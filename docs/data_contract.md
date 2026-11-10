# Data Contract

This is the agreed Phase 2 data contract for the team kickoff on Thu Nov 5, 2026.

## Raw sources

Each source is a different fictional hospital on a different continent. Each one uses its own field names, date style, units, and labels, so integration is part of the assignment.

| Source | Continent and hospital | Format | Time zone | Date style | Other differences |
|---|---|---|---|---|---|
| A | North America — Maple Ridge General (Canada) | TXT, one file per entity, `|` delimiter, header line, `#` comment lines | America/Toronto | `2026-05-01 09:00`, local time with no zone | Temperature in °F; triage uses ESI 1–5; sex is `M` / `F` |
| B | Europe — Rhine Valley Klinikum (Germany) | CSV, one file per entity, `;` delimiter, decimal comma, UTF-8 with BOM | Europe/Berlin | `01.05.2026 09:00` (day first) | °C; triage `P1 – P3`; German labels such as `Notfall` for Emergency; ICD-9 codes sometimes undotted |
| C | Asia — Sakura Bay Medical Center (Japan) | XML, one nested file: patients → admissions → child records; separate sections for staff, units, and ICD-9 | Asia/Tokyo | ISO 8601 with offset: `2026-05-01T09:00:00+09:00` | °C; triage colours `Red / Yellow / Green` |
| D | Oceania — Southern Cross Hospital (Australia) | JSON: nested patients file plus staff, units, and ICD-9 files | Australia/Sydney (has daylight saving) | Mix of Unix epoch seconds and `01/05/2026 9:00 AM` (day first, ambiguous) | °C; triage `1 / 2 / 3`; missing values as `null` or a missing key; ICD-9 leading zeros sometimes lost |

## Target sizes per source

Target size per source: about 7,000 records per source and about 28,000 in total.

- Handout requirement: 5,000–10,000 per source and 20,000–40,000 total.
- Vary each source by up to ±15% so the sources are not identical.
- Keep each source between 5,500 and 9,500 for safety.
- Nested XML and JSON items count once each.
- Tags, headers, and containers do not count.

| Entity | Target per source |
|---|---:|
| healthcare_professionals | 50 |
| hospital_units | 8 |
| icd9_dictionary | 40 |
| patients | 600 |
| admissions | 1,000 |
| triage_assessments | 950 |
| unit_stays | 1,300 |
| diagnoses | 1,500 |
| clinical_notes | 400 |
| discharge_records | 950 |
| diagnostic_orders | 200 |
| diagnostic_examinations | 190 |
| radiology_examinations | 90 |
| radiology_reports | 85 |
| surgical_procedures | 120 |
| Total | ~7,500 |

## Required data coverage

The data must still support all 20 Phase 1 queries, including:

- high-priority triage
- patients with more than 3 admissions
- ICU/CCU stays longer than, equal to, and shorter than 7 days
- Emergency Department admissions followed by ICU
- surgery before ICU
- same-day surgery and radiology
- patients with no admissions or no radiology
- in-hospital deaths
- discharge summaries with and without `recovery`
- multiple critical-care types in one admission
- open admissions
- ICD-9 codes

Use about 40 real ICD-9 codes checked against the CMS ICD-9-CM Version 32 file. Phase 1 already verified 11 of them. Store codes as text with dots and leading zeros (for example `038.9`).

## Planted data problems

Krish plants these problems on purpose, at controlled rates. Records that cannot be fixed should stay under about 5% in total, so most of the data survives cleaning. The generator logs every planted problem in `reports/ground_truth/injected_errors.csv`. That log is the answer key; the cleaning code must never read it directly.

| # | Problem | Example | Where | Target rate |
|---|---|---|---|---|
| 1 | Exact duplicate rows | Same admission line appears twice | All sources, mostly B | 1–2% of admissions and diagnoses |
| 2 | Duplicate entities | Same patient under two local IDs: `Avelin TESTWELL` vs `Avelin Testwell`, same DOB and insurance number | Within each source | ~2% of patients |
| 3 | Missing required values | Admission with no admission time; diagnosis with no ICD-9 code | All | ~1% |
| 4 | Missing optional values | Empty phone, address or specialty | All | 5–15% |
| 5 | Inconsistent capitalization and whitespace | `" emergency "`, `"EMERGENCY"`, `"Emergency"` | All | ~5% |
| 6 | Invalid or ambiguous dates | `2026-02-30`; `05/06/2026` in D (May 6 or June 5?) | All; ambiguous ones in D | ~1% invalid; ~3% ambiguous in D |
| 7 | Invalid numbers | Heart rate `abc` or `400`; pain level `15`; a °F value in a °C field | All | ~1% |
| 8 | Broken references | Admission points to a patient who does not exist; diagnosis uses a code missing from the dictionary | All | 0.5–1% |
| 9 | Events in the wrong order | Discharge before admission; unit exit before entry; exam after discharge | All | ~1% |
| 10 | Different missing-value markers | `""`, `NULL`, `N/A`, `-`, `?`, JSON `null`, missing key, empty XML tag | Varies by source | — |
| 11 | Same local ID in different sources | Patient 125 exists in A, B, C, and D but is a different person in each | All sources, by design (IDs start at 1 everywhere) | Every ID |
| 12 | Same person in two sources | ~25 true matches (same insurance number and DOB); ~10 same name but different person; ~10 uncertain (same name and DOB, insurance missing) | A ↔ B and C ↔ D | ~45 cases |
| 13 | Broken lines | Wrong number of fields; unclosed quote | A and B | ~0.2% |
| 14 | ICD-9 format differences | `25000` instead of `250.00`; `38.9` instead of `038.9` | B and D | ~5% of codes |
| 15 | Completed admission with no primary diagnosis | Discharged admission with only secondary diagnoses | All | ~0.5% |

## Reporting requirement

The report must state the type and approximate frequency of each problem. Krish's injection log gives the planted numbers, and the cleaning summary gives the detected numbers.
