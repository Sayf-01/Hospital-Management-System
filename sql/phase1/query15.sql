-- Query 15
-- Count the total number of transfers between hospital units for each patient. The patient’s first unit placement is not considered a transfer; each subsequent unit stay within the same admission represents one transfer.
--
-- Q15: Count each patient's transfers between hospital units.
-- The first placement within each admission is not a transfer.
--
-- The admission_transfers CTE calculates transfers for each admission.
-- LEFT JOIN retains admissions that have no recorded unit stays.
-- COUNT(us.unit_stay_id) counts placements, ignoring unmatched NULLs.
-- Subtracting one excludes the initial placement for that admission.
-- GREATEST(..., 0) prevents a negative count when no placements exist.
--
-- The main query adds the admission-level counts for each patient.
-- LEFT JOIN keeps patients who have no admissions.
-- COALESCE replaces a missing total with zero.
-- GROUP BY produces one result row per patient.
-- ORDER BY displays patients in patient_id order.
--
-- Example: three placements in one admission and two in another
-- produce (3 - 1) + (2 - 1) = 3 transfers.
WITH admission_transfers AS (
    SELECT
        a.admission_id,
        a.patient_id,
        GREATEST(
            COUNT(us.unit_stay_id) - 1,
            0
        ) AS transfer_count
    FROM admissions AS a
    LEFT JOIN unit_stays AS us
        ON us.admission_id = a.admission_id
    GROUP BY
        a.admission_id,
        a.patient_id
)
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    COALESCE(SUM(atf.transfer_count), 0) AS total_transfers
FROM patients AS p
LEFT JOIN admission_transfers AS atf
    ON atf.patient_id = p.patient_id
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name
ORDER BY
    p.patient_id;
