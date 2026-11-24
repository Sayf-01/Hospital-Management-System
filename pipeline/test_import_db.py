import io
import unittest
from contextlib import contextmanager
from pathlib import Path
from unittest.mock import MagicMock, patch

from psycopg.errors import UniqueViolation

from pipeline import import_db


class ImportTests(unittest.TestCase):
    def setUp(self):
        self.conn = MagicMock()
        self.conn.info.dbname = import_db.DATABASE
        self.cursor = self.conn.cursor.return_value.__enter__.return_value

    def test_csv_preserves_codes_and_maps_empty_fields_to_none(self):
        cursor = self.cursor
        cursor.fetchall.return_value = [("icd9_code", None), ("description", None)]
        with patch.object(Path, "open", return_value=io.StringIO(
            "icd9_code,description\n038.9,\n250.00,NA\n",
        )):
            self.assertEqual(import_db.load_table(self.conn, "icd9_dictionary", "codes.csv"), 2)

        statement, rows = cursor.executemany.call_args.args
        self.assertEqual(statement.as_string(),
                         'INSERT INTO "public"."icd9_dictionary" ("icd9_code", "description") '
                         'VALUES (%s, %s)')
        self.assertEqual(rows, [("038.9", None), ("250.00", "NA")])

    def test_bad_row_is_reported_after_batch_rollback(self):
        self.cursor.fetchall.return_value = [("source_code", None)]
        self.cursor.executemany.side_effect = UniqueViolation()
        self.cursor.execute.side_effect = [None, None, UniqueViolation()]
        with patch.object(Path, "open", return_value=io.StringIO("source_code\nA\nA\n")):
            with self.assertRaisesRegex(RuntimeError, r"source_systems: CSV row 3.*23505"):
                import_db.load_table(self.conn, "source_systems", "sources.csv")
        batch, diagnostic = self.conn.transaction.call_args_list
        self.assertEqual(batch.kwargs, {})
        self.assertEqual(diagnostic.kwargs, {"force_rollback": True})

    def test_import_propagates_insert_failure_to_outer_transaction(self):
        events = []

        @contextmanager
        def transaction():
            events.append("begin")
            try:
                yield
            except RuntimeError:
                events.append("rollback")
                raise
            else:
                events.append("commit")

        self.conn.transaction.side_effect = transaction
        with (patch.object(Path, "is_file", return_value=True),
              patch.object(import_db, "rebuild_schema",
                           side_effect=lambda *args, **kwargs: events.append("rebuild")),
              patch.object(import_db, "load_table", side_effect=[4, RuntimeError("bad row")]),
              patch.object(import_db, "reset_identity_sequences") as reset):
            with self.assertRaisesRegex(RuntimeError, "bad row"):
                import_db.import_database(self.conn, Path("integrated"), allow_destructive=True)
            reset.assert_not_called()
        self.assertEqual(events, ["begin", "rebuild", "rollback"])

    def test_sequence_restart_uses_actual_column_and_start_for_empty_table(self):
        self.cursor.fetchall.return_value = [
            ("patients", "patient_id", "1", "1"),
            ("admissions", "admission_id", "5", "1"),
        ]
        self.cursor.fetchone.side_effect = [(41,), (None,)]
        import_db.reset_identity_sequences(self.conn)
        restarts = [self.cursor.execute.call_args_list[i].args[0].as_string() for i in (2, 4)]
        self.assertEqual(restarts, [
            'ALTER TABLE "public"."patients" ALTER COLUMN "patient_id" RESTART WITH 42',
            'ALTER TABLE "public"."admissions" ALTER COLUMN "admission_id" RESTART WITH 5',
        ])

    def test_rebuild_requires_approval_and_phase2_database(self):
        with self.assertRaisesRegex(ValueError, "Explicit rebuild approval"):
            import_db.rebuild_schema(self.conn)
        self.conn.info.dbname = "hospital_phase1"
        with self.assertRaisesRegex(ValueError, "requires the hospital_phase2 database"):
            import_db.rebuild_schema(self.conn, allow_destructive=True)
        self.conn.cursor.assert_not_called()


if __name__ == "__main__":
    unittest.main()
