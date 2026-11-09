-- Query 20
-- Find all patients who underwent a surgical procedure and a radiology examination on the same calendar day during the same admission. Display the patient name, admission identifier, procedure type, radiology examination type, and the common date.
--
-- Q20: Find surgical procedures and radiology examinations occurring
-- on the same calendar day during the same admission.
--
-- The joins connect patients to admissions, procedures and examinations.
-- Matching admission_id ensures both events belong to the same visit.
-- CAST(... AS DATE) removes the clock time from each timestamp.
-- Comparing those dates finds same-day events even when their times differ.
-- Events in different admissions do not match, even for the same patient.
-- Events across midnight do not match because their calendar dates differ.
--
-- Each result row represents one matching procedure/examination pair.
-- Two procedures and two examinations on the same day produce four pairs.
-- Separate examinations of the same type may produce identical-looking
-- rows because examination IDs and timestamps are not displayed.
-- DISTINCT is omitted to preserve those separate event pairs.
-- ORDER BY sorts by admission, common date, procedure ID and radiology ID.
SELECT
    p.first_name,
    p.last_name,
    a.admission_id,
    sp.procedure_name AS procedure_type,
    r.examination_type AS radiology_examination_type,
    CAST(sp.procedure_datetime AS DATE) AS common_date
FROM patients AS p
JOIN admissions AS a
    ON a.patient_id = p.patient_id
JOIN surgical_procedures AS sp
    ON sp.admission_id = a.admission_id
JOIN radiology_exam_details AS r
    ON r.admission_id = a.admission_id
   AND CAST(r.examination_datetime AS DATE)
       = CAST(sp.procedure_datetime AS DATE)
ORDER BY
    a.admission_id,
    common_date,
    sp.procedure_id,
    r.radiology_id;
