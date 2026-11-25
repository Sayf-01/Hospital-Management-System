"""Run the Phase 2 pipeline against the frozen full dataset."""

import argparse
import csv
from collections import Counter
from dataclasses import dataclass
from importlib import import_module
from pathlib import Path
import sys
from tempfile import mkdtemp


ROOT = Path(__file__).resolve().parent
STAGES = ("Load", "Profile", "Clean", "Check", "Integrate", "Import", "Validate")
VALIDATION_RULES = tuple(range(1, 12))
MISSING_PRIMARY_RULE = 9
DEPENDENCIES = {
    "Load": ("phase2/load.py",),
    "Profile": ("reports/counts_raw.csv",),
    "Clean": ("phase2/clean.py", "schema/schema.sql"),
    "Check": ("pipeline/check_relations.py",),
    "Integrate": ("phase2/integrate.py", "sql/schema_v2.sql"),
    "Import": ("pipeline/import_db.py",),
    "Validate": ("sql/validation.sql",),
}


@dataclass(frozen=True)
class ValidationResult:
    violations: int
    missing_primary: int

    @property
    def unexpected(self):
        return self.violations - self.missing_primary


class Pipeline:
    def __init__(self, root, output):
        self.root = root
        self.output = output
        self.reports = output / "reports"
        self.reports.mkdir(parents=True, exist_ok=True)
        self.malformed = self.reports / "malformed_records.csv"
        self.cleaned = output / "data" / "clean"
        self.checked = output / "data" / "checked"
        self.quarantine = output / "data" / "quarantine"
        self.integrated = output / "data" / "integrated"

    def load(self):
        self.loader = import_module("phase2.load")
        self.data = self.loader.load_all(self.root / "data" / "raw" / "full", self.malformed)
        return f"{sum(len(frame) for tables in self.data.values() for frame in tables.values()):,} parsed records"

    def profile(self):
        # LA-1 provides the repository's existing source/entity volume profile.
        profile = self.loader.count_check(self.data, self.root / "reports" / "counts_raw.csv",
                                          self.malformed)
        profile.to_csv(self.reports / "counts_profile.csv", index=False, lineterminator="\n")
        if not profile["ok"].all():
            raise ValueError("Raw counts did not reconcile. See reports/counts_profile.csv.")
        return (f"{profile['loaded'].sum():,} parsed and {profile['malformed'].sum():,} malformed "
                f"across {len(profile)} source/entity groups (LA-1 count profile)")

    def clean(self):
        import pandas as pd

        cleaner = import_module("phase2.clean")
        malformed = pd.read_csv(self.malformed, dtype=str, keep_default_na=False)
        results = cleaner.clean_all(self.data, malformed)
        counts = cleaner.write_outputs(*results, self.cleaned, self.quarantine, self.reports)
        if not counts["reconciles"].all():
            raise ValueError("Clean counts did not reconcile. See reports/counts_clean.csv.")
        return f"{counts['rows_out'].sum():,} clean records"

    def check(self):
        checker = import_module("pipeline.check_relations")
        counts = checker.run(self.cleaned, self.checked, self.quarantine, self.reports)
        if not counts["reconciles"].all():
            raise ValueError("Check counts did not reconcile. See reports/counts_checked.csv.")
        return f"{counts['rows_out'].sum():,} accepted, {counts['quarantined'].sum():,} quarantined"

    def integrate(self):
        import pandas as pd

        integrator = import_module("phase2.integrate")
        # DA-3 exposes --input and uses module constants for its output paths.
        original = integrator.ROOT, integrator.CLEAN_DIR, integrator.OUT_DIR, integrator.REPORT_DIR
        argv = sys.argv
        try:
            integrator.ROOT = self.output
            integrator.OUT_DIR = self.integrated
            integrator.REPORT_DIR = self.reports
            sys.argv = [argv[0], "--input", str(self.checked)]
            integrator.main()
        finally:
            integrator.ROOT, integrator.CLEAN_DIR, integrator.OUT_DIR, integrator.REPORT_DIR = original
            sys.argv = argv
        counts = pd.read_csv(self.reports / "counts_integrated.csv",
                             dtype={"rows_in": str}, keep_default_na=False)
        # DA-3 writes integration rejections separately. Include the cleaner's
        # per-entity files and YO-2's sidecar in the database audit table too.
        quarantine_paths = sorted(self.quarantine.glob("*.csv"))
        quarantine_paths.append(self.integrated / "quarantine_integrate.csv")
        quarantine = pd.concat(
            [pd.read_csv(path, dtype=str, keep_default_na=False)[integrator.QUARANTINE_COLUMNS]
             for path in quarantine_paths],
            ignore_index=True,
        )
        quarantine.to_csv(self.integrated / "quarantine_records.csv", index=False, lineterminator="\n")
        counts.loc[len(counts)] = ["quarantine_records", str(len(quarantine)), len(quarantine), 0]
        counts.to_csv(self.reports / "counts_integrated.csv", index=False, lineterminator="\n")
        return f"{counts['rows_out'].sum():,} output rows, {counts['quarantined'].sum():,} integration rejections"

    def import_db(self, *, authorized):
        if not authorized:
            raise PermissionError("Database rebuild requires --allow-destructive-rebuild.")
        importer = import_module("pipeline.import_db")
        missing = [f"{table}.csv" for table in importer.LOAD_ORDER
                   if not (self.integrated / f"{table}.csv").is_file()]
        if missing:
            raise FileNotFoundError(f"Import inputs missing from DA-3 output: {', '.join(missing)}")
        with (self.reports / "counts_integrated.csv").open(encoding="utf-8", newline="") as stream:
            report = list(csv.DictReader(stream))
        expected = {row["table"]: int(row["rows_out"]) for row in report}
        if len(expected) != len(report) or set(expected) != set(importer.LOAD_ORDER):
            raise ValueError("counts_integrated.csv must list each import table exactly once.")
        with importer.connect() as conn:
            # Keep the rebuild and verification in one transaction, so a
            # count or sequence mismatch leaves the previous database intact.
            with conn.transaction():
                with conn.cursor() as cursor:
                    cursor.execute("SELECT current_database()")
                    if cursor.fetchone() != ("hospital_phase2",):
                        raise ValueError("Import requires the hospital_phase2 database.")
                importer.import_database(conn, self.integrated, allow_destructive=True)
                verify_import(conn, expected, self.reports)
        return f"{sum(expected.values()):,} rows imported across {len(expected)} tables"

    def validate(self):
        importer = import_module("pipeline.import_db")
        script = (self.root / "sql" / "validation.sql").read_text(encoding="utf-8")
        with importer.connect() as conn, conn.transaction(), conn.cursor() as cursor:
            cursor.execute("SET TRANSACTION READ ONLY")
            cursor.execute("SELECT current_database()")
            if cursor.fetchone() != ("hospital_phase2",):
                raise ValueError("Validation requires the hospital_phase2 database.")
            cursor.execute(script, prepare=False)
            columns = tuple(column.name for column in cursor.description or ())
            if columns != ("rule_id", "entity", "record_key", "detail"):
                raise ValueError("validation.sql returned an unexpected result shape.")
            results = cursor.fetchall()
            if cursor.nextset():
                raise ValueError("validation.sql must return one result set.")
        counts = Counter(row[0] for row in results)
        if set(counts).difference(VALIDATION_RULES):
            raise ValueError("validation.sql returned an unknown rule ID.")
        for rule in VALIDATION_RULES:
            note = " (documented data-quality limitation)" if rule == MISSING_PRIMARY_RULE and counts[rule] else ""
            print(f"  Rule {rule:02}: {counts[rule]:,} violation(s){note}")
        for rule, entity, key, detail in results:
            print(f"  Rule {rule:02} | {entity} | {key} | {detail}")
        return ValidationResult(len(results), counts[MISSING_PRIMARY_RULE])


def verify_import(conn, expected, reports):
    """Compare exact table counts and inspect identity state without advancing it."""
    from psycopg import sql

    counts = []
    identities = []
    with conn.cursor() as cursor:
        for table, target in expected.items():
            cursor.execute(sql.SQL("SELECT count(*) FROM {}").format(sql.Identifier("public", table)))
            (actual,) = cursor.fetchone()
            counts.append((table, target, actual))

        # The other tables enforce unique source keys or their corresponding
        # business keys. Quarantine only enforces uniqueness on its identity.
        cursor.execute(
            """SELECT count(*) - count(DISTINCT
                   (stage, source_code, entity, source_local_id, source_line, reason, raw_record))
               FROM public.quarantine_records"""
        )
        (duplicates,) = cursor.fetchone()
        cursor.execute(
            """SELECT table_name, column_name, identity_start, identity_increment,
                      parse_ident(pg_get_serial_sequence(
                          quote_ident(table_schema) || '.' || quote_ident(table_name), column_name))
               FROM information_schema.columns
               WHERE table_schema = 'public' AND table_name = ANY(%s) AND is_identity = 'YES'
               ORDER BY table_name, column_name""",
            (list(expected),),
        )
        for table, column, start, increment, sequence in cursor.fetchall():
            start, increment = int(start), int(increment)
            aggregate, limit = (sql.SQL("MAX"), max) if increment > 0 else (sql.SQL("MIN"), min)
            cursor.execute(sql.SQL("SELECT {}({}) FROM {}").format(
                aggregate, sql.Identifier(column), sql.Identifier("public", table),
            ))
            (value,) = cursor.fetchone()
            wanted = start if value is None else limit(start, value + increment)
            cursor.execute(sql.SQL("SELECT last_value, is_called FROM {}").format(sql.Identifier(*sequence)))
            last, called = cursor.fetchone()
            actual_next = last + increment if called else last
            identities.append((table, column, wanted, actual_next))

    for filename, header, rows in (
        ("counts_database.csv", ("table", "expected", "actual"), counts),
        ("identity_database.csv", ("table", "column", "expected_next", "actual_next"), identities),
    ):
        with (reports / filename).open("w", encoding="utf-8", newline="") as stream:
            writer = csv.writer(stream, lineterminator="\n")
            writer.writerow(header)
            writer.writerows(rows)
    mismatches = [f"{table}: expected {wanted}, got {actual}"
                  for table, wanted, actual in counts if wanted != actual]
    mismatches.extend(f"{table}.{column}: expected next ID {wanted}, got {actual}"
                      for table, column, wanted, actual in identities if wanted != actual)
    if duplicates:
        mismatches.append(f"quarantine_records contains {duplicates} duplicate audit rows")
    if mismatches:
        raise ValueError("Database reconciliation failed. " + "; ".join(mismatches))


def run_pipeline(pipeline, *, skip_import, authorized):
    statuses = dict.fromkeys(STAGES, "not run")
    validation = None
    for name, files in DEPENDENCIES.items():
        missing = [file for file in files if not (pipeline.root / file).is_file()]
        if missing:
            detail = "pending" if name == "Validate" else "unavailable"
            statuses[name] = f"{detail} ({', '.join(missing)})"

    if skip_import:
        statuses["Import"] = "skipped (--skip-import)"
        if statuses["Validate"] == "not run":
            statuses["Validate"] = "skipped (--skip-import)"
    elif not authorized:
        status = statuses["Import"]
        reason = "blocked (requires --allow-destructive-rebuild)"
        statuses["Import"] = reason if status == "not run" else f"{status}; {reason}"

    plan = (
        ("Load", pipeline.load), ("Profile", pipeline.profile), ("Clean", pipeline.clean),
        ("Check", pipeline.check), ("Integrate", pipeline.integrate),
        ("Import", lambda: pipeline.import_db(authorized=authorized)),
        ("Validate", pipeline.validate),
    )
    # Check required dependencies and authorization before starting work.
    required = STAGES[:5] if skip_import else STAGES[:6]
    if all(statuses[name] == "not run" for name in required):
        for name, execute in plan:
            if statuses[name] != "not run":
                continue
            print(f"[{name}] Running", flush=True)
            try:
                counts = execute()
            except Exception as exc:
                if name in ("Import", "Validate") and hasattr(exc, "sqlstate"):
                    error = f"{type(exc).__name__}, SQLSTATE {exc.sqlstate or 'unavailable'}"
                else:
                    error = str(exc)
                statuses[name] = f"failed ({error})"
                break
            if name == "Validate":
                validation = counts
                if validation.unexpected:
                    statuses[name] = f"violations found ({validation.unexpected} outside Rule 9)"
                elif validation.missing_primary:
                    statuses[name] = (
                        f"completed with {validation.missing_primary} documented Rule 9 violation(s)"
                    )
                else:
                    statuses[name] = "succeeded (0 violations)"
            else:
                statuses[name] = f"succeeded ({counts})"
                print(f"[{name}] {counts}")

    print("\nPipeline summary")
    for name, status in statuses.items():
        print(f"  {name:<10} {status}")
    if skip_import and all(statuses[name].startswith("succeeded") for name in STAGES[:5]):
        print("Data-processing stages completed. PostgreSQL stages were skipped.")
        return 0
    if validation is not None:
        if validation.unexpected:
            print("Pipeline ran, with integrity violations outside the documented Rule 9 limitation.")
            return 2
        if validation.missing_primary:
            print("Pipeline completed with documented Rule 9 violations.")
        else:
            print("Pipeline completed and all 11 validation rules passed.")
        return 0
    print("Requested pipeline run is incomplete.")
    return 1


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    database = parser.add_mutually_exclusive_group()
    database.add_argument("--skip-import", action="store_true",
                          help="Run data-processing stages only, without connecting to PostgreSQL")
    database.add_argument("--allow-destructive-rebuild", action="store_true",
                          help="Authorize dropping and recreating Phase 2 objects in hospital_phase2")
    args = parser.parse_args(argv)
    output = Path(mkdtemp(prefix="hospital-phase2-"))
    print(f"Run outputs: {output}")
    return run_pipeline(Pipeline(ROOT, output), skip_import=args.skip_import,
                        authorized=args.allow_destructive_rebuild)


if __name__ == "__main__":
    sys.exit(main())
