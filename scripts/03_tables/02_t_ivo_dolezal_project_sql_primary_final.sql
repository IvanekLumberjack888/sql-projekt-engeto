-- PRIMARY TABLE
---------------------------------------------------------
-- 02_t_ivo_dolezal_project_sql_primary_final.sql
-- Primární tabulka se mzdami a cenami potravin
---------------------------------------------------------


DROP TABLE IF EXISTS
	data_academy_content.t_ivo_dolezal_project_sql_primary_final;

CREATE TABLE data_academy_content.t_ivo_dolezal_project_sql_primary_final AS
SELECT
	payroll_year,
	industry_branch_code,
	industry_name,
	avg_payroll AS payroll_value,
	food_category_code,
	food_category_name,
	avg_price AS food_price
FROM
	data_academy_content.v_payroll_price_joined
ORDER BY
	payroll_year,
	industry_branch_code,
	food_category_code;
-- Kontrola, jestli je ta tabulka OK
SELECT
	COUNT(*) AS total_records,
	MIN(payroll_year) AS first_year,
	MAX(payroll_year) AS last_year,
	COUNT(DISTINCT industry_branch_code) AS industries_count,
	COUNT(DISTINCT food_category_code) AS food_categories_count
FROM
	data_academy_content.t_ivo_dolezal_project_sql_primary_final;

