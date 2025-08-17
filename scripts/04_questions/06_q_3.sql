
-- QUESTION 3
---------------------------------------------------------
-- Otázka 3: Která kategorie potravin zdražuje nejpomaleji
-- SLOWEST PRICE GROWTH IN CZECHIA (2006–2018)
---------------------------------------------------------

SET search_path TO data_academy_content;

WITH avg_growth AS (
  SELECT
    category_code,
    category_name,
    ROUND(AVG(price_change_percent)::numeric, 2) AS avg_annual_growth_percent,
    COUNT(*)                                    AS years_count
  FROM v_price_yearly_changes
  WHERE price_year BETWEEN 2007 AND 2018
    AND price_change_percent IS NOT NULL
  GROUP BY category_code, category_name
)
SELECT
  ag.category_code           AS "Kód kategorie",
  ag.category_name           AS "Název kategorie",
  ag.avg_annual_growth_percent AS "Průměrný roční nárůst (%)",
  ag.years_count             AS "Počet let"
FROM avg_growth ag
ORDER BY ag.avg_annual_growth_percent ASC
LIMIT 1;
