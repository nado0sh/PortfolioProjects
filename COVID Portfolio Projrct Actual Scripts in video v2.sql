SELECT location, date, total_cases, new_cases, total_deaths, population
FROM MyPortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
order By 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS float)/total_cases)*100 AS DeathPercentage
FROM MyPortfolioProject..CovidDeaths$
WHERE location LIKE '%states%' and continent IS NOT NULL
order By 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, total_deaths, population, 
       (total_cases/population)*100 AS PercentPopulationInfect
FROM MyPortfolioProject..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
order By 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCountry, 
       MAX((total_cases/population))*100 as PercentPopulationInfect
FROM MyPortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
order By PercentPopulationInfect desc

-- Showing the Countries with Highest Death Count per Population

SELECT location, MAX(CAST( total_deaths as int)) AS TotalDeathCount
FROM MyPortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
order By TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST( total_deaths as int)) AS TotalDeathCount
FROM MyPortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
order By TotalDeathCount desc


-- Showing the Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM MyPortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

 -- Global Numbers
 
SELECT SUM(new_cases) AS NewCases, SUM(CAST(new_deaths AS int)) AS NewDeaths --, total_cases, total_deaths
       , (SUM(new_deaths)/SUM(NULLIF(new_cases,0)))*100 AS DeathPercentage
FROM MyPortfolioProject..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
order By 1, 2


 -- Looking at Total Population  Vaccinations

--SELECT *
--FROM MyPortfolioProject..CovidDeaths$ D, MyPortfolioProject..CovidVaccinations$ V
--WHERE D.location = V.location AND D.date = V.date

--SELECT *
--FROM MyPortfolioProject..CovidDeaths$ Dea
--JOIN MyPortfolioProject..CovidVaccinations$ Vac
--ON Dea.location = Vac.location AND Dea.date = Vac.date

--SELECT Dea.continent, Dea.location , Dea.date, Dea.population, Vac.new_vaccinations
--       , SUM(Vac.new_vaccinations) OVER (PARTITION BY Dea.Location) 
--FROM MyPortfolioProject..CovidDeaths$ Dea
--JOIN MyPortfolioProject..CovidVaccinations$ Vac
--ON Dea.location = Vac.location AND Dea.date = Vac.date
--ORDER BY 1,2,3

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
       , SUM(CONVERT(bigint, ISNULL(Vac.new_vaccinations, 0))) OVER 
	     (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.date desc) AS RollingPeopleVaccinated 
       --, (RollingPeopleVaccinated/Dea.population)*100
FROM MyPortfolioProject..CovidDeaths$ Dea
JOIN MyPortfolioProject..CovidVaccinations$ Vac
ON Dea.location = Vac.location AND Dea.date = Vac.date
where Dea.continent is not null 
ORDER BY 1,2,3

--USE CTE
WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
       , SUM(CONVERT(bigint, ISNULL(Vac.new_vaccinations, 0))) OVER 
	     (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.date) AS RollingPeopleVaccinated 
       --, (RollingPeopleVaccinated/Dea.population)*100
FROM MyPortfolioProject..CovidDeaths$ Dea
JOIN MyPortfolioProject..CovidVaccinations$ Vac
ON Dea.location = Vac.location AND Dea.date = Vac.date
where Dea.continent is not null 
--ORDER BY 1,2,3
)

SELECT * , (RollingPeopleVaccinated/population)*100 
FROM POPvsVAC

 -- Temp Table

 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
       , SUM(CONVERT(bigint, ISNULL(Vac.new_vaccinations, 0))) OVER 
	     (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.date) AS RollingPeopleVaccinated 
       --, (RollingPeopleVaccinated/Dea.population)*100
 FROM MyPortfolioProject..CovidDeaths$ Dea
 JOIN MyPortfolioProject..CovidVaccinations$ Vac
 ON Dea.location = Vac.location AND Dea.date = Vac.date
 where Dea.continent is not null 
 --ORDER BY 1,2,3
  
SELECT * , (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


 -- Creating View to STore Data for Later Visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
       , SUM(CONVERT(bigint, ISNULL(Vac.new_vaccinations, 0))) OVER 
	     (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.date) AS RollingPeopleVaccinated 
     --, (RollingPeopleVaccinated/Dea.population)*100
FROM MyPortfolioProject..CovidDeaths$ Dea
JOIN MyPortfolioProject..CovidVaccinations$ Vac
ON Dea.location = Vac.location AND Dea.date = Vac.date
where Dea.continent is not null 
--ORDER BY 1,2,3

-- check if the view is listed in the database:
SELECT *
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME = 'PercentPopulationVaccinated'


SELECT *
FROM PercentPopulationVaccinated







