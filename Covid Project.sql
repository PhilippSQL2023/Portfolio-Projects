SELECT*
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER by 3,4

--SELECT*
--FROM [Portfolio Project]..CovidVaccinations
--ORDER by 3,4


SELECT Location, date, total_cases,new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying when you get infected with covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like 'Germany'
ORDER BY 1,2

-- Total Cases vs Population
-- Percentage of population being infected

SELECT Location, date, total_cases,population, (total_cases/population)*100 AS InfectedPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like 'Germany'
ORDER BY 1,2

-- Countries with highest infection rate compared to population

SELECT Location,population, MAX(total_cases) AS HighestInfectionCount, 
MAX(total_cases/population)*100 AS InfectedPercentage
FROM [Portfolio Project]..CovidDeaths
GROUP BY Location,population 
ORDER BY InfectedPercentage DESC

-- Countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location 
ORDER BY TotalDeathCount DESC

-- Let´s have a look at the numbers by continent

-- Contintents with the highest death count per population

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC



-- Global numbers
-- Total cases and total deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
WHERE continent is not null 
order by 1,2


-- Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY  
dea.location ORDER BY dea.location, dea.date)
AS accumulated_vaccinations
--, (accumulated_vaccinations/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Usage of CTE

WITH Popoulation_versus_Vaccinations (continent, location,date,population, new_vaccinations, accumulated_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY  
dea.location ORDER BY dea.location, dea.date)
AS accumulated_vaccinations
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT*, (accumulated_vaccinations/population)*100
FROM Popoulation_versus_Vaccinations


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
accumulated_vaccinations numeric
)

INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS accumulated_vaccinations
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (accumulated_vaccinations/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store date for visualizations

CREATE VIEW PercentPopulationVaccinated AS   
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS accumulated_vaccinations
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date



CREATE VIEW CountriesHighestDeathCount AS
SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location 

CREATE VIEW CountriesHighestInfectRatevsPopulation AS
SELECT Location,population, MAX(total_cases) AS HighestInfectionCount, 
MAX(total_cases/population)*100 AS InfectedPercentage
FROM [Portfolio Project]..CovidDeaths
GROUP BY Location,population 


CREATE VIEW TotalCasesVSTotalDeathsInGermany AS
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like 'Germany'