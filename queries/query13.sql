-- Query 13
-- List all admissions in which the patient had at least one radiology examination but had no recorded ICU or CCU stay.
--
-- Q13: List admissions with at least one radiology examination
-- but no ICU or CCU stay during that same admission.
--
-- JOIN connects each admission to its patient's name and identifier.
-- EXISTS checks whether a radiology examination belongs to the admission.
-- It avoids repeating an admission when several examinations exist.
-- NOT EXISTS excludes admissions with any ICU or CCU stay.
-- hospital_units identifies the unit type for each unit_stays record.
-- Both subqueries match admission_id, so examinations and unit stays
-- from the patient's other admissions do not affect the result.
-- Following the team's convention, MICU and SICU are not excluded here.
-- ORDER BY displays the qualifying admissions in admission_id order.
SELECT
    a.admission_id,
    p.patient_id,
    p.first_name,
    p.last_name,
    a.admission_datetime
FROM admissions AS a
JOIN patients AS p
    ON p.patient_id = a.patient_id
WHERE EXISTS (
    SELECT 1
    FROM radiology_exam_details AS r
    WHERE r.admission_id = a.admission_id
)
AND NOT EXISTS (
    SELECT 1
    FROM unit_stays AS us
    JOIN hospital_units AS hu
        ON hu.unit_id = us.unit_id
    WHERE us.admission_id = a.admission_id
      AND hu.unit_type IN ('ICU', 'CCU')
)
ORDER BY
    a.admission_id;
