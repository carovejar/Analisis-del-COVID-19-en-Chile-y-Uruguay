-----------------------------------------------------------------------------------------------------------------
--           ANÁLISIS EXPLORATORIO DE CONTAGIOS Y MUERTES A CAUSA DEL CORONAVIRUS EN CHILE Y URUGUAY
-----------------------------------------------------------------------------------------------------------------

-- 1. Vista general de la tabla CasesDeathsHosp

SELECT TOP 1000 *
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp
ORDER BY location, date

-- 2. Selección de las columnas que se van a utilizar para analizar el Covid-19 en Chile y Uruguay

SELECT location, date, population,stringency_index, total_cases, new_cases, ISNULL (total_deaths,0) as total_deaths,
ISNULL (new_deaths,0) as new_deaths, ISNULL (icu_patients,0) as icu_patients, ISNULL (hosp_patients,0) as hosp_patients
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp
WHERE location = 'Chile' OR location = 'Uruguay'
ORDER BY location, date

-- 3. Creación de una vista con las columnas que se van a utilizar y filtrando los datos para Chile y Uruguay

CREATE VIEW CasesDeathsHosp_CH_UY AS
SELECT location, date, population,stringency_index, total_cases, new_cases, ISNULL (total_deaths,0) as total_deaths,
ISNULL (new_deaths,0) as new_deaths, ISNULL (icu_patients,0) as icu_patients, ISNULL (hosp_patients,0) as hosp_patients
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp
WHERE location = 'Chile' OR location = 'Uruguay'

-- 4. Porcentaje de muertes con respesto al total de casos

SELECT location, date, total_cases, ISNULL (total_deaths,0) as total_deaths, ISNULL ((total_deaths/total_cases) *100,0) as death_pct
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp_CH_UY
ORDER BY location, date

-- 5. Porcentaje de casos y muertes respecto al total de la población

SELECT location, date, total_cases, ISNULL (total_deaths,0) as total_deaths, population, ISNULL (total_deaths*100/population,0) as total_deaths_pct, 
ISNULL (total_cases*100/population,0) as total_cases_pct
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp_CH_UY
ORDER BY location, date

-- 6. Total de casos, nuevos casos, nuevas muertes y total de muertes por cada millón de habitantes

SELECT location, date, 
total_cases*1000000/population as total_cases_per_million, new_cases*1000000/population as new_cases_per_million,
ISNULL (new_deaths*1000000/population,0) as new_deaths_per_million,
ISNULL (total_deaths *1000000/population, 0) as total_deaths_per_million
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp_CH_UY
ORDER BY location, date


-- 7. Número máximo de nuevos casos que alcanzó cada país por millón de habitantes y como porcentaje de la pablación

SELECT D.location, date, new_cases, new_cases*1000000/population as new_cases_per_million, new_cases*100/population as new_cases_pct
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp as D
RIGHT JOIN 
(SELECT location, max (new_cases) as max_new_cases
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp
GROUP BY location
HAVING location = 'Chile' OR location = 'Uruguay') as M
ON D.new_cases = M.max_new_cases AND D.location = M.location
ORDER BY location, date

-- 8. Número máximo de muertes en un día que alcanzó cada país por millón de habitantes y como porcentaje de la pablación

SELECT D.location, date, new_deaths, new_deaths*1000000/population as new_deaths_per_million, 
		new_deaths*100/population as new_deaths_pct
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp as D
RIGHT JOIN 
(SELECT location, max (new_deaths) as max_new_deaths
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp
GROUP BY location
HAVING location = 'Chile' OR location = 'Uruguay') as M
ON D.new_deaths = M.max_new_deaths AND D.location = M.location
ORDER BY location, date

-- 9. Total de casos y muertes, al último día registrado al momento de realizar el estudio, por millón de habitantes y 
--como porcentaje de la población

SELECT D.location, date, total_cases as max_total_cases, total_deaths as max_total_deaths,
		total_cases*100/population as total_cases_pct,
		total_deaths*100/population as total_deaths_pct,
		total_cases*1000000/population as max_total_cases_per_million,
		total_deaths*1000000/population as max_total_deaths_per_million
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp as D
RIGHT JOIN (SELECT  location, MAX (date) as max_date
			FROM PortfolioProjectCovid.dbo.CasesDeathsHosp 
			WHERE location = 'Chile' OR location = 'Uruguay'
			GROUP BY location) as M
ON D.date = M.max_date AND D.location = M.location
ORDER BY location, date

-- 10. Otra forma de calcular lo anterior, pero sin mostrar la fecha

SELECT location, population, MAX (total_deaths) as max_total_deaths, MAX (total_cases) as max_total_cases,
		MAX (total_cases_per_million) as max_total_cases_per_million,
		MAX (total_deaths_per_million) as max_total_deaths_per_million,
		MAX (total_cases)*100/population as max_total_cases_pct
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp
WHERE location = 'Chile' OR location = 'Uruguay'
GROUP BY location, population
ORDER BY max_total_cases_pct desc

-- 11. Porcentaje de la población que se ha contagiado y porcentaje de la población que ha muerto

SELECT location, date, total_cases*100/population as total_cases_pct, ISNULL (total_deaths*100/population,0) as total_deaths_pct
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp_CH_UY
ORDER BY location, date

-- 12. Índice de rigor

SELECT location, date, stringency_index, AVG (stringency_index) OVER (PARTITION BY location) as AVG_stringency_index
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp_CH_UY
ORDER BY location, date

-- 13. Cantidad de personas que se encuentran hospitalizadas y cantidad de personas que se encuentran en la unidad de cuidados intensivos
-- En esta consulta se puede observar que la base de datos de Our World in Data no cuenta con los datos relativos a hospitalizaciones
-- tanto para Chile como para Uruguay

SELECT location, date, icu_patients,hosp_patients
FROM PortfolioProjectCovid.dbo.CasesDeathsHosp_CH_UY
ORDER BY location, date


-----------------------------------------------------------------------------------------------------------------
--      ANÁLISIS EXPLORATORIO DE TEST Y VACUNACIONES REALIZADAS CONTRA EL CORONAVIRUS EN CHILE Y URUGUAY
-----------------------------------------------------------------------------------------------------------------

-- 1. Vista general de la tabla CasesDeathsHosp

SELECT TOP 1000 *
FROM PortfolioProjectCovid.dbo.TestVaccinations
ORDER BY location, date

-- 2. Vista de las columnas que se van a utilizar para analizar el Covid-19 en Chile y Uruguay

SELECT location, date, new_tests, total_tests, positive_rate, total_vaccinations, people_vaccinated,
		people_fully_vaccinated, total_boosters, new_vaccinations
FROM PortfolioProjectCovid.dbo.TestVaccinations
WHERE location = 'Chile' OR location = 'Uruguay'
ORDER BY location, date

-- 3. Creación de una vista con las columnas a utilizar y filtrando los datos para Chile y Uruguay

CREATE VIEW TestVaccinations_CH_UY AS
SELECT location, date, new_tests, total_tests, positive_rate, total_vaccinations, people_vaccinated,
		people_fully_vaccinated, total_boosters, new_vaccinations
FROM PortfolioProjectCovid.dbo.TestVaccinations
WHERE location = 'Chile' OR location = 'Uruguay'

-- 4. Cantidad de nuevos test y total de test realizados por cada mil de habitantes

SELECT T.location, T.date, new_tests, total_tests, CAST (new_tests AS numeric)*1000/population as new_test_per_thousand,
		CAST (total_tests AS numeric)*1000/population as total_tests_per_thousand
FROM PortfolioProjectCovid.dbo.TestVaccinations as T
JOIN PortfolioProjectCovid.dbo.CasesDeathsHosp as C
ON T.location = C.location AND T.date = C.date
WHERE T.location = 'Chile' OR T.location = 'Uruguay'
ORDER BY location, date

-- 5. Positividad de los tests

SELECT location, date, positive_rate, AVG (positive_rate) OVER (PARTITION BY location) AS avg_positive_rate
FROM PortfolioProjectCovid.dbo.TestVaccinations_CH_UY
ORDER BY location, date

-- 6. Total de vacunaciones realizadas, cantidad de personas vacunadas, cantidad de personas vacunadas con las dos dosis,
-- total de vacunaciones realizadas luego de la segunda dosis y número de nuevas vacunaciones realizadas por cada mil habitantes

SELECT T.location, T.date, total_vaccinations*1000/population AS total_vaccinations_per_thosand, 
		people_vaccinated *1000/population AS people_vaccinated_per_thosand, 
		people_fully_vaccinated*1000/population AS people_fully_vaccinated_per_thosand,
		total_boosters*1000/population AS total_boosters_per_thosand,
		new_vaccinations*1000/population AS new_vaccinations_per_thosand
FROM PortfolioProjectCovid.dbo.TestVaccinations AS T
JOIN PortfolioProjectCovid.dbo.CasesDeathsHosp AS C
ON T.location = C.location AND T.date = C.date
WHERE T.location = 'Chile' OR T.location = 'Uruguay'
ORDER BY T.location, T.date

-- 7. Porcentaje de la población que se encuentra vacunada

SELECT T.location, T.date, people_vaccinated*100/population AS people_vaccinated_pct, 
		people_fully_vaccinated*100/population AS people_fully_vaccinated_pct
FROM PortfolioProjectCovid.dbo.TestVaccinations AS T
JOIN PortfolioProjectCovid.dbo.CasesDeathsHosp AS C
ON T.location = C.location AND T.date = C.date
WHERE T.location = 'Chile' OR T.location = 'Uruguay'
ORDER BY T.location, T.date

-- 8. Porcentaje de la población que se ha colocado una tercera dosis con respecto al total de la población
-- y al total de personas vacunadas

SELECT T.location, T.date, total_boosters, total_boosters*100/population AS total_boosters_pct, 
		total_boosters*100/CAST (people_vaccinated AS numeric) AS total_boosters_pct_vacc
FROM PortfolioProjectCovid.dbo.TestVaccinations AS T
JOIN PortfolioProjectCovid.dbo.CasesDeathsHosp AS C
ON T.location = C.location AND T.date = C.date
WHERE T.location = 'Chile' OR T.location = 'Uruguay'
ORDER BY T.location, T.date

-- 9. Tasa de vacunación promedio

SELECT T.location, AVG (new_vaccinations*100/population) AS new_vaccinations_avg
FROM PortfolioProjectCovid.dbo.TestVaccinations AS T
JOIN PortfolioProjectCovid.dbo.CasesDeathsHosp AS C
ON T.location = C.location AND T.date = C.date
WHERE T.location = 'Chile' OR T.location = 'Uruguay'
GROUP BY T.location
ORDER BY T.location