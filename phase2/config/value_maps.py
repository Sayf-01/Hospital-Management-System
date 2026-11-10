"""Source-specific category labels mapped to Phase 1 values."""

VALUE_MAPS: dict[str, dict[str, dict[str, str]]] = {
    "admission_type": {
        "A": {
            "Emergency": "Emergency",
            "Urgent": "Urgent",
            " URGENT ": "Urgent",
            "Elective": "Elective",
            " ELECTIVE ": "Elective",
            "Outpatient": "Outpatient",
            " OUTPATIENT ": "Outpatient",
        },
        "B": {
            "Notfall": "Emergency",
            " NOTFALL ": "Emergency",
            "Dringend": "Urgent",
            " DRINGEND ": "Urgent",
            "Geplant": "Elective",
            " GEPLANT ": "Elective",
            "Ambulant": "Outpatient",
        },
        "C": {
            "Emergency": "Emergency",
            "EMERGENCY": "Emergency",
            "Urgent": "Urgent",
            "URGENT": "Urgent",
            "Elective": "Elective",
            "ELECTIVE": "Elective",
            "Outpatient": "Outpatient",
        },
        "D": {
            "Emergency": "Emergency",
            " EMERGENCY ": "Emergency",
            "Urgent": "Urgent",
            " URGENT ": "Urgent",
            "Elective": "Elective",
            "Outpatient": "Outpatient",
        },
    },
    "admission_source": {
        source: {
            "Emergency Department": "Emergency Department",
            "Referral": "Referral",
        }
        for source in "ABCD"
    },
    "admission_status": {
        source: {
            "Admitted": "Admitted",
            "Discharged": "Discharged",
            "Deceased": "Deceased",
        }
        for source in "ABCD"
    },
    "priority_level": {
        "A": {
            "1": "High-Priority Emergency",
            "2": "High-Priority Emergency",
            "3": "Urgent",
            "4": "Non-Urgent",
            "5": "Non-Urgent",
        },
        "B": {
            "P1": "High-Priority Emergency",
            "P2": "Urgent",
            "P3": "Non-Urgent",
        },
        "C": {
            "Red": "High-Priority Emergency",
            "Yellow": "Urgent",
            "Green": "Non-Urgent",
        },
        "D": {
            "1": "High-Priority Emergency",
            "2": "Urgent",
            "3": "Non-Urgent",
        },
    },
    "gender": {
        "A": {"M": "Male", "F": "Female"},
        **{
            source: {"Male": "Male", "Female": "Female"}
            for source in "BCD"
        },
    },
    "unit_type": {
        source: {
            "Emergency": "Emergency",
            "General Ward": "General Ward",
            "MICU": "MICU",
            "SICU": "SICU",
            "ICU": "ICU",
            "CCU": "CCU",
            "Other": "Other",
        }
        for source in "ABCD"
    },
    "diagnosis_type": {
        source: {
            "Primary": "Primary",
            "Secondary": "Secondary",
            "Preliminary": "Preliminary",
        }
        for source in "ABCD"
    },
    "note_type": {
        source: {
            "Initial Assessment": "Initial Assessment",
            "Progress Note": "Progress Note",
            "Discharge Summary": "Discharge Summary",
        }
        for source in "ABCD"
    },
    "discharge_condition": {
        source: {"Improved": "Improved", "Deceased": "Deceased"}
        for source in "ABCD"
    },
    "role": {
        source: {
            "Physician": "Physician",
            "Surgeon": "Surgeon",
            "Nurse": "Nurse",
            "Radiologist": "Radiologist",
            "Technician": "Technician",
        }
        for source in "ABCD"
    },
    "life_status": {
        source: {"Alive": "Alive", "Deceased": "Deceased"}
        for source in "ABCD"
    },
}


def _normalize_label(label: str) -> str:
    return " ".join(label.split()).casefold()


def map_category(source: str, field: str, raw_value: object) -> str | None:
    """Return a Phase 1 category; raise ValueError for an unknown non-null label."""
    source_maps = VALUE_MAPS[field]
    if source not in source_maps:
        raise KeyError(f"No {field!r} category map for source {source!r}")
    if raw_value is None:
        return None

    raw_label = str(raw_value)
    labels = source_maps[source]
    if raw_label in labels:
        return labels[raw_label]

    normalized_label = _normalize_label(raw_label)
    for label, mapped_value in labels.items():
        if _normalize_label(label) == normalized_label:
            return mapped_value

    raise ValueError(
        f"Unknown {field!r} label for source {source!r}: {raw_label!r}"
    )
