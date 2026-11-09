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
