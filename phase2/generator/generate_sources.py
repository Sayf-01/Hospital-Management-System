"""KR-2 Step 3: build, check, and deliberately corrupt synthetic records.

Preview files use canonical fields and source-local IDs and wall times.
The four source serializers are a separate step.
"""

import argparse
import csv
import json
import random
import runpy
from collections import Counter, defaultdict
from datetime import datetime, timedelta
from pathlib import Path


SEED = 363
SAMPLE_PATIENTS = 50
SOURCES = ("A", "B", "C", "D")
CORE_TABLES = ("patients", "admissions", "diagnoses")
MAP_PATH = Path(__file__).resolve().parents[1] / "config" / "source_maps.py"
START = datetime(2026, 1, 5, 8)

# CMS ICD-9-CM Version 32, CMS32_DESC_LONG_DX.txt.
ICD9_REFERENCE = {
    '038.9': 'Unspecified septicemia',
    '250.00': 'Diabetes mellitus without mention of complication, type II or unspecified type, not stated as uncontrolled',
    '272.4': 'Other and unspecified hyperlipidemia',
    '276.51': 'Dehydration',
    '285.9': 'Anemia, unspecified',
    '300.00': 'Anxiety state, unspecified',
    '003.0': 'Salmonella gastroenteritis',
    '311': 'Depressive disorder, not elsewhere classified',
    '401.9': 'Unspecified essential hypertension',
    '410.91': 'Acute myocardial infarction of unspecified site, initial episode of care',
    '414.01': 'Coronary atherosclerosis of native coronary artery',
    '427.31': 'Atrial fibrillation',
    '428.0': 'Congestive heart failure, unspecified',
    '434.91': 'Cerebral artery occlusion, unspecified with cerebral infarction',
    '438.20': 'Late effects of cerebrovascular disease, hemiplegia affecting unspecified side',
    '465.9': 'Acute upper respiratory infections of unspecified site',
    '466.0': 'Acute bronchitis',
    '486': 'Pneumonia, organism unspecified',
    '491.21': 'Obstructive chronic bronchitis with (acute) exacerbation',
    '493.90': 'Asthma, unspecified type, unspecified',
    '496': 'Chronic airway obstruction, not elsewhere classified',
    '518.81': 'Acute respiratory failure',
    '530.81': 'Esophageal reflux',
    '535.50': 'Unspecified gastritis and gastroduodenitis, without mention of hemorrhage',
    '564.00': 'Constipation, unspecified',
    '571.5': 'Cirrhosis of liver without mention of alcohol',
    '584.9': 'Acute kidney failure, unspecified',
    '585.3': 'Chronic kidney disease, Stage III (moderate)',
    '599.0': 'Urinary tract infection, site not specified',
    '715.90': 'Osteoarthrosis, unspecified whether generalized or localized, site unspecified',
    '724.2': 'Lumbago',
    '780.2': 'Syncope and collapse',
    '780.60': 'Fever, unspecified',
    '008.45': 'Intestinal infection due to Clostridium difficile',
    '786.05': 'Shortness of breath',
    '786.50': 'Chest pain, unspecified',
    '789.00': 'Abdominal pain, unspecified site',
    '041.11': 'Methicillin susceptible Staphylococcus aureus in conditions classified elsewhere and of unspecified site',
    '820.8': 'Closed fracture of unspecified part of neck of femur',
    '070.54': 'Chronic hepatitis C without mention of hepatic coma',
}
ICD9_CODES = tuple(ICD9_REFERENCE)

PRIMARY_KEYS = dict(
    patients="patient_id", admissions="admission_id", diagnoses="diagnosis_id",
    healthcare_professionals="professional_id", hospital_units="unit_id",
    icd9_dictionary="icd9_code", triage_assessments="triage_id", unit_stays="unit_stay_id",
    clinical_notes="note_id", discharge_records="discharge_id", diagnostic_orders="order_id",
    diagnostic_examinations="examination_id", radiology_examinations="radiology_id",
    radiology_reports="report_id", surgical_procedures="procedure_id",
)

STAFF = "healthcare_professionals"
REFERENCES = dict(
    admissions=dict(patient_id="patients", admitting_professional_id=STAFF),
    diagnoses=dict(patient_id="patients", admission_id="admissions", icd9_code="icd9_dictionary",
                   diagnosing_physician_id=STAFF),
    triage_assessments=dict(admission_id="admissions", nurse_id=STAFF),
    unit_stays=dict(admission_id="admissions", unit_id="hospital_units", responsible_physician_id=STAFF),
    clinical_notes=dict(admission_id="admissions", author_id=STAFF),
    discharge_records=dict(admission_id="admissions", responsible_physician_id=STAFF),
    diagnostic_orders=dict(patient_id="patients", admission_id="admissions", ordering_physician_id=STAFF),
    diagnostic_examinations=dict(order_id="diagnostic_orders", performed_by_id=STAFF),
    radiology_examinations=dict(examination_id="diagnostic_examinations", referring_physician_id=STAFF,
                                technician_id=STAFF),
    radiology_reports=dict(radiology_id="radiology_examinations", radiologist_id=STAFF),
    surgical_procedures=dict(admission_id="admissions", surgeon_id=STAFF),
)


def counts_for_scale(targets, scale):
    if scale == "full":
        return dict(targets)
    ratio = SAMPLE_PATIENTS / targets["patients"]
    counts = {table: max(1, round(target * ratio)) for table, target in targets.items()}
    for table in ("hospital_units", "icd9_dictionary"):
        counts[table] = targets[table]
    counts["healthcare_professionals"] = max(5, counts["healthcare_professionals"])
    return counts


def visit_counts(patient_count, admission_count, rng):
    # Leave the last two patients without admissions. Give patient 1 four
    # visits for the Phase 1 readmission example.
    active_ids = list(range(1, patient_count - 1))
    counts = {patient_id: 1 for patient_id in active_ids}
    counts[1] = 4
    remaining = admission_count - sum(counts.values())
    if remaining < 0:
        raise ValueError("Admission target too small for the planned cases")
    others = active_ids[1:]
    rng.shuffle(others)
    for offset in range(remaining):
        counts[others[offset % len(others)]] += 1
    return counts


def make_patients(source, count, rng):
    return [
        {
            "patient_id": patient_id,
            "first_name": f"Given{source}{patient_id:04d}",
            "last_name": f"Patient{source}{patient_id:04d}",
            "date_of_birth": (
                datetime(1940, 1, 1) + timedelta(days=rng.randrange(27000))
            ).date().isoformat(),
            "gender": rng.choice(("Male", "Female")),
            "health_insurance_number": f"P2-{source}-{patient_id:05d}",
            "address": None,
            "phone_number": None,
            "emergency_contact_info": None,
            "life_status": "Alive",
            "date_of_death": None,
        }
        for patient_id in range(1, count + 1)
    ]


def make_admissions(patients, visits, completed_count, rng, start):
    # Only the last visit can be open or end in death.
    admission_count = sum(visits.values())
    eligible = [pid for pid in visits if pid != 1]
    open_count = admission_count - completed_count
    if not 0 <= open_count <= len(eligible):
        raise ValueError("Discharge target is incompatible with the visit plan")
    open_patients = set(rng.sample(eligible, open_count))
    closed_patients = [pid for pid in eligible if pid not in open_patients]
    deceased = set(rng.sample(closed_patients, max(1, admission_count // 80)))

    admissions = []
    for patient in patients:
        pid = patient["patient_id"]
        n = visits.get(pid, 0)
        for visit in range(n):
            last = visit == n - 1
            entry = start + timedelta(days=(pid % 100) + 20 * visit)
            duration = (
                timedelta(days=8 if visit == 0 else 7)
                if pid == 1 and visit < 2
                else timedelta(hours=rng.randint(5, 120))
            )
            discharge = entry + duration
            status = "Discharged"
            if last and pid in open_patients:
                status = "Admitted"
                discharge = None
            elif last and pid in deceased:
                status = "Deceased"
                patient["life_status"] = "Deceased"
                patient["date_of_death"] = discharge.isoformat()
            admission_type = rng.choice(("Emergency", "Urgent", "Elective", "Outpatient"))
            admissions.append({
                "admission_id": len(admissions) + 1,
                "patient_id": pid,
                "admitting_professional_id": None,  # Staff is added next.
                "admission_datetime": entry.isoformat(),
                "discharge_datetime": discharge.isoformat() if discharge else None,
                "admission_type": admission_type,
                "admission_source": (
                    "Emergency Department" if admission_type == "Emergency" else "Referral"
                ),
                "reason_for_admission": "Synthetic encounter",
                "current_condition": None,
                "insurance_info": None,
                "admission_status": status,
            })
    return admissions


def make_diagnoses(admissions, count, rng):
    diagnoses = []

    def add(admission, code, kind, hour):
        entry = datetime.fromisoformat(admission["admission_datetime"])
        diagnoses.append({
            "diagnosis_id": len(diagnoses) + 1,
            "patient_id": admission["patient_id"],
            "admission_id": admission["admission_id"],
            "icd9_code": code,
            "diagnosing_physician_id": None,  # Staff is added next.
            "diagnosis_datetime": (entry + timedelta(hours=hour)).isoformat(),
            "diagnosis_type": kind,
        })

    secondary_slots = []
    for admission in admissions:
        completed = admission["admission_status"] != "Admitted"
        code = rng.choice(ICD9_CODES)
        add(admission, code, "Primary" if completed else "Preliminary", 1)
        if completed:
            secondary = rng.choice([value for value in ICD9_CODES if value != code])
            secondary_slots.append((admission, secondary))

    remaining = count - len(diagnoses)
    if not 0 <= remaining <= len(secondary_slots):
        raise ValueError("Diagnosis target is incompatible with the admission plan")
    rng.shuffle(secondary_slots)
    for admission, code in secondary_slots[:remaining]:
        add(admission, code, "Secondary", 2)
    return diagnoses


def validate_source(source, rows, counts, field_maps):
    def require(condition, detail):
        if not condition:
            raise ValueError(f"Source {source}: {detail}")

    for table, key in zip(CORE_TABLES, ("patient_id", "admission_id", "diagnosis_id")):
        values = rows[table]
        ids = [row[key] for row in values]
        require(len(values) == counts[table], f"wrong {table} count")
        require(ids == list(range(1, len(ids) + 1)), f"invalid {table} local IDs")
        expected = set(field_maps[source, table].values())
        require(all(set(row) == expected for row in values), f"{table} fields differ from KR-1")

    patients = {row["patient_id"]: row for row in rows["patients"]}
    admissions = {row["admission_id"]: row for row in rows["admissions"]}
    primary_counts = Counter()
    diagnosis_counts = Counter()
    visits = defaultdict(list)
    for admission in admissions.values():
        pid = admission["patient_id"]
        aid = admission["admission_id"]
        require(pid in patients, f"admission {aid} references missing patient {pid}")
        entry = datetime.fromisoformat(admission["admission_datetime"])
        exit_value = admission["discharge_datetime"]
        status = admission["admission_status"]
        require((exit_value is None) == (status == "Admitted"), f"admission {aid} status mismatch")
        require(not exit_value or datetime.fromisoformat(exit_value) > entry,
                f"admission {aid} discharge is not after entry")
        visits[pid].append(admission)
        if status == "Deceased":
            require(patients[pid]["life_status"] == "Deceased"
                    and patients[pid]["date_of_death"] == exit_value,
                    f"admission {aid} death does not match patient")

    for pid, episodes in visits.items():
        ordered = sorted(episodes, key=lambda row: row["admission_datetime"])
        for earlier, later in zip(ordered, ordered[1:]):
            require(earlier["admission_status"] == "Discharged" and
                    earlier["discharge_datetime"] <= later["admission_datetime"],
                    f"patient {pid} has overlapping or post-death visits")

    for diagnosis in rows["diagnoses"]:
        aid = diagnosis["admission_id"]
        require(aid in admissions, f"diagnosis references missing admission {aid}")
        admission = admissions[aid]
        require(diagnosis["patient_id"] == admission["patient_id"],
                f"diagnosis patient does not match admission {aid}")
        require(diagnosis["icd9_code"] in ICD9_CODES, "unknown ICD-9 code")
        when = diagnosis["diagnosis_datetime"]
        require(when >= admission["admission_datetime"] and
                (not admission["discharge_datetime"] or when <= admission["discharge_datetime"]),
                f"diagnosis outside admission {aid}")
        diagnosis_counts[aid] += 1
        primary_counts[aid] += diagnosis["diagnosis_type"] == "Primary"

    completed = 0
    for aid, admission in admissions.items():
        closed = admission["admission_status"] != "Admitted"
        completed += closed
        require(diagnosis_counts[aid] >= 1 and primary_counts[aid] == int(closed),
                f"admission {aid} diagnosis or primary count is wrong")
    require(completed == counts["discharge_records"], "wrong completed admission count")
    require(len(patients) - len(visits) == 2, "expected two patients without admissions")
    require(any(len(episodes) > 3 for episodes in visits.values()), "no frequent-admission case")


def complete_entities(source, rows, counts, rng):
    admissions = rows["admissions"]
    closed = [a for a in admissions if a["discharge_datetime"]]
    open_visits = [a for a in admissions if not a["discharge_datetime"]]
    roles = ("Physician", "Surgeon", "Nurse", "Radiologist", "Technician")
    units = ("Emergency", "ICU", "CCU", "MICU", "SICU", "General Ward",
             "Other", "General Ward")
    rows.update({
        "healthcare_professionals": [
            dict(professional_id=i, first_name=f"Staff{source}{i:03d}",
                 last_name=f"Provider{source}{i:03d}", role=roles[(i - 1) % len(roles)],
                 specialty=None)
            for i in range(1, counts["healthcare_professionals"] + 1)
        ],
        "hospital_units": [
            dict(unit_id=i, unit_name=f"{kind} {i}", unit_type=kind)
            for i, kind in enumerate(units, 1)
        ],
        "icd9_dictionary": [
            dict(icd9_code=code, official_title=title, description=None, disease_category=None)
            for code, title in ICD9_REFERENCE.items()
        ],
    })

    def staff(role):
        return rng.choice([p["professional_id"] for p in rows["healthcare_professionals"]
                           if p["role"] == role])

    def after(admission, minutes):
        return (datetime.fromisoformat(admission["admission_datetime"]) +
                timedelta(minutes=minutes)).isoformat()

    def add(table, **fields):
        entries = rows.setdefault(table, [])
        entries.append({PRIMARY_KEYS[table]: len(entries) + 1, **fields})
        return entries[-1]

    for patient in rows["patients"]:
        i = patient["patient_id"]
        patient.update(address=f"Synthetic address {source}-{i}",
                       phone_number=f"555-01{i % 100:02d}",
                       emergency_contact_info=f"Synthetic contact {i}")
    for a in admissions:
        a["admitting_professional_id"] = staff("Physician")
    for d in rows["diagnoses"]:
        d["diagnosing_physician_id"] = staff("Physician")
    admissions[0].update(admission_type="Emergency", admission_source="Emergency Department")

    for i, a in enumerate(admissions[:counts["triage_assessments"]]):
        add("triage_assessments", admission_id=a["admission_id"], nurse_id=staff("Nurse"),
            assessment_datetime=after(a, 10),
            priority_level=("High-Priority Emergency", "Urgent", "Non-Urgent")[i % 3],
            blood_pressure="120/80", heart_rate=72 + i % 18, respiratory_rate=16,
            body_temperature=round(36.4 + (i % 9) / 10, 1), oxygen_saturation=98.0,
            pain_level=i % 8, reported_symptoms="Synthetic triage presentation",
            known_allergies=None, current_medications=None)

    def stay(a, unit, entry, exit_time, reason=None):
        add("unit_stays", admission_id=a["admission_id"], unit_id=unit,
            responsible_physician_id=staff("Physician"), ward_and_room=f"W{unit}-01",
            bed_number=str(a["admission_id"]), entry_datetime=entry,
            exit_datetime=exit_time, reason_for_transfer=reason)

    a, b, c, d = admissions[:4]
    stay(a, 1, a["admission_datetime"], after(a, 120))
    stay(a, 2, after(a, 120), a["discharge_datetime"], "Transfer to ICU")
    stay(b, 2, b["admission_datetime"], b["discharge_datetime"])
    stay(c, 3, c["admission_datetime"], c["discharge_datetime"])
    stay(d, 4, d["admission_datetime"], after(d, 120))
    stay(d, 5, after(d, 120), d["discharge_datetime"], "Transfer to SICU")
    stay(open_visits[0], 6, open_visits[0]["admission_datetime"], None)
    later = closed[4:]
    extra = counts["unit_stays"] - len(rows["unit_stays"]) - len(later)
    if not 0 <= extra <= len(later):
        raise ValueError("Unit-stay count cannot be met by the fixture plan")
    for i, a in enumerate(later):
        if i < extra:
            transfer_unit = 2 + (i % 4)
            stay(a, 1 if a["admission_source"] == "Emergency Department" else 6,
                 a["admission_datetime"], after(a, 150))
            stay(a, transfer_unit, after(a, 150), a["discharge_datetime"], "Transfer")
        else:
            stay(a, 6, a["admission_datetime"], a["discharge_datetime"])

    for i, a in enumerate(closed[:counts["clinical_notes"] - 1]):
        kind, content = (
            ("Discharge Summary", "Recovery documented in synthetic summary."),
            ("Discharge Summary", "Follow-up documented in synthetic summary."),
            ("Progress Note", "Recovery mentioned in synthetic progress note."),
            ("Initial Assessment", "Synthetic initial evaluation."),
        )[i % 4]
        add("clinical_notes", admission_id=a["admission_id"], author_id=staff("Physician"),
            note_type=kind, note_datetime=(a["discharge_datetime"] if kind == "Discharge Summary"
                                           else after(a, 30)), note_contents=content)
    # Same timestamp, different note IDs: latest-note queries can break the tie.
    first = closed[0]
    add("clinical_notes", admission_id=first["admission_id"], author_id=staff("Physician"),
        note_type="Discharge Summary", note_datetime=first["discharge_datetime"],
        note_contents="Synthetic discharge addendum with revised follow-up.")
    for a in closed:
        died = a["admission_status"] == "Deceased"
        add("discharge_records", admission_id=a["admission_id"],
            responsible_physician_id=staff("Physician"),
            discharge_destination="Morgue" if died else "Home",
            discharge_condition="Deceased" if died else "Improved",
            prescribed_medications=None,
            follow_up_instructions=None if died else "Synthetic follow-up advice",
            follow_up_appointment_datetime=None)

    # Imaging includes both ICU and general-ward admissions. Use at least one
    # general-ward case even at sample scale.
    general = closed[4 + extra:]
    imaging_pool = [closed[0], general[0], *closed[1:4]]
    used = {a["admission_id"] for a in imaging_pool}
    imaging_pool.extend(a for a in closed if a["admission_id"] not in used)
    for i, a in enumerate(imaging_pool[:counts["diagnostic_orders"]]):
        examined = i < counts["diagnostic_examinations"]
        imaging = i < counts["radiology_examinations"]
        exam_type = (("Chest X-Ray", "CT Chest", "MRI Brain")[i % 3]
                     if imaging else "Blood Test")
        doctor = staff("Physician")
        order = add("diagnostic_orders", patient_id=a["patient_id"],
                    admission_id=a["admission_id"], ordering_physician_id=doctor,
                    order_datetime=after(a, 20), requested_examination=exam_type,
                    clinical_reason="Synthetic diagnostic workup",
                    priority="STAT" if i % 4 == 0 else "Routine",
                    order_status="Completed" if examined else "Ordered")
        if examined:
            tech = staff("Technician")
            exam = add("diagnostic_examinations", order_id=order["order_id"],
                       performed_by_id=tech, examination_type=exam_type,
                       examination_datetime=after(a, 40), examination_status="Completed",
                       result_summary="Synthetic result")
            if imaging:
                radiology = add("radiology_examinations", examination_id=exam["examination_id"],
                                referring_physician_id=doctor, technician_id=tech,
                                body_area="Head" if exam_type == "MRI Brain" else "Chest",
                                image_link=None)
                if i < counts["radiology_reports"]:
                    add("radiology_reports", radiology_id=radiology["radiology_id"],
                        radiologist_id=staff("Radiologist"), report_datetime=after(a, 100),
                        findings="Synthetic imaging findings", impression="Synthetic impression")

    for i, a in enumerate(closed[:counts["surgical_procedures"]]):
        add("surgical_procedures", admission_id=a["admission_id"], surgeon_id=staff("Surgeon"),
            procedure_name=("Coronary artery bypass grafting", "Laparoscopic appendectomy",
                            "Internal fixation of femoral neck fracture")[i % 3],
            procedure_datetime=after(a, 60), operating_room="OR-1",
            procedure_notes="Synthetic procedure note")


def validate_entities(source, rows, counts, field_maps):
    def check(ok, detail):
        if not ok:
            raise ValueError(f"Source {source}: {detail}")

    check(set(rows) == set(counts) == set(PRIMARY_KEYS), "table list differs from KR-1")
    ids = {}
    for table, values in rows.items():
        check(len(values) == counts[table], f"wrong {table} count")
        check(all(set(r) == set(field_maps[source, table].values()) for r in values),
              f"{table} fields differ from KR-1")
        key = PRIMARY_KEYS[table]
        ids[table] = {r[key]: r for r in values}
        check(None not in ids[table] and len(ids[table]) == len(values), f"invalid {table} keys")
    for table, references in REFERENCES.items():
        for r in rows[table]:
            for key, parent in references.items():
                check(r[key] is None or r[key] in ids[parent], f"broken {table}.{key}")

    def inside(a, when):
        return a["admission_datetime"] <= when and (
            a["discharge_datetime"] is None or when <= a["discharge_datetime"]
        )

    admissions = ids["admissions"]
    for table, col in (("triage_assessments", "assessment_datetime"),
                       ("clinical_notes", "note_datetime"),
                       ("surgical_procedures", "procedure_datetime"),
                       ("diagnostic_orders", "order_datetime"),
                       ("unit_stays", "entry_datetime")):
        for r in rows[table]:
            check(inside(admissions[r["admission_id"]], r[col]), f"{table}.{col} outside visit")
    for r in rows["unit_stays"]:
        a = admissions[r["admission_id"]]
        exit_time = r["exit_datetime"]
        check((exit_time is None and a["admission_status"] == "Admitted")
              or (exit_time and inside(a, exit_time) and r["entry_datetime"] < exit_time),
              "invalid unit exit")
    for r in rows["diagnostic_orders"]:
        check(r["patient_id"] == admissions[r["admission_id"]]["patient_id"], "order patient mismatch")
    for r in rows["diagnostic_examinations"]:
        order = ids["diagnostic_orders"][r["order_id"]]
        when = r["examination_datetime"]
        check(inside(admissions[order["admission_id"]], when) and order["order_datetime"] <= when,
              "examination before order or outside visit")
    for r in rows["radiology_reports"]:
        rad = ids["radiology_examinations"][r["radiology_id"]]
        exam = ids["diagnostic_examinations"][rad["examination_id"]]
        check(r["report_datetime"] >= exam["examination_datetime"], "report before examination")
    for table, key in (("discharge_records", "admission_id"), ("radiology_examinations", "examination_id"),
                       ("radiology_reports", "radiology_id"), ("patients", "health_insurance_number")):
        check(len({r[key] for r in rows[table]}) == len(rows[table]), f"duplicate {table}.{key}")
    for r in rows["discharge_records"]:
        status = admissions[r["admission_id"]]["admission_status"]
        check(status != "Admitted" and (status == "Deceased") ==
              (r["discharge_condition"] == "Deceased"), "discharge record status mismatch")


def generate(scale):
    config = runpy.run_path(str(MAP_PATH))
    dataset = {}
    for offset, source in enumerate(SOURCES):
        rng = random.Random(SEED + offset)
        counts = counts_for_scale(config["TARGET_COUNTS"][source], scale)
        patients = make_patients(source, counts["patients"], rng)
        visits = visit_counts(counts["patients"], counts["admissions"], rng)
        start = START + timedelta(days=160 if source in ("B", "D") else 0)
        admissions = make_admissions(patients, visits, counts["discharge_records"], rng, start)
        diagnoses = make_diagnoses(admissions, counts["diagnoses"], rng)
        rows = {"patients": patients, "admissions": admissions, "diagnoses": diagnoses}
        validate_source(source, rows, counts, config["FIELD_MAPS"])
        complete_entities(source, rows, counts, rng)
        validate_entities(source, rows, counts, config["FIELD_MAPS"])
        dataset[source] = rows
    return dataset


ISSUE_COLUMNS = (
    "source", "entity", "local_id", "issue", "field",
    "original_value", "planted_value", "status", "details",
)


def inject_errors(dataset, scale, rates):
    """Mutate validated records; return the generator-only answer key."""
    events = []

    def log(source, table, row, issue, field, old, new, details="", status="applied"):
        events.append(dict(zip(ISSUE_COLUMNS, (
            source, table, row[PRIMARY_KEYS[table]], issue, field,
            json.dumps(old, ensure_ascii=False), json.dumps(new, ensure_ascii=False),
            status, details,
        ))))

    def replace(source, table, row, issue, field, value):
        log(source, table, row, issue, field, row[field], value)
        row[field] = value

    def pick(rng, pool, count):
        return rng.sample(pool, min(count, len(pool)))

    # The first patient in each source retains the readmission examples. Visit
    # windows are separated for true matches in the two designated source pairs.
    protected_patients = {source: {1} for source in SOURCES}
    for i, (left, right) in enumerate((("A", "B"), ("C", "D"))):
        rng = random.Random(SEED + 200 + i)
        per_kind = ((13, 5, 5) if i == 0 else (12, 5, 5)) if scale == "full" else (2, 1, 1)
        candidates = []
        for source in (left, right):
            ongoing = {a["patient_id"] for a in dataset[source]["admissions"]
                       if a["admission_status"] == "Admitted"}
            candidates.append([p for p in dataset[source]["patients"][1:-2]
                               if p["life_status"] == "Alive" and p["patient_id"] not in ongoing])
        pairs = iter(zip(*(pick(rng, pool, sum(per_kind)) for pool in candidates)))
        for kind, count in zip(("cross_source_true_match", "cross_source_name_only",
                                "cross_source_uncertain"), per_kind):
            for _ in range(count):
                a, b = next(pairs)
                protected_patients[left].add(a["patient_id"])
                protected_patients[right].add(b["patient_id"])
                for source, patient in ((left, a), (right, b)):
                    other_source, other = (right, b) if source == left else (left, a)
                    changes = {}
                    if source == right:
                        changes.update(first_name=a["first_name"], last_name=a["last_name"])
                        if kind != "cross_source_name_only":
                            changes.update(date_of_birth=a["date_of_birth"], gender=a["gender"])
                        elif b["date_of_birth"] == a["date_of_birth"]:
                            changes["date_of_birth"] = "1939-01-01"
                        if kind == "cross_source_true_match":
                            changes["health_insurance_number"] = a["health_insurance_number"]
                    if kind == "cross_source_uncertain":
                        changes["health_insurance_number"] = None
                    log(source, "patients", patient, kind, "(identity)",
                        {field: patient[field] for field in changes}, changes,
                        details=f"Counterpart: {other_source} patient {other['patient_id']}")
                    patient.update(changes)

    for i, (source, rows) in enumerate(dataset.items()):
        rng = random.Random(SEED + 300 + i)

        def choose(pool, issue, basis=None):
            rate = rates[issue][source]
            if not rate:
                return []
            return pick(rng, pool, max(1, round(rate * (len(pool) if basis is None else basis))))

        # Copy exact duplicates only after edits. If an admission is serialized
        # twice in a nested source, attach its children to the first copy only.
        exact = "exact_duplicate_admissions_and_diagnoses"
        original = {table: list(values) for table, values in rows.items()}
        # Preserve two no-admission patients and the first four visit fixtures.
        patient_pool = [p for p in original["patients"][:-2]
                        if p["patient_id"] not in protected_patients[source]]
        admission_pool = original["admissions"][4:]
        note_pool = [n for n in original["clinical_notes"] if n["admission_id"] > 4]
        triage_pool = original["triage_assessments"][4:]
        stay_pool = [s for s in original["unit_stays"]
                     if s["admission_id"] > 4 and s["exit_datetime"] is not None]
        diagnosis_pool = [d for d in original["diagnoses"] if d["admission_id"] > 4]
        altered = set()

        def eligible(pool):
            return [row for row in pool if id(row) not in altered]

        def change(table, pool, issue, field, value, basis=None):
            for r in choose(eligible(pool), issue, basis):
                replace(source, table, r, issue, field, value(r))
                altered.add(id(r))

        issue = "within_source_duplicate_patients"
        for r in choose(patient_pool, issue, len(original["patients"])):
            duplicate = dict(r, patient_id=len(rows["patients"]) + 1,
                             last_name=f" {r['last_name'].upper()} ")
            rows["patients"].append(duplicate)
            log(source, "patients", duplicate, issue, "patient_id", r["patient_id"],
                duplicate["patient_id"], "Same insurance number and date of birth")
            altered.add(id(r))

        change("clinical_notes", note_pool, "missing_required", "note_contents", lambda _: None)
        change("patients", patient_pool, "missing_optional", "phone_number", lambda _: None)
        change("admissions", admission_pool, "case_or_space", "admission_type",
               lambda r: f" {r['admission_type'].upper()} ")
        change("clinical_notes", note_pool, "invalid_date", "note_datetime",
               lambda _: "2026-02-30T09:00:00", len(original["clinical_notes"]))
        change("triage_assessments", triage_pool, "invalid_numeric", "pain_level", lambda _: 15)
        change("diagnoses", diagnosis_pool, "broken_reference", "icd9_code",
               lambda _: "999.99")
        change("unit_stays", stay_pool, "chronology", "exit_datetime",
               lambda r: (datetime.fromisoformat(r["entry_datetime"]) -
                          timedelta(minutes=5)).isoformat())

        # Keep the dictionary itself correct. Only selected foreign-key text
        # values carry known formatting defects that a loader can normalize.
        formatted = [d for d in diagnosis_pool if "." in d["icd9_code"]
                     and (source != "D" or d["icd9_code"].startswith("0"))]
        change("diagnoses", formatted, "icd9_format", "icd9_code",
               lambda r: (r["icd9_code"].replace(".", "") if source == "B"
                          else r["icd9_code"].lstrip("0")), len(diagnosis_pool))

        secondaries = {r["admission_id"] for r in original["diagnoses"]
                       if r["diagnosis_type"] == "Secondary"}
        primaries = [r for r in diagnosis_pool if r["diagnosis_type"] == "Primary"
                     and r["admission_id"] in secondaries]
        issue = "missing_primary"
        for r in choose(eligible(primaries), issue, len(admission_pool)):
            rows["diagnoses"].remove(r)
            altered.add(id(r))
            log(source, "diagnoses", r, issue, "(record)", r, None,
                f"Admission {r['admission_id']} retains a secondary diagnosis")

        # These cases are annotations for the raw-format writers. The preview
        # retains the canonical data; pending rows are never counted as applied.
        issue = "malformed_rows"
        for r in choose(eligible(note_pool), issue, len(original["clinical_notes"])):
            log(source, "clinical_notes", r, issue, "(line)", None,
                "wrong number of fields", "Apply after writing TXT or CSV", "pending_serialization")
            altered.add(id(r))
        issue = "ambiguous_day_first"
        ambiguous = [r for r in note_pool
                     if r["note_datetime"][8:10] <= "12"
                     and r["note_datetime"][5:7] != r["note_datetime"][8:10]]
        for r in choose(eligible(ambiguous), issue, len(original["clinical_notes"])):
            old = r["note_datetime"]
            example = datetime.fromisoformat(old).strftime("%d/%m/%Y %I:%M %p")
            log(source, "clinical_notes", r, issue, "note_datetime", old, example,
                "Write a day-first local string rather than an epoch value",
                "pending_serialization")

        for table, pool in (("admissions", admission_pool), ("diagnoses", diagnosis_pool)):
            for r in choose(eligible(pool), exact, len(original[table])):
                rows[table].append(r.copy())
                log(source, table, r, exact, "(record)", None, r,
                    f"Duplicate occurrence appended at position {len(rows[table])}")

    return events


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scale", choices=("sample", "full"), default="sample")
    parser.add_argument("--preview", type=Path, help="Optional intermediate JSON preview path")
    parser.add_argument("--inject-errors", action="store_true",
                        help="Apply controlled data issues after clean checks")
    parser.add_argument("--issues-log", type=Path,
                        help="CSV answer key path (required with --inject-errors)")
    args = parser.parse_args()
    if args.inject_errors != bool(args.issues_log):
        parser.error("--inject-errors and --issues-log must be used together")
    outputs = [path for path in (args.preview, args.issues_log) if path is not None]
    if len({path.resolve() for path in outputs}) != len(outputs):
        parser.error("The preview and log need distinct paths")
    for path in outputs:
        if path.exists():
            parser.error(f"Output already exists: {path}; choose a new path")
    dataset = generate(args.scale)
    for source, rows in dataset.items():
        total = sum(map(len, rows.values()))
        print(f"{source}: {len(rows)} tables, {total:,} clean records [checks passed]")
    if args.inject_errors:
        config = runpy.run_path(str(MAP_PATH))
        events = inject_errors(dataset, args.scale, config["INJECTION_RATES"])
        for source, rows in dataset.items():
            total = sum(map(len, rows.values()))
            print(f"{source}: {total:,} records after planting issues")
        totals = Counter(e["status"] for e in events)
        print(f"Ground truth: {totals['applied']} applied entries; "
              f"{totals['pending_serialization']} pending writer entries")
        with args.issues_log.open("x", encoding="utf-8", newline="") as target:
            writer = csv.DictWriter(target, fieldnames=ISSUE_COLUMNS)
            writer.writeheader()
            writer.writerows(events)
        print(f"Issue log: {args.issues_log}")
    if args.preview:
        with args.preview.open("x", encoding="utf-8") as preview:
            json.dump(dataset, preview, ensure_ascii=False, indent=2)
            preview.write("\n")
        print(f"Intermediate preview: {args.preview}")


if __name__ == "__main__":
    main()
