-- Query 03
-- Retrieve the names, admission dates, and discharge dates of patients who were discharged without undergoing any surgical procedure during the admission.
--
-- keeps discharged admissions whose ID does not appear in surgical_procedures
SELECT p.first_name, p.last_name, a.admission_datetime, a.discharge_datetime
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
WHERE a.admission_id NOT IN (SELECT admission_id
                         FROM surgical_procedures
                         )
                         AND a.admission_status='Discharged';
