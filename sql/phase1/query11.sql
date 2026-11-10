-- Query 11
-- Retrieve the name of each patient and the total number of radiology examinations received across all admissions. Include patients who have not received any radiology examinations and display zero for their examination count.
--
-- Q11: Count each patient's radiology examinations across all admissions,
-- including patients who have received no radiology examinations.
--
-- radiology_exam_details links each radiology examination to its patient.
-- LEFT JOIN keeps every patient, even when no examination matches.
-- COUNT(r.radiology_id) counts matching examinations and ignores NULL
-- values, so patients without examinations receive a count of zero.
-- GROUP BY produces one result row per patient. Grouping by patient_id
-- keeps different patients separate even if they share the same name.
-- ORDER BY displays patients in patient_id order.
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    COUNT(r.radiology_id) AS total_radiology_examinations
FROM patients AS p
LEFT JOIN radiology_exam_details AS r
    ON r.patient_id = p.patient_id
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name
ORDER BY
    p.patient_id;
