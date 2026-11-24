-- DA-4 trigger tests: one bad INSERT per rule. EVERY statement below must FAIL.
-- Run after the integrated data is imported. Nothing is saved: each test runs in
-- its own transaction that is rolled back.
-- Screenshot each error message for the report and the demo.

-- T1: a unit stay that starts the day before its admission
BEGIN;
INSERT INTO unit_stays (source_code, source_local_id, admission_id, unit_id, entry_datetime)
SELECT 'A', 'TEST-T1', a.admission_id,
       (SELECT MIN(unit_id) FROM hospital_units WHERE source_code = 'A'),
       a.admission_datetime - INTERVAL '1 day'
FROM admissions a
WHERE a.admission_id = 1;
ROLLBACK;

-- T2a: an examination dated a year after its admission ended
BEGIN;
INSERT INTO diagnostic_examinations (source_code, source_local_id, order_id,
                                     examination_type, examination_datetime)
SELECT o.source_code, 'TEST-T2a', o.order_id, 'Chest X-ray',
       a.discharge_datetime + INTERVAL '1 year'
FROM diagnostic_orders o
JOIN admissions a ON a.admission_id = o.admission_id
WHERE a.discharge_datetime IS NOT NULL
ORDER BY o.order_id
LIMIT 1;
ROLLBACK;

-- T2b: a surgery the day before the patient was admitted
BEGIN;
INSERT INTO surgical_procedures (source_code, source_local_id, admission_id, surgeon_id,
                                 procedure_name, procedure_datetime)
SELECT 'A', 'TEST-T2b', a.admission_id,
       (SELECT MIN(professional_id) FROM healthcare_professionals WHERE source_code = 'A'),
       'Appendectomy', a.admission_datetime - INTERVAL '1 day'
FROM admissions a
WHERE a.admission_id = 1;
ROLLBACK;

-- T3: a radiology report written before its examination took place
--     (moves an existing report one day before its exam)
BEGIN;
UPDATE radiology_reports r
SET    report_datetime = e.examination_datetime - INTERVAL '1 day'
FROM   radiology_examinations x
JOIN   diagnostic_examinations e ON e.examination_id = x.examination_id
WHERE  x.radiology_id = r.radiology_id
  AND  r.report_id = (SELECT MIN(report_id) FROM radiology_reports);
ROLLBACK;

-- T4a: a discharge record for a patient who is still admitted
BEGIN;
INSERT INTO discharge_records (source_code, source_local_id, admission_id, discharge_condition)
SELECT a.source_code, 'TEST-T4a', a.admission_id, 'Improved'
FROM admissions a
WHERE a.admission_status = 'Admitted'
ORDER BY a.admission_id
LIMIT 1;
ROLLBACK;

-- T4b: a 'Deceased' discharge condition on an admission marked Discharged
BEGIN;
UPDATE discharge_records d
SET    discharge_condition = 'Deceased'
WHERE  d.discharge_id = (SELECT MIN(d2.discharge_id)
                         FROM discharge_records d2
                         JOIN admissions a ON a.admission_id = d2.admission_id
                         WHERE a.admission_status = 'Discharged');
ROLLBACK;
