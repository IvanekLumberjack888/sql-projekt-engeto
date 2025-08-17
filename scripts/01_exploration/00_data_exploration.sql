-- #PRŮZKUM DAT
---------------------------------------------------------
/*                  ,***
  ######           ***´                                
  #     # #####  #    # ###### #    # #    # #    # 
  #     # #    # #    #     #  #   #  #    # ##  ## 
  ######  #    # #    #    #   ####   #    # # ## # 
  #       #####  #    #   #    #  #   #    # #    # 
  #       #   #  #    #  #     #   #  #    # #    # 
  #       #    #  ####  ###### #    #  ####  #    # 
  
 */
---------------------------------------------------------
---------------------------------------------------------

-- Tohle je průzkum dat projektu

---------------------------------------------------------
-- A tohle -> je ke tvorbě:

/*
   ######                                      
   #     # #####  # #    #   ##   #####  #   # 
   #     # #    # # ##  ##  #  #  #    #  # #  
   ######  #    # # # ## # #    # #    #   #   
   #       #####  # #    # ###### #####    #     'TABLE' 
   #       #   #  # #    # #    # #   #    #   
   #       #    # # #    # #    # #    #   #   
*/
---------------------------------------------------------				
-- MZDY

-- Základní kontrola tabulky mzdy
SELECT
	*
FROM
	czechia_payroll
LIMIT 5;

-- Typy hodnot mzdy
SELECT
	code, name
FROM
	czechia_payroll_value_type;
-- 316	Průměrný počet zaměstnaných osob
-- 5958	Průměrná hrubá mzda na zaměstnance

-- Mzdy za jaké období?
SELECT
	DISTINCT payroll_year
FROM
	czechia_payroll
ORDER BY
	payroll_year;
-- 2000 až 2021

SELECT DISTINCT(code), name
FROM czechia_payroll_calculation;
-- 100	fyzický
-- 200	přepočtený


-- __CENY__

-- Základní kontrola tabulky ceny
SELECT
	*
FROM
	czechia_price
LIMIT 5; -- Např: 112201 je NULL.

-- Ceny potravin v jakém období?
SELECT
	DISTINCT EXTRACT(YEAR FROM date_from) AS rok
FROM
	czechia_price
ORDER BY
	rok;
-- 2006 až 2018
-- To znamená, že porovnám roky 2006 až 2018
-- na payrollech a zboží (Intersection?)
-- Nejlepší bude poslední společný rok -> 2018 nebo první
-- Uvidíme

-- Jaké máme potraviny podle kódů?
SELECT DISTINCT"name", code
FROM czechia_price_category
ORDER by"name";
-- Běžné typy potravin. Něco je v kg, něco v litrech a něco je na kus. Zajímá nás chleba a mlíko.
-- Chléb konzumní kmínový	111301
-- Mléko polotučné pasterované	114201

-- V ROCE 2018

-- Mzda
SELECT 
	ROUND(AVG(value)::numeric, 2) AS prumerna_mzda_2018
FROM czechia_payroll 
WHERE
	value_type_code = '5958'
	AND payroll_year  = 2018;
-- 5958	Průměrná hrubá mzda na zaměstnance je 32485.087500000000 Kč
-- round na 32485.09

-- Potraviny (chleba a mléko)

-- Chleba a mléko
SELECT
	ROUND(AVG(CASE
		WHEN category_code = 111301 THEN value END)::NUMERIC, 2)
		AS avg_bread_price_2018,
	ROUND(AVG(CASE
		WHEN category_code = 114201 THEN value END)::NUMERIC, 2)
		AS avg_milk_price_2018
FROM
	data_academy_content.czechia_price
WHERE
	EXTRACT(YEAR FROM date_from) = 2018
	AND region_code IS NULL;

-- prumerna_cena_chleba_2018 je 24.238500000000013 Kč za kg
-- round na 24.24
-- prumerna_cena_mleka_2018 je 19.817555555555558 Kč za litr
-- round na 19.82

-- Kolik čeho se mohlo koupit? -> Kupní síla 2018
WITH prices AS (
  SELECT 
    AVG(value) FILTER (WHERE category_code = 111301)::numeric AS bread_price,
    AVG(value) FILTER (WHERE category_code = 114201)::numeric AS milk_price
  FROM data_academy_content.czechia_price
  WHERE EXTRACT(YEAR FROM date_from) = 2018
    AND region_code IS NULL
), salary AS (
  SELECT AVG(value)::numeric AS avg_salary
  FROM data_academy_content.czechia_payroll
  WHERE value_type_code = 5958
    AND calculation_code = 100
    AND payroll_year = 2018
)
SELECT
  ROUND(s.avg_salary / p.bread_price,  2) AS bread_kg_2018,
  ROUND(s.avg_salary / p.milk_price,   2) AS milk_l_2018
FROM salary s CROSS JOIN prices p;
-- Mohlo se koupit 
-- bread_kg_2018	1317.38	kg
-- milk_l_2018		1611.12 litrů

-- Test spojení payrolly x ceny pro tabulku moje_jednoducha_tabulka
DROP TABLE IF EXISTS public.moje_jednoducha_tabulka;
CREATE TABLE public.moje_jednoducha_tabulka AS
SELECT
	p.payroll_year,
	p.industry_branch_code,
	AVG(p.value)	AS avg_salary,
	pr.category_code,
	AVG(pr.value)	AS avg_price
FROM data_academy_content.czechia_payroll p
JOIN data_academy_content.czechia_price pr
	ON p.payroll_year = EXTRACT(YEAR FROM pr.date_from)
WHERE p.value_type_code = 5958
	AND p.calculation_code = 100
	AND p.payroll_year = 2018
	AND pr.region_code IS NULL
GROUP BY
	p.payroll_year,
	p.industry_branch_code,
	pr.category_code
LIMIT 100;

-- Mrknu
SELECT *
FROM public.moje_jednoducha_tabulka;

-- Ještě test_tabulka_vsechny_roky
DROP TABLE IF EXISTS public.test_tabulka_vsechny_roky;
CREATE TABLE public.test_tabulka_vsechny_roky AS
SELECT
  payroll_year,
  industry_branch_code,
  AVG(value) AS avg_salary
FROM data_academy_content.czechia_payroll
WHERE value_type_code = 5958
  AND calculation_code = 100
  AND payroll_year BETWEEN 2006 AND 2018
GROUP BY payroll_year, industry_branch_code;

-- Mrknu
SELECT *
FROM public.test_tabulka_vsechny_roky
ORDER BY avg_salary DESC
LIMIT 10;

-- A pro všechny roky období a odvětví
SELECT 
	MIN(payroll_year)	AS first_year,
	MAX(payroll_year)	AS end_year,
	COUNT(DISTINCT(industry_branch_code)) AS branch_count
FROM public.test_tabulka_vsechny_roky;
-- 2006 až	2018 jsou data z 19 odvětví

--

---------------------------------------------------------	

-- Tady bude secondary:
/*				 
	 #####                                                         
	#     # ######  ####   ####  #    # #####    ##   #####  #   # 
	#       #      #    # #    # ##   # #    #  #  #  #    #  # #  
	 #####  #####  #      #    # # #  # #    # #    # #    #   #   
 	      # #      #      #    # #  # # #    # ###### #####    #     'TABLE'
          # #      #      #    # #    # #   ## #    # #    #   #   
	######  ######  ####   ####  #    # #####  #    # #    #   #   
				                                                              
*/				 
---------------------------------------------------------				 			 

-- === PRŮZKUM SEKUNDÁRNÍCH DAT ===

-- Seznam zemí
SELECT
	DISTINCT country
	FROM data_academy_content.economies
	ORDER BY country;
-- 266 zemí

-- Záznamy v tom časovém rozmezí (2006-2018)
SELECT
	country,
	COUNT(*) AS record_count,
	MIN("year") AS first_year,
	MAX("year") AS last_year
FROM
	data_academy_content.economies
WHERE YEAR BETWEEN 2006 AND 2018
	AND gdp IS NOT NULL
GROUP BY country
ORDER BY country;
-- 254 zemí

--Evropské země
--S kompletními daty
SELECT
  e.country,
  MIN(e.year) AS first_year,
  MAX(e.year) AS last_year
FROM data_academy_content.economies AS e
JOIN data_academy_content.countries AS c
  ON e.country = c.country
WHERE e.year BETWEEN 2006 AND 2018
  AND c.continent = 'Europe'
GROUP BY e.country
ORDER BY e.country;
-- 45 záznamů - kompletní záznamy

-- HDP (GDP)
SELECT
	DISTINCT e.country,
	e.gdp,
	e.gini,
	e.year
FROM data_academy_content.economies AS e
WHERE e.country = 'Czech%'
	AND e.year BETWEEN 2006 AND 2018
	AND e.gini IS NOT NULL
	AND e.gdp IS NOT NULL
ORDER BY e.gdp DESC;

SELECT *
FROM v_european_economies;

SELECT *
FROM data_academy_content.economies;

------------------------------------------------------------
-- (ne)zajímavé statistiky :-)
SELECT *
FROM data_academy_content.czechia_payroll
LIMIT 10;

SELECT *
FROM czechia_price_category;

SELECT *
FROM czechia_price;

SELECT region_code, value, date_from 
FROM data_academy_content.czechia_price
WHERE date_from <= DATE '2007-12-31' 
  AND date_to >= DATE '2007-01-01'
ORDER BY region_code;
-- Celá ČR je 15. .. NULL

-- Chleba a mlíko s kódy
SELECT code, name, price_value, price_unit
FROM data_academy_content.czechia_price_category
WHERE name ILIKE LOWER('%chléb%') OR name ILIKE LOWER('%mléko%')
ORDER BY code;

SELECT code, name FROM data_academy_content.czechia_payroll_calculation;


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

SELECT * FROM countries;



