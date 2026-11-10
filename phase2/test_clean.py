import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import pandas as pd

from phase2.clean import (
    SAMPLE_INPUT,
    clean_csv,
    clean_numbers,
    drop_exact_duplicates,
    fix_icd9,
    map_categories,
    merge_duplicate_patients,
    normalize_missing,
    normalize_text,
    parse_timestamps,
    quarantine,
    rename_fields,
    run,
)


class CleaningHelpersTests(unittest.TestCase):
    def test_normalize_missing_and_text(self):
        frame = pd.DataFrame(
            {"first_name": ["  given   name ", "?"], "code": [" ab  12 ", "N/A"]}
        )
        normalized = normalize_missing(frame)
        normalized = normalize_text(normalized, ["first_name", "code"])
        self.assertEqual(normalized.at[0, "first_name"], "Given Name")
        self.assertIsNone(normalized.at[1, "first_name"])
        self.assertEqual(normalized.at[0, "code"], "AB 12")
        self.assertIsNone(normalized.at[1, "code"])

    def test_rename_fields_keeps_parent_ids_source_scoped(self):
        frame = pd.DataFrame({"patient_no": ["9"], "admission_no": ["12"]})
        renamed = rename_fields(frame, "B", "admissions")
        self.assertEqual(renamed.columns.tolist(), ["source_patient_id", "admission_id"])

    def test_category_mapping_flags_unknown_labels(self):
        frame = pd.DataFrame({"admission_type": ["Notfall", "unlisted"]})
        mapped, flags = map_categories(frame, "B", "admissions")
        self.assertEqual(mapped.at[0, "admission_type"], "Emergency")
        self.assertIsNone(mapped.at[1, "admission_type"])
        self.assertTrue(flags.at[1, "admission_type"])

    def test_timestamps_are_localized_then_converted_to_utc(self):
        frame = pd.DataFrame({"assessment_datetime": ["15.06.2026 08:10"]})
        parsed, invalid = parse_timestamps(frame, "B", ["assessment_datetime"])
        self.assertEqual(
            parsed.at[0, "assessment_datetime"],
            pd.Timestamp("2026-06-15 06:10:00", tz="UTC"),
        )
        self.assertFalse(invalid.at[0, "assessment_datetime"])

    def test_source_numeric_formats_and_ranges(self):
        frame = pd.DataFrame(
            {"body_temperature": ["36,4"], "pain_level": ["15"]}
        )
        cleaned, invalid = clean_numbers(frame, "B", "triage_assessments")
        self.assertEqual(cleaned.at[0, "body_temperature"], 36.4)
        self.assertTrue(pd.isna(cleaned.at[0, "pain_level"]))
        self.assertTrue(invalid.at[0, "pain_level"])

        fahrenheit, _ = clean_numbers(
            pd.DataFrame({"body_temperature": ["98.6"]}), "A", "triage_assessments"
        )
        self.assertEqual(fahrenheit.at[0, "body_temperature"], 37.0)

    def test_icd9_repairs(self):
        self.assertEqual(fix_icd9("38.9"), "038.9")
        self.assertEqual(fix_icd9("42731"), "427.31")
        self.assertEqual(fix_icd9("E12345"), "E123.45")

    def test_duplicate_helpers(self):
        records = pd.DataFrame(
            {"source_local_id": ["1", "1"], "line": [2, 3], "value": ["x", "x"]}
        )
        unique, removed = drop_exact_duplicates(records)
        self.assertEqual((len(unique), removed), (1, 1))

        patients = pd.DataFrame(
            {
                "source_local_id": ["9", "2"],
                "first_name": ["Ada", " ada "],
                "last_name": ["Lovelace", "LOVELACE"],
                "date_of_birth": ["1815-12-10", "1815-12-10"],
                "health_insurance_number": ["AB-1", "ab-1"],
            }
        )
        merged, removed = merge_duplicate_patients(patients)
        self.assertEqual((len(merged), removed), (1, 1))
        self.assertEqual(merged.iloc[0]["source_local_id"], "2")

    def test_quarantine_keeps_source_identity_and_raw_values(self):
        frame = pd.DataFrame(
            {
                "source_code": ["B", "B"],
                "entity": ["patients", "patients"],
                "source_local_id": ["1", "2"],
                "_raw_values": ['{"id":"1"}', '{"id":"2"}'],
            }
        )
        clean, rejected = quarantine(
            frame, pd.Series([False, True]), "invalid required value"
        )
        self.assertEqual(len(clean), 1)
        self.assertEqual(rejected.iloc[0]["source_local_id"], "2")
        self.assertEqual(rejected.iloc[0]["raw_values"], '{"id":"2"}')

    def test_sample_csv_cleaning_counts_and_examples(self):
        clean, rejected, examples, counts = clean_csv(
            Path(SAMPLE_INPUT), "B", "patients"
        )
        self.assertEqual(counts, {
            "rows_in": 51,
            "rows_out": 50,
            "quarantined": 0,
            "duplicates_removed": 1,
        })
        self.assertEqual(len(rejected), 0)
        self.assertIsInstance(clean.iloc[0]["source_local_id"], str)
        self.assertTrue((clean["source_code"] == "B").all())
        self.assertTrue({"line", "problem_type"}.issubset(examples.columns))
        self.assertIn("duplicate_patient", set(examples["problem_type"]))
        duplicate_example = examples.loc[
            examples["problem_type"] == "duplicate_patient"
        ].iloc[0]
        self.assertIn("kept source-local ID 38", duplicate_example["cleaned_value"])

    def test_invalid_required_value_is_quarantined_with_raw_values(self):
        with TemporaryDirectory() as temporary_directory:
            input_path = Path(temporary_directory) / "patients.csv"
            input_path.write_text(
                "patient_no;given_name;family_name;birth_date;sex;life_status\n"
                "99;Ada;Lovelace;31.02.1815;Female;Alive\n",
                encoding="utf-8",
            )
            clean, rejected, examples, counts = clean_csv(
                input_path, "B", "patients"
            )
        self.assertEqual(len(clean), 0)
        self.assertEqual(counts["quarantined"], 1)
        self.assertEqual(rejected.iloc[0]["source_local_id"], "99")
        self.assertIn("birth_date", rejected.iloc[0]["raw_values"])
        self.assertIn("invalid_date", set(examples["problem_type"]))

    def test_run_is_idempotent_for_a_source_and_entity(self):
        with TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            output_dir = root / "clean"
            quarantine_dir = root / "quarantine"
            report_dir = root / "reports"

            run(
                SAMPLE_INPUT,
                "B",
                "patients",
                output_dir,
                quarantine_dir,
                report_dir,
            )
            run(
                SAMPLE_INPUT,
                "B",
                "patients",
                output_dir,
                quarantine_dir,
                report_dir,
            )

            self.assertEqual(len(pd.read_csv(output_dir / "patients.csv")), 50)
            self.assertEqual(len(pd.read_csv(quarantine_dir / "patients.csv")), 0)
            self.assertEqual(len(pd.read_csv(report_dir / "counts_clean.csv")), 1)
            examples = pd.read_csv(report_dir / "cleaning_examples.csv")
            self.assertEqual(
                len(examples.loc[examples["problem_type"] == "duplicate_patient"]),
                1,
            )


if __name__ == "__main__":
    unittest.main()
