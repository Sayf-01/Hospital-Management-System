"""Clean a source CSV into the Phase 1 hand-off shape."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
from typing import Iterable
from zoneinfo import ZoneInfo

import pandas as pd

if __package__:
    from .config.source_maps import FIELD_MAPS, SOURCE_TIME_ZONES
    from .config.value_maps import VALUE_MAPS, map_category
else:
    from config.source_maps import FIELD_MAPS, SOURCE_TIME_ZONES
    from config.value_maps import VALUE_MAPS, map_category


ROOT = Path(__file__).resolve().parents[1]
SAMPLE_INPUT = ROOT / "data" / "raw" / "sample" / "B_patients.csv"
OUTPUT_DIR = ROOT / "data" / "clean"
QUARANTINE_DIR = ROOT / "data" / "quarantine"
REPORT_DIR = ROOT / "reports"

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

DATE_FORMATS = {
    "A": "%Y-%m-%d",
    "B": "%d.%m.%Y",
    "C": "%Y-%m-%d",
    "D": "%d/%m/%Y",
}

TIMESTAMP_FORMATS = {
    "A": "ISO8601",
    "B": "%d.%m.%Y %H:%M",
    "C": "ISO8601",
    "D": "%d/%m/%Y %I:%M %p",
}

NUMERIC_RANGES = {
    "heart_rate": (20, 250),
    "respiratory_rate": (4, 60),
    "body_temperature": (25, 45),
    "oxygen_saturation": (0, 100),
    "pain_level": (0, 10),
}

REQUIRED_FIELDS = {
    "patients": {"first_name", "last_name", "date_of_birth", "gender", "life_status"},
    "admissions": {
        "source_patient_id",
        "admission_datetime",
        "admission_type",
        "admission_status",
    },
    "triage_assessments": {
        "source_admission_id",
        "assessment_datetime",
        "priority_level",
    },
    "diagnoses": {
        "source_patient_id",
        "source_admission_id",
        "icd9_code",
        "diagnosis_datetime",
        "diagnosis_type",
    },
}

MISSING_MARKERS = {"", "null", "n/a", "na", "-", "?", "none"}
EXAMPLE_COLUMNS = [
    "source_code",
    "entity",
    "source_local_id",
    "line",
    "problem_type",
    "column",
    "raw_value",
    "cleaned_value",
]


def _is_missing(value: object) -> bool:
    if value is None or value is pd.NA:
        return True
    if isinstance(value, str):
        return " ".join(value.split()).casefold() in MISSING_MARKERS
    return bool(pd.isna(value))


def normalize_missing(df: pd.DataFrame) -> pd.DataFrame:
    """Replace common source null markers with Python ``None`` values."""
    result = df.copy().astype(object)
    for column in result.columns:
        result[column] = pd.Series(
            [None if _is_missing(value) else value for value in result[column]],
            index=result.index,
            dtype=object,
        )
    return result


def normalize_text(df: pd.DataFrame, cols: Iterable[str]) -> pd.DataFrame:
    """Collapse whitespace and normalize human names and code fields."""
    result = df.copy()
    for column in cols:
        if column not in result.columns:
            continue
        for index, value in result[column].items():
            if _is_missing(value):
                result.at[index, column] = None
                continue
            text = " ".join(str(value).split())
            if column in {"first_name", "last_name"}:
                text = text.title()
            elif column == "code" or column.endswith("_code"):
                text = text.upper()
            result.at[index, column] = text
    return result


def rename_fields(df: pd.DataFrame, source: str, entity: str) -> pd.DataFrame:
    """Apply the SA-2 source field map and identify parent links as source IDs."""
    try:
        field_map = FIELD_MAPS[(source, entity)]
    except KeyError as error:
        raise ValueError(f"No field map for source {source!r}, entity {entity!r}") from error

    unmapped = set(df.columns) - set(field_map)
    if unmapped:
        raise ValueError(
            f"Unmapped columns for source {source} {entity}: {', '.join(sorted(unmapped))}"
        )

    result = df.rename(columns=field_map).copy()
    primary_key = ENTITY_PRIMARY_KEYS[entity]
    parent_columns = {
        column: f"source_{column}"
        for column in result.columns
        if column != primary_key
        and column.endswith("_id")
        and not column.startswith("source_")
    }
    return result.rename(columns=parent_columns)


def map_categories(
    df: pd.DataFrame, source: str, entity: str
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Map known category labels and return a mask for unknown labels."""
    result = df.copy()
    flags = pd.DataFrame(index=result.index)
    for field in VALUE_MAPS:
        if field not in result.columns:
            continue
        flags[field] = False
        values = result[field].tolist()
        for index, raw_value in result[field].items():
            if _is_missing(raw_value):
                continue
            try:
                values[result.index.get_loc(index)] = map_category(
                    source, field, raw_value
                )
            except ValueError:
                values[result.index.get_loc(index)] = None
                flags.at[index, field] = True
        result[field] = pd.Series(values, index=result.index, dtype=object)
    return result, flags


def parse_timestamps(
    df: pd.DataFrame, source: str, cols: Iterable[str]
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Parse source-local timestamps, convert them to UTC, and flag invalid input."""
    result = df.copy()
    invalid = pd.DataFrame(index=result.index)
    zone = ZoneInfo(SOURCE_TIME_ZONES[source])
    for column in cols:
        if column not in result.columns:
            continue
        values = result[column]
        supplied = values.map(lambda value: not _is_missing(value))
        if source == "D":
            epoch_seconds = pd.to_numeric(values, errors="coerce")
            epoch_mask = epoch_seconds.notna()
            local = pd.to_datetime(
                values.where(~epoch_mask),
                format=TIMESTAMP_FORMATS[source],
                errors="coerce",
            )
            local = local.dt.tz_localize(
                zone, ambiguous="NaT", nonexistent="NaT"
            ).dt.tz_convert("UTC")
            epoch = pd.to_datetime(
                epoch_seconds, unit="s", errors="coerce", utc=True
            )
            parsed = local.where(~epoch_mask, epoch)
        else:
            parsed = pd.to_datetime(
                values,
                format=TIMESTAMP_FORMATS[source],
                errors="coerce",
            )
            if parsed.dt.tz is None:
                parsed = parsed.dt.tz_localize(
                    zone, ambiguous="NaT", nonexistent="NaT"
                ).dt.tz_convert("UTC")
            else:
                parsed = parsed.dt.tz_convert("UTC")
        parsed = parsed.dt.tz_localize(None)
        invalid[column] = supplied & parsed.isna()
        result[column] = parsed
    return result, invalid


def clean_numbers(
    df: pd.DataFrame, source: str, entity: str
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Parse configured measurements, apply source units, and flag invalid ranges."""
    result = df.copy()
    invalid = pd.DataFrame(index=result.index)
    numeric_fields = set(NUMERIC_RANGES)
    for column in numeric_fields.intersection(result.columns):
        values = result[column].astype("string")
        if source == "B":
            values = values.str.replace(",", ".", regex=False)
        parsed = pd.to_numeric(values, errors="coerce")
        supplied = result[column].map(lambda value: not _is_missing(value))
        if source == "A" and column == "body_temperature":
            parsed = ((parsed - 32) * 5 / 9).round(1)
        lower, upper = NUMERIC_RANGES[column]
        out_of_range = parsed.notna() & ~parsed.between(lower, upper)
        invalid[column] = supplied & (parsed.isna() | out_of_range)
        result[column] = parsed.mask(out_of_range)
    return result, invalid


def fix_icd9(code: object) -> str | None:
    """Normalize ICD-9 punctuation and restore a missing numeric leading zero."""
    if _is_missing(code):
        return None
    value = str(code).strip().upper()
    if value.startswith("E"):
        if "." not in value and len(value) > 4:
            value = f"{value[:4]}.{value[4:]}"
        return value

    if "." in value:
        integer, fraction = value.split(".", maxsplit=1)
        return f"{integer.zfill(3)}.{fraction}"
    if value.isdigit() and len(value) > 3:
        return f"{value[:3]}.{value[3:]}"
    return value.zfill(3) if value.isdigit() else value


def drop_exact_duplicates(df: pd.DataFrame) -> tuple[pd.DataFrame, int]:
    """Drop exact row duplicates while ignoring internal line/raw-value columns."""
    ignored = [column for column in ("line", "_raw_values") if column in df]
    comparable = df.drop(columns=ignored)
    keep = ~comparable.duplicated(keep="first")
    return df.loc[keep].copy(), int((~keep).sum())


def merge_duplicate_patients(patients: pd.DataFrame) -> tuple[pd.DataFrame, int]:
    """Keep the lowest-ID patient for each complete cleaned identity."""
    identity = {
        "first_name",
        "last_name",
        "date_of_birth",
        "health_insurance_number",
    }
    if not identity.issubset(patients.columns):
        return patients.copy(), 0
    eligible = patients[list(identity)].notna().all(axis=1)
    identity_keys = pd.DataFrame(index=patients.index)
    for column in identity:
        identity_keys[column] = (
            patients[column].astype(str).str.strip().str.casefold()
            if column != "date_of_birth"
            else patients[column]
        )
    order = (
        pd.to_numeric(patients["source_local_id"], errors="coerce")
        if "source_local_id" in patients
        else pd.Series(range(len(patients)), index=patients.index)
    )
    ordered = patients.assign(_id_order=order).sort_values(
        "_id_order", kind="stable", na_position="last"
    )
    ordered_keys = identity_keys.loc[ordered.index]
    duplicate = eligible.loc[ordered.index] & ordered_keys.duplicated(
        keep="first"
    )
    kept = ordered.loc[~duplicate].drop(columns="_id_order")
    return patients.loc[kept.index].copy(), int(duplicate.sum())


def quarantine(
    df: pd.DataFrame, mask: pd.Series, reason: str | pd.Series
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Split rejected rows from clean rows, retaining source identifiers and raw values."""
    selected = df.loc[mask].copy()
    if selected.empty:
        return df.loc[~mask].copy(), pd.DataFrame(
            columns=["source_code", "entity", "source_local_id", "reason", "raw_values"]
        )
    if isinstance(reason, pd.Series):
        selected["reason"] = reason.loc[selected.index]
    else:
        selected["reason"] = reason
    quarantine_columns = [
        column
        for column in (
            "source_code",
            "entity",
            "source_local_id",
            "reason",
            "_raw_values",
        )
        if column in selected.columns
    ]
    rejected = selected[quarantine_columns].rename(
        columns={"_raw_values": "raw_values"}
    )
    return df.loc[~mask].copy(), rejected


def _json_value(value: object) -> object:
    if _is_missing(value):
        return None
    if isinstance(value, (pd.Timestamp,)):
        return value.isoformat()
    if hasattr(value, "item"):
        return value.item()
    return value


def _raw_json(row: pd.Series) -> str:
    return json.dumps(
        {str(key): _json_value(value) for key, value in row.items()},
        ensure_ascii=False,
        default=str,
    )


def _example(
    examples: list[dict[str, object]],
    row: pd.Series,
    problem_type: str,
    column: str,
    raw_value: object,
    cleaned_value: object,
) -> None:
    examples.append(
        {
            "source_code": row["source_code"],
            "entity": row["entity"],
            "source_local_id": row["source_local_id"],
            "line": row["line"],
            "problem_type": problem_type,
            "column": column,
            "raw_value": _json_value(raw_value),
            "cleaned_value": _json_value(cleaned_value),
        }
    )


def _format_date_column(df: pd.DataFrame, source: str) -> tuple[pd.DataFrame, pd.Series]:
    result = df.copy()
    invalid = pd.Series(False, index=result.index, dtype=bool)
    if "date_of_birth" not in result:
        return result, invalid
    supplied = result["date_of_birth"].map(lambda value: not _is_missing(value))
    parsed = pd.to_datetime(
        result["date_of_birth"],
        format=DATE_FORMATS[source],
        errors="coerce",
    )
    invalid = supplied & parsed.isna()
    result["date_of_birth"] = parsed.dt.strftime("%Y-%m-%d").where(parsed.notna())
    return result, invalid


def clean_csv(
    input_path: Path, source: str, entity: str
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, dict[str, int]]:
    """Clean one mapped sample CSV and return clean, quarantine, examples, and counts."""
    if source not in SOURCE_TIME_ZONES:
        raise ValueError(f"Unknown source code {source!r}")
    if entity not in ENTITY_PRIMARY_KEYS:
        raise ValueError(f"Unknown entity {entity!r}")

    with input_path.open(encoding="utf-8-sig", newline="") as file:
        sample = file.read(4096)
    try:
        delimiter = csv.Sniffer().sniff(sample, delimiters=",;\t|").delimiter
    except csv.Error as error:
        raise ValueError(f"Could not determine CSV delimiter for {input_path}") from error

    raw = pd.read_csv(
        input_path,
        sep=delimiter,
        dtype=str,
        keep_default_na=False,
        encoding="utf-8-sig",
    )
    if raw.empty:
        raw.insert(0, "line", pd.Series(dtype="int64"))
    else:
        raw.insert(0, "line", range(2, len(raw) + 2))
    original = raw.copy()
    original_by_line = original.set_index("line", drop=False)
    raw_values = original.drop(columns="line").apply(_raw_json, axis=1)

    normalized = normalize_missing(raw.drop(columns="line"))
    normalized = rename_fields(normalized, source, entity)
    primary_key = ENTITY_PRIMARY_KEYS[entity]
    if primary_key not in normalized:
        raise ValueError(f"Field map for {source} {entity} has no {primary_key!r}")
    source_local_id = normalized[primary_key].map(
        lambda value: None if _is_missing(value) else str(value)
    )
    normalized = normalized.drop(columns=primary_key)
    normalized.insert(0, "source_code", source)
    normalized.insert(1, "source_local_id", source_local_id)
    normalized.insert(2, "entity", entity)
    normalized.insert(3, "line", original["line"])
    normalized["_raw_values"] = raw_values.to_list()

    raw_name_map = FIELD_MAPS[(source, entity)]
    examples: list[dict[str, object]] = []
    for raw_column, clean_column in raw_name_map.items():
        if raw_column not in original or clean_column not in normalized:
            continue
        before = original[raw_column]
        after = normalized[clean_column]
        missing_marker = before.map(_is_missing) & after.map(_is_missing)
        for index in before.index[missing_marker]:
            _example(
                examples,
                normalized.loc[index],
                "missing_value",
                clean_column,
                before.at[index],
                None,
            )
        if clean_column in {"first_name", "last_name"} and raw_column in original:
            for index in before.index[before.astype(str) != after.astype(str)]:
                if not _is_missing(before.at[index]):
                    _example(
                        examples,
                        normalized.loc[index],
                        "text_normalization",
                        clean_column,
                        before.at[index],
                        after.at[index],
                    )

    text_columns = [
        column
        for column in normalized.columns
        if column not in {"source_code", "source_local_id", "entity", "line", "_raw_values"}
        and not column.startswith("source_")
        and not column.endswith("_datetime")
        and column != "date_of_birth"
    ]
    text_before = normalized.copy()
    normalized = normalize_text(normalized, text_columns)
    for column in text_columns:
        changed = text_before[column].astype(str) != normalized[column].astype(str)
        for index in normalized.index[changed]:
            _example(
                examples,
                normalized.loc[index],
                "text_normalization",
                column,
                text_before.at[index, column],
                normalized.at[index, column],
            )

    normalized, category_flags = map_categories(normalized, source, entity)
    for field in category_flags.columns:
        for index in normalized.index[category_flags[field]]:
            _example(
                examples,
                normalized.loc[index],
                "unknown_category",
                field,
                original_by_line.loc[normalized.at[index, "line"]].get(field),
                None,
            )

    normalized, date_invalid = _format_date_column(normalized, source)
    if "date_of_birth" in normalized:
        for index in normalized.index[date_invalid]:
            _example(
                examples,
                normalized.loc[index],
                "invalid_date",
                "date_of_birth",
                original_by_line.loc[normalized.at[index, "line"]].get(
                    next(
                        (
                            raw_column
                            for raw_column, clean_column in raw_name_map.items()
                            if clean_column == "date_of_birth"
                        ),
                        "",
                    )
                ),
                normalized.at[index, "date_of_birth"],
            )

    timestamp_columns = [
        column
        for column in normalized.columns
        if column.endswith("_datetime") or column == "date_of_death"
    ]
    timestamp_before = normalized[timestamp_columns].copy()
    normalized, timestamp_invalid_by_column = parse_timestamps(
        normalized, source, timestamp_columns
    )
    for column in timestamp_columns:
        changed = timestamp_before[column].astype(str) != normalized[column].astype(str)
        for index in normalized.index[changed]:
            raw_value = timestamp_before.at[index, column]
            if _is_missing(raw_value):
                continue
            problem = (
                "invalid_date"
                if timestamp_invalid_by_column.at[index, column]
                else "timestamp"
            )
            _example(
                examples,
                normalized.loc[index],
                problem,
                column,
                raw_value,
                normalized.at[index, column],
            )

    number_before = normalized.copy()
    normalized, numeric_invalid_by_column = clean_numbers(normalized, source, entity)
    for column in NUMERIC_RANGES.keys() & normalized.columns:
        changed = number_before[column].astype(str) != normalized[column].astype(str)
        for index in normalized.index[changed]:
            _example(
                examples,
                normalized.loc[index],
                "numeric",
                column,
                number_before.at[index, column],
                normalized.at[index, column],
            )

    if "icd9_code" in normalized:
        before = normalized["icd9_code"].copy()
        normalized["icd9_code"] = normalized["icd9_code"].map(fix_icd9)
        changed = before.astype(str) != normalized["icd9_code"].astype(str)
        for index in normalized.index[changed]:
            _example(
                examples,
                normalized.loc[index],
                "icd9_format",
                "icd9_code",
                before.at[index],
                normalized.at[index, "icd9_code"],
            )

    reasons = pd.Series("", index=normalized.index, dtype=object)
    required = REQUIRED_FIELDS.get(entity, set())
    for column in required:
        if column not in normalized:
            continue
        missing = normalized[column].map(_is_missing)
        reasons.loc[missing] = reasons.loc[missing].map(
            lambda current: "; ".join(filter(None, (current, f"missing required {column}")))
        )
    for mask, label in (
        (
            category_flags[list(required.intersection(category_flags.columns))]
            .any(axis=1)
            if required.intersection(category_flags.columns)
            else pd.Series(False, index=normalized.index),
            "unknown required category",
        ),
        (date_invalid, "invalid required date"),
        (
            timestamp_invalid_by_column[
                list(required.intersection(timestamp_invalid_by_column.columns))
            ].any(axis=1)
            if required.intersection(timestamp_invalid_by_column.columns)
            else (
                timestamp_invalid_by_column["date_of_death"]
                & normalized["life_status"].eq("Deceased")
                if entity == "patients" and "date_of_death" in timestamp_invalid_by_column
                else pd.Series(False, index=normalized.index)
            ),
            "invalid required timestamp",
        ),
        (
            numeric_invalid_by_column[
                list(required.intersection(numeric_invalid_by_column.columns))
            ].any(axis=1)
            if required.intersection(numeric_invalid_by_column.columns)
            else pd.Series(False, index=normalized.index),
            "invalid numeric value or range",
        ),
    ):
        if label == "invalid required date" and "date_of_birth" not in required:
            continue
        reasons.loc[mask] = reasons.loc[mask].map(
            lambda current: "; ".join(filter(None, (current, label)))
        )

    normalized, quarantined = quarantine(
        normalized, reasons.ne(""), reasons.rename("reason")
    )

    clean_before_dedup = normalized.copy()
    normalized, exact_duplicates = drop_exact_duplicates(normalized)
    duplicates_removed = exact_duplicates
    if exact_duplicates:
        removed = clean_before_dedup.loc[
            ~clean_before_dedup.index.isin(normalized.index)
        ]
        for _, row in removed.iterrows():
            _example(
                examples,
                row,
                "exact_duplicate",
                "(row)",
                row["_raw_values"],
                "removed",
            )
    if entity == "patients":
        clean_before_merge = normalized.copy()
        normalized, patient_duplicates = merge_duplicate_patients(normalized)
        duplicates_removed += patient_duplicates
        removed = clean_before_merge.loc[
            ~clean_before_merge.index.isin(normalized.index)
        ]
        for _, row in removed.iterrows():
            identity_mask = pd.Series(True, index=normalized.index)
            for column in (
                "first_name",
                "last_name",
                "date_of_birth",
                "health_insurance_number",
            ):
                identity_mask &= (
                    normalized[column].astype(str).str.strip().str.casefold()
                    == str(row[column]).strip().casefold()
                )
            kept_id = normalized.loc[identity_mask, "source_local_id"].iloc[0]
            _example(
                examples,
                row,
                "duplicate_patient",
                "health_insurance_number/date_of_birth",
                row["_raw_values"],
                f"removed; kept source-local ID {kept_id}",
            )

    examples_frame = pd.DataFrame(examples, columns=EXAMPLE_COLUMNS)
    if not examples_frame.empty:
        examples_frame = examples_frame.groupby(
            "problem_type", sort=False, group_keys=False
        ).head(2)

    output = normalized.drop(columns=["entity", "line", "_raw_values"])
    output = output.reset_index(drop=True)
    quarantined = quarantined.reset_index(drop=True)
    counts = {
        "rows_in": len(raw),
        "rows_out": len(output),
        "quarantined": len(quarantined),
        "duplicates_removed": duplicates_removed,
    }
    return output, quarantined, examples_frame, counts


def run(
    input_path: Path,
    source: str,
    entity: str,
    output_dir: Path = OUTPUT_DIR,
    quarantine_dir: Path = QUARANTINE_DIR,
    report_dir: Path = REPORT_DIR,
) -> dict[str, int]:
    cleaned, quarantined, examples, counts = clean_csv(input_path, source, entity)
    output_dir.mkdir(parents=True, exist_ok=True)
    quarantine_dir.mkdir(parents=True, exist_ok=True)
    report_dir.mkdir(parents=True, exist_ok=True)

    clean_path = output_dir / f"{entity}.csv"
    if clean_path.exists():
        prior_clean = pd.read_csv(clean_path, dtype=str, keep_default_na=False)
        prior_clean = prior_clean.loc[prior_clean["source_code"] != source]
        cleaned = pd.concat([prior_clean, cleaned], ignore_index=True, sort=False)
    cleaned.to_csv(clean_path, index=False)

    quarantine_path = quarantine_dir / f"{entity}.csv"
    if quarantine_path.exists():
        prior_quarantine = pd.read_csv(
            quarantine_path, dtype=str, keep_default_na=False
        )
        prior_quarantine = prior_quarantine.loc[
            prior_quarantine["source_code"] != source
        ]
        quarantined = pd.concat(
            [prior_quarantine, quarantined], ignore_index=True, sort=False
        )
    quarantined.to_csv(quarantine_path, index=False)
    count_row = pd.DataFrame(
        [{"source": source, "entity": entity, **counts}]
    )
    count_path = report_dir / "counts_clean.csv"
    if count_path.exists():
        prior_counts = pd.read_csv(count_path)
        prior_counts = prior_counts.loc[
            ~((prior_counts["source"] == source) & (prior_counts["entity"] == entity))
        ]
        count_row = pd.concat([prior_counts, count_row], ignore_index=True)
    count_row.to_csv(count_path, index=False)
    examples_path = report_dir / "cleaning_examples.csv"
    if examples_path.exists():
        prior_examples = pd.read_csv(
            examples_path, dtype=str, keep_default_na=False
        )
        prior_examples = prior_examples.loc[
            ~(
                (prior_examples["source_code"] == source)
                & (prior_examples["entity"] == entity)
            )
        ]
        examples = pd.concat([prior_examples, examples], ignore_index=True)
    examples.to_csv(examples_path, index=False)
    return counts


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", default="B", choices=tuple(SOURCE_TIME_ZONES))
    parser.add_argument("--entity", default="patients", choices=tuple(ENTITY_PRIMARY_KEYS))
    parser.add_argument("--input", type=Path, default=SAMPLE_INPUT)
    args = parser.parse_args()

    counts = run(args.input, args.source, args.entity)
    print(
        f"{args.source} {args.entity}: {counts['rows_in']} in, "
        f"{counts['rows_out']} out, {counts['quarantined']} quarantined, "
        f"{counts['duplicates_removed']} duplicates removed"
    )


if __name__ == "__main__":
    main()
