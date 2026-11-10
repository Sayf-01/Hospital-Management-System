-- Query 10
-- List all patients who underwent a surgical procedure before entering an ICU or CCU during the same admission. Display the patient name, procedure date and time, critical care unit type, and unit entry time.
--
-- Find patients who had surgery before entering the ICU or CCU.
-- The surgery and unit stay must belong to the same admission.
-- Only procedures performed before unit entry are included.
 
SELECT
    p.first_name || ' ' || p.last_name AS patient_name,
    sp.procedure_datetime,
    hu.unit_type,
    us.entry_datetime
FROM patients p
JOIN admissions a
    ON p.patient_id = a.patient_id
JOIN surgical_procedures sp
    ON a.admission_id = sp.admission_id
JOIN unit_stays us
    ON a.admission_id = us.admission_id
JOIN hospital_units hu
    ON us.unit_id = hu.unit_id
WHERE hu.unit_type IN ('ICU', 'CCU')
  AND sp.procedure_datetime < us.entry_datetime;
