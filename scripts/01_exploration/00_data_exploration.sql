-- ========================================
-- DATA EXPLORATION
-- ========================================
-- Tento soubor slouží pro průzkumné SQL dotazy při vývoji projektu.
-- Obsahuje ad-hoc analýzy a exploraci zdrojových dat.
-- Není součástí finálního řešení projektu.

-- Příklad: Základní přehled tabulky ekonomik
SELECT 
    country,
    YEAR,
    GDP,
    population
FROM economies
WHERE YEAR BETWEEN 2006 AND 2018
LIMIT 10;

-- Příklad: Kontrola dostupných dat pro ČR
SELECT *
FROM countries
WHERE country = 'Czech Republic';
