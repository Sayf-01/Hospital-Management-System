-- Query 01
-- List the names and admission dates of all patients who were classified as high-priority emergency patients during triage.
--
-- Keeps admissions whose ID appears in triage_assessments
-- with priority 'High-Priority Emergency'.
SELECT p.first_name, p.last_name, a.admission_datetime
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
WHERE a.admission_id IN (SELECT admission_id
                         FROM triage_assessments
                         WHERE priority_level = 'High-Priority Emergency');
