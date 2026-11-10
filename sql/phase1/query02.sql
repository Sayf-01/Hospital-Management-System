-- Query 02
-- Find all patients who had more than three hospital admissions. Display the patient identifier, patient name, and total number of admissions.
--
-- Joins patients to their admissions, groups the rows by patient
-- and counts each patient's admissions.
-- HAVING keeps only patients with more than three admissions,
-- since WHERE cannot filter on an aggregate such as COUNT.
-- Results are sorted by admission count, highest first.
SELECT p.patient_id, p.first_name || ' ' || p.last_name AS patient_name,
COUNT(a.admission_id) AS total_admissions
FROM patients p
JOIN admissions a ON a.patient_id = p.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
HAVING COUNT(a.admission_id) > 3 ORDER BY total_admissions DESC, p.patient_id;
