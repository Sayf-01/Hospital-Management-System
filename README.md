# Hospital Management System

A PostgreSQL database for a hospital: patients, admissions, triage, clinical notes, diagnoses (ICD-9),
diagnostic orders and examinations, radiology, surgery, unit stays and discharges.

All data is synthetic. No real patients or staff are represented.

**Team:** Lamees, Sayf, Dany, Krish, Youssef

## Repository layout

```
schema/schema.sql         Tables, constraints, indexes, foreign keys and the radiology_exam_details view
data/data.sql             Data for all 15 tables
data/raw/sample/          Sample source files for the four hospital systems (TXT, CSV, XML, JSON)
sql/phase1/               The 20 queries (query01.sql to query20.sql)
phase2/                   Data integration pipeline: generator, config and documentation
reports/                  Generated counts and logs
docs/er-diagram.png       ER diagram
requirements.txt          Python dependencies
.env.example              Template for your local .env file
```

## Development setup

Requires Python 3.11+. In PowerShell, from the repository folder:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
```

Then put your database connection string in