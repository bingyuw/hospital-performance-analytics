-- File: create_views_objective2.sql
-- Purpose: Objective 2 — Patient Behavior views for Power BI
-- Note: Readmission metrics use inpatient-only (ENCOUNTERCLASS = 'inpatient')

USE hospital_db;

-- ============================================================
-- 2.1 Unique patients (any encounter) vs. inpatient admissions, per quarter
-- ============================================================
DROP VIEW IF EXISTS vw_patients_by_quarter;
CREATE VIEW vw_patients_by_quarter AS
WITH quarterly AS (
    SELECT
        YEAR(START) AS year_key,
        QUARTER(START) AS qt,
        COUNT(DISTINCT PATIENT) AS unique_patients,
        COUNT(DISTINCT CASE WHEN ENCOUNTERCLASS = 'inpatient' THEN PATIENT END) AS inpatient_admissions
    FROM encounters
    GROUP BY YEAR(START), QUARTER(START)
)
SELECT
    CONCAT(year_key, '-Q', qt) AS year_quarter,
    year_key,
    qt,
    unique_patients,
    inpatient_admissions
FROM quarterly
ORDER BY year_key, qt;

-- ============================================================
-- 2.2 Readmission summary — count + rate (inpatient only)
-- ============================================================
DROP VIEW IF EXISTS vw_readmission_summary;
CREATE VIEW vw_readmission_summary AS
WITH readmitted AS (
    SELECT COUNT(DISTINCT PATIENT) AS readmitted_count
    FROM (
        SELECT
            PATIENT,
            START,
            LAG(STOP) OVER (PARTITION BY PATIENT ORDER BY START) AS prev_stop
        FROM encounters
        WHERE ENCOUNTERCLASS = 'inpatient'
    ) AS lag_table
    WHERE prev_stop IS NOT NULL
      AND START < prev_stop + INTERVAL 30 DAY
      AND START > prev_stop  -- ← ADD THIS
),
inpatient_total AS (
    SELECT COUNT(DISTINCT PATIENT) AS total_inpatients
    FROM encounters
    WHERE ENCOUNTERCLASS = 'inpatient'
)
SELECT
    r.readmitted_count,
    i.total_inpatients,
    ROUND(r.readmitted_count / i.total_inpatients * 100.0, 2) AS readmission_rate_pct
FROM readmitted r
CROSS JOIN inpatient_total i;

-- ============================================================
-- 2.3 Top 10 readmitted inpatients (ranked)
-- ============================================================
DROP VIEW IF EXISTS vw_top_readmitted_patients;
CREATE VIEW vw_top_readmitted_patients AS
WITH readmission_events AS (
    SELECT
        PATIENT,
        START,
        STOP,
        LAG(STOP) OVER (PARTITION BY PATIENT ORDER BY START) AS prev_stop
    FROM encounters
    WHERE ENCOUNTERCLASS = 'inpatient'
),
counted AS (
    SELECT
        PATIENT,
        COUNT(*) AS readmission_count
    FROM readmission_events
    WHERE prev_stop IS NOT NULL
      AND START < prev_stop + INTERVAL 30 DAY
    GROUP BY PATIENT
)
SELECT
    PATIENT,
    readmission_count,
    RANK() OVER (ORDER BY readmission_count DESC) AS rnk
FROM counted
ORDER BY readmission_count DESC
LIMIT 10;

-- ============================================================
-- 2.4 Readmission detail — one row per readmission event (inpatient only)
-- ============================================================
DROP VIEW IF EXISTS vw_readmissions_30day;
CREATE VIEW vw_readmissions_30day AS
WITH lag_table AS (
    SELECT
        PATIENT,
        START,
        STOP,
        LAG(STOP) OVER (PARTITION BY PATIENT ORDER BY START) AS prev_stop
    FROM encounters
    WHERE ENCOUNTERCLASS = 'inpatient'
)
SELECT
    PATIENT,
    START AS admission_start,
    STOP AS admission_stop,
    prev_stop,
    TIMESTAMPDIFF(DAY, prev_stop, START) AS days_since_prev
FROM lag_table
WHERE prev_stop IS NOT NULL
  AND START < prev_stop + INTERVAL 30 DAY
  AND START > prev_stop  -- ← new: excludes overlapping stays
ORDER BY PATIENT, admission_start;
