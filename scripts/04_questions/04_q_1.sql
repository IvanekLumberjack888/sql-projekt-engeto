-- QUESTION 1
---------------------------------------------------------
-- Otázka 1: Rostou mzdy ve všech odvětvích?
-- PAYROLL TRENDS IN CZECHIA (2006-2018)
---------------------------------------------------------
-- Použité vjůčko v_annuall_sumarry
WITH extremes AS (
	SELECT
		industry_branch_code,
		industry_name,
		MIN(payroll_year) AS first_year,
		MAX(payroll_year) AS last_year
	FROM
		data_academy_content.v_annual_payroll_summary
	GROUP BY
		industry_branch_code,
		industry_name
),
comparison AS (
	SELECT
		e.industry_branch_code,
		e.industry_name,
		f.avg_payroll AS first_payroll,
		l.avg_payroll AS last_payroll
	FROM
		extremes AS e
	JOIN data_academy_content.v_annual_payroll_summary f
		ON
		f.industry_branch_code = e.industry_branch_code
		AND f.payroll_year = e.first_year
	JOIN data_academy_content.v_annual_payroll_summary l
	   	 ON
		l.industry_branch_code = e.industry_branch_code
		AND l.payroll_year = e.last_year
)
SELECT
	industry_name,
	ROUND(first_payroll, 2) AS payroll_first_year,
	-- Mzda v r. 2006
	ROUND(last_payroll, 2) AS payroll_last_year,
	-- Mzda v r. 2018
	ROUND(last_payroll - first_payroll, 2) AS absolute_change,
	-- Změna
	ROUND((last_payroll - first_payroll) / first_payroll * 100, 2) AS
		percent_change,
	-- Změna v %
	CASE
		WHEN last_payroll > first_payroll THEN 'MZDY ROSTOU'
		WHEN last_payroll < first_payroll THEN 'MZDY KLESAJÍ'
		ELSE 'MZDY JSOU STEJNÉ'
	END AS trend
	-- POjmenovaný sloupec
FROM
	comparison
ORDER BY
	percent_change DESC;
