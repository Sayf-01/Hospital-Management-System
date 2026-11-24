"""Validate source-local relationships and UTC chronology in the Phase 2 CSVs."""

import argparse
from collections import Counter
from pathlib import Path

import pandas as pd

from phase2.clean import (
    ENTITY_ORDER,
    EVENTS_INSIDE_ADMISSION,
    QUARANTINE_COLUMNS,
    REFERENCES,
    ROOT,
    SOURCES,
    TRIAGE_BEFORE_ADMISSION,
    raw_json,
)


IDENTIFIERS = ["source_code", "source_local_id", "source_line"]
COMPLETED = {"Discharged", "Deceased"}
TIMES = {
    "patients": ("date_of_death", "date_of_birth"),
    "admissions": ("admission_datetime", "discharge_datetime"),
    "unit_stays": ("entry_datetime", "exit_datetime"),
    "triage_assessments": ("assessment_datetime",),
    "diagnostic_examinations": ("examination_datetime",),
    "radiology_reports": ("report_datetime",),
    **{entity: (column,) for entity, column in EVENTS_INSIDE_ADMISSION.items()},
}
FLAG_COLUMNS = [*IDENTIFIERS, "entity", "field", "value", "reason"]
ADMISSION_EVENTS = {
    **EVENTS_INSIDE_ADMISSION,
    "diagnostic_examinations": "examination_datetime",
    "triage_assessments": "assessment_datetime",
    "unit_stays": "entry_datetime",
}


def key_column(entity):
    return "icd9_code" if entity == "icd9_dictionary" else "source_local_id"


def within_admission(when, admission, *, lead_time=pd.Timedelta(0)):
    start, end = admission["admission_datetime"], admission["discharge_datetime"]
    return pd.notna(when) and when >= start - lead_time and (pd.isna(end) or when <= end)


class RelationChecks:
    def __init__(self, frames, prior_quarantine):
        self.frames = frames
        self.rows = {}
        self.times = {}
        self.active = {}
        self.rejections = {}
        self.rejected_keys = {entity: set() for entity in ENTITY_ORDER}
        self.flags = []
        self.prior = {entity: set() for entity in ENTITY_ORDER}
        for row in prior_quarantine:
            if row["entity"] in self.prior and row["source_local_id"]:
                self.prior[row["entity"]].add((row["source_code"], row["source_local_id"]))

        for entity, frame in frames.items():
            self.rows[entity] = frame.to_dict("records")
            key = key_column(entity)
            self.active[entity] = {
                (row["source_code"], row[key]): index
                for index, row in enumerate(self.rows[entity])
            }
            if (len(self.active[entity]) != len(frame) or frame[key].eq("").any()
                    or not frame["source_code"].isin(SOURCES).all()):
                raise ValueError(f"{entity}: expected unique, nonempty IDs within known sources")
            self.times[entity] = {
                column: pd.to_datetime(frame[column], format="ISO8601", utc=True,
                                       errors="coerce").tolist()
                for column in TIMES.get(entity, ())
            }

    def reject(self, entity, index, reason, stage="relationships"):
        row = self.rows[entity][index]
        key = (row["source_code"], row[key_column(entity)])
        del self.active[entity][key]
        self.rejected_keys[entity].add(key)
        self.rejections[entity, index] = (stage, reason)

    def clear_optional(self, entity, index, field, reason):
        row = self.rows[entity][index]
        self.flags.append({
            **{column: row[column] for column in IDENTIFIERS},
            "entity": entity, "field": field, "value": row[field], "reason": reason,
        })
        row[field] = ""

    def parent(self, row, entity, ref):
        return self.active[entity].get((row["source_code"], row[ref]))

    def dates(self, entity, index):
        return {column: values[index] for column, values in self.times[entity].items()}

    def check_references(self, entity, index, row):
        missing = []
        optional = []
        for field, parent, required in REFERENCES.get(entity, ()):
            key = (row["source_code"], row[field])
            if key in self.active[parent]:
                continue
            if required:
                if key[1] and (key in self.prior[parent] or key in self.rejected_keys[parent]):
                    return "parent quarantined"
                missing.append(f"{field} in {parent}")
            elif key[1]:
                optional.append((field, parent))
        if missing:
            return f"missing parent: {', '.join(missing)}"
        if entity in ("diagnoses", "diagnostic_orders"):
            admission = self.parent(row, "admissions", "source_admission_id")
            if row["source_patient_id"] != self.rows["admissions"][admission]["source_patient_id"]:
                return "source_patient_id does not match the admission's patient"
        for field, parent in optional:
            self.clear_optional(entity, index, field, f"unresolved optional reference to {parent}")
        return None

    def check_admission(self, row, times):
        start, end = times["admission_datetime"], times["discharge_datetime"]
        status = row["admission_status"]
        if pd.isna(start):
            return "invalid admission_datetime"
        if status in COMPLETED and (pd.isna(end) or end <= start):
            return "completed admission requires discharge_datetime after admission_datetime"
        if status == "Admitted" and row["discharge_datetime"]:
            return "Admitted status conflicts with discharge_datetime"
        patient = self.parent(row, "patients", "source_patient_id")
        patient_row = self.rows["patients"][patient]
        dates = self.dates("patients", patient)
        death = dates["date_of_death"]
        if pd.notna(dates["date_of_birth"]) and start < dates["date_of_birth"]:
            return "admission_datetime precedes date_of_birth"
        if status == "Deceased" and (
            patient_row["life_status"] != "Deceased" or not within_admission(death, times)
        ):
            return "Deceased admission requires a Deceased patient with date_of_death within the admission"
        if pd.notna(death) and start > death:
            return "admission_datetime is after date_of_death"
        return None

    def check_chronology(self, entity, index, row):
        times = self.dates(entity, index)
        if entity == "admissions":
            return self.check_admission(row, times)
        if entity == "radiology_reports":
            radiology = self.parent(row, "radiology_examinations", "source_radiology_id")
            exam = self.parent(self.rows["radiology_examinations"][radiology],
                               "diagnostic_examinations", "source_examination_id")
            report_time = times["report_datetime"]
            if pd.isna(report_time) or report_time < self.dates("diagnostic_examinations", exam)["examination_datetime"]:
                return "report_datetime is invalid or precedes the examination"
            return None
        if entity == "diagnostic_examinations":
            order = self.parent(row, "diagnostic_orders", "source_order_id")
            when = times["examination_datetime"]
            if pd.notna(when) and when < self.dates("diagnostic_orders", order)["order_datetime"]:
                return "examination_datetime precedes order_datetime"
            row = self.rows["diagnostic_orders"][order]

        event_field = ADMISSION_EVENTS.get(entity)
        if event_field is None:
            return None
        admission = self.dates("admissions", self.parent(row, "admissions", "source_admission_id"))
        when = times[event_field]
        lead = TRIAGE_BEFORE_ADMISSION if entity == "triage_assessments" else pd.Timedelta(0)
        if not within_admission(when, admission, lead_time=lead):
            return f"{event_field} is invalid or outside the allowed admission period"
        if entity == "unit_stays" and row["exit_datetime"]:
            end = times["exit_datetime"]
            if pd.isna(end) or end <= when or not within_admission(end, admission):
                self.clear_optional(entity, index, "exit_datetime",
                                    "exit_datetime is invalid, not after entry, or after discharge")
        return None

    def check_overlaps(self):
        entity = "unit_stays"
        latest_exit = {}
        entries = self.times[entity]["entry_datetime"]
        for index in sorted(self.active[entity].values(), key=entries.__getitem__):
            row = self.rows[entity][index]
            admission_key = (row["source_code"], row["source_admission_id"])
            previous = latest_exit.get(admission_key)
            if previous is not None and entries[index] < previous:
                self.reject(entity, index, "unit stay overlaps an earlier stay for the same admission",
                            stage="chronology")
                continue
            # A missing exit leaves the end unknown. The cleaning rules only
            # establish an overlap when an earlier exit is known.
            if row["exit_datetime"]:
                latest_exit[admission_key] = self.times[entity]["exit_datetime"][index]

    def require_primary(self):
        primary = {
            (row["source_code"], row["source_admission_id"])
            for index in self.active["diagnoses"].values()
            if (row := self.rows["diagnoses"][index])["diagnosis_type"] == "Primary"
        }
        for key, index in list(self.active["admissions"].items()):
            row = self.rows["admissions"][index]
            if row["admission_status"] in COMPLETED and key not in primary:
                self.reject("admissions", index, "completed admission has no valid Primary diagnosis")

    def run(self):
        # Validate diagnoses immediately after admissions, then enforce the
        # primary diagnosis rule before checking the other descendants.
        order = list(ENTITY_ORDER)
        order.remove("diagnoses")
        order.insert(order.index("admissions") + 1, "diagnoses")
        for entity in order:
            for index, row in enumerate(self.rows[entity]):
                reason = self.check_references(entity, index, row)
                if reason:
                    self.reject(entity, index, reason)
                elif reason := self.check_chronology(entity, index, row):
                    self.reject(entity, index, reason, stage="chronology")
            if entity == "diagnoses":
                self.require_primary()
                for index in list(self.active[entity].values()):
                    row = self.rows[entity][index]
                    if self.parent(row, "admissions", "source_admission_id") is None:
                        self.reject(entity, index, "parent quarantined")
            if entity == "unit_stays":
                self.check_overlaps()
        return self.build_outputs()

    def build_outputs(self):
        checked, quarantine, counts = {}, [], []
        for entity, frame in self.frames.items():
            kept = list(self.active[entity].values())
            checked[entity] = pd.DataFrame(
                [self.rows[entity][index] for index in kept], columns=frame.columns,
            )
            for index in frame.index.difference(kept):
                original = frame.loc[index]
                stage, reason = self.rejections[entity, index]
                quarantine.append({
                    **{column: original[column] for column in IDENTIFIERS},
                    "entity": entity, "stage": stage, "reason": reason,
                    "raw_record": raw_json(original),
                })
            incoming = Counter(frame["source_code"])
            outgoing = Counter(checked[entity]["source_code"])
            rejected = Counter(row["source_code"] for row in quarantine if row["entity"] == entity)
            for source in SOURCES:
                counts.append({
                    "source": source, "entity": entity, "rows_in": incoming[source],
                    "rows_out": outgoing[source], "quarantined": rejected[source],
                    "reconciles": incoming[source] == outgoing[source] + rejected[source],
                })
        return (checked, pd.DataFrame(quarantine, columns=QUARANTINE_COLUMNS),
                pd.DataFrame(self.flags, columns=FLAG_COLUMNS), pd.DataFrame(counts))


def run(input_dir, output_dir, quarantine_dir, report_dir):
    if output_dir.resolve() in (input_dir.resolve(), quarantine_dir.resolve()):
        raise ValueError("Checked output must be separate from input and quarantine directories.")
    frames = {}
    prior_quarantine = []
    for entity in ENTITY_ORDER:
        path = input_dir / f"{entity}.csv"
        frame = pd.read_csv(path, dtype=str, keep_default_na=False)
        required = {*IDENTIFIERS, key_column(entity), *TIMES.get(entity, ())}
        required.update(field for field, _, _ in REFERENCES.get(entity, ()))
        required.update({
            "admissions": {"admission_status"}, "patients": {"life_status"},
            "diagnoses": {"diagnosis_type"},
        }.get(entity, ()))
        if missing := required.difference(frame.columns):
            raise ValueError(f"{path}: missing columns {', '.join(sorted(missing))}")
        frames[entity] = frame
        prior = quarantine_dir / path.name
        if prior.is_file():
            prior_quarantine.extend(pd.read_csv(prior, dtype=str, keep_default_na=False)
                                    .to_dict("records"))

    checked, quarantine, flags, counts = RelationChecks(frames, prior_quarantine).run()
    for directory in (output_dir, quarantine_dir, report_dir):
        directory.mkdir(parents=True, exist_ok=True)
    for entity, frame in checked.items():
        frame.to_csv(output_dir / f"{entity}.csv", index=False, lineterminator="\n")
    # Stage-owned file. The cleaner's per-entity quarantine files remain intact.
    quarantine.to_csv(quarantine_dir / "quarantine_check.csv", index=False, lineterminator="\n")
    flags.to_csv(report_dir / "relation_check_flags.csv", index=False, lineterminator="\n")
    examples = quarantine.groupby(["source_code", "reason"], sort=False).head(2)
    examples.to_csv(report_dir / "relation_check_examples.csv", index=False, lineterminator="\n")
    counts.to_csv(report_dir / "counts_checked.csv", index=False, lineterminator="\n")
    return counts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=ROOT / "data" / "clean")
    parser.add_argument("--output", type=Path, default=ROOT / "data" / "checked")
    parser.add_argument("--quarantine", type=Path, default=ROOT / "data" / "quarantine")
    parser.add_argument("--reports", type=Path, default=ROOT / "reports")
    args = parser.parse_args()
    try:
        counts = run(args.input, args.output, args.quarantine, args.reports)
    except (OSError, ValueError) as exc:
        parser.exit(1, f"{exc}\n")
    print(f"Accepted {counts['rows_out'].sum():,} records, "
          f"quarantined {counts['quarantined'].sum():,}.")


if __name__ == "__main__":
    main()
