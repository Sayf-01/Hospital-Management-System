"""Orchestration tests using temporary files and mocked stage adapters."""

from contextlib import redirect_stdout
import io
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import MagicMock, call, patch

from run_all import DEPENDENCIES, ROOT, Pipeline, ValidationResult, run_pipeline


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
        self.pipeline.validate.return_value = ValidationResult(0, 0)

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

    def test_validation_distinguishes_documented_and_other_violations(self):
        self.pipeline.validate.return_value = ValidationResult(43, 43)
        code, output = self.run_plan()
        self.assertEqual(code, 0)
        self.assertIn("43 documented Rule 9 violation(s)", output)
        self.assertNotIn("all 11 validation rules passed", output)
        self.pipeline.validate.return_value = ValidationResult(44, 43)
        code, output = self.run_plan()
        self.assertEqual(code, 2)
        self.assertIn("violations found (1 outside Rule 9)", output)

    def test_validation_sql_error_remains_an_execution_failure(self):
        from psycopg.errors import SyntaxError

        self.pipeline.validate.side_effect = SyntaxError()
        code, output = self.run_plan()
        self.assertEqual(code, 1)
        self.assertIn("failed (SyntaxError, SQLSTATE 42601)", output)

    def test_validation_and_query_six_share_the_same_rule_definitions(self):
        detail = (ROOT / "sql" / "validation.sql").read_text(encoding="utf-8")
        summary = (ROOT / "sql" / "task6_queries.sql").read_text(encoding="utf-8")
        rules = detail.split("WITH records AS MATERIALIZED (")[1].split("\nSELECT rule_id,")[0]
        self.assertIn("WITH records AS MATERIALIZED (" + rules + "\nSELECT check_name,", summary)

    def test_validation_displays_details_and_counts_in_read_only_transaction(self):
        path = self.root / "sql/validation.sql"
        script = "SELECT 9 AS rule_id;"
        path.write_text(script, encoding="utf-8")
        pipeline = Pipeline(self.root, self.root / "work")
        importer = MagicMock()
        conn = importer.connect.return_value.__enter__.return_value
        cursor = conn.cursor.return_value.__enter__.return_value
        cursor.fetchone.return_value = ("hospital_phase2",)
        cursor.fetchall.return_value = [(9, "admissions", [17], "No Primary diagnosis")]
        columns = ("rule_id", "entity", "record_key", "detail")
        cursor.description = [MagicMock() for _ in columns]
        for description, name in zip(cursor.description, columns):
            description.name = name
        cursor.nextset.return_value = None
        output = io.StringIO()
        with patch("run_all.import_module", return_value=importer), redirect_stdout(output):
            self.assertEqual(pipeline.validate(), ValidationResult(1, 1))
        conn.transaction.assert_called_once_with()
        self.assertEqual(cursor.execute.call_args_list, [
            call("SET TRANSACTION READ ONLY"), call("SELECT current_database()"),
            call(script, prepare=False),
        ])
        self.assertIn("Rule 01: 0 violation(s)", output.getvalue())
        self.assertIn("Rule 09: 1 violation(s) (documented data-quality limitation)", output.getvalue())
        self.assertIn("Rule 09 | admissions | [17] | No Primary diagnosis", output.getvalue())
