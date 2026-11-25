# SA-5: Phase 1 queries Q2, Q6, Q8 and Q18 on the Phase 2 database

Author: Sayf (SA-5) · November 25, 2026

The four queries were run on `hospital_phase2`, built from the frozen full data with
`python run_all.py --allow-destructive-rebuild`. The Phase 1 results come from the Phase 1
database (`schema/schema.sql` and `data/data.sql`). All four queries ran unchanged: every
table and column they use still exists in `sql/schema_v2.sql`. The final SQL is in
`sql/phase1_queries_v2.sql`, and both sets of results are in `reports/phase1_reruns/`.

## Summary

| Query | What it asks | Phase 1 rows | Phase 2 rows | SQL changed? |
| --- | --- | --: | --: | --- |
| Q2 | Patients with more than three admissions | 4 | 15 | No |
| Q6 | Admissions per patient, including patients with none | 50 | 2,375 | No |
| Q8 | Most common Primary ICD-9 code in admissions with an ICU or CCU stay | 1 | 2 (tie) | No |
| Q18 | Latest clinical note for each patient | 46 | 954 | No |

The database the queries ran on:

| | Phase 1 | Phase 2 |
| --- | --: | --: |
| Patients | 50 | 2,375 |
| Admissions | 120 | 4,000 |
| Diagnoses | 167 | 5,942 |
| Clinical notes | 358 | 1,566 |

## Q2: patients with more than three admissions

**SQL:** unchanged.

**Result:** 15 patients, each with exactly 4 admissions (Phase 1: 4 patients, with 4 or 5 admissions).

**Why:** 11 of the 15 are patients merged across two hospitals (A with B, or C with D), so
their admissions from both hospitals now count together. Without that merge, only 4 patients
would qualify, one per hospital. This shows the cross-hospital patient matching (DA-3) working:
each merged patient appears once with all their admissions.

| Patients in the result | Count |
| --- | --: |
| Patients from one hospital | 4 (one each from A, B, C and D) |
| Patients merged across two hospitals | 11 (6 from A and B, 5 from C and D) |
| **Total** | **15** |

## Q6: admissions per patient, including patients with none

**SQL:** unchanged.

**Result:** 2,375 patients (Phase 1: 50). 8 patients have no admissions (Phase 1: 4).

**Why:** the four hospitals bring far more patients. The 2,375 patients are the patients
from all four hospitals after duplicates were merged: 47 duplicates within a hospital
during cleaning (SA-3) and 25 matches across hospitals during integration (DA-3). The
`LEFT JOIN` still keeps patients with no admissions, so they show 0 instead of
disappearing. Most patients have 1 or 2 admissions (average 1.68).

| Admissions | Phase 1 patients | Phase 2 patients |
| --: | --: | --: |
| 0 | 4 | 8 |
| 1 | 9 | 775 |
| 2 | 5 | 1,566 |
| 3 | 28 | 11 |
| 4 | 3 | 15 |
| 5 | 1 | 0 |

## Q8: most common Primary diagnosis in ICU or CCU admissions

**SQL:** unchanged. This query has no date or time columns, so the switch to `TIMESTAMPTZ` does not affect it.

**Result:** a tie between two codes, each assigned 26 times (Phase 1: one code, 410.91, 7 times).

| ICD-9 code | Description | Times assigned |
| --- | --- | --: |
| 401.9 | Unspecified essential hypertension | 26 |
| 486 | Pneumonia, organism unspecified | 26 |

**Why:** 707 admissions had an ICU or CCU stay, with 701 Primary diagnoses across 40 codes.
Both winning codes appear in all four hospitals. The query keeps every code equal to the
maximum, so it correctly returns both codes in the tie. The merged ICD-9 dictionary holds each
of its 40 codes once, and every diagnosis code matches it, including the 155 codes repaired
during cleaning (for example `41401` to `414.01`). Six ICU or CCU admissions have no
Primary diagnosis. They are the flagged admissions from cleaning, and they are correctly not
counted. As in Phase 1, the query counts only units of type `ICU` and `CCU`, not `SICU`
or `MICU`.

## Q18: latest clinical note for each patient

**SQL:** unchanged. Ties are still broken with `note_id`.

**Result:** 954 patients (Phase 1: 46). The other 1,421 patients have no clinical notes.

**Why:** all note times are now stored as `TIMESTAMPTZ` in UTC, so notes written in Toronto,
Berlin, Tokyo and Sydney are ordered by the real moment they were written, not by local
clock time. Five merged patients have notes from two hospitals (patients 42 and 179 from A and
B; 1245, 1282 and 1384 from C and D). For each of them the query correctly picks the latest note
across both hospitals. In the full data no patient has two notes at the same latest time, so
the `note_id` tie-breaker never changes the result. The 16 notes quarantined during cleaning
(no text, or an impossible date) are not in the database, so they cannot appear.

Note: `note_datetime` is shown in the session's time zone. psql here shows UTC (`+00`).
pgAdmin may show the same moments in local time (for example `-05` in Montréal).
