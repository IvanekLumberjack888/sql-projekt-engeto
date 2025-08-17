-- VALIDATION
-- -------------------------------------------------------------------------
-- 05_validation_tests.sql
-- Validační dotazy - kontrolujeme kvalitu a konzistenci dat
-- -------------------------------------------------------------------------

-- Validace 1: Kontrola úplnosti dat
/* kontrolujeme, zda máme data za celou cílovou periodu 2006-2018.
 * Můžeme k tomu použít jednodušší agregační funkce MIN a MAX pro roky,
 * což je rychlejší a přehlednější než složitější CASE podmínky.
 */
SELECT 
    '1. Úplnost dat v primární tabulce' AS test_name,
    COUNT(*) AS total_records,
    MIN(payroll_year) AS first_year,
    MAX(payroll_year) AS last_year,
    COUNT(DISTINCT payroll_year) AS unique_years,
    COUNT(DISTINCT industry_branch_code) AS unique_industries,
    COUNT(DISTINCT food_category_code) AS unique_food_categories
FROM data_academy_content.t_ivo_dolezal_project_sql_primary_final;

---

-- Validace 2: Kontrola NULL hodnot
/* Testujeme všechny klíčové sloupce na NULL hodnoty, protože
 * NULL v jakémkoliv z nich může způsobit chybu nebo nesprávný výpočet.
 * Místo jedné celkové podmínky ukážeme počet NULLů v každém sloupci,
 * což dává jasnější obrázek o tom, kde je problém.
 */
SELECT 
    '2. Kontrola NULL hodnot' AS test_name,
    SUM(CASE WHEN payroll_value IS NULL THEN 1 ELSE 0 END) AS null_payroll,
    SUM(CASE WHEN food_price IS NULL THEN 1 ELSE 0 END) AS null_food_price,
    SUM(CASE WHEN industry_name IS NULL THEN 1 ELSE 0 END) AS null_industry,
    SUM(CASE WHEN food_category_name IS NULL THEN 1 ELSE 0 END) AS null_food_category
FROM data_academy_content.t_ivo_dolezal_project_sql_primary_final;

---

-- Validace 3: Kontrola extrémních hodnot (nuly a záporná čísla)
-- Zaměřujeme se na to, že mzdy i ceny by měly být striktně větší než nula, protože nulové nebo záporné hodnoty nedávají ekonomicky smysl. Zároveň se podíváme na minimální a maximální hodnoty, abychom měli přehled o rozsahu dat.]
SELECT 
    '3. Kontrola extrémních hodnot' AS test_name,
    MIN(payroll_value) AS min_payroll_value,
    MAX(payroll_value) AS max_payroll_value,
    MIN(food_price) AS min_food_price,
    MAX(food_price) AS max_food_price,
    SUM(CASE WHEN payroll_value <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_payroll_count,
    SUM(CASE WHEN food_price <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_price_count
FROM data_academy_content.t_ivo_dolezal_project_sql_primary_final;

---

-- Validace 4: Kontrola sekundární tabulky
-- Ověřujeme, zda sekundární tabulka obsahuje data za správné roky a zda se týká pouze České republiky, protože pracujeme s makroekonomickými daty pro ČR.]
SELECT 
    '4. Kontrola sekundární tabulky' AS test_name,
    COUNT(*) AS total_records,
    MIN(econ_year) AS first_year,
    MAX(econ_year) AS last_year,
    COUNT(DISTINCT country_name) AS unique_countries,
    CASE 
        WHEN MIN(econ_year) = 2006 AND MAX(econ_year) = 2018 THEN 'PASS'
        ELSE 'FAIL - chybí roky'
    END AS year_range_test,
    CASE 
        WHEN COUNT(DISTINCT country_name) = 1 THEN 'PASS'
        ELSE 'FAIL - více zemí'
    END AS country_test
FROM data_academy_content.t_ivo_dolezal_project_sql_secondary_final;

---

-- Validace 5: Kontrola propojení tabulek
-- [My ověřujeme, že každý rok v primární tabulce má odpovídající záznam v sekundární tabulce. Můžeme to udělat pomocí LEFT JOIN a počítáním, kolik let se propojilo.]
SELECT 
    '5. Kontrola propojení tabulek' AS test_name,
    COUNT(DISTINCT p.payroll_year) AS years_in_primary,
    COUNT(DISTINCT s.econ_year) AS years_in_secondary,
    COUNT(DISTINCT p.payroll_year) - COUNT(DISTINCT s.econ_year) AS year_diff
FROM data_academy_content.t_ivo_dolezal_project_sql_primary_final p
LEFT JOIN data_academy_content.t_ivo_dolezal_project_sql_secondary_final s
    ON p.payroll_year = s.econ_year;

---

-- Závěrečný validační report
-- [My vytváříme celkový report, který shrnuje stav všech validačních testů do jednoho přehledu. Můžeme to udělat s využitím subdotazů nebo CTE, což je čistější a elegantnější řešení než opakované SELECTy na stejnou tabulku.]
WITH validation_summary AS (
    SELECT
        COUNT(*) AS total_records,
        MIN(payroll_year) AS min_year,
        MAX(payroll_year) AS max_year,
        SUM(CASE WHEN payroll_value IS NULL THEN 1 ELSE 0 END) AS null_payroll,
        SUM(CASE WHEN food_price IS NULL THEN 1 ELSE 0 END) AS null_food_price,
        SUM(CASE WHEN payroll_value <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_payroll,
        SUM(CASE WHEN food_price <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_price
    FROM data_academy_content.t_ivo_dolezal_project_sql_primary_final
)
SELECT
    'Celkový validační report' AS test_name,
    CASE 
        WHEN min_year = 2006 AND max_year = 2018 AND total_records > 6000 THEN 'PASS'
        ELSE 'FAIL: Roky/počet záznamů'
    END AS completeness_status,
    CASE 
        WHEN null_payroll = 0 AND null_food_price = 0 THEN 'PASS'
        ELSE 'FAIL: NULL hodnoty'
    END AS null_status,
    CASE 
        WHEN zero_or_negative_payroll = 0 AND zero_or_negative_price = 0 THEN 'PASS'
        ELSE 'FAIL: Záporné/nulové hodnoty'
    END AS extreme_values_status,
    'Všechny testy v pořádku: ' || (
        CASE 
            WHEN min_year = 2006 AND max_year = 2018 AND total_records > 6000 
                 AND null_payroll = 0 AND null_food_price = 0 
                 AND zero_or_negative_payroll = 0 AND zero_or_negative_price = 0 
            THEN 'Ano' 
            ELSE 'Ne' 
        END
    ) AS final_verdict
FROM validation_summary;
