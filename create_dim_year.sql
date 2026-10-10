-- File: create_dim_year.sql
-- Purpose: Shared year dimension for Power BI cross-filtering
-- Note: One row per distinct year — the "hub" that all views relate to

USE hospital_db;

DROP VIEW IF EXISTS dim_year;
CREATE VIEW dim_year AS
SELECT DISTINCT
    YEAR(START) AS year_key
FROM encounters
ORDER BY year_key;

