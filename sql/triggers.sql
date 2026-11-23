-- Hospital Management System - Phase 2 triggers (DA-4, PostgreSQL / PL/pgSQL)
-- SOEN 363
--
-- Run AFTER sql/schema_v2.sql and BEFORE importing data, so the import itself is
-- checked row by row. Safe to rerun: every trigger is dropped and recreated.
--
-- Plain constraints (in schema_v2.sql) can only look at one row of one table.
-- These rules compare a row with its parent in another table, so they need triggers:
--   T1  a unit stay lies inside its admission
--   T2  a diagnostic examination (through its order) and a surgical procedure
--       happen during their admission
--   T3  a radiology report comes after its examination
--   T4  a discharge record exists only for a Discharged or Deceased admission, and
--       its condition is 'Deceased' exactly when the admission status is Deceased
--
-- Already enforced without a trigger:
--   * diagnosis / order patient = admission patient: the composite foreign key
--     (admission_id, patient_id) in schema_v2.sql
-- Not a trigger, by choice:
--   * "every completed admission has at least one Primary diagnosis": diagnoses are
--     inserted after their admission, so a row check would reject every admission.
--     Youssef checks it after import.
--
-- Every rejection raises SQLSTATE 23514 (check_violation), the same error code a
-- CHECK constraint gives. The message names the rule and the row by its source
-- (for example A:1024), so a rejected row can be traced back to its source file.


-- Shared helper: is a moment inside an admission? An open admission (no discharge
-- yet) has no end. Both ends are inclusive.
CREATE OR REPLACE FUNCTION within_admission(p_admission_id INT, p_moment TIMESTAMPTZ)
RETURNS BOOLEAN
LANGUAGE sql STABLE
AS $$
    SELECT p_moment >= a.admission_datetime
       AND (a.discharge_datetime IS NULL OR p_moment <= a.discharge_datetime)
    FROM admissions a
    WHERE a.admission_id = p_admission_id;
$$;


-- T1: a unit stay must lie inside its admission
--     entry at or after admission time; exit at or before discharge, if there is one
CREATE OR REPLACE FUNCTION check_unit_stay_in_admission()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT within_admission(NEW.admission_id, NEW.entry_datetime) THEN
        RAISE EXCEPTION 'T1: unit stay %:% enters the unit at %, outside admission %',
            NEW.source_code, NEW.source_local_id, NEW.entry_datetime, NEW.admission_id
            USING ERRCODE = 'check_violation';
    END IF;
    IF NEW.exit_datetime IS NOT NULL
       AND NOT within_admission(NEW.admission_id, NEW.exit_datetime) THEN
        RAISE EXCEPTION 'T1: unit stay %:% leaves the unit at %, after admission % ended',
            NEW.source_code, NEW.source_local_id, NEW.exit_datetime, NEW.admission_id
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS t1_unit_stay_in_admission ON unit_stays;
CREATE TRIGGER t1_unit_stay_in_admission
    BEFORE INSERT OR UPDATE OF admission_id, entry_datetime, exit_datetime ON unit_stays
    FOR EACH ROW EXECUTE FUNCTION check_unit_stay_in_admission();


-- T2a: a diagnostic examination happens during its admission (found through its order)
CREATE OR REPLACE FUNCTION check_examination_in_admission()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_admission_id INT;
BEGIN
    SELECT o.admission_id INTO v_admission_id
    FROM diagnostic_orders o
    WHERE o.order_id = NEW.order_id;

    IF NOT within_admission(v_admission_id, NEW.examination_datetime) THEN
        RAISE EXCEPTION 'T2: examination %:% at % is outside admission % (order %)',
            NEW.source_code, NEW.source_local_id, NEW.examination_datetime, v_admission_id, NEW.order_id
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS t2_examination_in_admission ON diagnostic_examinations;
CREATE TRIGGER t2_examination_in_admission
    BEFORE INSERT OR UPDATE OF order_id, examination_datetime ON diagnostic_examinations
    FOR EACH ROW EXECUTE FUNCTION check_examination_in_admission();


-- T2b: a surgical procedure happens during its admission
CREATE OR REPLACE FUNCTION check_procedure_in_admission()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT within_admission(NEW.admission_id, NEW.procedure_datetime) THEN
        RAISE EXCEPTION 'T2: procedure %:% at % is outside admission %',
            NEW.source_code, NEW.source_local_id, NEW.procedure_datetime, NEW.admission_id
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS t2_procedure_in_admission ON surgical_procedures;
CREATE TRIGGER t2_procedure_in_admission
    BEFORE INSERT OR UPDATE OF admission_id, procedure_datetime ON surgical_procedures
    FOR EACH ROW EXECUTE FUNCTION check_procedure_in_admission();


-- T3: a radiology report comes after its examination
--     report -> radiology_examinations -> diagnostic_examinations (the exam time)
CREATE OR REPLACE FUNCTION check_report_after_examination()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_examination_time TIMESTAMPTZ;
BEGIN
    SELECT e.examination_datetime INTO v_examination_time
    FROM radiology_examinations r
    JOIN diagnostic_examinations e ON e.examination_id = r.examination_id
    WHERE r.radiology_id = NEW.radiology_id;

    IF NEW.report_datetime < v_examination_time THEN
        RAISE EXCEPTION 'T3: report %:% at % is before its examination at %',
            NEW.source_code, NEW.source_local_id, NEW.report_datetime, v_examination_time
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS t3_report_after_examination ON radiology_reports;
CREATE TRIGGER t3_report_after_examination
    BEFORE INSERT OR UPDATE OF radiology_id, report_datetime ON radiology_reports
    FOR EACH ROW EXECUTE FUNCTION check_report_after_examination();


-- T4: a discharge record only for a finished admission, and 'Deceased' must agree
CREATE OR REPLACE FUNCTION check_discharge_matches_admission()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
BEGIN
    SELECT a.admission_status INTO v_status
    FROM admissions a
    WHERE a.admission_id = NEW.admission_id;

    IF v_status NOT IN ('Discharged', 'Deceased') THEN
        RAISE EXCEPTION 'T4: discharge record %:% is for admission %, which is still %',
            NEW.source_code, NEW.source_local_id, NEW.admission_id, v_status
            USING ERRCODE = 'check_violation';
    END IF;
    -- IS DISTINCT FROM treats an empty condition as "not Deceased"
    IF (NEW.discharge_condition IS NOT DISTINCT FROM 'Deceased') <> (v_status = 'Deceased') THEN
        RAISE EXCEPTION 'T4: discharge record %:% says %, but admission % is %',
            NEW.source_code, NEW.source_local_id, COALESCE(NEW.discharge_condition, 'no condition'),
            NEW.admission_id, v_status
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS t4_discharge_matches_admission ON discharge_records;
CREATE TRIGGER t4_discharge_matches_admission
    BEFORE INSERT OR UPDATE OF admission_id, discharge_condition ON discharge_records
    FOR EACH ROW EXECUTE FUNCTION check_discharge_matches_admission();
