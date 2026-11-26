-- Task 6 Query 5 (DA-5): duplicate source IDs were resolved
-- Run on hospital_phase2. Read-only: only SELECT statements.
--
-- Each hospital numbers its own records from 1, so the same local ID appears in
-- several hospitals. Integration (DA-3) gave every record a global ID and kept
-- the hospital's own ID beside it. These three parts show that it worked.


-- Part 1: one local patient ID that exists in all four hospitals.
-- Each source record maps to its own global patient, unless rule M1 merged them;
-- match_rule says which ('NEW' = kept separate, 'M1' = merged).
SELECT  m.source_code,
        s.hospital_name,
        m.source_local_id,
        m.patient_id                         AS global_patient_id,
        m.match_rule,
        p.first_name || ' ' || p.last_name   AS patient_name
FROM    patient_source_map m
JOIN    source_systems s ON s.source_code = m.source_code
JOIN    patients p       ON p.patient_id  = m.patient_id
WHERE   m.source_local_id = '125'
ORDER BY m.source_code;


-- Part 1b: the same check on a merged patient. Two hospitals' records share one
-- global patient, and both rows say M1.
SELECT  m.source_code,
        s.hospital_name,
        m.source_local_id,
        m.patient_id                         AS global_patient_id,
        m.match_rule,
        m.source_insurance_number
FROM    patient_source_map m
JOIN    source_systems s ON s.source_code = m.source_code
WHERE   m.patient_id = (SELECT MIN(patient_id) FROM patient_source_map WHERE match_rule = 'M1')
ORDER BY m.source_code;


-- Part 2: no (source_code, source_local_id) maps to two global IDs, in any table.
-- Each table lists (source, local ID, global ID); a source record with more than
-- one global ID would appear here. Expected result: 0 rows.
WITH source_records AS (
    SELECT 'patients' AS entity, source_code, source_local_id, patient_id AS global_id FROM patient_source_map
    UNION ALL SELECT 'healthcare_professionals', source_code, source_local_id, professional_id FROM healthcare_professionals
    UNION ALL SELECT 'hospital_units',           source_code, source_local_id, unit_id         FROM hospital_units
    UNION ALL SELECT 'admissions',               source_code, source_local_id, admission_id    FROM admissions
    UNION ALL SELECT 'triage_assessments',       source_code, source_local_id, triage_id       FROM triage_assessments
    UNION ALL SELECT 'unit_stays',               source_code, source_local_id, unit_stay_id    FROM unit_stays
    UNION ALL SELECT 'diagnoses',                source_code, source_local_id, diagnosis_id    FROM diagnoses
    UNION ALL SELECT 'clinical_notes',           source_code, source_local_id, note_id         FROM clinical_notes
    UNION ALL SELECT 'discharge_records',        source_code, source_local_id, discharge_id    FROM discharge_records
    UNION ALL SELECT 'diagnostic_orders',        source_code, source_local_id, order_id        FROM diagnostic_orders
    UNION ALL SELECT 'diagnostic_examinations',  source_code, source_local_id, examination_id  FROM diagnostic_examinations
    UNION ALL SELECT 'radiology_examinations',   source_code, source_local_id, radiology_id    FROM radiology_examinations
    UNION ALL SELECT 'radiology_reports',        source_code, source_local_id, report_id       FROM radiology_reports
    UNION ALL SELECT 'surgical_procedures',      source_code, source_local_id, procedure_id    FROM surgical_procedures
)
SELECT  entity, source_code, source_local_id,
        COUNT(DISTINCT global_id) AS global_ids
FROM    source_records
GROUP BY entity, source_code, source_local_id
HAVING  COUNT(DISTINCT global_id) > 1;


-- Part 3: how patients were matched across hospitals.
SELECT 'Source patient records'                    AS measure, COUNT(*) AS count FROM patient_source_map
UNION ALL
SELECT 'Integrated patients',                       COUNT(*) FROM patients
UNION ALL
SELECT 'Patients merged across hospitals (M1)',     COUNT(DISTINCT patient_id) FROM patient_source_map WHERE match_rule = 'M1'
UNION ALL
SELECT 'Source records joined by a merge',          COUNT(*) FROM patient_source_map WHERE match_rule = 'M1'
UNION ALL
SELECT 'Uncertain matches kept separate (U1)',      COUNT(*) FROM patient_match_candidates WHERE match_rule = 'U1'
UNION ALL
SELECT 'Insurance-number conflicts (U2)',           COUNT(*) FROM patient_match_candidates WHERE match_rule = 'U2'
UNION ALL
SELECT 'Local patient IDs used in all 4 hospitals', COUNT(*) FROM (
    SELECT source_local_id FROM patient_source_map
    GROUP BY source_local_id HAVING COUNT(DISTINCT source_code) = 4) AS shared;
