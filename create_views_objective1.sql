-- File: create_views_objective1.sql
-- Purpose: Objective 1 — Encounters Overview views for Power BI

USE hospital_db;

-- ============================================================
-- 1.1 Total encounters per year
-- ============================================================
DROP VIEW IF EXISTS vw_encounters_by_year;
CREATE VIEW vw_encounters_by_year AS
SELECT
    YEAR(START) AS year_key,
    COUNT(*) AS total_encounters
FROM encounters
GROUP BY YEAR(START);

-- ============================================================
-- 1.2 Percentage by encounter class per year (LONG format) — WITH YoY
-- ============================================================
DROP VIEW IF EXISTS vw_encounters_by_class_year;
CREATE VIEW vw_encounters_by_class_year AS
WITH yearly AS (
    SELECT
        YEAR(START) AS year_key,
        ENCOUNTERCLASS AS encounter_class,
        COUNT(*) AS class_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY YEAR(START)), 2) AS pct_of_year
    FROM encounters
    GROUP BY YEAR(START), ENCOUNTERCLASS
),
with_lag AS (
    SELECT
        year_key,
        encounter_class,
        class_count,
        pct_of_year,
        LAG(class_count) OVER (PARTITION BY encounter_class ORDER BY year_key) AS prev_year_count
    FROM yearly
)
SELECT
    year_key,
    encounter_class,
    class_count,
    pct_of_year,
    ROUND((class_count - prev_year_count) / prev_year_count * 100.0, 2) AS yoy_change_pct
FROM with_lag
ORDER BY year_key, encounter_class;

-- ============================================================
-- 1.3 % of encounters over/under 24 hours — PER YEAR
-- ============================================================
DROP VIEW IF EXISTS vw_encounter_duration_split;
CREATE VIEW vw_encounter_duration_split AS
WITH duration AS (
    SELECT
        Id,
        YEAR(START) AS year_key,
        TIMESTAMPDIFF(SECOND, START, STOP) / 3600 AS hour_diff
    FROM encounters
)
SELECT
    year_key,
    ROUND(SUM(CASE WHEN hour_diff < 24 THEN 1 ELSE 0 END) / COUNT(*) * 100.0, 2) AS pct_under_24h,
    ROUND(SUM(CASE WHEN hour_diff >= 24 THEN 1 ELSE 0 END) / COUNT(*) * 100.0, 2) AS pct_over_eq_24h
FROM duration
GROUP BY year_key
ORDER BY year_key;
