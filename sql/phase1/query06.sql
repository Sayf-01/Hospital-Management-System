-- Query 06
-- Count the total number of hospital admissions for each patient. Include patients who have no recorded admissions.
--
-- I use the ‘LEFT JOIN’ operation on admissions from patients so patients with no
-- admissions stay in the result. “COUNT” on admission_id ignores any Null values, so they
-- show zero rather than one. Every patient is listed.
SELECT p.patient_id, p.first_name || ' ' || p.last_name AS patient_name,
COUNT(a.admission_id) AS total_admissions
FROM patients p
LEFT JOIN admissions a ON a.patient_id = p.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name ORDER BY p.patient_id;
