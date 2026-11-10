"""KR-2 Step 4: write and verify the four raw source formats.

Run from the repository root: python phase2/generator/write_sources.py
The default produces the sample, with no changes to Step 3 or its preview.
"""

import argparse
import codecs
import csv
import io
import json
import runpy
import xml.etree.ElementTree as ET
from collections import Counter, defaultdict
from datetime import date, datetime
from pathlib import Path
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from generate_sources import (
    ISSUE_COLUMNS, MAP_PATH, PRIMARY_KEYS, SOURCES, generate, inject_errors,
)


# The paths and field names come from the KR-1 map. These keys identify
# the immediate parent for each table nested in the XML and JSON sources.
PARENTS = {
    "admissions": ("patients", "patient_id"),
    "triage_assessments": ("admissions", "admission_id"),
    "unit_stays": ("admissions", "admission_id"),
    "diagnoses": ("admissions", "admission_id"),
    "clinical_notes": ("admissions", "admission_id"),
    "discharge_records": ("admissions", "admission_id"),
    "diagnostic_orders": ("admissions", "admission_id"),
    "diagnostic_examinations": ("diagnostic_orders", "order_id"),
    "radiology_examinations": ("diagnostic_examinations", "examination_id"),
    "radiology_reports": ("radiology_examinations", "radiology_id"),
    "surgical_procedures": ("admissions", "admission_id"),
}

GERMAN_ADMISSION_TYPES = {
    "Emergency": "Notfall", "Urgent": "Dringend",
    "Elective": "Geplant", "Outpatient": "Ambulant",
}
TRIAGE = {
    "A": ("1", "3", "5"), "B": ("P1", "P2", "P3"),
    "C": ("Red", "Yellow", "Green"), "D": (1, 2, 3),
}
PRIORITY = ("High-Priority Emergency", "Urgent", "Non-Urgent")
NULL_MARKERS = {"A": ("", "NULL", "-"), "B": ("", "N/A", "?")}
OMIT = object()


def day_first(value):
    # Avoid platform-specific strftime flags for the unpadded hour.
    return value.strftime("%d/%m/%Y ") + value.strftime("%I:%M %p").lstrip("0")


class Writer:
    def __init__(self, output, config, events):
        self.output = output
        self.fields = config["FIELD_MAPS"]
        self.locations = config["SOURCE_LOCATIONS"]
        self.nested_fields = config["NESTED_PARENT_FIELDS"]
        zones = config["SOURCE_TIME_ZONES"]
        self.zones = {source: ZoneInfo(zones[source]) for source in ("C", "D")}
        self.pending = {
            (e["source"], e["entity"], e["local_id"], e["issue"]): e
            for e in events if e["status"] == "pending_serialization"
        }
        self.malformed = Counter()

    def path(self, source, table):
        return self.output / self.locations[source, table].split(": ", 1)[0]

    def transform(self, source, table, row, field):
        value = row[field]
        identifier = row[PRIMARY_KEYS[table]]
        # Stable across processes and across exact duplicate occurrences.
        selector = sum(ord(c) for c in f"{identifier}:{field}")
        if value is None:
            if source in NULL_MARKERS:
                options = NULL_MARKERS[source]
                return options[selector % len(options)]
            if selector % 3 == 0:
                return OMIT
            return None
        if field == "gender" and source == "A":
            return {"Male": "M", "Female": "F"}[value]
        if field == "priority_level":
            return TRIAGE[source][PRIORITY.index(value)]
        if field == "admission_type" and source == "B":
            category = value.strip().title()
            raw = GERMAN_ADMISSION_TYPES.get(category, value)
            return f" {raw.upper()} " if value != category else raw
        if field == "date_of_birth":
            pattern = {"B": "%d.%m.%Y", "D": "%d/%m/%Y"}.get(source)
            return date.fromisoformat(value).strftime(pattern) if pattern else value
        if field.endswith("_datetime") or field == "date_of_death":
            try:
                when = datetime.fromisoformat(value)
            except ValueError:
                # Keep deliberately invalid input visible to the loader.
                return value
            if source == "A":
                return when.strftime("%Y-%m-%d %H:%M")
            if source == "B":
                return when.strftime("%d.%m.%Y %H:%M")
            zoned = when.replace(tzinfo=self.zones[source])
            if source == "C":
                return zoned.isoformat()
            if field == "note_datetime":
                event = self.pending.get((source, table, identifier, "ambiguous_day_first"))
                if event is not None:
                    raw = day_first(when)
                    event.update(planted_value=json.dumps(raw), status="applied",
                                 details=f"{self.path(source, table).name}: "
                                         "day-first local string with two plausible readings")
                    return raw
            # Put some ordinary local strings in D as well, keeping additional
            # ambiguous cases limited to those selected by the injection step.
            if when.day > 12 and selector % 4 == 0:
                return day_first(when)
            return int(zoned.timestamp())
        if field == "body_temperature" and source == "A":
            return f"{value * 9 / 5 + 32:.1f}"
        if isinstance(value, float) and source == "B":
            return str(value).replace(".", ",")
        return value

    @staticmethod
    def flat_line(source, values):
        values = [str(value) for value in values]
        if any("\r" in value or "\n" in value for value in values):
            raise ValueError("The TXT and CSV contract allows one physical line per record")
        if source == "A":
            if any("|" in value for value in values):
                raise ValueError("Unexpected TXT delimiter inside a field")
            return "|".join(values)
        buffer = io.StringIO(newline="")
        csv.writer(buffer, delimiter=";", lineterminator="\n").writerow(values)
        return buffer.getvalue()[:-1]

    def write_flat(self, source, table, rows):
        path = self.path(source, table)
        fields = self.fields[source, table]
        encoding = "utf-8" if source == "A" else "utf-8-sig"
        with path.open("x", encoding=encoding, newline="\n") as file:
            if source == "A":
                file.write(f"# Synthetic hospital data: source A, {table}\n")
            file.write(self.flat_line(source, fields) + "\n")
            first_row = 3 if source == "A" else 2
            for line_number, row in enumerate(rows, first_row):
                values = [self.transform(source, table, row, field) for field in fields.values()]
                identifier = row[PRIMARY_KEYS[table]]
                event = self.pending.get((source, table, identifier, "malformed_rows"))
                if event is not None:
                    good = self.flat_line(source, values)
                    bad = self.flat_line(source, values[:-1])
                    event.update(original_value=json.dumps(good), planted_value=json.dumps(bad),
                                 status="applied", details=f"{path.name}:{line_number}: final field removed")
                    self.malformed[source, table] += 1
                    file.write(bad + "\n")
                else:
                    file.write(self.flat_line(source, values) + "\n")

    def write_txt(self, tables):
        for table, rows in tables.items():
            self.write_flat("A", table, rows)

    def write_csv(self, tables):
        for table, rows in tables.items():
            self.write_flat("B", table, rows)

    def project(self, source, table, row):
        values = {}
        for raw, field in self.fields[source, table].items():
            if field in self.nested_fields.get(table, ()):
                continue
            value = self.transform(source, table, row, field)
            if value is not OMIT:
                values[raw] = value
        return values

    def nested_builder(self, tables, render):
        grouped = defaultdict(lambda: defaultdict(list))
        child_tables = defaultdict(list)
        for child, (parent, foreign_key) in PARENTS.items():
            child_tables[parent].append(child)
            for row in tables[child]:
                grouped[child][row[foreign_key]].append(row)
        expanded = set()

        def build(table, row):
            identifier = row[PRIMARY_KEYS[table]]
            key = (table, identifier)
            children = {}
            # A duplicate admission still appears as a second record, but
            # placing its descendants twice would invent extra duplicate rows.
            if key not in expanded:
                expanded.add(key)
                for child in child_tables[table]:
                    matches = grouped[child].get(identifier, ())
                    if matches:
                        children[child] = [build(child, item) for item in matches]
            return render(table, row, children)

        return build

    def xml_path(self, table):
        return self.locations["C", table].split(": ", 1)[1].strip("/").split("/")

    def write_xml(self, tables):
        def render(table, row, children):
            element = ET.Element(self.xml_path(table)[-1])
            for raw, value in self.project("C", table, row).items():
                node = element
                parts = raw.split("/")
                for tag in parts[:-1]:
                    sub = node.find(tag)
                    node = sub if sub is not None else ET.SubElement(node, tag)
                leaf = parts[-1]
                if leaf.startswith("@"):
                    node.set(leaf[1:], str(value))
                else:
                    ET.SubElement(node, leaf).text = None if value is None else str(value)
            for child, nodes in children.items():
                ET.SubElement(element, self.xml_path(child)[-2]).extend(nodes)
            return element

        root = ET.Element("hospital")
        build = self.nested_builder(tables, render)
        for table in tables:
            if table not in PARENTS:
                container = ET.SubElement(root, self.xml_path(table)[-2])
                container.extend(build(table, row) for row in tables[table])
        ET.indent(root, space="  ")
        with self.path("C", "patients").open("xb") as file:
            ET.ElementTree(root).write(file, encoding="utf-8", xml_declaration=True)

    def json_path(self, table):
        return self.locations["D", table].split(": ", 1)[1].split(".")[1:]

    def write_json(self, tables):
        def render(table, row, children):
            obj = self.project("D", table, row)
            for child, items in children.items():
                obj[self.json_path(child)[-1].removesuffix("[*]")] = items
            return obj

        build = self.nested_builder(tables, render)
        for table, rows in tables.items():
            if table not in PARENTS:
                with self.path("D", table).open("x", encoding="utf-8", newline="\n") as file:
                    json.dump([build(table, row) for row in rows], file, ensure_ascii=False, indent=2)
                    file.write("\n")

    def verify(self, dataset):
        """Read all emitted files back and reconcile entity and malformed counts."""
        xml = ET.parse(self.path("C", "patients")).getroot()
        if xml.tag != "hospital":
            raise ValueError("Unexpected C root element")
        json_paths = {self.path("D", table) for table in dataset["D"]}
        json_files = {path: json.loads(path.read_text(encoding="utf-8")) for path in json_paths}
        counts = []
        for source, tables in dataset.items():
            for table, rows in tables.items():
                path = self.path(source, table)
                if source in ("A", "B"):
                    if path.read_bytes().startswith(codecs.BOM_UTF8) != (source == "B"):
                        raise ValueError(f"Unexpected BOM: {path}")
                    text = path.read_text(encoding="utf-8" if source == "A" else "utf-8-sig")
                    lines = [line for line in text.splitlines() if line and
                             not (source == "A" and line.startswith("#"))]
                    parsed = [line.split("|") if source == "A" else
                              next(csv.reader([line], delimiter=";", strict=True)) for line in lines]
                    header = list(self.fields[source, table])
                    if parsed[0] != header:
                        raise ValueError(f"Wrong columns: {path}")
                    raw = parsed[1:]
                    count = len(raw)
                    bad = sum(len(values) != len(header) for values in raw)
                else:
                    if source == "C":
                        raw = xml.findall("./" + "/".join(self.xml_path(table)[1:]))
                        id_field = "@value" if table == "icd9_dictionary" else "@id"
                        actual_ids = Counter(record.get(id_field[1:]) for record in raw)
                    else:
                        raw = json_files[path]
                        if not isinstance(raw, list):
                            raise ValueError(f"Expected an array: {path}")
                        for segment in self.json_path(table):
                            raw = [child for record in raw
                                   for child in record.get(segment.removesuffix("[*]"), [])]
                        id_field = next(raw_key for raw_key, canonical in self.fields[source, table].items()
                                        if canonical == PRIMARY_KEYS[table])
                        actual_ids = Counter(record[id_field] for record in raw)
                    expected_ids = Counter(
                        str(row[PRIMARY_KEYS[table]]) if source == "C" else row[PRIMARY_KEYS[table]]
                        for row in rows
                    )
                    if actual_ids != expected_ids:
                        raise ValueError(f"IDs changed during serialization: {source} {table}")
                    count, bad = len(raw), 0
                if count != len(rows) or bad != self.malformed[source, table]:
                    raise ValueError(f"Row count mismatch: {source} {table}")
                counts.append({"source": source, "entity": table, "raw_records": count,
                               "malformed_rows_included": bad})
        return counts


def write_report(path, rows, columns):
    with path.open("x", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=columns)
        writer.writeheader()
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scale", choices=("sample", "full"), default="sample")
    parser.add_argument("--output-dir", type=Path, help="Default: data/raw/<scale>")
    parser.add_argument("--reports-dir", type=Path, default=Path("reports"))
    args = parser.parse_args()
    output = (args.output_dir or Path("data/raw") / args.scale).resolve()
    reports = args.reports_dir.resolve()
    if reports == output or output in reports.parents:
        parser.error("Keep reports and the answer key outside the raw output folder")
    issues = reports / "ground_truth" / (
        "injected_errors_sample.csv" if args.scale == "sample" else "injected_errors.csv"
    )
    counts_path = reports / ("counts_sample.csv" if args.scale == "sample" else "counts_raw.csv")
    for path in (issues, counts_path):
        if path.exists():
            parser.error(f"Report already exists: {path}; use a new --reports-dir")
    if output.exists() and (not output.is_dir() or any(output.iterdir())):
        parser.error(f"Raw output is not an empty directory: {output}; use a new --output-dir")

    config = runpy.run_path(str(MAP_PATH))
    data = generate(args.scale)
    rates = config["INJECTION_RATES"]
    if args.scale == "sample":
        # KR-2 wants at least two examples of this D-only issue in the sample.
        rates = {**rates, "ambiguous_day_first": {**rates["ambiguous_day_first"], "D": 0.06}}
    events = inject_errors(data, args.scale, rates)
    try:
        writer = Writer(output, config, events)
    except ZoneInfoNotFoundError:
        parser.error("Missing time-zone data. Run: python -m pip install tzdata")
    output.mkdir(parents=True, exist_ok=True)
    writer.write_txt(data["A"])
    writer.write_csv(data["B"])
    writer.write_xml(data["C"])
    writer.write_json(data["D"])
    counts = writer.verify(data)
    if any(e["status"] != "applied" for e in events):
        raise ValueError("Some planned issues were not written to a source")
    totals = Counter()
    bad = Counter()
    for row in counts:
        totals[row["source"]] += row["raw_records"]
        bad[row["source"]] += row["malformed_rows_included"]
    if args.scale == "full" and (
        not all(5500 <= totals[s] <= 9500 for s in SOURCES)
        or not 20000 <= sum(totals.values()) <= 40000
    ):
        raise ValueError(f"Full source totals fall outside the required range: {totals}")
    issues.parent.mkdir(parents=True, exist_ok=True)
    write_report(issues, events, ISSUE_COLUMNS)
    write_report(counts_path, counts,
                 ("source", "entity", "raw_records", "malformed_rows_included"))
    formats = dict(zip(SOURCES, ("TXT", "CSV", "XML", "JSON")))
    for source in SOURCES:
        suffix = f", including {bad[source]} deliberate malformed row(s)" if bad[source] else ""
        print(f"{source} ({formats[source]}): {totals[source]:,} raw records{suffix}")
    print(f"Verified {len(list(output.iterdir()))} files and {sum(totals.values()):,} total records.")
    print(f"Raw files: {output}\nCounts: {counts_path}\nAnswer key: {issues}")
    print(f"Ground truth: {len(events)} applied log entries; 0 pending.")


if __name__ == "__main__":
    main()
