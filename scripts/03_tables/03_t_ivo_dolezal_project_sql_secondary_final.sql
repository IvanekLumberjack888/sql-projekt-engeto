-- SECONDARY TABLE
---------------------------------------------------------
-- 03_t_ivo_dolezal_project_sql_secondary_final.sql
-- Sekundární tabulka s HDP, GINI, deňěmi, atd.
---------------------------------------------------------

-- Ověření
DROP TABLE IF EXISTS data_academy_content.t_ivo_dolezal_project_sql_secondary_final;

CREATE TABLE data_academy_content.t_ivo_dolezal_project_sql_secondary_final AS
SELECT DISTINCT
    e."year"           AS econ_year,
    e.country          AS country_name,
    c.capital_city     AS capital_city,
    c.currency_name    AS currency_name,
    c.currency_code    AS currency_code,
    e.gdp              AS gdp,
    e.population       AS population,
    e.gini             AS gini,
    e.taxes            AS taxes
FROM data_academy_content.economies AS e
INNER JOIN data_academy_content.countries AS c
    ON e.country = c.country
WHERE c.continent = 'Europe'
  AND e."year" BETWEEN 2006 AND 2018
  AND e.gdp IS NOT NULL
  AND e.taxes IS NOT NULL
  AND c.currency_code IS NOT NULL
  AND c.currency_name IS NOT NULL
  AND e.gini IS NOT NULL
ORDER BY country_name, econ_year;
-- Evropa. U některých sloupců v těch tabulkách bylo NULL v záznamech -> To je ošetřeno.


