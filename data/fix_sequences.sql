-- Resets every identity sequence to the table's current MAX(id).
-- Run once after data.sql. Without it, the next INSERT that omits the ID
-- starts at 1 and fails with a duplicate-key error.

SELECT setval('public.admissions_admission_id_seq',                  COALESCE((SELECT MAX(admission_id)    FROM public.admissions), 1));
SELECT setval('public.clinical_notes_note_id_seq',                   COALESCE((SELECT MAX(note_id)         FROM public.clinical_notes), 1));
SELECT setval('public.diagnoses_diagnosis_id_seq',                   COALESCE((SELECT MAX(diagnosis_id)    FROM public.diagnoses), 1));
SELECT setval('public.diagnostic_examinations_examination_id_seq',   COALESCE((SELECT MAX(examination_id)  FROM public.diagnostic_examinations), 1));
SELECT setval('public.diagnostic_orders_order_id_seq',               COALESCE((SELECT MAX(order_id)        FROM public.diagnostic_orders), 1));
SELECT setval('public.discharge_records_discharge_id_seq',           COALESCE((SELECT MAX(discharge_id)    FROM public.discharge_records), 1));
SELECT setval('public.healthcare_professionals_professional_id_seq', COALESCE((SELECT MAX(professional_id) FROM public.healthcare_professionals), 1));
SELECT setval('public.hospital_units_unit_id_seq',                   COALESCE((SELECT MAX(unit_id)         FROM public.hospital_units), 1));
SELECT setval('public.patients_patient_id_seq',                      COALESCE((SELECT MAX(patient_id)      FROM public.patients), 1));
SELECT setval('public.radiology_examinations_radiology_id_seq',      COALESCE((SELECT MAX(radiology_id)    FROM public.radiology_examinations), 1));
SELECT setval('public.radiology_reports_report_id_seq',              COALESCE((SELECT MAX(report_id)       FROM public.radiology_reports), 1));
SELECT setval('public.surgical_procedures_procedure_id_seq',         COALESCE((SELECT MAX(procedure_id)    FROM public.surgical_procedures), 1));
SELECT setval('public.triage_assessments_triage_id_seq',             COALESCE((SELECT MAX(triage_id)       FROM public.triage_assessments), 1));
SELECT setval('public.unit_stays_unit_stay_id_seq',                  COALESCE((SELECT MAX(unit_stay_id)    FROM public.unit_stays), 1));
