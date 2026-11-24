"""Import Phase 2 CSVs into the local PostgreSQL project database."""

import argparse
import csv
from pathlib import Path
import re
import sys

import pandas as pd
import psycopg
from dotenv import dotenv_values
from psycopg import sql


ROOT = Path(__file__).resolve().parents[1]
DATABASE = "hospital_phase2"
SCHEMA = "public"
SCHEMA_PATH = ROOT / "sql" / "schema_v2.sql"
TRIGGERS_PATH = ROOT / "sql" / "triggers.sql"
LOAD_ORDER = (
    "source_systems", "healthcare_professionals", "hospital_units",
    "icd9_dictionary", "patients", "patient_source_map",
    "patient_match_candidates", "admissions", "triage_assessments",
    "unit_stays", "clinical_notes", "diagnoses", "discharge_records",
    "diagnostic_orders", "diagnostic_examinations", "radiology_examinations",
    "radiology_reports", "surgical_procedures", "quarantine_records",
)


def connect():
    """Read local settings without producing a connection string in output."""
    settings = dotenv_values(ROOT / ".env")
    # The explicit dbname takes precedence over one supplied in a URL.
    return psycopg.connect(
        settings.get("DATABASE_URL") or "",
        dbname=DATABASE,
        **{
            option: value
            for option, db_key, pg_key in (
                ("host", "DB_HOST", "PGHOST"),
                ("port", "DB_PORT", "PGPORT"),
                ("user", "DB_USER", "PGUSER"),
                ("password", "DB_PASSWORD", "PGPASSWORD"),
            )
            if (value := settings.get(db_key) or settings.get(pg_key))
        },
    )


def _require_phase2(conn):
    if conn.info.dbname != DATABASE:
        raise ValueError(f"This operation requires the {DATABASE} database.")


def _read_schema():
    if not SCHEMA_PATH.is_file():
        raise FileNotFoundError(f"Required schema file is missing: {SCHEMA_PATH}")
    scripts = [(SCHEMA_PATH, SCHEMA_PATH.read_text(encoding="utf-8"))]
    if TRIGGERS_PATH.is_file():
        scripts.append((TRIGGERS_PATH, TRIGGERS_PATH.read_text(encoding="utf-8")))
    return scripts


def rebuild_schema(conn, *, allow_destructive=False):
    """Execute the schema scripts in the caller's import transaction."""
    _require_phase2(conn)
    scripts = _read_schema()
    for path, script in scripts:
        # Conservative check for the repository's local SQL scripts. Matching
        # a keyword in a comment or function body also requires approval.
        if re.search(r"\b(DROP|TRUNCATE|DELETE)\b", script, re.IGNORECASE):
            if not allow_destructive:
                raise ValueError(f"{path.name} contains potentially destructive SQL. "
                                 "Explicit rebuild approval is required.")

    with conn.cursor() as cursor:
        cursor.execute("SET LOCAL search_path TO public")
        for path, script in scripts:
            try:
                cursor.execute(script, prepare=False)
            except psycopg.Error as exc:
                raise RuntimeError(f"{path.name} failed ({_error_code(exc)}).") from None


def _read_csv(csv_path):
    # Keep codes such as 038.9, and treat only empty fields as missing.
    with Path(csv_path).open(encoding="utf-8-sig", newline="") as stream:
        reader = csv.reader(stream, strict=True)
        header = next(reader, [])
        if not header or "" in header or len(header) != len(set(header)):
            raise ValueError("CSV header must contain unique, nonempty column names.")
        try:
            for number, record in enumerate(reader, start=2):
                if len(record) != len(header):
                    raise ValueError(f"CSV row {number} has {len(record)} fields, "
                                     f"expected {len(header)}.")
        except csv.Error as exc:
            raise ValueError(f"CSV syntax error at line {reader.line_num}: {exc}") from None
        stream.seek(0)
        frame = pd.read_csv(stream, dtype=str, keep_default_na=False,
                            na_values=[""], skip_blank_lines=False)
    return frame.astype(object).where(frame.notna(), None)


def _error_code(exc):
    return f"{type(exc).__name__}, SQLSTATE {exc.sqlstate or 'unavailable'}"


def load_table(conn, table, csv_path):
    """Insert a CSV with its header as the column list and return its row count."""
    _require_phase2(conn)
    if table not in LOAD_ORDER:
        raise ValueError(f"Unknown Phase 2 table: {table!r}")
    try:
        frame = _read_csv(csv_path)
    except csv.Error as exc:
        raise ValueError(f"{table}: CSV syntax error: {exc}") from None
    except (OSError, ValueError) as exc:
        raise ValueError(f"{table}: {exc}") from None
    columns = list(frame.columns)

    with conn.cursor() as cursor:
        cursor.execute(
            """SELECT column_name, identity_generation
               FROM information_schema.columns
               WHERE table_schema = %s AND table_name = %s
                 AND is_generated = 'NEVER'""",
            (SCHEMA, table),
        )
        available = dict(cursor.fetchall())
        if not available:
            raise ValueError(f"Target table {SCHEMA}.{table} is missing or inaccessible.")
        unknown = set(columns) - available.keys()
        if unknown:
            raise ValueError(f"{table}: unknown or generated columns: {sorted(unknown)}")

        override = (sql.SQL(" OVERRIDING SYSTEM VALUE")
                    if any(available[column] == "ALWAYS" for column in columns)
                    else sql.SQL(""))
        statement = sql.SQL("INSERT INTO {} ({}){} VALUES ({})").format(
            sql.Identifier(SCHEMA, table),
            sql.SQL(", ").join(map(sql.Identifier, columns)),
            override,
            sql.SQL(", ").join(sql.Placeholder() for _ in columns),
        )
        rows = list(frame.itertuples(index=False, name=None))
        if not rows:
            return 0
        try:
            # Roll back the batch to a savepoint before diagnosing a bad row.
            with conn.transaction():
                cursor.executemany(statement, rows)
        except psycopg.Error as batch_error:
            with conn.transaction(force_rollback=True):
                for number, row in enumerate(rows, start=2):
                    try:
                        cursor.execute(statement, row)
                    except psycopg.Error as exc:
                        raise RuntimeError(
                            f"{table}: CSV row {number} failed ({_error_code(exc)})."
                        ) from None
            raise RuntimeError(f"{table}: batch insert failed "
                               f"({_error_code(batch_error)}).") from None
    return len(rows)


def reset_identity_sequences(conn):
    """Restart actual identity columns transactionally after explicit inserts."""
    _require_phase2(conn)
    with conn.cursor() as cursor:
        cursor.execute(
            """SELECT table_name, column_name, identity_start, identity_increment
               FROM information_schema.columns
               WHERE table_schema = %s AND table_name = ANY(%s)
                 AND is_identity = 'YES'""",
            (SCHEMA, list(LOAD_ORDER)),
        )
        for table, column, start, increment in cursor.fetchall():
            start, increment = int(start), int(increment)
            table_name = sql.Identifier(SCHEMA, table)
            column_name = sql.Identifier(column)
            extreme = sql.SQL("MAX" if increment > 0 else "MIN")
            cursor.execute(sql.SQL("SELECT {}({}) FROM {}").format(
                extreme, column_name, table_name,
            ))
            (value,) = cursor.fetchone()
            restart = start
            if value is not None:
                limit = max if increment > 0 else min
                restart = limit(start, value + increment)
            cursor.execute(sql.SQL("ALTER TABLE {} ALTER COLUMN {} RESTART WITH {}").format(
                table_name, column_name, sql.Literal(restart),
            ))


def import_database(conn, csv_dir, *, allow_destructive=False):
    """Rebuild and load the complete dataset as one atomic operation."""
    _require_phase2(conn)
    paths = {table: Path(csv_dir) / f"{table}.csv" for table in LOAD_ORDER}
    missing = [path.name for path in paths.values() if not path.is_file()]
    if missing:
        raise FileNotFoundError(f"Missing integrated CSVs in {csv_dir}: {', '.join(missing)}")
    with conn.transaction():
        rebuild_schema(conn, allow_destructive=allow_destructive)
        counts = {table: load_table(conn, table, path) for table, path in paths.items()}
        reset_identity_sequences(conn)
    return counts


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--check-connection", action="store_true")
    action.add_argument("--csv-dir", type=Path, help="Directory of integrated table CSVs")
    parser.add_argument(
        "--allow-destructive-rebuild", action="store_true",
        help="Approve dropping and recreating Phase 2 tables and setting its timezone to UTC",
    )
    args = parser.parse_args(argv)
    try:
        if args.check_connection:
            with connect() as conn:
                _require_phase2(conn)
                with conn.cursor() as cursor:
                    cursor.execute("SELECT current_database()")
                    (database,) = cursor.fetchone()
            print(f"Connected to {database}.")
        else:
            if not SCHEMA_PATH.is_file():
                raise FileNotFoundError(f"Required schema file is missing: {SCHEMA_PATH}")
            if not TRIGGERS_PATH.is_file():
                print("Optional trigger script is missing: sql/triggers.sql", file=sys.stderr)
            with connect() as conn:
                counts = import_database(
                    conn, args.csv_dir, allow_destructive=args.allow_destructive_rebuild,
                )
            for table, count in counts.items():
                print(f"{table}: {count} rows")
    except psycopg.Error as exc:
        print(f"PostgreSQL operation failed ({_error_code(exc)}).", file=sys.stderr)
        return 1
    except (OSError, ValueError, RuntimeError) as exc:
        print(exc, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
