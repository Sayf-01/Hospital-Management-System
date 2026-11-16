# SOEN 363 Phase 2 — Task 2 Cleaning Report Section

Author: Sayf (SA-6) · November 16, 2026

Report section for Task 2 (Clean and Standardize the Data), ready to paste into the team report. All numbers come from the full frozen data (KR-3).

## 1. Overview

The cleaning stage (`phase2/clean.py`) takes the four loaded hospital sources and turns them into clean tables that follow the Phase 1 schema. It runs after the loader (LA-1) and before integration (DA-3). The cleaner has four stages, in this order:

1. **Clean.** Each value is checked and standardized against its Phase 1 column type. This covers missing values, text, dates, numbers, categories and ICD-9 codes. Exact duplicates are removed and duplicate patients are merged.
2. **Relationships.** Every reference inside a source must point to a parent that still exists. This stage is repeated until nothing changes, so a rejected parent also rejects its children.
3. **Chronology.** Events must happen in a possible order.
4. **Write.** The stage writes the clean tables, the quarantine tables and the reports.

Three principles guide every rule:

- **Never invent values.** A value that cannot be repaired with certainty becomes NULL if the column is optional. If the column is required (NOT NULL in `schema/schema.sql`), the whole record is quarantined.
- **Quarantine with a reason.** A rejected record is not deleted. It goes to `data/quarantine/<entity>.csv` with its stage, its problem type and its original raw record.
- **Log every change.** Every correction, NULL and rejection is a line in `reports/cleaning_log.csv`. Routine conversions applied to every row (UTC times, date formats, label mapping, °F to °C) are counted in `reports/cleaning_summary.csv` instead, so the log only lists real data problems.

**How to run** (from the repository root):

```
python phase2/clean.py                  # full data (default)
python phase2/clean.py --scale sample   # quick check on the sample
python phase2/evaluate_cleaning.py      # compare with the answer key
python -m pytest phase2                 # unit and full-data tests
```

**Outputs**

| File | Contents |
| --- | --- |
| `data/clean/*.csv` | One clean table per entity, with source code and source ID kept for integration |
| `data/quarantine/*.csv` | Rejected records with stage, reason and raw record |
| `reports/counts_clean.csv` | Row counts per source and entity, with a reconciliation check |
| `reports/cleaning_log.csv` | One line per problem found and the action taken |
| `reports/cleaning_summary.csv` | Totals per problem type and source |
| `reports/cleaning_examples.csv` | Real before-and-after examples |
| `reports/patient_id_remap.csv` | Old patient ID to kept patient ID for merged duplicates |
| `reports/planted_vs_detected.csv` | Planted problems compared with detected problems (SA-4) |

The cleaner never reads the generator's answer key. A separate script (`evaluate_cleaning.py`) compares the results with it afterwards, so the comparison in Section 11 is a fair test. Running the cleaner twice gives byte-identical outputs.

## 2. Missing values

Each hospital marks a missing value differently. The cleaner treats a value as missing if, after trimming spaces and ignoring case, it is one of these markers: empty, `NULL`, `N/A`, `NA`, `-`, `?` or `none`. A field that is absent from the record also counts as missing.

| Source | Markers found in the full data |
| --- | --- |
| A (TXT) | empty field, `-`, `NULL` |
| B (CSV) | empty field, `?`, `N/A` |
| C (XML) | empty element, missing element |
| D (JSON) | missing key |

What happens next depends on whether the Phase 1 schema requires the column:

| Column | Action | Count |
| --- | --- | --: |
| Required (NOT NULL), e.g. `note_contents` | Record quarantined (it cannot be stored without inventing a value) | 16 |
| Optional, e.g. `discharge_datetime`, `phone_number` | Kept as NULL and logged | 30,786 |

The optional count is high because the generator always leaves some fields empty by design. For example, 4,000 admissions have no `current_condition` and no `insurance_info`, and 2,399 patients have no `date_of_death` because they are alive. Only 225 of the 30,786 were planted problems; all 225 were detected. The 16 required-value rejections were all clinical notes with no text, 4 per source.

## 3. Duplicates

**Exact duplicates.** Two rows are exact duplicates when every field is equal after trimming spaces. The first copy is kept and the others are removed with `drop_duplicates(keep="first")`. Every removed copy is logged.

**Duplicate patients.** A patient registered twice in the same hospital gets a new ID each time, so the rows are not exact duplicates. Two patient rows in the same source are the same person only when all of these match:

- first name and last name (extra spaces removed, case ignored)
- date of birth
- health insurance number (trimmed, case ignored)

A patient without an insurance number is never matched, because a name and a birth date alone are not enough proof. The patient with the lowest local ID is kept. The others are removed, and every admission and diagnosis that pointed to them is repointed to the kept patient. `reports/patient_id_remap.csv` records each old ID and its kept ID.

| Problem | A | B | C | D | Total | Action |
| --- | --: | --: | --: | --: | --: | --- |
| Exact duplicate rows (admissions 51, diagnoses 75) | 24 | 52 | 25 | 25 | 126 | Removed |
| Duplicate patients | 11 | 12 | 12 | 12 | 47 | Merged into kept patient |

Matching the same patient across different hospitals is integration, not cleaning. It is done in DA-3.

## 4. Text

- **Free text** (notes, instructions, medications): only leading and trailing spaces are removed. The wording is never changed.
- **Other text** (names, phone numbers, IDs): leading and trailing spaces are removed and runs of spaces inside are collapsed to one.
- **Category labels**: spaces and capitals are fixed as part of the category mapping (Section 7). For example, `" EMERGENCY "` and `" NOTFALL "` both become `Emergency`.

Only changes to values that were really untidy are logged. A label that was already clean but simply written in another language or code is a routine mapping and is counted in the summary instead.

| Problem | A | B | C | D | Total | Action |
| --- | --: | --: | --: | --: | --: | --- |
| Extra spaces in a name (`last_name`) | 11 | 12 | 12 | 12 | 47 | Trimmed |
| Wrong case or spaces in a label (`admission_type`) | 47 | 52 | 49 | 51 | 199 | Corrected |

## 5. Dates and timestamps

Every timestamp is stored in UTC, so events from different hospitals can be compared and ordered. Calendar dates (date of birth, date of death) are only reformatted to `YYYY-MM-DD`. No time zone is applied to them, because a birthday does not change between countries.

| Source | Time zone | Raw timestamp format | Example raw | Stored (UTC) |
| --- | --- | --- | --- | --- |
| A | America/Toronto | `YYYY-MM-DD HH:MM` (local) | `2026-01-06 08:00` | `2026-01-06 13:00:00` |
| B | Europe/Berlin | `DD.MM.YYYY HH:MM` (local) | `15.06.2026 08:00` | `2026-06-15 06:00:00` |
| C | Asia/Tokyo | ISO 8601 with offset | `2026-01-06T08:00:00+09:00` | `2026-01-05 23:00:00` |
| D | Australia/Sydney | Epoch seconds, or `DD/MM/YYYY h:mm AM/PM` (local) | `1781474400` | `2026-06-14 22:00:00` |

The conversion uses Python's `zoneinfo`, so daylight saving time is handled for each date. The rules for uncertain times:

- **Explicit offset (C).** The offset written in the value is used, as it is the most certain information.
- **Epoch seconds (D).** These are already an exact instant, so no time zone is needed.
- **Local time that does not exist or exists twice.** During a daylight-saving change, a clock time can be skipped or repeated. Such a time cannot be converted with certainty, so it is treated as invalid. None occurred in the full data.
- **Impossible date** (for example `2026-02-30T09:00:00`). The value is invalid. All 16 cases were on `note_datetime`, a required column, so the notes were quarantined (4 per source).
- **Ambiguous day-first date (D).** D writes `DD/MM/YYYY`. When both the day and the month are 12 or less and differ, as in `01/07/2026`, the value would also make sense as `MM/DD`. The cleaner keeps D's documented day-first format and logs the assumption instead of rejecting the record. This happened 230 times: the 12 planted cases, plus 218 real D birth dates that happen to fit both readings.

| Problem | A | B | C | D | Total | Action |
| --- | --: | --: | --: | --: | --: | --- |
| Timestamp converted to UTC (routine) | 7,597 | 8,317 | 7,837 | 8,227 | 31,978 | Converted |
| Date reformatted (routine) | 0 | 636 | 0 | 412 | 1,048 | Converted |
| Impossible timestamp | 4 | 4 | 4 | 4 | 16 | Quarantined |
| Ambiguous day-first date | 0 | 0 | 0 | 230 | 230 | Kept, assumption logged |

## 6. Numeric values and units

Measurements are parsed with Python's `Decimal`, so no rounding error is added.

- **Decimal comma (B).** B writes `37,2`. The comma is replaced by a point before parsing.
- **Fahrenheit (A).** A records body temperature in °F. It is converted with (°F − 32) × 5 / 9 and rounded to one decimal, half away from zero, to match the `numeric(4,1)` column. For example, 97.5 °F becomes 36.4 °C. This was applied to 903 triage rows.
- **Whole numbers.** Heart rate, respiratory rate and pain level must be whole numbers.
- **Blood pressure** is stored as text and must look like `120/80`.

After conversion, each value must fall inside a valid range (inclusive):

| Measure | Valid range |
| --- | --- |
| Heart rate | 20–250 bpm |
| Respiratory rate | 4–60 breaths/min |
| Body temperature | 30.0–45.0 °C |
| Oxygen saturation | 50.0–100.0 % |
| Pain level | 0–10 |

A value outside its range is not a real measurement, but the rest of the triage record is still useful. Every measurement column is optional, so the bad value becomes NULL and the record is kept.

| Problem | A | B | C | D | Total | Action |
| --- | --: | --: | --: | --: | --: | --- |
| °F converted to °C (routine) | 903 | 0 | 0 | 0 | 903 | Corrected |
| Out of range (`pain_level` = 15) | 9 | 10 | 9 | 10 | 38 | Set to NULL |

## 7. Clinical categories and ICD-9 codes

**Categories.** Each hospital uses its own labels. The mapping tables in `phase2/config/value_maps.py` (SA-2) translate every source label into the single Phase 1 value. Only listed labels are accepted; an unknown label is never guessed. The main differences between sources:

| Column | A (TXT) | B (CSV) | C (XML) | D (JSON) | Phase 1 value |
| --- | --- | --- | --- | --- | --- |
| `gender` | `M` / `F` | `Male` / `Female` | `Male` / `Female` | `Male` / `Female` | `Male` / `Female` |
| `admission_type` | English | German: `Notfall`, `Dringend`, `Geplant`, `Ambulant` | English, sometimes upper case | English | `Emergency`, `Urgent`, `Elective`, `Outpatient` |
| `priority_level` | Scale 1–5: 1–2 → High-Priority Emergency, 3 → Urgent, 4–5 → Non-Urgent | `P1` / `P2` / `P3` | `Red` / `Yellow` / `Green` | `1` / `2` / `3` | `High-Priority Emergency`, `Urgent`, `Non-Urgent` |

5,370 labels were translated this way (A 1,484, B 1,976, C 931, D 979). These are routine mappings, not errors.

**ICD-9 codes.** Every diagnosis code must exist in the ICD-9 dictionary. Some sources write codes without the dot (`41401`) or without leading zeros (`41.11`). The cleaner compares codes with the dot and leading zeros removed. It repairs a code only when exactly one dictionary code matches. If two codes could match, or none does, the code is not guessed and the diagnosis is quarantined, because `icd9_code` is required.

| Raw code | Stored code | Why |
| --- | --- | --- |
| `41401` (B) | `414.01` | Dot missing; one dictionary match |
| `25000` (B) | `250.00` | Dot missing; one dictionary match |
| `41.11` (D) | `041.11` | Leading zero missing; one dictionary match |
| `999.99` (A, B, C, D) | none | Not in the dictionary: quarantined |

| Problem | A | B | C | D | Total | Action |
| --- | --: | --: | --: | --: | --: | --- |
| ICD-9 format repaired | 0 | 78 | 0 | 77 | 155 | Corrected |
| ICD-9 code not in dictionary | 7 | 12 | 7 | 12 | 38 | Quarantined |

## 8. Relationships

Every reference inside a source is checked against its parent table, for example a diagnosis against its admission, patient and ICD-9 code.

- **Missing required parent.** The child record is quarantined. The check is repeated until nothing changes, so when a parent is rejected, its children are rejected on the next pass (a cascade).
- **Missing optional parent** (a staff member, such as the nurse on a triage). The reference becomes NULL and is logged. The record is kept.
- **Inconsistent references.** The patient on a diagnosis or a diagnostic order must be the patient of its admission. A discharge record cannot belong to an admission that is still `Admitted`, and its condition must agree with the admission status (`Deceased` with `Deceased`). One-to-one links (one discharge per admission, one radiology record per examination, one report per radiology record) and at most one Primary diagnosis per admission are enforced, matching the Phase 1 UNIQUE constraints.
- **Missing Primary diagnosis.** A completed admission (Discharged or Deceased) should have a Primary diagnosis. Inventing one is not allowed, so the admission is kept and flagged for review.

| Problem | A | B | C | D | Total | Action |
| --- | --: | --: | --: | --: | --: | --- |
| Records quarantined for a broken or inconsistent reference | 0 | 0 | 0 | 0 | 0 | Quarantined |
| Completed admission with no Primary diagnosis | 9 | 11 | 11 | 12 | 43 | Kept, flagged for review |

No record was rejected at this stage. The bad ICD-9 codes were already caught in Section 7, and none of the 47 merged duplicate patients had admissions or diagnoses that needed repointing. Of the 43 flagged admissions, 20 had their Primary diagnosis removed by the generator. The other 23 lost their Primary diagnosis because its ICD-9 code was `999.99` and was quarantined. A test (`test_full_data.py`) checks that every flag has one of these two reasons.

## 9. Chronology

All times are compared in UTC (Section 5), so events from one admission can be ordered safely. The checks:

| Check | Rule |
| --- | --- |
| Admission | Discharge after admission; admission not before the patient's birth |
| Death | The date of death must match the patient's Deceased admission |
| Unit stay | Exit after entry; stay inside its admission; stays in one admission do not overlap |
| Diagnoses, notes, orders, surgeries | Event time inside its admission |
| Triage | Not after discharge; at most 24 hours before the admission opens |
| Examinations | After their order, and inside the admission |

If the wrong time is in a required column, the record is quarantined, since the right time cannot be known. If the wrong time is optional, only that time becomes NULL and the record is kept. Overlapping stays are found with `groupby` and `shift(1)`, which compare each stay with the previous one in the same admission.

| Problem | A | B | C | D | Total | Action |
| --- | --: | --: | --: | --: | --: | --- |
| Unit stay exit not after entry (`exit_datetime` is optional) | 12 | 13 | 13 | 13 | 51 | Set to NULL |
| Records quarantined for chronology | 0 | 0 | 0 | 0 | 0 | Quarantined |

## 10. Representative before-and-after examples

All examples are real rows from the full-data run (`reports/cleaning_examples.csv`).

| Source | Record | Column | Before | After | Action |
| --- | --- | --- | --- | --- | --- |
| A | clinical note 162 | `note_contents` | `-` | none | Quarantined (required) |
| B | admission 15 | `discharge_datetime` | `N/A` | NULL | Kept as NULL |
| A | admission 156 | whole row | second identical copy | none | Removed |
| A | patient 571 | patient ID | `571` | `132` | Merged into kept patient |
| A | patient 571 | `last_name` | `" PATIENTA0132 "` | `PATIENTA0132` | Trimmed |
| B | admission 41 | `admission_type` | `" NOTFALL "` | `Emergency` | Corrected |
| C | admission 1 | `admission_datetime` | `2026-01-06T08:00:00+09:00` | `2026-01-05 23:00:00` | Converted to UTC |
| D | clinical note 22 | `note_datetime` | `01/07/2026 7:00 AM` | `2026-06-30 21:00:00` | Kept, day-first assumption logged |
| A | clinical note 55 | `note_datetime` | `2026-02-30T09:00:00` | none | Quarantined |
| B | patient 1 | `date_of_birth` | `04.05.2010` | `2010-05-04` | Reformatted |
| A | triage 1 | `body_temperature` | `97.5` (°F) | `36.4` (°C) | Converted |
| A | triage 152 | `pain_level` | `15` | NULL | Set to NULL |
| C | triage 1 | `priority_level` | `Red` | `High-Priority Emergency` | Mapped |
| B | diagnosis 20 | `icd9_code` | `41401` | `414.01` | Repaired |
| A | diagnosis 149 | `icd9_code` | `999.99` | none | Quarantined |
| A | unit stay 25 | `exit_datetime` | `2026-01-11 15:25:00` (not after entry) | NULL | Set to NULL |
| A | admission 65 | Primary diagnosis | none | none | Kept, flagged for review |
| A | clinical note (line) | whole line | `237\|252\|11\|Discharge Summary\|2026-02-24 10:00` | none | Quarantined (malformed) |

The malformed line has five fields where six were expected, so the loader could not read it as a record. It is kept in quarantine with its raw text.

## 11. Summary of cleaning results

**Counts per source.** Every raw record is accounted for. For each source and entity, rows loaded = rows out + exact duplicates removed + duplicate patients merged + rows quarantined. This holds for all 60 source and entity pairs (`reconciles` column in `reports/counts_clean.csv`).

|  | A | B | C | D | Total |
| --- | --: | --: | --: | --: | --: |
| Raw records (KR-3) | 7,144 | 7,840 | 7,366 | 7,741 | 30,091 |
| Malformed at load | 1 | 1 | 0 | 0 | 2 |
| Rows loaded | 7,143 | 7,839 | 7,366 | 7,741 | 30,089 |
| Exact duplicates removed | 24 | 52 | 25 | 25 | 126 |
| Duplicate patients merged | 11 | 12 | 12 | 12 | 47 |
| Quarantined in cleaning | 15 | 20 | 15 | 20 | 70 |
| Quarantined for relationships | 0 | 0 | 0 | 0 | 0 |
| Quarantined for chronology | 0 | 0 | 0 | 0 | 0 |
| **Clean rows out** | **7,093** | **7,755** | **7,314** | **7,684** | **29,846** |

Reconciliation: 29,846 clean + 126 duplicates + 47 merged + 70 quarantined + 2 malformed = 30,091 raw records.

Only 72 records were rejected (70 quarantined and 2 malformed), which is 0.24% of the raw data. Every other problem was repaired, set to NULL, or kept and flagged.

**Planted versus detected.** The generator (KR-3) wrote an answer key of every problem it planted. After cleaning, `evaluate_cleaning.py` compares the cleaning log with that key.

| Planted problem | Planted | Detected | Detected as |
| --- | --: | --: | --- |
| Missing optional value | 225 | 225 | Kept as NULL |
| Missing required value | 16 | 16 | Quarantined |
| Exact duplicate admission or diagnosis | 126 | 126 | Removed |
| Duplicate patient in one source | 47 | 47 | Merged into kept patient |
| Wrong case or spaces in a label | 199 | 199 | Corrected |
| Impossible date | 16 | 16 | Quarantined |
| Ambiguous day-first date (D) | 12 | 12 | Kept, assumption logged |
| Invalid number | 38 | 38 | Set to NULL |
| ICD-9 format | 155 | 155 | Corrected |
| Broken ICD-9 reference | 38 | 38 | Quarantined |
| Missing Primary diagnosis | 20 | 20 | Kept, flagged for review |
| Chronology (stay exit before entry) | 51 | 51 | Set to NULL |
| Malformed line | 2 | 2 | Quarantined |
| **Total** | **945** | **945** |  |

All 945 planted cleaning problems were detected, and no record was rejected without a planted reason (`reports/unplanted_rejections.csv` is empty). The answer key also lists 90 cross-hospital matching entries; these belong to integration (DA-3), not cleaning, and are reported there.

Some counts are higher than the planted numbers, and each difference is explained: 218 more ambiguous dates are real D birth dates (Section 5), 23 more missing-Primary flags come from quarantined ICD-9 codes (Section 8), and the extra missing optional values are fields the generator always leaves empty (Section 2). The full-data tests (`phase2/test_full_data.py`) check all of these results automatically.
