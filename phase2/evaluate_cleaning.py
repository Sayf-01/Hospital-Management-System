"""SA-4: compare what clean.py detected with what Krish's generator planted.

The cleaner never reads the answer key; this separate script does, after the
cleaner has run, so the comparison is a fair test. Run from the repository root:

    python phase2/clean.py                  # full data
    python phase2/evaluate_cleaning.py      # compares with injected_errors.csv
    python phase2/evaluate_cleaning.py --scale sample

Writes:
    reports/planted_vs_detected.csv   one row per planted problem type and source
    reports/unplanted_rejections.csv  rejected records that no planted problem explains
                                      (should be empty: no false rejections)
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
ANSWER_KEYS = {
    "full": ROOT / "reports" / "ground_truth" / "injected_errors.csv",
    "sample": ROOT / "reports" / "ground_truth" / "injected_errors_sample.csv",
}
# Matching patients across hospitals is integration (DA-3), not cleaning.
INTEGRATION_ISSUES = ("cross_source_true_match", "cross_source_uncertain", "cross_source_name_only")


def read_csv(path: Path) -> pd.DataFrame:
    return pd.read_csv(path, dtype=str, keep_default_na=False)


def find_detection(row, log: pd.DataFrame, remap: pd.DataFrame) -> pd.DataFrame:
    """The cleaning-log lines that show one planted problem was caught."""
    same_source = log["source_code"] == row.source
    if row.issue == "within_source_duplicate_patients":
        # Caught only if the remap table also lists it (old ID -> kept ID).
        in_remap = ((remap["source_code"] == row.source) & (remap["old_patient_id"] == row.local_id)).any()
        return log[same_source & (log["problem_type"] == "duplicate_patient")
                   & (log["source_local_id"] == row.local_id) & in_remap]
    if row.issue == "malformed_rows":
        return log[same_source & (log["entity"] == row.entity) & (log["problem_type"] == "malformed_record")]
    if row.issue == "missing_primary":
        # The generator removed this admission's Primary diagnosis; the cleaner must flag the admission.
        admission = str(json.loads(row.original_value)["admission_id"])
        return log[same_source & (log["problem_type"] == "missing_primary_diagnosis")
                   & (log["source_local_id"] == admission)]
    hits = log[same_source & (log["entity"] == row.entity) & (log["source_local_id"] == row.local_id)]
    if row.issue.startswith("exact_duplicate"):
        return hits[hits["problem_type"] == "exact_duplicate"]
    if row.field not in ("(record)", "(line)"):
        hits = hits[hits["column"] == row.field]
    return hits


def join_unique(values: pd.Series) -> str:
    """'a; b' + 'b' -> 'a; b' (each name once, sorted). ';' because some actions contain commas."""
    names = {name for value in values for name in value.split("; ") if name}
    return "; ".join(sorted(names))


def evaluate(scale: str = "full", report_dir: Path = ROOT / "reports",
             quarantine_dir: Path = ROOT / "data" / "quarantine") -> tuple[pd.DataFrame, pd.DataFrame]:
    truth = read_csv(ANSWER_KEYS[scale])
    log = read_csv(report_dir / "cleaning_log.csv")
    remap = read_csv(report_dir / "patient_id_remap.csv")
    cleaning = truth[~truth["issue"].isin(INTEGRATION_ISSUES)].copy()

    # One answer-key row at a time: was it caught, and how?
    matches = cleaning.apply(lambda row: find_detection(row, log, remap), axis=1)
    cleaning["detected"] = matches.map(lambda hits: not hits.empty)
    cleaning["detected_as"] = matches.map(lambda hits: "; ".join(sorted(set(hits["problem_type"]))))
    cleaning["action"] = matches.map(lambda hits: "; ".join(sorted(set(hits["action"]))))

    # Count per problem type and hospital with groupby().sum(), as in the slides.
    cleaning["planted"] = 1
    cleaning["detected"] = cleaning["detected"].astype(int)
    counts = cleaning.groupby(["issue", "source"])[["planted", "detected"]].sum().reset_index()
    detected_as = cleaning.groupby(["issue", "source"])["detected_as"].apply(join_unique).reset_index()
    actions = cleaning.groupby(["issue", "source"])["action"].apply(join_unique).reset_index()
    table = pd.merge(counts, detected_as, on=["issue", "source"], how="left")
    table = pd.merge(table, actions, on=["issue", "source"], how="left")
    table["detected"] = table["detected"].astype("Int64")
    table["missed"] = table["planted"] - table["detected"]

    integration = truth[truth["issue"].isin(INTEGRATION_ISSUES)].copy()
    integration["planted"] = 1
    integration = integration.groupby(["issue", "source"])[["planted"]].sum().reset_index()
    integration["detected_as"] = "not a cleaning problem: matched across hospitals in DA-3"
    table = pd.concat([table, integration], ignore_index=True)
    table = table[["issue", "source", "planted", "detected", "missed", "detected_as", "action"]]

    # False rejections: LEFT JOIN each quarantined record to the answer key.
    # A record with no planted problem (and not a broken line from loading) is unexplained.
    quarantine = pd.concat([read_csv(path) for path in sorted(quarantine_dir.glob("*.csv"))], ignore_index=True)
    planted_records = truth[["source", "entity", "local_id"]].drop_duplicates()
    planted_records = planted_records.rename(columns={"source": "source_code", "local_id": "source_local_id"})
    planted_records["_planted"] = True
    joined = pd.merge(quarantine, planted_records, on=["source_code", "entity", "source_local_id"], how="left")
    unplanted = quarantine[(joined["_planted"].isna() & (joined["stage"] != "load")).values]

    table.to_csv(report_dir / "planted_vs_detected.csv", index=False)
    unplanted.to_csv(report_dir / "unplanted_rejections.csv", index=False)
    return table, unplanted


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--scale", choices=("sample", "full"), default="full")
    args = parser.parse_args()
    table, unplanted = evaluate(args.scale)
    cleaning = table[table["detected"].notna()]
    by_issue = cleaning.groupby("issue")[["planted", "detected", "missed"]].sum().astype(int)
    print(by_issue.to_string())
    planted, detected = int(by_issue["planted"].sum()), int(by_issue["detected"].sum())
    print(f"\nCleaning problems: {detected} of {planted} planted problems detected; "
          f"{len(unplanted)} rejected records not explained by a planted problem.")
    return 0 if detected == planted and unplanted.empty else 1


if __name__ == "__main__":
    sys.exit(main())
