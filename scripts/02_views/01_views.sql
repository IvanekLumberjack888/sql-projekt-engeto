-- VIEWS
---------------------------------------------------------
-- 01_views.sql
-- Vytvoření pomocných pohledů pro snadnější práci
---------------------------------------------------------

-- Jak je na tom EVROPA - POHLED nebo raději podle Pavly 'vjůčko'
CREATE OR REPLACE VIEW data_academy_content.v_european_economies AS
SELECT
	country,
	year,
	gdp,
	population,
	gini
FROM data_academy_content.economies e
WHERE year BETWEEN 2006 AND 2018
	AND e.country IN (
		SELECT c.country
		FROM data_academy_content.countries c
		WHERE c.continent = 'Europe');

-- Vjůčko pro mzdy v ČR
-- Vjůčko na ceny a mzdy tugedr
CREATE OR REPLACE VIEW data_academy_content.v_czechia_payroll_clean AS
SELECT
	payroll_year,
	industry_branch_code,
	pib.name AS industry_name,
	value AS payroll_value,
	value_type_code,
	calculation_code
FROM
	data_academy_content.czechia_payroll AS p
LEFT JOIN data_academy_content.czechia_payroll_industry_branch AS pib
	ON
	p.industry_branch_code = pib.code
WHERE
	value_type_code = 5958
	AND calculation_code = 100
	AND payroll_year BETWEEN 2006 AND 2018
	AND value IS NOT NULL
    AND pib.name IS NOT NULL;

-- A teď vjůčko na mzdy a ceny Česko - pro tebe všecko :-D
-- ZDE PROVEDENA OPRAVA: Zjednodušení JOINů a WHERE klauzule
CREATE OR REPLACE VIEW data_academy_content.v_payroll_price_joined AS
SELECT
	p.payroll_year,
	p.industry_branch_code,
	p.industry_name,
	ROUND(AVG(p.payroll_value)::numeric, 2) AS avg_payroll,
	pr.category_code AS food_category_code,
	pr.category_name AS food_category_name,
	ROUND(AVG(pr.price_value_czk)::numeric, 2) AS avg_price
FROM data_academy_content.v_czechia_payroll_clean p
JOIN data_academy_content.v_czechia_price_clean pr
	ON p.payroll_year = pr.price_year
WHERE p.industry_name IS NOT NULL
GROUP BY
	p.payroll_year,
	p.industry_branch_code,
	p.industry_name,
	food_category_code,
	food_category_name;

-- Vjůčko na ceny a mzdy tugedr
CREATE OR REPLACE VIEW data_academy_content.v_czechia_price_clean AS
SELECT
	EXTRACT	(YEAR FROM date_from) AS price_year,
	category_code,
	pc.name AS category_name,
	pc.price_value,
	pc.price_unit,
	value AS price_value_czk,
	region_code
FROM data_academy_content.czechia_price pr
LEFT JOIN data_academy_content.czechia_price_category pc
	ON pr.category_code = pc.code
WHERE pr.region_code IS NULL
	AND pr.date_from	<= DATE '2018-12-31 23:59:59'	-- Potraviny jsou od-do
	AND pr.date_to		>= DATE '2006-01-01 00:00:00'	-- Období je jiné než payroll
	AND EXTRACT(YEAR FROM pr.date_from) BETWEEN 2006 AND 2018
	AND pr.value		IS NOT NULL
	AND industry_branch_code IS NOT NULL;	
	--přece nebudem počítat s nuly

	
-- A teď vjůčko na mzdy a ceny Česko - pro tebe všecko :-D
CREATE OR REPLACE VIEW data_academy_content.v_payroll_price_joined AS
SELECT
	p.payroll_year,
	p.industry_branch_code,
	p.industry_name,
	ROUND(AVG(p.payroll_value)::numeric, 2) AS avg_payroll,
	pr.category_code AS food_category_code,
	pr.category_name AS food_category_name,
	ROUND(AVG(pr.price_value_czk)::numeric, 2) AS avg_price
FROM data_academy_content.v_czechia_payroll_clean p
INNER JOIN data_academy_content.v_czechia_price_clean pr
	ON p.payroll_year = pr.price_year	-- Spojíme podle roku
LEFT JOIN data_academy_content.czechia_payroll_industry_branch AS pib
    ON p.industry_branch_code = pib.code
WHERE
    pib.name IS NOT NULL
GROUP BY
	p.payroll_year,
	p.industry_branch_code,
	p.industry_name,
	food_category_code,
	food_category_name;

-- Vjůčko mezd po letech
CREATE OR REPLACE VIEW data_academy_content.v_annual_payroll_summary AS
SELECT
	payroll_year,
	industry_branch_code,
	industry_name,
	ROUND(AVG(payroll_value)::numeric, 2) AS avg_payroll,
	COUNT(*) AS record_count
FROM data_academy_content.v_czechia_payroll_clean
WHERE industry_name IS NOT NULL
GROUP BY
	payroll_year,
	industry_branch_code,
	industry_name
ORDER BY
	payroll_year,
	industry_branch_code;

-- Vjůčko cen po letech
CREATE OR REPLACE VIEW data_academy_content.v_annual_price_summary AS
SELECT
	price_year,
	category_code,
	category_name,
	price_unit,
	ROUND(AVG(price_value_czk)::numeric, 2) AS avg_price,
	COUNT(*) AS record_count
FROM data_academy_content.v_czechia_price_clean
GROUP BY
	price_year,
	category_code,
	category_name,
	price_unit
ORDER BY
	price_year,
	category_code;

-- A teď vjůčko na chleba a mléko
CREATE OR REPLACE VIEW data_academy_content.v_basic_food_prices AS
SELECT
	price_year,
	category_code,
	category_name,
	price_unit,
	avg_price
FROM data_academy_content.v_annual_price_summary
WHERE category_code IN ('111301', '114201')
ORDER BY price_year, category_code;

-- Vjůčko: Jak se měnila mzda -> "NO.. jak u koho.. :-D"
CREATE OR REPLACE VIEW data_academy_content.v_payroll_yearly_changes AS
SELECT
    current_year.payroll_year,
    current_year.industry_branch_code,
    current_year.industry_name,
    current_year.avg_payroll     AS current_payroll,
    previous_year.avg_payroll    AS previous_payroll,
    ROUND(
        (
            (current_year.avg_payroll - previous_year.avg_payroll)
            / previous_year.avg_payroll * 100
        )::numeric,
        2
    ) AS payroll_change_percent
FROM data_academy_content.v_annual_payroll_summary current_year
LEFT JOIN data_academy_content.v_annual_payroll_summary previous_year
  ON current_year.industry_branch_code = previous_year.industry_branch_code
  AND current_year.payroll_year = previous_year.payroll_year + 1
WHERE previous_year.avg_payroll IS NOT NULL
ORDER BY
    current_year.payroll_year,
    current_year.industry_branch_code;

-- Vjůčko: Jak se měnily ceny v letech? -> 📈📈📈
CREATE OR REPLACE VIEW data_academy_content.v_price_yearly_changes AS
SELECT
	current_year.price_year,
	current_year.category_code,
	current_year.category_name,
	current_year.avg_price AS current_price,
	previous_year.avg_price AS previous_price,
	ROUND(
		(
			(current_year.avg_price - previous_year.avg_price)
			/ previous_year.avg_price * 100
			)::numeric,
			2
		) AS price_change_percent
FROM data_academy_content.v_annual_price_summary current_year
LEFT JOIN data_academy_content.v_annual_price_summary previous_year
	ON current_year.category_code = previous_year.category_code
	AND current_year.price_year = previous_year.price_year + 1
WHERE previous_year.avg_price IS NOT NULL
ORDER BY current_year.price_year, current_year.category_code;

-- Vjůčko s roční průměrnou mzdou v ČR napříč obory
CREATE OR REPLACE
VIEW data_academy_content.v_overall_payroll_avg AS
SELECT
	payroll_year,
	ROUND(AVG(avg_payroll)::NUMERIC, 2) AS avg_salary_czk
	-- průměrná mzda ČR napříč všemi obory
FROM
	data_academy_content.v_annual_payroll_summary
GROUP BY
	payroll_year
ORDER BY
	payroll_year;

-- Vjůčko s pohledem na meziroční růst HPD ČR
CREATE OR REPLACE VIEW data_academy_content.v_gdp_diff AS
WITH gdp_cr AS (
  SELECT
    year,
    gdp,
    LAG(gdp) OVER (ORDER BY year) AS prev_gdp
  FROM data_academy_content.v_european_economies
  WHERE country = 'Czech Republic'
    AND year BETWEEN 2006 AND 2018
)
SELECT
  year,
  ROUND(((gdp - prev_gdp) / prev_gdp * 100)::numeric, 2) AS gdp_growth_pct
FROM gdp_cr
WHERE prev_gdp IS NOT NULL
ORDER BY year  
;

-- Vjůčko pro meziroční růst průměrné mzdy ČR
CREATE OR REPLACE VIEW data_academy_content.v_salary_diff AS
WITH salary_cr AS (
  SELECT
    payroll_year AS year,
    ROUND(AVG(avg_payroll)::numeric, 2) AS avg_salary,
    LAG(ROUND(AVG(avg_payroll)::numeric, 2)) OVER (ORDER BY payroll_year) AS prev_avg_salary
  FROM data_academy_content.v_annual_payroll_summary
  WHERE payroll_year BETWEEN 2006 AND 2018
  GROUP BY payroll_year
)
SELECT
  year,
  ROUND(((avg_salary - prev_avg_salary) / prev_avg_salary * 100)::numeric, 2) AS salary_growth_pct
FROM salary_cr
WHERE prev_avg_salary IS NOT NULL
ORDER BY year
;

-- Průměr mezd, všechna odvětví
SET search_path TO data_academy_content;

-- -------------------------------------------------------------------------
-- POHLED 2: v_annual_payroll_summary  
-- Roční průměr mezd v ČR za všechna odvětví (bez sloupce industry_branch_code)
-- -------------------------------------------------------------------------


-- Makro data
CREATE OR REPLACE VIEW v_european_economies AS
SELECT 
    c.country,
    e.year,
    e.gdp,
    e.population,
    e.gini
FROM economies e
JOIN countries c ON e.country = c.country
WHERE c.continent = 'Europe'
  AND e.year BETWEEN 2000 AND 2020
ORDER BY c.country, e.year;

CREATE OR REPLACE VIEW v_annual_payroll_summary AS
SELECT 
    cp.payroll_year,
    ROUND(AVG(cp.value), 2) AS avg_payroll,
    COUNT(*)                  AS industry_count,
    MIN(cp.value)             AS min_payroll,
    MAX(cp.value)             AS max_payroll
FROM czechia_payroll cp
WHERE cp.value_type_code = 5958  -- Průměrná hrubá mzda na zaměstnance
  AND cp.unit_code       = 200   -- Kč
  AND cp.calculation_code= 200   -- Přepočtená hodnota
  AND cp.value IS NOT NULL
GROUP BY cp.payroll_year
ORDER BY cp.payroll_year;

CREATE OR REPLACE VIEW "v_european_economies" AS
SELECT
    c."country",
    e."year",
    e."gdp"
FROM "economies" e
JOIN "countries" c ON e."country" = c."country"
WHERE c."continent" = 'Europe'
  AND e."year" BETWEEN 2006 AND 2018
ORDER BY c."country", e."year";

-------------------------------------------------------------------------------
-- 2) POHLED: v_annual_payroll_summary
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW "v_annual_payroll_summary" AS
SELECT
    cp."payroll_year"    AS "year",
    ROUND(AVG(cp."value"), 2) AS "avg_payroll"
FROM "czechiapayroll" cp
WHERE cp."valuetypecode" = 5958
  AND cp."unitcode"     = 200
  AND cp."calculationcode" = 200
  AND cp."value" IS NOT NULL
GROUP BY cp."payroll_year"
ORDER BY cp."payroll_year";

-------------------------------------------------------------------------------
-- 3) POHLED: v_annual_price_summary
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW "v_annual_price_summary" AS
SELECT
    EXTRACT(YEAR FROM cp."datefrom")::INT AS "year",
    ROUND(AVG(cp."value"), 2)          AS "avg_price"
FROM "czechiaprice" cp
WHERE cp."regioncode" IS NULL
  AND cp."value" IS NOT NULL
  AND EXTRACT(YEAR FROM cp."datefrom") BETWEEN 2006 AND 2018
GROUP BY EXTRACT(YEAR FROM cp."datefrom")
ORDER BY 1;
