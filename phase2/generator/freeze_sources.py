"""KR-3: verify reproducible full sources, audit planted risks, then freeze bytes.

Run from the repository root:
    python phase2/generator/freeze_sources.py
Later verification (does not regenerate or write raw files):
    python phase2/generator/freeze_sources.py --verify
"""
import argparse
import csv
import hashlib
import json
import stat
import subprocess
import sys
import tempfile
from collections import Counter
from pathlib import Path

from generate_sources import MAP_PATH, PRIMARY_KEYS, generate, inject_errors
from write_sources import PARENTS
import runpy

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data/raw"
MANIFEST = RAW / "checksums.txt"
REPORTS = ROOT / "reports"
RISK_ISSUES = {
    "missing_required", "invalid_date", "broken_reference", "chronology", "malformed_rows",
}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def raw_files():
    return sorted(p for p in RAW.rglob("*") if p.is_file() and p != MANIFEST)


def verify_manifest():
    if not MANIFEST.exists():
        raise ValueError("No manifest found; run the freeze command first")
    expected = {}
    for line in MANIFEST.read_text(encoding="utf-8").splitlines():
        sha, relative = line.split("  ", 1)
        path = (RAW / relative).resolve()
        if not path.is_relative_to(RAW.resolve()) or path == MANIFEST:
            raise ValueError("Invalid path in checksum manifest")
        if path in expected:
            raise ValueError("Duplicate path in checksum manifest")
        expected[path] = sha
    actual = {path.resolve(): digest(path) for path in raw_files()}
    if expected != actual:
        changed = sorted(str(p.relative_to(RAW)) for p in expected.keys() | actual.keys()
                         if expected.get(p) != actual.get(p))
        raise ValueError("Checksum mismatch, missing or additional file: " + ", ".join(changed))
    print(f"PASS: {len(actual)} raw files match SHA-256 checksums (sample and full).")


def audit_risk(events):
    """Conservative exposure, not a prediction of the cleaner's decisions.

    Include all descendants of a completed admission losing its primary
    diagnosis. Include every occurrence of a risky record ID, even duplicates.
    Other optional clinical defects may be nulled instead of rejected.
    """
    config = runpy.run_path(str(MAP_PATH))
    data = generate("full")
    inject_errors(data, "full", config["INJECTION_RATES"])
    risks = {s: {t: set() for t in tables} for s, tables in data.items()}
    diagnoses = {s: {str(d["diagnosis_id"]): d for d in tables["diagnoses"]}
                 for s, tables in data.items()}
    for event in events:
        source, table = event["source"], event["entity"]
        issue, identifier = event["issue"], event["local_id"]
        if issue in RISK_ISSUES:
            risks[source][table].add(identifier)
            if issue == "broken_reference" and table == "diagnoses":
                row = diagnoses[source].get(identifier)
                if row and row["diagnosis_type"] == "Primary":
                    risks[source]["admissions"].add(str(row["admission_id"]))
        elif issue == "missing_primary":
            removed = json.loads(event["original_value"])
            risks[source]["admissions"].add(str(removed["admission_id"]))
    changed = True
    while changed:
        changed = False
        for source, tables in data.items():
            for table, (parent, foreign_key) in PARENTS.items():
                for row in tables[table]:
                    if str(row[foreign_key]) in risks[source][parent]:
                        ids = risks[source][table]
                        key = str(row[PRIMARY_KEYS[table]])
                        if key not in ids:
                            ids.add(key)
                            changed = True
    summaries = []
    for source, tables in data.items():
        total = sum(map(len, tables.values()))
        exposed = sum(str(row[PRIMARY_KEYS[table]]) in risks[source][table]
                      for table, rows in tables.items() for row in rows)
        summaries.append({"source": source, "raw_records": total,
                          "conservative_at_risk_records": exposed,
                          "percent_at_risk": round(100 * exposed / total, 3)})
    if any(row["percent_at_risk"] >= 5 for row in summaries):
        raise ValueError("Conservative planted-risk exposure reaches 5% for a source")
    return summaries


def freeze():
    if MANIFEST.exists():
        raise ValueError("Already frozen. Use --verify; coordinate any regeneration with the team.")
    required = [REPORTS / "counts_raw.csv", REPORTS / "ground_truth/injected_errors.csv"]
    if not (RAW / "full").is_dir() or any(not path.exists() for path in required):
        raise ValueError("First run: python phase2/generator/write_sources.py --scale full")
    if not (RAW / "sample").is_dir():
        raise ValueError("Expected the existing KR-2 sample directory")
    # Regenerate in isolation to verify raw bytes, counts and answer key without
    # changing any existing source file. Uses the same generator and seed 363.
    with tempfile.TemporaryDirectory(prefix="kr3-reproduce-") as folder:
        temporary = Path(folder)
        subprocess.run([
            sys.executable, str(Path(__file__).with_name("write_sources.py")),
            "--scale", "full", "--output-dir", str(temporary / "full"),
            "--reports-dir", str(temporary / "reports"),
        ], check=True, stdout=subprocess.PIPE, text=True)
        reproduced = {p.name: digest(p) for p in (temporary / "full").iterdir()}
        existing = {p.name: digest(p) for p in (RAW / "full").iterdir() if p.is_file()}
        if reproduced != existing or len(existing) != 35:
            raise ValueError("Full raw files differ from a fresh run; do not freeze changed files")
        for path in required:
            relative = path.relative_to(REPORTS)
            if digest(path) != digest(temporary / "reports" / relative):
                raise ValueError(f"Report differs from a fresh run: {path.name}")
    with required[0].open(encoding="utf-8", newline="") as file:
        counts = list(csv.DictReader(file))
    if len(counts) != 60 or len({(r["source"], r["entity"]) for r in counts}) != 60:
        raise ValueError("Expected 60 source/entity count rows")
    totals = Counter()
    malformed = 0
    for row in counts:
        totals[row["source"]] += int(row["raw_records"])
        malformed += int(row["malformed_rows_included"])
    if set(totals) != set("ABCD") or not all(5500 <= n <= 9500 for n in totals.values()):
        raise ValueError(f"Source sizes outside the team safety range: {totals}")
    if not 20000 <= sum(totals.values()) <= 40000:
        raise ValueError("Total size outside the assignment range")
    with required[1].open(encoding="utf-8", newline="") as file:
        events = list(csv.DictReader(file))
    if any(e["status"] != "applied" for e in events):
        raise ValueError("Pending or unknown injection status")
    risks = audit_risk(events)
    report_path = REPORTS / "kr3_freeze_audit.json"
    if report_path.exists():
        raise ValueError("Existing freeze audit found; inspect it before retrying")
    report = {
        "seed": 363, "source_totals": dict(sorted(totals.items())),
        "total_raw_records": sum(totals.values()), "malformed_rows_included": malformed,
        "reproduced_full_files": 35, "all_60_count_rows_verified": True,
        "ground_truth_log_entries": len(events),
        "issue_log_entries_by_type": dict(sorted(Counter(e["issue"] for e in events).items())),
        "risk_scope": "Conservative exposure from planted problems, including descendants of "
                      "admissions losing a primary diagnosis; not an observed rejection count.",
        "risk_by_source": risks,
        "limitations": [
            "The audit covers generator reproducibility and planted-risk exposure.",
            "Loaders, cleaners and final SQL integrity validation must independently report outcomes.",
            "Read-only permissions are local protection; Git does not preserve them on checkout.",
        ],
    }
    with report_path.open("x", encoding="utf-8", newline="\n") as file:
        json.dump(report, file, indent=2)
        file.write("\n")
    with MANIFEST.open("x", encoding="utf-8", newline="\n") as file:
        for path in raw_files():
            file.write(f"{digest(path)}  {path.relative_to(RAW).as_posix()}\n")
    for path in [*raw_files(), MANIFEST]:
        mode = path.stat().st_mode
        path.chmod(mode & ~(stat.S_IWUSR | stat.S_IWGRP | stat.S_IWOTH))
    verify_manifest()
    for row in risks:
        print(f"{row['source']}: {row['raw_records']:,} raw records; "
              f"conservative at-risk exposure {row['percent_at_risk']:.3f}%")
    print(f"Frozen {sum(totals.values()):,} full records; {malformed} malformed lines included.")
    print("Raw sources and checksums are read-only on this machine.")
    print("Audit: reports/kr3_freeze_audit.json")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify", action="store_true", help="Check hashes without modifying files")
    args = parser.parse_args()
    try:
        if args.verify:
            verify_manifest()
        else:
            freeze()
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"KR-3 stopped: {error}\n")


if __name__ == "__main__":
    main()
