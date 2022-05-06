-- VISUALIZATIONS


-- VIZ #1
-- Grand total global death rate
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- VIZ #2
-- Total death counts by country
SELECT location, SUM(cast(new_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- VIZ #3
-- Countries with highest infection rate per population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectionRate DESC


-- VIZ #4
-- Countries with highest daily infection rate per population
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY InfectionRate DESC