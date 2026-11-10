-- Query 16
-- List all patients who stayed in more than one type of critical care unit during the same admission. For example, a patient may have been transferred from an ICU to a CCU.
--
-- Find patients who stayed in more than one critical care unit type
-- during the same admission. COUNT(DISTINCT) ensures that repeated
-- stays in the same unit type are counted only once.
 
SELECT
    p.first_name || ' ' || p.last_name AS patient_name,
    a.admission_id,
    COUNT(DISTINCT hu.unit_type) AS critical_care_types
FROM patients p
JOIN admissions a
    ON p.patient_id = a.patient_id
JOIN unit_stays us
    ON a.admission_id = us.admission_id
JOIN hospital_units hu
    ON us.unit_id = hu.unit_id
WHERE hu.unit_type IN ('MICU', 'SICU', 'ICU', 'CCU')
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name,
    a.admission_id
HAVING COUNT(DISTINCT hu.unit_type) > 1;
