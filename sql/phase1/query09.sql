-- Query 09
-- Calculate the average length of stay for each critical care unit type, such as MICU, SICU, ICU, and CCU. Display the unit type and its average length of stay.
--
-- Q9: Calculate the average length of stay for each
-- critical-care unit type: MICU, SICU, ICU, and CCU.
-- Include only completed stays.
SELECT
    hu.unit_type,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                us.exit_datetime - us.entry_datetime
            )) / 86400.0
        ),
        2
    ) AS average_stay_days
FROM unit_stays us
JOIN hospital_units hu
    ON us.unit_id = hu.unit_id
WHERE hu.unit_type IN ('MICU', 'SICU', 'ICU', 'CCU')
  AND us.exit_datetime IS NOT NULL
GROUP BY hu.unit_type
ORDER BY hu.unit_type;
