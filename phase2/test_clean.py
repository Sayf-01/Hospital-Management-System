"""Tests for SA-3 (phase2/clean.py). Run from the repository root:
    python -m pytest phase2/test_clean.py      (or: python -m unittest phase2.test_clean)

Expected values were worked out by hand or with a second tool (pandas time zones,
`date -u -d @...`), not by running clean.py, so these tests check facts.
"""

import json
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import pandas as pd

from phase2.clean import (
    ROOT,
    clean_blood_pressure,
    clean_category,
    clean_id,
    clean_measurement,
    clean_text,
    find_exact_duplicates,
    fix_icd9,
    is_missing,
    merge_duplicate_patients,
    parse_date,
    parse_timestamp,
    read_schema,
    run,
)

SAMPLE_DIR = ROOT / "data" / "raw" / "sample"
ANSWER_KEY = ROOT / "reports" / "ground_truth" / "injected_errors_sample.csv"


class MissingValues(unittest.TestCase):
    def test_every_source_marker_means_missing(self):
        for marker in ["", "   ", "NULL", "null", "N/A", "NA", "-", "?", "none", None]:
            self.assertTrue(is_missing(marker), marker)
        for value in ["0", "No", "555-0101", "Nonexistent"]:
            self.assertFalse(is_missing(value), value)

    def test_required_columns_come_from_the_phase1_schema(self):
        schema = read_schema()
        self.assertTrue(schema["clinical_notes"]["note_contents"]["required"])
        self.assertFalse(schema["patients"]["phone_number"]["required"])
        self.assertEqual(schema["patients"]["phone_number"]["length"], 20)
        self.assertEqual(len(schema), 15)


class Duplicates(unittest.TestCase):
    def test_exact_duplicates_ignore_only_surrounding_spaces_and_line_numbers(self):
        raw = pd.DataFrame({
            "id": ["1", " 1 ", "1"],
            "type": ["Urgent", "Urgent", "URGENT"],
            "_line": ["2", "3", "4"],
        })
        self.assertEqual(find_exact_duplicates(raw).tolist(), [False, True, False])

    def test_duplicate_patient_keeps_lowest_id_and_needs_insurance(self):
        patients = pd.DataFrame({
            "source_code": ["A", "A", "A", "A"],
            "source_local_id": ["51", "44", "7", "8"],
            "first_name": ["GivenA0044", "GivenA0044", "Ada", "Ada"],
            "last_name": ["PATIENTA0044", "PatientA0044", "Byron", "Byron"],
            "date_of_birth": ["1990-01-01", "1990-01-01", "1815-12-10", "1815-12-10"],
            "health_insurance_number": ["P2-A-00044", "p2-a-00044", None, None],
        })
        kept, remap = merge_duplicate_patients(patients)
        self.assertEqual(sorted(kept["source_local_id"]), ["44", "7", "8"])
        self.assertEqual(remap[["old_patient_id", "kept_patient_id"]].values.tolist(), [["51", "44"]])


class Text(unittest.TestCase):
    def test_short_text_collapses_spaces_free_text_only_trims(self):
        self.assertEqual(clean_text("  Critical   Care 1 ", "varchar", 100), ("Critical Care 1", None))
        self.assertEqual(clean_text("  line one   two ", "text", None), ("line one   two", None))
        self.assertEqual(clean_text("x" * 21, "varchar", 20), (None, "text_too_long"))

    def test_ids_must_be_whole_numbers(self):
        self.assertEqual(clean_id(" 007 "), ("7", None))
        self.assertEqual(clean_id("12a"), (None, "invalid_id"))
        self.assertEqual(clean_id("3000000000"), (None, "invalid_id"))


class DatesAndTimestamps(unittest.TestCase):
    def test_each_source_converts_to_utc(self):
        # Berlin is UTC+2 in June (CEST).
        self.assertEqual(parse_timestamp("15.06.2026 08:10", "B")[0], "2026-06-15 06:10:00")
        # Toronto is UTC-5 in January (EST).
        self.assertEqual(parse_timestamp("2026-01-06 08:00", "A")[0], "2026-01-06 13:00:00")
        # C carries its own +09:00 offset.
        self.assertEqual(parse_timestamp("2026-01-06T08:00:00+09:00", "C")[0], "2026-01-05 23:00:00")
        # `date -u -d @1781474400` -> Sun Jun 14 22:00:00 UTC 2026.
        self.assertEqual(parse_timestamp("1781474400", "D")[0], "2026-06-14 22:00:00")
        # Sydney is UTC+10 in July (AEST); 5:00 PM -> 07:00 UTC.
        self.assertEqual(parse_timestamp("08/07/2026 5:00 PM", "D")[0], "2026-07-08 07:00:00")

    def test_daylight_saving_gaps_and_repeats_are_rejected(self):
        # Each local time below does not exist or happens twice (pandas raises on all of them).
        for value, source in [
            ("2026-03-08 02:30", "A"), ("2026-11-01 01:30", "A"),
            ("29.03.2026 02:30", "B"), ("25.10.2026 02:30", "B"),
            ("04/10/2026 2:30 AM", "D"), ("05/04/2026 2:30 AM", "D"),
        ]:
            self.assertEqual(parse_timestamp(value, source)[1], "ambiguous_or_missing_local_time", value)
        self.assertEqual(parse_timestamp("05/04/2026 4:30 AM", "D")[1], None)

    def test_impossible_dates_are_invalid(self):
        self.assertEqual(parse_timestamp("2026-02-30T09:00:00", "A")[1], "invalid_timestamp")
        self.assertEqual(parse_date("31.02.1815", "B")[1], "invalid_date")

    def test_day_first_ambiguity_is_kept_and_noted(self):
        self.assertEqual(parse_date("08/03/1946", "D"), ("1946-03-08", None, "ambiguous_day_first_assumed"))
        self.assertEqual(parse_date("25/03/1946", "D")[2], None)   # 25 cannot be a month
        self.assertEqual(parse_date("05/05/1946", "D")[2], None)   # same either way


class NumbersAndUnits(unittest.TestCase):
    def test_units_and_decimal_commas(self):
        # (97.5 - 32) * 5 / 9 = 36.388... -> 36.4 ; (98.6 - 32) * 5 / 9 = 37.0
        self.assertEqual(clean_measurement("97.5", "A", "body_temperature")[0], "36.4")
        self.assertEqual(clean_measurement("98.6", "A", "body_temperature")[0], "37.0")
        self.assertEqual(clean_measurement("36,4", "B", "body_temperature")[0], "36.4")

    def test_invalid_values_are_flagged(self):
        self.assertEqual(clean_measurement("15", "C", "pain_level")[1], "out_of_range")
        self.assertEqual(clean_measurement("abc", "C", "heart_rate")[1], "invalid_number")
        self.assertEqual(clean_measurement("72.5", "C", "heart_rate")[1], "invalid_number")
        # A Fahrenheit value in a Celsius source is out of range, not silently converted.
        self.assertEqual(clean_measurement("98.6", "C", "body_temperature")[1], "out_of_range")
        self.assertEqual(clean_blood_pressure("120/80"), ("120/80", None))
        self.assertEqual(clean_blood_pressure("120-80"), (None, "invalid_blood_pressure"))


class CategoriesAndCodes(unittest.TestCase):
    def test_source_labels_map_to_phase1_values(self):
        self.assertEqual(clean_category("Notfall", "B", "admission_type"), ("Emergency", None))
        self.assertEqual(clean_category(" URGENT ", "D", "admission_type"), ("Urgent", None))
        self.assertEqual(clean_category("Red", "C", "priority_level"), ("High-Priority Emergency", None))
        self.assertEqual(clean_category("4", "A", "priority_level"), ("Non-Urgent", None))
        self.assertEqual(clean_category("Purple", "C", "priority_level"), (None, "unknown_category"))

    def test_icd9_repaired_only_on_one_dictionary_match(self):
        dictionary = {"427.31", "038.9", "311"}
        self.assertEqual(fix_icd9("42731", dictionary), ("427.31", None))
        self.assertEqual(fix_icd9("38.9", dictionary), ("038.9", None))
        self.assertEqual(fix_icd9("311", dictionary), ("311", None))
        self.assertEqual(fix_icd9("999.99", dictionary), (None, "icd9_not_in_dictionary"))
        self.assertEqual(fix_icd9("0123", {"012.3", "123"}), (None, "icd9_ambiguous"))


class WholeSample(unittest.TestCase):
    """Runs the full pipeline once on Krish's sample and checks it against his answer key."""

    @classmethod
    def setUpClass(cls):
        cls.folder = TemporaryDirectory()
        root = Path(cls.folder.name)
        cls.dirs = (root / "clean", root / "quarantine", root / "reports")
        cls.counts = run(SAMPLE_DIR, *cls.dirs)
        cls.log = pd.read_csv(cls.dirs[2] / "cleaning_log.csv", dtype=str, keep_default_na=False)

    @classmethod
    def tearDownClass(cls):
        cls.folder.cleanup()

    def test_every_record_is_accounted_for(self):
        self.assertTrue(self.counts["reconciles"].all())
        self.assertEqual(int(self.counts["rows_loaded"].sum()), 2679)

    def test_every_planted_cleaning_problem_is_detected(self):
        truth = pd.read_csv(ANSWER_KEY, dtype=str, keep_default_na=False)
        truth = truth[~truth["issue"].str.startswith("cross_source")]   # Dany's step
        log = self.log
        remap = pd.read_csv(self.dirs[2] / "patient_id_remap.csv", dtype=str)
        missed = []
        for row in truth.itertuples():
            if row.issue == "within_source_duplicate_patients":
                found = ((remap["source_code"] == row.source) & (remap["old_patient_id"] == row.local_id)).any()
            elif row.issue == "malformed_rows":
                found = ((log["source_code"] == row.source) & (log["problem_type"] == "malformed_record")).any()
            elif row.issue == "missing_primary":
                admission = str(json.loads(row.original_value)["admission_id"])
                found = ((log["source_code"] == row.source) & (log["source_local_id"] == admission)
                         & (log["problem_type"] == "missing_primary_diagnosis")).any()
            else:
                hits = log[(log["source_code"] == row.source) & (log["entity"] == row.entity)
                           & (log["source_local_id"] == row.local_id)]
                if row.field not in ("(record)", "(line)"):
                    hits = hits[hits["column"] == row.field]
                found = not hits.empty
            if not found:
                missed.append((row.source, row.entity, row.local_id, row.issue))
        self.assertEqual(len(truth), 86)
        self.assertEqual(missed, [])

    def test_nothing_is_invented(self):
        quarantine = pd.read_csv(self.dirs[1] / "clinical_notes.csv", dtype=str, keep_default_na=False)
        reasons = " ".join(quarantine["reason"])
        self.assertIn("missing required note_contents", reasons)
        clean = pd.read_csv(self.dirs[0] / "clinical_notes.csv", dtype=str, keep_default_na=False)
        self.assertFalse((clean["note_contents"] == "").any())

    def test_rerun_gives_identical_files(self):
        with TemporaryDirectory() as second:
            other = [Path(second) / name for name in ("clean", "quarantine", "reports")]
            run(SAMPLE_DIR, *other)
            for first_dir, second_dir in zip(self.dirs, other):
                for path in sorted(first_dir.glob("*.csv")):
                    if path.name == "malformed_records.csv":
                        continue
                    self.assertEqual(path.read_bytes(), (second_dir / path.name).read_bytes(), path.name)


if __name__ == "__main__":
    unittest.main()
