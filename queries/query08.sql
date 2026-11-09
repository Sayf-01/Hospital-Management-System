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
