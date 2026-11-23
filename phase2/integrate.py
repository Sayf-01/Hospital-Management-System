"""DA-3: integrate the four cleaned sources into one set of tables with global IDs.

"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
CLEAN_DIR = ROOT / "data" / "clean"      # switch to data/checked with --input once YO-2 exists
SCHEMA_V2 = ROOT / "sql" / "schema_v2.sql"
OUT_DIR = ROOT / "data" / "integrated"
REPORT_DIR = ROOT / "reports"

# One row per source hospital (integration_rules.md, section 7)
SOURCE_SYSTEMS = pd.DataFrame(
    [
        ("A", "Maple Ridge General", "North America", "TXT", "America/Toronto"),
        ("B", "Rhine Valley Klinikum", "Europe", "CSV", "Europe/Berlin"),
        ("C", "Sakura Bay Medical Center", "Asia", "XML", "Asia/Tokyo"),
        ("D", "Southern Cross Hospital", "Oceania", "JSON", "Australia/Sydney"),
    ],
    columns=["source_code", "hospital_name", "continent", "file_format", "time_zone"],
)


def read_clean(entity: str) -> pd.DataFrame:
    """Read one cleaned file. Every value stays text, and an empty cell stays ''
    (not NaN), so nothing is reformatted on the way through."""
    return pd.read_csv(CLEAN_DIR / f"{entity}.csv", dtype=str, keep_default_na=False)


def assign_global_ids(df: pd.DataFrame, id_column: str) -> pd.DataFrame:
    """Number the rows 1..N in a fixed order: source A to D, then local ID as a
    number (text IDs after numeric ones). Same input -> same IDs on every run."""
    df = df.copy()
    df["_local_number"] = pd.to_numeric(df["source_local_id"], errors="coerce")
    df = df.sort_values(
        ["source_code", "_local_number", "source_local_id"],
        na_position="last",
        kind="mergesort",  # stable sort, so ties keep their order
    )
    df[id_column] = range(1, len(df) + 1)
    return df.drop(columns="_local_number").reset_index(drop=True)


def build_lookup(df: pd.DataFrame, id_column: str) -> dict[tuple[str, str], int]:
    """The 'key board': (source_code, source_local_id) -> global ID."""
    return dict(zip(zip(df["source_code"], df["source_local_id"]), df[id_column]))


def combine_icd9(icd9: pd.DataFrame) -> pd.DataFrame:
    """One shared dictionary: the four sources use the same real ICD-9 codes.
    For each code keep the first non-empty value of each column (sources A to D).
    Sayf's cleaning already verified the official titles, so they agree."""
    icd9 = icd9.sort_values(["source_code"], kind="mergesort")
    columns = ["official_title", "description", "disease_category"]
    first_filled = icd9.replace("", pd.NA).groupby("icd9_code", sort=True)[columns].first()
    titles_per_code = icd9.groupby("icd9_code")["official_title"].nunique()
    if (titles_per_code > 1).any():
        raise ValueError(f"ICD-9 codes with different titles: {list(titles_per_code[titles_per_code > 1].index)}")
    return first_filled.fillna("").reset_index()


def normalize_name(values: pd.Series) -> pd.Series:
    """Trim, collapse inner spaces, ignore case: ' Ana  LOPEZ' -> 'ana lopez'."""
    return values.str.split().str.join(" ").str.casefold()


PATIENT_COLUMNS = [
    "first_name", "last_name", "date_of_birth", "gender", "health_insurance_number",
    "address", "phone_number", "emergency_contact_info", "life_status", "date_of_death",
]
# Fields that can differ between two hospitals' copies of the same person
CONFLICT_FIELDS = ["address", "phone_number", "emergency_contact_info"]


def integrate_patients(patients: pd.DataFrame, admissions: pd.DataFrame):
    """Apply M1 / U1 / U2 (integration_rules.md, section 3).

    Returns (patients table, patient_source_map, patient_match_candidates, conflict log).
    """
    p = assign_global_ids(patients, "_order")          # fixed A..D order, reused below
    p["_first"] = normalize_name(p["first_name"])
    p["_last"] = normalize_name(p["last_name"])
    p["_insurance"] = p["health_insurance_number"].str.strip().str.casefold()
    identity = ["_first", "_last", "date_of_birth", "gender"]

    # M1: same names, birth date, gender AND insurance number, from different sources
    has_insurance = p["_insurance"] != ""
    m1_key = p[identity + ["_insurance"]].astype(str).agg("|".join, axis=1)
    sources_per_key = p[has_insurance].groupby(m1_key[has_insurance])["source_code"].nunique()
    merged_keys = set(sources_per_key[sources_per_key > 1].index)
    p["_group"] = m1_key.where(m1_key.isin(merged_keys), "single|" + p["_order"].astype(str))
    p["match_rule"] = p["_group"].str.startswith("single|").map({True: "NEW", False: "M1"})

    # Global patient ID: groups numbered in the order of their first source record
    group_order = p.groupby("_group", sort=False)["_order"].min().sort_values()
    group_to_id = {group: i for i, group in enumerate(group_order.index, start=1)}
    p["patient_id"] = p["_group"].map(group_to_id)

    # Conflicts inside a merge: take the source with the most recent admission
    latest = admissions.groupby(["source_code", "source_patient_id"])["admission_datetime"].max()
    p["_latest_admission"] = [
        latest.get((s, i), "") for s, i in zip(p["source_code"], p["source_local_id"])
    ]
    # most recent admission first; on a tie, the earlier source (A before B)
    p = p.sort_values(["patient_id", "_latest_admission", "_order"],
                      ascending=[True, False, True], kind="mergesort")

    rows, conflicts = [], []
    for patient_id, group in p.groupby("patient_id", sort=True):
        chosen = group.iloc[0].copy()                    # the preferred source record
        for field in CONFLICT_FIELDS:
            filled = group[group[field] != ""]
            if filled.empty:
                continue
            keep = filled.iloc[0]                        # an empty value never wins
            if filled[field].nunique() > 1:
                conflicts.append({
                    "patient_id": patient_id, "field": field,
                    "kept_value": keep[field], "kept_from": f"{keep.source_code}:{keep.source_local_id}",
                    "other_values": "; ".join(
                        f"{r.source_code}:{r.source_local_id}={r[field]}"
                        for _, r in filled.iloc[1:].iterrows()
                    ),
                    "rule": "most recent admission",
                })
            chosen[field] = keep[field]
        dead = group[group["life_status"] == "Deceased"]
        if not dead.empty:                               # a recorded death is final
            chosen["life_status"] = "Deceased"
            chosen["date_of_death"] = dead.iloc[0]["date_of_death"]
        rows.append(chosen)
    integrated = pd.DataFrame(rows)

    # U2: same insurance number on two different people -> keep it on the lower ID only
    candidates = []
    integrated = integrated.sort_values("patient_id")
    for insurance, same in integrated[integrated["_insurance"] != ""].groupby("_insurance"):
        ids = sorted(same["patient_id"])
        for other in ids[1:]:
            candidates.append((ids[0], other, "U2", f"same insurance number {insurance}, different identity"))
            integrated.loc[integrated["patient_id"] == other, "health_insurance_number"] = ""

    # U1: same names and birth date in different sources, insurance missing on a side
    by_person = integrated.groupby(["_first", "_last", "date_of_birth"])
    for _, same in by_person:
        if len(same) < 2:
            continue
        same = same.sort_values("patient_id")
        records = same.to_dict("records")
        for i, left in enumerate(records):
            for right in records[i + 1:]:
                if left["source_code"] != right["source_code"] and "" in (left["_insurance"], right["_insurance"]):
                    candidates.append((left["patient_id"], right["patient_id"], "U1",
                                       "same name and date of birth; insurance number missing on one side"))

    patients_out = integrated[["patient_id"] + PATIENT_COLUMNS].reset_index(drop=True)
    source_map = (
        p[["source_code", "source_local_id", "patient_id", "match_rule", "health_insurance_number"]]
        .rename(columns={"health_insurance_number": "source_insurance_number"})
        .sort_values(["source_code", "patient_id"], kind="mergesort").reset_index(drop=True)
    )
    candidates_out = pd.DataFrame(candidates, columns=["patient_id_1", "patient_id_2", "match_rule", "reason"])
    candidates_out = candidates_out.sort_values(["patient_id_1", "patient_id_2"]).reset_index(drop=True)
    candidates_out.insert(0, "candidate_id", range(1, len(candidates_out) + 1))
    candidates_out["decision"] = "Not merged"
    return patients_out, source_map, candidates_out, pd.DataFrame(conflicts)


def schema_columns() -> dict[str, list[tuple[str, str]]]:
    """Read sql/schema_v2.sql: {table: [(column, type), ...]} in schema order, so the
    output files use exactly the schema's column names and order."""
    tables, current = {}, None
    for line in SCHEMA_V2.read_text(encoding="utf-8").splitlines():
        start = re.match(r"CREATE TABLE (\w+)", line)
        if start:
            current = start.group(1)
            tables[current] = []
        elif current and line.startswith(");"):
            current = None
        elif current:
            column = re.match(r"    ([a-z_0-9]+)\s+([A-Z]+)", line)   # constraint lines start in capitals
            if column:
                tables[current].append((column.group(1), column.group(2)))
    return tables


# Child tables, parents first. For each source_* column in the cleaned
# file: the lookup it goes through, and whether a missing parent rejects the row.
#   required=True  -> the schema column is NOT NULL: no parent, no row (quarantine)
#   required=False -> optional link: an unknown parent becomes NULL and is logged
CHILD_TABLES = [
    ("admissions", "admission_id", {
        "source_patient_id": ("patients", True),
        "source_admitting_professional_id": ("healthcare_professionals", False)}),
    ("triage_assessments", "triage_id", {
        "source_admission_id": ("admissions", True),
        "source_nurse_id": ("healthcare_professionals", False)}),
    ("unit_stays", "unit_stay_id", {
        "source_admission_id": ("admissions", True),
        "source_unit_id": ("hospital_units", True),
        "source_responsible_physician_id": ("healthcare_professionals", False)}),
    ("diagnoses", "diagnosis_id", {
        "source_admission_id": ("admissions", True),
        "source_diagnosing_physician_id": ("healthcare_professionals", False)}),
    ("clinical_notes", "note_id", {
        "source_admission_id": ("admissions", True),
        "source_author_id": ("healthcare_professionals", True)}),
    ("discharge_records", "discharge_id", {
        "source_admission_id": ("admissions", True),
        "source_responsible_physician_id": ("healthcare_professionals", False)}),
    ("diagnostic_orders", "order_id", {
        "source_admission_id": ("admissions", True),
        "source_ordering_physician_id": ("healthcare_professionals", True)}),
    ("diagnostic_examinations", "examination_id", {
        "source_order_id": ("diagnostic_orders", True),
        "source_performed_by_id": ("healthcare_professionals", False)}),
    ("radiology_examinations", "radiology_id", {
        "source_examination_id": ("diagnostic_examinations", True),
        "source_referring_physician_id": ("healthcare_professionals", False),
        "source_technician_id": ("healthcare_professionals", False)}),
    ("radiology_reports", "report_id", {
        "source_radiology_id": ("radiology_examinations", True),
        "source_radiologist_id": ("healthcare_professionals", True)}),
    ("surgical_procedures", "procedure_id", {
        "source_admission_id": ("admissions", True),
        "source_surgeon_id": ("healthcare_professionals", True)}),
]

QUARANTINE_COLUMNS = ["source_code", "entity", "source_local_id", "source_line", "stage", "reason", "raw_record"]


def link_parents(df, entity, links, lookups, quarantine, nulled):
    """Swap every source_<parent>_id for the parent's global ID, looked up in the
    SAME source. Required link missing -> quarantine; optional -> NULL + log."""
    df = df.copy()
    rejected = pd.Series(False, index=df.index)
    reasons = pd.Series("", index=df.index)
    for source_column, (parent, required) in links.items():
        target_column = source_column.removeprefix("source_")
        lookup = lookups[parent]
        global_ids = [lookup.get((s, v)) if v != "" else None
                      for s, v in zip(df["source_code"], df[source_column])]
        df[target_column] = pd.array(global_ids, dtype="Int64")
        unmapped = df[target_column].isna() & (df[source_column] != "")
        if required:
            bad = df[target_column].isna() & ~rejected
            reasons[bad] = f"unmapped parent: {source_column} -> {parent}"
            rejected |= bad
        else:
            for _, row in df[unmapped].iterrows():
                nulled.append({"entity": entity, "source_code": row["source_code"],
                               "source_local_id": row["source_local_id"], "field": target_column,
                               "value": row[source_column], "reason": f"unmapped optional parent {parent}"})
    add_quarantine(quarantine, df[rejected], entity, reasons[rejected])
    return df[~rejected]


def add_quarantine(quarantine, rows, entity, reasons):
    """Rejected rows keep their source, line and raw values, so they can be counted in SQL."""
    for (_, row), reason in zip(rows.iterrows(), reasons):
        raw = {k: v for k, v in row.items() if k.startswith("source_") or isinstance(v, str)}
        quarantine.append({
            "source_code": row["source_code"], "entity": entity,
            "source_local_id": row["source_local_id"], "source_line": row.get("source_line", ""),
            "stage": "integrate", "reason": reason,
            "raw_record": "|".join(f"{k}={v}" for k, v in raw.items() if k != "source_line"),
        })


def patient_from_admission(df, entity, admissions, quarantine):
    """diagnoses and diagnostic_orders also store patient_id: take it from the
    admission's patient AFTER merging, so 'row patient = admission patient' holds.
    If the source said a different patient than its admission, reject the row."""
    df = df.copy()
    admission_patient = dict(zip(admissions["admission_id"], admissions["patient_id"]))
    df["patient_id"] = df["admission_id"].map(admission_patient).astype("Int64")
    claimed = df["_claimed_patient_id"]
    mismatch = claimed.notna() & (claimed != df["patient_id"])
    add_quarantine(quarantine, df[mismatch], entity,
                   ["patient does not match the admission's patient"] * int(mismatch.sum()))
    return df[~mismatch]


def to_schema(df, table, columns):
    """Keep exactly the schema_v2 columns in order; timestamps get an explicit UTC
    offset so any client reads them as the right moment."""
    out = pd.DataFrame(index=df.index)
    for name, sql_type in columns[table]:
        if name not in df.columns:
            raise KeyError(f"{table}.{name} is in schema_v2 but not produced")
        values = df[name]
        if sql_type == "TIMESTAMPTZ":
            values = values.where(values == "", values + "+00:00")
        out[name] = values
    return out


def main() -> None:
    global CLEAN_DIR
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--input", default=str(CLEAN_DIR),
                        help="folder of cleaned (or checked) CSVs; default data/clean")
    args = parser.parse_args()
    CLEAN_DIR = Path(args.input)
    columns = schema_columns()

    # Step 1: tables with no parents
    staff = assign_global_ids(read_clean("healthcare_professionals"), "professional_id")
    units = assign_global_ids(read_clean("hospital_units"), "unit_id")
    icd9 = combine_icd9(read_clean("icd9_dictionary"))

    # Step 2: patients, with matching
    patients, patient_map, candidates, conflicts = integrate_patients(
        read_clean("patients"), read_clean("admissions"))

    lookups = {
        "healthcare_professionals": build_lookup(staff, "professional_id"),
        "hospital_units": build_lookup(units, "unit_id"),
        "patients": build_lookup(patient_map, "patient_id"),
    }
    quarantine, nulled = [], []
    tables = {"source_systems": SOURCE_SYSTEMS, "healthcare_professionals": staff,
              "hospital_units": units, "icd9_dictionary": icd9, "patients": patients,
              "patient_source_map": patient_map, "patient_match_candidates": candidates}
    rows_in = {name: len(read_clean(name)) for name in
               ["healthcare_professionals", "hospital_units", "icd9_dictionary", "patients"]}

    # Steps 3-7: every child table, parents first
    known_codes = set(icd9["icd9_code"])
    for entity, id_column, links in CHILD_TABLES:
        df = read_clean(entity)
        rows_in[entity] = len(df)
        if "source_patient_id" in df.columns and entity != "admissions":
            # what the source claimed, checked against the admission below
            claimed = [lookups["patients"].get((s, v)) for s, v in zip(df["source_code"], df["source_patient_id"])]
            df["_claimed_patient_id"] = pd.array(claimed, dtype="Int64")
        df = link_parents(df, entity, links, lookups, quarantine, nulled)
        if entity == "diagnoses":
            unknown = ~df["icd9_code"].isin(known_codes)
            add_quarantine(quarantine, df[unknown], entity, ["ICD-9 code not in dictionary"] * int(unknown.sum()))
            df = df[~unknown]
        if entity in ("diagnoses", "diagnostic_orders"):
            df = patient_from_admission(df, entity, tables["admissions"], quarantine)
        df = assign_global_ids(df, id_column)
        lookups[entity] = build_lookup(df, id_column)
        tables[entity] = df

    # Write data/integrated/<table>.csv (exact schema_v2 columns) and the reports
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    counts = []
    for table, df in tables.items():
        out = to_schema(df, table, columns)
        out.to_csv(OUT_DIR / f"{table}.csv", index=False, lineterminator="\n")
        rejected = sum(1 for q in quarantine if q["entity"] == table)
        counts.append({"table": table, "rows_in": rows_in.get(table, ""), "rows_out": len(out),
                       "quarantined": rejected})
    pd.DataFrame(quarantine, columns=QUARANTINE_COLUMNS).to_csv(
        OUT_DIR / "quarantine_integrate.csv", index=False, lineterminator="\n")
    pd.DataFrame(counts).to_csv(REPORT_DIR / "counts_integrated.csv", index=False, lineterminator="\n")
    conflicts.to_csv(REPORT_DIR / "patient_merge_conflicts.csv", index=False, lineterminator="\n")
    pd.DataFrame(nulled, columns=["entity", "source_code", "source_local_id", "field", "value", "reason"]).to_csv(
        REPORT_DIR / "integration_nulled_links.csv", index=False, lineterminator="\n")

    for row in counts:
        print(f"{row['table']:<26} in={row['rows_in']!s:>5}  out={row['rows_out']:>5}  quarantined={row['quarantined']}")
    print(f"patients merged (M1 pairs): {(patient_map['match_rule'] == 'M1').sum() // 2}, "
          f"uncertain candidates: {len(candidates)}, merge conflicts: {len(conflicts)}, "
          f"optional links nulled: {len(nulled)}")
    print(f"DA-3 done: {OUT_DIR.relative_to(ROOT)} ready")


if __name__ == "__main__":
    main()