---
title: sql-project-engeto
---
Přehled mých projektů je ne webu: https://ivaneklumberjack888.github.io/#projects

# 📊 Analýza vlivu HDP na mzdy a ceny potravin v ČR (2006–2018)

<div align="center">

![SQL Badge](https://img.shields.io/badge/SQL-PostgreSQL-blue?style=for-the-badge&logo=postgresql)
![Data Analysis](https://img.shields.io/badge/Data-Analysis-orange?style=for-the-badge&logo=chart.js)
![ENGETO](https://img.shields.io/badge/ENGETO-Project-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

</div>

---

## 🚀 Projekt (🪄)

> 'vtípek, to takhle kouzlíte, kouzlíte a najednou vykouzlíte projekt |black_rumour|'

Tento projekt vznikl jako součást **ENGETO kurzu: Datová analýza s Pythonem** a představuje komplexní analýzu ekonomických vztahů v České republice za období 2006–2018.

Řeší se v něm několik otázek
---

## 🎯 Motivace & koncept

Žijeme v dynamickém světě, kde růst ekonomiky (HDP) neprobíhá izolovaně. Zajímalo mě, jak se ekonomický růst promítá do:
- 💰 **Průměrných mezd** napříč odvětvími
- 🍞 **Cen základních potravin** (chleba, mléko)
- ⏰ **Časového zpoždění** těchto efektů

---

## 🗂️ Struktura repozitáře

sql-projekt-engeto/
├── .gitignore
├── README.md
├── config/
│   └── connection.properties
├── docs/
│   ├── 00_ERD.png
│   ├── 01_project_directory.png
│   ├── 02_project_structure.txt
│   └── 03_research_questions.md
└── scripts/
    ├── 01_exploration/
    │   └── 00_data_exploration.sql
    ├── 02_views/
    │   └── 01_views.sql
    ├── 03_tables/
    │   ├── 02_primary_table.sql
    │   └── 03_secondary_table.sql
    ├── 04_questions/
    │   ├── 04_q_1.sql
    │   ├── 05_q_2.sql
    │   ├── 06_q_3.sql
    │   ├── 07_q_4.sql
    │   └── 08_q_5.sql
    └── 05_validation/
        └── 09_data_validation.sql

---

## 🔧 Technické řešení

### Použité SQL techniky
- 🔄 **CTE (Common Table Expressions)** pro strukturovaný kód
- 📊 **Window Functions** (`LAG`, `LEAD`) pro časové analýzy
- 🔗 **Víceúrovňové JOINy** pro propojení dat z více zdrojů
- 📈 **Agregační funkce** pro výpočty průměrů a trendů
- ✅ **Validační skripty** pro kontrolu kvality dat

### Datasetové zdroje
- **czechiapayroll**: Průměrné hrubé mzdy v ČR (kód typu 5958)
- **czechiaprice**: Ceny vybraných potravin (chléb, který v dnešní uspěchané době občas upeču a mléko, které si občas dávám do kávy 😉)
- **economies** & **countries**: Makrodata HDP, GINI, populace pro Evropu
- **..others**

---

## 📈 Klíčové výsledky

### 💼 1) Růst mezd napříč všemi odvětvími
Veškerá odvětví zaznamenala **pozitivní meziroční nárůst** průměrné mzdy v ČR v období 2006–2018. Nejsilněji rostly mzdy v sektoru financí a IT, nejméně pak v odvětví veřejné správy.

### 🛒 2) Kupní síla domácností – mléko a chleba
| Rok  | Prům. mzda (CZK) | Cena chleba (kg) | Cena mléka (l) | kg chleba na mzdu | l mléka na mzdu |
|------|------------------|------------------|----------------|-------------------|-----------------|
| 2006 | 20 342,38        | 16,12            | 14,44          | **1 261,9**       | **1 408,8**     |
| 2018 | 31 980,26        | 24,24            | 19,82          | **1 319,3**       | **1 613,5**     |

> 📊 **Závěr:** Za 12 let se kupní síla mírně zlepšila – zatímco mzdy vzrostly o **57%**, ceny chleba a mléka vzrostly o **50%** resp. **37%**.

### 🍯 3) Nejpomalejší růst cen – cukr krystalový
Mezi sledovanými kategoriemi potravin rostly **nejpomaleji ceny krystalového cukru** – dokonce v několika letech mírně klesaly díky stálé dostupnosti a domácí produkci.

### 📊 4) Vztah HDP vs. mzdy vs. ceny
| Rok  | HDP (%) | Mzdy (%) | Ceny (%) | Interpretace |
|------|---------|----------|----------|--------------|
| 2007 | +5,57   | +6,79    | +6,76    | 🔥 Silný růst všech ukazatelů |
| 2008 | +2,69   | +8,06    | +6,18    | 💪 Mzdy rostly rychleji než HDP |
| 2009 | -4,66   | +3,25    | -6,41    | 📉 Krizový rok – HDP klesl, mzdy stagnace |
| 2010 | +2,43   | +2,00    | +1,94    | 🔄 Postupné zotavování |
| 2011 | +1,76   | +2,27    | +3,35    | ⚖️ Stabilní růst s mírnou inflací |

---

## 🧠 Analytické poznatky

### ✅ **Potvrzené hypotézy:**
1. **Pozitivní korelace HDP-mzdy**: V letech vysokého růstu HDP (2007, 2008) rostly i mzdy nadprůměrně
2. **Rychlejší reakce mezd**: Mzdy reagují o trochu lépe na výkyvy HDP, než ceny potravin
3. **Asymetrické reakce**: Mzdy reagují rychleji na pozitivní změny HDP, než na negativní

### 🔍 **Zajímavá zjištění:**
- **Krize 2009**: Pokles HDP o 4,66% se projevil jen mírnou korekcí cen (-6,41%), zatímco mzdy stále rostly (+3,25%)
- **Časové zpoždění**: Ceny potravin mají tendenci "setrvávat" díky regulačním mechanismům
- **Stabilita potravin**: Většina kategorií rostla rovnoměrně 1–7% ročně bez extrémních výkyvů

---

## 🚀 Jak spustit analýzu

### Předpoklady
```bash
# Potřebné nástroje
- PostgreSQL 12+
- Přístup k ENGETO databázi
- DBeaver / pgAdmin / psql
```

### Postup spuštění
```sql
-- 1. Nastavení schema
SET search_path TO data_academy_content;

-- 2. Vytvoření pohledů
\i sql/01_views.sql

-- 3. Spuštění hlavní analýzy
\i sql/g_5.sql

-- 4. Validace výsledků
\i sql/validation.sql
```

---

## 💡 Možná rozšíření

- 🗺️ **Regionální analýza** podle krajů ČR
- 🏭 **Sektorová analýza** podle odvětví ekonomiky
- 📅 **Rozšíření časové řady** o roky 2019–2024
- 📊 **Interaktivní dashboard** v Power BI/Tableau
- 🤖 **Machine Learning modely** pro predikci trendů

---

## 📚 Použitá literatura & zdroje

- [ENGETO Data Academy](https://engeto.cz/)
- [PostgreSQL Window Functions Documentation](https://www.postgresql.org/docs/current/tutorial-window.html)

---

## 👨‍💻 O autorovi

**Ivo Doležal* 
- 🐙 GitHub: [@ivaneklumberjack888](https://github.com/ivaneklumberjack888)
- 💼 LinkedIn: [ivodolezal888](https://linkedin.com/in/ivan-eklum)
- 📧 Email: ivousd@gmail.com
- 🎓 ENGETO Data analyst with Python, tímto uvádím lektory, kteří se mnou spolupracovali nocí a ránem. Rád bych jim poděkoval za spolupráci. Děkuji Pavle H., Matoušovi a Matoušovi, Jirkovi, Honzovi a Honzovi, Davidovi Příhodovi xD a všem ostatním. Díky.
Nejvíc samozřejmě manželce. 🥰

> *"Data jsou nová ropa, ale pouze pokud je dokážeme správně zpracovat a interpretovat."*

---

## 📜 Licence

Tento projekt je licencován pod **Apache** – viz [LICENSE.md](LICENSE.md) pro detaily.

---

<div align="center">

### ⭐ Pokud se vám projekt líbí, dejte hvězdičku!

![GitHub stars](https://img.shields.io/github/stars/ivaneklumberjack888/ENGETO-SQL-Project?style=social)

**Vytvořeno s ❤️ pro ENGETO. Váš SQL Project**

</div>
