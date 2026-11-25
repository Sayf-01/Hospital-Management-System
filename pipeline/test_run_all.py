"""Orchestration tests using temporary files and mocked stage adapters."""

from contextlib import redirect_stdout
import io
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import MagicMock, call, patch

from run_all import DEPENDENCIES, Pipeline, run_pipeline


class PipelineTests(unittest.TestCase):
    def setUp(self):
        temporary = TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        for files in DEPENDENCIES.values():
            for name in files:
                path = self.root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.touch()
        self.pipeline = MagicMock()
        self.pipeline.root = self.root

    def run_plan(self, *, skip_import=False, authorized=True):
        output = io.StringIO()
        with redirect_stdout(output):
            code = run_pipeline(self.pipeline, skip_import=skip_import, authorized=authorized)
        return code, output.getvalue()

    def test_order_and_deterministic_rerun(self):
        methods = [
            call.load(), call.profile(), call.clean(), call.check(), call.integrate(),
            call.import_db(authorized=True), call.validate(),
        ]
        first = self.run_plan()
        self.assertEqual(first[0], 0)
        self.assertEqual(self.pipeline.method_calls, methods)
        self.pipeline.reset_mock()
        self.assertEqual(self.run_plan(), first)
        self.assertEqual(self.pipeline.method_calls, methods)

    def test_skip_import_skips_both_postgresql_stages(self):
        (self.root / "pipeline/import_db.py").unlink()
        code, output = self.run_plan(skip_import=True, authorized=False)
        self.assertEqual(code, 0)
        self.assertIn("Data-processing stages completed", output)
        self.assertEqual(self.pipeline.method_calls, [
            call.load(), call.profile(), call.clean(), call.check(), call.integrate(),
        ])

    def test_failure_stops_at_the_failing_stage(self):
        self.pipeline.clean.side_effect = RuntimeError("clean counts mismatch")
        code, output = self.run_plan()
        self.assertEqual(code, 1)
        self.assertIn("failed (clean counts mismatch)", output)
        self.assertEqual(self.pipeline.method_calls, [call.load(), call.profile(), call.clean()])

    def test_missing_required_module_is_reported_in_preflight(self):
        (self.root / "pipeline/check_relations.py").unlink()
        code, output = self.run_plan(skip_import=True, authorized=False)
        self.assertEqual(code, 1)
        self.assertIn("unavailable (pipeline/check_relations.py)", output)
        self.assertEqual(self.pipeline.method_calls, [])

    def test_full_run_requires_explicit_authorization(self):
        code, output = self.run_plan(authorized=False)
        self.assertEqual(code, 1)
        self.assertIn("blocked (requires --allow-destructive-rebuild)", output)
        self.assertEqual(self.pipeline.method_calls, [])
        pipeline = Pipeline(self.root, self.root / "work")
        with patch("run_all.import_module") as load_module:
            with self.assertRaises(PermissionError):
                pipeline.import_db(authorized=False)
            load_module.assert_not_called()

    def test_pending_validation_is_not_a_full_success(self):
        (self.root / "sql/validation.sql").unlink()
        code, output = self.run_plan()
        self.assertEqual(code, 1)
        self.assertIn("pending (sql/validation.sql)", output)
        self.pipeline.import_db.assert_called_once_with(authorized=True)
        self.pipeline.validate.assert_not_called()

    def test_import_checks_integrated_inputs_before_connecting(self):
        pipeline = Pipeline(self.root, self.root / "work")
        importer = MagicMock()
        importer.LOAD_ORDER = ("quarantine_records",)
        with patch("run_all.import_module", return_value=importer):
            with self.assertRaisesRegex(FileNotFoundError, "quarantine_records.csv"):
                pipeline.import_db(authorized=True)
        importer.connect.assert_not_called()

    def test_validation_displays_all_result_sets_in_read_only_transaction(self):
        path = self.root / "sql/validation.sql"
        script = "SELECT 'ok' AS status; SELECT 2 AS count;"
        path.write_text(script, encoding="utf-8")
        pipeline = Pipeline(self.root, self.root / "work")
        importer = MagicMock()
        conn = importer.connect.return_value.__enter__.return_value
        cursor = conn.cursor.return_value.__enter__.return_value
        cursor.fetchone.return_value = ("hospital_phase2",)
        cursor.fetchall.side_effect = [[("ok",)], [(2,)]]
        column = MagicMock()
        column.name = "value"
        cursor.description = [column]
        cursor.nextset.side_effect = [True, None]
        output = io.StringIO()
        with patch("run_all.import_module", return_value=importer), redirect_stdout(output):
            self.assertEqual(pipeline.validate(), "2 result sets, 2 result rows")
        conn.transaction.assert_called_once_with()
        self.assertEqual(cursor.execute.call_args_list, [
            call("SET TRANSACTION READ ONLY"), call("SELECT current_database()"),
            call(script, prepare=False),
        ])
        self.assertIn("Result 2 (1 rows)", output.getvalue())
