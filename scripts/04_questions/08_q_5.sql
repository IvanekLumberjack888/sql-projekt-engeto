-- QUESTION 5
---------------------------------------------------------
-- Otázka 5: Spojení HDP, růstu mezd a růstu cen potravin
-- (2006–2018)
---------------------------------------------------------

-- -------------------------------------------------------------------------
-- Skript pro dotaz č. 5: Vztah HDP, mezd a cen potravin v ČR
-- -------------------------------------------------------------------------

SET search_path TO data_academy_content;

-- 1. Vjůčko s pohledem na meziroční růst HDP ČR
-- Vypočítá procentuální růst HDP pro Českou republiku
CREATE OR REPLACE VIEW v_gdp_diff AS
WITH gdp_cr AS (
  SELECT
    year,
    gdp,
    LAG(gdp) OVER (ORDER BY year) AS prev_gdp
  FROM v_european_economies
  WHERE country = 'Czech Republic'
    AND year BETWEEN 2006 AND 2018
)
SELECT
  year,
  ROUND(((gdp - prev_gdp) / prev_gdp * 100)::numeric, 2) AS gdp_growth_pct
FROM gdp_cr
WHERE prev_gdp IS NOT NULL
ORDER BY year;


-- 2. Vjůčko pro meziroční růst průměrné mzdy ČR
-- Vypočítá procentuální růst průměrné mzdy
CREATE OR REPLACE VIEW v_salary_diff AS
WITH salary_cr AS (
  SELECT
    payroll_year AS year,
    ROUND(AVG(avg_payroll)::numeric, 2) AS avg_salary,
    LAG(ROUND(AVG(avg_payroll)::numeric, 2)) OVER (ORDER BY payroll_year) AS prev_avg_salary
  FROM v_annual_payroll_summary
  WHERE payroll_year BETWEEN 2006 AND 2018
  GROUP BY payroll_year
)
SELECT
  year,
  ROUND(((avg_salary - prev_avg_salary) / prev_avg_salary * 100)::numeric, 2) AS salary_growth_pct
FROM salary_cr
WHERE prev_avg_salary IS NOT NULL
ORDER BY year;


-- 3. Vjůčko pro meziroční růst průměrných cen potravin
-- Vypočítá procentuální růst průměrné ceny pro každou kategorii
CREATE OR REPLACE VIEW v_price_yearly_changes_avg AS
WITH avg_prices AS (
    SELECT
        price_year AS year,
        AVG(avg_price) AS avg_price_czk
    FROM v_annual_price_summary
    GROUP BY price_year
    ORDER BY price_year
)
SELECT
    current_year.year,
    ROUND(
        (
            (current_year.avg_price_czk - previous_year.avg_price_czk)
            / previous_year.avg_price_czk * 100
        )::numeric,
        2
    ) AS price_growth_pct
FROM avg_prices AS current_year
LEFT JOIN avg_prices AS previous_year
    ON current_year.year = previous_year.year + 1
WHERE previous_year.avg_price_czk IS NOT NULL
ORDER BY current_year.year;

-- 4. Konečný dotaz pro analýzu vztahů
-- Spojí všechna data do jedné tabulky
SELECT
    gdp.year,
    gdp.gdp_growth_pct,
    salary.salary_growth_pct,
    price.price_growth_pct
FROM v_gdp_diff AS gdp
JOIN v_salary_diff AS salary ON gdp.year = salary.year
JOIN v_price_yearly_changes_avg AS price ON gdp.year = price.year
ORDER BY gdp.year;


-- Nechtělo mi to brát ty vjůčka z 01_view. Dal jsem je sem.
