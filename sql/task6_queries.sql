-- Task 6 Query 6. Integrity summary with a row for each check, including zeros.
-- Includes overlaps between checks, so the counts should not be summed as distinct records.
-- The validation.sql rule definitions are repeated so this query can run on its own.
WITH records AS MATERIALIZED (
    -- Explicit Schema v2 table list and primary keys, including the composite map key.
    SELECT 'source_systems' AS entity, jsonb_build_array(t.source_code) AS record_key,
           to_jsonb(t) AS fields FROM public.source_systems AS t
    UNION ALL
    SELECT 'patients' AS entity, jsonb_build_array(t.patient_id) AS record_key,
           to_jsonb(t) AS fields FROM public.patients AS t
    UNION ALL
    SELECT 'healthcare_professionals' AS entity, jsonb_build_array(t.professional_id) AS record_key,
           to_jsonb(t) AS fields FROM public.healthcare_professionals AS t
    UNION ALL
    SELECT 'icd9_dictionary' AS entity, jsonb_build_array(t.icd9_code) AS record_key,
           to_jsonb(t) AS fields FROM public.icd9_dictionary AS t
    UNION ALL
    SELECT 'hospital_units' AS entity, jsonb_build_array(t.unit_id) AS record_key,
           to_jsonb(t) AS fields FROM public.hospital_units AS t
    UNION ALL
    SELECT 'admissions' AS entity, jsonb_build_array(t.admission_id) AS record_key,
           to_jsonb(t) AS fields FROM public.admissions AS t
    UNION ALL
    SELECT 'triage_assessments' AS entity, jsonb_build_array(t.triage_id) AS record_key,
           to_jsonb(t) AS fields FROM public.triage_assessments AS t
    UNION ALL
    SELECT 'clinical_notes' AS entity, jsonb_build_array(t.note_id) AS record_key,
           to_jsonb(t) AS fields FROM public.clinical_notes AS t
    UNION ALL
    SELECT 'diagnostic_orders' AS entity, jsonb_build_array(t.order_id) AS record_key,
           to_jsonb(t) AS fields FROM public.diagnostic_orders AS t
    UNION ALL
    SELECT 'diagnostic_examinations' AS entity, jsonb_build_array(t.examination_id) AS record_key,
           to_jsonb(t) AS fields FROM public.diagnostic_examinations AS t
    UNION ALL
    SELECT 'radiology_examinations' AS entity, jsonb_build_array(t.radiology_id) AS record_key,
           to_jsonb(t) AS fields FROM public.radiology_examinations AS t
    UNION ALL
    SELECT 'radiology_reports' AS entity, jsonb_build_array(t.report_id) AS record_key,
           to_jsonb(t) AS fields FROM public.radiology_reports AS t
    UNION ALL
    SELECT 'surgical_procedures' AS entity, jsonb_build_array(t.procedure_id) AS record_key,
           to_jsonb(t) AS fields FROM public.surgical_procedures AS t
    UNION ALL
    SELECT 'unit_stays' AS entity, jsonb_build_array(t.unit_stay_id) AS record_key,
           to_jsonb(t) AS fields FROM public.unit_stays AS t
    UNION ALL
    SELECT 'diagnoses' AS entity, jsonb_build_array(t.diagnosis_id) AS record_key,
           to_jsonb(t) AS fields FROM public.diagnoses AS t
    UNION ALL
    SELECT 'discharge_records' AS entity, jsonb_build_array(t.discharge_id) AS record_key,
           to_jsonb(t) AS fields FROM public.discharge_records AS t
    UNION ALL
    SELECT 'patient_source_map' AS entity, jsonb_build_array(t.source_code, t.source_local_id) AS record_key,
           to_jsonb(t) AS fields FROM public.patient_source_map AS t
    UNION ALL
    SELECT 'patient_match_candidates' AS entity, jsonb_build_array(t.candidate_id) AS record_key,
           to_jsonb(t) AS fields FROM public.patient_match_candidates AS t
    UNION ALL
    SELECT 'quarantine_records' AS entity, jsonb_build_array(t.quarantine_id) AS record_key,
           to_jsonb(t) AS fields FROM public.quarantine_records AS t
),
-- Rule 1. Report each duplicate key group or key with a null component.
rule_01 AS (
    SELECT entity, record_key, 'Key occurs ' || count(*) || ' time(s)' AS detail
    FROM records
    GROUP BY entity, record_key
    HAVING count(*) > 1 OR record_key @> '[null]'::jsonb
),
-- Rule 2. Report each broken foreign-key reference. Nulls are checked by Rule 11
-- only where required. All single-column foreign keys point to a primary key.
foreign_keys(child, child_field, parent) AS (
    VALUES
        ('healthcare_professionals', 'source_code', 'source_systems'),
        ('hospital_units', 'source_code', 'source_systems'),
        ('admissions', 'source_code', 'source_systems'),
        ('admissions', 'patient_id', 'patients'),
        ('admissions', 'admitting_professional_id', 'healthcare_professionals'),
        ('triage_assessments', 'source_code', 'source_systems'),
        ('triage_assessments', 'admission_id', 'admissions'),
        ('triage_assessments', 'nurse_id', 'healthcare_professionals'),
        ('clinical_notes', 'source_code', 'source_systems'),
        ('clinical_notes', 'admission_id', 'admissions'),
        ('clinical_notes', 'author_id', 'healthcare_professionals'),
        ('diagnostic_orders', 'source_code', 'source_systems'),
        ('diagnostic_orders', 'ordering_physician_id', 'healthcare_professionals'),
        ('diagnostic_examinations', 'source_code', 'source_systems'),
        ('diagnostic_examinations', 'order_id', 'diagnostic_orders'),
        ('diagnostic_examinations', 'performed_by_id', 'healthcare_professionals'),
        ('radiology_examinations', 'source_code', 'source_systems'),
        ('radiology_examinations', 'examination_id', 'diagnostic_examinations'),
        ('radiology_examinations', 'referring_physician_id', 'healthcare_professionals'),
        ('radiology_examinations', 'technician_id', 'healthcare_professionals'),
        ('radiology_reports', 'source_code', 'source_systems'),
        ('radiology_reports', 'radiology_id', 'radiology_examinations'),
        ('radiology_reports', 'radiologist_id', 'healthcare_professionals'),
        ('surgical_procedures', 'source_code', 'source_systems'),
        ('surgical_procedures', 'admission_id', 'admissions'),
        ('surgical_procedures', 'surgeon_id', 'healthcare_professionals'),
        ('unit_stays', 'source_code', 'source_systems'),
        ('unit_stays', 'admission_id', 'admissions'),
        ('unit_stays', 'unit_id', 'hospital_units'),
        ('unit_stays', 'responsible_physician_id', 'healthcare_professionals'),
        ('diagnoses', 'source_code', 'source_systems'),
        ('diagnoses', 'icd9_code', 'icd9_dictionary'),
        ('diagnoses', 'diagnosing_physician_id', 'healthcare_professionals'),
        ('discharge_records', 'source_code', 'source_systems'),
        ('discharge_records', 'admission_id', 'admissions'),
        ('discharge_records', 'responsible_physician_id', 'healthcare_professionals'),
        ('patient_source_map', 'source_code', 'source_systems'),
        ('patient_source_map', 'patient_id', 'patients'),
        ('patient_match_candidates', 'patient_id_1', 'patients'),
        ('patient_match_candidates', 'patient_id_2', 'patients'),
        ('quarantine_records', 'source_code', 'source_systems')
),
rule_02 AS (
    SELECT r.entity, r.record_key,
           fk.child_field || '=' || (r.fields ->> fk.child_field) || ' -> ' || fk.parent AS detail
    FROM records AS r
    JOIN foreign_keys AS fk ON fk.child = r.entity
    LEFT JOIN records AS p
      ON p.entity = fk.parent AND p.record_key = jsonb_build_array(r.fields -> fk.child_field)
    WHERE r.fields ->> fk.child_field IS NOT NULL AND p.entity IS NULL

    UNION ALL

    -- Both composite foreign keys reference the admission and its patient.
    SELECT r.entity, r.record_key,
           'admission_id=' || (r.fields ->> 'admission_id') ||
           ', patient_id=' || (r.fields ->> 'patient_id') || ' -> admissions'
    FROM records AS r
    WHERE r.entity IN ('diagnoses', 'diagnostic_orders')
      AND r.fields ->> 'admission_id' IS NOT NULL
      AND r.fields ->> 'patient_id' IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM public.admissions AS a
          WHERE a.admission_id = (r.fields ->> 'admission_id')::integer
            AND a.patient_id = (r.fields ->> 'patient_id')::integer
      )
),
-- Rule 3. Admissions must reference existing patients.
rule_03 AS (
    SELECT 'admissions' AS entity, jsonb_build_array(a.admission_id) AS record_key,
           'Missing patient_id=' || coalesce(a.patient_id::text, 'NULL') AS detail
    FROM public.admissions AS a
    WHERE NOT EXISTS (SELECT 1 FROM public.patients AS p WHERE p.patient_id = a.patient_id)
),
-- Rule 4. A diagnosis must reference both an admission and a dictionary entry.
rule_04 AS (
    SELECT 'diagnoses' AS entity, jsonb_build_array(d.diagnosis_id) AS record_key,
           concat_ws(', ',
               CASE WHEN a.admission_id IS NULL THEN 'Missing admission_id=' || coalesce(d.admission_id::text, 'NULL') END,
               CASE WHEN i.icd9_code IS NULL THEN 'Missing icd9_code=' || coalesce(d.icd9_code, 'NULL') END
           ) AS detail
    FROM public.diagnoses AS d
    LEFT JOIN public.admissions AS a ON a.admission_id = d.admission_id
    LEFT JOIN public.icd9_dictionary AS i ON i.icd9_code = d.icd9_code
    WHERE a.admission_id IS NULL OR i.icd9_code IS NULL
),
-- Rule 5. For an existing admission, both references must identify its patient.
rule_05 AS (
    SELECT r.entity, r.record_key,
           'Admission ' || a.admission_id || ' belongs to patient ' || a.patient_id ||
           ', referenced patient is ' || coalesce(r.fields ->> 'patient_id', 'NULL') AS detail
    FROM records AS r
    JOIN public.admissions AS a ON a.admission_id = (r.fields ->> 'admission_id')::integer
    WHERE r.entity IN ('diagnoses', 'diagnostic_orders')
      AND a.patient_id IS DISTINCT FROM (r.fields ->> 'patient_id')::integer
),
-- Rule 6. A discharge timestamp must be strictly later than admission.
rule_06 AS (
    SELECT 'admissions' AS entity, jsonb_build_array(admission_id) AS record_key,
           'Admitted ' || admission_datetime || ', discharged ' || discharge_datetime AS detail
    FROM public.admissions
    WHERE discharge_datetime <= admission_datetime
),
-- Rule 7. A recorded unit exit must be strictly later than entry.
rule_07 AS (
    SELECT 'unit_stays' AS entity, jsonb_build_array(unit_stay_id) AS record_key,
           'Entered ' || entry_datetime || ', exited ' || exit_datetime AS detail
    FROM public.unit_stays
    WHERE exit_datetime <= entry_datetime
),
-- Rule 8. Examinations (through their orders) and procedures must fall within
-- their admission, inclusive. An open admission has no upper bound.
admission_events(entity, record_key, admission_id, event_time) AS (
    SELECT 'diagnostic_examinations', jsonb_build_array(e.examination_id),
           o.admission_id, e.examination_datetime
    FROM public.diagnostic_examinations AS e
    JOIN public.diagnostic_orders AS o ON o.order_id = e.order_id
    UNION ALL
    SELECT 'surgical_procedures', jsonb_build_array(procedure_id), admission_id, procedure_datetime
    FROM public.surgical_procedures
),
rule_08 AS (
    SELECT e.entity, e.record_key,
           'Event at ' || e.event_time || ' is outside admission ' || a.admission_id AS detail
    FROM admission_events AS e
    JOIN public.admissions AS a ON a.admission_id = e.admission_id
    WHERE e.event_time < a.admission_datetime OR e.event_time > a.discharge_datetime
),
-- Rule 9. Completed admissions missing a Primary diagnosis are reported as
-- violations. YO-2 deliberately retains and flags these admissions.
rule_09 AS (
    SELECT 'admissions' AS entity, jsonb_build_array(a.admission_id) AS record_key,
           a.source_code || ':' || a.source_local_id || ' (' || a.admission_status ||
           ') has no Primary diagnosis' AS detail
    FROM public.admissions AS a
    WHERE a.admission_status IN ('Discharged', 'Deceased')
      AND NOT EXISTS (
          SELECT 1 FROM public.diagnoses AS d
          WHERE d.admission_id = a.admission_id AND d.diagnosis_type = 'Primary'
      )
),
-- Rule 10. Discharge time and any discharge record must agree with the status.
rule_10 AS (
    SELECT 'admissions' AS entity, jsonb_build_array(admission_id) AS record_key,
           'Discharge timestamp disagrees with status ' || admission_status AS detail
    FROM public.admissions
    WHERE (admission_status = 'Admitted' AND discharge_datetime IS NOT NULL)
       OR (admission_status IN ('Discharged', 'Deceased') AND discharge_datetime IS NULL)
    UNION ALL
    SELECT 'discharge_records', jsonb_build_array(d.discharge_id),
           'Admission ' || a.admission_id || ' has status ' || a.admission_status ||
           ' and discharge condition ' || coalesce(d.discharge_condition, 'NULL')
    FROM public.discharge_records AS d
    JOIN public.admissions AS a ON a.admission_id = d.admission_id
    WHERE a.admission_status NOT IN ('Discharged', 'Deceased')
       OR (d.discharge_condition IS NOT DISTINCT FROM 'Deceased') <> (a.admission_status = 'Deceased')
),
-- Rule 11. Report each missing required field or invalid controlled value.
-- The lists follow Schema v2 and the documented gender and file format domains.
required_fields(entity, field_names) AS (
    VALUES
        ('source_systems', ARRAY['source_code', 'hospital_name', 'continent', 'file_format', 'time_zone']),
        ('patients', ARRAY['patient_id', 'first_name', 'last_name', 'date_of_birth', 'gender', 'life_status']),
        ('healthcare_professionals', ARRAY['professional_id', 'source_code', 'source_local_id', 'first_name', 'last_name', 'role']),
        ('icd9_dictionary', ARRAY['icd9_code', 'official_title']),
        ('hospital_units', ARRAY['unit_id', 'source_code', 'source_local_id', 'unit_name', 'unit_type']),
        ('admissions', ARRAY['admission_id', 'source_code', 'source_local_id', 'patient_id', 'admission_datetime', 'admission_type', 'admission_status']),
        ('triage_assessments', ARRAY['triage_id', 'source_code', 'source_local_id', 'admission_id', 'assessment_datetime', 'priority_level']),
        ('clinical_notes', ARRAY['note_id', 'source_code', 'source_local_id', 'admission_id', 'author_id', 'note_type', 'note_datetime', 'note_contents']),
        ('diagnostic_orders', ARRAY['order_id', 'source_code', 'source_local_id', 'patient_id', 'admission_id', 'ordering_physician_id', 'order_datetime', 'requested_examination']),
        ('diagnostic_examinations', ARRAY['examination_id', 'source_code', 'source_local_id', 'order_id', 'examination_type', 'examination_datetime']),
        ('radiology_examinations', ARRAY['radiology_id', 'source_code', 'source_local_id', 'examination_id']),
        ('radiology_reports', ARRAY['report_id', 'source_code', 'source_local_id', 'radiology_id', 'radiologist_id', 'report_datetime']),
        ('surgical_procedures', ARRAY['procedure_id', 'source_code', 'source_local_id', 'admission_id', 'surgeon_id', 'procedure_name', 'procedure_datetime']),
        ('unit_stays', ARRAY['unit_stay_id', 'source_code', 'source_local_id', 'admission_id', 'unit_id', 'entry_datetime']),
        ('diagnoses', ARRAY['diagnosis_id', 'source_code', 'source_local_id', 'patient_id', 'admission_id', 'icd9_code', 'diagnosis_datetime', 'diagnosis_type']),
        ('discharge_records', ARRAY['discharge_id', 'source_code', 'source_local_id', 'admission_id']),
        ('patient_source_map', ARRAY['source_code', 'source_local_id', 'patient_id', 'match_rule']),
        ('patient_match_candidates', ARRAY['candidate_id', 'patient_id_1', 'patient_id_2', 'match_rule', 'reason', 'decision']),
        ('quarantine_records', ARRAY['quarantine_id', 'stage', 'source_code', 'entity', 'reason'])
),
categorical_fields(entity, field, allowed_values) AS (
    VALUES
        ('source_systems', 'source_code', ARRAY['A', 'B', 'C', 'D']),
        ('patients', 'life_status', ARRAY['Alive', 'Deceased']),
        ('healthcare_professionals', 'role', ARRAY['Physician', 'Surgeon', 'Nurse', 'Radiologist', 'Technician']),
        ('hospital_units', 'unit_type', ARRAY['Emergency', 'General Ward', 'MICU', 'SICU', 'ICU', 'CCU', 'Other']),
        ('admissions', 'admission_type', ARRAY['Emergency', 'Urgent', 'Elective', 'Outpatient', 'Newborn']),
        ('admissions', 'admission_source', ARRAY['Emergency Department', 'Referral', 'Transfer from Another Hospital', 'Walk-in', 'Other']),
        ('admissions', 'admission_status', ARRAY['Admitted', 'Discharged', 'Deceased']),
        ('triage_assessments', 'priority_level', ARRAY['High-Priority Emergency', 'Urgent', 'Non-Urgent']),
        ('clinical_notes', 'note_type', ARRAY['Initial Assessment', 'Progress Note', 'Discharge Summary']),
        ('diagnoses', 'diagnosis_type', ARRAY['Primary', 'Secondary', 'Preliminary']),
        ('discharge_records', 'discharge_condition', ARRAY['Improved', 'Stable', 'Unchanged', 'Deteriorated', 'Deceased']),
        ('patient_source_map', 'match_rule', ARRAY['NEW', 'M1']),
        ('patient_match_candidates', 'match_rule', ARRAY['U1', 'U2']),
        ('patient_match_candidates', 'decision', ARRAY['Not merged', 'Merged', 'Rejected']),
        ('quarantine_records', 'stage', ARRAY['load', 'clean', 'relationships', 'chronology', 'integrate']),
        ('patients', 'gender', ARRAY['Male', 'Female']),
        ('source_systems', 'file_format', ARRAY['TXT', 'CSV', 'XML', 'JSON'])
),
rule_11 AS (
    SELECT r.entity, r.record_key, f.field || ' is required' AS detail
    FROM records AS r
    JOIN required_fields AS req ON req.entity = r.entity
    CROSS JOIN LATERAL unnest(req.field_names) AS f(field)
    WHERE coalesce(r.fields ->> f.field, '') !~ '[^[:space:]]'
    UNION ALL
    SELECT r.entity, r.record_key, c.field || '=' || (r.fields ->> c.field) || ' is invalid'
    FROM records AS r
    JOIN categorical_fields AS c ON c.entity = r.entity
    WHERE r.fields ->> c.field IS NOT NULL
      AND NOT ((r.fields ->> c.field) = ANY(c.allowed_values))
)
SELECT check_name, violation_count
FROM (
    SELECT 1 AS rule_id, 'Primary key uniqueness and presence' AS check_name, count(*) AS violation_count FROM rule_01
    UNION ALL
    SELECT 2 AS rule_id, 'Foreign key references' AS check_name, count(*) AS violation_count FROM rule_02
    UNION ALL
    SELECT 3 AS rule_id, 'Admissions with missing patients' AS check_name, count(*) AS violation_count FROM rule_03
    UNION ALL
    SELECT 4 AS rule_id, 'Diagnoses with missing admissions or ICD-9 entries' AS check_name, count(*) AS violation_count FROM rule_04
    UNION ALL
    SELECT 5 AS rule_id, 'Patient and admission consistency' AS check_name, count(*) AS violation_count FROM rule_05
    UNION ALL
    SELECT 6 AS rule_id, 'Discharge after admission' AS check_name, count(*) AS violation_count FROM rule_06
    UNION ALL
    SELECT 7 AS rule_id, 'Unit exit after entry' AS check_name, count(*) AS violation_count FROM rule_07
    UNION ALL
    SELECT 8 AS rule_id, 'Examinations and procedures within admission' AS check_name, count(*) AS violation_count FROM rule_08
    UNION ALL
    SELECT 9 AS rule_id, 'Completed admissions without Primary diagnosis' AS check_name, count(*) AS violation_count FROM rule_09
    UNION ALL
    SELECT 10 AS rule_id, 'Discharge information and admission status' AS check_name, count(*) AS violation_count FROM rule_10
    UNION ALL
    SELECT 11 AS rule_id, 'Required fields and valid categories' AS check_name, count(*) AS violation_count FROM rule_11
) AS summary
ORDER BY rule_id;
