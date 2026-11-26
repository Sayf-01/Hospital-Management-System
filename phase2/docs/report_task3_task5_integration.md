# SOEN 363 Phase 2 — Task 3 Integration and Task 5 Constraints Report Sections

Author: Dany (DA-5) · November 25, 2026

Report sections for Task 3 (Integrate the Sources) and Task 5 (Constraints and Triggers),
ready to paste into the team report. All numbers come from the full frozen data, as loaded
in `hospital_phase2` (32,187 rows).

AI assistance: schema v2, the integration rules, `phase2/integrate.py`, the triggers and
these sections were drafted with AI assistance (Claude), then reviewed, tested and revised
by Dany.

---

## Task 3: Integration

### 3.1 The problem

The four hospitals each number their own records from 1. Patient 125, admission 1 and staff
member 1 exist in all four. The same person can also be a patient in two hospitals, with two
different local IDs. Integration has to:

1. give every record one ID that is unique across all hospitals,
2. merge a person who appears in two hospitals, without merging two different people, and
3. keep a link from every row back to the source record it came from.

### 3.2 Schema changes

Schema v2 (`sql/schema_v2.sql`) keeps every Phase 1 rule and adds what integration needs.
The full table, with one row per change, is in `phase2/docs/schema_changes.md`. In short:

| Change | Problem it solves |
| --- | --- |
| `source_systems` table (A, B, C, D, with hospital, continent, format and time zone) | Rows did not say which hospital they came from |
| `source_code` + `source_local_id`, unique together, on every table except `patients` and `icd9_dictionary` | Local IDs clash across hospitals; the same source record must not load twice |
| `patient_source_map` | One patient can come from several hospitals |
| `patient_match_candidates` | Uncertain matches must be kept separate but recorded |
| `quarantine_records` | Rejected records must be countable in SQL |
| Every `TIMESTAMP` → `TIMESTAMPTZ`, database set to UTC | Four time zones; times must compare as real moments |
| One shared `icd9_dictionary` | All four hospitals use the same real codes |

### 3.3 Global IDs

`phase2/integrate.py` gives each table its own IDs, 1 to N. Rows are numbered in a fixed
order: by hospital (A, B, C, D), then by local ID as a number. The same input always gives
the same IDs: running the script twice produces identical files.

Every foreign key is then translated through a lookup from `(source_code, source_local_id)`
to the new global ID, **within the same hospital**. A B unit stay that says admission 4 is
linked to B's admission 4, never to A's. If the parent is missing, the row is set aside in
quarantine with the reason `unmapped parent` instead of being loaded with a guessed link.
On the full data, no row needed this: all 32,187 rows were linked.

`diagnoses.patient_id` and `diagnostic_orders.patient_id` are taken from the admission's
patient after merging, so they always match the admission. The composite foreign key
`(admission_id, patient_id)` would reject them otherwise.

### 3.4 Patient matching

Two patient records from **different** hospitals are compared after normalizing names
(trimmed, spaces collapsed, case ignored) and insurance numbers (trimmed, case ignored).

| Rule | When | Result | Count |
| --- | --- | --- | --: |
| **M1** merge | Same first name, last name, date of birth, gender **and** insurance number | One patient; both source records in `patient_source_map` with rule `M1` | 25 patients (50 source records) |
| **U1** uncertain | Same names and date of birth, but the insurance number is missing on one side | Two patients; one row in `patient_match_candidates` | 10 pairs |
| **U2** conflict | Same insurance number, different person | Two patients; the number stays on the lower ID | 0 |
| Not a match | Anything else, including the same name and birth date with different insurance numbers | Two patients | — |

Result: **2,400 source patient records → 2,375 patients.** A patient is never merged on a
name alone, and local IDs are never compared.

**Conflicting values.** All 25 merged pairs had a different address, phone number and
emergency contact in each hospital (75 differences). The value from the hospital with the
most recent admission is kept, an empty value never overwrites a filled one, and a death
recorded by either hospital is final. Every resolved difference is logged in
`reports/patient_merge_conflicts.csv`.

### 3.5 Traceability example

Patient **4** is a patient found in two hospitals. Every integrated row can be followed back
to the line of the source file it came from:

```
patients               patient_id = 4   GivenA0004 PatientA0004, born 1947-06-14
   │
patient_source_map     A : 4    rule M1   insurance P2-A-00004
                       B : 547  rule M1   insurance P2-A-00004
   │
data/clean/patients.csv          A,4,...   (source_line 6)
                                 B,547,... (source_line 548)
   │
data/raw/full/A_patients.txt   line 6:   4|GivenA0004|PatientA0004|1947-06-14|F|P2-A-00004|...
data/raw/full/B_patients.csv   line 548: 547;GivenA0004;PatientA0004;14.06.1947;Female;P2-A-00004;...
```

The two hospitals stored the same person in two formats (`F` and `Female`, `1947-06-14` and
`14.06.1947`). Cleaning standardized them, and integration matched them on rule M1. Patient
4's address is `Synthetic address B-547`, taken from hospital B because B has the more
recent admission (July 2026). Their three admissions keep their own sources: admissions 9
and 10 come from A, and admission 1866 comes from B (local admission 916).

The same query works for any patient:

```sql
SELECT m.source_code, s.hospital_name, m.source_local_id, m.match_rule
FROM   patient_source_map m
JOIN   source_systems s ON s.source_code = m.source_code
WHERE  m.patient_id = 4;
```

### 3.6 Task 6 Query 5: duplicate source IDs were resolved

`sql/task6_query5.sql`, three parts, all read-only.

**Part 1.** Local patient ID 125 exists in all four hospitals. Each maps to a different
global patient:

| Hospital | Local ID | Global patient | Rule |
| --- | --- | --: | --- |
| A, Maple Ridge General | 125 | 125 | NEW |
| B, Rhine Valley Klinikum | 125 | 691 | NEW |
| C, Sakura Bay Medical Center | 125 | 1306 | NEW |
| D, Southern Cross Hospital | 125 | 1892 | NEW |

The counter-example is a merge: A 4 and B 547 share global patient 4, both marked `M1`.

**Part 2.** No `(source_code, source_local_id)` maps to two global IDs in any of the 14
source-tagged tables: **0 rows.**

**Part 3.** Matching counts:

| Measure | Count |
| --- | --: |
| Source patient records | 2,400 |
| Integrated patients | 2,375 |
| Patients merged across hospitals (M1) | 25 |
| Source records joined by a merge | 50 |
| Uncertain matches kept separate (U1) | 10 |
| Insurance-number conflicts (U2) | 0 |
| Local patient IDs used in all 4 hospitals | 570 |

---

## Task 5: Constraints and triggers

The database refuses bad data itself, at two levels.

### 5.1 Constraints (`sql/schema_v2.sql`)

| Kind | Where |
| --- | --- |
| Primary keys | Every table; `patient_source_map` uses `(source_code, source_local_id)` |
| Foreign keys | Every link between tables, plus `source_code → source_systems` |
| Composite foreign key | `(admission_id, patient_id)` on `diagnoses` and `diagnostic_orders`: the row's patient must be the admission's patient |
| `UNIQUE` | `(source_code, source_local_id)` on every source-tagged table; insurance number; one discharge record per admission; one radiology record per exam; one report per radiology exam |
| Partial unique index | At most one Primary diagnosis per admission |
| `NOT NULL` | Every required column, as in Phase 1 |
| `CHECK` | Allowed values for every category column; discharge after admission; unit exit after entry; pain 0–10; status `Admitted` exactly when there is no discharge time; `Deceased` exactly when a date of death is set; pairs in `patient_match_candidates` stored once, smaller ID first |

### 5.2 Triggers (`sql/triggers.sql`)

A `CHECK` can only see one row of one table. These four rules compare a row with its parent
in another table, so they are PL/pgSQL triggers. They run before every insert or update, so
the import itself is checked row by row. All 32,187 real rows passed.

| Trigger | Table | Rejects |
| --- | --- | --- |
| T1 `t1_unit_stay_in_admission` | `unit_stays` | A unit stay that starts before its admission or ends after the discharge |
| T2 `t2_examination_in_admission` | `diagnostic_examinations` | An exam (found through its order) outside its admission |
| T2 `t2_procedure_in_admission` | `surgical_procedures` | A surgery outside its admission |
| T3 `t3_report_after_examination` | `radiology_reports` | A radiology report dated before its exam |
| T4 `t4_discharge_matches_admission` | `discharge_records` | A discharge record for a patient still admitted, or a `Deceased` condition that does not match the admission status |

Each trigger raises error code 23514 (`check_violation`) and names the rejected row by its
source, so it can be traced. `sql/triggers_test.sql` tries one bad row per rule, each inside
`BEGIN; ... ROLLBACK;`. All six fail:

```
T1: unit stay A:TEST-T1 enters the unit at 2026-01-05 13:00:00+00, outside admission 1
T2: examination A:TEST-T2a at 2027-01-14 13:00:00+00 is outside admission 1 (order 1)
T2: procedure A:TEST-T2b at 2026-01-05 13:00:00+00 is outside admission 1
T3: report A:1 at 2026-01-05 13:40:00+00 is before its examination at 2026-01-06 13:40:00+00
T4: discharge record A:TEST-T4a is for admission 21, which is still Admitted
T4: discharge record A:1 says Deceased, but admission 1 is Discharged
```

### 5.3 Rules enforced another way

- **Diagnosis or order patient = admission patient:** the composite foreign key, so no trigger
  is needed.
- **Every completed admission has at least one Primary diagnosis:** checked after the import
  (YO-2 flags the admissions that have none). A row check cannot do it, because diagnoses
  are inserted after their admission, so every admission would be rejected at the moment it
  is inserted.
- **Limit:** the triggers check a child row when it is inserted or changed. Changing an
  admission's own times afterwards does not re-check its stays; in this project, admissions
  are loaded once by the import.
