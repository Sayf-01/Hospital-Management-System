-- Query 04
-- List all patients who had both a radiology examination and a surgical procedure during the same admission.
--
-- Lists patients with an admission that had both a surgery
-- and a radiology exam.
-- Radiology is linked to the admission via exam -> order -> admission.
SELECT patient_id, first_name, last_name
FROM patients
WHERE patient_id IN (
    SELECT patient_id
    FROM admissions
    WHERE admission_id IN (SELECT admission_id
                           FROM surgical_procedures)
      AND admission_id IN (
          SELECT admission_id
          FROM diagnostic_orders
          WHERE order_id IN (
              SELECT order_id
              FROM diagnostic_examinations
              WHERE examination_id IN (SELECT examination_id
                                       FROM radiology_examinations))));
