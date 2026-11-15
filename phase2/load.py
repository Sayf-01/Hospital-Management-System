"""LA-1: read the four raw hospital sources into pandas DataFrames.

Run from the repository root:
    python phase2/load.py                  # sample data, checks against reports/counts_sample.csv
    python phase2/load.py --scale full     # full data, checks against reports/counts_raw.csv

Contract for the cleaning step (SA):
  * Values are not changed. Every cell is the text exactly as it appears in the
    file ("15.06.1980", "NULL", " NOTFALL " all stay as they are).
      - A/B: an empty field is the empty string "".
      - C:   an empty element (<dateOfDeath />) is ""; an absent element is None.
      - D:   JSON numbers are kept as their original text (98.0 stays "98.0");
             null and a missing key are both None.
  * Nothing is lost. Every record is either a row in a table or a line in
    reports/malformed_records.csv with a reason.
  * Every row carries _source (A/B/C/D), _file (file name) and _line:
      - A/B: physical line number in the file (header and comments count).
      - C:   line number of the record's opening tag in the XML.
      - D:   the record's position, e.g. $[3].admissions[0].triage[1].
  * C/D nested records get their ancestors' IDs as source_<parent>_id
    columns (source_patient_id, source_admission_id, source_order_id,
    source_examination_id, source_radiology_id), as in KR-1's FIELD_MAPS.
  * Column names are the raw names (A: PAT_ID, B: patient_no, C: @id or
    name/@first, D: patientId). Rename with FIELD_MAPS during cleaning.
"""

import argparse
import csv
import json
import runpy
import sys
from pathlib import Path

import pandas as pd
from lxml import etree

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_RAW_DIR = REPO_ROOT / "data" / "raw" / "sample"
MALFORMED_REPORT = REPO_ROOT / "reports" / "malformed_records.csv"
SOURCE_MAPS = REPO_ROOT / "phase2" / "config" / "source_maps.py"

TRACKING_COLUMNS = ["_source", "_file", "_line"]
MALFORMED_COLUMNS = ["source", "entity", "file", "line", "reason", "raw_record"]

# Nesting trees for C (XML) and D (JSON). Each node is
# (table, container, record tag/key, id field, parent IDs to inherit, children).
# "inherit" lists which ancestor tables pass their ID down, matching the
# source_* fields in KR-1's FIELD_MAPS (e.g. diagnoses get patient + admission).
_NESTED_TREE = [
    ("patients", [], [
        ("admissions", ["patients"], [
            ("triage_assessments", ["admissions"], []),
            ("unit_stays", ["admissions"], []),
            ("diagnoses", ["patients", "admissions"], []),
            ("clinical_notes", ["admissions"], []),
            ("discharge_records", ["admissions"], []),
            ("diagnostic_orders", ["patients", "admissions"], [
                ("diagnostic_examinations", ["diagnostic_orders"], [
                    ("radiology_examinations", ["diagnostic_examinations"], [
                        ("radiology_reports", ["radiology_examinations"], []),
                    ]),
                ]),
            ]),
            ("surgical_procedures", ["admissions"], []),
        ]),
    ]),
]

# Name of the inherited column for each parent table.
_PARENT_COLUMN = {
    "patients": "source_patient_id",
    "admissions": "source_admission_id",
    "diagnostic_orders": "source_order_id",
    "diagnostic_examinations": "source_examination_id",
    "radiology_examinations": "source_radiology_id",
}

# C: (container tag, record tag, id attribute) for each table.
_C_LAYOUT = {
    "healthcare_professionals": ("staff", "professional", "id"),
    "hospital_units": ("units", "unit", "id"),
    "icd9_dictionary": ("icd9", "code", "value"),
    "patients": ("patients", "patient", "id"),
    "admissions": ("admissions", "admission", "id"),
    "triage_assessments": ("triage", "assessment", "id"),
    "unit_stays": ("unitStays", "unitStay", "id"),
    "diagnoses": ("diagnoses", "diagnosis", "id"),
    "clinical_notes": ("clinicalNotes", "note", "id"),
    "discharge_records": ("dischargeRecords", "dischargeRecord", "id"),
    "diagnostic_orders": ("orders", "order", "id"),
    "diagnostic_examinations": ("exams", "exam", "id"),
    "radiology_examinations": ("radiology", "radiologyExam", "id"),
    "radiology_reports": ("reports", "report", "id"),
    "surgical_procedures": ("procedures", "procedure", "id"),
}

# D: (key holding the child list, id key) for each table.
_D_LAYOUT = {
    "patients": (None, "patientId"),
    "admissions": ("admissions", "admissionId"),
    "triage_assessments": ("triage", "triageId"),
    "unit_stays": ("unitStays", "unitStayId"),
    "diagnoses": ("diagnoses", "diagnosisId"),
    "clinical_notes": ("clinicalNotes", "noteId"),
    "discharge_records": ("dischargeRecords", "dischargeId"),
    "diagnostic_orders": ("orders", "orderId"),
    "diagnostic_examinations": ("exams", "examinationId"),
    "radiology_examinations": ("radiology", "radiologyId"),
    "radiology_reports": ("reports", "reportId"),
    "surgical_procedures": ("procedures", "procedureId"),
}
# D: flat files with an array of records at the root.
_D_FLAT_FILES = {
    "healthcare_professionals": "D_staff.json",
    "hospital_units": "D_units.json",
    "icd9_dictionary": "D_icd9.json",
}
_D_NESTED_FILE = "D_patients.json"
_C_FILE = "C_hospital.xml"


# --------------------------------------------------------------------------
# Shared helpers
# --------------------------------------------------------------------------

def _field_maps():
    """KR-1's FIELD_MAPS, used only to order columns. Empty if unavailable."""
    try:
        return runpy.run_path(str(SOURCE_MAPS))["FIELD_MAPS"]
    except (OSError, KeyError):
        return {}


def _to_frame(source, table, records, field_maps):
    """Build a DataFrame of text values with the tracking columns last.

    Columns follow FIELD_MAPS order when the map is available. A mapped column
    that never appears in the file (possible in C/D, where null fields can be
    omitted) is still created, filled with None, so every table has a stable
    shape. Unexpected extra columns are kept, after the mapped ones.
    """
    expected = list(field_maps.get((source, table), {}))
    seen = []
    for record in records:
        for key in record:
            if key not in seen and key not in TRACKING_COLUMNS:
                seen.append(key)
    columns = expected + [c for c in seen if c not in expected] + TRACKING_COLUMNS
    frame = pd.DataFrame.from_records(records, columns=columns)
    # Missing keys become NaN in pandas; use None so "absent" has one form.
    frame = frame.astype(object).where(frame.notna(), None)
    return frame


def _malformed(log, source, entity, file, line, reason, raw):
    log.append({"source": source, "entity": entity, "file": file,
                "line": str(line), "reason": reason, "raw_record": raw})


def _check_raw_dir(raw_dir):
    raw_dir = Path(raw_dir) if raw_dir is not None else DEFAULT_RAW_DIR
    if not raw_dir.is_dir():
        raise FileNotFoundError(f"Raw data folder not found: {raw_dir}")
    return raw_dir


# --------------------------------------------------------------------------
# A and B: one delimited file per table
# --------------------------------------------------------------------------

def _load_delimited(source, path, table, parse_line, is_comment, encoding,
                    malformed, field_maps):
    records = []
    header = None
    with path.open(encoding=encoding, newline="") as file:
        for line_number, raw_line in enumerate(file, start=1):
            line = raw_line.rstrip("\r\n")
            if line == "" or is_comment(line):
                continue
            try:
                values = parse_line(line)
            except csv.Error as error:
                if header is None:
                    raise ValueError(f"{path.name}:{line_number}: unreadable header ({error})")
                _malformed(malformed, source, table, path.name, line_number,
                           f"unparseable line ({error})", line)
                continue
            if header is None:
                header = values
                if len(set(header)) != len(header):
                    raise ValueError(f"{path.name}: duplicate column names in header")
                continue
            if len(values) != len(header):
                _malformed(malformed, source, table, path.name, line_number,
                           f"expected {len(header)} fields, got {len(values)}", line)
                continue
            record = dict(zip(header, values))
            record.update(_source=source, _file=path.name, _line=str(line_number))
            records.append(record)
    if header is None:
        raise ValueError(f"{path.name}: no header line found")
    return _to_frame(source, table, records, field_maps)


def _load_flat_source(source, raw_dir, malformed, field_maps):
    if source == "A":
        pattern, encoding = "A_*.txt", "utf-8"

        def parse_line(line):
            return line.split("|")

        def is_comment(line):
            return line.startswith("#")
    else:
        # utf-8-sig drops the byte-order mark so the first column name is clean.
        pattern, encoding = "B_*.csv", "utf-8-sig"

        def parse_line(line):
            return next(csv.reader([line], delimiter=";", strict=True))

        def is_comment(line):
            return False

    files = sorted(raw_dir.glob(pattern))
    if not files:
        raise FileNotFoundError(f"No {pattern} files in {raw_dir}")
    tables = {}
    for path in files:
        table = path.stem[len(source) + 1:]  # "A_patients" -> "patients"
        tables[table] = _load_delimited(source, path, table, parse_line, is_comment,
                                        encoding, malformed, field_maps)
    return tables


def load_source_a(raw_dir=None, malformed=None):
    """Read the A_*.txt files (pipe-delimited) into {table: DataFrame}.

    Rows with the wrong number of fields go to `malformed` (a list of dicts),
    not to the table. load_all() writes that list to reports/malformed_records.csv.
    """
    malformed = [] if malformed is None else malformed
    return _load_flat_source("A", _check_raw_dir(raw_dir), malformed, _field_maps())


def load_source_b(raw_dir=None, malformed=None):
    """Read the B_*.csv files (semicolon CSV with a UTF-8 BOM) into {table: DataFrame}."""
    malformed = [] if malformed is None else malformed
    return _load_flat_source("B", _check_raw_dir(raw_dir), malformed, _field_maps())


# --------------------------------------------------------------------------
# C: one XML file, nested
# --------------------------------------------------------------------------

def _xml_fields(element, container_tags):
    """Flatten one XML record's own fields, skipping child-record containers.

    Attributes become "@name"; a leaf element becomes its tag; attributes on a
    leaf element become "tag/@name" (e.g. name/@first). An empty element gives "".
    """
    record = {f"@{name}": value for name, value in element.attrib.items()}
    for child in element:
        if not isinstance(child.tag, str):  # comments, processing instructions
            continue
        if child.tag in container_tags:
            continue
        for name, value in child.attrib.items():
            record[f"{child.tag}/@{name}"] = value
        if len(child) == 0 and (child.text is not None or not child.attrib):
            record[child.tag] = child.text if child.text is not None else ""
        elif len(child):
            for grandchild in child:
                if isinstance(grandchild.tag, str):
                    record[f"{child.tag}/{grandchild.tag}"] = grandchild.text or ""
    return record


def _walk_c(element, node, parent_ids, rows, malformed, file_name):
    table, inherit, children = node
    container_tag, record_tag, id_attr = _C_LAYOUT[table]
    child_containers = {_C_LAYOUT[child[0]][0]: child for child in children}
    for container in element.findall(container_tag):
        for record_el in container:
            if not isinstance(record_el.tag, str):
                continue
            if record_el.tag != record_tag:
                _malformed(malformed, "C", table, file_name, record_el.sourceline,
                           f"unexpected <{record_el.tag}> inside <{container_tag}>",
                           etree.tostring(record_el, encoding="unicode")[:500])
                continue
            record = _xml_fields(record_el, set(child_containers))
            for parent in inherit:
                record[_PARENT_COLUMN[parent]] = parent_ids.get(parent)
            record.update(_source="C", _file=file_name, _line=str(record_el.sourceline))
            rows[table].append(record)
            ids = {**parent_ids, table: record_el.get(id_attr)}
            for child in children:
                _walk_c(record_el, child, ids, rows, malformed, file_name)


def load_source_c(raw_dir=None, malformed=None):
    """Read C_hospital.xml into {table: DataFrame}, flattening the nesting."""
    malformed = [] if malformed is None else malformed
    raw_dir = _check_raw_dir(raw_dir)
    path = raw_dir / _C_FILE
    # Safe parser: no external entities, no network access.
    parser = etree.XMLParser(resolve_entities=False, no_network=True, huge_tree=False)
    root = etree.parse(str(path), parser).getroot()
    if root.tag != "hospital":
        raise ValueError(f"{path.name}: expected <hospital> root, found <{root.tag}>")

    rows = {table: [] for table in _C_LAYOUT}
    for table in ("healthcare_professionals", "hospital_units", "icd9_dictionary"):
        _walk_c(root, (table, [], []), {}, rows, malformed, path.name)
    for node in _NESTED_TREE:
        _walk_c(root, node, {}, rows, malformed, path.name)

    field_maps = _field_maps()
    return {table: _to_frame("C", table, records, field_maps)
            for table, records in rows.items()}


# --------------------------------------------------------------------------
# D: four JSON files, patients nested
# --------------------------------------------------------------------------

def _json_text(value):
    """Keep JSON scalars as text. Numbers arrive as their original text."""
    if value is None or isinstance(value, str):
        return value
    if isinstance(value, bool):
        return "true" if value else "false"
    return json.dumps(value, ensure_ascii=False)  # unexpected nested object/list


def _read_json(path):
    # parse_int/parse_float=str keep numbers exactly as written in the file.
    with path.open(encoding="utf-8") as file:
        data = json.load(file, parse_int=str, parse_float=str)
    if not isinstance(data, list):
        raise ValueError(f"{path.name}: expected an array at the root")
    return data


def _walk_d(items, position, node, parent_ids, rows, malformed, file_name):
    table, inherit, children = node
    child_keys = {_D_LAYOUT[child[0]][0] for child in children}
    _, id_key = _D_LAYOUT[table]
    for index, item in enumerate(items):
        where = f"{position}[{index}]"
        if not isinstance(item, dict):
            _malformed(malformed, "D", table, file_name, where,
                       "expected a JSON object", json.dumps(item)[:500])
            continue
        record = {key: _json_text(value) for key, value in item.items()
                  if key not in child_keys}
        for parent in inherit:
            record[_PARENT_COLUMN[parent]] = parent_ids.get(parent)
        record.update(_source="D", _file=file_name, _line=where)
        rows[table].append(record)
        ids = {**parent_ids, table: _json_text(item.get(id_key))}
        for child in children:
            key = _D_LAYOUT[child[0]][0]
            value = item.get(key)
            if value is None:
                continue
            if not isinstance(value, list):
                _malformed(malformed, "D", child[0], file_name, f"{where}.{key}",
                           "expected a JSON array", json.dumps(value)[:500])
                continue
            _walk_d(value, f"{where}.{key}", child, ids, rows, malformed, file_name)


def load_source_d(raw_dir=None, malformed=None):
    """Read the D_*.json files into {table: DataFrame}, flattening the nesting."""
    malformed = [] if malformed is None else malformed
    raw_dir = _check_raw_dir(raw_dir)
    rows = {table: [] for table in list(_D_FLAT_FILES) + list(_D_LAYOUT)}

    for table, file_name in _D_FLAT_FILES.items():
        items = _read_json(raw_dir / file_name)
        for index, item in enumerate(items):
            where = f"$[{index}]"
            if not isinstance(item, dict):
                _malformed(malformed, "D", table, file_name, where,
                           "expected a JSON object", json.dumps(item)[:500])
                continue
            record = {key: _json_text(value) for key, value in item.items()}
            record.update(_source="D", _file=file_name, _line=where)
            rows[table].append(record)

    patients = _read_json(raw_dir / _D_NESTED_FILE)
    for node in _NESTED_TREE:
        _walk_d(patients, "$", node, {}, rows, malformed, _D_NESTED_FILE)

    field_maps = _field_maps()
    return {table: _to_frame("D", table, records, field_maps)
            for table, records in rows.items()}


# --------------------------------------------------------------------------
# All sources
# --------------------------------------------------------------------------

def write_malformed_report(malformed, path=MALFORMED_REPORT):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=MALFORMED_COLUMNS)
        writer.writeheader()
        writer.writerows(malformed)
    return path


def load_all(raw_dir=None, malformed_report=MALFORMED_REPORT):
    """Load A, B, C and D. Returns {"A": {table: DataFrame}, "B": ..., ...}.

    Writes every rejected record to `malformed_report` (set it to None to skip).
    """
    malformed = []
    data = {
        "A": load_source_a(raw_dir, malformed),
        "B": load_source_b(raw_dir, malformed),
        "C": load_source_c(raw_dir, malformed),
        "D": load_source_d(raw_dir, malformed),
    }
    if malformed_report is not None:
        write_malformed_report(malformed, malformed_report)
    return data


def count_check(data, counts_csv, malformed_csv=MALFORMED_REPORT):
    """Compare loaded rows + logged malformed rows with Krish's raw counts.

    Krish's raw_records counts every record in the file, including malformed
    ones, so: rows in the table + rows in the malformed log = raw_records.
    Returns a DataFrame with one line per (source, entity) and an "ok" column.
    """
    expected = pd.read_csv(counts_csv, dtype={"source": str, "entity": str})
    bad = pd.read_csv(malformed_csv, dtype=str) if Path(malformed_csv).exists() \
        else pd.DataFrame(columns=MALFORMED_COLUMNS)
    bad_counts = bad.groupby(["source", "entity"]).size()
    lines = []
    for row in expected.itertuples(index=False):
        tables = data.get(row.source, {})
        loaded = len(tables[row.entity]) if row.entity in tables else None
        logged = int(bad_counts.get((row.source, row.entity), 0))
        ok = (loaded is not None and loaded + logged == row.raw_records
              and logged == row.malformed_rows_included)
        lines.append({"source": row.source, "entity": row.entity, "loaded": loaded,
                      "malformed": logged, "expected_raw": row.raw_records,
                      "expected_malformed": row.malformed_rows_included, "ok": ok})
    listed = set(zip(expected["source"], expected["entity"]))
    for source, tables in data.items():
        for table, frame in tables.items():
            if (source, table) not in listed:
                lines.append({"source": source, "entity": table, "loaded": len(frame),
                              "malformed": None, "expected_raw": None,
                              "expected_malformed": None, "ok": False})
    return pd.DataFrame(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--scale", choices=("sample", "full"), default="sample")
    parser.add_argument("--raw-dir", type=Path, help="Default: data/raw/<scale>")
    args = parser.parse_args()
    raw_dir = args.raw_dir or REPO_ROOT / "data" / "raw" / args.scale
    counts_csv = REPO_ROOT / "reports" / (
        "counts_sample.csv" if args.scale == "sample" else "counts_raw.csv")

    data = load_all(raw_dir)
    report = count_check(data, counts_csv)
    with pd.option_context("display.max_rows", None, "display.width", 120):
        print(report.to_string(index=False))
    total = sum(len(frame) for tables in data.values() for frame in tables.values())
    print(f"\nLoaded {total:,} rows; {int(report['malformed'].fillna(0).sum())} "
          f"malformed record(s) logged to {MALFORMED_REPORT.relative_to(REPO_ROOT)}")
    if report["ok"].all():
        print(f"All {len(report)} tables match {counts_csv.name}.")
        return 0
    print(f"MISMATCH in {int((~report['ok']).sum())} table(s); see rows with ok=False.")
    return 1


if __name__ == "__main__":
    sys.exit(main())