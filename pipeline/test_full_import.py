"""YO-4 tests that leave PostgreSQL untouched."""

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import MagicMock, patch

from run_all import Pipeline, verify_import


class FullImportTests(unittest.TestCase):
    def setUp(self):
        directory = TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.workspace = Path(directory.name)
        self.conn = MagicMock()
        self.cursor = self.conn.cursor.return_value.__enter__.return_value

    def test_verification_records_exact_counts_and_next_identity(self):
        self.cursor.fetchall.return_value = [
            ("quarantine_records", "quarantine_id", "1", "1", ["public", "quarantine_seq"]),
        ]
        self.cursor.fetchone.side_effect = [(2,), (0,), (2,), (3, False)]
        verify_import(self.conn, {"quarantine_records": 2}, self.workspace)
        self.assertIn("quarantine_records,2,2", (self.workspace / "counts_database.csv").read_text())
        self.assertIn("quarantine_records,quarantine_id,3,3",
                      (self.workspace / "identity_database.csv").read_text())
        self.assertEqual(self.cursor.execute.call_args.args[0].as_string(),
                         'SELECT last_value, is_called FROM "public"."quarantine_seq"')

    def test_verification_reports_table_and_sequence_discrepancies(self):
        self.cursor.fetchall.return_value = [
            ("quarantine_records", "quarantine_id", "1", "1", ["public", "quarantine_seq"]),
        ]
        self.cursor.fetchone.side_effect = [(1,), (1,), (5,), (1, False)]
        with self.assertRaisesRegex(ValueError, r"quarantine_records: expected 2, got 1.+"
                                    r"expected next ID 6, got 1.+duplicate audit rows"):
            verify_import(self.conn, {"quarantine_records": 2}, self.workspace)

    def test_server_database_name_is_checked_before_rebuild(self):
        pipeline = Pipeline(self.workspace, self.workspace / "run")
        pipeline.integrated.mkdir(parents=True)
        (pipeline.integrated / "quarantine_records.csv").touch()
        (pipeline.reports / "counts_integrated.csv").write_text(
            "table,rows_out\nquarantine_records,0\n", encoding="utf-8")
        importer = MagicMock()
        importer.LOAD_ORDER = ("quarantine_records",)
        importer.connect.return_value.__enter__.return_value = self.conn
        self.cursor.fetchone.return_value = ("hospital_phase1",)
        with patch("run_all.import_module", return_value=importer):
            with self.assertRaisesRegex(ValueError, "requires the hospital_phase2 database"):
                pipeline.import_db(authorized=True)
        importer.import_database.assert_not_called()
