SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs Total deaths
-- Shows the likelihood of dying if you contract COVID in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs Population
-- Shows percentage of population that got COVID
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Countries with highest infection rate per population
SELECT Location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectionRate DESC

-- Countries with highest death count per population
SELECT Location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population))*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY DeathRate DESC

-- Highest death counts (total), excluding world and continents
SELECT Location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Highest total death counts by continent
SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- GLOBAL NUMBERS

-- Total global new cases and deaths day by day
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Grand total global death rate
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- JOIN THE TABLES

-- Total Pop vs Vaccs

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RunningVaccs
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- CTE to create our RunningVaccs calc
WITH PopvsVac (continent, location, date, population, new_vaccinations, RunningVaccs)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RunningVaccs
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RunningVaccs/population)*100
FROM PopvsVac

-- Temp Table to create our RunningVaccs calc

CREATE TABLE #PercentPopVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccincations numeric,
RunningVaccs numeric
)

INSERT INTO #PercentPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RunningVaccs
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RunningVaccs/population)*100
FROM #PercentPopVacc

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopVacc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RunningVaccs
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL