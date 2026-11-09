-- Query 05
-- Find all ICU or CCU unit stays that lasted more than seven days. Display the patient name, unit type, unit entry time, unit exit time, and calculated length of stay.
--
-- Q5: Find ICU or CCU stays longer than 7 days.
-- Join patients, admissions, unit stays, and hospital units.
-- Only include completed stays lasting strictly more than 7 days.
SELECT
    p.first_name,
    p.last_name,
    hu.unit_type,
    us.entry_datetime,
    us.exit_datetime,
    ROUND(
        EXTRACT(EPOCH FROM
            (us.exit_datetime - us.entry_datetime)
        ) / 86400.0,
        2
    ) AS length_of_stay_days
FROM patients p
JOIN admissions a
    ON p.patient_id = a.patient_id
JOIN unit_stays us
    ON a.admission_id = us.admission_id
JOIN hospital_units hu
    ON us.unit_id = hu.unit_id
WHERE hu.unit_type IN ('ICU', 'CCU')
  AND us.exit_datetime IS NOT NULL
  AND us.exit_datetime - us.entry_datetime > INTERVAL '7 days'
ORDER BY length_of_stay_days DESC;
