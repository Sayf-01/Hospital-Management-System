# KR-6: Synthetic hospital sources and AI disclosure

**Course:** SOEN 363, Project Phase 2  
**Contributor:** Krish Patel  
**Prepared:** November 16, 2026  
**Scope:** Source generation and the frozen raw dataset. The team's cleaning,
integration and final SQL validation results are reported separately.

## 1. Source design

Four fictional hospitals were created on four distinct continents. Each hospital
has its own local identifiers and data conventions. No real patient or staff
records were used. The sources represent 15 related entities from the Phase 1
hospital database.

| Source | Fictional hospital | Country and continent | Files and format | Time zone |
|---|---|---|---|---|
| A | Maple Ridge General | Canada, North America | 15 pipe-delimited TXT files | America/Toronto |
| B | Rhine Valley Klinikum | Germany, Europe | 15 semicolon-delimited CSV files | Europe/Berlin |
| C | Sakura Bay Medical Center | Japan, Asia | One nested XML file | Asia/Tokyo |
| D | Southern Cross Hospital | Australia, Oceania | Four JSON files | Australia/Sydney |

A and B use one file per entity. A includes a header and comment lines beginning
with #. B uses UTF-8 with a byte-order mark and standard CSV quoting. In C,
patients contain admissions and their clinical child records; staff, units and
the ICD-9 dictionary appear in separate sections. D has separate staff, unit and
dictionary arrays, plus a patient file containing nested admissions and clinical
records.

### Differences that require standardization

| Property | A | B | C | D |
|---|---|---|---|---|
| Clinical timestamp | 2026-05-01 09:00 | 01.05.2026 09:00 | 2026-05-01T09:00:00+09:00 | Epoch seconds or 01/05/2026 9:00 AM |
| Birth date | YYYY-MM-DD | DD.MM.YYYY | YYYY-MM-DD | DD/MM/YYYY |
| Temperature | Fahrenheit | Celsius, decimal comma | Celsius | Celsius |
| Triage labels | ESI 1, 3 and 5 in generated records | P1, P2, P3 | Red, Yellow, Green | 1, 2, 3 |
| Gender labels | M/F | Male/Female | Male/Female | Male/Female |
| Missing values | Blank, NULL, - | Blank, N/A, ? | Empty or absent elements | JSON null or absent keys |

Source B also uses German admission labels, including Notfall, Dringend,
Geplant and Ambulant. The selected ESI values represent all three target
triage groups; the cleaning contract also defines ESI 2 and 4.

A and B timestamps represent local wall times without an offset. C includes an
explicit Tokyo offset. D converts selected local times using the Sydney time
zone, including its daylight-saving rules, to epoch seconds; its text timestamps
remain local. Source time zones are documented so the cleaning stage can convert
clinical timestamps to UTC. Birth dates remain calendar dates.

The day and month can both be between 1 and 12 in some D strings. These strings
have two possible readings without the contract, but the documented source rule
is day first. They test whether the pipeline uses source-specific parsing.
Impossible dates are separate planted errors and cannot be repaired by assuming
a different date order.

## 2. Generation and hospital workflow

The Python generator uses seed 363 and separate deterministic random streams
for each source and generation stage. It first creates and validates clean
linked records. It then plants controlled problems and writes the source-specific
representations. Using the same code and seed reproduces the full source bytes,
count report and injection log.

Local IDs start at 1 in each source. Consequently, the same identifier can
refer to different entities in different hospitals. The source must accompany
every local ID during integration. Equal local IDs or equal names alone do not
justify merging patients.

The clean generation checks cover field layouts, key uniqueness, foreign-key
links, admission chronology, patient/admission agreement and primary diagnoses
for completed admissions. The workflow includes triage, transfers, diagnostic
orders and examinations, radiology reports, surgery, notes and discharge
information. Open admissions and in-hospital deaths are also present.

Reserved examples include more than three admissions for a patient; critical-care
stays longer than, exactly equal to and shorter than seven days; Emergency
Department arrival followed by ICU; surgery before ICU; same-day surgery and
radiology; patients without admissions or radiology; and notes with and without
the word recovery. These examples support meaningful Phase 1 query testing.
Their presence does not replace rerunning all 20 queries against the final
integrated database.

## 3. Frozen raw record counts

The full dataset contains **30,091 raw entity instances in 35 files**.
Each source is within the assignment's 5,000–10,000 range and the team's
5,500–9,500 safety range. The overall total is within 20,000–40,000.

| Entity | A | B | C | D | Total |
|---|---:|---:|---:|---:|---:|
| healthcare professionals | 48 | 52 | 49 | 52 | 201 |
| hospital units | 8 | 8 | 8 | 8 | 32 |
| icd9 dictionary | 40 | 40 | 40 | 40 | 160 |
| patients | 581 | 636 | 600 | 630 | 2,447 |
| admissions | 960 | 1,061 | 990 | 1,040 | 4,051 |
| triage assessments | 903 | 988 | 931 | 979 | 3,801 |
| unit stays | 1,235 | 1,352 | 1,274 | 1,339 | 5,200 |
| diagnoses | 1,434 | 1,586 | 1,480 | 1,555 | 6,055 |
| clinical notes | 380 | 416 | 392 | 412 | 1,600 |
| discharge records | 903 | 988 | 931 | 979 | 3,801 |
| diagnostic orders | 190 | 208 | 196 | 206 | 800 |
| diagnostic examinations | 181 | 198 | 186 | 196 | 761 |
| radiology examinations | 86 | 94 | 88 | 93 | 361 |
| radiology reports | 81 | 88 | 83 | 88 | 340 |
| surgical procedures | 114 | 125 | 118 | 124 | 481 |
| **Total** | **7,144** | **7,840** | **7,366** | **7,741** | **30,091** |

These are source-instance counts before cleaning or integration. A patient,
admission or nested diagnosis each counts once. Headers, attributes, XML tags
and JSON containers do not count. Duplicate entity instances and the two
deliberately malformed note lines are included in the raw totals. The same 40
reference codes are present once per source, giving 160 raw dictionary entries;
there are 40 distinct codes across the sources.

The raw count reconciles with generation as follows:

**29,938 clean records + 47 duplicate patient records + 126 exact duplicate
admission/diagnosis rows − 20 removed primary diagnoses = 30,091 raw records.**

The smaller KR-2 sample contains 2,681 records and is kept separately. It is
excluded from the 30,091 full-data total. Differences between raw counts and
final database counts must later be reconciled through exact deduplication,
entity matching and justified quarantine.

## 4. Controlled data-quality problems

The generator answer key is reports/ground_truth/injected_errors.csv.
It contains **1,035 applied entries and no pending entries**. Each entry records
the source, entity, local ID, problem type, field, original value, planted value
and supporting details. This log is kept outside the raw source directory.
The cleaning pipeline must detect problems from the raw files and must never
use the answer key as an input.

### Counts and approximate injection frequencies

Each nonzero cell below shows **number planted / selection reference count
(percentage)**. These are the actual selection-reference sizes used by the
generator, recovered from a reproducible rerun of its selection functions.
They are not percentages of all records in a source.

| Planted problem | A | B | C | D |
|---|---:|---:|---:|---:|
| Exact admission/diagnosis duplicates | 24/2375 (1.01%) | 52/2600 (2.00%) | 25/2450 (1.02%) | 25/2575 (0.97%) |
| Duplicate patients under new IDs | 11/570 (1.93%) | 12/624 (1.92%) | 12/588 (2.04%) | 12/618 (1.94%) |
| Missing required note contents | 4/375 (1.07%) | 4/411 (0.97%) | 4/387 (1.03%) | 4/407 (0.98%) |
| Missing optional phone numbers | 53/533 (9.94%) | 59/586 (10.07%) | 55/551 (9.98%) | 58/581 (9.98%) |
| Admission label case/whitespace | 47/946 (4.97%) | 52/1036 (5.02%) | 49/976 (5.02%) | 51/1026 (4.97%) |
| Invalid note dates | 4/380 (1.05%) | 4/416 (0.96%) | 4/392 (1.02%) | 4/412 (0.97%) |
| Ambiguous-looking day-first dates | 0 | 0 | 0 | 12/412 (2.91%) |
| Invalid triage pain levels | 9/899 (1.00%) | 10/984 (1.02%) | 9/927 (0.97%) | 10/975 (1.03%) |
| Diagnosis codes absent from dictionary | 7/1420 (0.49%) | 12/1555 (0.77%) | 7/1466 (0.48%) | 12/1541 (0.78%) |
| Unit exit before entry | 12/1228 (0.98%) | 13/1345 (0.97%) | 13/1267 (1.03%) | 13/1332 (0.98%) |
| Malformed note lines | 1/380 (0.26%) | 1/416 (0.24%) | 0 | 0 |
| ICD-9 formatting differences | 0 | 78/1555 (5.02%) | 0 | 77/1541 (5.00%) |
| Removed primary diagnoses | 5/946 (0.53%) | 5/1036 (0.48%) | 5/976 (0.51%) | 5/1026 (0.49%) |

For exact duplicates, the reference is the combined original admission and
diagnosis population, with rounding applied separately to each entity. Duplicate
patient selection uses the original patient count. Other references use the
eligible entity pool or the explicit original-entity count passed by the
generator. Protected examples and previously selected records can reduce an
eligible pool. Counts therefore need not equal a nominal percentage of the
entire table.

Missing required values and invalid dates occur in clinical notes. Optional
missing-value injections remove patient phone numbers. Invalid numeric examples
set triage pain levels to 15. Broken references assign diagnosis code 999.99,
which is absent from the supplied dictionaries. Chronology errors place unit
exit five minutes before entry. Malformed A/B note lines omit the final field.
Missing-primary cases remove the primary row while retaining a secondary
diagnosis.

ICD-9 representation problems include 0030 in B instead of 003.0, and
38.9 in D instead of 038.9. The authoritative reference dictionaries remain
correct. The differences in missing-value markers, units and source labels
also arise during serialization; the 1,035 log entries do not enumerate every
ordinary missing field or format conversion in the files.

### Duplicate entities across sources

| Identity scenario | A–B pairs | C–D pairs | Total pairs |
|---|---:|---:|---:|
| True matches | 13 | 12 | 25 |
| Same name, different person | 5 | 5 | 10 |
| Uncertain matches | 5 | 5 | 10 |

True-match pairs share names, birth date, gender and the synthetic insurance
identifier. Same-name nonmatches have different birth dates. Uncertain pairs
share names and birth date but lack insurance evidence. The matching rules must
keep uncertain cases separate unless later evidence justifies a merge.

Both sides of each pair are logged: 25 true pairs produce 50 entries; 10
same-name pairs produce 20 entries; and 10 uncertain pairs produce 20 entries.
Thus, 1,035 log entries are not 1,035 rejected records or necessarily 1,035
distinct erroneous rows. Repeated local identifiers across sources occur by
design and are not separately logged for every occurrence.

### Expected usability

The freeze audit conservatively marks potentially affected records, including
descendants of admissions that lose a primary diagnosis. Exposure is 83 records
in A (1.162%), 109 in B (1.390%), 97 in C (1.317%) and 98 in D (1.266%).
Each is below the team's approximately 5% limit. This is a planted-risk estimate,
not an observed rejection rate. Optional invalid values can sometimes be kept
as null with a flag; unrecoverable required facts must be quarantined with a
reason rather than invented.

## 5. ICD-9 reference verification

The dictionary contains 40 distinct diagnosis codes checked against the Centers
for Medicare & Medicaid Services (CMS) ICD-9-CM Version 32 reference [1]. The
archive member used was CMS32_DESC_LONG_DX.txt.

For verification, the decimal point was removed from each generated code and
the resulting string was matched to the reference key. Leading zeros were
retained. Each stored official title was compared with the reference title.
A repeated check on November 16, 2026 found **40 matches and zero missing codes
or title mismatches**. This reference comparison was run in the assistant's
Python environment; it is not presented as a separate manual Windows check
by Krish.

Codes remain strings throughout generation and serialization. For example,
038.9 retains its leading zero, and 250.00 retains its decimal formatting.
Controlled variants occur only in selected diagnosis records; these should be
normalized against the verified reference rather than interpreted as numbers.

## 6. Reproducibility and freeze

The full files are stored in data/raw/full/. The freeze script independently
regenerates all 35 full files in a temporary directory and compares them with
the existing files, count report and answer key. It then writes SHA-256 hashes
to data/raw/checksums.txt and makes the raw files and manifest read-only on
the local machine.

The manifest covers 70 raw files: 35 full files and 35 existing sample files.
Git attributes preserve the bytes without automatic line-ending conversion.
Read-only permissions are local protection and do not automatically survive
a Git checkout; the checksum verifier provides the portable integrity check.

Krish's posted Windows output confirms generation of 30,091 raw records and
successful verification of all 70 hashes. An independent compatibility run
with LA-1 also reconciled 30,089 loaded rows plus two malformed records against
all 60 source/entity counts. Final SQL integrity and integration results belong
to the team's later validation sections.

The frozen files must not be edited during cleaning. Any approved regeneration
requires updated checksums, validation and team notification. Raw sources and
database dumps are retained for the demonstration and excluded from the final
submission ZIP, as required by the assignment.

## 7. Individual contribution and AI assistance

Krish Patel was the team member responsible for delivering KR-1, KR-2 and KR-3:
the source design, synthetic datasets, controlled data-quality problems, source
files and full-data freeze. He added the files to the project, installed the
required dependencies, ran the generation and verification commands on Windows,
checked the reported outputs, and managed his branches and commits. His shared
terminal results confirm successful sample generation, full-data generation and
checksum verification. This section documents his assigned contribution to the
team project.

ChatGPT supported this work by drafting generator and freeze code, suggesting
checks, assisting with troubleshooting, and drafting documentation. Additional
reference comparisons and compatibility checks were run in the assistant's
Python environment and are identified separately in this report. Krish's
execution and version-control work should be credited to him; AI-assisted code
and writing are disclosed as such. The team remains responsible for reviewing
the implementation, explaining it during the demonstration and validating the
final integrated database.

### Assistance record

| Date | Tool and purpose | Prompt summary | Review and verification |
|---|---|---|---|
| November 10, 2026 | ChatGPT: source design and KR-2 implementation | Define four hospital source layouts; generate linked fictional records; plant controlled errors; write TXT, CSV, XML and JSON. | Mappings cover 15 entities per source. Clean sample checks passed. The writer read back 35 files and counted 2,681 instances. |
| November 16, 2026 | ChatGPT: KR-3 freeze preparation | Check teammates' branches, generate full data, audit planted risks and add freeze/checksum verification. | Krish ran the full writer and freeze on Windows and shared passing output. Assistant-side loader and reproducibility checks were also performed. |
| November 16, 2026 | ChatGPT: KR-6 report preparation | | Tables were calculated from frozen count and injection reports. All 40 ICD-9 titles were rechecked against CMS. Krish reviews the wording before inclusion in the group report. |

The first two prompt entries summarize multi-turn requests rather than claiming
to reproduce complete verbatim prompts. The related conversation, source code
and generation logs provide the supporting record. No real patient information
or database credentials are included in this section.

## Reference

[1] Centers for Medicare & Medicaid Services, “ICD-9-CM Diagnosis and Procedure
Codes: Abbreviated and Full Code Titles,” Version 32 download. Accessed:
Nov. 16, 2026.
https://www.cms.gov/medicare/coding-billing/icd-10-codes/icd-9-cm-diagnosis-procedure-codes-abbreviated-and-full-code-titles

Reference archive:
https://www.cms.gov/Medicare/Coding/ICD9ProviderDiagnosticCodes/Downloads/ICD-9-CM-v32-master-descriptions.zip
