# Integration rules: global IDs and patient matching

**Status:** DA-2 draft for review by Sayf and Youssef.
**Applies to:** `integrate.py` (DA-3), which turns the checked files into tables for [`sql/schema_v2.sql`](../../sql/schema_v2.sql).
**Input:** cleaned records, each tagged with `source_code` and `source_local_id`. Within-source duplicate patients are already merged by cleaning (see `reports/patient_id_remap.csv`), so these rules handle only what happens *across* sources.

## 1. Global IDs

1. `integrate.py` assigns every table its own IDs `1..N`.
2. Rows are numbered in a fixed order: by `source_code` (A, B, C, D), then by `source_local_id` as a number. If a local ID is not a number, it sorts after the numeric ones, as text.
3. The same input therefore always gets the same IDs, so two runs produce identical files.
4. The IDs are written explicitly into the CSVs. After import, each identity sequence must be moved past the largest ID (`setval`), or the next normal `INSERT` fails with a duplicate key. Youssef's import does this.
5. A merged patient (rule M1) takes the ID of its first source record in that order. The later source records point to the same ID through `patient_source_map`.

## 2. What is merged across hospitals

Only **patients** can be merged. Staff, units, admissions and every clinical record keep one global ID per source record, even when two hospitals use the same name or number. For example, unit "ICU 1" in A and "ICU 1" in B are two different units.

The ICD-9 dictionary is the exception the other way round: it is shared, not per source (see section 6).

## 3. Patient matching

Two patient records from **different** sources are compared on normalized values:

- **Names:** trimmed, internal spaces collapsed, case-folded (`" Ana  LOPEZ"` → `ana lopez`).
- **Insurance number:** trimmed and case-folded, punctuation kept.
- **Date of birth:** the cleaned calendar date.

| Rule | When | What happens |
|---|---|---|
| **M1: merge** | Same first name, last name, date of birth, gender **and** insurance number, all present | One integrated patient. Each source record goes into `patient_source_map` with `match_rule = 'M1'`. |
| **U1: uncertain** | Same first name, last name and date of birth, but the insurance number is missing on at least one side | Kept as separate patients. One row in `patient_match_candidates` with `match_rule = 'U1'`. |
| **U2: insurance conflict** | Same insurance number, but the first name, last name, date of birth or gender differ | Kept as separate patients. One row in `patient_match_candidates` with `match_rule = 'U2'`. The number stays on the patient with the lower global ID; on the other it is `NULL` in `patients`, so the `UNIQUE` constraint holds. The original number is still kept in `patient_source_map.source_insurance_number`. |
| Not a match | Anything else, including the same name and birth date with two **different** insurance numbers | Separate patients, no candidate row. |

Every patient record that is not merged goes into `patient_source_map` with `match_rule = 'NEW'`.

**Never merge on name alone, or on name and date of birth alone.** Fuzzy matching (similar spellings) is not used; a near-match is at most a U1 candidate.

The M1 key matches the cross-source rule in `cleaning_rules.md` and Krish's `data_dictionary.md` (designated shared insurance number + names + date of birth). Gender is added to the key so that a merge never has to choose between two genders.

### Examples

- **Patient 125 in A and patient 125 in B:** two different people with two different insurance numbers (`P2-A-00125`, `P2-B-00125`). Local IDs are never compared, so they become two global patients, each with one `NEW` row in the map.
- **M1:** A 23 and B 7 are both `GivenA0023 PatientA0023`, male, born 1974-03-25, insurance `P2-A-00023`. They become one patient with two map rows, both `M1`.
- **U1:** A 2 and B 19 are both `GivenA0002 PatientA0002`, male, born 1943-03-15, but neither has an insurance number. Two patients, plus one candidate row explaining why.

In Sayf's cleaned sample this gives 4 M1 merges (A 23 + B 7, A 40 + B 15, C 14 + D 34, C 21 + D 24), 2 U1 candidates (A 2 / B 19, C 5 / D 21) and no U2 conflicts.

## 4. Conflicting values when merging

When an M1 merge finds different values for the same field:

1. Keep the value from the source with the **most recent admission** for that patient. If both latest admissions start at the same moment, keep the value from the earlier source code (A before B, and so on).
2. An empty value never overwrites a filled one: if only one source has a phone number, keep it.
3. **Life status:** if one source records a death, the patient is `Deceased` with that source's `date_of_death`, since a death recorded by any hospital is final.
4. Every overridden value is logged with both sources so it can be shown in the report.

## 5. Re-linking foreign keys

1. For each entity, `integrate.py` builds a lookup `{(source_code, source_local_id): global_id}`. Patients use `patient_source_map` as their lookup.
2. Every parent link in a child row goes through the lookup of the parent's entity, **within the same source**. For example, a B unit stay's `source_admission_id = 4` looks up `('B', '4')` in the admissions lookup.
3. If a lookup fails, the parent is missing. Youssef's checks should already have caught this; if not, the row goes to `quarantine_records` with `stage = 'integrate'` and reason `unmapped parent`. A row is never loaded with a guessed or empty required parent.
4. `diagnoses.patient_id` and `diagnostic_orders.patient_id` are **taken from the admission's patient after merging**, not looked up separately. That way "diagnosis patient = admission patient" always holds, and the composite foreign key accepts the row.

## 6. ICD-9 dictionary

1. The four cleaned dictionaries are combined into one table, keyed by the dotted code (after Sayf's format fix, `0389` and `38.9` both become `038.9`).
2. If two sources give different titles for the same code, keep the CMS official title.
3. A `description` or `disease_category` that is empty in one source is filled from another source when one has it.

## 7. Source systems

`integrate.py` writes these four rows first, from the data dictionary:

| `source_code` | `hospital_name` | `continent` | `file_format` | `time_zone` |
|---|---|---|---|---|
| A | Maple Ridge General | North America | TXT | America/Toronto |
| B | Rhine Valley Klinikum | Europe | CSV | Europe/Berlin |
| C | Sakura Bay Medical Center | Asia | XML | Asia/Tokyo |
| D | Southern Cross Hospital | Oceania | JSON | Australia/Sydney |

## 8. Times

Cleaning outputs UTC times without an offset (`2026-01-06 13:00:00`). Schema v2 stores them as `TIMESTAMPTZ`, and the database is set to UTC, so they import as the right moment. To be safe with any client, `integrate.py` writes them with an explicit `+00:00`.

## 9. Traceability

Any integrated row can be traced back to its source record:

- **Clinical rows, staff and units:** `source_code` + `source_local_id` on the row itself.
- **Patients:** `patient_source_map` lists every source record behind the patient.
- **The original line:** the cleaning log and `quarantine_records` keep the source file line.

Example query for one patient:

```sql
SELECT m.source_code, s.hospital_name, m.source_local_id, m.match_rule
FROM   patient_source_map m
JOIN   source_systems s ON s.source_code = m.source_code
WHERE  m.patient_id = 3;
```
