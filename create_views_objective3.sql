-- File: create_views_objective3.sql
-- Purpose: Objective 3 — Cost & Coverage views for Power BI
-- Note: Procedures ranked within each payer per year

USE hospital_db;

-- ============================================================
-- 3.1 Average claim cost per payer per year
-- ============================================================
DROP VIEW IF EXISTS vw_claim_cost_by_payer;
CREATE VIEW vw_claim_cost_by_payer AS
SELECT
    YEAR(e.START) AS year_key,
    p.NAME AS payer_name,
    COUNT(e.Id) AS encounter_count,
    ROUND(AVG(e.TOTAL_CLAIM_COST), 2) AS avg_claim_cost,
    ROUND(SUM(e.TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters e
LEFT JOIN payers p ON e.PAYER = p.Id
GROUP BY YEAR(e.START), p.NAME
ORDER BY year_key, avg_claim_cost DESC;

-- ============================================================
-- 3.2 Procedures ranked within each payer per year
-- ============================================================
DROP VIEW IF EXISTS vw_procedures_by_payer_ranked;
CREATE VIEW vw_procedures_by_payer_ranked AS
WITH proc_payer AS (
    SELECT
        YEAR(e.START) AS year_key,
        p.NAME AS payer_name,
        pr.CODE AS procedure_code,
        pr.DESCRIPTION AS procedure_description,
        COUNT(*) AS procedure_frequency,
        ROUND(AVG(pr.BASE_COST), 2) AS avg_base_cost
    FROM procedures pr
    JOIN encounters e ON pr.ENCOUNTER = e.Id
    JOIN payers p ON e.PAYER = p.Id
    GROUP BY YEAR(e.START), p.NAME, pr.CODE, pr.DESCRIPTION
),
ranked AS (
    SELECT
        year_key,
        payer_name,
        procedure_code,
        procedure_description,
        procedure_frequency,
        avg_base_cost,
        DENSE_RANK() OVER (
            PARTITION BY year_key, payer_name
            ORDER BY procedure_frequency DESC
        ) AS freq_rank,
        DENSE_RANK() OVER (
            PARTITION BY year_key, payer_name
            ORDER BY avg_base_cost DESC
        ) AS cost_rank
    FROM proc_payer
)
SELECT
    year_key,
    payer_name,
    procedure_code,
    procedure_description,
    procedure_frequency,
    avg_base_cost,
    freq_rank,
    cost_rank
FROM ranked
WHERE freq_rank <= 20 OR cost_rank <= 20
ORDER BY year_key, payer_name, freq_rank;