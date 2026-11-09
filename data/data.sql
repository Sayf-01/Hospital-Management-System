--
-- PostgreSQL database dump
--

\restrict K2HAUxYGZmX5Df9G2n2c70LYphTaFCtm4N75oh4d8ZoIu0K0eiyz8UPdSgMxx4a

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-11-09 16:58:25

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5157 (class 0 OID 16456)
-- Dependencies: 231
-- Data for Name: healthcare_professionals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.healthcare_professionals (professional_id, first_name, last_name, role, specialty) FROM stdin;
1	Alven	Simstaff01	Physician	Cardiology
2	Nerina	Simstaff02	Physician	Internal Medicine
3	Tovian	Simstaff03	Physician	Emergency Medicine
4	Selani	Simstaff04	Physician	Respiratory Medicine
5	Karelin	Simstaff05	Surgeon	Cardiac Surgery
6	Mavora	Simstaff06	Surgeon	General Surgery
7	Delvian	Simstaff07	Surgeon	Orthopaedic Surgery
8	Elora	Simstaff08	Nurse	Emergency Nursing
9	Ravena	Simstaff09	Nurse	Critical Care Nursing
10	Fenora	Simstaff10	Nurse	Medical Ward Nursing
11	Loravi	Simstaff11	Radiologist	Diagnostic Radiology
12	Orven	Simstaff12	Radiologist	Diagnostic Radiology
13	Vareli	Simstaff13	Technician	Radiology
14	Javrin	Simstaff14	Technician	Laboratory
15	Corali	Simstaff15	Technician	Cardiac Diagnostics
16	Zerina	Simstaff16	Nurse	Surgical Nursing
\.


--
-- TOC entry 5162 (class 0 OID 16480)
-- Dependencies: 236
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patients (patient_id, first_name, last_name, date_of_birth, gender, health_insurance_number, address, phone_number, emergency_contact_info, life_status, date_of_death) FROM stdin;
1	Avelin	Testwell01	1953-03-15	Female	SYN-HIN-000001	101 Fictional Meadow Lane, Simulated City, QC	514-555-0101	Invented relative Contact-1; 514-555-0150	Alive	\N
2	Mireva	Testwell02	1954-03-15	Male	SYN-HIN-000002	102 Fictional Meadow Lane, Simulated City, QC	514-555-0102	Invented relative Contact-2; 514-555-0151	Alive	\N
3	Tarin	Testwell03	1955-03-15	Female	SYN-HIN-000003	103 Fictional Meadow Lane, Simulated City, QC	514-555-0103	Invented relative Contact-3; 514-555-0152	Alive	\N
4	Selora	Testwell04	1976-05-05	Male	SYN-HIN-000004	104 Fictional Meadow Lane, Simulated City, QC	514-555-0104	Invented relative Contact-4; 514-555-0153	Alive	\N
5	Kavren	Testwell05	1983-06-06	Female	SYN-HIN-000005	105 Fictional Meadow Lane, Simulated City, QC	514-555-0105	Invented relative Contact-5; 514-555-0154	Alive	\N
6	Nerali	Testwell06	1990-07-07	Male	SYN-HIN-000006	106 Fictional Meadow Lane, Simulated City, QC	514-555-0106	Invented relative Contact-6; 514-555-0155	Alive	\N
7	Dovian	Testwell07	1959-03-15	Female	SYN-HIN-000007	107 Fictional Meadow Lane, Simulated City, QC	514-555-0107	Invented relative Contact-7; 514-555-0156	Deceased	2026-08-13 09:00:00
8	Elvani	Testwell08	1960-03-15	Male	SYN-HIN-000008	108 Fictional Meadow Lane, Simulated City, QC	514-555-0108	Invented relative Contact-8; 514-555-0157	Deceased	2026-08-19 09:00:00
9	Raviel	Testwell09	1956-10-10	Female	SYN-HIN-000009	109 Fictional Meadow Lane, Simulated City, QC	514-555-0109	Invented relative Contact-9; 514-555-0158	Alive	\N
10	Lunara	Testwell10	1963-11-11	Male	SYN-HIN-000010	110 Fictional Meadow Lane, Simulated City, QC	514-555-0110	Invented relative Contact-10; 514-555-0159	Alive	\N
11	Navira	Testwell11	1970-12-12	Female	\N	111 Fictional Meadow Lane, Simulated City, QC	514-555-0111	Invented relative Contact-11; 514-555-0160	Alive	\N
12	Corven	Testwell12	1977-01-13	Male	SYN-HIN-000012	112 Fictional Meadow Lane, Simulated City, QC	514-555-0112	Invented relative Contact-12; 514-555-0161	Alive	\N
13	Amelith	Testwell13	1984-02-14	Female	SYN-HIN-000013	113 Fictional Meadow Lane, Simulated City, QC	514-555-0113	Invented relative Contact-13; 514-555-0162	Alive	\N
14	Soravi	Testwell14	1966-03-15	Male	SYN-HIN-000014	114 Fictional Meadow Lane, Simulated City, QC	514-555-0114	Invented relative Contact-14; 514-555-0163	Alive	\N
15	Delrin	Testwell15	1998-04-16	Female	SYN-HIN-000015	115 Fictional Meadow Lane, Simulated City, QC	514-555-0115	Invented relative Contact-15; 514-555-0164	Alive	\N
16	Vivora	Testwell16	1968-03-15	Male	SYN-HIN-000016	116 Fictional Meadow Lane, Simulated City, QC	514-555-0116	Invented relative Contact-16; 514-555-0165	Alive	\N
17	Talven	Testwell17	1957-06-18	Female	SYN-HIN-000017	117 Fictional Meadow Lane, Simulated City, QC	514-555-0117	Invented relative Contact-17; 514-555-0166	Alive	\N
18	Marinel	Testwell18	1970-03-15	Male	SYN-HIN-000018	118 Fictional Meadow Lane, Simulated City, QC	514-555-0118	Invented relative Contact-18; 514-555-0167	Alive	\N
19	Orelia	Testwell19	1971-08-20	Female	SYN-HIN-000019	119 Fictional Meadow Lane, Simulated City, QC	514-555-0119	Invented relative Contact-19; 514-555-0168	Alive	\N
20	Fenric	Testwell20	1978-09-21	Male	SYN-HIN-000020	120 Fictional Meadow Lane, Simulated City, QC	514-555-0120	Invented relative Contact-20; 514-555-0169	Alive	\N
21	Anvori	Testwell21	1985-10-22	Female	SYN-HIN-000021	121 Fictional Meadow Lane, Simulated City, QC	514-555-0121	Invented relative Contact-21; 514-555-0170	Alive	\N
22	Belora	Testwell22	1992-11-23	Male	\N	122 Fictional Meadow Lane, Simulated City, QC	514-555-0122	Invented relative Contact-22; 514-555-0171	Alive	\N
23	Cedrin	Testwell23	1999-12-24	Female	SYN-HIN-000023	123 Fictional Meadow Lane, Simulated City, QC	514-555-0123	Invented relative Contact-23; 514-555-0172	Alive	\N
24	Dareli	Testwell24	1951-01-25	Male	SYN-HIN-000024	124 Fictional Meadow Lane, Simulated City, QC	514-555-0124	Invented relative Contact-24; 514-555-0173	Alive	\N
25	Esvara	Testwell25	1958-02-26	Female	SYN-HIN-000025	125 Fictional Meadow Lane, Simulated City, QC	514-555-0125	Invented relative Contact-25; 514-555-0174	Alive	\N
26	Fioren	Testwell26	1965-03-27	Male	SYN-HIN-000026	126 Fictional Meadow Lane, Simulated City, QC	514-555-0126	Invented relative Contact-26; 514-555-0175	Alive	\N
27	Gavira	Testwell27	1972-04-01	Female	SYN-HIN-000027	127 Fictional Meadow Lane, Simulated City, QC	514-555-0127	Invented relative Contact-27; 514-555-0176	Alive	\N
28	Helori	Testwell28	1979-05-02	Male	SYN-HIN-000028	128 Fictional Meadow Lane, Simulated City, QC	514-555-0128	Invented relative Contact-28; 514-555-0177	Alive	\N
29	Iveran	Testwell29	1986-06-03	Female	SYN-HIN-000029	129 Fictional Meadow Lane, Simulated City, QC	514-555-0129	Invented relative Contact-29; 514-555-0178	Alive	\N
30	Jorali	Testwell30	1993-07-04	Male	SYN-HIN-000030	130 Fictional Meadow Lane, Simulated City, QC	514-555-0130	Invented relative Contact-30; 514-555-0179	Alive	\N
31	Kelora	Testwell31	2000-08-05	Female	SYN-HIN-000031	131 Fictional Meadow Lane, Simulated City, QC	514-555-0131	Invented relative Contact-31; 514-555-0180	Alive	\N
32	Lorven	Testwell32	1952-09-06	Male	SYN-HIN-000032	132 Fictional Meadow Lane, Simulated City, QC	514-555-0132	Invented relative Contact-32; 514-555-0181	Alive	\N
33	Maveli	Testwell33	1959-10-07	Female	\N	133 Fictional Meadow Lane, Simulated City, QC	514-555-0133	Invented relative Contact-33; 514-555-0182	Alive	\N
34	Noreth	Testwell34	1966-11-08	Male	SYN-HIN-000034	134 Fictional Meadow Lane, Simulated City, QC	514-555-0134	Invented relative Contact-34; 514-555-0183	Alive	\N
35	Osvira	Testwell35	1973-12-09	Female	SYN-HIN-000035	135 Fictional Meadow Lane, Simulated City, QC	514-555-0135	Invented relative Contact-35; 514-555-0184	Alive	\N
36	Peralin	Testwell36	1980-01-10	Male	SYN-HIN-000036	136 Fictional Meadow Lane, Simulated City, QC	514-555-0136	Invented relative Contact-36; 514-555-0185	Alive	\N
37	Quenora	Testwell37	1987-02-11	Female	SYN-HIN-000037	137 Fictional Meadow Lane, Simulated City, QC	514-555-0137	Invented relative Contact-37; 514-555-0186	Alive	\N
38	Relvin	Testwell38	1994-03-12	Male	SYN-HIN-000038	138 Fictional Meadow Lane, Simulated City, QC	514-555-0138	Invented relative Contact-38; 514-555-0187	Alive	\N
39	Savari	Testwell39	2001-04-13	Female	SYN-HIN-000039	139 Fictional Meadow Lane, Simulated City, QC	514-555-0139	Invented relative Contact-39; 514-555-0188	Alive	\N
40	Toriel	Testwell40	1953-05-14	Male	SYN-HIN-000040	140 Fictional Meadow Lane, Simulated City, QC	514-555-0140	Invented relative Contact-40; 514-555-0189	Alive	\N
41	Uvella	Testwell41	1960-06-15	Female	SYN-HIN-000041	141 Fictional Meadow Lane, Simulated City, QC	514-555-0141	Invented relative Contact-41; 514-555-0190	Alive	\N
42	Valrin	Testwell42	1967-07-16	Male	SYN-HIN-000042	142 Fictional Meadow Lane, Simulated City, QC	514-555-0142	Invented relative Contact-42; 514-555-0191	Alive	\N
43	Wenora	Testwell43	1974-08-17	Female	SYN-HIN-000043	143 Fictional Meadow Lane, Simulated City, QC	514-555-0143	Invented relative Contact-43; 514-555-0192	Alive	\N
44	Xaveli	Testwell44	1981-09-18	Male	\N	144 Fictional Meadow Lane, Simulated City, QC	514-555-0144	Invented relative Contact-44; 514-555-0193	Alive	\N
45	Yorven	Testwell45	1988-10-19	Female	SYN-HIN-000045	145 Fictional Meadow Lane, Simulated City, QC	514-555-0145	Invented relative Contact-45; 514-555-0194	Alive	\N
46	Zelari	Testwell46	1995-11-20	Male	SYN-HIN-000046	146 Fictional Meadow Lane, Simulated City, QC	514-555-0146	Invented relative Contact-46; 514-555-0195	Alive	\N
47	Arvella	Testwell47	2002-12-21	Female	SYN-HIN-000047	147 Fictional Meadow Lane, Simulated City, QC	514-555-0147	Invented relative Contact-47; 514-555-0196	Alive	\N
48	Brinori	Testwell48	1954-01-22	Male	SYN-HIN-000048	148 Fictional Meadow Lane, Simulated City, QC	514-555-0148	Invented relative Contact-48; 514-555-0197	Alive	\N
49	Cavren	Testwell49	1961-02-23	Female	SYN-HIN-000049	149 Fictional Meadow Lane, Simulated City, QC	514-555-0149	Invented relative Contact-49; 514-555-0198	Alive	\N
50	Delyra	Testwell50	1968-03-24	Male	SYN-HIN-000050	150 Fictional Meadow Lane, Simulated City, QC	514-555-0150	Invented relative Contact-50; 514-555-0199	Alive	\N
\.


--
-- TOC entry 5145 (class 0 OID 16385)
-- Dependencies: 219
-- Data for Name: admissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admissions (admission_id, patient_id, admitting_professional_id, admission_datetime, discharge_datetime, admission_type, admission_source, reason_for_admission, current_condition, insurance_info, admission_status) FROM stdin;
1	1	1	2026-05-01 09:00:00	2026-05-31 09:00:00	Emergency	Emergency Department	Acute chest pain with suspected myocardial infarction	Requires prompt assessment and close monitoring	Synthetic educational coverage SYN-POL-0001	Discharged
2	1	1	2026-06-05 09:00:00	2026-06-15 09:00:00	Emergency	Emergency Department	Acute chest pain with suspected myocardial infarction	Requires prompt assessment and close monitoring	Synthetic educational coverage SYN-POL-0001	Discharged
3	1	1	2026-07-01 09:00:00	2026-07-11 09:00:00	Emergency	Emergency Department	Acute chest pain with suspected myocardial infarction	Requires prompt assessment and close monitoring	Synthetic educational coverage SYN-POL-0001	Discharged
4	1	1	2026-08-01 09:00:00	2026-08-03 09:00:00	Emergency	Emergency Department	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0001	Discharged
5	1	2	2026-09-01 09:00:00	2026-09-01 21:00:00	Emergency	Emergency Department	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0001	Discharged
6	2	1	2026-05-02 09:00:00	2026-06-01 09:00:00	Emergency	Emergency Department	Acute chest pain with suspected myocardial infarction	Requires prompt assessment and close monitoring	Synthetic educational coverage SYN-POL-0002	Discharged
7	2	1	2026-06-05 09:00:00	2026-06-10 09:00:00	Urgent	Referral	Acute chest pain with suspected myocardial infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0002	Discharged
8	2	1	2026-07-10 09:00:00	2026-07-13 09:00:00	Emergency	Emergency Department	Acute chest pain with suspected myocardial infarction	Requires prompt assessment and close monitoring	Synthetic educational coverage SYN-POL-0002	Discharged
9	2	2	2026-08-10 09:00:00	2026-08-13 09:00:00	Elective	Referral	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0002	Discharged
10	3	4	2026-05-01 09:00:00	2026-05-08 09:00:00	Urgent	Transfer from Another Hospital	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0003	Discharged
11	3	4	2026-06-01 09:00:00	2026-06-11 09:00:00	Urgent	Referral	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0003	Discharged
12	3	4	2026-07-01 09:00:00	2026-07-07 09:00:00	Emergency	Emergency Department	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0003	Discharged
13	4	1	2026-07-10 08:00:00	2026-07-10 11:00:00	Outpatient	Walk-in	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0004	Discharged
14	4	2	2026-07-10 13:00:00	2026-07-10 18:00:00	Outpatient	Referral	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0004	Discharged
15	5	2	2026-08-01 09:00:00	2026-08-01 12:00:00	Urgent	Walk-in	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0005	Discharged
16	6	2	2026-08-05 09:00:00	2026-08-08 09:00:00	Urgent	Walk-in	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0006	Discharged
17	6	2	2026-09-05 09:00:00	2026-09-07 09:00:00	Urgent	Walk-in	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0006	Discharged
18	7	2	2026-08-10 09:00:00	2026-08-13 09:00:00	Emergency	Emergency Department	Severe infection with suspected septicemia	Requires prompt assessment and close monitoring	Synthetic educational coverage SYN-POL-0007	Deceased
19	8	4	2026-08-15 09:00:00	2026-08-19 09:00:00	Emergency	Emergency Department	Fever and cough with pneumonia	Requires prompt assessment and close monitoring	Synthetic educational coverage SYN-POL-0008	Deceased
20	7	2	2026-04-01 09:00:00	2026-04-03 09:00:00	Urgent	Referral	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0007	Discharged
21	10	2	2026-08-25 09:00:00	2026-08-26 09:00:00	Emergency	Emergency Department	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0010	Discharged
22	11	2	2026-09-01 09:00:00	2026-09-03 09:00:00	Emergency	Emergency Department	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0011	Discharged
23	12	4	2026-09-02 09:00:00	2026-09-05 09:00:00	Emergency	Emergency Department	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0012	Discharged
24	13	1	2026-09-03 09:00:00	2026-09-06 09:00:00	Urgent	Referral	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0013	Discharged
25	10	1	2026-09-04 09:00:00	2026-09-05 09:00:00	Urgent	Referral	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0010	Discharged
26	15	1	2026-09-05 09:00:00	2026-09-05 13:00:00	Outpatient	Walk-in	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0015	Discharged
27	16	1	2026-09-06 09:00:00	\N	Emergency	Emergency Department	Breathlessness and fluid overload	Requires prompt assessment and close monitoring	Synthetic educational coverage SYN-POL-0016	Admitted
28	17	1	2026-09-07 09:00:00	2026-09-11 09:00:00	Emergency	Emergency Department	Acute chest pain with suspected myocardial infarction	Requires prompt assessment and close monitoring	Synthetic educational coverage SYN-POL-0017	Discharged
29	18	2	2026-03-01 09:00:00	\N	Urgent	Transfer from Another Hospital	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0018	Admitted
30	19	2	2026-09-08 09:00:00	2026-09-08 21:00:00	Emergency	Emergency Department	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0019	Discharged
31	13	1	2026-07-01 09:00:00	2026-07-03 09:00:00	Urgent	Referral	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0013	Discharged
32	20	2	2026-06-05 09:00:00	2026-06-06 03:00:00	Elective	Emergency Department	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0020	Discharged
33	20	2	2026-07-10 09:00:00	2026-07-11 15:00:00	Elective	Referral	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0020	Discharged
34	20	1	2026-08-14 09:00:00	2026-08-16 03:00:00	Urgent	Emergency Department	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0020	Discharged
35	21	2	2026-05-02 09:00:00	2026-05-03 03:00:00	Elective	Emergency Department	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0021	Discharged
36	21	2	2026-06-06 09:00:00	2026-06-07 15:00:00	Elective	Referral	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0021	Discharged
37	21	1	2026-07-11 09:00:00	2026-07-13 03:00:00	Urgent	Emergency Department	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0021	Discharged
38	21	1	2026-08-15 09:00:00	2026-08-17 15:00:00	Outpatient	Referral	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0021	Discharged
39	22	2	2026-05-03 09:00:00	2026-05-04 15:00:00	Elective	Referral	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0022	Discharged
40	22	1	2026-06-07 09:00:00	2026-06-09 03:00:00	Urgent	Emergency Department	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0022	Discharged
41	22	1	2026-07-12 09:00:00	2026-07-14 15:00:00	Outpatient	Referral	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0022	Discharged
42	22	2	2026-08-16 09:00:00	2026-08-16 15:00:00	Urgent	Emergency Department	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0022	Discharged
43	23	1	2026-05-04 09:00:00	2026-05-06 03:00:00	Urgent	Emergency Department	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0023	Discharged
44	23	1	2026-06-08 09:00:00	2026-06-10 15:00:00	Outpatient	Referral	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0023	Discharged
45	23	2	2026-07-13 09:00:00	2026-07-13 15:00:00	Urgent	Emergency Department	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0023	Discharged
46	24	1	2026-05-05 09:00:00	2026-05-07 15:00:00	Outpatient	Referral	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0024	Discharged
47	24	2	2026-06-09 09:00:00	2026-06-09 15:00:00	Urgent	Emergency Department	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0024	Discharged
48	24	2	2026-07-14 09:00:00	2026-07-15 03:00:00	Urgent	Referral	Outpatient lipid assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0024	Discharged
49	25	2	2026-05-06 09:00:00	2026-05-06 15:00:00	Urgent	Emergency Department	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0025	Discharged
50	25	2	2026-06-10 09:00:00	2026-06-11 03:00:00	Urgent	Referral	Outpatient lipid assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0025	Discharged
51	25	2	2026-07-15 09:00:00	2026-07-16 15:00:00	Urgent	Emergency Department	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0025	Discharged
52	26	2	2026-05-07 09:00:00	2026-05-08 03:00:00	Urgent	Referral	Outpatient lipid assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0026	Discharged
53	26	2	2026-06-11 09:00:00	2026-06-12 15:00:00	Urgent	Emergency Department	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0026	Discharged
54	26	2	2026-07-16 09:00:00	2026-07-18 03:00:00	Outpatient	Referral	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0026	Discharged
55	27	2	2026-05-08 09:00:00	2026-05-09 15:00:00	Urgent	Emergency Department	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0027	Discharged
56	27	2	2026-06-12 09:00:00	2026-06-14 03:00:00	Outpatient	Referral	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0027	Discharged
57	27	4	2026-07-17 09:00:00	2026-07-19 15:00:00	Urgent	Emergency Department	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0027	Discharged
58	28	2	2026-05-09 09:00:00	2026-05-11 03:00:00	Outpatient	Referral	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0028	Discharged
59	28	4	2026-06-13 09:00:00	2026-06-15 15:00:00	Urgent	Emergency Department	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0028	Discharged
60	28	2	2026-07-18 09:00:00	2026-07-18 15:00:00	Elective	Referral	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0028	Discharged
61	29	4	2026-05-10 09:00:00	2026-05-12 15:00:00	Urgent	Emergency Department	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0029	Discharged
62	29	2	2026-06-14 09:00:00	2026-06-14 15:00:00	Elective	Referral	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0029	Discharged
63	29	2	2026-07-19 09:00:00	2026-07-20 03:00:00	Elective	Emergency Department	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0029	Discharged
64	30	2	2026-05-11 09:00:00	2026-05-11 15:00:00	Elective	Referral	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0030	Discharged
65	30	2	2026-06-15 09:00:00	2026-06-16 03:00:00	Elective	Emergency Department	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0030	Discharged
66	30	1	2026-07-20 09:00:00	2026-07-21 15:00:00	Outpatient	Referral	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0030	Discharged
67	31	2	2026-05-12 09:00:00	2026-05-13 03:00:00	Elective	Emergency Department	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0031	Discharged
68	31	1	2026-06-16 09:00:00	2026-06-17 15:00:00	Outpatient	Referral	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0031	Discharged
69	31	1	2026-07-21 09:00:00	2026-07-23 03:00:00	Urgent	Emergency Department	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0031	Discharged
70	32	1	2026-05-13 09:00:00	2026-05-14 15:00:00	Outpatient	Referral	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0032	Discharged
71	32	1	2026-06-17 09:00:00	2026-06-19 03:00:00	Urgent	Emergency Department	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0032	Discharged
72	32	2	2026-07-22 09:00:00	2026-07-24 15:00:00	Urgent	Referral	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0032	Discharged
73	33	1	2026-05-14 09:00:00	2026-05-16 03:00:00	Urgent	Emergency Department	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0033	Discharged
74	33	2	2026-06-18 09:00:00	2026-06-20 15:00:00	Urgent	Referral	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0033	Discharged
75	33	2	2026-07-23 09:00:00	2026-07-23 15:00:00	Urgent	Emergency Department	Outpatient lipid assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0033	Discharged
76	34	2	2026-05-15 09:00:00	2026-05-17 15:00:00	Urgent	Referral	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0034	Discharged
77	34	2	2026-06-19 09:00:00	2026-06-19 15:00:00	Urgent	Emergency Department	Outpatient lipid assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0034	Discharged
78	34	2	2026-07-24 09:00:00	2026-07-25 03:00:00	Outpatient	Referral	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0034	Discharged
79	35	2	2026-05-16 09:00:00	2026-05-16 15:00:00	Urgent	Emergency Department	Outpatient lipid assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0035	Discharged
80	35	2	2026-06-20 09:00:00	2026-06-21 03:00:00	Outpatient	Referral	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0035	Discharged
81	35	2	2026-07-25 09:00:00	2026-07-26 15:00:00	Urgent	Emergency Department	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0035	Discharged
82	36	2	2026-05-17 09:00:00	2026-05-18 03:00:00	Outpatient	Referral	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0036	Discharged
83	36	2	2026-06-21 09:00:00	2026-06-22 15:00:00	Urgent	Emergency Department	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0036	Discharged
84	36	4	2026-07-26 09:00:00	2026-07-28 03:00:00	Urgent	Referral	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0036	Discharged
85	37	2	2026-05-18 09:00:00	2026-05-19 15:00:00	Urgent	Emergency Department	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0037	Discharged
86	37	4	2026-06-22 09:00:00	2026-06-24 03:00:00	Urgent	Referral	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0037	Discharged
87	37	2	2026-07-27 09:00:00	2026-07-29 15:00:00	Elective	Emergency Department	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0037	Discharged
88	38	4	2026-05-19 09:00:00	2026-05-21 03:00:00	Urgent	Referral	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0038	Discharged
89	38	2	2026-06-23 09:00:00	2026-06-25 15:00:00	Elective	Emergency Department	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0038	Discharged
90	38	2	2026-07-28 09:00:00	2026-07-28 15:00:00	Elective	Referral	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0038	Discharged
91	39	2	2026-05-20 09:00:00	2026-05-22 15:00:00	Elective	Emergency Department	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0039	Discharged
92	39	2	2026-06-24 09:00:00	2026-06-24 15:00:00	Elective	Referral	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0039	Discharged
93	39	1	2026-07-29 09:00:00	2026-07-30 03:00:00	Urgent	Emergency Department	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0039	Discharged
94	40	2	2026-05-01 09:00:00	2026-05-01 15:00:00	Elective	Referral	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0040	Discharged
95	40	1	2026-06-05 09:00:00	2026-06-06 03:00:00	Urgent	Emergency Department	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0040	Discharged
96	40	1	2026-07-10 09:00:00	2026-07-11 15:00:00	Urgent	Referral	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0040	Discharged
97	41	1	2026-05-02 09:00:00	2026-05-03 03:00:00	Urgent	Emergency Department	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0041	Discharged
98	41	1	2026-06-06 09:00:00	2026-06-07 15:00:00	Urgent	Referral	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0041	Discharged
99	41	2	2026-07-11 09:00:00	2026-07-13 03:00:00	Urgent	Emergency Department	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0041	Discharged
100	42	1	2026-05-03 09:00:00	2026-05-04 15:00:00	Urgent	Referral	Chest pain requiring diagnostic assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0042	Discharged
101	42	2	2026-06-07 09:00:00	2026-06-09 03:00:00	Urgent	Emergency Department	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0042	Discharged
102	42	2	2026-07-12 09:00:00	2026-07-14 15:00:00	Outpatient	Referral	Outpatient lipid assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0042	Discharged
103	43	2	2026-05-04 09:00:00	2026-05-06 03:00:00	Urgent	Emergency Department	Neurological monitoring and rehabilitation after cerebral infarction	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0043	Discharged
104	43	2	2026-06-08 09:00:00	2026-06-10 15:00:00	Outpatient	Referral	Outpatient lipid assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0043	Discharged
105	43	2	2026-07-13 09:00:00	2026-07-13 15:00:00	Urgent	Emergency Department	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0043	Discharged
106	44	2	2026-05-05 09:00:00	2026-05-07 15:00:00	Outpatient	Referral	Outpatient lipid assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0044	Discharged
107	44	2	2026-06-09 09:00:00	2026-06-09 15:00:00	Urgent	Emergency Department	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0044	Discharged
108	44	2	2026-07-14 09:00:00	2026-07-15 03:00:00	Urgent	Referral	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0044	Discharged
109	45	2	2026-05-06 09:00:00	2026-05-06 15:00:00	Urgent	Emergency Department	Elevated blood pressure requiring assessment	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0045	Discharged
110	45	2	2026-06-10 09:00:00	2026-06-11 03:00:00	Urgent	Referral	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0045	Discharged
111	45	4	2026-07-15 09:00:00	2026-07-16 15:00:00	Urgent	Emergency Department	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0045	Discharged
112	46	2	2026-05-07 09:00:00	2026-05-08 03:00:00	Urgent	Referral	Diabetes review and glucose monitoring	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0046	Discharged
113	46	4	2026-06-11 09:00:00	2026-06-12 15:00:00	Urgent	Emergency Department	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0046	Discharged
114	46	2	2026-07-16 09:00:00	2026-07-18 03:00:00	Elective	Referral	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0046	Discharged
115	47	4	2026-05-08 09:00:00	2026-05-09 15:00:00	Urgent	Emergency Department	Fever and cough with pneumonia	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0047	Discharged
116	47	2	2026-06-12 09:00:00	2026-06-14 03:00:00	Elective	Referral	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0047	Discharged
117	47	2	2026-07-17 09:00:00	2026-07-19 15:00:00	Elective	Emergency Department	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0047	Discharged
118	48	2	2026-05-09 09:00:00	2026-05-11 03:00:00	Elective	Referral	Acute abdominal pain with appendicitis	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0048	Discharged
119	48	2	2026-06-13 09:00:00	2026-06-15 15:00:00	Elective	Emergency Department	Hip pain after a fall with femoral neck fracture	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0048	Discharged
120	48	1	2026-07-18 09:00:00	2026-07-18 15:00:00	Urgent	Referral	Breathlessness and fluid overload	Stable enough for planned assessment	Synthetic educational coverage SYN-POL-0048	Discharged
\.


--
-- TOC entry 5147 (class 0 OID 16401)
-- Dependencies: 221
-- Data for Name: clinical_notes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clinical_notes (note_id, admission_id, author_id, note_type, note_datetime, note_contents) FROM stdin;
1	1	1	Initial Assessment	2026-05-01 09:24:00	Fictional encounter 1: Acute chest pain with suspected myocardial infarction. Assessment and planned investigations recorded.
2	1	1	Progress Note	2026-05-02 09:00:00	Fictional progress review for encounter 1. Observations and response to care reviewed.
3	1	1	Discharge Summary	2026-05-31 09:00:00	Fictional discharge summary for encounter 1. recovery was satisfactory. Follow-up information and medication review provided.
4	2	1	Initial Assessment	2026-06-05 09:24:00	Fictional encounter 2: Acute chest pain with suspected myocardial infarction. Assessment and planned investigations recorded.
5	2	1	Progress Note	2026-06-06 09:00:00	Fictional progress review for encounter 2. Observations and response to care reviewed.
6	2	1	Discharge Summary	2026-06-15 09:00:00	Fictional discharge summary for encounter 2. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
7	3	1	Initial Assessment	2026-07-01 09:24:00	Fictional encounter 3: Acute chest pain with suspected myocardial infarction. Assessment and planned investigations recorded.
8	3	1	Progress Note	2026-07-02 09:00:00	Fictional progress review for encounter 3. Observations and response to care reviewed.
9	3	1	Discharge Summary	2026-07-11 09:00:00	Fictional discharge summary for encounter 3. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
10	4	1	Initial Assessment	2026-08-01 09:24:00	Fictional encounter 4: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
11	4	1	Progress Note	2026-08-02 09:00:00	Fictional progress review for encounter 4. Observations and response to care reviewed.
12	4	1	Discharge Summary	2026-08-03 09:00:00	Fictional discharge summary for encounter 4. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
13	5	2	Initial Assessment	2026-09-01 09:24:00	Fictional encounter 5: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
14	5	2	Progress Note	2026-09-01 15:00:00	Fictional progress review for encounter 5. Observations and response to care reviewed.
15	5	2	Discharge Summary	2026-09-01 21:00:00	Fictional discharge summary for encounter 5. recovery was satisfactory. Follow-up information and medication review provided.
16	5	2	Progress Note	2026-09-01 21:00:00	Fictional final review at the same timestamp as the discharge summary.
17	5	2	Progress Note	2026-09-01 10:00:00	Fictional late-entered note carrying an earlier clinical timestamp.
18	6	1	Initial Assessment	2026-05-02 09:24:00	Fictional encounter 6: Acute chest pain with suspected myocardial infarction. Assessment and planned investigations recorded.
19	6	1	Progress Note	2026-05-03 09:00:00	Fictional progress review for encounter 6. Observations and response to care reviewed.
20	6	1	Discharge Summary	2026-06-01 09:00:00	Fictional discharge summary for encounter 6. Recovery was satisfactory. Follow-up information and medication review provided.
21	7	1	Initial Assessment	2026-06-05 09:24:00	Fictional encounter 7: Acute chest pain with suspected myocardial infarction. Assessment and planned investigations recorded.
22	7	1	Progress Note	2026-06-06 09:00:00	Fictional progress review for encounter 7. Observations and response to care reviewed.
23	7	1	Discharge Summary	2026-06-10 09:00:00	Fictional discharge summary for encounter 7. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
24	8	1	Initial Assessment	2026-07-10 09:24:00	Fictional encounter 8: Acute chest pain with suspected myocardial infarction. Assessment and planned investigations recorded.
25	8	1	Progress Note	2026-07-11 09:00:00	Fictional progress review for encounter 8. Observations and response to care reviewed.
26	8	1	Discharge Summary	2026-07-13 09:00:00	Fictional discharge summary for encounter 8. RECOVERY was satisfactory. Follow-up information and medication review provided.
27	9	2	Initial Assessment	2026-08-10 09:24:00	Fictional encounter 9: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
28	9	2	Progress Note	2026-08-11 09:00:00	Fictional progress review for encounter 9. Observations and response to care reviewed.
29	9	2	Discharge Summary	2026-08-13 09:00:00	Fictional discharge summary for encounter 9. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
30	10	4	Initial Assessment	2026-05-01 09:24:00	Fictional encounter 10: Fever and cough with pneumonia. Assessment and planned investigations recorded.
31	10	4	Progress Note	2026-05-02 09:00:00	Fictional progress review for encounter 10. Observations and response to care reviewed.
32	10	4	Discharge Summary	2026-05-08 09:00:00	Fictional discharge summary for encounter 10. recovery was satisfactory. Follow-up information and medication review provided.
33	11	4	Initial Assessment	2026-06-01 09:24:00	Fictional encounter 11: Fever and cough with pneumonia. Assessment and planned investigations recorded.
34	11	4	Progress Note	2026-06-02 09:00:00	Fictional progress review for encounter 11. Observations and response to care reviewed.
35	11	4	Discharge Summary	2026-06-11 09:00:00	Fictional discharge summary for encounter 11. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
36	12	4	Initial Assessment	2026-07-01 09:24:00	Fictional encounter 12: Fever and cough with pneumonia. Assessment and planned investigations recorded.
37	12	4	Progress Note	2026-07-02 09:00:00	Fictional progress review for encounter 12. Observations and response to care reviewed.
38	12	4	Discharge Summary	2026-07-07 09:00:00	Fictional discharge summary for encounter 12. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
39	13	1	Initial Assessment	2026-07-10 08:24:00	Fictional encounter 13: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
40	13	1	Progress Note	2026-07-10 09:30:00	Fictional progress review for encounter 13. Observations and response to care reviewed.
41	13	1	Discharge Summary	2026-07-10 11:00:00	Fictional discharge summary for encounter 13. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
42	14	2	Initial Assessment	2026-07-10 13:24:00	Fictional encounter 14: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
43	14	2	Progress Note	2026-07-10 15:30:00	Fictional progress review for encounter 14. Observations and response to care reviewed.
44	14	2	Discharge Summary	2026-07-10 18:00:00	Fictional discharge summary for encounter 14. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
45	15	2	Initial Assessment	2026-08-01 09:24:00	Fictional encounter 15: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
46	15	2	Progress Note	2026-08-01 10:30:00	Fictional progress review for encounter 15. recovery discussed during assessment.
47	15	2	Discharge Summary	2026-08-01 12:00:00	Fictional discharge summary for encounter 15. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
48	16	2	Initial Assessment	2026-08-05 09:24:00	Fictional encounter 16: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
49	16	2	Progress Note	2026-08-06 09:00:00	Fictional progress review for encounter 16. Observations and response to care reviewed.
50	16	2	Discharge Summary	2026-08-08 09:00:00	Fictional discharge summary for encounter 16. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
51	17	2	Initial Assessment	2026-09-05 09:24:00	Fictional encounter 17: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
52	17	2	Progress Note	2026-09-06 09:00:00	Fictional progress review for encounter 17. Observations and response to care reviewed.
53	17	2	Discharge Summary	2026-09-07 09:00:00	Fictional discharge summary for encounter 17. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
54	18	2	Initial Assessment	2026-08-10 09:24:00	Fictional encounter 18: Severe infection with suspected septicemia. Assessment and planned investigations recorded.
55	18	2	Progress Note	2026-08-11 09:00:00	Fictional progress review for encounter 18. Observations and response to care reviewed.
56	18	2	Discharge Summary	2026-08-13 09:00:00	Fictional encounter 18: clinical deterioration despite care. Death recorded at 2026-08-13 09:00:00. Family contact documented.
57	19	4	Initial Assessment	2026-08-15 09:24:00	Fictional encounter 19: Fever and cough with pneumonia. Assessment and planned investigations recorded.
58	19	4	Progress Note	2026-08-16 09:00:00	Fictional progress review for encounter 19. Observations and response to care reviewed.
59	19	4	Discharge Summary	2026-08-19 09:00:00	Fictional encounter 19: clinical deterioration despite care. Death recorded at 2026-08-19 09:00:00. Family contact documented.
60	20	2	Initial Assessment	2026-04-01 09:24:00	Fictional encounter 20: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
61	20	2	Progress Note	2026-04-02 09:00:00	Fictional progress review for encounter 20. Observations and response to care reviewed.
62	20	2	Discharge Summary	2026-04-03 09:00:00	Fictional discharge summary for encounter 20. recovery was satisfactory. Follow-up information and medication review provided.
63	21	2	Initial Assessment	2026-08-25 09:24:00	Fictional encounter 21: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
64	21	2	Progress Note	2026-08-25 21:00:00	Fictional progress review for encounter 21. Observations and response to care reviewed.
65	21	2	Discharge Summary	2026-08-26 09:00:00	Fictional discharge summary for encounter 21. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
66	22	2	Initial Assessment	2026-09-01 09:24:00	Fictional encounter 22: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
67	22	2	Progress Note	2026-09-02 09:00:00	Fictional progress review for encounter 22. Observations and response to care reviewed.
68	22	2	Discharge Summary	2026-09-03 09:00:00	Fictional discharge summary for encounter 22. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
69	23	4	Initial Assessment	2026-09-02 09:24:00	Fictional encounter 23: Fever and cough with pneumonia. Assessment and planned investigations recorded.
70	23	4	Progress Note	2026-09-03 09:00:00	Fictional progress review for encounter 23. Observations and response to care reviewed.
71	23	4	Discharge Summary	2026-09-05 09:00:00	Fictional discharge summary for encounter 23. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
72	24	1	Initial Assessment	2026-09-03 09:24:00	Fictional encounter 24: Breathlessness and fluid overload. Assessment and planned investigations recorded.
73	24	1	Progress Note	2026-09-04 09:00:00	Fictional progress review for encounter 24. Observations and response to care reviewed.
74	24	1	Discharge Summary	2026-09-06 09:00:00	Fictional discharge summary for encounter 24. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
75	25	1	Initial Assessment	2026-09-04 09:24:00	Fictional encounter 25: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
76	25	1	Progress Note	2026-09-04 21:00:00	Fictional progress review for encounter 25. Observations and response to care reviewed.
77	25	1	Discharge Summary	2026-09-05 09:00:00	Fictional discharge summary for encounter 25. recovery was satisfactory. Follow-up information and medication review provided.
78	26	1	Initial Assessment	2026-09-05 09:24:00	Fictional encounter 26: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
79	26	1	Progress Note	2026-09-05 11:00:00	Fictional progress review for encounter 26. Observations and response to care reviewed.
80	26	1	Discharge Summary	2026-09-05 13:00:00	Fictional discharge summary for encounter 26. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
81	27	1	Initial Assessment	2026-09-06 09:24:00	Fictional encounter 27: Breathlessness and fluid overload. Assessment and planned investigations recorded.
82	27	1	Progress Note	2026-09-07 09:00:00	Fictional progress review for encounter 27. Observations and response to care reviewed.
83	28	1	Initial Assessment	2026-09-07 09:24:00	Fictional encounter 28: Acute chest pain with suspected myocardial infarction. Assessment and planned investigations recorded.
84	28	1	Progress Note	2026-09-08 09:00:00	Fictional progress review for encounter 28. Observations and response to care reviewed.
85	28	1	Discharge Summary	2026-09-11 09:00:00	Fictional discharge summary for encounter 28. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
86	29	2	Initial Assessment	2026-03-01 09:24:00	Fictional encounter 29: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
87	29	2	Progress Note	2026-03-02 09:00:00	Fictional progress review for encounter 29. Observations and response to care reviewed.
88	30	2	Discharge Summary	2026-09-08 21:00:00	Fictional discharge summary for encounter 30. recovery was satisfactory. Follow-up information and medication review provided.
89	31	1	Initial Assessment	2026-07-01 09:24:00	Fictional encounter 31: Breathlessness and fluid overload. Assessment and planned investigations recorded.
90	31	1	Progress Note	2026-07-02 09:00:00	Fictional progress review for encounter 31. Observations and response to care reviewed.
91	31	1	Discharge Summary	2026-07-03 09:00:00	Fictional discharge summary for encounter 31. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
92	32	2	Initial Assessment	2026-06-05 09:24:00	Fictional encounter 32: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
93	32	2	Progress Note	2026-06-05 18:00:00	Fictional progress review for encounter 32. Observations and response to care reviewed.
94	32	2	Discharge Summary	2026-06-06 03:00:00	Fictional discharge summary for encounter 32. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
95	33	2	Initial Assessment	2026-07-10 09:24:00	Fictional encounter 33: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
96	33	2	Progress Note	2026-07-11 00:00:00	Fictional progress review for encounter 33. Observations and response to care reviewed.
97	33	2	Discharge Summary	2026-07-11 15:00:00	Fictional discharge summary for encounter 33. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
98	34	1	Initial Assessment	2026-08-14 09:24:00	Fictional encounter 34: Breathlessness and fluid overload. Assessment and planned investigations recorded.
99	34	1	Progress Note	2026-08-15 06:00:00	Fictional progress review for encounter 34. Observations and response to care reviewed.
100	34	1	Discharge Summary	2026-08-16 03:00:00	Fictional discharge summary for encounter 34. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
101	35	2	Initial Assessment	2026-05-02 09:24:00	Fictional encounter 35: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
102	35	2	Progress Note	2026-05-02 18:00:00	Fictional progress review for encounter 35. Observations and response to care reviewed.
103	35	2	Discharge Summary	2026-05-03 03:00:00	Fictional discharge summary for encounter 35. recovery was satisfactory. Follow-up information and medication review provided.
104	36	2	Initial Assessment	2026-06-06 09:24:00	Fictional encounter 36: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
105	36	2	Progress Note	2026-06-07 00:00:00	Fictional progress review for encounter 36. Observations and response to care reviewed.
106	36	2	Discharge Summary	2026-06-07 15:00:00	Fictional discharge summary for encounter 36. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
107	37	1	Initial Assessment	2026-07-11 09:24:00	Fictional encounter 37: Breathlessness and fluid overload. Assessment and planned investigations recorded.
108	37	1	Progress Note	2026-07-12 06:00:00	Fictional progress review for encounter 37. Observations and response to care reviewed.
109	37	1	Discharge Summary	2026-07-13 03:00:00	Fictional discharge summary for encounter 37. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
110	38	1	Initial Assessment	2026-08-15 09:24:00	Fictional encounter 38: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
111	38	1	Progress Note	2026-08-16 09:00:00	Fictional progress review for encounter 38. Observations and response to care reviewed.
112	38	1	Discharge Summary	2026-08-17 15:00:00	Fictional discharge summary for encounter 38. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
113	39	2	Initial Assessment	2026-05-03 09:24:00	Fictional encounter 39: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
114	39	2	Progress Note	2026-05-04 00:00:00	Fictional progress review for encounter 39. Observations and response to care reviewed.
115	39	2	Discharge Summary	2026-05-04 15:00:00	Fictional discharge summary for encounter 39. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
116	40	1	Initial Assessment	2026-06-07 09:24:00	Fictional encounter 40: Breathlessness and fluid overload. Assessment and planned investigations recorded.
117	40	1	Progress Note	2026-06-08 06:00:00	Fictional progress review for encounter 40. Observations and response to care reviewed.
118	40	1	Discharge Summary	2026-06-09 03:00:00	Fictional discharge summary for encounter 40. recovery was satisfactory. Follow-up information and medication review provided.
119	41	1	Initial Assessment	2026-07-12 09:24:00	Fictional encounter 41: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
120	41	1	Progress Note	2026-07-13 09:00:00	Fictional progress review for encounter 41. Observations and response to care reviewed.
121	41	1	Discharge Summary	2026-07-14 15:00:00	Fictional discharge summary for encounter 41. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
122	42	2	Initial Assessment	2026-08-16 09:24:00	Fictional encounter 42: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
123	42	2	Progress Note	2026-08-16 12:00:00	Fictional progress review for encounter 42. Observations and response to care reviewed.
124	42	2	Discharge Summary	2026-08-16 15:00:00	Fictional discharge summary for encounter 42. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
125	43	1	Initial Assessment	2026-05-04 09:24:00	Fictional encounter 43: Breathlessness and fluid overload. Assessment and planned investigations recorded.
126	43	1	Progress Note	2026-05-05 06:00:00	Fictional progress review for encounter 43. Observations and response to care reviewed.
127	43	1	Discharge Summary	2026-05-06 03:00:00	Fictional discharge summary for encounter 43. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
128	44	1	Initial Assessment	2026-06-08 09:24:00	Fictional encounter 44: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
129	44	1	Progress Note	2026-06-09 09:00:00	Fictional progress review for encounter 44. Observations and response to care reviewed.
130	44	1	Discharge Summary	2026-06-10 15:00:00	Fictional discharge summary for encounter 44. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
131	45	2	Initial Assessment	2026-07-13 09:24:00	Fictional encounter 45: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
132	45	2	Progress Note	2026-07-13 12:00:00	Fictional progress review for encounter 45. Observations and response to care reviewed.
133	45	2	Discharge Summary	2026-07-13 15:00:00	Fictional discharge summary for encounter 45. recovery was satisfactory. Follow-up information and medication review provided.
134	46	1	Initial Assessment	2026-05-05 09:24:00	Fictional encounter 46: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
135	46	1	Progress Note	2026-05-06 09:00:00	Fictional progress review for encounter 46. Observations and response to care reviewed.
136	46	1	Discharge Summary	2026-05-07 15:00:00	Fictional discharge summary for encounter 46. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
137	47	2	Initial Assessment	2026-06-09 09:24:00	Fictional encounter 47: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
138	47	2	Progress Note	2026-06-09 12:00:00	Fictional progress review for encounter 47. Observations and response to care reviewed.
139	47	2	Discharge Summary	2026-06-09 15:00:00	Fictional discharge summary for encounter 47. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
140	48	2	Initial Assessment	2026-07-14 09:24:00	Fictional encounter 48: Outpatient lipid assessment. Assessment and planned investigations recorded.
141	48	2	Progress Note	2026-07-14 18:00:00	Fictional progress review for encounter 48. Observations and response to care reviewed.
142	48	2	Discharge Summary	2026-07-15 03:00:00	Fictional discharge summary for encounter 48. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
143	49	2	Initial Assessment	2026-05-06 09:24:00	Fictional encounter 49: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
144	49	2	Progress Note	2026-05-06 12:00:00	Fictional progress review for encounter 49. Observations and response to care reviewed.
145	49	2	Discharge Summary	2026-05-06 15:00:00	Fictional discharge summary for encounter 49. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
146	50	2	Initial Assessment	2026-06-10 09:24:00	Fictional encounter 50: Outpatient lipid assessment. Assessment and planned investigations recorded.
147	50	2	Progress Note	2026-06-10 18:00:00	Fictional progress review for encounter 50. Observations and response to care reviewed.
148	50	2	Discharge Summary	2026-06-11 03:00:00	Fictional discharge summary for encounter 50. recovery was satisfactory. Follow-up information and medication review provided.
149	51	2	Initial Assessment	2026-07-15 09:24:00	Fictional encounter 51: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
150	51	2	Progress Note	2026-07-16 00:00:00	Fictional progress review for encounter 51. Observations and response to care reviewed.
151	51	2	Discharge Summary	2026-07-16 15:00:00	Fictional discharge summary for encounter 51. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
152	52	2	Initial Assessment	2026-05-07 09:24:00	Fictional encounter 52: Outpatient lipid assessment. Assessment and planned investigations recorded.
153	52	2	Progress Note	2026-05-07 18:00:00	Fictional progress review for encounter 52. Observations and response to care reviewed.
154	52	2	Discharge Summary	2026-05-08 03:00:00	Fictional discharge summary for encounter 52. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
155	53	2	Initial Assessment	2026-06-11 09:24:00	Fictional encounter 53: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
156	53	2	Progress Note	2026-06-12 00:00:00	Fictional progress review for encounter 53. Observations and response to care reviewed.
157	53	2	Discharge Summary	2026-06-12 15:00:00	Fictional discharge summary for encounter 53. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
158	54	2	Initial Assessment	2026-07-16 09:24:00	Fictional encounter 54: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
159	54	2	Progress Note	2026-07-17 06:00:00	Fictional progress review for encounter 54. Observations and response to care reviewed.
160	54	2	Discharge Summary	2026-07-18 03:00:00	Fictional discharge summary for encounter 54. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
161	55	2	Initial Assessment	2026-05-08 09:24:00	Fictional encounter 55: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
162	55	2	Progress Note	2026-05-09 00:00:00	Fictional progress review for encounter 55. Observations and response to care reviewed.
163	55	2	Discharge Summary	2026-05-09 15:00:00	Fictional discharge summary for encounter 55. recovery was satisfactory. Follow-up information and medication review provided.
164	56	2	Initial Assessment	2026-06-12 09:24:00	Fictional encounter 56: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
165	56	2	Progress Note	2026-06-13 06:00:00	Fictional progress review for encounter 56. Observations and response to care reviewed.
166	56	2	Discharge Summary	2026-06-14 03:00:00	Fictional discharge summary for encounter 56. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
167	57	4	Initial Assessment	2026-07-17 09:24:00	Fictional encounter 57: Fever and cough with pneumonia. Assessment and planned investigations recorded.
168	57	4	Progress Note	2026-07-18 09:00:00	Fictional progress review for encounter 57. Observations and response to care reviewed.
169	57	4	Discharge Summary	2026-07-19 15:00:00	Fictional discharge summary for encounter 57. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
170	58	2	Initial Assessment	2026-05-09 09:24:00	Fictional encounter 58: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
171	58	2	Progress Note	2026-05-10 06:00:00	Fictional progress review for encounter 58. Observations and response to care reviewed.
172	58	2	Discharge Summary	2026-05-11 03:00:00	Fictional discharge summary for encounter 58. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
173	59	4	Initial Assessment	2026-06-13 09:24:00	Fictional encounter 59: Fever and cough with pneumonia. Assessment and planned investigations recorded.
174	59	4	Progress Note	2026-06-14 09:00:00	Fictional progress review for encounter 59. Observations and response to care reviewed.
175	59	4	Discharge Summary	2026-06-15 15:00:00	Fictional discharge summary for encounter 59. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
176	60	2	Initial Assessment	2026-07-18 09:24:00	Fictional encounter 60: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
177	60	2	Progress Note	2026-07-18 12:00:00	Fictional progress review for encounter 60. Observations and response to care reviewed.
178	60	2	Discharge Summary	2026-07-18 15:00:00	Fictional discharge summary for encounter 60. recovery was satisfactory. Follow-up information and medication review provided.
179	61	4	Initial Assessment	2026-05-10 09:24:00	Fictional encounter 61: Fever and cough with pneumonia. Assessment and planned investigations recorded.
180	61	4	Progress Note	2026-05-11 09:00:00	Fictional progress review for encounter 61. Observations and response to care reviewed.
181	61	4	Discharge Summary	2026-05-12 15:00:00	Fictional discharge summary for encounter 61. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
182	62	2	Initial Assessment	2026-06-14 09:24:00	Fictional encounter 62: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
183	62	2	Progress Note	2026-06-14 12:00:00	Fictional progress review for encounter 62. Observations and response to care reviewed.
184	62	2	Discharge Summary	2026-06-14 15:00:00	Fictional discharge summary for encounter 62. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
185	63	2	Initial Assessment	2026-07-19 09:24:00	Fictional encounter 63: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
186	63	2	Progress Note	2026-07-19 18:00:00	Fictional progress review for encounter 63. Observations and response to care reviewed.
187	63	2	Discharge Summary	2026-07-20 03:00:00	Fictional discharge summary for encounter 63. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
188	64	2	Initial Assessment	2026-05-11 09:24:00	Fictional encounter 64: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
189	64	2	Progress Note	2026-05-11 12:00:00	Fictional progress review for encounter 64. Observations and response to care reviewed.
190	64	2	Discharge Summary	2026-05-11 15:00:00	Fictional discharge summary for encounter 64. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
191	65	2	Initial Assessment	2026-06-15 09:24:00	Fictional encounter 65: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
192	65	2	Progress Note	2026-06-15 18:00:00	Fictional progress review for encounter 65. Observations and response to care reviewed.
193	65	2	Discharge Summary	2026-06-16 03:00:00	Fictional discharge summary for encounter 65. recovery was satisfactory. Follow-up information and medication review provided.
194	66	1	Initial Assessment	2026-07-20 09:24:00	Fictional encounter 66: Breathlessness and fluid overload. Assessment and planned investigations recorded.
195	66	1	Progress Note	2026-07-21 00:00:00	Fictional progress review for encounter 66. Observations and response to care reviewed.
196	66	1	Discharge Summary	2026-07-21 15:00:00	Fictional discharge summary for encounter 66. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
197	67	2	Initial Assessment	2026-05-12 09:24:00	Fictional encounter 67: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
198	67	2	Progress Note	2026-05-12 18:00:00	Fictional progress review for encounter 67. Observations and response to care reviewed.
199	67	2	Discharge Summary	2026-05-13 03:00:00	Fictional discharge summary for encounter 67. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
200	68	1	Initial Assessment	2026-06-16 09:24:00	Fictional encounter 68: Breathlessness and fluid overload. Assessment and planned investigations recorded.
201	68	1	Progress Note	2026-06-17 00:00:00	Fictional progress review for encounter 68. Observations and response to care reviewed.
202	68	1	Discharge Summary	2026-06-17 15:00:00	Fictional discharge summary for encounter 68. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
203	69	1	Initial Assessment	2026-07-21 09:24:00	Fictional encounter 69: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
204	69	1	Progress Note	2026-07-22 06:00:00	Fictional progress review for encounter 69. Observations and response to care reviewed.
205	69	1	Discharge Summary	2026-07-23 03:00:00	Fictional discharge summary for encounter 69. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
206	70	1	Initial Assessment	2026-05-13 09:24:00	Fictional encounter 70: Breathlessness and fluid overload. Assessment and planned investigations recorded.
207	70	1	Progress Note	2026-05-14 00:00:00	Fictional progress review for encounter 70. Observations and response to care reviewed.
208	70	1	Discharge Summary	2026-05-14 15:00:00	Fictional discharge summary for encounter 70. recovery was satisfactory. Follow-up information and medication review provided.
209	71	1	Initial Assessment	2026-06-17 09:24:00	Fictional encounter 71: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
210	71	1	Progress Note	2026-06-18 06:00:00	Fictional progress review for encounter 71. Observations and response to care reviewed.
211	71	1	Discharge Summary	2026-06-19 03:00:00	Fictional discharge summary for encounter 71. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
212	72	2	Initial Assessment	2026-07-22 09:24:00	Fictional encounter 72: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
213	72	2	Progress Note	2026-07-23 09:00:00	Fictional progress review for encounter 72. Observations and response to care reviewed.
214	72	2	Discharge Summary	2026-07-24 15:00:00	Fictional discharge summary for encounter 72. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
215	73	1	Initial Assessment	2026-05-14 09:24:00	Fictional encounter 73: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
216	73	1	Progress Note	2026-05-15 06:00:00	Fictional progress review for encounter 73. Observations and response to care reviewed.
217	73	1	Discharge Summary	2026-05-16 03:00:00	Fictional discharge summary for encounter 73. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
218	74	2	Initial Assessment	2026-06-18 09:24:00	Fictional encounter 74: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
219	74	2	Progress Note	2026-06-19 09:00:00	Fictional progress review for encounter 74. Observations and response to care reviewed.
220	74	2	Discharge Summary	2026-06-20 15:00:00	Fictional discharge summary for encounter 74. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
221	75	2	Initial Assessment	2026-07-23 09:24:00	Fictional encounter 75: Outpatient lipid assessment. Assessment and planned investigations recorded.
222	75	2	Progress Note	2026-07-23 12:00:00	Fictional progress review for encounter 75. Observations and response to care reviewed.
223	75	2	Discharge Summary	2026-07-23 15:00:00	Fictional discharge summary for encounter 75. recovery was satisfactory. Follow-up information and medication review provided.
224	76	2	Initial Assessment	2026-05-15 09:24:00	Fictional encounter 76: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
225	76	2	Progress Note	2026-05-16 09:00:00	Fictional progress review for encounter 76. Observations and response to care reviewed.
226	76	2	Discharge Summary	2026-05-17 15:00:00	Fictional discharge summary for encounter 76. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
227	77	2	Initial Assessment	2026-06-19 09:24:00	Fictional encounter 77: Outpatient lipid assessment. Assessment and planned investigations recorded.
228	77	2	Progress Note	2026-06-19 12:00:00	Fictional progress review for encounter 77. Observations and response to care reviewed.
229	77	2	Discharge Summary	2026-06-19 15:00:00	Fictional discharge summary for encounter 77. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
230	78	2	Initial Assessment	2026-07-24 09:24:00	Fictional encounter 78: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
231	78	2	Progress Note	2026-07-24 18:00:00	Fictional progress review for encounter 78. Observations and response to care reviewed.
232	78	2	Discharge Summary	2026-07-25 03:00:00	Fictional discharge summary for encounter 78. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
233	79	2	Initial Assessment	2026-05-16 09:24:00	Fictional encounter 79: Outpatient lipid assessment. Assessment and planned investigations recorded.
234	79	2	Progress Note	2026-05-16 12:00:00	Fictional progress review for encounter 79. Observations and response to care reviewed.
235	79	2	Discharge Summary	2026-05-16 15:00:00	Fictional discharge summary for encounter 79. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
236	80	2	Initial Assessment	2026-06-20 09:24:00	Fictional encounter 80: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
237	80	2	Progress Note	2026-06-20 18:00:00	Fictional progress review for encounter 80. Observations and response to care reviewed.
238	80	2	Discharge Summary	2026-06-21 03:00:00	Fictional discharge summary for encounter 80. recovery was satisfactory. Follow-up information and medication review provided.
239	81	2	Initial Assessment	2026-07-25 09:24:00	Fictional encounter 81: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
240	81	2	Progress Note	2026-07-26 00:00:00	Fictional progress review for encounter 81. Observations and response to care reviewed.
241	81	2	Discharge Summary	2026-07-26 15:00:00	Fictional discharge summary for encounter 81. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
242	82	2	Initial Assessment	2026-05-17 09:24:00	Fictional encounter 82: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
243	82	2	Progress Note	2026-05-17 18:00:00	Fictional progress review for encounter 82. Observations and response to care reviewed.
244	82	2	Discharge Summary	2026-05-18 03:00:00	Fictional discharge summary for encounter 82. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
245	83	2	Initial Assessment	2026-06-21 09:24:00	Fictional encounter 83: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
246	83	2	Progress Note	2026-06-22 00:00:00	Fictional progress review for encounter 83. Observations and response to care reviewed.
247	83	2	Discharge Summary	2026-06-22 15:00:00	Fictional discharge summary for encounter 83. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
248	84	4	Initial Assessment	2026-07-26 09:24:00	Fictional encounter 84: Fever and cough with pneumonia. Assessment and planned investigations recorded.
249	84	4	Progress Note	2026-07-27 06:00:00	Fictional progress review for encounter 84. Observations and response to care reviewed.
250	84	4	Discharge Summary	2026-07-28 03:00:00	Fictional discharge summary for encounter 84. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
251	85	2	Initial Assessment	2026-05-18 09:24:00	Fictional encounter 85: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
252	85	2	Progress Note	2026-05-19 00:00:00	Fictional progress review for encounter 85. Observations and response to care reviewed.
253	85	2	Discharge Summary	2026-05-19 15:00:00	Fictional discharge summary for encounter 85. recovery was satisfactory. Follow-up information and medication review provided.
254	86	4	Initial Assessment	2026-06-22 09:24:00	Fictional encounter 86: Fever and cough with pneumonia. Assessment and planned investigations recorded.
255	86	4	Progress Note	2026-06-23 06:00:00	Fictional progress review for encounter 86. Observations and response to care reviewed.
256	86	4	Discharge Summary	2026-06-24 03:00:00	Fictional discharge summary for encounter 86. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
257	87	2	Initial Assessment	2026-07-27 09:24:00	Fictional encounter 87: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
258	87	2	Progress Note	2026-07-28 09:00:00	Fictional progress review for encounter 87. Observations and response to care reviewed.
259	87	2	Discharge Summary	2026-07-29 15:00:00	Fictional discharge summary for encounter 87. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
260	88	4	Initial Assessment	2026-05-19 09:24:00	Fictional encounter 88: Fever and cough with pneumonia. Assessment and planned investigations recorded.
261	88	4	Progress Note	2026-05-20 06:00:00	Fictional progress review for encounter 88. Observations and response to care reviewed.
262	88	4	Discharge Summary	2026-05-21 03:00:00	Fictional discharge summary for encounter 88. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
263	89	2	Initial Assessment	2026-06-23 09:24:00	Fictional encounter 89: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
264	89	2	Progress Note	2026-06-24 09:00:00	Fictional progress review for encounter 89. Observations and response to care reviewed.
265	89	2	Discharge Summary	2026-06-25 15:00:00	Fictional discharge summary for encounter 89. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
266	90	2	Initial Assessment	2026-07-28 09:24:00	Fictional encounter 90: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
267	90	2	Progress Note	2026-07-28 12:00:00	Fictional progress review for encounter 90. Observations and response to care reviewed.
268	90	2	Discharge Summary	2026-07-28 15:00:00	Fictional discharge summary for encounter 90. recovery was satisfactory. Follow-up information and medication review provided.
269	91	2	Initial Assessment	2026-05-20 09:24:00	Fictional encounter 91: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
270	91	2	Progress Note	2026-05-21 09:00:00	Fictional progress review for encounter 91. Observations and response to care reviewed.
271	91	2	Discharge Summary	2026-05-22 15:00:00	Fictional discharge summary for encounter 91. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
272	92	2	Initial Assessment	2026-06-24 09:24:00	Fictional encounter 92: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
273	92	2	Progress Note	2026-06-24 12:00:00	Fictional progress review for encounter 92. Observations and response to care reviewed.
274	92	2	Discharge Summary	2026-06-24 15:00:00	Fictional discharge summary for encounter 92. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
275	93	1	Initial Assessment	2026-07-29 09:24:00	Fictional encounter 93: Breathlessness and fluid overload. Assessment and planned investigations recorded.
276	93	1	Progress Note	2026-07-29 18:00:00	Fictional progress review for encounter 93. Observations and response to care reviewed.
277	93	1	Discharge Summary	2026-07-30 03:00:00	Fictional discharge summary for encounter 93. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
278	94	2	Initial Assessment	2026-05-01 09:24:00	Fictional encounter 94: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
279	94	2	Progress Note	2026-05-01 12:00:00	Fictional progress review for encounter 94. Observations and response to care reviewed.
280	94	2	Discharge Summary	2026-05-01 15:00:00	Fictional discharge summary for encounter 94. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
281	95	1	Initial Assessment	2026-06-05 09:24:00	Fictional encounter 95: Breathlessness and fluid overload. Assessment and planned investigations recorded.
282	95	1	Progress Note	2026-06-05 18:00:00	Fictional progress review for encounter 95. Observations and response to care reviewed.
283	95	1	Discharge Summary	2026-06-06 03:00:00	Fictional discharge summary for encounter 95. recovery was satisfactory. Follow-up information and medication review provided.
284	96	1	Initial Assessment	2026-07-10 09:24:00	Fictional encounter 96: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
285	96	1	Progress Note	2026-07-11 00:00:00	Fictional progress review for encounter 96. Observations and response to care reviewed.
286	96	1	Discharge Summary	2026-07-11 15:00:00	Fictional discharge summary for encounter 96. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
287	97	1	Initial Assessment	2026-05-02 09:24:00	Fictional encounter 97: Breathlessness and fluid overload. Assessment and planned investigations recorded.
288	97	1	Progress Note	2026-05-02 18:00:00	Fictional progress review for encounter 97. Observations and response to care reviewed.
289	97	1	Discharge Summary	2026-05-03 03:00:00	Fictional discharge summary for encounter 97. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
290	98	1	Initial Assessment	2026-06-06 09:24:00	Fictional encounter 98: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
291	98	1	Progress Note	2026-06-07 00:00:00	Fictional progress review for encounter 98. Observations and response to care reviewed.
292	98	1	Discharge Summary	2026-06-07 15:00:00	Fictional discharge summary for encounter 98. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
293	99	2	Initial Assessment	2026-07-11 09:24:00	Fictional encounter 99: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
294	99	2	Progress Note	2026-07-12 06:00:00	Fictional progress review for encounter 99. Observations and response to care reviewed.
295	99	2	Discharge Summary	2026-07-13 03:00:00	Fictional discharge summary for encounter 99. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
296	100	1	Initial Assessment	2026-05-03 09:24:00	Fictional encounter 100: Chest pain requiring diagnostic assessment. Assessment and planned investigations recorded.
297	100	1	Progress Note	2026-05-04 00:00:00	Fictional progress review for encounter 100. Observations and response to care reviewed.
298	100	1	Discharge Summary	2026-05-04 15:00:00	Fictional discharge summary for encounter 100. recovery was satisfactory. Follow-up information and medication review provided.
299	101	2	Initial Assessment	2026-06-07 09:24:00	Fictional encounter 101: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
300	101	2	Progress Note	2026-06-08 06:00:00	Fictional progress review for encounter 101. Observations and response to care reviewed.
301	101	2	Discharge Summary	2026-06-09 03:00:00	Fictional discharge summary for encounter 101. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
302	102	2	Initial Assessment	2026-07-12 09:24:00	Fictional encounter 102: Outpatient lipid assessment. Assessment and planned investigations recorded.
303	102	2	Progress Note	2026-07-13 09:00:00	Fictional progress review for encounter 102. Observations and response to care reviewed.
304	102	2	Discharge Summary	2026-07-14 15:00:00	Fictional discharge summary for encounter 102. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
305	103	2	Initial Assessment	2026-05-04 09:24:00	Fictional encounter 103: Neurological monitoring and rehabilitation after cerebral infarction. Assessment and planned investigations recorded.
306	103	2	Progress Note	2026-05-05 06:00:00	Fictional progress review for encounter 103. Observations and response to care reviewed.
307	103	2	Discharge Summary	2026-05-06 03:00:00	Fictional discharge summary for encounter 103. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
308	104	2	Initial Assessment	2026-06-08 09:24:00	Fictional encounter 104: Outpatient lipid assessment. Assessment and planned investigations recorded.
309	104	2	Progress Note	2026-06-09 09:00:00	Fictional progress review for encounter 104. Observations and response to care reviewed.
310	104	2	Discharge Summary	2026-06-10 15:00:00	Fictional discharge summary for encounter 104. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
311	105	2	Initial Assessment	2026-07-13 09:24:00	Fictional encounter 105: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
312	105	2	Progress Note	2026-07-13 12:00:00	Fictional progress review for encounter 105. Observations and response to care reviewed.
313	105	2	Discharge Summary	2026-07-13 15:00:00	Fictional discharge summary for encounter 105. recovery was satisfactory. Follow-up information and medication review provided.
314	106	2	Initial Assessment	2026-05-05 09:24:00	Fictional encounter 106: Outpatient lipid assessment. Assessment and planned investigations recorded.
315	106	2	Progress Note	2026-05-06 09:00:00	Fictional progress review for encounter 106. Observations and response to care reviewed.
316	106	2	Discharge Summary	2026-05-07 15:00:00	Fictional discharge summary for encounter 106. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
317	107	2	Initial Assessment	2026-06-09 09:24:00	Fictional encounter 107: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
318	107	2	Progress Note	2026-06-09 12:00:00	Fictional progress review for encounter 107. Observations and response to care reviewed.
319	107	2	Discharge Summary	2026-06-09 15:00:00	Fictional discharge summary for encounter 107. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
320	108	2	Initial Assessment	2026-07-14 09:24:00	Fictional encounter 108: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
321	108	2	Progress Note	2026-07-14 18:00:00	Fictional progress review for encounter 108. Observations and response to care reviewed.
322	108	2	Discharge Summary	2026-07-15 03:00:00	Fictional discharge summary for encounter 108. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
323	109	2	Initial Assessment	2026-05-06 09:24:00	Fictional encounter 109: Elevated blood pressure requiring assessment. Assessment and planned investigations recorded.
324	109	2	Progress Note	2026-05-06 12:00:00	Fictional progress review for encounter 109. Observations and response to care reviewed.
325	109	2	Discharge Summary	2026-05-06 15:00:00	Fictional discharge summary for encounter 109. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
326	110	2	Initial Assessment	2026-06-10 09:24:00	Fictional encounter 110: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
327	110	2	Progress Note	2026-06-10 18:00:00	Fictional progress review for encounter 110. Observations and response to care reviewed.
328	110	2	Discharge Summary	2026-06-11 03:00:00	Fictional discharge summary for encounter 110. recovery was satisfactory. Follow-up information and medication review provided.
329	111	4	Initial Assessment	2026-07-15 09:24:00	Fictional encounter 111: Fever and cough with pneumonia. Assessment and planned investigations recorded.
330	111	4	Progress Note	2026-07-16 00:00:00	Fictional progress review for encounter 111. Observations and response to care reviewed.
331	111	4	Discharge Summary	2026-07-16 15:00:00	Fictional discharge summary for encounter 111. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
332	112	2	Initial Assessment	2026-05-07 09:24:00	Fictional encounter 112: Diabetes review and glucose monitoring. Assessment and planned investigations recorded.
333	112	2	Progress Note	2026-05-07 18:00:00	Fictional progress review for encounter 112. Observations and response to care reviewed.
334	112	2	Discharge Summary	2026-05-08 03:00:00	Fictional discharge summary for encounter 112. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
335	113	4	Initial Assessment	2026-06-11 09:24:00	Fictional encounter 113: Fever and cough with pneumonia. Assessment and planned investigations recorded.
336	113	4	Progress Note	2026-06-12 00:00:00	Fictional progress review for encounter 113. Observations and response to care reviewed.
337	113	4	Discharge Summary	2026-06-12 15:00:00	Fictional discharge summary for encounter 113. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
338	114	2	Initial Assessment	2026-07-16 09:24:00	Fictional encounter 114: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
339	114	2	Progress Note	2026-07-17 06:00:00	Fictional progress review for encounter 114. Observations and response to care reviewed.
340	114	2	Discharge Summary	2026-07-18 03:00:00	Fictional discharge summary for encounter 114. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
341	115	4	Initial Assessment	2026-05-08 09:24:00	Fictional encounter 115: Fever and cough with pneumonia. Assessment and planned investigations recorded.
342	115	4	Progress Note	2026-05-09 00:00:00	Fictional progress review for encounter 115. Observations and response to care reviewed.
343	115	4	Discharge Summary	2026-05-09 15:00:00	Fictional discharge summary for encounter 115. recovery was satisfactory. Follow-up information and medication review provided.
344	116	2	Initial Assessment	2026-06-12 09:24:00	Fictional encounter 116: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
345	116	2	Progress Note	2026-06-13 06:00:00	Fictional progress review for encounter 116. Observations and response to care reviewed.
346	116	2	Discharge Summary	2026-06-14 03:00:00	Fictional discharge summary for encounter 116. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
347	117	2	Initial Assessment	2026-07-17 09:24:00	Fictional encounter 117: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
348	117	2	Progress Note	2026-07-18 09:00:00	Fictional progress review for encounter 117. Observations and response to care reviewed.
349	117	2	Discharge Summary	2026-07-19 15:00:00	Fictional discharge summary for encounter 117. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
350	118	2	Initial Assessment	2026-05-09 09:24:00	Fictional encounter 118: Acute abdominal pain with appendicitis. Assessment and planned investigations recorded.
351	118	2	Progress Note	2026-05-10 06:00:00	Fictional progress review for encounter 118. Observations and response to care reviewed.
352	118	2	Discharge Summary	2026-05-11 03:00:00	Fictional discharge summary for encounter 118. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
353	119	2	Initial Assessment	2026-06-13 09:24:00	Fictional encounter 119: Hip pain after a fall with femoral neck fracture. Assessment and planned investigations recorded.
354	119	2	Progress Note	2026-06-14 09:00:00	Fictional progress review for encounter 119. Observations and response to care reviewed.
355	119	2	Discharge Summary	2026-06-15 15:00:00	Fictional discharge summary for encounter 119. Condition stable at discharge. Assessment findings, treatment and follow-up reviewed.
356	120	1	Initial Assessment	2026-07-18 09:24:00	Fictional encounter 120: Breathlessness and fluid overload. Assessment and planned investigations recorded.
357	120	1	Progress Note	2026-07-18 12:00:00	Fictional progress review for encounter 120. Observations and response to care reviewed.
358	120	1	Discharge Summary	2026-07-18 15:00:00	Fictional discharge summary for encounter 120. recovery was satisfactory. Follow-up information and medication review provided.
\.


--
-- TOC entry 5161 (class 0 OID 16473)
-- Dependencies: 235
-- Data for Name: icd9_dictionary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.icd9_dictionary (icd9_code, official_title, description, disease_category) FROM stdin;
486	Pneumonia, organism unspecified	Pneumonia with no causative organism specified.	Respiratory diseases
272.4	Other and unspecified hyperlipidemia	Lipid disorder recorded without a more specific subtype.	Endocrine and metabolic diseases
401.9	Unspecified essential hypertension	Essential hypertension recorded without a more specific subtype.	Circulatory diseases
428.0	Congestive heart failure, unspecified	Congestive heart failure recorded without a more specific subtype.	Circulatory diseases
540.9	Acute appendicitis without mention of peritonitis	Acute appendicitis without recorded peritonitis.	Digestive diseases
820.8	Closed fracture of unspecified part of neck of femur	Closed fracture involving an unspecified part of the femoral neck.	Injury and poisoning
250.00	Diabetes mellitus without mention of complication, type II or unspecified type, not stated as uncontrolled	Type 2 or unspecified diabetes without a documented complication or uncontrolled status.	Endocrine and metabolic diseases
410.91	Acute myocardial infarction of unspecified site, initial episode of care	Acute myocardial infarction during the initial episode of care, with site unspecified.	Circulatory diseases
434.91	Cerebral artery occlusion, unspecified with cerebral infarction	Cerebral artery occlusion of unspecified type with cerebral infarction.	Circulatory diseases
786.50	Chest pain, unspecified	Chest pain recorded without a more specific description.	Symptoms and signs
038.9	Unspecified septicemia	Bloodstream infection documented without a specified organism.	Infectious diseases
\.


--
-- TOC entry 5149 (class 0 OID 16414)
-- Dependencies: 223
-- Data for Name: diagnoses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnoses (diagnosis_id, patient_id, admission_id, icd9_code, diagnosing_physician_id, diagnosis_datetime, diagnosis_type) FROM stdin;
1	1	1	410.91	1	2026-05-01 09:48:00	Primary
2	1	1	401.9	1	2026-05-01 09:54:00	Secondary
3	1	1	272.4	1	2026-05-01 09:57:00	Secondary
4	1	2	410.91	1	2026-06-05 09:48:00	Primary
5	1	2	401.9	1	2026-06-05 09:54:00	Secondary
6	1	2	272.4	1	2026-06-05 09:57:00	Secondary
7	1	3	410.91	1	2026-07-01 09:48:00	Primary
8	1	3	401.9	1	2026-07-01 09:54:00	Secondary
9	1	3	272.4	1	2026-07-01 09:57:00	Secondary
10	1	4	786.50	1	2026-08-01 09:48:00	Primary
11	1	4	401.9	1	2026-08-01 09:54:00	Secondary
12	1	4	272.4	1	2026-08-01 09:57:00	Secondary
13	1	5	401.9	2	2026-09-01 09:48:00	Primary
14	2	6	410.91	1	2026-05-02 09:48:00	Primary
15	2	6	401.9	1	2026-05-02 09:54:00	Secondary
16	2	6	272.4	1	2026-05-02 09:57:00	Secondary
17	2	7	410.91	1	2026-06-05 09:48:00	Primary
18	2	7	401.9	1	2026-06-05 09:54:00	Secondary
19	2	7	272.4	1	2026-06-05 09:57:00	Secondary
20	2	8	410.91	1	2026-07-10 09:48:00	Primary
21	2	8	401.9	1	2026-07-10 09:54:00	Secondary
22	2	8	272.4	1	2026-07-10 09:57:00	Secondary
23	2	9	820.8	2	2026-08-10 09:48:00	Primary
24	2	9	401.9	2	2026-08-10 09:54:00	Secondary
25	2	9	272.4	2	2026-08-10 09:57:00	Secondary
26	3	10	486	4	2026-05-01 09:48:00	Primary
27	3	10	401.9	4	2026-05-01 09:54:00	Secondary
28	3	10	272.4	4	2026-05-01 09:57:00	Secondary
29	3	11	486	4	2026-06-01 09:48:00	Primary
30	3	11	401.9	4	2026-06-01 09:54:00	Secondary
31	3	11	272.4	4	2026-06-01 09:57:00	Secondary
32	3	12	486	4	2026-07-01 09:48:00	Primary
33	3	12	401.9	4	2026-07-01 09:54:00	Secondary
34	3	12	272.4	4	2026-07-01 09:57:00	Secondary
35	4	13	786.50	1	2026-07-10 08:48:00	Primary
36	4	14	540.9	2	2026-07-10 13:48:00	Primary
37	5	15	401.9	2	2026-08-01 09:48:00	Primary
38	6	16	540.9	2	2026-08-05 09:48:00	Primary
39	6	17	540.9	2	2026-09-05 09:48:00	Primary
40	7	18	038.9	2	2026-08-10 09:48:00	Primary
41	8	19	486	4	2026-08-15 09:48:00	Primary
42	7	20	401.9	2	2026-04-01 09:48:00	Primary
43	10	21	401.9	2	2026-08-25 09:39:00	Preliminary
44	10	21	401.9	2	2026-08-25 09:48:00	Primary
45	11	22	250.00	2	2026-09-01 09:39:00	Preliminary
46	11	22	250.00	2	2026-09-01 09:48:00	Primary
47	11	22	401.9	2	2026-09-01 09:54:00	Secondary
48	12	23	486	4	2026-09-02 09:48:00	Primary
49	12	23	401.9	4	2026-09-02 09:54:00	Secondary
50	12	23	272.4	4	2026-09-02 09:57:00	Secondary
51	13	24	428.0	1	2026-09-03 09:48:00	Primary
52	10	25	786.50	1	2026-09-04 09:48:00	Primary
53	15	26	786.50	1	2026-09-05 09:48:00	Primary
54	16	27	428.0	1	2026-09-06 09:39:00	Preliminary
55	17	28	410.91	1	2026-09-07 09:48:00	Primary
56	18	29	434.91	2	2026-03-01 09:39:00	Preliminary
57	19	30	401.9	2	2026-09-08 09:48:00	Primary
58	13	31	428.0	1	2026-07-01 09:48:00	Primary
59	13	31	401.9	1	2026-07-01 09:54:00	Secondary
60	20	32	540.9	2	2026-06-05 09:48:00	Primary
61	20	33	820.8	2	2026-07-10 09:48:00	Primary
62	20	34	428.0	1	2026-08-14 09:48:00	Primary
63	21	35	540.9	2	2026-05-02 09:48:00	Primary
64	21	36	820.8	2	2026-06-06 09:48:00	Primary
65	21	37	428.0	1	2026-07-11 09:48:00	Primary
66	21	38	786.50	1	2026-08-15 09:48:00	Primary
67	21	38	401.9	1	2026-08-15 09:54:00	Secondary
68	22	39	820.8	2	2026-05-03 09:48:00	Primary
69	22	40	428.0	1	2026-06-07 09:48:00	Primary
70	22	41	786.50	1	2026-07-12 09:48:00	Primary
71	22	41	401.9	1	2026-07-12 09:54:00	Secondary
72	22	42	434.91	2	2026-08-16 09:48:00	Primary
73	23	43	428.0	1	2026-05-04 09:48:00	Primary
74	23	44	786.50	1	2026-06-08 09:48:00	Primary
75	23	44	401.9	1	2026-06-08 09:54:00	Secondary
76	23	45	434.91	2	2026-07-13 09:48:00	Primary
77	24	46	786.50	1	2026-05-05 09:48:00	Primary
78	24	46	401.9	1	2026-05-05 09:54:00	Secondary
79	24	47	434.91	2	2026-06-09 09:48:00	Primary
80	24	48	272.4	2	2026-07-14 09:48:00	Primary
81	25	49	434.91	2	2026-05-06 09:48:00	Primary
82	25	50	272.4	2	2026-06-10 09:48:00	Primary
83	25	51	401.9	2	2026-07-15 09:48:00	Primary
84	26	52	272.4	2	2026-05-07 09:48:00	Primary
85	26	53	401.9	2	2026-06-11 09:48:00	Primary
86	26	54	250.00	2	2026-07-16 09:48:00	Primary
87	26	54	401.9	2	2026-07-16 09:54:00	Secondary
88	27	55	401.9	2	2026-05-08 09:48:00	Primary
89	27	56	250.00	2	2026-06-12 09:48:00	Primary
90	27	56	401.9	2	2026-06-12 09:54:00	Secondary
91	27	57	486	4	2026-07-17 09:48:00	Primary
92	28	58	250.00	2	2026-05-09 09:48:00	Primary
93	28	58	401.9	2	2026-05-09 09:54:00	Secondary
94	28	59	486	4	2026-06-13 09:48:00	Primary
95	28	60	540.9	2	2026-07-18 09:48:00	Primary
96	29	61	486	4	2026-05-10 09:48:00	Primary
97	29	62	540.9	2	2026-06-14 09:48:00	Primary
98	29	63	820.8	2	2026-07-19 09:48:00	Primary
99	30	64	540.9	2	2026-05-11 09:48:00	Primary
100	30	65	820.8	2	2026-06-15 09:48:00	Primary
101	30	66	428.0	1	2026-07-20 09:48:00	Primary
102	30	66	401.9	1	2026-07-20 09:54:00	Secondary
103	31	67	820.8	2	2026-05-12 09:48:00	Primary
104	31	68	428.0	1	2026-06-16 09:48:00	Primary
105	31	68	401.9	1	2026-06-16 09:54:00	Secondary
106	31	69	786.50	1	2026-07-21 09:48:00	Primary
107	32	70	428.0	1	2026-05-13 09:48:00	Primary
108	32	70	401.9	1	2026-05-13 09:54:00	Secondary
109	32	71	786.50	1	2026-06-17 09:48:00	Primary
110	32	72	434.91	2	2026-07-22 09:48:00	Primary
111	33	73	786.50	1	2026-05-14 09:48:00	Primary
112	33	74	434.91	2	2026-06-18 09:48:00	Primary
113	33	75	272.4	2	2026-07-23 09:48:00	Primary
114	34	76	434.91	2	2026-05-15 09:48:00	Primary
115	34	77	272.4	2	2026-06-19 09:48:00	Primary
116	34	78	401.9	2	2026-07-24 09:48:00	Primary
117	35	79	272.4	2	2026-05-16 09:48:00	Primary
118	35	80	401.9	2	2026-06-20 09:48:00	Primary
119	35	81	250.00	2	2026-07-25 09:48:00	Primary
120	36	82	401.9	2	2026-05-17 09:48:00	Primary
121	36	83	250.00	2	2026-06-21 09:48:00	Primary
122	36	84	486	4	2026-07-26 09:48:00	Primary
123	37	85	250.00	2	2026-05-18 09:48:00	Primary
124	37	86	486	4	2026-06-22 09:48:00	Primary
125	37	87	540.9	2	2026-07-27 09:48:00	Primary
126	38	88	486	4	2026-05-19 09:48:00	Primary
127	38	89	540.9	2	2026-06-23 09:48:00	Primary
128	38	90	820.8	2	2026-07-28 09:48:00	Primary
129	38	90	401.9	2	2026-07-28 09:54:00	Secondary
130	39	91	540.9	2	2026-05-20 09:48:00	Primary
131	39	92	820.8	2	2026-06-24 09:48:00	Primary
132	39	92	401.9	2	2026-06-24 09:54:00	Secondary
133	39	93	428.0	1	2026-07-29 09:48:00	Primary
134	40	94	820.8	2	2026-05-01 09:48:00	Primary
135	40	94	401.9	2	2026-05-01 09:54:00	Secondary
136	40	95	428.0	1	2026-06-05 09:48:00	Primary
137	40	96	786.50	1	2026-07-10 09:48:00	Primary
138	41	97	428.0	1	2026-05-02 09:48:00	Primary
139	41	98	786.50	1	2026-06-06 09:48:00	Primary
140	41	99	434.91	2	2026-07-11 09:48:00	Primary
141	42	100	786.50	1	2026-05-03 09:48:00	Primary
142	42	101	434.91	2	2026-06-07 09:48:00	Primary
143	42	102	272.4	2	2026-07-12 09:48:00	Primary
144	42	102	401.9	2	2026-07-12 09:54:00	Secondary
145	43	103	434.91	2	2026-05-04 09:48:00	Primary
146	43	104	272.4	2	2026-06-08 09:48:00	Primary
147	43	104	401.9	2	2026-06-08 09:54:00	Secondary
148	43	105	401.9	2	2026-07-13 09:48:00	Primary
149	44	106	272.4	2	2026-05-05 09:48:00	Primary
150	44	106	401.9	2	2026-05-05 09:54:00	Secondary
151	44	107	401.9	2	2026-06-09 09:48:00	Primary
152	44	108	250.00	2	2026-07-14 09:48:00	Primary
153	45	109	401.9	2	2026-05-06 09:48:00	Primary
154	45	110	250.00	2	2026-06-10 09:48:00	Primary
155	45	111	486	4	2026-07-15 09:48:00	Primary
156	46	112	250.00	2	2026-05-07 09:48:00	Primary
157	46	113	486	4	2026-06-11 09:48:00	Primary
158	46	114	540.9	2	2026-07-16 09:48:00	Primary
159	46	114	401.9	2	2026-07-16 09:54:00	Secondary
160	47	115	486	4	2026-05-08 09:48:00	Primary
161	47	116	540.9	2	2026-06-12 09:48:00	Primary
162	47	116	401.9	2	2026-06-12 09:54:00	Secondary
163	47	117	820.8	2	2026-07-17 09:48:00	Primary
164	48	118	540.9	2	2026-05-09 09:48:00	Primary
165	48	118	401.9	2	2026-05-09 09:54:00	Secondary
166	48	119	820.8	2	2026-06-13 09:48:00	Primary
167	48	120	428.0	1	2026-07-18 09:48:00	Primary
\.


--
-- TOC entry 5153 (class 0 OID 16435)
-- Dependencies: 227
-- Data for Name: diagnostic_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnostic_orders (order_id, patient_id, admission_id, ordering_physician_id, order_datetime, requested_examination, clinical_reason, priority, order_status) FROM stdin;
1	1	1	1	2026-05-01 09:15:00	ECG	Acute chest pain with suspected myocardial infarction	STAT	Completed
2	1	1	1	2026-05-01 09:30:00	Chest X-Ray	Acute chest pain with suspected myocardial infarction	STAT	Completed
3	1	1	1	2026-05-01 10:30:00	CT Chest	Acute chest pain with suspected myocardial infarction	STAT	Completed
4	1	2	1	2026-06-05 09:15:00	ECG	Acute chest pain with suspected myocardial infarction	STAT	Completed
5	1	2	1	2026-06-05 09:30:00	Chest X-Ray	Acute chest pain with suspected myocardial infarction	STAT	Completed
6	1	3	1	2026-07-01 09:15:00	ECG	Acute chest pain with suspected myocardial infarction	STAT	Completed
7	1	3	1	2026-07-01 09:30:00	Chest X-Ray	Acute chest pain with suspected myocardial infarction	STAT	Completed
8	1	4	1	2026-08-01 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
9	1	4	1	2026-08-01 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
10	1	5	2	2026-09-01 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
11	2	6	1	2026-05-02 09:15:00	ECG	Acute chest pain with suspected myocardial infarction	STAT	Completed
12	2	6	1	2026-05-02 09:30:00	Chest X-Ray	Acute chest pain with suspected myocardial infarction	STAT	Completed
13	2	6	1	2026-05-02 10:30:00	CT Chest	Acute chest pain with suspected myocardial infarction	STAT	Completed
14	2	7	1	2026-06-05 09:15:00	ECG	Acute chest pain with suspected myocardial infarction	Routine	Completed
15	2	7	1	2026-06-05 09:30:00	Chest X-Ray	Acute chest pain with suspected myocardial infarction	Routine	Completed
16	2	8	1	2026-07-10 09:15:00	ECG	Acute chest pain with suspected myocardial infarction	STAT	Completed
17	2	8	1	2026-07-10 09:30:00	Chest X-Ray	Acute chest pain with suspected myocardial infarction	STAT	Completed
18	2	9	2	2026-08-10 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
19	3	10	4	2026-05-01 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
20	3	10	4	2026-05-01 09:30:00	Chest X-Ray	Fever and cough with pneumonia	Routine	Completed
21	3	11	4	2026-06-01 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
22	3	11	4	2026-06-01 09:30:00	Chest X-Ray	Fever and cough with pneumonia	Routine	Completed
23	3	12	4	2026-07-01 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
24	3	12	4	2026-07-01 09:30:00	Chest X-Ray	Fever and cough with pneumonia	Routine	Completed
25	4	13	1	2026-07-10 08:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
26	4	13	1	2026-07-10 08:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
27	4	13	1	2026-07-10 08:18:00	MRI	Fictional reassessment found the additional examination unnecessary.	Routine	Cancelled
28	4	14	2	2026-07-10 13:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
29	5	15	2	2026-08-01 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
30	6	16	2	2026-08-05 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
31	6	16	2	2026-08-05 09:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
32	6	17	2	2026-09-05 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
33	6	17	2	2026-09-05 23:20:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
34	7	18	2	2026-08-10 09:15:00	Complete Blood Count	Severe infection with suspected septicemia	STAT	Completed
35	7	18	2	2026-08-10 09:30:00	Chest X-Ray	Severe infection with suspected septicemia	STAT	Completed
36	8	19	4	2026-08-15 09:15:00	Complete Blood Count	Fever and cough with pneumonia	STAT	Completed
37	8	19	4	2026-08-15 09:30:00	Chest X-Ray	Fever and cough with pneumonia	STAT	Completed
38	7	20	2	2026-04-01 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
39	10	21	2	2026-08-25 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
40	11	22	2	2026-09-01 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
41	12	23	4	2026-09-02 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
42	13	24	1	2026-09-03 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
43	10	25	1	2026-09-04 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
44	10	25	1	2026-09-04 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
45	15	26	1	2026-09-05 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
46	15	26	1	2026-09-05 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
47	15	26	1	2026-09-05 09:18:00	MRI	Fictional reassessment found the additional examination unnecessary.	Routine	Cancelled
48	16	27	1	2026-09-06 09:15:00	Complete Blood Count	Breathlessness and fluid overload	STAT	Completed
49	16	27	1	2026-09-07 09:00:00	Follow-up Blood Test	Ongoing fictional monitoring	Routine	Ordered
50	17	28	1	2026-09-07 09:15:00	ECG	Acute chest pain with suspected myocardial infarction	STAT	Completed
51	17	28	1	2026-09-07 09:30:00	Chest X-Ray	Acute chest pain with suspected myocardial infarction	STAT	Completed
52	18	29	2	2026-03-01 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
53	18	29	2	2026-03-02 09:00:00	Follow-up Blood Test	Ongoing fictional monitoring	Routine	Ordered
54	19	30	2	2026-09-08 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
55	13	31	1	2026-07-01 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
56	20	32	2	2026-06-05 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
57	20	32	2	2026-06-05 09:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
58	20	32	2	2026-06-05 11:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
59	20	33	2	2026-07-10 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
60	20	33	2	2026-07-10 09:30:00	Chest X-Ray	Hip pain after a fall with femoral neck fracture	Routine	Completed
61	20	34	1	2026-08-14 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
62	21	35	2	2026-05-02 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
63	21	35	2	2026-05-02 09:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
64	21	35	2	2026-05-02 11:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
65	21	36	2	2026-06-06 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
66	21	36	2	2026-06-06 09:30:00	Chest X-Ray	Hip pain after a fall with femoral neck fracture	Routine	Completed
67	21	37	1	2026-07-11 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
68	21	38	1	2026-08-15 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
69	21	38	1	2026-08-15 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
70	21	38	1	2026-08-15 11:30:00	CT Chest	Chest pain requiring diagnostic assessment	Routine	Completed
71	22	39	2	2026-05-03 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
72	22	39	2	2026-05-03 09:30:00	Chest X-Ray	Hip pain after a fall with femoral neck fracture	Routine	Completed
73	22	39	2	2026-05-03 09:18:00	MRI	Fictional reassessment found the additional examination unnecessary.	Routine	Cancelled
74	22	40	1	2026-06-07 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
75	22	41	1	2026-07-12 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
76	22	41	1	2026-07-12 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
77	22	41	1	2026-07-12 11:30:00	CT Chest	Chest pain requiring diagnostic assessment	Routine	Completed
78	22	42	2	2026-08-16 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
79	22	42	2	2026-08-16 09:30:00	Chest X-Ray	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
80	23	43	1	2026-05-04 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
81	23	44	1	2026-06-08 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
82	23	44	1	2026-06-08 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
83	23	44	1	2026-06-08 11:30:00	CT Chest	Chest pain requiring diagnostic assessment	Routine	Completed
84	23	45	2	2026-07-13 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
85	23	45	2	2026-07-13 09:30:00	Chest X-Ray	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
86	24	46	1	2026-05-05 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
87	24	46	1	2026-05-05 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
88	24	46	1	2026-05-05 11:30:00	CT Chest	Chest pain requiring diagnostic assessment	Routine	Completed
89	24	47	2	2026-06-09 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
90	24	47	2	2026-06-09 09:30:00	Chest X-Ray	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
91	24	48	2	2026-07-14 09:15:00	Complete Blood Count	Outpatient lipid assessment	Routine	Completed
92	25	49	2	2026-05-06 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
93	25	49	2	2026-05-06 09:30:00	Chest X-Ray	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
94	25	50	2	2026-06-10 09:15:00	Complete Blood Count	Outpatient lipid assessment	Routine	Completed
95	25	51	2	2026-07-15 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
96	25	51	2	2026-07-15 09:30:00	Chest X-Ray	Elevated blood pressure requiring assessment	Routine	Completed
97	25	51	2	2026-07-15 11:30:00	CT Chest	Elevated blood pressure requiring assessment	Routine	Completed
98	26	52	2	2026-05-07 09:15:00	Complete Blood Count	Outpatient lipid assessment	Routine	Completed
99	26	52	2	2026-05-07 09:18:00	MRI	Fictional reassessment found the additional examination unnecessary.	Routine	Cancelled
100	26	53	2	2026-06-11 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
101	26	53	2	2026-06-11 09:30:00	Chest X-Ray	Elevated blood pressure requiring assessment	Routine	Completed
102	26	53	2	2026-06-11 11:30:00	CT Chest	Elevated blood pressure requiring assessment	Routine	Completed
103	26	54	2	2026-07-16 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
104	26	54	2	2026-07-16 09:30:00	Chest X-Ray	Diabetes review and glucose monitoring	Routine	Completed
105	27	55	2	2026-05-08 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
106	27	55	2	2026-05-08 09:30:00	Chest X-Ray	Elevated blood pressure requiring assessment	Routine	Completed
107	27	55	2	2026-05-08 11:30:00	CT Chest	Elevated blood pressure requiring assessment	Routine	Completed
108	27	56	2	2026-06-12 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
109	27	56	2	2026-06-12 09:30:00	Chest X-Ray	Diabetes review and glucose monitoring	Routine	Completed
110	27	57	4	2026-07-17 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
111	28	58	2	2026-05-09 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
112	28	58	2	2026-05-09 09:30:00	Chest X-Ray	Diabetes review and glucose monitoring	Routine	Completed
113	28	59	4	2026-06-13 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
114	28	60	2	2026-07-18 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
115	28	60	2	2026-07-18 09:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
116	28	60	2	2026-07-18 11:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
117	29	61	4	2026-05-10 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
118	29	62	2	2026-06-14 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
119	29	62	2	2026-06-14 09:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
120	29	62	2	2026-06-14 11:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
121	29	63	2	2026-07-19 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
122	29	63	2	2026-07-19 09:30:00	Chest X-Ray	Hip pain after a fall with femoral neck fracture	Routine	Completed
123	30	64	2	2026-05-11 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
124	30	64	2	2026-05-11 09:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
125	30	64	2	2026-05-11 11:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
126	30	65	2	2026-06-15 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
127	30	65	2	2026-06-15 09:30:00	Chest X-Ray	Hip pain after a fall with femoral neck fracture	Routine	Completed
128	30	65	2	2026-06-15 09:18:00	MRI	Fictional reassessment found the additional examination unnecessary.	Routine	Cancelled
129	30	66	1	2026-07-20 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
130	31	67	2	2026-05-12 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
131	31	67	2	2026-05-12 09:30:00	Chest X-Ray	Hip pain after a fall with femoral neck fracture	Routine	Completed
132	31	68	1	2026-06-16 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
133	31	69	1	2026-07-21 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
134	31	69	1	2026-07-21 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
135	31	69	1	2026-07-21 11:30:00	CT Chest	Chest pain requiring diagnostic assessment	Routine	Completed
136	32	70	1	2026-05-13 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
137	32	71	1	2026-06-17 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
138	32	71	1	2026-06-17 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
139	32	71	1	2026-06-17 11:30:00	CT Chest	Chest pain requiring diagnostic assessment	Routine	Completed
140	32	72	2	2026-07-22 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
141	32	72	2	2026-07-22 09:30:00	Chest X-Ray	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
142	33	73	1	2026-05-14 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
143	33	73	1	2026-05-14 09:30:00	Chest X-Ray	Chest pain requiring diagnostic assessment	Routine	Completed
144	33	73	1	2026-05-14 11:30:00	CT Chest	Chest pain requiring diagnostic assessment	Routine	Completed
145	33	74	2	2026-06-18 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
146	33	74	2	2026-06-18 09:30:00	Chest X-Ray	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
147	33	75	2	2026-07-23 09:15:00	Complete Blood Count	Outpatient lipid assessment	Routine	Completed
148	34	76	2	2026-05-15 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
149	34	76	2	2026-05-15 09:30:00	Chest X-Ray	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
150	34	77	2	2026-06-19 09:15:00	Complete Blood Count	Outpatient lipid assessment	Routine	Completed
151	34	78	2	2026-07-24 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
152	34	78	2	2026-07-24 09:30:00	Chest X-Ray	Elevated blood pressure requiring assessment	Routine	Completed
153	34	78	2	2026-07-24 11:30:00	CT Chest	Elevated blood pressure requiring assessment	Routine	Completed
154	34	78	2	2026-07-24 09:18:00	MRI	Fictional reassessment found the additional examination unnecessary.	Routine	Cancelled
155	35	79	2	2026-05-16 09:15:00	Complete Blood Count	Outpatient lipid assessment	Routine	Completed
156	35	80	2	2026-06-20 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
157	35	80	2	2026-06-20 09:30:00	Chest X-Ray	Elevated blood pressure requiring assessment	Routine	Completed
158	35	80	2	2026-06-20 11:30:00	CT Chest	Elevated blood pressure requiring assessment	Routine	Completed
159	35	81	2	2026-07-25 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
160	35	81	2	2026-07-25 09:30:00	Chest X-Ray	Diabetes review and glucose monitoring	Routine	Completed
161	36	82	2	2026-05-17 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
162	36	82	2	2026-05-17 09:30:00	Chest X-Ray	Elevated blood pressure requiring assessment	Routine	Completed
163	36	82	2	2026-05-17 11:30:00	CT Chest	Elevated blood pressure requiring assessment	Routine	Completed
164	36	83	2	2026-06-21 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
165	36	83	2	2026-06-21 09:30:00	Chest X-Ray	Diabetes review and glucose monitoring	Routine	Completed
166	36	84	4	2026-07-26 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
167	37	85	2	2026-05-18 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
168	37	85	2	2026-05-18 09:30:00	Chest X-Ray	Diabetes review and glucose monitoring	Routine	Completed
169	37	86	4	2026-06-22 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
170	37	87	2	2026-07-27 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
171	37	87	2	2026-07-27 09:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
172	37	87	2	2026-07-27 11:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
173	38	88	4	2026-05-19 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
174	38	89	2	2026-06-23 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
175	38	89	2	2026-06-23 09:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
176	38	89	2	2026-06-23 11:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
177	38	90	2	2026-07-28 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
178	38	90	2	2026-07-28 09:30:00	Chest X-Ray	Hip pain after a fall with femoral neck fracture	Routine	Completed
179	39	91	2	2026-05-20 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
180	39	91	2	2026-05-20 09:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
181	39	91	2	2026-05-20 11:30:00	Abdominal CT	Acute abdominal pain with appendicitis	Routine	Completed
182	39	91	2	2026-05-20 09:18:00	MRI	Fictional reassessment found the additional examination unnecessary.	Routine	Cancelled
183	39	92	2	2026-06-24 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
184	39	92	2	2026-06-24 09:30:00	Chest X-Ray	Hip pain after a fall with femoral neck fracture	Routine	Completed
185	39	93	1	2026-07-29 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
186	40	94	2	2026-05-01 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
187	40	95	1	2026-06-05 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
188	40	96	1	2026-07-10 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
189	41	97	1	2026-05-02 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
190	41	98	1	2026-06-06 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
191	41	99	2	2026-07-11 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
192	42	100	1	2026-05-03 09:15:00	ECG	Chest pain requiring diagnostic assessment	Routine	Completed
193	42	101	2	2026-06-07 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
194	42	102	2	2026-07-12 09:15:00	Complete Blood Count	Outpatient lipid assessment	Routine	Completed
195	43	103	2	2026-05-04 09:15:00	Complete Blood Count	Neurological monitoring and rehabilitation after cerebral infarction	Routine	Completed
196	43	104	2	2026-06-08 09:15:00	Complete Blood Count	Outpatient lipid assessment	Routine	Completed
197	43	104	2	2026-06-08 09:18:00	MRI	Fictional reassessment found the additional examination unnecessary.	Routine	Cancelled
198	43	105	2	2026-07-13 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
199	44	106	2	2026-05-05 09:15:00	Complete Blood Count	Outpatient lipid assessment	Routine	Completed
200	44	107	2	2026-06-09 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
201	44	108	2	2026-07-14 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
202	45	109	2	2026-05-06 09:15:00	Complete Blood Count	Elevated blood pressure requiring assessment	Routine	Completed
203	45	110	2	2026-06-10 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
204	45	111	4	2026-07-15 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
205	46	112	2	2026-05-07 09:15:00	Complete Blood Count	Diabetes review and glucose monitoring	Routine	Completed
206	46	113	4	2026-06-11 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
207	46	114	2	2026-07-16 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
208	47	115	4	2026-05-08 09:15:00	Complete Blood Count	Fever and cough with pneumonia	Routine	Completed
209	47	116	2	2026-06-12 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
210	47	117	2	2026-07-17 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
211	47	117	2	2026-07-17 09:18:00	MRI	Fictional reassessment found the additional examination unnecessary.	Routine	Cancelled
212	48	118	2	2026-05-09 09:15:00	Complete Blood Count	Acute abdominal pain with appendicitis	Routine	Completed
213	48	119	2	2026-06-13 09:15:00	Complete Blood Count	Hip pain after a fall with femoral neck fracture	Routine	Completed
214	48	120	1	2026-07-18 09:15:00	Complete Blood Count	Breathlessness and fluid overload	Routine	Completed
\.


--
-- TOC entry 5151 (class 0 OID 16425)
-- Dependencies: 225
-- Data for Name: diagnostic_examinations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnostic_examinations (examination_id, order_id, performed_by_id, examination_type, examination_datetime, examination_status, result_summary) FROM stdin;
1	1	15	ECG	2026-05-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
2	2	13	Chest X-Ray	2026-05-01 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
3	3	13	CT Chest	2026-05-01 11:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
4	4	15	ECG	2026-06-05 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
5	5	13	Chest X-Ray	2026-06-05 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
6	6	15	ECG	2026-07-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
7	7	13	Chest X-Ray	2026-07-01 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
8	8	15	ECG	2026-08-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
9	9	13	Chest X-Ray	2026-08-01 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
10	10	14	Complete Blood Count	2026-09-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
11	11	15	ECG	2026-05-02 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
12	12	13	Chest X-Ray	2026-05-02 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
13	13	13	CT Chest	2026-05-02 11:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
14	14	15	ECG	2026-06-05 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
15	15	13	Chest X-Ray	2026-06-05 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
16	16	15	ECG	2026-07-10 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
17	17	13	Chest X-Ray	2026-07-10 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
18	17	13	Chest X-Ray	2026-07-10 11:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
19	17	13	Chest X-Ray	2026-07-10 12:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
20	18	14	Complete Blood Count	2026-08-10 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
21	19	14	Complete Blood Count	2026-05-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
22	20	13	Chest X-Ray	2026-05-01 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
23	21	14	Complete Blood Count	2026-06-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
24	22	13	Chest X-Ray	2026-06-01 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
25	23	14	Complete Blood Count	2026-07-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
26	24	13	Chest X-Ray	2026-07-01 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
27	25	15	ECG	2026-07-10 08:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
28	26	13	Chest X-Ray	2026-07-10 09:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
29	28	14	Complete Blood Count	2026-07-10 13:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
30	29	14	Complete Blood Count	2026-08-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
31	30	14	Complete Blood Count	2026-08-05 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
32	31	13	Abdominal CT	2026-08-05 10:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
33	32	14	Complete Blood Count	2026-09-05 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
34	33	13	Abdominal CT	2026-09-05 23:50:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
35	34	14	Complete Blood Count	2026-08-10 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
36	35	13	Chest X-Ray	2026-08-10 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
37	36	14	Complete Blood Count	2026-08-15 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
38	37	13	Chest X-Ray	2026-08-15 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
39	38	14	Complete Blood Count	2026-04-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
40	39	14	Complete Blood Count	2026-08-25 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
41	40	14	Complete Blood Count	2026-09-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
42	41	14	Complete Blood Count	2026-09-02 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
43	42	14	Complete Blood Count	2026-09-03 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
44	43	15	ECG	2026-09-04 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
45	44	13	Chest X-Ray	2026-09-04 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
46	45	15	ECG	2026-09-05 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
47	46	13	Chest X-Ray	2026-09-05 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
48	48	14	Complete Blood Count	2026-09-06 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
49	50	15	ECG	2026-09-07 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
50	51	13	Chest X-Ray	2026-09-07 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
51	52	14	Complete Blood Count	2026-03-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
52	54	14	Complete Blood Count	2026-09-08 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
53	55	14	Complete Blood Count	2026-07-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
54	56	14	Complete Blood Count	2026-06-05 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
55	57	13	Abdominal CT	2026-06-05 10:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
56	58	13	Abdominal CT	2026-06-05 12:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
57	59	14	Complete Blood Count	2026-07-10 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
58	60	13	Chest X-Ray	2026-07-10 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
59	61	14	Complete Blood Count	2026-08-14 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
60	62	14	Complete Blood Count	2026-05-02 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
61	63	13	Abdominal CT	2026-05-02 10:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
62	64	13	Abdominal CT	2026-05-02 12:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
63	65	14	Complete Blood Count	2026-06-06 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
64	66	13	Chest X-Ray	2026-06-06 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
65	67	14	Complete Blood Count	2026-07-11 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
66	68	15	ECG	2026-08-15 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
67	69	13	Chest X-Ray	2026-08-15 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
68	70	13	CT Chest	2026-08-15 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
69	71	14	Complete Blood Count	2026-05-03 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
70	72	13	Chest X-Ray	2026-05-03 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
71	74	14	Complete Blood Count	2026-06-07 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
72	75	15	ECG	2026-07-12 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
73	76	13	Chest X-Ray	2026-07-12 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
74	77	13	CT Chest	2026-07-12 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
75	78	14	Complete Blood Count	2026-08-16 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
76	79	13	Chest X-Ray	2026-08-16 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
77	80	14	Complete Blood Count	2026-05-04 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
78	81	15	ECG	2026-06-08 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
79	82	13	Chest X-Ray	2026-06-08 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
80	83	13	CT Chest	2026-06-08 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
81	84	14	Complete Blood Count	2026-07-13 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
82	85	13	Chest X-Ray	2026-07-13 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
83	86	15	ECG	2026-05-05 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
84	87	13	Chest X-Ray	2026-05-05 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
85	88	13	CT Chest	2026-05-05 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
86	89	14	Complete Blood Count	2026-06-09 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
87	90	13	Chest X-Ray	2026-06-09 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
88	91	14	Complete Blood Count	2026-07-14 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
89	92	14	Complete Blood Count	2026-05-06 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
90	93	13	Chest X-Ray	2026-05-06 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
91	94	14	Complete Blood Count	2026-06-10 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
92	95	14	Complete Blood Count	2026-07-15 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
93	96	13	Chest X-Ray	2026-07-15 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
94	97	13	CT Chest	2026-07-15 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
95	98	14	Complete Blood Count	2026-05-07 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
96	100	14	Complete Blood Count	2026-06-11 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
97	101	13	Chest X-Ray	2026-06-11 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
98	102	13	CT Chest	2026-06-11 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
99	103	14	Complete Blood Count	2026-07-16 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
100	104	13	Chest X-Ray	2026-07-16 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
101	105	14	Complete Blood Count	2026-05-08 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
102	106	13	Chest X-Ray	2026-05-08 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
103	107	13	CT Chest	2026-05-08 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
104	108	14	Complete Blood Count	2026-06-12 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
105	109	13	Chest X-Ray	2026-06-12 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
106	110	14	Complete Blood Count	2026-07-17 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
107	111	14	Complete Blood Count	2026-05-09 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
108	112	13	Chest X-Ray	2026-05-09 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
109	113	14	Complete Blood Count	2026-06-13 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
110	114	14	Complete Blood Count	2026-07-18 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
111	115	13	Abdominal CT	2026-07-18 10:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
112	116	13	Abdominal CT	2026-07-18 12:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
113	117	14	Complete Blood Count	2026-05-10 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
114	118	14	Complete Blood Count	2026-06-14 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
115	119	13	Abdominal CT	2026-06-14 10:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
116	120	13	Abdominal CT	2026-06-14 12:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
117	121	14	Complete Blood Count	2026-07-19 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
118	122	13	Chest X-Ray	2026-07-19 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
119	123	14	Complete Blood Count	2026-05-11 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
120	124	13	Abdominal CT	2026-05-11 10:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
121	125	13	Abdominal CT	2026-05-11 12:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
122	126	14	Complete Blood Count	2026-06-15 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
123	127	13	Chest X-Ray	2026-06-15 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
124	129	14	Complete Blood Count	2026-07-20 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
125	130	14	Complete Blood Count	2026-05-12 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
126	131	13	Chest X-Ray	2026-05-12 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
127	132	14	Complete Blood Count	2026-06-16 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
128	133	15	ECG	2026-07-21 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
129	134	13	Chest X-Ray	2026-07-21 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
130	135	13	CT Chest	2026-07-21 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
131	136	14	Complete Blood Count	2026-05-13 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
132	137	15	ECG	2026-06-17 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
133	138	13	Chest X-Ray	2026-06-17 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
134	139	13	CT Chest	2026-06-17 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
135	140	14	Complete Blood Count	2026-07-22 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
136	141	13	Chest X-Ray	2026-07-22 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
137	142	15	ECG	2026-05-14 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
138	143	13	Chest X-Ray	2026-05-14 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
139	144	13	CT Chest	2026-05-14 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
140	145	14	Complete Blood Count	2026-06-18 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
141	146	13	Chest X-Ray	2026-06-18 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
142	147	14	Complete Blood Count	2026-07-23 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
143	148	14	Complete Blood Count	2026-05-15 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
144	149	13	Chest X-Ray	2026-05-15 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
145	150	14	Complete Blood Count	2026-06-19 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
146	151	14	Complete Blood Count	2026-07-24 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
147	152	13	Chest X-Ray	2026-07-24 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
148	153	13	CT Chest	2026-07-24 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
149	155	14	Complete Blood Count	2026-05-16 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
150	156	14	Complete Blood Count	2026-06-20 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
151	157	13	Chest X-Ray	2026-06-20 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
152	158	13	CT Chest	2026-06-20 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
153	159	14	Complete Blood Count	2026-07-25 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
154	160	13	Chest X-Ray	2026-07-25 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
155	161	14	Complete Blood Count	2026-05-17 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
156	162	13	Chest X-Ray	2026-05-17 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
157	163	13	CT Chest	2026-05-17 12:00:00	Completed	Fictional CT Chest findings reviewed; see radiology report.
158	164	14	Complete Blood Count	2026-06-21 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
159	165	13	Chest X-Ray	2026-06-21 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
160	166	14	Complete Blood Count	2026-07-26 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
161	167	14	Complete Blood Count	2026-05-18 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
162	168	13	Chest X-Ray	2026-05-18 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
163	169	14	Complete Blood Count	2026-06-22 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
164	170	14	Complete Blood Count	2026-07-27 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
165	171	13	Abdominal CT	2026-07-27 10:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
166	172	13	Abdominal CT	2026-07-27 12:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
167	173	14	Complete Blood Count	2026-05-19 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
168	174	14	Complete Blood Count	2026-06-23 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
169	175	13	Abdominal CT	2026-06-23 10:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
170	176	13	Abdominal CT	2026-06-23 12:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
171	177	14	Complete Blood Count	2026-07-28 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
172	178	13	Chest X-Ray	2026-07-28 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
173	179	14	Complete Blood Count	2026-05-20 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
174	180	13	Abdominal CT	2026-05-20 10:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
175	181	13	Abdominal CT	2026-05-20 12:00:00	Completed	Fictional Abdominal CT findings reviewed; see radiology report.
176	183	14	Complete Blood Count	2026-06-24 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
177	184	13	Chest X-Ray	2026-06-24 10:00:00	Completed	Fictional Chest X-Ray findings reviewed; see radiology report.
178	185	14	Complete Blood Count	2026-07-29 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
179	186	14	Complete Blood Count	2026-05-01 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
180	187	14	Complete Blood Count	2026-06-05 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
181	188	15	ECG	2026-07-10 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
182	189	14	Complete Blood Count	2026-05-02 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
183	190	15	ECG	2026-06-06 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
184	191	14	Complete Blood Count	2026-07-11 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
185	192	15	ECG	2026-05-03 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
186	193	14	Complete Blood Count	2026-06-07 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
187	194	14	Complete Blood Count	2026-07-12 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
188	195	14	Complete Blood Count	2026-05-04 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
189	196	14	Complete Blood Count	2026-06-08 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
190	198	14	Complete Blood Count	2026-07-13 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
191	199	14	Complete Blood Count	2026-05-05 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
192	200	14	Complete Blood Count	2026-06-09 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
193	201	14	Complete Blood Count	2026-07-14 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
194	202	14	Complete Blood Count	2026-05-06 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
195	203	14	Complete Blood Count	2026-06-10 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
196	204	14	Complete Blood Count	2026-07-15 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
197	205	14	Complete Blood Count	2026-05-07 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
198	206	14	Complete Blood Count	2026-06-11 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
199	207	14	Complete Blood Count	2026-07-16 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
200	208	14	Complete Blood Count	2026-05-08 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
201	209	14	Complete Blood Count	2026-06-12 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
202	210	14	Complete Blood Count	2026-07-17 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
203	212	14	Complete Blood Count	2026-05-09 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
204	213	14	Complete Blood Count	2026-06-13 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
205	214	14	Complete Blood Count	2026-07-18 09:30:00	Completed	Fictional test findings recorded for educational database demonstrations; interpretation reviewed by the treating physician.
\.


--
-- TOC entry 5155 (class 0 OID 16447)
-- Dependencies: 229
-- Data for Name: discharge_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discharge_records (discharge_id, admission_id, responsible_physician_id, discharge_destination, discharge_condition, prescribed_medications, follow_up_instructions, follow_up_appointment_datetime) FROM stdin;
1	1	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-07 09:00:00
2	2	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-22 09:00:00
3	3	1	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-18 09:00:00
4	4	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
5	5	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-09-08 21:00:00
6	6	1	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-08 09:00:00
7	7	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-17 09:00:00
8	8	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
9	9	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-20 09:00:00
10	10	4	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-15 09:00:00
11	11	4	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-18 09:00:00
12	12	4	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
13	13	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-17 11:00:00
14	14	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-17 18:00:00
15	15	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-08 12:00:00
16	16	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
17	17	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-09-14 09:00:00
18	18	2	Mortuary	Deceased	\N	\N	\N
19	19	4	Mortuary	Deceased	\N	\N	\N
20	20	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
21	21	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-09-02 09:00:00
22	22	2	Home	Improved	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-09-10 09:00:00
23	23	4	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-09-12 09:00:00
24	24	1	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
25	25	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-09-12 09:00:00
26	26	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-09-12 13:00:00
27	28	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
28	30	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-09-15 21:00:00
29	31	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-10 09:00:00
30	32	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
31	33	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-18 15:00:00
32	34	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-23 03:00:00
33	35	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-10 03:00:00
34	36	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
35	37	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-20 03:00:00
36	38	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-24 15:00:00
37	39	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-11 15:00:00
38	40	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
39	41	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-21 15:00:00
40	42	2	Rehabilitation Facility	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-23 15:00:00
41	43	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-13 03:00:00
42	44	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
43	45	2	Rehabilitation Facility	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-20 15:00:00
44	46	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-14 15:00:00
45	47	2	Rehabilitation Facility	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-16 15:00:00
46	48	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
47	49	2	Rehabilitation Facility	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-13 15:00:00
48	50	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-18 03:00:00
49	51	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-23 15:00:00
50	52	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
51	53	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-19 15:00:00
52	54	2	Home	Stable	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-25 03:00:00
53	55	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-16 15:00:00
54	56	2	Home	Improved	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
55	57	4	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-26 15:00:00
56	58	2	Home	Improved	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-18 03:00:00
57	59	4	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-22 15:00:00
58	60	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
59	61	4	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-19 15:00:00
60	62	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-21 15:00:00
61	63	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-27 03:00:00
62	64	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
63	65	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-23 03:00:00
64	66	1	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-28 15:00:00
65	67	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-20 03:00:00
66	68	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
67	69	1	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-30 03:00:00
68	70	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-21 15:00:00
69	71	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-26 03:00:00
70	72	2	Rehabilitation Facility	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
71	73	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-23 03:00:00
72	74	2	Rehabilitation Facility	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-27 15:00:00
73	75	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-30 15:00:00
74	76	2	Rehabilitation Facility	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
75	77	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-26 15:00:00
76	78	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-01 03:00:00
77	79	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-23 15:00:00
78	80	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
79	81	2	Home	Stable	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-02 15:00:00
80	82	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-25 03:00:00
81	83	2	Home	Improved	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-29 15:00:00
82	84	4	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
83	85	2	Home	Improved	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-26 15:00:00
84	86	4	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-01 03:00:00
85	87	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-05 15:00:00
86	88	4	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
87	89	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-02 15:00:00
88	90	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-04 15:00:00
89	91	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-29 15:00:00
90	92	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
91	93	1	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-08-06 03:00:00
92	94	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-08 15:00:00
93	95	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-13 03:00:00
94	96	1	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
95	97	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-10 03:00:00
96	98	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-14 15:00:00
97	99	2	Rehabilitation Facility	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-20 03:00:00
98	100	1	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
99	101	2	Rehabilitation Facility	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-16 03:00:00
100	102	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-21 15:00:00
101	103	2	Rehabilitation Facility	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-13 03:00:00
102	104	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
103	105	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-20 15:00:00
104	106	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-14 15:00:00
105	107	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-16 15:00:00
106	108	2	Home	Stable	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
107	109	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-13 15:00:00
108	110	2	Home	Improved	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-18 03:00:00
109	111	4	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-23 15:00:00
110	112	2	Home	Improved	Synthetic prescription summary: continue previously prescribed diabetes medicines as reviewed.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
111	113	4	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-19 15:00:00
112	114	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-25 03:00:00
113	115	4	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-16 15:00:00
114	116	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
115	117	2	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-07-26 15:00:00
116	118	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-05-18 03:00:00
117	119	2	Home	Improved	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	2026-06-22 15:00:00
118	120	1	Home	Stable	Synthetic prescription summary: medications reconciled with the discharge plan.	Fictional follow-up plan supplied; this text is educational data and is not treatment advice.	\N
\.


--
-- TOC entry 5159 (class 0 OID 16465)
-- Dependencies: 233
-- Data for Name: hospital_units; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital_units (unit_id, unit_name, unit_type) FROM stdin;
1	Synthetic Emergency Department	Emergency
2	Synthetic ICU East	ICU
3	Synthetic Coronary Care Unit	CCU
4	Synthetic Medical ICU	MICU
5	Synthetic Surgical ICU	SICU
6	Synthetic General Ward	General Ward
7	Synthetic ICU West	ICU
8	Synthetic Surgical Ward	General Ward
\.


--
-- TOC entry 5164 (class 0 OID 16495)
-- Dependencies: 238
-- Data for Name: radiology_examinations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.radiology_examinations (radiology_id, examination_id, referring_physician_id, technician_id, body_area, image_link) FROM stdin;
1	2	1	13	Chest	https://synthetic-hospital.example/images/IMG-0001
2	3	1	13	Chest	https://synthetic-hospital.example/images/IMG-0002
3	5	1	13	Chest	https://synthetic-hospital.example/images/IMG-0003
4	7	1	13	Chest	https://synthetic-hospital.example/images/IMG-0004
5	9	1	13	Chest	https://synthetic-hospital.example/images/IMG-0005
6	12	1	13	Chest	https://synthetic-hospital.example/images/IMG-0006
7	13	1	13	Chest	https://synthetic-hospital.example/images/IMG-0007
8	15	1	13	Chest	https://synthetic-hospital.example/images/IMG-0008
9	17	1	13	Chest	https://synthetic-hospital.example/images/IMG-0009
10	18	1	13	Chest	https://synthetic-hospital.example/images/IMG-0010
11	19	1	13	Chest	https://synthetic-hospital.example/images/IMG-0011
12	22	4	13	Chest	https://synthetic-hospital.example/images/IMG-0012
13	24	4	13	Chest	https://synthetic-hospital.example/images/IMG-0013
14	26	4	13	Chest	https://synthetic-hospital.example/images/IMG-0014
15	28	1	13	Chest	https://synthetic-hospital.example/images/IMG-0015
16	32	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0016
17	34	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0017
18	36	2	13	Chest	https://synthetic-hospital.example/images/IMG-0018
19	38	4	13	Chest	https://synthetic-hospital.example/images/IMG-0019
20	45	1	13	Chest	https://synthetic-hospital.example/images/IMG-0020
21	47	1	13	Chest	https://synthetic-hospital.example/images/IMG-0021
22	50	1	13	Chest	https://synthetic-hospital.example/images/IMG-0022
23	55	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0023
24	56	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0024
25	58	2	13	Chest	https://synthetic-hospital.example/images/IMG-0025
26	61	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0026
27	62	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0027
28	64	2	13	Chest	https://synthetic-hospital.example/images/IMG-0028
29	67	1	13	Chest	https://synthetic-hospital.example/images/IMG-0029
30	68	1	13	Chest	https://synthetic-hospital.example/images/IMG-0030
31	70	2	13	Chest	https://synthetic-hospital.example/images/IMG-0031
32	73	1	13	Chest	https://synthetic-hospital.example/images/IMG-0032
33	74	1	13	Chest	https://synthetic-hospital.example/images/IMG-0033
34	76	2	13	Chest	https://synthetic-hospital.example/images/IMG-0034
35	79	1	13	Chest	https://synthetic-hospital.example/images/IMG-0035
36	80	1	13	Chest	https://synthetic-hospital.example/images/IMG-0036
37	82	2	13	Chest	https://synthetic-hospital.example/images/IMG-0037
38	84	1	13	Chest	https://synthetic-hospital.example/images/IMG-0038
39	85	1	13	Chest	https://synthetic-hospital.example/images/IMG-0039
40	87	2	13	Chest	https://synthetic-hospital.example/images/IMG-0040
41	90	2	13	Chest	https://synthetic-hospital.example/images/IMG-0041
42	93	2	13	Chest	https://synthetic-hospital.example/images/IMG-0042
43	94	2	13	Chest	https://synthetic-hospital.example/images/IMG-0043
44	97	2	13	Chest	https://synthetic-hospital.example/images/IMG-0044
45	98	2	13	Chest	https://synthetic-hospital.example/images/IMG-0045
46	100	2	13	Chest	https://synthetic-hospital.example/images/IMG-0046
47	102	2	13	Chest	https://synthetic-hospital.example/images/IMG-0047
48	103	2	13	Chest	https://synthetic-hospital.example/images/IMG-0048
49	105	2	13	Chest	https://synthetic-hospital.example/images/IMG-0049
50	108	2	13	Chest	https://synthetic-hospital.example/images/IMG-0050
51	111	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0051
52	112	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0052
53	115	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0053
54	116	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0054
55	118	2	13	Chest	https://synthetic-hospital.example/images/IMG-0055
56	120	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0056
57	121	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0057
58	123	2	13	Chest	https://synthetic-hospital.example/images/IMG-0058
59	126	2	13	Chest	https://synthetic-hospital.example/images/IMG-0059
60	129	1	13	Chest	https://synthetic-hospital.example/images/IMG-0060
61	130	1	13	Chest	https://synthetic-hospital.example/images/IMG-0061
62	133	1	13	Chest	https://synthetic-hospital.example/images/IMG-0062
63	134	1	13	Chest	https://synthetic-hospital.example/images/IMG-0063
64	136	2	13	Chest	https://synthetic-hospital.example/images/IMG-0064
65	138	1	13	Chest	https://synthetic-hospital.example/images/IMG-0065
66	139	1	13	Chest	https://synthetic-hospital.example/images/IMG-0066
67	141	2	13	Chest	https://synthetic-hospital.example/images/IMG-0067
68	144	2	13	Chest	https://synthetic-hospital.example/images/IMG-0068
69	147	2	13	Chest	https://synthetic-hospital.example/images/IMG-0069
70	148	2	13	Chest	https://synthetic-hospital.example/images/IMG-0070
71	151	2	13	Chest	https://synthetic-hospital.example/images/IMG-0071
72	152	2	13	Chest	https://synthetic-hospital.example/images/IMG-0072
73	154	2	13	Chest	https://synthetic-hospital.example/images/IMG-0073
74	156	2	13	Chest	https://synthetic-hospital.example/images/IMG-0074
75	157	2	13	Chest	https://synthetic-hospital.example/images/IMG-0075
76	159	2	13	Chest	https://synthetic-hospital.example/images/IMG-0076
77	162	2	13	Chest	https://synthetic-hospital.example/images/IMG-0077
78	165	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0078
79	166	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0079
80	169	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0080
81	170	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0081
82	172	2	13	Chest	https://synthetic-hospital.example/images/IMG-0082
83	174	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0083
84	175	2	13	Abdomen	https://synthetic-hospital.example/images/IMG-0084
85	177	2	13	Chest	https://synthetic-hospital.example/images/IMG-0085
\.


--
-- TOC entry 5166 (class 0 OID 16506)
-- Dependencies: 241
-- Data for Name: radiology_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.radiology_reports (report_id, radiology_id, radiologist_id, report_datetime, findings, impression) FROM stdin;
1	1	11	2026-05-01 10:15:00	Fictional Chest X-Ray imaging findings for encounter 1. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
2	2	12	2026-05-01 11:15:00	Fictional CT Chest imaging findings for encounter 1. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
3	3	11	2026-06-05 10:15:00	Fictional Chest X-Ray imaging findings for encounter 2. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
4	4	11	2026-07-01 10:15:00	Fictional Chest X-Ray imaging findings for encounter 3. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
5	5	11	2026-08-01 10:15:00	Fictional Chest X-Ray imaging findings for encounter 4. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
6	6	11	2026-05-02 10:15:00	Fictional Chest X-Ray imaging findings for encounter 6. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
7	7	12	2026-05-02 11:15:00	Fictional CT Chest imaging findings for encounter 6. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
8	8	11	2026-06-05 10:15:00	Fictional Chest X-Ray imaging findings for encounter 7. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
9	9	11	2026-07-10 10:15:00	Fictional Chest X-Ray imaging findings for encounter 8. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
10	10	12	2026-07-10 11:15:00	Fictional Chest X-Ray imaging findings for encounter 8. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
11	11	11	2026-07-10 12:15:00	Fictional Chest X-Ray imaging findings for encounter 8. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
12	12	11	2026-05-01 10:15:00	Fictional Chest X-Ray imaging findings for encounter 10. No actual medical image or patient is represented.	Synthetic imaging impression consistent with the documented pneumonia scenario.
13	13	11	2026-06-01 10:15:00	Fictional Chest X-Ray imaging findings for encounter 11. No actual medical image or patient is represented.	Synthetic imaging impression consistent with the documented pneumonia scenario.
14	14	11	2026-07-01 10:15:00	Fictional Chest X-Ray imaging findings for encounter 12. No actual medical image or patient is represented.	Synthetic imaging impression consistent with the documented pneumonia scenario.
15	15	11	2026-07-10 09:15:00	Fictional Chest X-Ray imaging findings for encounter 13. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
16	16	11	2026-08-05 10:15:00	Fictional Abdominal CT imaging findings for encounter 16. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
17	17	11	2026-09-06 00:05:00	Fictional Abdominal CT imaging findings for encounter 17. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
18	18	11	2026-08-10 10:15:00	Fictional Chest X-Ray imaging findings for encounter 18. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
19	19	11	2026-08-15 10:15:00	Fictional Chest X-Ray imaging findings for encounter 19. No actual medical image or patient is represented.	Synthetic imaging impression consistent with the documented pneumonia scenario.
20	20	11	2026-09-04 10:15:00	Fictional Chest X-Ray imaging findings for encounter 25. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
21	21	11	2026-09-05 10:15:00	Fictional Chest X-Ray imaging findings for encounter 26. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
22	22	11	2026-09-07 10:15:00	Fictional Chest X-Ray imaging findings for encounter 28. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
23	23	11	2026-06-05 10:15:00	Fictional Abdominal CT imaging findings for encounter 32. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
24	24	12	2026-06-05 12:15:00	Fictional Abdominal CT imaging findings for encounter 32. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
25	25	11	2026-07-10 10:15:00	Fictional Chest X-Ray imaging findings for encounter 33. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
26	26	11	2026-05-02 10:15:00	Fictional Abdominal CT imaging findings for encounter 35. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
27	27	12	2026-05-02 12:15:00	Fictional Abdominal CT imaging findings for encounter 35. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
28	28	11	2026-06-06 10:15:00	Fictional Chest X-Ray imaging findings for encounter 36. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
29	29	11	2026-08-15 10:15:00	Fictional Chest X-Ray imaging findings for encounter 38. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
30	30	12	2026-08-15 12:15:00	Fictional CT Chest imaging findings for encounter 38. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
31	31	11	2026-05-03 10:15:00	Fictional Chest X-Ray imaging findings for encounter 39. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
32	32	11	2026-07-12 10:15:00	Fictional Chest X-Ray imaging findings for encounter 41. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
33	33	12	2026-07-12 12:15:00	Fictional CT Chest imaging findings for encounter 41. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
34	34	11	2026-08-16 10:15:00	Fictional Chest X-Ray imaging findings for encounter 42. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
35	35	11	2026-06-08 10:15:00	Fictional Chest X-Ray imaging findings for encounter 44. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
36	36	12	2026-06-08 12:15:00	Fictional CT Chest imaging findings for encounter 44. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
37	37	11	2026-07-13 10:15:00	Fictional Chest X-Ray imaging findings for encounter 45. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
38	38	11	2026-05-05 10:15:00	Fictional Chest X-Ray imaging findings for encounter 46. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
39	39	12	2026-05-05 12:15:00	Fictional CT Chest imaging findings for encounter 46. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
40	40	11	2026-06-09 10:15:00	Fictional Chest X-Ray imaging findings for encounter 47. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
41	41	11	2026-05-06 10:15:00	Fictional Chest X-Ray imaging findings for encounter 49. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
42	42	11	2026-07-15 10:15:00	Fictional Chest X-Ray imaging findings for encounter 51. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
43	43	12	2026-07-15 12:15:00	Fictional CT Chest imaging findings for encounter 51. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
44	44	11	2026-06-11 10:15:00	Fictional Chest X-Ray imaging findings for encounter 53. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
45	45	12	2026-06-11 12:15:00	Fictional CT Chest imaging findings for encounter 53. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
46	46	11	2026-07-16 10:15:00	Fictional Chest X-Ray imaging findings for encounter 54. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
47	47	11	2026-05-08 10:15:00	Fictional Chest X-Ray imaging findings for encounter 55. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
48	48	12	2026-05-08 12:15:00	Fictional CT Chest imaging findings for encounter 55. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
49	49	11	2026-06-12 10:15:00	Fictional Chest X-Ray imaging findings for encounter 56. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
50	50	11	2026-05-09 10:15:00	Fictional Chest X-Ray imaging findings for encounter 58. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
51	51	11	2026-07-18 10:15:00	Fictional Abdominal CT imaging findings for encounter 60. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
52	52	12	2026-07-18 12:15:00	Fictional Abdominal CT imaging findings for encounter 60. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
53	53	11	2026-06-14 10:15:00	Fictional Abdominal CT imaging findings for encounter 62. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
54	54	12	2026-06-14 12:15:00	Fictional Abdominal CT imaging findings for encounter 62. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
55	55	11	2026-07-19 10:15:00	Fictional Chest X-Ray imaging findings for encounter 63. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
56	56	11	2026-05-11 10:15:00	Fictional Abdominal CT imaging findings for encounter 64. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
57	57	12	2026-05-11 12:15:00	Fictional Abdominal CT imaging findings for encounter 64. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
58	58	11	2026-06-15 10:15:00	Fictional Chest X-Ray imaging findings for encounter 65. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
59	59	11	2026-05-12 10:15:00	Fictional Chest X-Ray imaging findings for encounter 67. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
60	60	11	2026-07-21 10:15:00	Fictional Chest X-Ray imaging findings for encounter 69. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
61	61	12	2026-07-21 12:15:00	Fictional CT Chest imaging findings for encounter 69. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
62	62	11	2026-06-17 10:15:00	Fictional Chest X-Ray imaging findings for encounter 71. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
63	63	12	2026-06-17 12:15:00	Fictional CT Chest imaging findings for encounter 71. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
64	64	11	2026-07-22 10:15:00	Fictional Chest X-Ray imaging findings for encounter 72. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
65	65	11	2026-05-14 10:15:00	Fictional Chest X-Ray imaging findings for encounter 73. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
66	66	12	2026-05-14 12:15:00	Fictional CT Chest imaging findings for encounter 73. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
67	67	11	2026-06-18 10:15:00	Fictional Chest X-Ray imaging findings for encounter 74. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
68	68	11	2026-05-15 10:15:00	Fictional Chest X-Ray imaging findings for encounter 76. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
69	69	11	2026-07-24 10:15:00	Fictional Chest X-Ray imaging findings for encounter 78. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
70	70	12	2026-07-24 12:15:00	Fictional CT Chest imaging findings for encounter 78. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
71	71	11	2026-06-20 10:15:00	Fictional Chest X-Ray imaging findings for encounter 80. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
72	72	12	2026-06-20 12:15:00	Fictional CT Chest imaging findings for encounter 80. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
73	73	11	2026-07-25 10:15:00	Fictional Chest X-Ray imaging findings for encounter 81. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
74	74	11	2026-05-17 10:15:00	Fictional Chest X-Ray imaging findings for encounter 82. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
75	75	12	2026-05-17 12:15:00	Fictional CT Chest imaging findings for encounter 82. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
76	76	11	2026-06-21 10:15:00	Fictional Chest X-Ray imaging findings for encounter 83. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
77	77	11	2026-05-18 10:15:00	Fictional Chest X-Ray imaging findings for encounter 85. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
78	78	11	2026-07-27 10:15:00	Fictional Abdominal CT imaging findings for encounter 87. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
79	79	12	2026-07-27 12:15:00	Fictional Abdominal CT imaging findings for encounter 87. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
80	80	11	2026-06-23 10:15:00	Fictional Abdominal CT imaging findings for encounter 89. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
81	81	12	2026-06-23 12:15:00	Fictional Abdominal CT imaging findings for encounter 89. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
82	82	11	2026-07-28 10:15:00	Fictional Chest X-Ray imaging findings for encounter 90. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
83	83	11	2026-05-20 10:15:00	Fictional Abdominal CT imaging findings for encounter 91. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
84	84	12	2026-05-20 12:15:00	Fictional Abdominal CT imaging findings for encounter 91. No actual medical image or patient is represented.	Synthetic abdominal imaging impression supports the documented appendicitis scenario.
85	85	11	2026-06-24 10:15:00	Fictional Chest X-Ray imaging findings for encounter 92. No actual medical image or patient is represented.	Synthetic imaging impression supplied for educational query testing.
\.


--
-- TOC entry 5168 (class 0 OID 16516)
-- Dependencies: 243
-- Data for Name: surgical_procedures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.surgical_procedures (procedure_id, admission_id, surgeon_id, procedure_name, procedure_datetime, operating_room, procedure_notes) FROM stdin;
1	1	5	Coronary artery bypass grafting	2026-05-01 12:00:00	SYN-OR-2	Fictional procedure event for encounter 1; no actual operation or patient is represented.
2	1	5	Re-exploration for postoperative bleeding	2026-05-01 16:00:00	SYN-OR-2	Fictional procedure event for encounter 1; no actual operation or patient is represented.
3	2	5	Coronary artery bypass grafting	2026-06-06 09:00:00	SYN-OR-3	Fictional procedure event for encounter 2; no actual operation or patient is represented.
4	3	5	Coronary artery bypass grafting	2026-07-01 11:00:00	SYN-OR-1	Fictional procedure event for encounter 3; no actual operation or patient is represented.
5	6	5	Coronary artery bypass grafting	2026-05-02 12:00:00	SYN-OR-1	Fictional procedure event for encounter 6; no actual operation or patient is represented.
6	9	7	Internal fixation of femoral neck fracture	2026-08-10 12:00:00	SYN-OR-1	Fictional procedure event for encounter 9; no actual operation or patient is represented.
7	14	6	Laparoscopic appendectomy	2026-07-10 14:00:00	SYN-OR-3	Fictional procedure event for encounter 14; no actual operation or patient is represented.
8	16	6	Laparoscopic appendectomy	2026-08-06 12:00:00	SYN-OR-2	Fictional procedure event for encounter 16; no actual operation or patient is represented.
9	17	6	Laparoscopic appendectomy	2026-09-06 00:10:00	SYN-OR-3	Fictional procedure event for encounter 17; no actual operation or patient is represented.
10	28	5	Coronary artery bypass grafting	2026-09-07 12:00:00	SYN-OR-2	Fictional procedure event for encounter 28; no actual operation or patient is represented.
11	31	5	Coronary artery bypass grafting	2026-07-01 12:00:00	SYN-OR-2	Fictional procedure event for encounter 31; no actual operation or patient is represented.
12	32	6	Laparoscopic appendectomy	2026-06-05 11:00:00	SYN-OR-3	Fictional procedure event for encounter 32; no actual operation or patient is represented.
13	33	7	Internal fixation of femoral neck fracture	2026-07-10 11:00:00	SYN-OR-1	Fictional procedure event for encounter 33; no actual operation or patient is represented.
14	35	6	Laparoscopic appendectomy	2026-05-02 11:00:00	SYN-OR-3	Fictional procedure event for encounter 35; no actual operation or patient is represented.
15	36	7	Internal fixation of femoral neck fracture	2026-06-06 11:00:00	SYN-OR-1	Fictional procedure event for encounter 36; no actual operation or patient is represented.
16	39	7	Internal fixation of femoral neck fracture	2026-05-03 11:00:00	SYN-OR-1	Fictional procedure event for encounter 39; no actual operation or patient is represented.
17	60	6	Laparoscopic appendectomy	2026-07-18 11:00:00	SYN-OR-1	Fictional procedure event for encounter 60; no actual operation or patient is represented.
18	62	6	Laparoscopic appendectomy	2026-06-14 11:00:00	SYN-OR-3	Fictional procedure event for encounter 62; no actual operation or patient is represented.
19	63	7	Internal fixation of femoral neck fracture	2026-07-19 11:00:00	SYN-OR-1	Fictional procedure event for encounter 63; no actual operation or patient is represented.
20	64	6	Laparoscopic appendectomy	2026-05-11 11:00:00	SYN-OR-2	Fictional procedure event for encounter 64; no actual operation or patient is represented.
21	65	7	Internal fixation of femoral neck fracture	2026-06-15 11:00:00	SYN-OR-3	Fictional procedure event for encounter 65; no actual operation or patient is represented.
22	67	7	Internal fixation of femoral neck fracture	2026-05-12 11:00:00	SYN-OR-2	Fictional procedure event for encounter 67; no actual operation or patient is represented.
23	87	6	Laparoscopic appendectomy	2026-07-27 11:00:00	SYN-OR-1	Fictional procedure event for encounter 87; no actual operation or patient is represented.
24	89	6	Laparoscopic appendectomy	2026-06-23 11:00:00	SYN-OR-3	Fictional procedure event for encounter 89; no actual operation or patient is represented.
25	90	7	Internal fixation of femoral neck fracture	2026-07-28 11:00:00	SYN-OR-1	Fictional procedure event for encounter 90; no actual operation or patient is represented.
26	91	6	Laparoscopic appendectomy	2026-05-20 11:00:00	SYN-OR-2	Fictional procedure event for encounter 91; no actual operation or patient is represented.
27	92	7	Internal fixation of femoral neck fracture	2026-06-24 11:00:00	SYN-OR-3	Fictional procedure event for encounter 92; no actual operation or patient is represented.
28	94	7	Internal fixation of femoral neck fracture	2026-05-01 11:00:00	SYN-OR-2	Fictional procedure event for encounter 94; no actual operation or patient is represented.
29	114	6	Laparoscopic appendectomy	2026-07-16 11:00:00	SYN-OR-1	Fictional procedure event for encounter 114; no actual operation or patient is represented.
30	116	6	Laparoscopic appendectomy	2026-06-12 11:00:00	SYN-OR-3	Fictional procedure event for encounter 116; no actual operation or patient is represented.
31	117	7	Internal fixation of femoral neck fracture	2026-07-17 11:00:00	SYN-OR-1	Fictional procedure event for encounter 117; no actual operation or patient is represented.
32	118	6	Laparoscopic appendectomy	2026-05-09 11:00:00	SYN-OR-2	Fictional procedure event for encounter 118; no actual operation or patient is represented.
33	119	7	Internal fixation of femoral neck fracture	2026-06-13 11:00:00	SYN-OR-3	Fictional procedure event for encounter 119; no actual operation or patient is represented.
\.


--
-- TOC entry 5170 (class 0 OID 16527)
-- Dependencies: 245
-- Data for Name: triage_assessments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.triage_assessments (triage_id, admission_id, nurse_id, assessment_datetime, priority_level, blood_pressure, heart_rate, respiratory_rate, body_temperature, oxygen_saturation, pain_level, reported_symptoms, known_allergies, current_medications) FROM stdin;
1	1	8	2026-05-01 09:06:00	High-Priority Emergency	158/96	108	24	36.6	93.0	8	Acute chest pain with suspected myocardial infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
2	2	8	2026-06-05 09:06:00	High-Priority Emergency	158/96	108	24	36.7	93.0	8	Acute chest pain with suspected myocardial infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
3	3	8	2026-07-01 09:06:00	High-Priority Emergency	158/96	108	24	36.8	93.0	8	Acute chest pain with suspected myocardial infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
4	4	8	2026-08-01 09:06:00	Non-Urgent	122/76	74	16	36.9	98.0	4	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
5	5	8	2026-09-01 09:06:00	Urgent	123/77	75	17	36.5	99.0	5	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
6	6	8	2026-05-02 09:06:00	High-Priority Emergency	158/96	108	24	36.6	93.0	8	Acute chest pain with suspected myocardial infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
7	7	8	2026-06-05 09:06:00	Urgent	125/79	77	19	36.7	98.0	1	Acute chest pain with suspected myocardial infarction	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
8	8	8	2026-07-10 09:06:00	High-Priority Emergency	158/96	108	24	36.8	93.0	8	Acute chest pain with suspected myocardial infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
9	9	8	2026-08-10 09:06:00	Urgent	127/81	79	17	36.9	97.0	3	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
10	10	8	2026-05-01 09:06:00	Non-Urgent	128/72	80	18	38.2	98.0	4	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
11	11	8	2026-06-01 09:06:00	Urgent	129/73	81	19	38.2	99.0	5	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
12	12	8	2026-07-01 09:06:00	Non-Urgent	130/74	82	16	38.2	97.0	0	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
13	13	8	2026-07-10 08:06:00	Urgent	131/75	83	17	36.8	98.0	1	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
14	14	8	2026-07-10 13:06:00	Non-Urgent	132/76	84	18	36.9	99.0	2	Acute abdominal pain with appendicitis	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
15	15	8	2026-08-01 09:06:00	Urgent	133/77	85	19	36.5	97.0	3	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
16	16	8	2026-08-05 09:06:00	Non-Urgent	134/78	86	16	36.6	98.0	4	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
17	17	8	2026-09-05 09:06:00	Urgent	135/79	87	17	36.7	99.0	5	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
18	18	8	2026-08-10 09:06:00	High-Priority Emergency	158/96	108	24	38.2	93.0	8	Severe infection with suspected septicemia	No known allergies reported	Medication reconciliation documented in the fictional assessment
19	19	8	2026-08-15 09:06:00	High-Priority Emergency	158/96	108	24	38.2	93.0	8	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
20	20	8	2026-04-01 09:06:00	Non-Urgent	118/72	72	16	36.5	99.0	2	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
21	21	8	2026-08-25 09:06:00	Urgent	119/73	73	17	36.6	97.0	3	Elevated blood pressure requiring assessment	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
22	22	8	2026-09-01 09:06:00	Non-Urgent	120/74	74	18	36.7	98.0	4	Diabetes review and glucose monitoring	No known allergies reported	Reported metformin use; reconciliation pending
23	23	8	2026-09-02 09:06:00	Urgent	121/75	75	19	38.2	99.0	5	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
24	24	8	2026-09-03 09:06:00	Non-Urgent	122/76	76	16	36.9	97.0	0	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
25	25	8	2026-09-04 09:06:00	Urgent	123/77	77	17	36.5	98.0	1	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
26	26	8	2026-09-05 09:06:00	Non-Urgent	124/78	78	18	36.6	99.0	2	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
27	27	8	2026-09-06 09:06:00	High-Priority Emergency	158/96	108	24	36.7	93.0	8	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
28	28	8	2026-09-07 09:06:00	High-Priority Emergency	158/96	108	24	36.8	93.0	8	Acute chest pain with suspected myocardial infarction	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
29	28	8	2026-09-07 09:12:00	High-Priority Emergency	158/96	108	24	36.8	93.0	8	Acute chest pain with suspected myocardial infarction	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
30	29	8	2026-03-01 09:06:00	Urgent	127/81	81	17	36.9	99.0	5	Neurological monitoring and rehabilitation after cerebral infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
31	30	8	2026-09-08 09:06:00	Non-Urgent	128/72	82	18	36.5	97.0	0	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
32	31	8	2026-07-01 09:06:00	Urgent	129/73	83	19	36.6	98.0	1	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
33	32	8	2026-06-05 09:06:00	Non-Urgent	130/74	84	16	36.7	99.0	2	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
34	33	8	2026-07-10 09:06:00	Urgent	131/75	85	17	36.8	97.0	3	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
35	34	8	2026-08-14 09:06:00	Non-Urgent	132/76	86	18	36.9	98.0	4	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
36	35	8	2026-05-02 09:06:00	Urgent	133/77	87	19	36.5	99.0	5	Acute abdominal pain with appendicitis	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
37	36	8	2026-06-06 09:06:00	Non-Urgent	134/78	70	16	36.6	97.0	0	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
38	37	8	2026-07-11 09:06:00	Urgent	135/79	71	17	36.7	98.0	1	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
39	38	8	2026-08-15 09:06:00	Non-Urgent	136/80	72	18	36.8	99.0	2	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
40	39	8	2026-05-03 09:06:00	Urgent	137/81	73	19	36.9	97.0	3	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
41	40	8	2026-06-07 09:06:00	Non-Urgent	118/72	74	16	36.5	98.0	4	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
42	41	8	2026-07-12 09:06:00	Urgent	119/73	75	17	36.6	99.0	5	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
43	42	8	2026-08-16 09:06:00	Non-Urgent	120/74	76	18	36.7	97.0	0	Neurological monitoring and rehabilitation after cerebral infarction	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
44	43	8	2026-05-04 09:06:00	Urgent	121/75	77	19	36.8	98.0	1	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
45	44	8	2026-06-08 09:06:00	Non-Urgent	122/76	78	16	36.9	99.0	2	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
46	45	8	2026-07-13 09:06:00	Urgent	123/77	79	17	36.5	97.0	3	Neurological monitoring and rehabilitation after cerebral infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
47	46	8	2026-05-05 09:06:00	Non-Urgent	124/78	80	18	36.6	98.0	4	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
48	47	8	2026-06-09 09:06:00	Urgent	125/79	81	19	36.7	99.0	5	Neurological monitoring and rehabilitation after cerebral infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
49	48	8	2026-07-14 09:06:00	Non-Urgent	126/80	82	16	36.8	97.0	0	Outpatient lipid assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
50	49	8	2026-05-06 09:06:00	Urgent	127/81	83	17	36.9	98.0	1	Neurological monitoring and rehabilitation after cerebral infarction	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
51	50	8	2026-06-10 09:06:00	Non-Urgent	128/72	84	18	36.5	99.0	2	Outpatient lipid assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
52	51	8	2026-07-15 09:06:00	Urgent	129/73	85	19	36.6	97.0	3	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
53	52	8	2026-05-07 09:06:00	Non-Urgent	130/74	86	16	36.7	98.0	4	Outpatient lipid assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
54	53	8	2026-06-11 09:06:00	Urgent	131/75	87	17	36.8	99.0	5	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
55	54	8	2026-07-16 09:06:00	Non-Urgent	132/76	70	18	36.9	97.0	0	Diabetes review and glucose monitoring	No known allergies reported	Reported metformin use; reconciliation pending
56	55	8	2026-05-08 09:06:00	Urgent	133/77	71	19	36.5	98.0	1	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
57	56	8	2026-06-12 09:06:00	Non-Urgent	134/78	72	16	36.6	99.0	2	Diabetes review and glucose monitoring	Reported penicillin allergy	Reported metformin use; reconciliation pending
58	57	8	2026-07-17 09:06:00	Urgent	135/79	73	17	38.2	97.0	3	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
59	58	8	2026-05-09 09:06:00	Non-Urgent	136/80	74	18	36.8	98.0	4	Diabetes review and glucose monitoring	No known allergies reported	Reported metformin use; reconciliation pending
60	59	8	2026-06-13 09:06:00	Urgent	137/81	75	19	38.2	99.0	5	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
61	60	8	2026-07-18 09:06:00	Non-Urgent	118/72	76	16	36.5	97.0	0	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
62	61	8	2026-05-10 09:06:00	Urgent	119/73	77	17	38.2	98.0	1	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
63	62	8	2026-06-14 09:06:00	Non-Urgent	120/74	78	18	36.7	99.0	2	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
64	63	8	2026-07-19 09:06:00	Urgent	121/75	79	19	36.8	97.0	3	Hip pain after a fall with femoral neck fracture	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
65	64	8	2026-05-11 09:06:00	Non-Urgent	122/76	80	16	36.9	98.0	4	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
66	65	8	2026-06-15 09:06:00	Urgent	123/77	81	17	36.5	99.0	5	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
67	66	8	2026-07-20 09:06:00	Non-Urgent	124/78	82	18	36.6	97.0	0	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
68	67	8	2026-05-12 09:06:00	Urgent	125/79	83	19	36.7	98.0	1	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
69	68	8	2026-06-16 09:06:00	Non-Urgent	126/80	84	16	36.8	99.0	2	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
70	69	8	2026-07-21 09:06:00	Urgent	127/81	85	17	36.9	97.0	3	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
71	70	8	2026-05-13 09:06:00	Non-Urgent	128/72	86	18	36.5	98.0	4	Breathlessness and fluid overload	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
72	71	8	2026-06-17 09:06:00	Urgent	129/73	87	19	36.6	99.0	5	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
73	72	8	2026-07-22 09:06:00	Non-Urgent	130/74	70	16	36.7	97.0	0	Neurological monitoring and rehabilitation after cerebral infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
74	73	8	2026-05-14 09:06:00	Urgent	131/75	71	17	36.8	98.0	1	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
75	74	8	2026-06-18 09:06:00	Non-Urgent	132/76	72	18	36.9	99.0	2	Neurological monitoring and rehabilitation after cerebral infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
76	75	8	2026-07-23 09:06:00	Urgent	133/77	73	19	36.5	97.0	3	Outpatient lipid assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
77	76	8	2026-05-15 09:06:00	Non-Urgent	134/78	74	16	36.6	98.0	4	Neurological monitoring and rehabilitation after cerebral infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
78	77	8	2026-06-19 09:06:00	Urgent	135/79	75	17	36.7	99.0	5	Outpatient lipid assessment	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
79	78	8	2026-07-24 09:06:00	Non-Urgent	136/80	76	18	36.8	97.0	0	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
80	79	8	2026-05-16 09:06:00	Urgent	137/81	77	19	36.9	98.0	1	Outpatient lipid assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
81	80	8	2026-06-20 09:06:00	Non-Urgent	118/72	78	16	36.5	99.0	2	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
82	81	8	2026-07-25 09:06:00	Urgent	119/73	79	17	36.6	97.0	3	Diabetes review and glucose monitoring	No known allergies reported	Reported metformin use; reconciliation pending
83	82	8	2026-05-17 09:06:00	Non-Urgent	120/74	80	18	36.7	98.0	4	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
84	83	8	2026-06-21 09:06:00	Urgent	121/75	81	19	36.8	99.0	5	Diabetes review and glucose monitoring	No known allergies reported	Reported metformin use; reconciliation pending
85	84	8	2026-07-26 09:06:00	Non-Urgent	122/76	82	16	38.2	97.0	0	Fever and cough with pneumonia	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
86	85	8	2026-05-18 09:06:00	Urgent	123/77	83	17	36.5	98.0	1	Diabetes review and glucose monitoring	No known allergies reported	Reported metformin use; reconciliation pending
87	86	8	2026-06-22 09:06:00	Non-Urgent	124/78	84	18	38.2	99.0	2	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
88	87	8	2026-07-27 09:06:00	Urgent	125/79	85	19	36.7	97.0	3	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
89	88	8	2026-05-19 09:06:00	Non-Urgent	126/80	86	16	38.2	98.0	4	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
90	89	8	2026-06-23 09:06:00	Urgent	127/81	87	17	36.9	99.0	5	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
91	90	8	2026-07-28 09:06:00	Non-Urgent	128/72	70	18	36.5	97.0	0	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
92	91	8	2026-05-20 09:06:00	Urgent	129/73	71	19	36.6	98.0	1	Acute abdominal pain with appendicitis	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
93	92	8	2026-06-24 09:06:00	Non-Urgent	130/74	72	16	36.7	99.0	2	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
94	93	8	2026-07-29 09:06:00	Urgent	131/75	73	17	36.8	97.0	3	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
95	94	8	2026-05-01 09:06:00	Non-Urgent	132/76	74	18	36.9	98.0	4	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
96	95	8	2026-06-05 09:06:00	Urgent	133/77	75	19	36.5	99.0	5	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
97	96	8	2026-07-10 09:06:00	Non-Urgent	134/78	76	16	36.6	97.0	0	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
98	97	8	2026-05-02 09:06:00	Urgent	135/79	77	17	36.7	98.0	1	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
99	98	8	2026-06-06 09:06:00	Non-Urgent	136/80	78	18	36.8	99.0	2	Chest pain requiring diagnostic assessment	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
100	99	8	2026-07-11 09:06:00	Urgent	137/81	79	19	36.9	97.0	3	Neurological monitoring and rehabilitation after cerebral infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
101	100	8	2026-05-03 09:06:00	Non-Urgent	118/72	80	16	36.5	98.0	4	Chest pain requiring diagnostic assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
102	101	8	2026-06-07 09:06:00	Urgent	119/73	81	17	36.6	99.0	5	Neurological monitoring and rehabilitation after cerebral infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
103	102	8	2026-07-12 09:06:00	Non-Urgent	120/74	82	18	36.7	97.0	0	Outpatient lipid assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
104	103	8	2026-05-04 09:06:00	Urgent	121/75	83	19	36.8	98.0	1	Neurological monitoring and rehabilitation after cerebral infarction	No known allergies reported	Medication reconciliation documented in the fictional assessment
105	104	8	2026-06-08 09:06:00	Non-Urgent	122/76	84	16	36.9	99.0	2	Outpatient lipid assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
106	105	8	2026-07-13 09:06:00	Urgent	123/77	85	17	36.5	97.0	3	Elevated blood pressure requiring assessment	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
107	106	8	2026-05-05 09:06:00	Non-Urgent	124/78	86	18	36.6	98.0	4	Outpatient lipid assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
108	107	8	2026-06-09 09:06:00	Urgent	125/79	87	19	36.7	99.0	5	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
109	108	8	2026-07-14 09:06:00	Non-Urgent	126/80	70	16	36.8	97.0	0	Diabetes review and glucose monitoring	No known allergies reported	Reported metformin use; reconciliation pending
110	109	8	2026-05-06 09:06:00	Urgent	127/81	71	17	36.9	98.0	1	Elevated blood pressure requiring assessment	No known allergies reported	Medication reconciliation documented in the fictional assessment
111	110	8	2026-06-10 09:06:00	Non-Urgent	128/72	72	18	36.5	99.0	2	Diabetes review and glucose monitoring	No known allergies reported	Reported metformin use; reconciliation pending
112	111	8	2026-07-15 09:06:00	Urgent	129/73	73	19	38.2	97.0	3	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
113	112	8	2026-05-07 09:06:00	Non-Urgent	130/74	74	16	36.7	98.0	4	Diabetes review and glucose monitoring	Reported penicillin allergy	Reported metformin use; reconciliation pending
114	113	8	2026-06-11 09:06:00	Urgent	131/75	75	17	38.2	99.0	5	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
115	114	8	2026-07-16 09:06:00	Non-Urgent	132/76	76	18	36.9	97.0	0	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
116	115	8	2026-05-08 09:06:00	Urgent	133/77	77	19	38.2	98.0	1	Fever and cough with pneumonia	No known allergies reported	Medication reconciliation documented in the fictional assessment
117	116	8	2026-06-12 09:06:00	Non-Urgent	134/78	78	16	36.6	99.0	2	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
118	117	8	2026-07-17 09:06:00	Urgent	135/79	79	17	36.7	97.0	3	Hip pain after a fall with femoral neck fracture	No known allergies reported	Medication reconciliation documented in the fictional assessment
119	118	8	2026-05-09 09:06:00	Non-Urgent	136/80	80	18	36.8	98.0	4	Acute abdominal pain with appendicitis	No known allergies reported	Medication reconciliation documented in the fictional assessment
120	119	8	2026-06-13 09:06:00	Urgent	137/81	81	19	36.9	99.0	5	Hip pain after a fall with femoral neck fracture	Reported penicillin allergy	Medication reconciliation documented in the fictional assessment
121	120	8	2026-07-18 09:06:00	Non-Urgent	118/72	82	16	36.5	97.0	0	Breathlessness and fluid overload	No known allergies reported	Medication reconciliation documented in the fictional assessment
\.


--
-- TOC entry 5172 (class 0 OID 16539)
-- Dependencies: 247
-- Data for Name: unit_stays; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.unit_stays (unit_stay_id, admission_id, unit_id, responsible_physician_id, ward_and_room, bed_number, entry_datetime, exit_datetime, reason_for_transfer) FROM stdin;
1	1	1	1	SYN-U1-R2	B2	2026-05-01 09:00:00	2026-05-01 13:00:00	Initial placement
2	1	2	1	SYN-U2-R2	B2	2026-05-01 13:00:00	2026-05-09 13:00:00	Clinical monitoring needs changed
3	1	3	1	SYN-U3-R2	B2	2026-05-09 13:00:00	2026-05-11 13:00:00	Clinical monitoring needs changed
4	1	6	1	SYN-U6-R2	B2	2026-05-11 13:00:00	2026-05-31 09:00:00	Condition permits general ward care
5	2	1	1	SYN-U1-R3	B3	2026-06-05 09:00:00	2026-06-05 11:00:00	Initial placement
6	2	2	1	SYN-U2-R3	B3	2026-06-05 11:00:00	2026-06-12 11:00:00	Clinical monitoring needs changed
7	2	6	1	SYN-U6-R3	B3	2026-06-12 11:00:00	2026-06-15 09:00:00	Condition permits general ward care
8	3	1	1	SYN-U1-R4	B4	2026-07-01 09:00:00	2026-07-01 11:00:00	Initial placement
9	3	3	1	SYN-U3-R4	B4	2026-07-01 11:00:00	2026-07-08 12:00:00	Clinical monitoring needs changed
10	3	6	1	SYN-U6-R4	B4	2026-07-08 12:00:00	2026-07-11 09:00:00	Condition permits general ward care
11	4	6	1	SYN-U6-R5	B1	2026-08-01 09:00:00	2026-08-03 09:00:00	Initial placement
12	5	6	2	SYN-U6-R6	B2	2026-09-01 09:00:00	2026-09-01 21:00:00	Initial placement
13	6	1	1	SYN-U1-R7	B3	2026-05-02 09:00:00	2026-05-02 13:00:00	Initial placement
14	6	2	1	SYN-U2-R7	B3	2026-05-02 13:00:00	2026-05-04 13:00:00	Clinical monitoring needs changed
15	6	3	1	SYN-U3-R7	B3	2026-05-04 13:00:00	2026-05-12 13:00:00	Clinical monitoring needs changed
16	6	6	1	SYN-U6-R7	B3	2026-05-12 13:00:00	2026-06-01 09:00:00	Condition permits general ward care
17	7	2	1	SYN-U2-R8	B4	2026-06-05 09:00:00	2026-06-06 09:00:00	Initial placement
18	7	6	1	SYN-U6-R8	B4	2026-06-06 09:00:00	2026-06-07 09:00:00	Condition permits general ward care
19	7	7	1	SYN-U7-R8	B4	2026-06-07 09:00:00	2026-06-09 09:00:00	Clinical monitoring needs changed
20	7	6	1	SYN-U6-R8	B4	2026-06-09 09:00:00	2026-06-10 09:00:00	Condition permits general ward care
21	8	1	1	SYN-U1-R9	B1	2026-07-10 09:00:00	2026-07-10 11:00:00	Initial placement
22	8	2	1	SYN-U2-R9	B1	2026-07-10 11:00:00	2026-07-12 09:00:00	Clinical monitoring needs changed
23	8	6	1	SYN-U6-R9	B1	2026-07-12 09:00:00	2026-07-13 09:00:00	Condition permits general ward care
24	9	6	2	SYN-U6-R10	B2	2026-08-10 09:00:00	2026-08-13 09:00:00	Initial placement
25	10	4	4	SYN-U4-R1	B3	2026-05-01 09:00:00	2026-05-03 09:00:00	Initial placement
26	10	5	4	SYN-U5-R1	B3	2026-05-03 09:00:00	2026-05-06 09:00:00	Clinical monitoring needs changed
27	10	6	4	SYN-U6-R1	B3	2026-05-06 09:00:00	2026-05-08 09:00:00	Condition permits general ward care
28	11	5	4	SYN-U5-R2	B4	2026-06-01 09:00:00	2026-06-09 09:00:00	Initial placement
29	11	6	4	SYN-U6-R2	B4	2026-06-09 09:00:00	2026-06-11 09:00:00	Condition permits general ward care
30	12	1	4	SYN-U1-R3	B1	2026-07-01 09:00:00	2026-07-01 11:00:00	Initial placement
31	12	4	4	SYN-U4-R3	B1	2026-07-01 11:00:00	2026-07-05 11:00:00	Clinical monitoring needs changed
32	12	6	4	SYN-U6-R3	B1	2026-07-05 11:00:00	2026-07-07 09:00:00	Condition permits general ward care
33	16	1	2	SYN-U1-R7	B1	2026-08-05 09:00:00	2026-08-05 11:00:00	Initial placement
34	16	8	2	SYN-U8-R7	B1	2026-08-05 11:00:00	2026-08-06 21:00:00	Clinical monitoring needs changed
35	16	6	2	SYN-U6-R7	B1	2026-08-06 21:00:00	2026-08-08 09:00:00	Condition permits general ward care
36	17	1	2	SYN-U1-R8	B2	2026-09-05 09:00:00	2026-09-06 01:00:00	Initial placement
37	17	6	2	SYN-U6-R8	B2	2026-09-06 01:00:00	2026-09-07 09:00:00	Condition permits general ward care
38	18	1	2	SYN-U1-R9	B3	2026-08-10 09:00:00	2026-08-10 11:00:00	Initial placement
39	18	2	2	SYN-U2-R9	B3	2026-08-10 11:00:00	2026-08-13 09:00:00	Clinical monitoring needs changed
40	19	1	4	SYN-U1-R10	B4	2026-08-15 09:00:00	2026-08-15 11:00:00	Initial placement
41	19	2	4	SYN-U2-R10	B4	2026-08-15 11:00:00	2026-08-19 09:00:00	Clinical monitoring needs changed
42	20	6	2	SYN-U6-R1	B1	2026-04-01 09:00:00	2026-04-03 09:00:00	Initial placement
43	21	6	2	SYN-U6-R2	B2	2026-08-25 09:00:00	2026-08-26 09:00:00	Initial placement
44	22	6	2	SYN-U6-R3	B3	2026-09-01 09:00:00	2026-09-03 09:00:00	Initial placement
45	23	6	4	SYN-U6-R4	B4	2026-09-02 09:00:00	2026-09-05 09:00:00	Initial placement
46	24	2	1	SYN-U2-R5	B1	2026-09-03 09:00:00	2026-09-05 09:00:00	Initial placement
47	24	6	1	SYN-U6-R5	B1	2026-09-05 09:00:00	2026-09-06 09:00:00	Condition permits general ward care
48	25	2	1	SYN-U2-R6	B2	2026-09-04 09:00:00	2026-09-05 09:00:00	Initial placement
49	27	1	1	SYN-U1-R8	B4	2026-09-06 09:00:00	2026-09-06 11:00:00	Initial placement
50	27	2	1	SYN-U2-R8	B4	2026-09-06 11:00:00	\N	Clinical monitoring needs changed
51	28	1	1	SYN-U1-R9	B1	2026-09-07 09:00:00	2026-09-07 13:00:00	Initial placement
52	28	2	1	SYN-U2-R9	B1	2026-09-07 13:00:00	2026-09-08 13:00:00	Clinical monitoring needs changed
53	28	3	1	SYN-U3-R9	B1	2026-09-08 13:00:00	2026-09-09 13:00:00	Clinical monitoring needs changed
54	28	6	1	SYN-U6-R9	B1	2026-09-09 13:00:00	2026-09-11 09:00:00	Condition permits general ward care
55	29	6	2	SYN-U6-R10	B2	2026-03-01 09:00:00	\N	Initial placement
56	30	6	2	SYN-U6-R1	B3	2026-09-08 09:00:00	2026-09-08 21:00:00	Initial placement
57	31	3	1	SYN-U3-R2	B4	2026-07-01 09:00:00	2026-07-03 09:00:00	Initial placement
58	32	6	2	SYN-U6-R3	B1	2026-06-05 09:00:00	2026-06-06 03:00:00	Initial placement
59	33	1	2	SYN-U1-R4	B2	2026-07-10 09:00:00	2026-07-10 10:30:00	Initial placement
60	33	6	2	SYN-U6-R4	B2	2026-07-10 10:30:00	2026-07-11 15:00:00	Condition permits general ward care
61	34	1	1	SYN-U1-R5	B3	2026-08-14 09:00:00	2026-08-14 10:30:00	Initial placement
62	34	6	1	SYN-U6-R5	B3	2026-08-14 10:30:00	2026-08-16 03:00:00	Condition permits general ward care
63	35	6	2	SYN-U6-R6	B4	2026-05-02 09:00:00	2026-05-03 03:00:00	Initial placement
64	36	1	2	SYN-U1-R7	B1	2026-06-06 09:00:00	2026-06-06 10:30:00	Initial placement
65	36	6	2	SYN-U6-R7	B1	2026-06-06 10:30:00	2026-06-07 15:00:00	Condition permits general ward care
66	37	1	1	SYN-U1-R8	B2	2026-07-11 09:00:00	2026-07-11 10:30:00	Initial placement
67	37	6	1	SYN-U6-R8	B2	2026-07-11 10:30:00	2026-07-13 03:00:00	Condition permits general ward care
68	39	1	2	SYN-U1-R10	B4	2026-05-03 09:00:00	2026-05-03 10:30:00	Initial placement
69	39	6	2	SYN-U6-R10	B4	2026-05-03 10:30:00	2026-05-04 15:00:00	Condition permits general ward care
70	40	1	1	SYN-U1-R1	B1	2026-06-07 09:00:00	2026-06-07 10:30:00	Initial placement
71	40	6	1	SYN-U6-R1	B1	2026-06-07 10:30:00	2026-06-09 03:00:00	Condition permits general ward care
72	42	6	2	SYN-U6-R3	B3	2026-08-16 09:00:00	2026-08-16 15:00:00	Initial placement
73	43	1	1	SYN-U1-R4	B4	2026-05-04 09:00:00	2026-05-04 10:30:00	Initial placement
74	43	6	1	SYN-U6-R4	B4	2026-05-04 10:30:00	2026-05-06 03:00:00	Condition permits general ward care
75	45	6	2	SYN-U6-R6	B2	2026-07-13 09:00:00	2026-07-13 15:00:00	Initial placement
76	47	6	2	SYN-U6-R8	B4	2026-06-09 09:00:00	2026-06-09 15:00:00	Initial placement
77	48	1	2	SYN-U1-R9	B1	2026-07-14 09:00:00	2026-07-14 10:30:00	Initial placement
78	48	6	2	SYN-U6-R9	B1	2026-07-14 10:30:00	2026-07-15 03:00:00	Condition permits general ward care
79	49	6	2	SYN-U6-R10	B2	2026-05-06 09:00:00	2026-05-06 15:00:00	Initial placement
80	50	1	2	SYN-U1-R1	B3	2026-06-10 09:00:00	2026-06-10 10:30:00	Initial placement
81	50	6	2	SYN-U6-R1	B3	2026-06-10 10:30:00	2026-06-11 03:00:00	Condition permits general ward care
82	51	1	2	SYN-U1-R2	B4	2026-07-15 09:00:00	2026-07-15 10:30:00	Initial placement
83	51	6	2	SYN-U6-R2	B4	2026-07-15 10:30:00	2026-07-16 15:00:00	Condition permits general ward care
84	52	1	2	SYN-U1-R3	B1	2026-05-07 09:00:00	2026-05-07 10:30:00	Initial placement
85	52	6	2	SYN-U6-R3	B1	2026-05-07 10:30:00	2026-05-08 03:00:00	Condition permits general ward care
86	53	1	2	SYN-U1-R4	B2	2026-06-11 09:00:00	2026-06-11 10:30:00	Initial placement
87	53	6	2	SYN-U6-R4	B2	2026-06-11 10:30:00	2026-06-12 15:00:00	Condition permits general ward care
88	55	1	2	SYN-U1-R6	B4	2026-05-08 09:00:00	2026-05-08 10:30:00	Initial placement
89	55	6	2	SYN-U6-R6	B4	2026-05-08 10:30:00	2026-05-09 15:00:00	Condition permits general ward care
90	57	6	4	SYN-U6-R8	B2	2026-07-17 09:00:00	2026-07-19 15:00:00	Initial placement
91	59	6	4	SYN-U6-R10	B4	2026-06-13 09:00:00	2026-06-15 15:00:00	Initial placement
92	60	1	2	SYN-U1-R1	B1	2026-07-18 09:00:00	2026-07-18 10:30:00	Initial placement
93	60	6	2	SYN-U6-R1	B1	2026-07-18 10:30:00	2026-07-18 15:00:00	Condition permits general ward care
94	61	6	4	SYN-U6-R2	B2	2026-05-10 09:00:00	2026-05-12 15:00:00	Initial placement
95	62	1	2	SYN-U1-R3	B3	2026-06-14 09:00:00	2026-06-14 10:30:00	Initial placement
96	62	6	2	SYN-U6-R3	B3	2026-06-14 10:30:00	2026-06-14 15:00:00	Condition permits general ward care
97	63	1	2	SYN-U1-R4	B4	2026-07-19 09:00:00	2026-07-19 10:30:00	Initial placement
98	63	6	2	SYN-U6-R4	B4	2026-07-19 10:30:00	2026-07-20 03:00:00	Condition permits general ward care
99	64	1	2	SYN-U1-R5	B1	2026-05-11 09:00:00	2026-05-11 10:30:00	Initial placement
100	64	6	2	SYN-U6-R5	B1	2026-05-11 10:30:00	2026-05-11 15:00:00	Condition permits general ward care
101	65	1	2	SYN-U1-R6	B2	2026-06-15 09:00:00	2026-06-15 10:30:00	Initial placement
102	65	6	2	SYN-U6-R6	B2	2026-06-15 10:30:00	2026-06-16 03:00:00	Condition permits general ward care
103	67	1	2	SYN-U1-R8	B4	2026-05-12 09:00:00	2026-05-12 10:30:00	Initial placement
104	67	6	2	SYN-U6-R8	B4	2026-05-12 10:30:00	2026-05-13 03:00:00	Condition permits general ward care
105	69	6	1	SYN-U6-R10	B2	2026-07-21 09:00:00	2026-07-23 03:00:00	Initial placement
106	71	6	1	SYN-U6-R2	B4	2026-06-17 09:00:00	2026-06-19 03:00:00	Initial placement
107	72	1	2	SYN-U1-R3	B1	2026-07-22 09:00:00	2026-07-22 10:30:00	Initial placement
108	72	6	2	SYN-U6-R3	B1	2026-07-22 10:30:00	2026-07-24 15:00:00	Condition permits general ward care
109	73	6	1	SYN-U6-R4	B2	2026-05-14 09:00:00	2026-05-16 03:00:00	Initial placement
110	74	1	2	SYN-U1-R5	B3	2026-06-18 09:00:00	2026-06-18 10:30:00	Initial placement
111	74	6	2	SYN-U6-R5	B3	2026-06-18 10:30:00	2026-06-20 15:00:00	Condition permits general ward care
112	75	1	2	SYN-U1-R6	B4	2026-07-23 09:00:00	2026-07-23 10:30:00	Initial placement
113	75	6	2	SYN-U6-R6	B4	2026-07-23 10:30:00	2026-07-23 15:00:00	Condition permits general ward care
114	76	1	2	SYN-U1-R7	B1	2026-05-15 09:00:00	2026-05-15 10:30:00	Initial placement
115	76	6	2	SYN-U6-R7	B1	2026-05-15 10:30:00	2026-05-17 15:00:00	Condition permits general ward care
116	77	1	2	SYN-U1-R8	B2	2026-06-19 09:00:00	2026-06-19 10:30:00	Initial placement
117	77	6	2	SYN-U6-R8	B2	2026-06-19 10:30:00	2026-06-19 15:00:00	Condition permits general ward care
118	79	1	2	SYN-U1-R10	B4	2026-05-16 09:00:00	2026-05-16 10:30:00	Initial placement
119	79	6	2	SYN-U6-R10	B4	2026-05-16 10:30:00	2026-05-16 15:00:00	Condition permits general ward care
120	81	6	2	SYN-U6-R2	B2	2026-07-25 09:00:00	2026-07-26 15:00:00	Initial placement
121	83	6	2	SYN-U6-R4	B4	2026-06-21 09:00:00	2026-06-22 15:00:00	Initial placement
122	84	1	4	SYN-U1-R5	B1	2026-07-26 09:00:00	2026-07-26 10:30:00	Initial placement
123	84	6	4	SYN-U6-R5	B1	2026-07-26 10:30:00	2026-07-28 03:00:00	Condition permits general ward care
124	85	6	2	SYN-U6-R6	B2	2026-05-18 09:00:00	2026-05-19 15:00:00	Initial placement
125	86	1	4	SYN-U1-R7	B3	2026-06-22 09:00:00	2026-06-22 10:30:00	Initial placement
126	86	6	4	SYN-U6-R7	B3	2026-06-22 10:30:00	2026-06-24 03:00:00	Condition permits general ward care
127	87	1	2	SYN-U1-R8	B4	2026-07-27 09:00:00	2026-07-27 10:30:00	Initial placement
128	87	6	2	SYN-U6-R8	B4	2026-07-27 10:30:00	2026-07-29 15:00:00	Condition permits general ward care
129	88	1	4	SYN-U1-R9	B1	2026-05-19 09:00:00	2026-05-19 10:30:00	Initial placement
130	88	6	4	SYN-U6-R9	B1	2026-05-19 10:30:00	2026-05-21 03:00:00	Condition permits general ward care
131	89	1	2	SYN-U1-R10	B2	2026-06-23 09:00:00	2026-06-23 10:30:00	Initial placement
132	89	6	2	SYN-U6-R10	B2	2026-06-23 10:30:00	2026-06-25 15:00:00	Condition permits general ward care
133	91	1	2	SYN-U1-R2	B4	2026-05-20 09:00:00	2026-05-20 10:30:00	Initial placement
134	91	6	2	SYN-U6-R2	B4	2026-05-20 10:30:00	2026-05-22 15:00:00	Condition permits general ward care
135	93	6	1	SYN-U6-R4	B2	2026-07-29 09:00:00	2026-07-30 03:00:00	Initial placement
136	95	6	1	SYN-U6-R6	B4	2026-06-05 09:00:00	2026-06-06 03:00:00	Initial placement
137	96	1	1	SYN-U1-R7	B1	2026-07-10 09:00:00	2026-07-10 10:30:00	Initial placement
138	96	6	1	SYN-U6-R7	B1	2026-07-10 10:30:00	2026-07-11 15:00:00	Condition permits general ward care
139	97	6	1	SYN-U6-R8	B2	2026-05-02 09:00:00	2026-05-03 03:00:00	Initial placement
140	98	1	1	SYN-U1-R9	B3	2026-06-06 09:00:00	2026-06-06 10:30:00	Initial placement
141	98	6	1	SYN-U6-R9	B3	2026-06-06 10:30:00	2026-06-07 15:00:00	Condition permits general ward care
142	99	1	2	SYN-U1-R10	B4	2026-07-11 09:00:00	2026-07-11 10:30:00	Initial placement
143	99	6	2	SYN-U6-R10	B4	2026-07-11 10:30:00	2026-07-13 03:00:00	Condition permits general ward care
144	100	1	1	SYN-U1-R1	B1	2026-05-03 09:00:00	2026-05-03 10:30:00	Initial placement
145	100	6	1	SYN-U6-R1	B1	2026-05-03 10:30:00	2026-05-04 15:00:00	Condition permits general ward care
146	101	1	2	SYN-U1-R2	B2	2026-06-07 09:00:00	2026-06-07 10:30:00	Initial placement
147	101	6	2	SYN-U6-R2	B2	2026-06-07 10:30:00	2026-06-09 03:00:00	Condition permits general ward care
148	103	1	2	SYN-U1-R4	B4	2026-05-04 09:00:00	2026-05-04 10:30:00	Initial placement
149	103	6	2	SYN-U6-R4	B4	2026-05-04 10:30:00	2026-05-06 03:00:00	Condition permits general ward care
150	105	6	2	SYN-U6-R6	B2	2026-07-13 09:00:00	2026-07-13 15:00:00	Initial placement
151	107	6	2	SYN-U6-R8	B4	2026-06-09 09:00:00	2026-06-09 15:00:00	Initial placement
152	108	1	2	SYN-U1-R9	B1	2026-07-14 09:00:00	2026-07-14 10:30:00	Initial placement
153	108	6	2	SYN-U6-R9	B1	2026-07-14 10:30:00	2026-07-15 03:00:00	Condition permits general ward care
154	109	6	2	SYN-U6-R10	B2	2026-05-06 09:00:00	2026-05-06 15:00:00	Initial placement
155	110	1	2	SYN-U1-R1	B3	2026-06-10 09:00:00	2026-06-10 10:30:00	Initial placement
156	110	6	2	SYN-U6-R1	B3	2026-06-10 10:30:00	2026-06-11 03:00:00	Condition permits general ward care
157	111	1	4	SYN-U1-R2	B4	2026-07-15 09:00:00	2026-07-15 10:30:00	Initial placement
158	111	6	4	SYN-U6-R2	B4	2026-07-15 10:30:00	2026-07-16 15:00:00	Condition permits general ward care
159	112	1	2	SYN-U1-R3	B1	2026-05-07 09:00:00	2026-05-07 10:30:00	Initial placement
160	112	6	2	SYN-U6-R3	B1	2026-05-07 10:30:00	2026-05-08 03:00:00	Condition permits general ward care
161	113	1	4	SYN-U1-R4	B2	2026-06-11 09:00:00	2026-06-11 10:30:00	Initial placement
162	113	6	4	SYN-U6-R4	B2	2026-06-11 10:30:00	2026-06-12 15:00:00	Condition permits general ward care
163	115	1	4	SYN-U1-R6	B4	2026-05-08 09:00:00	2026-05-08 10:30:00	Initial placement
164	115	6	4	SYN-U6-R6	B4	2026-05-08 10:30:00	2026-05-09 15:00:00	Condition permits general ward care
165	117	6	2	SYN-U6-R8	B2	2026-07-17 09:00:00	2026-07-19 15:00:00	Initial placement
166	119	6	2	SYN-U6-R10	B4	2026-06-13 09:00:00	2026-06-15 15:00:00	Initial placement
167	120	1	1	SYN-U1-R1	B1	2026-07-18 09:00:00	2026-07-18 10:30:00	Initial placement
168	120	6	1	SYN-U6-R1	B1	2026-07-18 10:30:00	2026-07-18 15:00:00	Condition permits general ward care
\.


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 220
-- Name: admissions_admission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admissions_admission_id_seq', 1, false);


--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 222
-- Name: clinical_notes_note_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clinical_notes_note_id_seq', 1, false);


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 224
-- Name: diagnoses_diagnosis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnoses_diagnosis_id_seq', 1, false);


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 226
-- Name: diagnostic_examinations_examination_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnostic_examinations_examination_id_seq', 1, false);


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 228
-- Name: diagnostic_orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnostic_orders_order_id_seq', 1, false);


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 230
-- Name: discharge_records_discharge_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.discharge_records_discharge_id_seq', 1, false);


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 232
-- Name: healthcare_professionals_professional_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.healthcare_professionals_professional_id_seq', 1, false);


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 234
-- Name: hospital_units_unit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_units_unit_id_seq', 1, false);


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 237
-- Name: patients_patient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patients_patient_id_seq', 1, false);


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 240
-- Name: radiology_examinations_radiology_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.radiology_examinations_radiology_id_seq', 1, false);


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 242
-- Name: radiology_reports_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.radiology_reports_report_id_seq', 1, false);


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 244
-- Name: surgical_procedures_procedure_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.surgical_procedures_procedure_id_seq', 1, false);


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 246
-- Name: triage_assessments_triage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.triage_assessments_triage_id_seq', 1, false);


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 248
-- Name: unit_stays_unit_stay_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unit_stays_unit_stay_id_seq', 1, false);


-- Completed on 2026-11-09 16:58:26

--
-- PostgreSQL database dump complete
--

\unrestrict K2HAUxYGZmX5Df9G2n2c70LYphTaFCtm4N75oh4d8ZoIu0K0eiyz8UPdSgMxx4a

