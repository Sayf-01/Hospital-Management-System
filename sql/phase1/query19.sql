-- Query 19
-- List all admissions where the patient’s discharge status or discharge condition indicates that the patient died during the hospital stay. Display the patient name, admission date, recorded date of death, and associated primary ICD-9 diagnosis.
--
-- Find patients who died during their hospital stay.
-- Join deceased admissions with their primary diagnoses,
-- then use the ICD-9 dictionary to display the diagnosis title.
 
SELECT
    p.first_name || ' ' || p.last_name AS patient_name,
    a.admission_datetime,
    p.date_of_death,
    d.icd9_code,
    icd.official_title AS diagnosis_title
FROM patients p
JOIN admissions a
    ON p.patient_id = a.patient_id
JOIN diagnoses d
    ON a.admission_id = d.admission_id
JOIN icd9_dictionary icd
    ON d.icd9_code = icd.icd9_code
WHERE a.admission_status = 'Deceased'
  AND d.diagnosis_type = 'Primary';
