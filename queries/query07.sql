-- Query 07
-- List all patients who entered the hospital through the Emergency Department and were later transferred to an ICU or CCU during the same admission.
--
-- Q7: Find patients admitted through the Emergency Department
-- who subsequently entered ICU or CCU during the same admission.
SELECT DISTINCT
    p.first_name,
    p.last_name,
    a.admission_id,
    a.admission_datetime,
    hu.unit_type,
    us.entry_datetime
FROM patients p
JOIN admissions a
    ON p.patient_id = a.patient_id
JOIN unit_stays us
    ON a.admission_id = us.admission_id
JOIN hospital_units hu
    ON us.unit_id = hu.unit_id
WHERE a.admission_source = 'Emergency Department'
  AND hu.unit_type IN ('ICU', 'CCU')
  AND us.entry_datetime > a.admission_datetime
ORDER BY a.admission_id, us.entry_datetime;
