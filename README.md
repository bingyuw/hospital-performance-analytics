# HOSPITAL PERFORMANCE ANALYTICS: PATIENT ENCOUNTERS, BEHAVIOR, AND COST DRIVERS

Built a three-page Power BI dashboard backed by MySQL views to analyze 27.9K hospital encounters from 2011 to 2022 — covering encounter trends, patient readmissions, and cost drivers.

**Tools:** Power BI, MySQL, Window Functions, CTEs, TIMESTAMPDIFF

---

## 📋 Table of Contents

- [🎯 Project Background](#-project-background)
- [🗃️ Data & Tools](#%EF%B8%8F-data—tools)
- [💻 SQL & Analysis](#-sql—analysis)
- [📊 Dashboards](#-dashboards)
- [💡 Findings](#-findings)
- [✅ Business Impact](#-business-recommendations)
- [⚙️ Reflections](#%EF%B8%8F-reflections)
- [🎬 Video Walkthrough](#-video-walkthrough)
- [📁 Project Files & Resources](#-project-files—resources)

---

## 🎯 Project Background

Hospitals collect massive amounts of encounter and billing data, but raw data does not improve care or reduce costs on its own. This project was built to answer a practical question: how can a hospital use its own encounter, patient, and cost data to understand where resources are going, which patients are most at risk of returning, and where coverage gaps are creating financial strain?

The analysis covers 27.9K encounters across six encounter classes — ambulatory, outpatient, urgent care, wellness, emergency, and inpatient — from 2011 to 2022.

*Note: The dataset ends mid-2022, so the final year shows lower totals than prior years. This is a data cutoff, not a real decline — worth keeping in mind when reading trends that extend into 2022.*

---

## 🗃️ Data & Tools

### Tables Used

| Table | Description | Key Fields |
|-------|-------------|------------|
| **encounters** | Visit records (27.9K) — the center of the analysis | start/stop times, encounter class, payer, claim cost |
| **procedures** | Procedure codes and costs | codes, descriptions, base costs, linked encounters |
| **patients** | Demographics | birth date, gender, race, location |
| **payers** | Payer names | payer names mapped to encounter payer IDs |

All other tables join back to encounters either directly or through patient ID.

### Tools & Techniques

| Category | Details |
|----------|---------|
| **Platform** | Power BI |
| **Database** | MySQL |
| **SQL Techniques** | Window functions (LAG, DENSE_RANK, SUM OVER), CTEs, TIMESTAMPDIFF, multi-table joins |
| **Modeling** | 11 MySQL views + shared year dimension; DAX kept minimal |

**Dataset & Project Framework:** Maven Analytics - "Hospital Analytics"
**Original Source:** 🔗 [Maven Analytics Guided Project](https://app.mavenanalytics.io/guided-projects/4a8bf6e9-eefc-45cb-bab5-9d731ed017d5)

*Note: The original dataset and project structure are the intellectual property of Maven Analytics. This repository contains my original SQL analysis, dashboard design, and documentation built upon their foundational project framework.*

---

## 💻 SQL & Analysis

I did the analytical work in MySQL before building any visuals. There were three reasons: SQL gave me full control over how each metric was defined, views created a clean layer between raw data and Power BI, and the logic stayed auditable and reproducible.

### Views by Objective

| Objective | Views |
|-----------|-------|
| **Encounter Overview** | `vw_encounters_by_year`, `vw_encounters_by_class_year` (incl. YoY change), `vw_encounter_duration_split` (under 24h vs 24h+) |
| **Patient Behavior** | `vw_patients_by_quarter`, `vw_readmission_summary`, `vw_top_readmitted_patients`, `vw_readmissions_30day` |
| **Cost and Coverage** | `vw_claim_cost_by_payer`, `vw_procedures_by_payer_ranked` |
| **Shared / supporting** | `dim_year`, `vw_total_unique_inpatients_by_year` |

Power BI connected directly to these views. Every metric that could be calculated in SQL was calculated in SQL, keeping the DAX measures minimal and the dashboard easy to maintain.

---

## 📊 Dashboards

### Dashboard 1: Encounter Overview

High-level view of hospital activity, tracking year-over-year shifts in encounter volume, encounter class, and encounter duration from 2011 to 2022 — helping identify which types of care are growing or declining over time.

**Visuals included:**

- **Encounter Volume & Duration Split by Year** — combo chart: total encounters (line) vs. duration split into under-24h and 24h+ (stacked columns)
- **Encounter Class Distribution** — donut chart showing average share of encounters by the six encounter classes across the period
- **Encounter Class Mix by Year** — matrix with year, encounter class, total count, class distribution (%), and YoY change (%), enabling class-level drill-down

**Source views:** `vw_encounters_by_year`, `vw_encounters_by_class_year` (also powers the encounter class slicer), `vw_encounter_duration_split`, `dim_year` (year slicer)

<img width="1918" height="1078" alt="01_encounter_overview" src="https://github.com/user-attachments/assets/df032f38-88d8-45a5-ab21-e71c89f73d66" />

*Figure 1: Encounter Overview dashboard*

<img width="1441" height="555" alt="02_class_mix_zoomin" src="https://github.com/user-attachments/assets/97ac9c74-8873-4c68-83da-a4bd310e6567" />

*Figure 2: Zoom-in — Encounter Class Mix by Year matrix (per-class counts, distribution %, and YoY change across 12 years)*

### Dashboard 2: Patient Behavior

Inpatient readmission patterns and patient volume from 2011-Q1 to 2022-Q4 — how many unique patients were admitted each quarter and how many returned within 30 days of a prior discharge.

**Visuals included:**

- **30-Day Readmitted Inpatients** — card: distinct inpatients with at least one readmission within 30 days
- **Total Unique Inpatients** — card: distinct inpatient population across the period
- **30-Day Inpatient Readmission Rate** — card: share of inpatients readmitted within 30 days
- **30-Day Inpatient Readmission Events** — card: total count of qualifying readmission events
- **Top 10 Inpatients Ranked by Readmission Count (30-Day)** — horizontal bar chart, patient ID on y-axis, readmission count on x-axis
- **Patient Volume & Inpatient Admissions by Quarter** — combo chart with dual axes: columns show total patients per quarter (left axis), line shows inpatient admissions per quarter (right axis)

**Source views:** `vw_patients_by_quarter`, `vw_readmission_summary`, `vw_top_readmitted_patients`, `vw_readmissions_30day`, `vw_total_unique_inpatients_by_year`, `dim_year` (year slicer)

<img width="1918" height="1078" alt="03_patient_behavior" src="https://github.com/user-attachments/assets/b0316f49-b467-499a-afd7-9b1ac21b9dcb" />

*Figure 3: Patient Behavior dashboard*

<img width="1437" height="548" alt="04_patient_volume_zoomin" src="https://github.com/user-attachments/assets/745e0850-cc0b-4193-9d27-da20bab611d3" />

*Figure 4: Zoom-in — Patient Volume & Inpatient Admissions by Quarter (48 quarters on dual axes)*

### Dashboard 3: Cost & Coverage

Payer coverage and procedure costs from 2011–2022 — comparing average claim costs across payers and profiling procedure frequency versus cost, with a focus on uninsured patients.

**Visuals included:**

- **Average Claim Cost by Payer** — horizontal bar chart of average claim cost per payer (including NO_INSURANCE)
- **Procedures for Uninsured Patients: Frequency vs. Cost** — scatter plot of procedures on NO_INSURANCE patients, frequency on x-axis, average base cost on y-axis; two range sliders filter by dragging the upper limits
- **Top 10 Procedures by Payer** — matrix of top 10 procedures by frequency for the 5 payers with the highest average claim cost (Medicaid, Humana, Cigna Health, Blue Cross Blue Shield, Anthem — excluding NO_INSURANCE)

**Source views:** `vw_claim_cost_by_payer`, `vw_procedures_by_payer_ranked`, `dim_year` (year slicer)

<img width="1918" height="1078" alt="05_cost_coverage" src="https://github.com/user-attachments/assets/a33e86b9-aec7-4cf5-a050-bc3b8f88b8d3" />

*Figure 5: Cost & Coverage dashboard*

<img width="870" height="454" alt="06_uninsured_scatter_zoomin" src="https://github.com/user-attachments/assets/5c942b3b-c13c-41a2-9180-817d8ff16845" />

*Figure 6: Zoom-in — Procedures for Uninsured Patients scatter plot with range-slider filters*

---

## 💡 Findings

### 1. Encounter volume moves in cycles

Total encounters were lowest in 2011 at 1.3K, then climbed to a peak of 3.9K in 2014. From 2015 to 2020, volume settled around 2.2K to 2.5K per year, before rising again to 3.5K in 2021. Encounter volume is not on a steady decline — it moves in cycles, and the mix of visits changes along with it.

### 2. Long encounters dropped sharply

Encounters lasting 24 hours or more dropped from 6.3 percent of visits in 2011 to just 1.6 percent in 2021. Since a 24-hour-plus encounter corresponds to an inpatient stay, this points to fewer inpatient admissions relative to total visits, with more care delivered in outpatient and other settings.

### 3. 2021 is an outlier year

2021 is the only year where ambulatory lost its top position to outpatient, the year with the lowest ambulatory share at 36.9 percent, and the year with the lowest rate of long encounters at 1.6 percent. These three anomalies align — fewer long stays and more outpatient volume point to a shift away from inpatient care in that year.

### 4. Ambulatory still dominates, but its share swung 23 points

Ambulatory care leads encounter volume in every year except 2021. Its highest share was 60.3 percent in 2014; its lowest was 36.9 percent in 2021 — a significant shift in how care is delivered.

### 5. Readmissions concentrate in a small group

*Note: All readmission metrics are based on inpatient encounters only (`ENCOUNTERCLASS = 'inpatient'`). Total patient volume in the quarterly chart includes all encounter classes.*

396 unique inpatients were seen across the period, and 23 were readmitted within 30 days — a **5.8 percent** readmission rate. The top 10 inpatients by 30-day readmission count were led by the highest-readmission patient at 52, with a median of 37 among the top 10.

### 6. Patient volume is not steady

Quarterly volume peaks in 2014-Q1/Q2 and 2021-Q1/Q2, while 2011 was consistently the lowest year with all four quarters below 200. Inpatient admissions stayed relatively stable — most quarters saw 10 to 15 inpatients, with a low of 5 in 2019-Q4 and a high of 20 in 2014-Q4.

### 7. Medicaid and uninsured encounters cost the most

Medicaid encounters had the highest average claim cost at **6.2K**, uninsured encounters came second at **5.6K**, and Anthem third at **4.2K**. Dual Eligible patients had the lowest at **1.7K** — less than a third of the highest.

### 8. Uninsured care is a long tail of one-offs

Most procedures for uninsured patients are performed infrequently, with a median frequency of just 20 across 2011 to 2022. Average base costs concentrate at the low end (median 2.7K); only one procedure reaches as high as 46K. Uninsured care is not expensive because of volume or routine treatment — it is expensive only in rare, isolated cases.

---

## ✅ Business Recommendations

### Encounter Overview — Volume Cycles and Care Delivery Shifts

| Signal | Implication |
|--------|-------------|
| Encounter volume moves in cycles, not a steady trend | Plan capacity, staffing, and budgeting around peak years like 2014 and 2021, not a single growth/decline assumption |
| Long (24h+) encounters fell from 6.3% to 1.6% of visits | Smaller share of inpatient work — direct implications for bed capacity, inpatient staffing, and resource distribution |
| 2021 broke the pattern (outpatient overtook ambulatory) | Investigate whether this was a one-year disruption or a structural shift in care delivery |
| Ambulatory share fell from 60.3% (2014) to 36.9% (2021) | Watch the trend; reconsider capacity investment and staffing across care settings if it continues |

### Patient Behavior — Reducing readmissions

| Signal | Implication |
|--------|-------------|
| 5.8% readmission rate driven by a small group of inpatients | Target care management — outreach, medication reviews, transitional care — at the highest-readmission patients |
| Top 10 readmitted inpatients hold a disproportionate share of events | Even a small reduction for this group meaningfully lowers total readmission events |
| Patient volume swings by quarter while inpatient admissions stay stable | Plan capacity around peak periods, not averages; more visits are being handled outside inpatient stays |

### Cost and Coverage — Payer and Procedure Cost Patterns

| Signal | Implication |
|--------|-------------|
| Medicaid (6.2K) and uninsured (5.6K) encounters cost the most per visit | High-cost care concentrates in a few payer groups — informs resource structuring and payer contract strategy |
| Uninsured procedures are low-frequency one-offs (median 20) with low median cost (2.7K) | Spending concentrates in rare, isolated cases — pair with location data to target outreach and financial assistance geographically |

---

## ⚙️ Reflections

### Technical Challenges

| Challenge | Solution |
|-----------|----------|
| **Defining readmissions correctly** | My first version counted any inpatient encounter starting within 30 days of a previous discharge — plausible but wrong, since overlapping and transferred stays counted as readmissions when the patient never left. I added a condition that the new admission must start strictly after the previous discharge, eliminating the false positives and matching how hospitals actually measure readmissions. |
| **Making year-over-year change meaningful** | A raw count change in encounter class is misleading because total volume shifts year to year. I showed both the count and the percentage change side by side so the viewer can tell whether a class grew on its own or simply because the hospital saw more patients overall. |
| **Keeping Power BI simple** | It is tempting to move all logic into DAX. I deliberately kept the heavy aggregation in SQL, which made the report easier to debug, easier to maintain, and easier for anyone reviewing the SQL to verify the numbers. |

### Directions for Further Analysis

- Investigate what drove the encounter class mix shifts — particularly whether ambulatory or urgent care grew due to policy changes, population shifts, or operational decisions.
- Dig into *why* a small group of patients returns so frequently — encounter history, reason codes, and demographics could reveal chronic-condition management gaps vs. discharge-process issues.
- Segment procedures and reason codes by payer to clarify whether the cost gap reflects patient population differences or reimbursement structures.
- Pair the high-frequency, high-cost uninsured procedures with patient location data to find geographic clusters for outreach or financial assistance.

---

## 🎬 Video Walkthrough

A walkthrough of the three dashboards — encounter trends, readmission patterns, and cost/coverage analysis.

https://github.com/user-attachments/assets/113e4091-1f5d-4e51-8f29-ffd09375af0c

---

## 📁 Project Files & Resources

- `create_hospital_db.sql` # Creates the database and sets up the ground for analysis
- `create_views_objective1.sql` # Encounter overview views
- `create_views_objective2.sql` # Patient behavior views
- `create_views_objective3.sql` # Cost and coverage views
- `create_dim_year.sql` # Shared year dimension
- `vw_total_unique_inpatients_by_year.sql` # Supporting inpatient count view
- `encounters.rar` # Visit records with start/stop times, encounter class, payer, claim cost (compressed CSV file)
- `procedures.rar` # Procedure codes, descriptions, base costs, linked encounters (compressed CSV file)
- `patients.rar` # Demographics: birth date, gender, race, location (compressed CSV file)
- `payers.rar` # Payer names mapped to encounter payer IDs (compressed CSV file)
- `dashboard_walkthrough.mp4` # Screen recording walkthrough
- `screenshots/01_encounter_overview.png` # Encounter Overview dashboard
- `screenshots/02_class_mix_zoomin.png` # Zoom-in: Encounter Class Mix by Year matrix
- `screenshots/03_patient_behavior.png` # Patient Behavior dashboard
- `screenshots/04_patient_volume_zoomin.png` # Zoom-in: Patient Volume & Inpatient Admissions by Quarter
- `screenshots/05_cost_coverage.png` # Cost & Coverage dashboard
- `screenshots/06_uninsured_scatter_zoomin.png` # Zoom-in: Procedures for Uninsured Patients scatter plot
- `README.md` # Project overview and analysis

---

## 🏷️ Tags

`#PowerBI` `#MySQL` `#HealthcareAnalytics` `#DataVisualization` `#DashboardDesign` `#BusinessIntelligence` `#HospitalAnalytics`
