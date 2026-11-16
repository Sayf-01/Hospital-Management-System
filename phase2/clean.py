"""SA-3: clean and standardize the four raw sources (Task 2, items 1-8).

Run from the repository root:
    python phase2/clean.py                 # sample data (data/raw/sample)
    python phase2/clean.py --scale full    # full data (data/raw/full)

Input:  LA-1's load_all() -> {"A": {entity: DataFrame}, ...}, every value as raw text.
Output (every run rebuilds them from scratch, so a rerun gives identical files):
    data/clean/<entity>.csv          accepted records, all sources stacked
    data/quarantine/<entity>.csv     rejected records, each with a reason
    reports/counts_clean.csv         rows in / out / removed per source and entity
    reports/cleaning_log.csv         every corrected, nulled, flagged or rejected value
    reports/cleaning_examples.csv    before/after examples (2 per problem per source)
    reports/patient_id_remap.csv     within-source duplicate patients: old ID -> kept ID
    reports/cleaning_summary.csv     problem counts per source (for the report)

Rules come from phase2/docs/cleaning_rules.md (SA-2). Which columns are required,
their types and their maximum lengths are read straight from schema/schema.sql,
so a column is required exactly when Phase 1 marks it NOT NULL.

Stages
    1. clean_entity()          items 1-6: missing values, exact duplicates, text,
                               dates/timestamps, numbers/units, categories, ICD-9
    2. merge_duplicate_patients() item 2: duplicate patients inside one source
    3. check_relationships()   item 7: missing parents, inconsistent references
    4. check_chronology()      item 8: admission, discharge, exam, procedure and
                               unit-stay timestamps
Nothing is invented: a value is corrected only when the correct value is certain;
otherwise an optional value becomes NULL (and is logged) and a record with a bad
required value goes to quarantine with a reason.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timedelta, timezone
from decimal import ROUND_HALF_UP, Decimal, InvalidOperation
from pathlib import Path
from zoneinfo import ZoneInfo

import pandas as pd

PHASE2_DIR = Path(__file__).resolve().parent
if str(PHASE2_DIR) not in sys.path:
    sys.path.insert(0, str(PHASE2_DIR))

import load  # noqa: E402  (LA-1 loaders)
from config.source_maps import FIELD_MAPS, SOURCE_TIME_ZONES  # noqa: E402
from config.value_maps import VALUE_MAPS, map_category  # noqa: E402

ROOT = PHASE2_DIR.parent
SCHEMA_PATH = ROOT / "schema" / "schema.sql"
OUTPUT_DIR = ROOT / "data" / "clean"
QUARANTINE_DIR = ROOT / "data" / "quarantine"
REPORT_DIR = ROOT / "reports"

SOURCES = ("A", "B", "C", "D")

# Parents before children, so references can be checked in one pass.
ENTITY_ORDER = (
    "healthcare_professionals",
    "hospital_units",
    "icd9_dictionary",
    "patients",
    "admissions",
    "triage_assessments",
    "unit_stays",
    "diagnoses",
    "clinical_notes",
    "discharge_records",
    "diagnostic_orders",
    "diagnostic_examinations",
    "radiology_examinations",
    "radiology_reports",
    "surgical_procedures",
)

ENTITY_PRIMARY_KEYS = {
    "patients": "patient_id",
    "admissions": "admission_id",
    "triage_assessments": "triage_id",
    "unit_stays": "unit_stay_id",
    "diagnoses": "diagnosis_id",
    "clinical_notes": "note_id",
    "discharge_records": "discharge_id",
    "diagnostic_orders": "order_id",
    "diagnostic_examinations": "examination_id",
    "radiology_examinations": "radiology_id",
    "radiology_reports": "report_id",
    "surgical_procedures": "procedure_id",
    "healthcare_professionals": "professional_id",
    "hospital_units": "unit_id",
    "icd9_dictionary": "icd9_code",
}

# Every source text in this list counts as "no value" (rules doc, Missing values).
MISSING_MARKERS = {"", "null", "n/a", "na", "-", "?", "none"}

# Free-text columns: only trimmed. Other text columns also get runs of spaces collapsed.
FREE_TEXT_TYPE = "text"

DATE_FORMATS = {"A": "%Y-%m-%d", "B": "%d.%m.%Y", "C": "%Y-%m-%d", "D": "%d/%m/%Y"}
B_TIMESTAMP_FORMAT = "%d.%m.%Y %H:%M"
D_TIMESTAMP_FORMAT = "%d/%m/%Y %I:%M %p"

# Valid ranges from the rules doc (inclusive), in the units stored in the database.
NUMERIC_RANGES = {
    "heart_rate": (20, 250),
    "respiratory_rate": (4, 60),
    "body_temperature": (30.0, 45.0),
    "oxygen_saturation": (50.0, 100.0),
    "pain_level": (0, 10),
}
INTEGER_MEASURES = {"heart_rate", "respiratory_rate", "pain_level"}
POSTGRES_INTEGER_MAX = 2_147_483_647

ICD9_PATTERN = re.compile(r"^(\d{3}(\.\d{1,2})?|V\d{2}(\.\d{1,2})?|E\d{3}(\.\d)?)$")
BLOOD_PRESSURE_PATTERN = re.compile(r"^\d{2,3}/\d{2,3}$")

# Item 7: (column, parent entity, required?) for every reference inside one source.
REFERENCES = {
    "admissions": [
        ("source_patient_id", "patients", True),
        ("source_admitting_professional_id", "healthcare_professionals", False),
    ],
    "triage_assessments": [
        ("source_admission_id", "admissions", True),
        ("source_nurse_id", "healthcare_professionals", False),
    ],
    "unit_stays": [
        ("source_admission_id", "admissions", True),
        ("source_unit_id", "hospital_units", True),
        ("source_responsible_physician_id", "healthcare_professionals", False),
    ],
    "diagnoses": [
        ("source_patient_id", "patients", True),
        ("source_admission_id", "admissions", True),
        ("icd9_code", "icd9_dictionary", True),
        ("source_diagnosing_physician_id", "healthcare_professionals", False),
    ],
    "clinical_notes": [
        ("source_admission_id", "admissions", True),
        ("source_author_id", "healthcare_professionals", True),
    ],
    "discharge_records": [
        ("source_admission_id", "admissions", True),
        ("source_responsible_physician_id", "healthcare_professionals", False),
    ],
    "diagnostic_orders": [
        ("source_patient_id", "patients", True),
        ("source_admission_id", "admissions", True),
        ("source_ordering_physician_id", "healthcare_professionals", True),
    ],
    "diagnostic_examinations": [
        ("source_order_id", "diagnostic_orders", True),
        ("source_performed_by_id", "healthcare_professionals", False),
    ],
    "radiology_examinations": [
        ("source_examination_id", "diagnostic_examinations", True),
        ("source_referring_physician_id", "healthcare_professionals", False),
        ("source_technician_id", "healthcare_professionals", False),
    ],
    "radiology_reports": [
        ("source_radiology_id", "radiology_examinations", True),
        ("source_radiologist_id", "healthcare_professionals", True),
    ],
    "surgical_procedures": [
        ("source_admission_id", "admissions", True),
        ("source_surgeon_id", "healthcare_professionals", True),
    ],
}

# Item 8: the event timestamp of each child that must fall inside its admission.
EVENTS_INSIDE_ADMISSION = {
    "diagnoses": "diagnosis_datetime",
    "clinical_notes": "note_datetime",
    "diagnostic_orders": "order_datetime",
    "surgical_procedures": "procedure_datetime",
}
# Triage may be recorded shortly before the admission is opened (team guide, YO-2 rule).
TRIAGE_BEFORE_ADMISSION = timedelta(hours=24)

# Expected standardization of every row (not a data problem): kept out of
# cleaning_log.csv but used for before/after examples.
ROUTINE_CONVERSIONS = ["timestamp_to_utc", "date_reformatted", "category_mapped", "fahrenheit_to_celsius"]

LOG_COLUMNS = [
    "source_code", "entity", "source_local_id", "source_line", "stage",
    "problem_type", "column", "raw_value", "cleaned_value", "action",
]
QUARANTINE_COLUMNS = [
    "source_code", "entity", "source_local_id", "source_line", "stage",
    "reason", "raw_values",
]


# --------------------------------------------------------------------------
# Schema: required columns, types and lengths come from schema/schema.sql
# --------------------------------------------------------------------------

def read_schema(path: Path = SCHEMA_PATH) -> dict[str, dict[str, dict]]:
    """Return {table: {column: {"type", "length", "required"}}} from the Phase 1 DDL."""
    text = path.read_text(encoding="utf-8")
    tables = {}
    for match in re.finditer(r"CREATE TABLE public\.(\w+) \((.*?)\n\);", text, re.S):
        columns = {}
        for line in match.group(2).split("\n"):
            column = re.match(
                r"\s{4}(\w+) (character varying\((\d+)\)|integer|text|date|"
                r"numeric\(\d+,\d+\)|timestamp without time zone)(.*)$",
                line,
            )
            if column is None:
                continue
            kind = column.group(2)
            if kind.startswith("character varying"):
                kind = "varchar"
            elif kind.startswith("numeric"):
                kind = "numeric"
            elif kind.startswith("timestamp"):
                kind = "timestamp"
            columns[column.group(1)] = {
                "type": kind,
                "length": int(column.group(3)) if column.group(3) else None,
                "required": "NOT NULL" in column.group(4),
            }
        tables[match.group(1)] = columns
    return tables


def clean_column_name(entity: str, column: str) -> str:
    """Name a Phase 1 column takes in the clean files (IDs are still source IDs)."""
    if column == ENTITY_PRIMARY_KEYS[entity] and entity != "icd9_dictionary":
        return "source_local_id"
    if column.endswith("_id"):
        return f"source_{column}"
    return column


# --------------------------------------------------------------------------
# Small helpers
# --------------------------------------------------------------------------

def is_missing(value: object) -> bool:
    """True for None/NaN and for every missing-value marker used by the sources."""
    if value is None:
        return True
    if isinstance(value, str):
        return " ".join(value.split()).casefold() in MISSING_MARKERS
    try:
        return bool(pd.isna(value))
    except (TypeError, ValueError):
        return False


def raw_json(row: pd.Series) -> str:
    """Keep the untouched source record as JSON text for quarantine and the log."""
    values = {
        str(key): (None if value is None else str(value))
        for key, value in row.items()
        if key not in ("_source", "_file", "_line")
    }
    return json.dumps(values, ensure_ascii=False)


class CleaningLog:
    """Collects one line per corrected, nulled, flagged or rejected value."""

    def __init__(self) -> None:
        self.rows: list[dict] = []

    def add_rows(self, records: pd.DataFrame) -> None:
        """Add a table of log lines (one per value), keeping their order."""
        records = records[LOG_COLUMNS].copy()
        for column in ("raw_value", "cleaned_value"):
            records[column] = records[column].map(lambda value: None if is_missing(value) else str(value))
        self.rows.extend(records.to_dict("records"))

    def frame(self) -> pd.DataFrame:
        return pd.DataFrame(self.rows, columns=LOG_COLUMNS)


def log_records(log: CleaningLog, source: str, entity: str, rows: pd.DataFrame, stage: str,
                problem, column: str, raw_values, cleaned_values, action) -> None:
    """Log one line for each row in `rows`. problem/raw/cleaned/action: one value or a column."""
    if rows.empty:
        return
    log.add_rows(pd.DataFrame({
        "source_code": source,
        "entity": entity,
        "source_local_id": rows["source_local_id"],
        "source_line": rows["_line"],
        "stage": stage,
        "problem_type": problem,
        "column": column,
        "raw_value": raw_values,
        "cleaned_value": cleaned_values,
        "action": action,
    }))


def add_quarantine(quarantine_rows: list, rows: pd.DataFrame, entity: str, stage: str, reason) -> None:
    """Copy rejected rows (with their untouched raw values) into the quarantine list."""
    if rows.empty:
        return
    table = pd.DataFrame({
        "source_code": rows["source_code"],
        "entity": entity,
        "source_local_id": rows["source_local_id"],
        "source_line": rows["_line"],
        "stage": stage,
        "reason": reason,
        "raw_values": rows["_raw_values"],
    })
    quarantine_rows.extend(table.to_dict("records"))


def add_reason(reasons: pd.Series, mask: pd.Series, text) -> pd.Series:
    """Append a rejection reason to the rows in `mask` (text: one string or a column)."""
    reasons = reasons.copy()
    reasons.loc[mask] = (reasons[mask] + "; " + text).str.lstrip("; ")
    return reasons


# --------------------------------------------------------------------------
# Item 1: missing values
# --------------------------------------------------------------------------

def normalize_missing(df: pd.DataFrame) -> pd.DataFrame:
    """Replace every missing-value marker ("", NULL, N/A, -, ?, none ...) with None."""
    result = df.copy()
    for column in result.columns:
        result[column] = result[column].map(lambda value: None if is_missing(value) else value)
        result[column] = result[column].astype(object)
    return result


# --------------------------------------------------------------------------
# Item 3: text and identifiers
# --------------------------------------------------------------------------

def clean_text(value: str, kind: str, length: int | None) -> tuple[str | None, str | None]:
    """Trim; collapse runs of spaces in short text. Returns (value, problem)."""
    text = str(value).strip() if kind == FREE_TEXT_TYPE else " ".join(str(value).split())
    if text == "":
        return None, None
    if length is not None and len(text) > length:
        return None, "text_too_long"
    return text, None


def clean_id(value: str) -> tuple[str | None, str | None]:
    """IDs must be whole numbers that fit a PostgreSQL integer."""
    text = str(value).strip()
    if not re.fullmatch(r"\d+", text) or int(text) > POSTGRES_INTEGER_MAX:
        return None, "invalid_id"
    return str(int(text)), None


# --------------------------------------------------------------------------
# Item 6: clinical categories
# --------------------------------------------------------------------------

def clean_category(value: str, source: str, column: str) -> tuple[str | None, str | None]:
    """Map a source label to its Phase 1 value with SA-2's value_maps."""
    try:
        return map_category(source, column, value), None
    except ValueError:
        return None, "unknown_category"


# --------------------------------------------------------------------------
# Item 4: dates and timestamps
# --------------------------------------------------------------------------

def to_utc_wall_time(local: datetime, zone: ZoneInfo) -> tuple[datetime | None, str | None]:
    """Attach the source time zone and convert to UTC.

    A wall time that does not exist (spring-forward gap) or exists twice
    (fall-back hour) cannot be converted with certainty, so it is invalid.
    """
    first = local.replace(tzinfo=zone, fold=0)
    second = local.replace(tzinfo=zone, fold=1)
    if first.utcoffset() != second.utcoffset():
        return None, "ambiguous_or_missing_local_time"
    utc = first.astimezone(timezone.utc)
    if utc.astimezone(zone).replace(tzinfo=None) != local:
        return None, "ambiguous_or_missing_local_time"
    return utc.replace(tzinfo=None), None


def day_first_is_ambiguous(text: str) -> bool:
    """D writes DD/MM/YYYY. If day and month are both <= 12 and differ, MM/DD also fits."""
    day, month = (int(part) for part in text.split("/")[:2])
    return day <= 12 and month <= 12 and day != month


def parse_timestamp(value: str, source: str) -> tuple[str | None, str | None, str | None]:
    """Return (UTC wall time 'YYYY-MM-DD HH:MM:SS', problem, note)."""
    text = str(value).strip()
    zone = ZoneInfo(SOURCE_TIME_ZONES[source])
    note = None
    try:
        if source == "D" and re.fullmatch(r"\d+", text):
            # Unix epoch seconds are already an instant: no time zone needed.
            utc = datetime.fromtimestamp(int(text), tz=timezone.utc).replace(tzinfo=None)
            return utc.strftime("%Y-%m-%d %H:%M:%S"), None, None
        if source in ("A", "C"):
            parsed = datetime.fromisoformat(text)
        elif source == "B":
            parsed = datetime.strptime(text, B_TIMESTAMP_FORMAT)
        else:
            parsed = datetime.strptime(text, D_TIMESTAMP_FORMAT)
            if day_first_is_ambiguous(text):
                note = "ambiguous_day_first_assumed"
    except (ValueError, OverflowError, OSError):
        return None, "invalid_timestamp", None

    if parsed.tzinfo is not None:
        # An explicit offset (C writes +09:00) is the most certain information.
        utc = parsed.astimezone(timezone.utc).replace(tzinfo=None)
    else:
        utc, problem = to_utc_wall_time(parsed, zone)
        if problem:
            return None, problem, None
    return utc.strftime("%Y-%m-%d %H:%M:%S"), None, note


def parse_date(value: str, source: str) -> tuple[str | None, str | None, str | None]:
    """Calendar dates (date of birth) keep their date: no time zone is applied."""
    text = str(value).strip()
    try:
        parsed = datetime.strptime(text, DATE_FORMATS[source])
    except ValueError:
        return None, "invalid_date", None
    note = "ambiguous_day_first_assumed" if source == "D" and day_first_is_ambiguous(text) else None
    return parsed.strftime("%Y-%m-%d"), None, note


# --------------------------------------------------------------------------
# Item 5: numbers and units
# --------------------------------------------------------------------------

def round_one_decimal(number: Decimal) -> Decimal:
    """numeric(4,1) rounds half away from zero; do the same here."""
    return number.quantize(Decimal("0.1"), rounding=ROUND_HALF_UP)


def clean_measurement(value: str, source: str, column: str) -> tuple[str | None, str | None, str | None]:
    """Return (value as text, problem, note). Converts B's decimal comma and A's degrees F."""
    text = str(value).strip()
    note = None
    if source == "B":
        text = text.replace(",", ".")
    try:
        number = Decimal(text)
    except InvalidOperation:
        return None, "invalid_number", None
    if not number.is_finite():
        return None, "invalid_number", None
    if column in INTEGER_MEASURES:
        if number != number.to_integral_value():
            return None, "invalid_number", None
        number = number.to_integral_value()
    else:
        if source == "A" and column == "body_temperature":
            number = (number - 32) * 5 / 9
            note = "fahrenheit_to_celsius"
        number = round_one_decimal(number)
    lower, upper = NUMERIC_RANGES[column]
    if not lower <= number <= upper:
        return None, "out_of_range", None
    return str(number), None, note


def clean_blood_pressure(value: str) -> tuple[str | None, str | None]:
    """Blood pressure is text like 120/80; only its form is checked."""
    text = str(value).strip()
    if not BLOOD_PRESSURE_PATTERN.fullmatch(text):
        return None, "invalid_blood_pressure"
    return text, None


# --------------------------------------------------------------------------
# ICD-9 codes (rules doc: repair only on a unique dictionary match)
# --------------------------------------------------------------------------

def icd9_key(code: str) -> tuple[str, str]:
    """Compare codes without the dot and without leading zeros: 038.9 ~ 0389 ~ 38.9."""
    whole, _, fraction = code.partition(".")
    return (whole + fraction).lstrip("0"), fraction


def fix_icd9(code: str, dictionary_codes: set[str]) -> tuple[str | None, str | None]:
    """Return (canonical code, problem). Never guesses between two possible codes."""
    text = str(code).strip().upper()
    if text in dictionary_codes:
        return text, None
    digits, fraction = icd9_key(text)
    matches = [
        known for known in dictionary_codes
        if icd9_key(known)[0] == digits and ("." not in text or icd9_key(known)[1] == fraction)
    ]
    if len(matches) == 1:
        return matches[0], None
    if len(matches) > 1:
        return None, "icd9_ambiguous"
    return None, "icd9_not_in_dictionary"


# --------------------------------------------------------------------------
# Item 2: exact duplicates and duplicate patients
# --------------------------------------------------------------------------

def find_exact_duplicates(raw: pd.DataFrame) -> pd.Series:
    """True for every repeated copy of a row (all fields equal after trimming)."""
    compared = [column for column in raw.columns if column not in ("_source", "_file", "_line")]
    trimmed = raw[compared].map(lambda value: None if value is None else str(value).strip())
    kept = trimmed.drop_duplicates(keep="first")
    return pd.Series(~raw.index.isin(kept.index), index=raw.index)


def merge_duplicate_patients(patients: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Keep the lowest local ID for each identity inside one source.

    Identity = first name + last name (spaces collapsed, case ignored), date of
    birth, and insurance number (trimmed, case ignored). No insurance, no match.
    Returns (kept patients, remap table with old_patient_id -> kept_patient_id).
    """
    if patients.empty:
        return patients.copy(), pd.DataFrame(columns=["source_code", "old_patient_id", "kept_patient_id"])
    patients = patients.reset_index(drop=True)
    work = patients.copy()
    work["_first"] = work["first_name"].map(lambda name: " ".join(str(name).split()).casefold())
    work["_last"] = work["last_name"].map(lambda name: " ".join(str(name).split()).casefold())
    work["_insurance"] = work["health_insurance_number"].map(
        lambda number: None if is_missing(number) else str(number).strip().casefold())
    work["_order"] = work["source_local_id"].astype(int)
    work = work.sort_values(["source_code", "_order"], kind="stable")
    keyed = work[work["_insurance"].notna()]

    key = ["source_code", "_first", "_last", "date_of_birth", "_insurance"]
    lowest = keyed.drop_duplicates(subset=key, keep="first")[key + ["source_local_id"]]
    lowest = lowest.rename(columns={"source_local_id": "kept_patient_id"})
    matched = pd.merge(keyed.reset_index(), lowest, on=key, how="left").set_index("index")
    duplicate = matched[matched["source_local_id"] != matched["kept_patient_id"]]

    remap = pd.DataFrame({
        "source_code": duplicate["source_code"],
        "old_patient_id": duplicate["source_local_id"],
        "kept_patient_id": duplicate["kept_patient_id"],
    })
    kept = patients.drop(index=duplicate.index)
    return kept, remap.reset_index(drop=True)


# --------------------------------------------------------------------------
# Stage 1: clean one table of one source (items 1-6)
# --------------------------------------------------------------------------

def rename_fields(df: pd.DataFrame, source: str, entity: str) -> pd.DataFrame:
    """Raw names -> Phase 1 names (KR-1 FIELD_MAPS) -> clean-file names (source IDs)."""
    field_map = FIELD_MAPS[(source, entity)]
    unmapped = set(df.columns) - set(field_map) - {"_source", "_file", "_line"}
    if unmapped:
        raise ValueError(f"Unmapped columns for {source} {entity}: {', '.join(sorted(unmapped))}")
    result = df.rename(columns=field_map)
    return result.rename(columns={column: clean_column_name(entity, column) for column in field_map.values()})


def clean_value(value: str, column: str, spec: dict, source: str, entity: str,
                dictionary_codes: set[str]) -> tuple[str | None, str | None, str | None]:
    """Clean one value that is present, using its Phase 1 type.

    Returns (cleaned value, problem, event). A problem means the value is unusable;
    an event names a correction or conversion that goes in the log.
    """
    event = None
    if spec["type"] == "integer" and column.endswith("_id"):
        cleaned, problem = clean_id(value)
    elif column in NUMERIC_RANGES:
        cleaned, problem, event = clean_measurement(value, source, column)
    elif spec["type"] == "timestamp":
        cleaned, problem, event = parse_timestamp(value, source)
    elif spec["type"] == "date":
        cleaned, problem, event = parse_date(value, source)
    elif column == "icd9_code" and entity == "icd9_dictionary":
        cleaned = str(value).strip().upper()
        problem = None if ICD9_PATTERN.fullmatch(cleaned) else "invalid_icd9_format"
    elif column == "icd9_code":
        cleaned, problem = fix_icd9(value, dictionary_codes)
        if problem is None and cleaned != str(value).strip():
            event = "icd9_format_repaired"
    elif column in VALUE_MAPS:
        cleaned, problem = clean_category(value, source, column)
        tidy_labels = {label for label in VALUE_MAPS[column][source] if label == " ".join(label.split())}
        if problem is None and str(value) not in tidy_labels:
            event = "category_case_or_space"
        elif problem is None and str(value) != cleaned:
            event = "category_mapped"
    elif column == "blood_pressure":
        cleaned, problem = clean_blood_pressure(value)
    else:
        cleaned, problem = clean_text(value, spec["type"], spec["length"])
        if problem is None and cleaned != value:
            event = "whitespace_trimmed"
    if problem is None and cleaned is not None and spec["length"] and len(cleaned) > spec["length"]:
        problem = "text_too_long"
    if problem is not None:
        return None, problem, None
    if event is None and spec["type"] == "timestamp":
        event = "timestamp_to_utc"          # routine: used for before/after examples
    elif event is None and spec["type"] == "date" and cleaned != value:
        event = "date_reformatted"          # routine: used for before/after examples
    return cleaned, None, event


def event_action(event: str) -> str:
    if event.startswith("ambiguous"):
        return "kept, assumption logged"
    if event in ("timestamp_to_utc", "date_reformatted"):
        return "converted"
    return "corrected"


def clean_entity(raw: pd.DataFrame, source: str, entity: str, schema: dict,
                 dictionary_codes: set[str], log: CleaningLog) -> tuple[pd.DataFrame, pd.DataFrame, dict]:
    """Clean one source table. Returns (clean rows, quarantined rows, counts)."""
    columns = schema[entity]
    counts = {"rows_in": len(raw), "exact_duplicates": 0}
    raw = raw.reset_index(drop=True)
    raw_values = raw.apply(raw_json, axis=1) if len(raw) else pd.Series(dtype=object)
    df = rename_fields(raw, source, entity)
    df["_raw_values"] = raw_values
    df["_line"] = raw["_line"]
    df.insert(0, "source_code", source)
    for column in columns:
        name = clean_column_name(entity, column)
        if name not in df.columns:
            df[name] = None  # C/D can leave an empty field out entirely
    id_column = "icd9_code" if entity == "icd9_dictionary" else "source_local_id"
    if entity == "icd9_dictionary":
        df["source_local_id"] = df["icd9_code"].map(lambda value: None if value is None else str(value).strip())

    # Item 2: exact duplicate rows (compared on the raw values, trimmed).
    duplicate = find_exact_duplicates(raw)
    log_records(log, source, entity, df[duplicate], "clean", "exact_duplicate", "(row)",
                df.loc[duplicate, "_raw_values"], None, "removed")
    df = df[~duplicate].copy()
    counts["exact_duplicates"] = int(duplicate.sum())

    # Item 1: one representation for "no value".
    before_missing = df.copy()
    value_columns = [clean_column_name(entity, column) for column in columns]
    df[value_columns] = normalize_missing(df[value_columns])

    reasons = pd.Series("", index=df.index, dtype=object)

    # Items 3-6, one column at a time, using its Phase 1 type.
    for column, spec in columns.items():
        name = clean_column_name(entity, column)
        required = spec["required"]
        values = df[name]
        missing = values.isna()
        results = values.apply(
            lambda value: (None, None, None) if is_missing(value)
            else clean_value(value, column, spec, source, entity, dictionary_codes))
        cleaned = results.map(lambda result: result[0])
        problem = results.map(lambda result: result[1])
        event = results.map(lambda result: result[2])
        has_problem = problem.notna()
        has_event = event.notna()
        df[name] = cleaned.astype(object)          # NULL where missing or unusable

        # One log line per value that was missing, unusable, corrected or converted.
        # raw_value shows how the source wrote "nothing": "", NULL, N/A, a missing key...
        log_table = pd.DataFrame(index=df.index, columns=["problem_type", "raw_value", "cleaned_value", "action"],
                                 dtype=object)
        log_table.loc[missing, "problem_type"] = "missing_required" if required else "missing_optional"
        log_table.loc[missing, "action"] = "quarantined" if required else "kept as NULL"
        log_table.loc[missing, "raw_value"] = before_missing.loc[missing, name].map(
            lambda value: "(absent)" if value is None else repr(str(value)))
        log_table.loc[has_problem, "problem_type"] = problem[has_problem]
        log_table.loc[has_problem, "action"] = "quarantined" if required else "set to NULL"
        log_table.loc[has_problem, "raw_value"] = values[has_problem]
        log_table.loc[has_event, "problem_type"] = event[has_event]
        log_table.loc[has_event, "action"] = event[has_event].map(event_action)
        log_table.loc[has_event, "raw_value"] = values[has_event]
        log_table.loc[has_event, "cleaned_value"] = cleaned[has_event]
        logged = log_table[log_table["problem_type"].notna()]
        log_records(log, source, entity, df.loc[logged.index], "clean", logged["problem_type"], column,
                    logged["raw_value"], logged["cleaned_value"], logged["action"])

        if required:
            reasons = add_reason(reasons, missing, f"missing required {column}")
            reasons = add_reason(reasons, has_problem, problem[has_problem] + f" in required {column}")

    # Status pairs enforced by Phase 1 CHECK constraints (rules doc).
    if entity == "patients":
        status, death = df["life_status"], df["date_of_death"]
        reasons = add_reason(reasons, status.eq("Deceased") & death.isna(),
                             "Deceased patient without a valid date_of_death")
        reasons = add_reason(reasons, status.eq("Alive") & death.notna(), "Alive patient with a date_of_death")
    if entity == "admissions":
        status, discharge = df["admission_status"], df["discharge_datetime"]
        reasons = add_reason(reasons, status.eq("Admitted") & discharge.notna(),
                             "Admitted admission with a discharge time")
        closed = status.isin(["Discharged", "Deceased"]) & discharge.isna()
        reasons = add_reason(reasons, closed, status[closed] + " admission without a valid discharge time")

    # Two different records claiming the same source ID cannot both be right.
    ids = df[id_column]
    clash = ids.notna() & ids.duplicated(keep=False)
    reasons = add_reason(reasons, clash, "conflicting records share source ID " + ids[clash])

    rejected = reasons.ne("")
    quarantined = df[rejected].copy()
    quarantined["reason"] = reasons[rejected]
    clean = df[~rejected].copy()
    order = ["source_code", "source_local_id"] + [
        clean_column_name(entity, column) for column in columns
        if clean_column_name(entity, column) != "source_local_id"
    ]
    clean = clean[order + ["_line", "_raw_values"]]
    counts["quarantined_clean"] = len(quarantined)
    return clean, quarantined, counts


# --------------------------------------------------------------------------
# Stage 3: relationships (item 7)
# --------------------------------------------------------------------------

def reject(tables: dict, quarantine_rows: list, log: CleaningLog, source: str, entity: str,
           mask, reason, stage: str, column: str, problem: str | None = None) -> int:
    """Move the masked rows of one table to quarantine with a reason (one string or a column)."""
    frame = tables[source][entity]
    selected = frame[mask]
    problem = problem or reason.split(":")[0]
    add_quarantine(quarantine_rows, selected, entity, stage, reason)
    log_records(log, source, entity, selected, stage, problem, column, selected[column], None, "quarantined")
    tables[source][entity] = frame[~mask].copy()
    return len(selected)


def set_null_and_log(tables: dict, log: CleaningLog, source: str, entity: str, mask,
                     column: str, stage: str, problem: str) -> None:
    """Optional value that cannot be right: keep the record, set the value to NULL, log it."""
    frame = tables[source][entity]
    log_records(log, source, entity, frame[mask], stage, problem, column, frame.loc[mask, column], None, "set to NULL")
    frame.loc[mask, column] = None
    tables[source][entity] = frame


def check_relationships(tables: dict, quarantine_rows: list, log: CleaningLog) -> None:
    """Missing parents and inconsistent references, repeated until nothing changes.

    A broken required reference rejects the child; when a parent is rejected its
    children lose their parent on the next pass, so the rejection cascades down.
    A broken optional reference (a staff member) becomes NULL and is logged.
    """
    changed = True
    while changed:
        changed = False
        for source in SOURCES:
            for entity, references in REFERENCES.items():
                if tables[source][entity].empty:
                    continue
                for column, parent, required in references:
                    parent_key = "icd9_code" if parent == "icd9_dictionary" else "source_local_id"
                    known = tables[source][parent][parent_key]
                    frame = tables[source][entity]
                    broken = frame[column].notna() & ~frame[column].isin(known)
                    if not broken.any():
                        continue
                    if required:
                        reason = f"missing parent: {column} " + frame.loc[broken, column] + f" not found in {parent}"
                        reject(tables, quarantine_rows, log, source, entity, broken, reason,
                               "relationships", column, problem="missing_parent")
                        changed = True
                    else:
                        set_null_and_log(tables, log, source, entity, broken, column,
                                         "relationships", "broken_optional_reference")

            # Inconsistent references: the patient stored on a diagnosis or an
            # order must be the patient of its admission.
            admissions = tables[source]["admissions"][["source_local_id", "source_patient_id"]]
            admissions = admissions.rename(columns={
                "source_local_id": "source_admission_id",
                "source_patient_id": "_admission_patient"})
            for entity in ("diagnoses", "diagnostic_orders"):
                frame = tables[source][entity]
                if frame.empty:
                    continue
                joined = pd.merge(frame.reset_index(), admissions, on="source_admission_id",
                                  how="left").set_index("index")
                mismatch = joined["_admission_patient"].notna() & (
                    joined["source_patient_id"] != joined["_admission_patient"])
                if mismatch.any():
                    reject(tables, quarantine_rows, log, source, entity,
                           frame.index.isin(joined.index[mismatch]),
                           "inconsistent reference: patient does not match the admission's patient",
                           "relationships", "source_patient_id")
                    changed = True

            # Discharge record must agree with its admission (Task 5 rule).
            frame = tables[source]["discharge_records"]
            if not frame.empty:
                status = tables[source]["admissions"].set_index("source_local_id")["admission_status"]
                admission_status = frame["source_admission_id"].map(status)
                open_admission = admission_status.eq("Admitted")
                if open_admission.any():
                    reject(tables, quarantine_rows, log, source, "discharge_records", open_admission,
                           "inconsistent reference: discharge record for an admission still Admitted",
                           "relationships", "source_admission_id")
                    changed = True
                frame = tables[source]["discharge_records"]
                admission_status = frame["source_admission_id"].map(status)
                condition_mismatch = frame["discharge_condition"].notna() & (
                    frame["discharge_condition"].eq("Deceased") != admission_status.eq("Deceased"))
                if condition_mismatch.any():
                    reject(tables, quarantine_rows, log, source, "discharge_records", condition_mismatch,
                           "inconsistent reference: discharge_condition disagrees with admission_status",
                           "relationships", "discharge_condition")
                    changed = True

            # One-to-one links in the Phase 1 schema (UNIQUE constraints).
            for entity, column in (("discharge_records", "source_admission_id"),
                                   ("radiology_examinations", "source_examination_id"),
                                   ("radiology_reports", "source_radiology_id")):
                frame = tables[source][entity]
                repeated = frame[column].notna() & frame[column].duplicated(keep=False)
                if repeated.any():
                    reject(tables, quarantine_rows, log, source, entity, repeated,
                           f"inconsistent reference: several {entity} point to the same {column}",
                           "relationships", column)
                    changed = True

            # At most one Primary diagnosis per admission; one row per (admission, code, type).
            frame = tables[source]["diagnoses"]
            if not frame.empty:
                primary = frame["diagnosis_type"].eq("Primary")
                two_primary = primary & frame["source_admission_id"].where(primary).duplicated(keep=False)
                same_code = frame.duplicated(["source_admission_id", "icd9_code", "diagnosis_type"], keep=False)
                conflict = two_primary | same_code
                if conflict.any():
                    reject(tables, quarantine_rows, log, source, "diagnoses", conflict,
                           "inconsistent reference: conflicting diagnoses for one admission",
                           "relationships", "diagnosis_type")
                    changed = True


# --------------------------------------------------------------------------
# Stage 4: chronology (item 8)
# --------------------------------------------------------------------------

def as_time(series: pd.Series) -> pd.Series:
    return pd.to_datetime(series, format="%Y-%m-%d %H:%M:%S")


def admission_window(tables: dict, source: str) -> pd.DataFrame:
    admissions = tables[source]["admissions"]
    return pd.DataFrame({
        "source_admission_id": admissions["source_local_id"],
        "_admitted": as_time(admissions["admission_datetime"]),
        "_discharged": as_time(admissions["discharge_datetime"]),
    })


def with_admission_window(frame: pd.DataFrame, window: pd.DataFrame) -> pd.DataFrame:
    """LEFT JOIN each row to its admission's start and end (rows keep their index)."""
    return pd.merge(frame.reset_index(), window, on="source_admission_id", how="left").set_index("index")


def check_deaths(tables: dict, quarantine_rows: list, log: CleaningLog, source: str) -> None:
    """The patient's date of death must match their Deceased admission (YO-2).

    1. A Deceased admission belongs to a patient whose life_status is Deceased.
    2. That patient's date_of_death falls inside the admission (admission to discharge).
    3. No admission starts after the patient's date_of_death.
    Which record is wrong cannot be known, so the admission is quarantined (its
    children follow on the next relationships pass). A Deceased patient with no
    Deceased admission is allowed: the death may have happened outside the hospital.
    """
    patients = tables[source]["patients"][["source_local_id", "life_status", "date_of_death"]]
    patients = patients.rename(columns={"source_local_id": "source_patient_id"})
    admissions = tables[source]["admissions"]
    if admissions.empty:
        return
    joined = pd.merge(admissions.reset_index(), patients, on="source_patient_id", how="left").set_index("index")
    deceased_admission = joined["admission_status"] == "Deceased"

    not_deceased = deceased_admission & joined["life_status"].ne("Deceased")
    reject(tables, quarantine_rows, log, source, "admissions", admissions.index.isin(joined.index[not_deceased]),
           "inconsistent reference: Deceased admission but the patient's life_status is not Deceased",
           "relationships", "admission_status")

    died = as_time(joined["date_of_death"])
    death_outside = deceased_admission & ~not_deceased & (
        (died < as_time(joined["admission_datetime"])) | (died > as_time(joined["discharge_datetime"])))
    after_death = died.notna() & (as_time(joined["admission_datetime"]) > died)
    admissions = tables[source]["admissions"]
    reject(tables, quarantine_rows, log, source, "admissions", admissions.index.isin(joined.index[death_outside]),
           "chronology: the patient's date_of_death is outside this Deceased admission",
           "chronology", "discharge_datetime")
    admissions = tables[source]["admissions"]
    reject(tables, quarantine_rows, log, source, "admissions",
           admissions.index.isin(joined.index[after_death & ~death_outside]),
           "chronology: admission_datetime is after the patient's date_of_death",
           "chronology", "admission_datetime")


def check_chronology(tables: dict, quarantine_rows: list, log: CleaningLog) -> None:
    """Impossible orderings: a wrong required time rejects the record (it cannot be
    repaired without inventing a time); a wrong optional time becomes NULL (rules doc)."""
    for source in SOURCES:
        # Admissions: discharge after admission, admission after birth.
        admissions = tables[source]["admissions"]
        if not admissions.empty:
            admitted = as_time(admissions["admission_datetime"])
            discharged = as_time(admissions["discharge_datetime"])
            bad = discharged.notna() & (discharged <= admitted)
            reject(tables, quarantine_rows, log, source, "admissions", bad,
                   "chronology: discharge_datetime is not after admission_datetime",
                   "chronology", "discharge_datetime")
            admissions = tables[source]["admissions"]
            births = tables[source]["patients"].set_index("source_local_id")["date_of_birth"]
            born = pd.to_datetime(admissions["source_patient_id"].map(births), format="%Y-%m-%d")
            before_birth = born.notna() & (as_time(admissions["admission_datetime"]) < born)
            reject(tables, quarantine_rows, log, source, "admissions", before_birth,
                   "chronology: admission_datetime is before the patient's date_of_birth",
                   "chronology", "admission_datetime")
            check_deaths(tables, quarantine_rows, log, source)

        window = admission_window(tables, source)

        # Unit stays: exit after entry, inside the admission, no overlap.
        stays = tables[source]["unit_stays"]
        if not stays.empty:
            entry, exit_ = as_time(stays["entry_datetime"]), as_time(stays["exit_datetime"])
            bad_exit = exit_.notna() & (exit_ <= entry)
            set_null_and_log(tables, log, source, "unit_stays", bad_exit, "exit_datetime",
                             "chronology", "exit_not_after_entry")
            stays = tables[source]["unit_stays"]
            joined = with_admission_window(stays, window)
            entry = as_time(joined["entry_datetime"])
            exit_ = as_time(joined["exit_datetime"])
            outside = (entry < joined["_admitted"]) | (joined["_discharged"].notna() & (entry > joined["_discharged"]))
            exit_late = exit_.notna() & joined["_discharged"].notna() & (exit_ > joined["_discharged"])
            set_null_and_log(tables, log, source, "unit_stays", stays.index.isin(joined.index[exit_late & ~outside]),
                             "exit_datetime", "chronology", "exit_after_discharge")
            stays = tables[source]["unit_stays"]
            reject(tables, quarantine_rows, log, source, "unit_stays", stays.index.isin(joined.index[outside]),
                   "chronology: entry_datetime is outside the admission period",
                   "chronology", "entry_datetime")
            stays = tables[source]["unit_stays"]
            ordered = stays.assign(_entry=as_time(stays["entry_datetime"]),
                                   _exit=as_time(stays["exit_datetime"]))
            ordered = ordered.sort_values(["source_admission_id", "_entry"])
            # groupby + shift(1): the exit time of the previous stay in the same admission.
            previous_exit = ordered.groupby("source_admission_id")["_exit"].shift(1)
            overlap = previous_exit.notna() & (ordered["_entry"] < previous_exit)
            reject(tables, quarantine_rows, log, source, "unit_stays", stays.index.isin(ordered.index[overlap]),
                   "chronology: unit stay overlaps the previous stay of the same admission",
                   "chronology", "entry_datetime")

        # Events that must fall inside their admission.
        for entity, column in EVENTS_INSIDE_ADMISSION.items():
            frame = tables[source][entity]
            if frame.empty:
                continue
            joined = with_admission_window(frame, window)
            when = as_time(joined[column])
            outside = (when < joined["_admitted"]) | (joined["_discharged"].notna() & (when > joined["_discharged"]))
            reject(tables, quarantine_rows, log, source, entity, frame.index.isin(joined.index[outside]),
                   f"chronology: {column} is outside the admission period", "chronology", column)

        # Triage: not after discharge and at most 24 h before the admission opens.
        frame = tables[source]["triage_assessments"]
        if not frame.empty:
            joined = with_admission_window(frame, window)
            when = as_time(joined["assessment_datetime"])
            outside = (when < joined["_admitted"] - TRIAGE_BEFORE_ADMISSION) | (
                joined["_discharged"].notna() & (when > joined["_discharged"]))
            reject(tables, quarantine_rows, log, source, "triage_assessments",
                   frame.index.isin(joined.index[outside]),
                   "chronology: assessment_datetime is outside the admission period",
                   "chronology", "assessment_datetime")

        # Examinations follow their order and stay inside the admission (via the order).
        orders = tables[source]["diagnostic_orders"]
        exams = tables[source]["diagnostic_examinations"]
        if not exams.empty:
            order_info = pd.merge(
                orders[["source_local_id", "source_admission_id", "order_datetime"]].rename(
                    columns={"source_local_id": "source_order_id"}),
                window, on="source_admission_id", how="left")
            joined = pd.merge(exams.reset_index(), order_info, on="source_order_id", how="left").set_index("index")
            when = as_time(joined["examination_datetime"])
            outside = (when < as_time(joined["order_datetime"])) | (when < joined["_admitted"]) | (
                joined["_discharged"].notna() & (when > joined["_discharged"]))
            reject(tables, quarantine_rows, log, source, "diagnostic_examinations",
                   exams.index.isin(joined.index[outside]),
                   "chronology: examination_datetime is before its order or outside the admission period",
                   "chronology", "examination_datetime")

        # Radiology report comes after its examination.
        reports = tables[source]["radiology_reports"]
        if not reports.empty:
            exam_time = pd.merge(
                tables[source]["radiology_examinations"][["source_local_id", "source_examination_id"]],
                tables[source]["diagnostic_examinations"][["source_local_id", "examination_datetime"]].rename(
                    columns={"source_local_id": "source_examination_id"}),
                on="source_examination_id", how="left",
            ).rename(columns={"source_local_id": "source_radiology_id"})
            joined = pd.merge(reports.reset_index(), exam_time, on="source_radiology_id", how="left").set_index("index")
            early = as_time(joined["report_datetime"]) < as_time(joined["examination_datetime"])
            reject(tables, quarantine_rows, log, source, "radiology_reports",
                   reports.index.isin(joined.index[early]),
                   "chronology: report_datetime is before its examination",
                   "chronology", "report_datetime")

        # Follow-up appointment (optional) cannot be before the discharge.
        frame = tables[source]["discharge_records"]
        if not frame.empty:
            joined = with_admission_window(frame, window)
            early = as_time(joined["follow_up_appointment_datetime"]) < joined["_discharged"]
            set_null_and_log(tables, log, source, "discharge_records", frame.index.isin(joined.index[early]),
                             "follow_up_appointment_datetime", "chronology", "follow_up_before_discharge")


def flag_missing_primary(tables: dict, log: CleaningLog) -> None:
    """A completed admission needs a Primary diagnosis. Never invent one: keep and flag."""
    for source in SOURCES:
        admissions = tables[source]["admissions"]
        diagnoses = tables[source]["diagnoses"]
        with_primary = diagnoses.loc[diagnoses["diagnosis_type"] == "Primary", "source_admission_id"]
        completed = admissions["admission_status"].isin(["Discharged", "Deceased"])
        missing = completed & ~admissions["source_local_id"].isin(with_primary)
        log_records(log, source, "admissions", admissions[missing], "relationships",
                    "missing_primary_diagnosis", "diagnosis_type", None, None, "kept, flagged for review")


# --------------------------------------------------------------------------
# Whole pipeline
# --------------------------------------------------------------------------

def clean_all(data: dict, malformed: pd.DataFrame | None = None, schema: dict | None = None):
    """Clean every source. Returns (tables, quarantine, log, counts, remap)."""
    schema = schema or read_schema()
    log = CleaningLog()
    tables = {source: {} for source in SOURCES}
    quarantine_rows: list[dict] = []
    counts = {}

    # Records the loader could not read at all are rejected here too.
    if malformed is not None and not malformed.empty:
        quarantine_rows.extend(pd.DataFrame({
            "source_code": malformed["source"],
            "entity": malformed["entity"],
            "source_local_id": None,
            "source_line": malformed["line"],
            "stage": "load",
            "reason": "malformed record: " + malformed["reason"],
            "raw_values": malformed["raw_record"],
        }).to_dict("records"))
        log.add_rows(pd.DataFrame({
            "source_code": malformed["source"],
            "entity": malformed["entity"],
            "source_local_id": None,
            "source_line": malformed["line"],
            "stage": "load",
            "problem_type": "malformed_record",
            "column": "(row)",
            "raw_value": malformed["raw_record"],
            "cleaned_value": None,
            "action": "quarantined",
        }))

    for source in SOURCES:
        dictionary_codes: set[str] = set()
        for entity in ENTITY_ORDER:
            clean, rejected, entity_counts = clean_entity(
                data[source][entity], source, entity, schema, dictionary_codes, log)
            if entity == "icd9_dictionary":
                dictionary_codes = set(clean["icd9_code"])
            add_quarantine(quarantine_rows, rejected, entity, "clean", rejected["reason"])
            tables[source][entity] = clean
            counts[(source, entity)] = entity_counts

    # Item 2: duplicate patients inside one source, then repoint their children.
    all_patients = pd.concat([tables[source]["patients"] for source in SOURCES])
    _, remap = merge_duplicate_patients(all_patients)
    for source in SOURCES:
        source_remap = remap[remap["source_code"] == source]
        patients = tables[source]["patients"]
        removed = patients["source_local_id"].isin(source_remap["old_patient_id"])
        merged = pd.merge(patients[removed].reset_index(), source_remap, how="left",
                          left_on="source_local_id", right_on="old_patient_id").set_index("index")
        log_records(log, source, "patients", patients[removed], "clean", "duplicate_patient",
                    "source_local_id", patients.loc[removed, "source_local_id"], merged["kept_patient_id"],
                    "merged into patient " + merged["kept_patient_id"])
        tables[source]["patients"] = patients[~removed].copy()
        counts[(source, "patients")]["duplicate_patients_merged"] = int(removed.sum())

        lookup = source_remap.set_index("old_patient_id")["kept_patient_id"]
        for entity in ("admissions", "diagnoses", "diagnostic_orders"):
            frame = tables[source][entity]
            repoint = frame["source_patient_id"].isin(lookup.index)
            new_ids = frame.loc[repoint, "source_patient_id"].map(lookup)
            log_records(log, source, entity, frame[repoint], "clean", "repointed_to_kept_patient",
                        "source_patient_id", frame.loc[repoint, "source_patient_id"], new_ids, "corrected")
            frame.loc[repoint, "source_patient_id"] = new_ids
            tables[source][entity] = frame

    # Items 7 and 8. Relationships run again after chronology so that children
    # of a record rejected for chronology are rejected too.
    check_relationships(tables, quarantine_rows, log)
    check_chronology(tables, quarantine_rows, log)
    check_relationships(tables, quarantine_rows, log)
    flag_missing_primary(tables, log)

    quarantine = pd.DataFrame(quarantine_rows, columns=QUARANTINE_COLUMNS)
    return tables, quarantine, log.frame(), counts, remap


def build_counts(tables: dict, quarantine: pd.DataFrame, counts: dict) -> pd.DataFrame:
    rows = []
    for source in SOURCES:
        for entity in ENTITY_ORDER:
            in_quarantine = quarantine[(quarantine["source_code"] == source) & (quarantine["entity"] == entity)]
            entity_counts = counts[(source, entity)]
            rows.append({
                "source": source,
                "entity": entity,
                "rows_loaded": entity_counts["rows_in"],
                "malformed_at_load": int((in_quarantine["stage"] == "load").sum()),
                "exact_duplicates_removed": entity_counts["exact_duplicates"],
                "duplicate_patients_merged": entity_counts.get("duplicate_patients_merged", 0),
                "quarantined_cleaning": int((in_quarantine["stage"] == "clean").sum()),
                "quarantined_relationships": int((in_quarantine["stage"] == "relationships").sum()),
                "quarantined_chronology": int((in_quarantine["stage"] == "chronology").sum()),
                "rows_out": len(tables[source][entity]),
            })
    frame = pd.DataFrame(rows)
    frame["reconciles"] = frame["rows_loaded"] == (
        frame["exact_duplicates_removed"] + frame["duplicate_patients_merged"]
        + frame["quarantined_cleaning"] + frame["quarantined_relationships"]
        + frame["quarantined_chronology"] + frame["rows_out"])
    return frame


def build_examples(log: pd.DataFrame) -> pd.DataFrame:
    """Two representative before/after rows per problem type and source."""
    examples = log.sort_values(["problem_type", "source_code", "entity"], kind="stable")
    return examples.groupby(["problem_type", "source_code"], sort=False).head(2)


def build_summary(log: pd.DataFrame) -> pd.DataFrame:
    """How many values or records each problem touched, per source and action."""
    summary = log.groupby(["stage", "problem_type", "action", "source_code"]).size()
    summary = summary.unstack("source_code", fill_value=0).reset_index()
    for source in SOURCES:
        if source not in summary:
            summary[source] = 0
    summary["total"] = summary[list(SOURCES)].sum(axis=1)
    return summary.sort_values(["stage", "total"], ascending=[True, False])


def write_outputs(tables, quarantine, log, counts, remap, output_dir, quarantine_dir, report_dir):
    for folder in (output_dir, quarantine_dir, report_dir):
        Path(folder).mkdir(parents=True, exist_ok=True)
    for entity in ENTITY_ORDER:
        stacked = pd.concat([tables[source][entity] for source in SOURCES], ignore_index=True)
        stacked = stacked.rename(columns={"_line": "source_line"}).drop(columns="_raw_values")
        stacked.to_csv(Path(output_dir) / f"{entity}.csv", index=False)
        quarantine[quarantine["entity"] == entity].to_csv(
            Path(quarantine_dir) / f"{entity}.csv", index=False)
    routine = log["problem_type"].isin(ROUTINE_CONVERSIONS)
    log[~routine].to_csv(Path(report_dir) / "cleaning_log.csv", index=False)
    build_examples(log).to_csv(Path(report_dir) / "cleaning_examples.csv", index=False)
    build_summary(log).to_csv(Path(report_dir) / "cleaning_summary.csv", index=False)
    count_table = build_counts(tables, quarantine, counts)
    count_table.to_csv(Path(report_dir) / "counts_clean.csv", index=False)
    remap.to_csv(Path(report_dir) / "patient_id_remap.csv", index=False)
    return count_table


def run(raw_dir: Path | None = None, output_dir: Path = OUTPUT_DIR,
        quarantine_dir: Path = QUARANTINE_DIR, report_dir: Path = REPORT_DIR) -> pd.DataFrame:
    """Load, clean and write everything. Returns the counts table."""
    # Same calls as load.load_all(), but the unreadable records are collected here
    # instead of rewriting LA-1's reports/malformed_records.csv on every run.
    malformed_rows: list[dict] = []
    data = {
        "A": load.load_source_a(raw_dir, malformed_rows),
        "B": load.load_source_b(raw_dir, malformed_rows),
        "C": load.load_source_c(raw_dir, malformed_rows),
        "D": load.load_source_d(raw_dir, malformed_rows),
    }
    malformed = pd.DataFrame(malformed_rows, columns=load.MALFORMED_COLUMNS)
    tables, quarantine, log, counts, remap = clean_all(data, malformed)
    return write_outputs(tables, quarantine, log, counts, remap, output_dir, quarantine_dir, report_dir)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--scale", choices=("sample", "full"), default="sample")
    parser.add_argument("--raw-dir", type=Path, help="Default: data/raw/<scale>")
    args = parser.parse_args()
    raw_dir = args.raw_dir or ROOT / "data" / "raw" / args.scale
    counts = run(raw_dir)
    totals = counts[[column for column in counts.columns if column not in ("source", "entity", "reconciles")]].sum()
    print(counts.groupby("source")[["rows_loaded", "rows_out"]].sum().to_string())
    print(f"\nLoaded {totals['rows_loaded']:,} rows -> {totals['rows_out']:,} clean; "
          f"{totals['exact_duplicates_removed']} exact duplicates, "
          f"{totals['duplicate_patients_merged']} duplicate patients merged, "
          f"{totals['quarantined_cleaning'] + totals['quarantined_relationships'] + totals['quarantined_chronology']} "
          f"quarantined, {totals['malformed_at_load']} malformed at load.")
    if not counts["reconciles"].all():
        print("Counts do NOT reconcile for:", counts.loc[~counts["reconciles"], ["source", "entity"]].values.tolist())
        return 1
    print("Every table reconciles: loaded = removed + quarantined + clean.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
