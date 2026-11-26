-- Phase 1 queries rerun on hospital_phase2 (Phase 2, Task 6).
-- Each section is one Phase 1 query, saved under its own number.
-- Results: reports/phase1_reruns/qNN_phase2.csv (Phase 1 results: qNN_phase1.csv).

-- =====================================================================
-- Q02 (rerun by Sayf, SA-5): runs unchanged on the Phase 2 schema.
-- =====================================================================
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

-- =====================================================================
-- Q06 (rerun by Sayf, SA-5): runs unchanged on the Phase 2 schema.
-- =====================================================================
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

-- =====================================================================
-- Q08 (rerun by Sayf, SA-5): runs unchanged on the Phase 2 schema.
-- =====================================================================
-- Query 08
-- Retrieve the most frequently assigned primary ICD-9 diagnosis among admissions that included at least one ICU or CCU stay. Display the ICD-9 code, its official description, and the number of times it was assigned.
--
--We first find admissions with an ICU or CCU stay. Then I count the primary diagnosis
--codes in those admissions and keep the code with the highest count, while
-- adding its title.
WITH icu_ccu_admissions AS (
    SELECT DISTINCT us.admission_id
    FROM   unit_stays us
    JOIN   hospital_units hu ON hu.unit_id = us.unit_id
    WHERE  hu.unit_type IN ('ICU', 'CCU')
),
code_counts AS (
    SELECT d.icd9_code,
           COUNT(*) AS times_assigned
    FROM   diagnoses d
    JOIN   icu_ccu_admissions i ON i.admission_id = d.admission_id
    WHERE  d.diagnosis_type = 'Primary'
    GROUP BY d.icd9_code
)
SELECT  c.icd9_code,
        dict.official_title AS official_description,
        c.times_assigned
FROM    code_counts c
JOIN    icd9_dictionary dict ON dict.icd9_code = c.icd9_code
WHERE   c.times_assigned = (SELECT MAX(times_assigned) FROM code_counts)
ORDER BY c.icd9_code;

-- =====================================================================
-- Q18 (rerun by Sayf, SA-5): runs unchanged on the Phase 2 schema.
-- =====================================================================
-- Query 18
-- Retrieve the latest clinical note for each patient. Display the patient name, note type, note creation date and time, and note contents.
--
--using note_id to break ties, I ranked each patient’s notes from newest to oldest, i then
--kept only rank one. The ranking needs to happen first because ‘WHERE’ can’t filter on it.
WITH ranked_notes AS (
    SELECT  a.patient_id,
            cn.note_type,
            cn.note_datetime,
            cn.note_contents,
            -- restart the numbering for each patient; 1 = their latest note
            ROW_NUMBER() OVER (
                PARTITION BY a.patient_id
                ORDER BY cn.note_datetime DESC, cn.note_id DESC
            ) AS rn
    FROM    clinical_notes cn
    JOIN    admissions a ON a.admission_id = cn.admission_id
)
SELECT  p.first_name || ' ' || p.last_name AS patient_name,
        r.note_type,
        r.note_datetime,
        r.note_contents
FROM    ranked_notes r
JOIN    patients p ON p.patient_id = r.patient_id
WHERE   r.rn = 1
ORDER BY p.patient_id;

-- =====================================================================
-- Q10 (rerun by Dany, DA-5): runs unchanged on the Phase 2 schema.
-- =====================================================================
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


-- =====================================================================
-- Q14 (rerun by Dany, DA-5): runs unchanged on the Phase 2 schema.
-- =====================================================================
-- Query 14
-- Retrieve the patient or patients with the longest completed hospital stay, calculated from admission time to discharge time. If multiple patients have the same maximum length of stay, display all of them.
--
-- A subquery finds the maximum length among completed stays.
-- The outer query returns all stays matching that length, including ties.
 
SELECT
    p.first_name || ' ' || p.last_name AS patient_name,
    a.admission_datetime,
    a.discharge_datetime,
    a.discharge_datetime - a.admission_datetime AS length_of_stay
FROM admissions a
JOIN patients p
    ON a.patient_id = p.patient_id
WHERE a.discharge_datetime IS NOT NULL
  AND (a.discharge_datetime - a.admission_datetime) = (
      SELECT MAX(discharge_datetime - admission_datetime)
      FROM admissions
      WHERE discharge_datetime IS NOT NULL
  );


-- =====================================================================
-- Q16 (rerun by Dany, DA-5): runs unchanged on the Phase 2 schema.
-- =====================================================================
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


-- =====================================================================
-- Q19 (rerun by Dany, DA-5): runs unchanged on the Phase 2 schema.
-- =====================================================================
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

