CREATE View PercentPopulationVaccinted AS 
SELECT dea.continent, dea.location,  dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT( float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage 
From PortfolioProjects..CovidDeaths
--WHERE [location] LIKE '%somalia%'
Where continent is NOT NULL
Order by 1, 2;

-- looking at countries with highest infection rare comapred to population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 as DeathPercentage 
From PortfolioProjects..CovidDeaths
Order by 1;


SELECT [location], MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
Where continent is NULL
GROUP By [location]
ORDER BY TotalDeathCount desc;

SELECT location, population,
MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population)) * 100 as DeathPercentage
From PortfolioProjects..CovidDeaths
GROUP by location, population
ORDER by HighestInfectionCount Desc;

select * FROM PortfolioProjects..CovidVaccinations;
select * FROM PortfolioProjects..CovidDeaths;


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent is not NULL
--GROUP BY [date]
order BY 1,2;


SELECT dea.continent, dea.location, dea.population, dea.[date], vac.new_vaccinations,
SUM(CONVERT( int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
order BY 2, 3;


-- USE CTE

With PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location,  dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT( float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
--order BY 2, 3
)

SELECT *,( RollingPeopleVaccinated/Population)*100 FROM PopvsVac;


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinted;
Create Table #PercentPopulationVaccinted(

Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC

)

iNSERT INTO #PercentPopulationVaccinted
SELECT dea.continent, dea.location,  dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT( float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not NULL
--order BY 2, 3

SELECT *,( RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinted;

--  Creating view to store data for later visualization
DROP TABLE IF EXISTS PercentPopulationVaccinted; 

--order BY 2, 3

SELECT * FROM PercentPopulationVaccinted