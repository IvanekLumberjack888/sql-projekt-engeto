-- QUESTION 4
---------------------------------------------------------
-- Otázka 4: Byl rok s výrazně vyšším růstem cen než mezd?
-- CRITICAL YEARS – PRICES vs SALARIES (2006–2018)
---------------------------------------------------------
-- Kontrola všech meziročních rozdílů růstu cen a mezd (2006–2018)

SET search_path TO data_academy_content;

WITH salary_growth AS (
  SELECT
    payroll_year,
    ROUND(AVG(payroll_change_percent)::numeric, 2) AS avg_salary_growth
  FROM v_payroll_yearly_changes
  WHERE payroll_change_percent IS NOT NULL
  GROUP BY payroll_year
),
price_growth AS (
  SELECT
    price_year    AS payroll_year,
    ROUND(AVG(price_change_percent)::numeric, 2) AS avg_price_growth
  FROM v_price_yearly_changes
  WHERE price_change_percent IS NOT NULL
  GROUP BY price_year
)
SELECT
  ROUND((pg.avg_price_growth - sg.avg_salary_growth)::numeric, 2)
  	AS diff_pct,
  sg.payroll_year      AS year,
  sg.avg_salary_growth AS salary_growth_pct,
  pg.avg_price_growth  AS price_growth_pct
FROM salary_growth sg
JOIN price_growth pg
  ON sg.payroll_year = pg.payroll_year
ORDER BY diff_pct DESC;

