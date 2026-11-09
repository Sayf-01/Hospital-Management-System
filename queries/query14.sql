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
