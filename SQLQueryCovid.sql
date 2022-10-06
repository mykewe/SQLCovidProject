--SELECT * FROM dbo.CovidDeaths
--ORDER BY 3, 4;

--SELECT * FROM dbo.CovidVaccinations
--ORDER BY 3, 4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

---Total Cases vs Total Deaths
--Shows likelihood of death if one gets covid 
SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths*100.0/total_cases),2) AS death_percentage
FROM dbo.CovidDeaths
WHERE Location='United Kingdom'
AND continent IS NOT NULL
ORDER BY 1, 2;


---Total Cases vs Population
--Shows what percentage of population got covid
SELECT Location, date,  population, total_cases,(total_cases*100.0/population) AS covid_percentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;
 
 --Countries with Highest Infection Rate compared to population
SELECT Location,  population, MAX(total_cases) AS HigestInfectionCount,MAX(total_cases*1.0/population)*100 AS PopulationInfectedPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location,  population
ORDER BY PopulationInfectedPercentage DESC;


---Countries with the highest death count 
SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

---Continents with the highest death count 
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Total cases and deaths each day globally
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 100.0*SUM(new_deaths)/SUM(new_cases) AS DeathPercentages
FROM  dbo.CovidDeaths
WHERE continent IS NOT NULL
AND new_cases IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Total cases and deaths so far globally
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 100.0*SUM(new_deaths)/SUM(new_cases) AS DeathPercentages
FROM  dbo.CovidDeaths
WHERE continent IS NOT NULL
AND new_cases IS NOT NULL;

------Vaccinations data------
SELECT TOP 50 * FROM dbo.CovidVaccinations;

------Total population vs vaccination
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.Location ORDER BY d.Location, d.date) AS RollingVaccinations
FROM dbo.CovidDeaths AS d
JOIN dbo.CovidVaccinations AS v
ON d.Location = v.Location
AND d.date = v.date
WHERE d.continent IS NOT NULL
AND v.new_vaccinations IS NOT NULL
ORDER BY 2, 3;


WITH PopulationVaccinated AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.Location ORDER BY d.Location, d.date) AS RollingVaccinations
FROM dbo.CovidDeaths AS d
JOIN dbo.CovidVaccinations AS v
ON d.Location = v.Location
AND d.date = v.date
WHERE d.continent IS NOT NULL
AND v.new_vaccinations IS NOT NULL

)

SELECT continent, location, population, new_vaccinations, RollingVaccinations, 
100.0*RollingVaccinations/population AS RollingVaccinationPercentage
FROM PopulationVaccinated
GO
---Create views

 --Countries with Highest Infection Rate compared to population
CREATE OR ALTER VIEW PopulationInfectionRate AS
WITH PopulationVaccinated AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.Location ORDER BY d.Location, d.date) AS RollingVaccinations
FROM dbo.CovidDeaths AS d
JOIN dbo.CovidVaccinations AS v
ON d.Location = v.Location
AND d.date = v.date
WHERE d.continent IS NOT NULL
AND v.new_vaccinations IS NOT NULL
)
SELECT continent, location, population, new_vaccinations, RollingVaccinations, 
100.0*RollingVaccinations/population AS RollingVaccinationPercentage
FROM PopulationVaccinated
GO

---Countries with the highest death count 
CREATE OR ALTER VIEW CountriesDeathCount AS
SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
GO

---Continents with the highest death count 
CREATE OR ALTER VIEW ContinentDeathCount AS
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
GO
 
--Total cases and deaths each day globally
CREATE OR ALTER VIEW TotalCasesDeath AS
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 100.0*SUM(new_deaths)/SUM(new_cases) AS DeathPercentages
FROM  dbo.CovidDeaths
WHERE continent IS NOT NULL
AND new_cases IS NOT NULL
GROUP BY date
GO

CREATE OR ALTER VIEW PopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.Location ORDER BY d.Location, d.date) AS RollingVaccinations
FROM dbo.CovidDeaths AS d
JOIN dbo.CovidVaccinations AS v
ON d.Location = v.Location
AND d.date = v.date
WHERE d.continent IS NOT NULL
AND v.new_vaccinations IS NOT NULL;

