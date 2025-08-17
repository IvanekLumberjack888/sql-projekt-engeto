-- QUESTION 2
---------------------------------------------------------
-- Otázka 2: Kolik kg chleba a litrů mléka si mohl koupit
-- za průměrnou mzdu v prvním (2006) a posledním (2018) období
---------------------------------------------------------

SET search_path TO data_academy_content;

SELECT
  s.payroll_year,
  s.avg_salary_czk,                                            -- průměrná mzda ČR
  f.bread_price_per_kg,                                        -- průměrná cena chleba za kg
  f.milk_price_per_liter,                                      -- průměrná cena mléka za litr
  ROUND(s.avg_salary_czk / f.bread_price_per_kg, 1)   AS kg_bread_per_salary,    -- kolik kg chleba za mzdu
  ROUND(s.avg_salary_czk / f.milk_price_per_liter, 1) AS liters_milk_per_salary   -- kolik litrů mléka za mzdu
FROM
  (
    -- průměrná mzda ČR pro první a poslední rok
    SELECT
      ps.payroll_year,
      ROUND(AVG(ps.avg_payroll)::numeric, 2) AS avg_salary_czk
    FROM v_annual_payroll_summary ps
    WHERE ps.payroll_year IN (
      (SELECT MIN(payroll_year) FROM v_annual_payroll_summary),
      (SELECT MAX(payroll_year) FROM v_annual_payroll_summary)
    )
    GROUP BY ps.payroll_year
  ) AS s
JOIN
  (
    -- průměrné ceny chleba a mléka pro první a poslední rok
    SELECT
      bp.price_year                                  AS payroll_year,
      MAX(CASE WHEN bp.category_code = '111301' THEN bp.avg_price END) AS bread_price_per_kg,
      MAX(CASE WHEN bp.category_code = '114201' THEN bp.avg_price END) AS milk_price_per_liter
    FROM v_basic_food_prices bp
    WHERE bp.price_year IN (2006, 2018)
    GROUP BY bp.price_year
  ) AS f
  ON s.payroll_year = f.payroll_year
ORDER BY s.payroll_year;

