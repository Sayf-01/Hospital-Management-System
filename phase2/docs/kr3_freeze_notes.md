# KR-3: full synthetic sources and freeze

Status: prepared and tested on November 16, 2026. A teammate's checkout is frozen
only after the commands below succeed there.

## Starting point and dependencies

Create KR-3 from updated main. KR-1, KR-2, SA-2 and LA-1 are already merged there.
SA-3 (PR #8) and DA-1/DA-2 (PR #9) remain separate reviews. No merge of those
branches is needed to generate the sources. Their code was inspected without
changing or merging their branches.

## Run from the repository root

1. Add `data/raw/** -text` to .gitattributes before staging the raw files. This
   prevents automatic Git line-ending conversion, including on Windows.
2. Install dependencies: `python -m pip install -r requirements.txt tzdata`.
3. Generate: `python phase2/generator/write_sources.py --scale full`.
4. Freeze: `python phase2/generator/freeze_sources.py`.
5. Verify later: `python phase2/generator/freeze_sources.py --verify`.
6. Run the loader: `python phase2/load.py --scale full`.

An existing full output folder or report is deliberately not overwritten. Do
not delete or regenerate a frozen source without coordinating with the team.

## Deliverables

- data/raw/full/: 35 actual TXT, CSV, XML and JSON files.
- reports/counts_raw.csv: 60 source/entity count rows.
- reports/ground_truth/injected_errors.csv: 1,035 answer-key entries, all applied.
- reports/kr3_freeze_audit.json: reproducibility and conservative planted-risk audit.
- data/raw/checksums.txt: SHA-256 for the 35 full and 35 existing sample files.
- phase2/generator/freeze_sources.py: checks, read-only permissions and later verification.

The generator and sample writer remain unchanged from KR-2. The sample files
are kept byte-for-byte as they were on main (LF line endings), and their
checksums were computed from those committed bytes. The Git attribute
(`data/raw/** -text`) stops Git from converting line endings, so a fresh
checkout on Windows, macOS or Linux matches the manifest. A fresh checkout does
not retain local read-only permissions; use the manifest to verify bytes on
every machine.

## Verified full counts

| Source | Continent | Format | Raw entity instances |
|---|---|---|---:|
| A | North America | TXT | 7,144 |
| B | Europe | CSV | 7,840 |
| C | Asia | XML | 7,366 |
| D | Oceania | JSON | 7,741 |
| Total | Four distinct continents | Four formats | 30,091 |

XML uses Tokyo offset timestamps; JSON uses Sydney epoch seconds and day-first
strings. These follow the current KR-1 maps and dictionary. Containers and
attributes do not count as entity records. The raw total includes the two
deliberately malformed A/B lines.

The clean generator creates 29,938 records. Adding 47 duplicate patient records
and 126 exact duplicate admission/diagnosis records, and removing 20 primary
diagnoses, yields 30,091 raw records. Cross-source match log entries include both
sides of a pair: 50 true-match entries represent 25 pairs; 20 same-name entries
represent 10 nonmatching pairs; 20 uncertain entries represent 10 uncertain pairs.

## Integrity and risk scope

The freeze script independently regenerates the full sources in a temporary
directory and compares every full file, the count report and the answer key byte
for byte. It then hashes raw sources and makes those files and the manifest
read-only locally.

Conservative planted-risk exposure is A 1.162%, B 1.390%, C 1.317%, D 1.266%.
The estimate includes all descendants of an admission missing its primary
diagnosis, including a broken-code primary. It is an exposure estimate from
the generator answer key, not an observed rejection rate or a SQL integrity
certificate. The cleaning pipeline never reads that answer key.

## Compatibility evidence

Checked against main acb2e90166d20ff176044ea111fbb7b0e459099d:
LA-1 loads 30,089 rows, logs two malformed lines and matches all 60 count rows.

An isolated test of SA-3 commit 1945e7985c729fc7a83da7077435b5e3b396051f
retained 29,846 rows, removed 126 exact duplicate rows,
merged 47 duplicate patient rows and quarantined 70 loaded rows.
All 60 tables reconcile. Raw reconciliation:
29,846 accepted + 126 exact duplicates + 47 patient duplicate rows
+ 70 quarantined + 2 malformed = 30,091.

This file's compatibility results are a pre-import check, not proof of all
post-import business rules. Youssef still needs to validate the populated SQL
database. Do not include raw sources or database dumps in the Moodle submission;
keep them available for the demonstration, as required by the handout.
