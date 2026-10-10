DROP VIEW IF EXISTS vw_total_unique_inpatients_by_year;

CREATE VIEW vw_total_unique_inpatients_by_year AS
SELECT
    YEAR(START) AS yr,
    COUNT(DISTINCT PATIENT) AS total_unique_inpatients
FROM encounters
WHERE ENCOUNTERCLASS = 'inpatient'
GROUP BY YEAR(START)
ORDER BY yr;
