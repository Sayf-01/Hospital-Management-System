# DA-5: Phase 1 queries Q10, Q14, Q16 and Q19 on the Phase 2 database

Author: Dany (DA-5) · November 25, 2026

The four queries were run on `hospital_phase2`, the same database as on Neon (32,187 rows),
built from the frozen full data by `run_all.py`. The Phase 1 results come from the Phase 1
database (`schema/schema.sql` and `data/data.sql`). All four queries ran unchanged: every
table and column they use still exists in `sql/schema_v2.sql`. The SQL is in
`sql/phase1_queries_v2.sql`, and both sets of results are in `reports/phase1_reruns/`.

Times are shown in UTC (`+00`), the time zone the Phase 2 database is set to. pgAdmin may
show the same moments in local time.

## Summary

| Query | What it asks | Phase 1 rows | Phase 2 rows | SQL changed? |
| --- | --- | --: | --: | --- |
| Q10 | Patients with a surgery before entering an ICU or CCU, in the same admission | 7 | 239 | No |
| Q14 | Patient(s) with the longest completed stay, ties included | 2 | 4 (tie) | No |
| Q16 | Patients with more than one type of critical care unit in one admission | 4 | 4 | No |
| Q19 | Admissions where the patient died during the stay, with the Primary diagnosis | 2 | 48 | No |

## Q10: surgery before an ICU or CCU stay

**SQL:** unchanged.

**Result:** 239 rows: 189 patients, 239 admissions (Phase 1: 7 rows).

| Hospital | Rows | Patients |
| --- | --: | --: |
| A | 57 | 44 |
| B | 62 | 53 |
| C | 59 | 47 |
| D | 61 | 46 |
| **Total** | **239** | **189** |

**Why:** four hospitals bring far more surgeries and ICU or CCU stays. The surgery and the
unit stay are matched through the same `admission_id`, and after integration every admission
belongs to exactly one hospital, so a surgery is never paired with a stay from another
hospital. 8 pairs where the surgery happened at or after the unit entry are correctly left
out. Comparing the two times is now reliable across hospitals: both are stored as
`TIMESTAMPTZ` in UTC, so a Tokyo surgery and a Tokyo unit stay are compared as real moments.
4 of the patients are patients merged across two hospitals (M1); each still appears only with
the admission where the surgery happened.

## Q14: longest completed hospital stay

**SQL:** unchanged. The query keeps every stay equal to the maximum, so ties all appear.

**Result:** a four-way tie at exactly 8 days, one patient from each hospital (Phase 1: two
patients tied at 30 days).

| Hospital | Source patient | Global patient | Length of stay |
| --- | --- | --: | --- |
| A | 1 | 1 | 8 days |
| B | 1 | 571 | 8 days |
| C | 1 | 1182 | 8 days |
| D | 1 | 1770 | 8 days |

**Why:** the four admissions all have the local ID 1 in their own hospital, so they would
collide without global IDs. Integration gave them four different global patients, and the
query returns all four. Only the 3,801 completed admissions count; the 199 admissions still
open (no discharge time) are correctly left out by `discharge_datetime IS NOT NULL`.

Storing times in UTC matters here: 37 stays cross a daylight-saving change. Measured on the
local wall clock they would look an hour longer or shorter (for example `4 days 23:00:00`
instead of 5 days). Because the database subtracts two UTC moments, every length is the real
time the patient spent in hospital.

## Q16: more than one type of critical care unit in one admission

**SQL:** unchanged. Critical care still means `MICU`, `SICU`, `ICU` or `CCU`.

**Result:** 4 admissions, one per hospital, each with 2 types (Phase 1: 4 admissions).

| Hospital | Admission | Unit types |
| --- | --: | --- |
| A | 4 | MICU, SICU |
| B | 954 | MICU, SICU |
| C | 1994 | MICU, SICU |
| D | 2974 | MICU, SICU |

**Why:** of the 1,403 admissions with a critical care stay, these 4 used two different unit
types. `COUNT(DISTINCT unit_type)` counts types, not stays, so an admission with two stays in
the same type would not qualify. The query groups by `admission_id`, and each admission
belongs to one hospital, so stays from two hospitals are never combined into one admission,
even for a merged patient.

## Q19: patients who died during the hospital stay

**SQL:** unchanged. "Died during the stay" still means `admission_status = 'Deceased'`.

**Result:** 48 admissions (Phase 1: 2): 11 from A, 13 from B, 12 from C, 12 from D.

**Why:** the four hospitals record more deaths, and integration kept them consistent. For
all 48 admissions:

- the patient's `life_status` is `Deceased`,
- the `date_of_death` falls between the admission and the discharge,
- the discharge record's condition is `Deceased` (trigger T4 enforces this), and
- there is exactly one Primary diagnosis, so each admission appears once.

None of the 48 belong to a merged patient. Every one of the 48 deceased patients in the
database died during one of these admissions.
