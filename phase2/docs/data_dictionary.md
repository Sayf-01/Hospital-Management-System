# Phase 2 source data dictionary

Status: KR-1 review draft. Confirm these raw names and nesting paths with Lamees and Sayf before freezing samples. Target columns come from [Phase 1 schema](https://github.com/Sayf-01/Hospital-Management-System/blob/main/schema/schema.sql) (file SHA `e7c4f7ed30f7369d6c7631aad158ca12f22c5c22`). Counts and error rates below are plans, not observed results.

| Source | Hospital and continent | Raw format | Dates and units |
|---|---|---|---|
| A | Maple Ridge General, North America | UTF-8 TXT. One file per entity. First non-comment row is a header, `|` separates fields, and lines beginning with `#` are comments. One physical line per entity; generated values contain no literal pipes or line breaks. | `YYYY-MM-DD HH:MM` in America/Toronto; temperature in °F; birth date `YYYY-MM-DD`. |
| B | Rhine Valley Klinikum, Europe | CSV with UTF-8 BOM and `;` delimiter. Use CSV quoting for text containing semicolons or quotes. Keep generated values on one physical line to support malformed-line recovery. | `DD.MM.YYYY HH:MM` in Europe/Berlin; temperature in °C, decimals use comma; birth date `DD.MM.YYYY`. |
| C | Sakura Bay Medical Center, Asia | One UTF-8 XML file rooted at `<hospital>`. Sections for staff, units, ICD-9 codes, and nested patient records. Entity IDs are `id` attributes except the ICD-9 code, which is a `value` attribute. | ISO 8601 timestamps with `+09:00`; Asia/Tokyo; °C; birth date `YYYY-MM-DD`. |
| D | Southern Cross Hospital, Oceania | UTF-8 JSON. Four files, each with an array at the root. The patients file nests admissions and their child entities. | Integer Unix epoch **seconds** or day-first `DD/MM/YYYY h:mm AM/PM` in Australia/Sydney; °C; birth date `DD/MM/YYYY`. |

A uses `M/F` and ESI `1–5`. B includes German admission labels such as `Notfall` and triage `P1/P2/P3`. C uses `Red/Yellow/Green`; D uses triage `1/2/3`. The source design uses stable labels, with deliberate variants injected separately. A and B may use blanks or markers like `NULL`, `N/A`, `-` and `?`; C uses empty or absent elements; D uses JSON null or a missing key. Keep the original forms in the source files.

For D, day-first dates stay day-first even when the day and month could be swapped. Preserve the original value so the cleaning stage can log the interpretation. Epoch values represent instants and do not need a local-time interpretation. Clinical timestamps standardize to UTC later; dates of birth stay calendar dates. Keep ICD-9 codes as strings in all sources, even when deliberately omitting dots or zeros in B or D.

## Parent IDs and record counting

A and B store the parent IDs in the headers listed below. In C and D, the loader supplies the listed `source_*` fields from ancestors. These are **flattened keys**, not fields to emit in XML or JSON. All non-nesting references, such as `unitId`, staff IDs and ICD-9 codes, are explicit fields.

- Example: C patient `@id=125` → admission `@id=501` → diagnosis `@id=701` supplies `source_patient_id=125` and `source_admission_id=501` for that diagnosis. The D structure gives the same links through `patientId` and `admissionId`.
- Local IDs are source-scoped and entity-scoped; retain the source on every flattened record. Loader metadata such as `_source`, `_file` and `_line` is separate from the column renaming map. During loading, generate target primary keys (using the Phase 1 identity columns) and maintain a durable crosswalk from `(source, entity, local ID)` to target ID. Resolve every foreign key through that crosswalk rather than inserting source IDs directly; retain enough lineage to recover the source time zone for date-based reporting.
- Each entity instance is one record. XML tags and JSON containers are not extra records. For malformed A/B lines, keep a raw-row count and account for those rows in the malformed log. Never read the injection log as an input to the cleaner.

## Planned clean counts before injections

| Entity | A | B | C | D |
|---|---:|---:|---:|---:|
| `healthcare_professionals` | 48 | 52 | 49 | 52 |
| `hospital_units` | 8 | 8 | 8 | 8 |
| `icd9_dictionary` | 40 | 40 | 40 | 40 |
| `patients` | 570 | 624 | 588 | 618 |
| `admissions` | 950 | 1040 | 980 | 1030 |
| `triage_assessments` | 903 | 988 | 931 | 979 |
| `unit_stays` | 1235 | 1352 | 1274 | 1339 |
| `diagnoses` | 1425 | 1560 | 1470 | 1545 |
| `clinical_notes` | 380 | 416 | 392 | 412 |
| `discharge_records` | 903 | 988 | 931 | 979 |
| `diagnostic_orders` | 190 | 208 | 196 | 206 |
| `diagnostic_examinations` | 181 | 198 | 186 | 196 |
| `radiology_examinations` | 86 | 94 | 88 | 93 |
| `radiology_reports` | 81 | 88 | 83 | 88 |
| `surgical_procedures` | 114 | 125 | 118 | 124 |
| **Total** | 7114 | 7781 | 7334 | 7709 |

The base contract lists 7,483 records per source. The planned total after source-size variation and before injections is **29938**. Keep the 40 verified ICD-9 entries per source; variations apply to other entities. After generation, count again and report the actual per-entity and per-source totals. Enforce 5,500–9,500 per source as the team's safety band. Record duplicates added and primary diagnoses removed when reconciling the raw totals.

## Planned injection rates

Percentages refer to eligible rows, not all rows in a source. The generator should log the selected field, original value and planted value. In small samples, deliberately include examples of rare cases even when rounding a percentage would give zero. Reserve clean positive and negative examples for all 20 Phase 1 queries before injecting errors.

| Planned problem | A | B | C | D | Denominator or scope |
|---|---:|---:|---:|---:|---|
| exact duplicate admissions and diagnoses | 1% | 2% | 1% | 1% | Original rows of each of the two named entities. |
| within source duplicate patients | 2% | 2% | 2% | 2% | Original patient rows; add another local ID and retain evidence for matching. |
| missing required | 1% | 1% | 1% | 1% | Eligible rows with a populated required clinical field; exclude local IDs used to trace errors. |
| missing optional | 10% | 10% | 10% | 10% | Rows with a populated optional field; blank one eligible field. |
| case or space | 5% | 5% | 5% | 5% | Rows with an eligible populated text or category field. |
| invalid date | 1% | 1% | 1% | 1% | Rows with an eligible date or timestamp. |
| ambiguous day first | 0% | 0% | 0% | 3% | D timestamp rows eligible for a day-first string with day and month both ≤ 12; retain the intended local date. |
| invalid numeric | 1% | 1% | 1% | 1% | Rows with an eligible clinical numeric field. |
| broken reference | 0.5% | 0.75% | 0.5% | 0.75% | Rows with an eligible explicit foreign key; for nested sources use e.g. unit, staff or diagnosis-code links. |
| chronology | 1% | 1% | 1% | 1% | Rows with linked event timestamps. |
| malformed rows | 0.2% | 0.2% | 0% | 0% | Non-header, non-comment entity lines in A or B. |
| icd9 format | 0% | 5% | 0% | 5% | Diagnosis rows with an eligible code representation; record dictionary variants separately if injected. |
| missing primary | 0.5% | 0.5% | 0.5% | 0.5% | Completed admissions; remove the primary diagnosis without converting the secondary diagnosis. |

Start local IDs at 1 in each source to produce natural ID collisions. Across A↔B and C↔D combined, plan about 25 true patient matches, 10 same-name nonmatches and 10 uncertain cases. Give each true match the same designated synthetic insurance number in both sources, distinct from ordinary local insurance numbers. Merge only when that identifier, normalized first and last names, and DOB all agree. Keep same-name nonmatches separate; keep uncertain cases separate and flag them for review. Keep cases that cannot be repaired under about 5% overall, including the downstream effect of rejecting a parent.

The loader must preserve source/entity/local-ID to target-ID lineage for every loaded record, including aliases created by within-source deduplication and patient merges. Multiple source patient IDs may resolve to the same target patient ID only for a verified match. Local IDs never become target IDs directly, and all child foreign keys must be resolved through the crosswalk. Calendar-day comparisons use the UTC date of stored timestamps unless a query explicitly specifies another time zone; Q20 compares UTC calendar dates.

## Field mappings

Each row maps one Phase 1 column to four raw fields. The PostgreSQL type and required flag come from Phase 1; deliberately bad raw values can fail those expectations. For A/B/C the serialized values are text; in D the generator may use JSON numbers for integer and decimal fields, but never for ICD-9 codes. Examples show the serialized form. XML `@x` means an attribute, and `name/@first` means an attribute on a child element.

### healthcare_professionals

- **A:** `A_healthcare_professionals.txt`
- **B:** `B_healthcare_professionals.csv`
- **C:** `C_hospital.xml: /hospital/staff/professional`
- **D:** `D_staff.json: $[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `professional_id` | integer | Yes | `STAFF_ID` · `17` | `staff_no` · `17` | `@id` · `17` | `professionalId` · `17` |
| `first_name` | character varying(50) | Yes | `FNAME` · `Avelin` | `given_name` · `Avelin` | `name/@first` · `Avelin` | `firstName` · `Avelin` |
| `last_name` | character varying(50) | Yes | `LNAME` · `Testwell` | `family_name` · `Testwell` | `name/@last` · `Testwell` | `lastName` · `Testwell` |
| `role` | character varying(50) | Yes | `ROLE` · `Physician` | `role` · `Physician` | `role` · `Physician` | `role` · `Physician` |
| `specialty` | character varying(100) | No | `SPECIALTY` · `Internal Medicine` | `specialty` · `Internal Medicine` | `specialty` · `Internal Medicine` | `specialty` · `Internal Medicine` |

### hospital_units

- **A:** `A_hospital_units.txt`
- **B:** `B_hospital_units.csv`
- **C:** `C_hospital.xml: /hospital/units/unit`
- **D:** `D_units.json: $[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `unit_id` | integer | Yes | `UNIT_ID` · `8` | `unit_id` · `8` | `@id` · `8` | `unitId` · `8` |
| `unit_name` | character varying(100) | Yes | `UNIT_NAME` · `Critical Care 1` | `unit_name` · `Critical Care 1` | `unitName` · `Critical Care 1` | `unitName` · `Critical Care 1` |
| `unit_type` | character varying(50) | Yes | `UNIT_TYPE` · `ICU` | `unit_type` · `ICU` | `unitType` · `ICU` | `unitType` · `ICU` |

### icd9_dictionary

- **A:** `A_icd9_dictionary.txt`
- **B:** `B_icd9_dictionary.csv`
- **C:** `C_hospital.xml: /hospital/icd9/code`
- **D:** `D_icd9.json: $[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `icd9_code` | character varying(10) | Yes | `ICD9_CODE` · `038.9` | `icd9` · `0389` | `@value` · `038.9` | `icd9Code` · `38.9` |
| `official_title` | character varying(255) | Yes | `OFFICIAL_TITLE` · `Unspecified septicemia` | `official_title` · `Unspecified septicemia` | `officialTitle` · `Unspecified septicemia` | `officialTitle` · `Unspecified septicemia` |
| `description` | text | No | `DESCRIPTION` · `Example text` | `description` · `Example text` | `description` · `Example text` | `description` · `Example text` |
| `disease_category` | character varying(100) | No | `DISEASE_CATEGORY` · `Infectious diseases` | `disease_category` · `Infectious diseases` | `diseaseCategory` · `Infectious diseases` | `diseaseCategory` · `Infectious diseases` |

### patients

- **A:** `A_patients.txt`
- **B:** `B_patients.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient`
- **D:** `D_patients.json: $[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `patient_id` | integer | Yes | `PAT_ID` · `125` | `patient_no` · `125` | `@id` · `125` | `patientId` · `125` |
| `first_name` | character varying(50) | Yes | `FNAME` · `Avelin` | `given_name` · `Avelin` | `name/@first` · `Avelin` | `firstName` · `Avelin` |
| `last_name` | character varying(50) | Yes | `LNAME` · `Testwell` | `family_name` · `Testwell` | `name/@last` · `Testwell` | `lastName` · `Testwell` |
| `date_of_birth` | date | Yes | `DOB` · `1980-06-15` | `birth_date` · `15.06.1980` | `dateOfBirth` · `1980-06-15` | `dateOfBirth` · `15/06/1980` |
| `gender` | character varying(20) | Yes | `SEX` · `M` | `sex` · `männlich` | `gender` · `Male` | `gender` · `male` |
| `health_insurance_number` | character varying(30) | No | `HIN` · `P2-DEMO-0125` | `insurance_no` · `P2-DEMO-0125` | `healthInsuranceNumber` · `P2-DEMO-0125` | `healthInsuranceNumber` · `P2-DEMO-0125` |
| `address` | character varying(255) | No | `ADDR` · `12 Example Road` | `address` · `12 Example Road` | `address` · `12 Example Road` | `address` · `12 Example Road` |
| `phone_number` | character varying(20) | No | `PHONE_NUMBER` · `514-555-0101` | `phone_number` · `514-555-0101` | `phoneNumber` · `514-555-0101` | `phoneNumber` · `514-555-0101` |
| `emergency_contact_info` | character varying(255) | No | `EMERG_CONTACT` · `Sample contact 514-555-0102` | `emergency_contact_info` · `Sample contact 514-555-0102` | `emergencyContactInfo` · `Sample contact 514-555-0102` | `emergencyContactInfo` · `Sample contact 514-555-0102` |
| `life_status` | character varying(20) | Yes | `STATUS` · `Alive` | `life_status` · `Alive` | `lifeStatus` · `Alive` | `lifeStatus` · `Alive` |
| `date_of_death` | timestamp without time zone | No | `DOD` · `2026-05-01 09:00` | `date_of_death` · `01.05.2026 09:00` | `dateOfDeath` · `2026-05-01T09:00:00+09:00` | `dateOfDeath` · `01/05/2026 9:00 AM` |

### admissions

- **A:** `A_admissions.txt`
- **B:** `B_admissions.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission`
- **D:** `D_patients.json: $[*].admissions[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `admission_id` | integer | Yes | `ADM_ID` · `501` | `admission_no` · `501` | `@id` · `501` | `admissionId` · `501` |
| `patient_id` | integer | Yes | `PAT_ID` · `125` | `patient_no` · `125` | `source_patient_id` · from ancestor | `source_patient_id` · from ancestor |
| `admitting_professional_id` | integer | No | `ADMITTING_PROFESSIONAL_ID` · `17` | `admitting_professional_id` · `17` | `admittingProfessionalId` · `17` | `admittingProfessionalId` · `17` |
| `admission_datetime` | timestamp without time zone | Yes | `ADMIT_AT` · `2026-05-01 09:00` | `arrival_time` · `01.05.2026 09:00` | `admissionDatetime` · `2026-05-01T09:00:00+09:00` | `admissionDatetime` · `01/05/2026 9:00 AM` |
| `discharge_datetime` | timestamp without time zone | No | `DISCHARGE_AT` · `2026-05-02 09:00` | `departure_time` · `02.05.2026 09:00` | `dischargeDatetime` · `2026-05-02T09:00:00+09:00` | `dischargeDatetime` · `02/05/2026 9:00 AM` |
| `admission_type` | character varying(50) | Yes | `ADMISSION_TYPE` · `Emergency` | `admission_type` · `Notfall` | `admissionType` · `Emergency` | `admissionType` · `Emergency` |
| `admission_source` | character varying(50) | No | `ADMISSION_SOURCE` · `Emergency Department` | `admission_source` · `Emergency Department` | `admissionSource` · `Emergency Department` | `admissionSource` · `Emergency Department` |
| `reason_for_admission` | text | No | `REASON_FOR_ADMISSION` · `Example text` | `reason_for_admission` · `Example text` | `reasonForAdmission` · `Example text` | `reasonForAdmission` · `Example text` |
| `current_condition` | character varying(255) | No | `CURRENT_CONDITION` · `Example text` | `current_condition` · `Example text` | `currentCondition` · `Example text` | `currentCondition` · `Example text` |
| `insurance_info` | character varying(100) | No | `INSURANCE_INFO` · `Example text` | `insurance_info` · `Example text` | `insuranceInfo` · `Example text` | `insuranceInfo` · `Example text` |
| `admission_status` | character varying(20) | Yes | `ADMISSION_STATUS` · `Discharged` | `admission_status` · `Discharged` | `admissionStatus` · `Discharged` | `admissionStatus` · `Discharged` |

### triage_assessments

- **A:** `A_triage_assessments.txt`
- **B:** `B_triage_assessments.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/triage/assessment`
- **D:** `D_patients.json: $[*].admissions[*].triage[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `triage_id` | integer | Yes | `TRIAGE_ID` · `17` | `triage_id` · `17` | `@id` · `17` | `triageId` · `17` |
| `admission_id` | integer | Yes | `ADM_ID` · `501` | `admission_no` · `501` | `source_admission_id` · from ancestor | `source_admission_id` · from ancestor |
| `nurse_id` | integer | No | `NURSE_ID` · `17` | `nurse_id` · `17` | `nurseId` · `17` | `nurseId` · `17` |
| `assessment_datetime` | timestamp without time zone | Yes | `ASSESSMENT_DATETIME` · `2026-05-01 09:00` | `assessment_datetime` · `01.05.2026 09:00` | `assessmentDatetime` · `2026-05-01T09:00:00+09:00` | `assessmentDatetime` · `01/05/2026 9:00 AM` |
| `priority_level` | character varying(30) | Yes | `PRIORITY_LEVEL` · `1` | `priority_level` · `P1` | `priorityLevel` · `Red` | `priorityLevel` · `1` |
| `blood_pressure` | character varying(15) | No | `BLOOD_PRESSURE` · `120/80` | `blood_pressure` · `120/80` | `bloodPressure` · `120/80` | `bloodPressure` · `120/80` |
| `heart_rate` | integer | No | `HEART_RATE` · `78` | `heart_rate` · `78` | `heartRate` · `78` | `heartRate` · `78` |
| `respiratory_rate` | integer | No | `RESPIRATORY_RATE` · `18` | `respiratory_rate` · `18` | `respiratoryRate` · `18` | `respiratoryRate` · `18` |
| `body_temperature` | numeric(4,1) | No | `BODY_TEMPERATURE` · `98.6` | `body_temperature` · `37,0` | `bodyTemperature` · `37.0` | `bodyTemperature` · `37.0` |
| `oxygen_saturation` | numeric(4,1) | No | `OXYGEN_SATURATION` · `97.0` | `oxygen_saturation` · `97,0` | `oxygenSaturation` · `97.0` | `oxygenSaturation` · `97.0` |
| `pain_level` | integer | No | `PAIN_LEVEL` · `3` | `pain_level` · `3` | `painLevel` · `3` | `painLevel` · `3` |
| `reported_symptoms` | text | No | `REPORTED_SYMPTOMS` · `Example text` | `reported_symptoms` · `Example text` | `reportedSymptoms` · `Example text` | `reportedSymptoms` · `Example text` |
| `known_allergies` | text | No | `KNOWN_ALLERGIES` · `Example text` | `known_allergies` · `Example text` | `knownAllergies` · `Example text` | `knownAllergies` · `Example text` |
| `current_medications` | text | No | `CURRENT_MEDICATIONS` · `Example text` | `current_medications` · `Example text` | `currentMedications` · `Example text` | `currentMedications` · `Example text` |

### unit_stays

- **A:** `A_unit_stays.txt`
- **B:** `B_unit_stays.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/unitStays/unitStay`
- **D:** `D_patients.json: $[*].admissions[*].unitStays[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `unit_stay_id` | integer | Yes | `UNIT_STAY_ID` · `17` | `unit_stay_id` · `17` | `@id` · `17` | `unitStayId` · `17` |
| `admission_id` | integer | Yes | `ADM_ID` · `501` | `admission_no` · `501` | `source_admission_id` · from ancestor | `source_admission_id` · from ancestor |
| `unit_id` | integer | Yes | `UNIT_ID` · `8` | `unit_id` · `8` | `unitId` · `8` | `unitId` · `8` |
| `responsible_physician_id` | integer | No | `RESPONSIBLE_PHYSICIAN_ID` · `17` | `responsible_physician_id` · `17` | `responsiblePhysicianId` · `17` | `responsiblePhysicianId` · `17` |
| `ward_and_room` | character varying(50) | No | `WARD_AND_ROOM` · `Ward 2 Room 4` | `ward_and_room` · `Ward 2 Room 4` | `wardAndRoom` · `Ward 2 Room 4` | `wardAndRoom` · `Ward 2 Room 4` |
| `bed_number` | character varying(20) | No | `BED_NUMBER` · `B04` | `bed_number` · `B04` | `bedNumber` · `B04` | `bedNumber` · `B04` |
| `entry_datetime` | timestamp without time zone | Yes | `ENTRY_DATETIME` · `2026-05-01 09:00` | `entry_datetime` · `01.05.2026 09:00` | `entryDatetime` · `2026-05-01T09:00:00+09:00` | `entryDatetime` · `01/05/2026 9:00 AM` |
| `exit_datetime` | timestamp without time zone | No | `EXIT_DATETIME` · `2026-05-01 09:00` | `exit_datetime` · `01.05.2026 09:00` | `exitDatetime` · `2026-05-01T09:00:00+09:00` | `exitDatetime` · `01/05/2026 9:00 AM` |
| `reason_for_transfer` | text | No | `REASON_FOR_TRANSFER` · `Example text` | `reason_for_transfer` · `Example text` | `reasonForTransfer` · `Example text` | `reasonForTransfer` · `Example text` |

### diagnoses

- **A:** `A_diagnoses.txt`
- **B:** `B_diagnoses.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/diagnoses/diagnosis`
- **D:** `D_patients.json: $[*].admissions[*].diagnoses[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `diagnosis_id` | integer | Yes | `DIAG_ID` · `701` | `diagnosis_no` · `701` | `@id` · `701` | `diagnosisId` · `701` |
| `patient_id` | integer | Yes | `PAT_ID` · `125` | `patient_no` · `125` | `source_patient_id` · from ancestor | `source_patient_id` · from ancestor |
| `admission_id` | integer | Yes | `ADM_ID` · `501` | `admission_no` · `501` | `source_admission_id` · from ancestor | `source_admission_id` · from ancestor |
| `icd9_code` | character varying(10) | Yes | `ICD9_CODE` · `038.9` | `icd9` · `0389` | `icd9Code` · `038.9` | `icd9Code` · `38.9` |
| `diagnosing_physician_id` | integer | No | `DIAGNOSING_PHYSICIAN_ID` · `17` | `diagnosing_physician_id` · `17` | `diagnosingPhysicianId` · `17` | `diagnosingPhysicianId` · `17` |
| `diagnosis_datetime` | timestamp without time zone | Yes | `DIAGNOSIS_DATETIME` · `2026-05-01 09:00` | `diagnosis_datetime` · `01.05.2026 09:00` | `diagnosisDatetime` · `2026-05-01T09:00:00+09:00` | `diagnosisDatetime` · `01/05/2026 9:00 AM` |
| `diagnosis_type` | character varying(20) | Yes | `DIAGNOSIS_TYPE` · `Primary` | `diagnosis_type` · `Primary` | `diagnosisType` · `Primary` | `diagnosisType` · `Primary` |

### clinical_notes

- **A:** `A_clinical_notes.txt`
- **B:** `B_clinical_notes.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/clinicalNotes/note`
- **D:** `D_patients.json: $[*].admissions[*].clinicalNotes[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `note_id` | integer | Yes | `NOTE_ID` · `17` | `note_id` · `17` | `@id` · `17` | `noteId` · `17` |
| `admission_id` | integer | Yes | `ADM_ID` · `501` | `admission_no` · `501` | `source_admission_id` · from ancestor | `source_admission_id` · from ancestor |
| `author_id` | integer | Yes | `AUTHOR_ID` · `17` | `author_id` · `17` | `authorId` · `17` | `authorId` · `17` |
| `note_type` | character varying(50) | Yes | `NOTE_TYPE` · `Discharge Summary` | `note_type` · `Discharge Summary` | `noteType` · `Discharge Summary` | `noteType` · `Discharge Summary` |
| `note_datetime` | timestamp without time zone | Yes | `NOTE_DATETIME` · `2026-05-01 09:00` | `note_datetime` · `01.05.2026 09:00` | `noteDatetime` · `2026-05-01T09:00:00+09:00` | `noteDatetime` · `01/05/2026 9:00 AM` |
| `note_contents` | text | Yes | `NOTE_CONTENTS` · `Recovery discussed.` | `note_contents` · `Recovery discussed.` | `noteContents` · `Recovery discussed.` | `noteContents` · `Recovery discussed.` |

### discharge_records

- **A:** `A_discharge_records.txt`
- **B:** `B_discharge_records.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/dischargeRecords/dischargeRecord`
- **D:** `D_patients.json: $[*].admissions[*].dischargeRecords[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `discharge_id` | integer | Yes | `DISCHARGE_ID` · `17` | `discharge_id` · `17` | `@id` · `17` | `dischargeId` · `17` |
| `admission_id` | integer | Yes | `ADM_ID` · `501` | `admission_no` · `501` | `source_admission_id` · from ancestor | `source_admission_id` · from ancestor |
| `responsible_physician_id` | integer | No | `RESPONSIBLE_PHYSICIAN_ID` · `17` | `responsible_physician_id` · `17` | `responsiblePhysicianId` · `17` | `responsiblePhysicianId` · `17` |
| `discharge_destination` | character varying(100) | No | `DISCHARGE_DESTINATION` · `Home` | `discharge_destination` · `Home` | `dischargeDestination` · `Home` | `dischargeDestination` · `Home` |
| `discharge_condition` | character varying(20) | No | `DISCHARGE_CONDITION` · `Improved` | `discharge_condition` · `Improved` | `dischargeCondition` · `Improved` | `dischargeCondition` · `Improved` |
| `prescribed_medications` | text | No | `PRESCRIBED_MEDICATIONS` · `Example text` | `prescribed_medications` · `Example text` | `prescribedMedications` · `Example text` | `prescribedMedications` · `Example text` |
| `follow_up_instructions` | text | No | `FOLLOW_UP_INSTRUCTIONS` · `Example text` | `follow_up_instructions` · `Example text` | `followUpInstructions` · `Example text` | `followUpInstructions` · `Example text` |
| `follow_up_appointment_datetime` | timestamp without time zone | No | `FOLLOW_UP_APPOINTMENT_DATETIME` · `2026-05-01 09:00` | `follow_up_appointment_datetime` · `01.05.2026 09:00` | `followUpAppointmentDatetime` · `2026-05-01T09:00:00+09:00` | `followUpAppointmentDatetime` · `01/05/2026 9:00 AM` |

### diagnostic_orders

- **A:** `A_diagnostic_orders.txt`
- **B:** `B_diagnostic_orders.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/orders/order`
- **D:** `D_patients.json: $[*].admissions[*].orders[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `order_id` | integer | Yes | `ORDER_ID` · `101` | `order_id` · `101` | `@id` · `101` | `orderId` · `101` |
| `patient_id` | integer | Yes | `PAT_ID` · `125` | `patient_no` · `125` | `source_patient_id` · from ancestor | `source_patient_id` · from ancestor |
| `admission_id` | integer | Yes | `ADM_ID` · `501` | `admission_no` · `501` | `source_admission_id` · from ancestor | `source_admission_id` · from ancestor |
| `ordering_physician_id` | integer | Yes | `ORDERING_PHYSICIAN_ID` · `17` | `ordering_physician_id` · `17` | `orderingPhysicianId` · `17` | `orderingPhysicianId` · `17` |
| `order_datetime` | timestamp without time zone | Yes | `ORDER_DATETIME` · `2026-05-01 09:00` | `order_datetime` · `01.05.2026 09:00` | `orderDatetime` · `2026-05-01T09:00:00+09:00` | `orderDatetime` · `01/05/2026 9:00 AM` |
| `requested_examination` | character varying(100) | Yes | `REQUESTED_EXAMINATION` · `Chest X-ray` | `requested_examination` · `Chest X-ray` | `requestedExamination` · `Chest X-ray` | `requestedExamination` · `Chest X-ray` |
| `clinical_reason` | text | No | `CLINICAL_REASON` · `Example text` | `clinical_reason` · `Example text` | `clinicalReason` · `Example text` | `clinicalReason` · `Example text` |
| `priority` | character varying(20) | No | `PRIORITY` · `Routine` | `priority` · `Routine` | `priority` · `Routine` | `priority` · `Routine` |
| `order_status` | character varying(20) | No | `ORDER_STATUS` · `Completed` | `order_status` · `Completed` | `orderStatus` · `Completed` | `orderStatus` · `Completed` |

### diagnostic_examinations

- **A:** `A_diagnostic_examinations.txt`
- **B:** `B_diagnostic_examinations.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/orders/order/exams/exam`
- **D:** `D_patients.json: $[*].admissions[*].orders[*].exams[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `examination_id` | integer | Yes | `EXAMINATION_ID` · `201` | `examination_id` · `201` | `@id` · `201` | `examinationId` · `201` |
| `order_id` | integer | Yes | `ORDER_ID` · `101` | `order_id` · `101` | `source_order_id` · from ancestor | `source_order_id` · from ancestor |
| `performed_by_id` | integer | No | `PERFORMED_BY_ID` · `17` | `performed_by_id` · `17` | `performedById` · `17` | `performedById` · `17` |
| `examination_type` | character varying(100) | Yes | `EXAMINATION_TYPE` · `Chest X-ray` | `examination_type` · `Chest X-ray` | `examinationType` · `Chest X-ray` | `examinationType` · `Chest X-ray` |
| `examination_datetime` | timestamp without time zone | Yes | `EXAMINATION_DATETIME` · `2026-05-01 09:00` | `examination_datetime` · `01.05.2026 09:00` | `examinationDatetime` · `2026-05-01T09:00:00+09:00` | `examinationDatetime` · `01/05/2026 9:00 AM` |
| `examination_status` | character varying(20) | No | `EXAMINATION_STATUS` · `Completed` | `examination_status` · `Completed` | `examinationStatus` · `Completed` | `examinationStatus` · `Completed` |
| `result_summary` | text | No | `RESULT_SUMMARY` · `Example text` | `result_summary` · `Example text` | `resultSummary` · `Example text` | `resultSummary` · `Example text` |

### radiology_examinations

- **A:** `A_radiology_examinations.txt`
- **B:** `B_radiology_examinations.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/orders/order/exams/exam/radiology/radiologyExam`
- **D:** `D_patients.json: $[*].admissions[*].orders[*].exams[*].radiology[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `radiology_id` | integer | Yes | `RADIOLOGY_ID` · `301` | `radiology_id` · `301` | `@id` · `301` | `radiologyId` · `301` |
| `examination_id` | integer | Yes | `EXAMINATION_ID` · `201` | `examination_id` · `201` | `source_examination_id` · from ancestor | `source_examination_id` · from ancestor |
| `referring_physician_id` | integer | No | `REFERRING_PHYSICIAN_ID` · `17` | `referring_physician_id` · `17` | `referringPhysicianId` · `17` | `referringPhysicianId` · `17` |
| `technician_id` | integer | No | `TECHNICIAN_ID` · `17` | `technician_id` · `17` | `technicianId` · `17` | `technicianId` · `17` |
| `body_area` | character varying(50) | No | `BODY_AREA` · `Chest` | `body_area` · `Chest` | `bodyArea` · `Chest` | `bodyArea` · `Chest` |
| `image_link` | character varying(255) | No | `IMAGE_LINK` · `https://images.example/exam-201` | `image_link` · `https://images.example/exam-201` | `imageLink` · `https://images.example/exam-201` | `imageLink` · `https://images.example/exam-201` |

### radiology_reports

- **A:** `A_radiology_reports.txt`
- **B:** `B_radiology_reports.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/orders/order/exams/exam/radiology/radiologyExam/reports/report`
- **D:** `D_patients.json: $[*].admissions[*].orders[*].exams[*].radiology[*].reports[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `report_id` | integer | Yes | `REPORT_ID` · `17` | `report_id` · `17` | `@id` · `17` | `reportId` · `17` |
| `radiology_id` | integer | Yes | `RADIOLOGY_ID` · `301` | `radiology_id` · `301` | `source_radiology_id` · from ancestor | `source_radiology_id` · from ancestor |
| `radiologist_id` | integer | Yes | `RADIOLOGIST_ID` · `17` | `radiologist_id` · `17` | `radiologistId` · `17` | `radiologistId` · `17` |
| `report_datetime` | timestamp without time zone | Yes | `REPORT_DATETIME` · `2026-05-01 09:00` | `report_datetime` · `01.05.2026 09:00` | `reportDatetime` · `2026-05-01T09:00:00+09:00` | `reportDatetime` · `01/05/2026 9:00 AM` |
| `findings` | text | No | `FINDINGS` · `Example text` | `findings` · `Example text` | `findings` · `Example text` | `findings` · `Example text` |
| `impression` | text | No | `IMPRESSION` · `Example text` | `impression` · `Example text` | `impression` · `Example text` | `impression` · `Example text` |

### surgical_procedures

- **A:** `A_surgical_procedures.txt`
- **B:** `B_surgical_procedures.csv`
- **C:** `C_hospital.xml: /hospital/patients/patient/admissions/admission/procedures/procedure`
- **D:** `D_patients.json: $[*].admissions[*].procedures[*]`

| Phase 1 column | Type | Required | A field · example | B field · example | C field · example | D field · example |
|---|---|---|---|---|---|---|
| `procedure_id` | integer | Yes | `PROCEDURE_ID` · `17` | `procedure_id` · `17` | `@id` · `17` | `procedureId` · `17` |
| `admission_id` | integer | Yes | `ADM_ID` · `501` | `admission_no` · `501` | `source_admission_id` · from ancestor | `source_admission_id` · from ancestor |
| `surgeon_id` | integer | Yes | `SURGEON_ID` · `17` | `surgeon_id` · `17` | `surgeonId` · `17` | `surgeonId` · `17` |
| `procedure_name` | character varying(150) | Yes | `PROCEDURE_NAME` · `Example procedure` | `procedure_name` · `Example procedure` | `procedureName` · `Example procedure` | `procedureName` · `Example procedure` |
| `procedure_datetime` | timestamp without time zone | Yes | `PROCEDURE_DATETIME` · `2026-05-01 09:00` | `procedure_datetime` · `01.05.2026 09:00` | `procedureDatetime` · `2026-05-01T09:00:00+09:00` | `procedureDatetime` · `01/05/2026 9:00 AM` |
| `operating_room` | character varying(20) | No | `OPERATING_ROOM` · `OR-2` | `operating_room` · `OR-2` | `operatingRoom` · `OR-2` | `operatingRoom` · `OR-2` |
| `procedure_notes` | text | No | `PROCEDURE_NOTES` · `Example text` | `procedure_notes` · `Example text` | `procedureNotes` · `Example text` | `procedureNotes` · `Example text` |
