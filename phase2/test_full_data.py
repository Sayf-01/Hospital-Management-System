"""SA-4 tests: the cleaner on Krish's frozen full data (KR-3). Run from the repository root:
    python -m pytest phase2/test_full_data.py      (about 15 seconds)

Expected numbers come from Krish's own files (counts_raw.csv, kr3_freeze_audit.json and
the answer key injected_errors.csv), never from clean.py itself.
"""

import json
import subprocess
import sys
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import pandas as pd

from phase2.clean import ROOT, run
from phase2.evaluate_cleaning import evaluate

FULL_DIR = ROOT / "data" / "raw" / "full"
REPORTS = ROOT / "reports"


def read(path: Path) -> pd.DataFrame:
    return pd.read_csv(path, dtype=str, keep_default_na=False)


@unittest.skipUnless(FULL_DIR.exists(), "full data (KR-3) not checked out")
class FullData(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.folder = TemporaryDirectory()
        root = Path(cls.folder.name)
        cls.clean_dir, cls.quarantine_dir, cls.report_dir = root / "clean", root / "quarantine", root / "reports"
        cls.counts = run(FULL_DIR, cls.clean_dir, cls.quarantine_dir, cls.report_dir)
        cls.table, cls.unplanted = evaluate("full", cls.report_dir, cls.quarantine_dir)
        cls.log = read(cls.report_dir / "cleaning_log.csv")

    @classmethod
    def tearDownClass(cls):
        cls.folder.cleanup()

    def test_raw_files_are_the_frozen_ones(self):
        result = subprocess.run([sys.executable, str(ROOT / "phase2" / "generator" / "freeze_sources.py"), "--verify"],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("PASS: 70 raw files", result.stdout)

    def test_every_raw_record_is_accounted_for(self):
        audit = json.loads((REPORTS / "kr3_freeze_audit.json").read_text())
        raw_counts = read(REPORTS / "counts_raw.csv")
        count_column = [column for column in raw_counts.columns if column not in ("source", "entity")][0]
        self.assertEqual(int(raw_counts[count_column].astype(int).sum()), audit["total_raw_records"])
        counts = self.counts
        loaded_plus_malformed = int(counts["rows_loaded"].sum() + counts["malformed_at_load"].sum())
        self.assertEqual(loaded_plus_malformed, audit["total_raw_records"])
        self.assertTrue(counts["reconciles"].all())

    def test_every_planted_cleaning_problem_is_detected(self):
        cleaning = self.table[self.table["detected"].notna()]
        missed = cleaning[cleaning["missed"] > 0]
        self.assertTrue(missed.empty, missed.to_string())
        answer_key = read(REPORTS / "ground_truth" / "injected_errors.csv")
        self.assertEqual(int(self.table["planted"].sum()), len(answer_key))

    def test_no_false_rejections(self):
        self.assertTrue(self.unplanted.empty, self.unplanted.to_string())

    def test_most_records_remain_usable(self):
        counts = self.counts
        raw = counts["rows_loaded"].sum() + counts["malformed_at_load"].sum()
        rejected = counts[["quarantined_cleaning", "quarantined_relationships",
                           "quarantined_chronology", "malformed_at_load"]].sum().sum()
        self.assertLess(rejected / raw, 0.05)

    def test_extra_ambiguous_dates_are_really_ambiguous(self):
        # D writes DD/MM/YYYY; flagged only when both parts are <= 12 and differ.
        flagged = self.log[self.log["problem_type"] == "ambiguous_day_first_assumed"]
        self.assertTrue((flagged["source_code"] == "D").all())
        for raw_value in flagged["raw_value"]:
            day, month = (int(part) for part in raw_value.split("/")[:2])
            self.assertTrue(day <= 12 and month <= 12 and day != month, raw_value)

    def test_extra_missing_primary_flags_lost_their_primary_in_cleaning(self):
        answer_key = read(REPORTS / "ground_truth" / "injected_errors.csv")
        planted = {(row.source, str(json.loads(row.original_value)["admission_id"]))
                   for row in answer_key[answer_key["issue"] == "missing_primary"].itertuples()}
        flagged = self.log[self.log["problem_type"] == "missing_primary_diagnosis"]
        rejected_diagnoses = read(self.quarantine_dir / "diagnoses.csv")
        rejected_admissions = set()
        for row in rejected_diagnoses.itertuples():
            raw = {key.casefold(): str(value) for key, value in json.loads(row.raw_record).items()}
            admission = next(value for key, value in raw.items() if "adm" in key)
            kind = next(value for key, value in raw.items() if "type" in key)
            if "prim" in kind.casefold():
                rejected_admissions.add((row.source_code, str(int(admission))))
        for source, admission in zip(flagged["source_code"], flagged["source_local_id"]):
            self.assertTrue((source, admission) in planted or (source, admission) in rejected_admissions,
                            f"{source} admission {admission} flagged without a reason")

    def test_committed_outputs_match_a_fresh_run(self):
        pairs = [(self.clean_dir, ROOT / "data" / "clean"), (self.quarantine_dir, ROOT / "data" / "quarantine")]
        for name in ("counts_clean.csv", "cleaning_log.csv", "cleaning_examples.csv", "cleaning_summary.csv",
                     "patient_id_remap.csv", "planted_vs_detected.csv", "unplanted_rejections.csv"):
            pairs.append((self.report_dir / name, REPORTS / name))
        for fresh, committed in pairs:
            files = sorted(fresh.glob("*.csv")) if fresh.is_dir() else [fresh]
            for path in files:
                other = committed / path.name if fresh.is_dir() else committed
                self.assertEqual(path.read_bytes(), other.read_bytes(), f"{other} is out of date")


if __name__ == "__main__":
    unittest.main()
