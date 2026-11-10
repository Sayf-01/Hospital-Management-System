-- Query 17
-- Find all admissions during which the patient received more than one distinct ICD-9 diagnosis. Display the patient name, admission identifier, and number of distinct ICD-9 codes.
--
-- Q17: Find admissions with more than one distinct ICD-9 code.
-- Repeated records of the same code count only once.
SELECT
    p.first_name,
    p.last_name,
    a.admission_id,a.patient_id,
    COUNT(DISTINCT d.icd9_code) AS distinct_icd9_count
FROM patients AS p
JOIN admissions AS a
    ON a.patient_id = p.patient_id
JOIN diagnoses AS d
    ON d.admission_id = a.admission_id
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name,
    a.admission_id
HAVING COUNT(DISTINCT d.icd9_code) > 1
ORDER BY  a.admission_id ;
