-- Query 12
-- Find all patients whose discharge-summary clinical note contains the keyword “recovery”. The search should be case-insensitive.
--
-- Q12: Find patients whose discharge-summary clinical
-- notes contain "recovery", regardless of capitalization.
SELECT DISTINCT
    p.first_name,
    p.last_name,
    a.admission_id,
    cn.note_datetime,
    cn.note_contents
FROM patients p
JOIN admissions a
    ON p.patient_id = a.patient_id
JOIN clinical_notes cn
    ON a.admission_id = cn.admission_id
WHERE cn.note_type = 'Discharge Summary'
  AND cn.note_contents ILIKE '%recovery%'
ORDER BY p.last_name, p.first_name, a.admission_id;
