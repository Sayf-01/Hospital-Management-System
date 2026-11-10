# Cleaning rules

**Status:** rules draft for Dany and Youssef to review.
**Schema authority:** Phase 1 [`schema/schema.sql`](../../schema/schema.sql). A field is required exactly when its Phase 1 column is `NOT NULL`.

## Rules shared by all entities

| Topic | Rule |
|---|---|
| Missing values | Convert `""`, whitespace-only text, `NULL`, `null`, `N/A`, `NA`, `-`, `?`, `none`, JSON `null`, missing JSON keys and empty XML elements to `NULL`. Match text markers after trimming and case-folding. |
| Correction | Correct only deterministic formatting or unit differences. Preserve the original value in the cleaning log. Never guess or synthesize values. |
| Bad required value | Quarantine the record and flag the field if missing, invalid, unknown, or not safely repairable. |
| Bad optional value | Keep the record, set the field to `NULL`, and flag it. Exceptions where that would violate a Phase 1 cross-field `CHECK` are stated below. |
| Strings | Trim leading/trailing whitespace. Preserve meaningful spelling, case, punctuation, and internal whitespace. Do not truncate overlength values: quarantine a record with an overlength required value; null and flag an overlength optional value. |
| References | Validate IDs within their source and entity. A broken required reference quarantines the child record; a broken optional reference becomes `NULL` and is flagged. If a parent is quarantined, apply the same rule to children whose required parent reference no longer resolves. |
| Timestamps | Convert source-local times to UTC, then store the UTC wall time in the Phase 1 `timestamp without time zone` column. A timestamp with an explicit offset is converted from that offset. If a local timestamp falls in a daylight-saving gap or repeated hour and has no offset or other certain disambiguating evidence, treat it as invalid. Retain each record's source in the load crosswalk so source-local dates can be reconstructed when required. |
| Dates of birth | Keep as calendar dates; do not apply a time zone. |
| D ambiguous dates | Parse D strings day-first as specified by its contract. If both day and month are at most 12, retain that day-first interpretation and flag it as an assumption. If one component exceeds 12, the interpretation is unambiguous. |
| A/B malformed rows | Quarantine and log a row whose field count is wrong or whose CSV quoting cannot be parsed; do not shift columns or infer missing fields. |
| Exact duplicate rows | After trimming each field, keep one identical row and log each removed copy. Compare all fields; do not merge merely similar rows. |
| Duplicate patients within a source | Match on cleaned first name, last name, DOB and insurance number. For names, collapse whitespace and case-fold; for insurance, trim and case-fold while preserving punctuation. Keep the lowest local patient ID, log `old ID → kept ID`, and repoint child records. Do not merge when insurance is missing. |
| IDs across sources | Source IDs are source- and entity-scoped; never insert them directly as target primary keys. Let the database generate target IDs and maintain a durable crosswalk keyed by `(source, entity, source ID)` to the target ID. Resolve every foreign key through this crosswalk. Multiple source patient keys may point to one target patient only for a verified cross-source match. Never link records merely because local IDs match. |
| Cross-source patient matching | Merge only when the cleaned first name, last name, DOB, and an explicitly designated shared synthetic insurance number all match. Normalize names by collapsing whitespace and case-folding; normalize the insurance number by trimming and case-folding while preserving punctuation. Do not merge on a local insurance number, name, or DOB alone. Keep uncertain candidates as separate patients and flag them for review; do not use fuzzy matching. |
| Calendar-day queries | Because Phase 1 stores timestamps as UTC wall time, calendar-day comparisons use the UTC date unless a query explicitly specifies another time zone. Q20 therefore compares UTC calendar dates; do not convert timestamps back to source-local time implicitly. |
| Missing primary diagnosis | Keep the admission and its remaining diagnoses; flag the missing primary diagnosis. Never promote a secondary diagnosis or invent a primary diagnosis. |
| ICD-9 formatting | Keep codes as text. Restore dots/leading zeros only when the cleaned digits match exactly one canonical code in the verified dictionary. Otherwise quarantine a diagnosis with an invalid/missing code; do not guess. |

## Source date and time conventions

| Source | Timestamp representation | Time zone | Date of birth | Additional handling |
|---|---|---|---|---|
| A | `YYYY-MM-DD HH:MM` | `America/Toronto` | `YYYY-MM-DD` | Local time has no embedded zone. Convert °F temperatures to °C. |
| B | `DD.MM.YYYY HH:MM` | `Europe/Berlin` | `DD.MM.YYYY` | Local time has no embedded zone. Parse decimal commas. |
| C | ISO 8601 with `+09:00` | `Asia/Tokyo` | `YYYY-MM-DD` | Convert from the explicit offset. |
| D | Unix epoch seconds or `DD/MM/YYYY h:mm AM/PM` | `Australia/Sydney` | `DD/MM/YYYY` | Epochs are instants; convert directly to UTC. Parse strings day-first; apply the ambiguity flag above. |

## Numeric and chronology rules

| Field | Valid value |
|---|---|
| `heart_rate` | Integer 20–250 beats/minute, inclusive. |
| `respiratory_rate` | Integer 4–60 breaths/minute, inclusive. |
| `body_temperature` | 30.0–45.0 °C, inclusive, after converting A's °F; round to one decimal place. |
| `oxygen_saturation` | 50.0–100.0%, inclusive. |
| `pain_level` | Integer 0–10, inclusive, matching the Phase 1 check. |
| `blood_pressure` | Systolic/diastolic integer text such as `120/80`; validate syntax only, without adding unprovided clinical cutoffs. |

Invalid optional numeric measurements become `NULL` and are flagged independently; one invalid vital sign does not reject its triage record. An invalid required numeric value quarantines its record. When a timestamp ordering is impossible and cannot be corrected from source evidence, quarantine the record if it affects a required timestamp; otherwise null and flag the optional timestamp.

The Phase 1 schema also enforces two paired-value rules. If a patient's `life_status` and `date_of_death` conflict, or an admission's `admission_status` and `discharge_datetime` conflict, quarantine the affected patient/admission when no certain correction is available. In particular, do not null an optional timestamp if doing so would make the record violate a Phase 1 `CHECK`; do not infer a replacement status or date.

## Category values observed in the samples

The source-specific labels below map to the Phase 1 value shown. `value_maps.py` applies trimming and case-insensitive matching, so the whitespace/capitalization variants listed separately remain explicit and supported. The maps include every value permitted by the Phase 1 category constraints, even when a value is not present in the samples. Any other category label is unknown: quarantine if required; otherwise set `NULL` and flag.

| Field | Source A raw → Phase 1 | Source B raw → Phase 1 | Source C raw → Phase 1 | Source D raw → Phase 1 |
|---|---|---|---|---|
| `admission_type` | `Emergency` → Emergency; `Urgent`, ` URGENT ` → Urgent; `Elective`, ` ELECTIVE ` → Elective; `Outpatient`, ` OUTPATIENT ` → Outpatient; `Newborn` → Newborn | `Notfall`, ` NOTFALL ` → Emergency; `Dringend`, ` DRINGEND ` → Urgent; `Geplant`, ` GEPLANT ` → Elective; `Ambulant` → Outpatient; `Newborn` → Newborn | `Emergency`, `EMERGENCY` → Emergency; `Urgent`, `URGENT` → Urgent; `Elective`, `ELECTIVE` → Elective; `Outpatient` → Outpatient; `Newborn` → Newborn | `Emergency`, ` EMERGENCY ` → Emergency; `Urgent`, ` URGENT ` → Urgent; `Elective` → Elective; `Outpatient` → Outpatient; `Newborn` → Newborn |
| `admission_source` | `Emergency Department`, `Referral`, `Transfer from Another Hospital`, `Walk-in`, `Other` map to themselves | Same labels and targets as A | Same labels and targets as A | Same labels and targets as A |
| `admission_status` | `Admitted`, `Discharged`, `Deceased` map to themselves | Same labels and targets as A | Same labels and targets as A | Same labels and targets as A |
| `priority_level` | ESI `1`, `2` → High-Priority Emergency; `3` → Urgent; `4`, `5` → Non-Urgent | `P1` → High-Priority Emergency; `P2` → Urgent; `P3` → Non-Urgent | `Red` → High-Priority Emergency; `Yellow` → Urgent; `Green` → Non-Urgent | `1` → High-Priority Emergency; `2` → Urgent; `3` → Non-Urgent |
| `gender` | `M` → Male; `F` → Female | `Male` → Male; `Female` → Female | Same labels and targets as B | Same labels and targets as B |
| `unit_type` | `Emergency`, `General Ward`, `MICU`, `SICU`, `ICU`, `CCU`, `Other` map to themselves | Same labels and targets as A | Same labels and targets as A | Same labels and targets as A |
| `diagnosis_type` | `Primary`, `Secondary`, `Preliminary` map to themselves | Same labels and targets as A | Same labels and targets as A | Same labels and targets as A |
| `note_type` | `Initial Assessment`, `Progress Note`, `Discharge Summary` map to themselves | Same labels and targets as A | Same labels and targets as A | Same labels and targets as A |
| `discharge_condition` | `Improved`, `Stable`, `Unchanged`, `Deteriorated`, `Deceased` map to themselves | Same labels and targets as A | Same labels and targets as A | Same labels and targets as A |
| `role` | `Physician`, `Surgeon`, `Nurse`, `Radiologist`, `Technician` map to themselves | Same labels and targets as A | Same labels and targets as A | Same labels and targets as A |
| `life_status` | `Alive`, `Deceased` map to themselves | Same labels and targets as A | Same labels and targets as A | Same labels and targets as A |

## Entity field rules

### `healthcare_professionals`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `professional_id` | Yes | A `STAFF_ID`; B `staff_no`; C `@id`; D `professionalId` | Parse as integer; unique within source/entity. | Quarantine and flag. |
| `first_name` | Yes | A `FNAME`; B `given_name`; C `name/@first`; D `firstName` | Trim; preserve spelling and case. | Quarantine and flag. |
| `last_name` | Yes | A `LNAME`; B `family_name`; C `name/@last`; D `lastName` | Trim; preserve spelling and case. | Quarantine and flag. |
| `role` | Yes | A-D `ROLE`/`role`; labels include `Physician`, `Nurse`, `Technician` | Map using the role values above. | Quarantine if unknown; flag. |
| `specialty` | No | A-D `SPECIALTY`/`specialty`; e.g. `Internal Medicine` | Trim and preserve text. | `NULL`; keep and flag. |

### `hospital_units`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `unit_id` | Yes | A `UNIT_ID`; B `unit_id`; C `@id`; D `unitId` | Parse as integer; unique within source/entity. | Quarantine and flag. |
| `unit_name` | Yes | A `UNIT_NAME`; B-D `unitName`/`unit_name`; e.g. `Critical Care 1` | Trim; preserve name. | Quarantine and flag. |
| `unit_type` | Yes | A-D `UNIT_TYPE`/`unitType`; e.g. `ICU`, `General Ward` | Map using the unit-type values above. | Quarantine if unknown; flag. |

### `icd9_dictionary`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `icd9_code` | Yes | A `ICD9_CODE`; B `icd9` (e.g. `0389`); C `@value`; D `icd9Code` (e.g. `38.9`) | Keep text; normalize punctuation/leading zero only on a unique verified-code match. | Quarantine if missing, invalid, or ambiguous; flag. |
| `official_title` | Yes | A `OFFICIAL_TITLE`; B-D `officialTitle`/`official_title` | Trim; preserve title. | Quarantine and flag. |
| `description` | No | A-D `DESCRIPTION`/`description`; free text | Trim; preserve text. | `NULL`; keep and flag. |
| `disease_category` | No | A-D `DISEASE_CATEGORY`/`diseaseCategory` | Trim; preserve text. | `NULL`; keep and flag. |

### `patients`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `patient_id` | Yes | A `PAT_ID`; B `patient_no`; C `@id`; D `patientId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `first_name` | Yes | A `FNAME`; B `given_name`; C `name/@first`; D `firstName` | Trim; preserve display spelling. Case-fold only for within-source duplicate matching. | Quarantine and flag. |
| `last_name` | Yes | A `LNAME`; B `family_name`; C `name/@last`; D `lastName` | Trim; preserve display spelling. Case-fold only for within-source duplicate matching. | Quarantine and flag. |
| `date_of_birth` | Yes | A/C ISO date; B `DD.MM.YYYY`; D `DD/MM/YYYY` | Parse a valid calendar date; for D use day-first and flag ambiguous cases. | Quarantine and flag. |
| `gender` | Yes | A `SEX`=`M/F`; B `sex`; C/D `gender`=`Male/Female` | Map to `Male` or `Female` using the category table. | Quarantine if unknown; flag. |
| `health_insurance_number` | No | A `HIN`; B `insurance_no`; C/D `healthInsuranceNumber` | Trim; retain as text. Used for duplicate matching only when present. | `NULL`; keep and flag. |
| `address` | No | A `ADDR`; B-D `address` | Trim; preserve text. | `NULL`; keep and flag. |
| `phone_number` | No | A `PHONE_NUMBER`; B `phone_number`; C/D `phoneNumber` | Trim; preserve as text, including punctuation. | `NULL`; keep and flag. |
| `emergency_contact_info` | No | A `EMERG_CONTACT`; B-D `emergency_contact_info`/`emergencyContactInfo` | Trim; preserve text. | `NULL`; keep and flag. |
| `life_status` | Yes | A `STATUS`; B-D `life_status`/`lifeStatus`; `Alive`/`Deceased` | Map using the category table; validate against `date_of_death`. | Quarantine if unknown or inconsistent with death date; flag. |
| `date_of_death` | No | A `DOD`; B-D `date_of_death`/`dateOfDeath`; source timestamp format | Parse/convert as a timestamp; must be present only when required by the Phase 1 status check. | `NULL` if invalid and status is `Alive`; otherwise quarantine if null would violate the check. |

### `admissions`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `admission_id` | Yes | A `ADM_ID`; B `admission_no`; C `@id`; D `admissionId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `patient_id` | Yes | A `PAT_ID`; B `patient_no`; C/D inherited `source_patient_id` | Parse as integer and resolve to a patient in the same source. | Quarantine if missing or broken; flag. |
| `admitting_professional_id` | No | A `ADMITTING_PROFESSIONAL_ID`; B `admitting_professional_id`; C/D `admittingProfessionalId` | Parse and resolve within source when present. | `NULL` if invalid/broken; keep and flag. |
| `admission_datetime` | Yes | A ISO local; B German day-first; C ISO `+09:00`; D epoch seconds or day-first string | Parse, apply source time zone/offset, convert to UTC. | Quarantine and flag. |
| `discharge_datetime` | No | A `DISCHARGE_AT`; B `departure_time`; C/D `dischargeDatetime`; may be absent for open admissions | Parse and convert; must be later than admission time and consistent with status. | `NULL` and keep when allowed (e.g. open admission); otherwise quarantine if invalidity violates a Phase 1 check. |
| `admission_type` | Yes | A-D `ADMISSION_TYPE`/`admissionType`; includes German labels and case/space variants | Map using the category table. | Quarantine if unknown; flag. |
| `admission_source` | No | A-D `ADMISSION_SOURCE`/`admissionSource`; samples show `Emergency Department`, `Referral` | Map using the category table. | `NULL`; keep and flag if unknown. |
| `reason_for_admission` | No | A-D `REASON_FOR_ADMISSION`/`reasonForAdmission`; free text | Trim; preserve text. | `NULL`; keep and flag. |
| `current_condition` | No | A-D `CURRENT_CONDITION`/`currentCondition` | Trim; preserve text. | `NULL`; keep and flag. |
| `insurance_info` | No | A-D `INSURANCE_INFO`/`insuranceInfo` | Trim; preserve text. | `NULL`; keep and flag. |
| `admission_status` | Yes | A-D `ADMISSION_STATUS`/`admissionStatus`; `Admitted`, `Discharged`, `Deceased` | Map using the category table; enforce status/discharge-time check. | Quarantine if unknown or inconsistent and not certainly repairable; flag. |

### `triage_assessments`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `triage_id` | Yes | A `TRIAGE_ID`; B `triage_id`; C `@id`; D `triageId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `admission_id` | Yes | A `ADM_ID`; B `admission_no`; C/D inherited `source_admission_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `nurse_id` | No | A `NURSE_ID`; B `nurse_id`; C/D `nurseId` | Parse and resolve within source when present. | `NULL` if invalid/broken; keep and flag. |
| `assessment_datetime` | Yes | A local ISO; B day-first; C offset ISO; D epoch/string | Convert to UTC. | Quarantine and flag. |
| `priority_level` | Yes | A ESI `1–5`; B `P1–P3`; C colours; D `1–3` | Map using the triage scale in the category table. | Quarantine if unknown; flag. |
| `blood_pressure` | No | A-D `BLOOD_PRESSURE`/`bloodPressure`; e.g. `120/80` | Require systolic/diastolic integer syntax only. | `NULL` if invalid; keep and flag. |
| `heart_rate` | No | A-D `HEART_RATE`/`heartRate`; integer | Integer 20–250 inclusive. | `NULL` if invalid/out of range; keep and flag. |
| `respiratory_rate` | No | A-D `RESPIRATORY_RATE`/`respiratoryRate`; integer | Integer 4–60 inclusive. | `NULL` if invalid/out of range; keep and flag. |
| `body_temperature` | No | A °F; B decimal comma °C; C/D °C | Convert A to °C; decimal-comma parse B; accept 30.0–45.0 °C inclusive; round to 0.1. | `NULL` if invalid/out of range; keep and flag. |
| `oxygen_saturation` | No | A-D `OXYGEN_SATURATION`/`oxygenSaturation`; percent | Accept 50.0–100.0 inclusive. | `NULL` if invalid/out of range; keep and flag. |
| `pain_level` | No | A-D `PAIN_LEVEL`/`painLevel`; integer | Integer 0–10 inclusive. | `NULL` if invalid/out of range; keep and flag. |
| `reported_symptoms` | No | A-D `REPORTED_SYMPTOMS`/`reportedSymptoms`; free text | Trim; preserve text. | `NULL`; keep and flag. |
| `known_allergies` | No | A-D `KNOWN_ALLERGIES`/`knownAllergies`; free text | Trim; preserve text. | `NULL`; keep and flag. |
| `current_medications` | No | A-D `CURRENT_MEDICATIONS`/`currentMedications`; free text | Trim; preserve text. | `NULL`; keep and flag. |

### `unit_stays`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `unit_stay_id` | Yes | A `UNIT_STAY_ID`; B `unit_stay_id`; C `@id`; D `unitStayId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `admission_id` | Yes | A `ADM_ID`; B `admission_no`; C/D inherited `source_admission_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `unit_id` | Yes | A `UNIT_ID`; B `unit_id`; C/D `unitId` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `responsible_physician_id` | No | A-D `RESPONSIBLE_PHYSICIAN_ID`/`responsiblePhysicianId` | Parse and resolve within source when present. | `NULL` if invalid/broken; keep and flag. |
| `ward_and_room` | No | A-D `WARD_AND_ROOM`/`wardAndRoom` | Trim; preserve text. | `NULL`; keep and flag. |
| `bed_number` | No | A-D `BED_NUMBER`/`bedNumber` | Trim; preserve as text. | `NULL`; keep and flag. |
| `entry_datetime` | Yes | A local ISO; B day-first; C offset ISO; D epoch/string | Convert to UTC. | Quarantine and flag. |
| `exit_datetime` | No | A-D `EXIT_DATETIME`/`exitDatetime`; may be absent for an open stay | Convert to UTC; if present it must be later than entry. | `NULL` if invalid/out of order; keep and flag. |
| `reason_for_transfer` | No | A-D `REASON_FOR_TRANSFER`/`reasonForTransfer`; free text | Trim; preserve text. | `NULL`; keep and flag. |

### `diagnoses`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `diagnosis_id` | Yes | A `DIAG_ID`; B `diagnosis_no`; C `@id`; D `diagnosisId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `patient_id` | Yes | A `PAT_ID`; B `patient_no`; C/D inherited `source_patient_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `admission_id` | Yes | A `ADM_ID`; B `admission_no`; C/D inherited `source_admission_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `icd9_code` | Yes | A/C dotted text; B may omit dot; D may lose leading zero | Normalize only on a unique verified-code match and resolve in the source dictionary. | Quarantine if missing, invalid, ambiguous, or unresolved; flag. |
| `diagnosing_physician_id` | No | A-D `DIAGNOSING_PHYSICIAN_ID`/`diagnosingPhysicianId` | Parse and resolve within source when present. | `NULL` if invalid/broken; keep and flag. |
| `diagnosis_datetime` | Yes | A local ISO; B day-first; C offset ISO; D epoch/string | Convert to UTC. | Quarantine and flag. |
| `diagnosis_type` | Yes | A-D `DIAGNOSIS_TYPE`/`diagnosisType`; `Primary`, `Secondary`, `Preliminary` | Map using the category table. | Quarantine if unknown; flag. |

### `clinical_notes`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `note_id` | Yes | A `NOTE_ID`; B `note_id`; C `@id`; D `noteId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `admission_id` | Yes | A `ADM_ID`; B `admission_no`; C/D inherited `source_admission_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `author_id` | Yes | A `AUTHOR_ID`; B `author_id`; C/D `authorId` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `note_type` | Yes | A-D `NOTE_TYPE`/`noteType`; three Phase 1 note labels | Map using the category table. | Quarantine if unknown; flag. |
| `note_datetime` | Yes | A local ISO; B day-first; C offset ISO; D epoch/string | Convert to UTC. | Quarantine and flag. |
| `note_contents` | Yes | A `NOTE_CONTENTS`; B `note_contents`; C/D `noteContents`; free text | Trim; preserve content. | Quarantine if missing/invalid; flag. |

### `discharge_records`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `discharge_id` | Yes | A `DISCHARGE_ID`; B `discharge_id`; C `@id`; D `dischargeId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `admission_id` | Yes | A `ADM_ID`; B `admission_no`; C/D inherited `source_admission_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `responsible_physician_id` | No | A-D `RESPONSIBLE_PHYSICIAN_ID`/`responsiblePhysicianId` | Parse and resolve within source when present. | `NULL` if invalid/broken; keep and flag. |
| `discharge_destination` | No | A-D `DISCHARGE_DESTINATION`/`dischargeDestination`; e.g. `Home` | Trim; preserve text. | `NULL`; keep and flag. |
| `discharge_condition` | No | A-D `DISCHARGE_CONDITION`/`dischargeCondition`; samples include `Improved`, `Deceased` | Map using the category table. | `NULL` if unknown; keep and flag. |
| `prescribed_medications` | No | A-D `PRESCRIBED_MEDICATIONS`/`prescribedMedications`; free text | Trim; preserve text. | `NULL`; keep and flag. |
| `follow_up_instructions` | No | A-D `FOLLOW_UP_INSTRUCTIONS`/`followUpInstructions`; free text | Trim; preserve text. | `NULL`; keep and flag. |
| `follow_up_appointment_datetime` | No | A-D `FOLLOW_UP_APPOINTMENT_DATETIME`/`followUpAppointmentDatetime` | Parse and convert to UTC. | `NULL`; keep and flag. |

### `diagnostic_orders`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `order_id` | Yes | A `ORDER_ID`; B `order_id`; C `@id`; D `orderId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `patient_id` | Yes | A `PAT_ID`; B `patient_no`; C/D inherited `source_patient_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `admission_id` | Yes | A `ADM_ID`; B `admission_no`; C/D inherited `source_admission_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `ordering_physician_id` | Yes | A `ORDERING_PHYSICIAN_ID`; B-D `orderingPhysicianId`/`ordering_physician_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `order_datetime` | Yes | A local ISO; B day-first; C offset ISO; D epoch/string | Convert to UTC. | Quarantine and flag. |
| `requested_examination` | Yes | A `REQUESTED_EXAMINATION`; B-D `requestedExamination`/`requested_examination` | Trim; preserve label. | Quarantine and flag. |
| `clinical_reason` | No | A-D `CLINICAL_REASON`/`clinicalReason`; free text | Trim; preserve text. | `NULL`; keep and flag. |
| `priority` | No | A-D `PRIORITY`/`priority`; e.g. `Routine` | Trim; preserve as text; no Phase 1 value check. | `NULL`; keep and flag if invalid/overlength. |
| `order_status` | No | A-D `ORDER_STATUS`/`orderStatus`; e.g. `Completed` | Trim; preserve as text; no Phase 1 value check. | `NULL`; keep and flag if invalid/overlength. |

### `diagnostic_examinations`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `examination_id` | Yes | A `EXAMINATION_ID`; B `examination_id`; C `@id`; D `examinationId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `order_id` | Yes | A `ORDER_ID`; B `order_id`; C/D inherited `source_order_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `performed_by_id` | No | A-D `PERFORMED_BY_ID`/`performedById` | Parse and resolve within source when present. | `NULL` if invalid/broken; keep and flag. |
| `examination_type` | Yes | A-D `EXAMINATION_TYPE`/`examinationType`; e.g. `Chest X-ray` | Trim; preserve label. | Quarantine and flag. |
| `examination_datetime` | Yes | A local ISO; B day-first; C offset ISO; D epoch/string | Convert to UTC; flag and quarantine if it is after the linked admission discharge and cannot be corrected. | Quarantine and flag. |
| `examination_status` | No | A-D `EXAMINATION_STATUS`/`examinationStatus`; e.g. `Completed` | Trim; preserve as text; no Phase 1 value check. | `NULL`; keep and flag if invalid/overlength. |
| `result_summary` | No | A-D `RESULT_SUMMARY`/`resultSummary`; free text | Trim; preserve text. | `NULL`; keep and flag. |

### `radiology_examinations`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `radiology_id` | Yes | A `RADIOLOGY_ID`; B `radiology_id`; C `@id`; D `radiologyId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `examination_id` | Yes | A `EXAMINATION_ID`; B `examination_id`; C/D inherited `source_examination_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `referring_physician_id` | No | A-D `REFERRING_PHYSICIAN_ID`/`referringPhysicianId` | Parse and resolve within source when present. | `NULL` if invalid/broken; keep and flag. |
| `technician_id` | No | A-D `TECHNICIAN_ID`/`technicianId` | Parse and resolve within source when present. | `NULL` if invalid/broken; keep and flag. |
| `body_area` | No | A-D `BODY_AREA`/`bodyArea`; e.g. `Chest` | Trim; preserve text. | `NULL`; keep and flag. |
| `image_link` | No | A-D `IMAGE_LINK`/`imageLink`; URL-like text | Trim; preserve text. | `NULL`; keep and flag. |

### `radiology_reports`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `report_id` | Yes | A `REPORT_ID`; B `report_id`; C `@id`; D `reportId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `radiology_id` | Yes | A `RADIOLOGY_ID`; B `radiology_id`; C/D inherited `source_radiology_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `radiologist_id` | Yes | A `RADIOLOGIST_ID`; B `radiologist_id`; C/D `radiologistId` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `report_datetime` | Yes | A local ISO; B day-first; C offset ISO; D epoch/string | Convert to UTC. | Quarantine and flag. |
| `findings` | No | A-D `FINDINGS`/`findings`; free text | Trim; preserve text. | `NULL`; keep and flag. |
| `impression` | No | A-D `IMPRESSION`/`impression`; free text | Trim; preserve text. | `NULL`; keep and flag. |

### `surgical_procedures`

| Field | Required? | What the sources look like | Rule | Action if bad |
|---|---|---|---|---|
| `procedure_id` | Yes | A `PROCEDURE_ID`; B `procedure_id`; C `@id`; D `procedureId` | Parse as integer; source-scoped. | Quarantine and flag. |
| `admission_id` | Yes | A `ADM_ID`; B `admission_no`; C/D inherited `source_admission_id` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `surgeon_id` | Yes | A `SURGEON_ID`; B `surgeon_id`; C/D `surgeonId` | Parse and resolve within source. | Quarantine if missing or broken; flag. |
| `procedure_name` | Yes | A `PROCEDURE_NAME`; B-D `procedure_name`/`procedureName` | Trim; preserve label. | Quarantine and flag. |
| `procedure_datetime` | Yes | A local ISO; B day-first; C offset ISO; D epoch/string | Convert to UTC; quarantine if after linked admission discharge and not certainly repairable. | Quarantine and flag. |
| `operating_room` | No | A `OPERATING_ROOM`; B-D `operating_room`/`operatingRoom` | Trim; preserve as text. | `NULL`; keep and flag. |
| `procedure_notes` | No | A `PROCEDURE_NOTES`; B-D `procedure_notes`/`procedureNotes`; free text | Trim; preserve text. | `NULL`; keep and flag. |
