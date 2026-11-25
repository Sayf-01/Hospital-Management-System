import unittest

import pandas as pd

from pipeline.check_relations import ENTITY_ORDER, ROOT, RelationChecks


class RelationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.headers = {
            entity: pd.read_csv(ROOT / "data" / "clean" / f"{entity}.csv", nrows=0).columns
            for entity in ENTITY_ORDER
        }

    def setUp(self):
        self.records = {entity: [] for entity in ENTITY_ORDER}
        self.add("patients", "1", life_status="Alive", date_of_birth="1980-01-01")
        self.add("healthcare_professionals", "1")
        self.add("hospital_units", "1")
        self.add("icd9_dictionary", "038.9", icd9_code="038.9")
        self.add("admissions", "1", source_patient_id="1", admission_status="Admitted",
                 admission_datetime="2026-01-02 00:00:00")

    def add(self, entity, local_id, source="A", **fields):
        row = {column: "" for column in self.headers[entity]}
        row.update(source_code=source, source_local_id=local_id,
                   source_line=str(len(self.records[entity]) + 2), **fields)
        self.records[entity].append(row)
        return row

    def check(self, prior=()):
        frames = {
            entity: pd.DataFrame(records, columns=self.headers[entity])
            for entity, records in self.records.items()
        }
        return RelationChecks(frames, prior).run()

    def test_required_parent_must_exist_in_same_source(self):
        self.add("patients", "99", source="B", life_status="Alive")
        self.records["admissions"][0]["source_patient_id"] = "99"
        _, quarantine, _, _ = self.check()
        self.assertEqual(quarantine.loc[0, "reason"], "missing parent: source_patient_id in patients")

    def test_previously_quarantined_parent_is_distinguished_from_missing(self):
        self.records["admissions"][0]["source_patient_id"] = "99"
        _, quarantine, _, _ = self.check([
            {"entity": "patients", "source_code": "A", "source_local_id": "99"}
        ])
        self.assertEqual(quarantine.loc[0, "reason"], "parent quarantined")

    def test_required_staff_rejects_and_optional_staff_is_cleared_and_flagged(self):
        self.add("clinical_notes", "2", source_admission_id="1", source_author_id="99",
                 note_datetime="2026-01-02 02:00:00")
        self.add("triage_assessments", "2", source_admission_id="1", source_nurse_id="99",
                 assessment_datetime="2026-01-02 00:00:00")
        checked, quarantine, flags, _ = self.check()
        self.assertEqual(quarantine.loc[0, "reason"],
                         "missing parent: source_author_id in healthcare_professionals")
        self.assertEqual(checked["triage_assessments"].iloc[0]["source_nurse_id"], "")
        self.assertEqual(flags.loc[0, ["field", "value"]].tolist(), ["source_nurse_id", "99"])

    def test_bad_chronology_rejects_required_time_and_clears_optional_exit(self):
        self.add("clinical_notes", "2", source_admission_id="1", source_author_id="1",
                 note_datetime="2026-01-02 00:30:00+01:00")
        self.add("unit_stays", "2", source_admission_id="1", source_unit_id="1",
                 entry_datetime="2026-01-02 01:00:00", exit_datetime="2026-01-02 00:00:00")
        checked, quarantine, flags, _ = self.check()
        self.assertEqual(quarantine.loc[0, "entity"], "clinical_notes")
        self.assertIn("outside", quarantine.loc[0, "reason"])
        self.assertEqual(checked["unit_stays"].iloc[0]["exit_datetime"], "")
        self.assertEqual(flags.loc[0, "field"], "exit_datetime")

    def test_nested_overlaps_and_boundary_touch(self):
        for local_id, start, end in (("1", "01:00", "05:00"), ("2", "02:00", "03:00"),
                                     ("3", "04:00", "04:30"), ("4", "05:00", "06:00")):
            self.add("unit_stays", local_id, source_admission_id="1", source_unit_id="1",
                     entry_datetime=f"2026-01-02 {start}", exit_datetime=f"2026-01-02 {end}")
        checked, quarantine, _, _ = self.check()
        self.assertEqual(checked["unit_stays"]["source_local_id"].tolist(), ["1", "4"])
        self.assertEqual(quarantine["source_local_id"].tolist(), ["2", "3"])
        self.assertTrue(quarantine["reason"].str.contains("overlaps").all())

    def add_order_chain(self):
        self.add("diagnostic_orders", "2", source_admission_id="1", source_patient_id="1",
                 source_ordering_physician_id="1", order_datetime="2026-01-02 01:00:00")
        self.add("diagnostic_examinations", "2", source_order_id="2",
                 examination_datetime="2026-01-02 02:00:00")
        self.add("radiology_examinations", "2", source_examination_id="2")
        self.add("radiology_reports", "2", source_radiology_id="2", source_radiologist_id="1",
                 report_datetime="2026-01-02 02:00:00")

    def test_invalid_primary_flags_admission_and_keeps_valid_children(self):
        self.records["admissions"][0].update(admission_status="Discharged",
                                              discharge_datetime="2026-01-02 06:00:00")
        self.add("diagnoses", "2", source_admission_id="1", source_patient_id="1",
                 diagnosis_type="Primary", icd9_code="999", diagnosis_datetime="2026-01-02 01:00")
        secondary = self.add("diagnoses", "3", source_admission_id="1", source_patient_id="1",
                             diagnosis_type="Secondary", icd9_code="038.9",
                             diagnosis_datetime="2026-01-02 01:00")
        self.add_order_chain()
        checked, quarantine, flags, counts = self.check()
        self.assertEqual(quarantine["entity"].tolist(), ["diagnoses"])
        self.assertIn("missing parent", quarantine.iloc[0]["reason"])
        self.assertEqual(checked["diagnoses"].to_dict("records"), [secondary])
        self.assertEqual(len(flags), 1)
        self.assertEqual(flags.iloc[0][["entity", "source_code", "source_local_id", "source_line",
                                        "field", "reason"]].tolist(),
                         ["admissions", "A", "1", "2", "diagnosis_type",
                          "completed admission has no valid Primary diagnosis"])
        for entity in ("admissions", "diagnostic_orders", "diagnostic_examinations",
                       "radiology_examinations", "radiology_reports"):
            self.assertEqual(checked[entity].to_dict("records"), self.records[entity])
        self.assertTrue(counts["reconciles"].all())

    def test_invalid_examination_propagates_to_radiology(self):
        self.add_order_chain()
        self.records["diagnostic_examinations"][0]["examination_datetime"] = "2026-01-02 00:30:00"
        _, quarantine, _, _ = self.check()
        reasons = quarantine.set_index("entity")["reason"]
        self.assertIn("precedes order_datetime", reasons["diagnostic_examinations"])
        self.assertEqual(reasons["radiology_examinations"], "parent quarantined")
        self.assertEqual(reasons["radiology_reports"], "parent quarantined")

    def test_deceased_admission_requires_death_inside_window(self):
        self.records["admissions"][0].update(admission_status="Deceased",
                                              discharge_datetime="2026-01-02 06:00:00")
        self.records["patients"][0].update(life_status="Deceased", date_of_death="2026-01-03")
        _, quarantine, _, _ = self.check()
        self.assertIn("date_of_death within the admission", quarantine.loc[0, "reason"])

    def test_valid_records_pass_unchanged(self):
        self.records["admissions"][0].update(admission_status="Discharged",
                                              discharge_datetime="2026-01-02 06:00:00")
        self.add("diagnoses", "2", source_admission_id="1", source_patient_id="1",
                 diagnosis_type="Primary", icd9_code="038.9", diagnosis_datetime="2026-01-02 01:00")
        self.add("triage_assessments", "2", source_admission_id="1",
                 assessment_datetime="2026-01-01 00:00:00")
        self.add_order_chain()
        checked, quarantine, flags, _ = self.check()
        self.assertTrue(quarantine.empty)
        self.assertTrue(flags.empty)
        for entity, records in self.records.items():
            self.assertEqual(checked[entity].to_dict("records"), records, entity)
