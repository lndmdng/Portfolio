SELECT *
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [SQL Covid Portfolio Project].dbo.CovidVaccinations$
--ORDER BY 3,4

--Selecting data that I will be using 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths (Displaying likelihood of death)

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths (Displaying likelihood of death) in US

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Total Cases vs Population in the World
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PopPercentage
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population in the US
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PopPercentage
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopPercentInfected
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PopPercentInfected desc



--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Info by Continent
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int )) as TotalDeaths, SUM(cast(new_deaths as int ))/SUM(New_Cases)*100 as DeathPercentage  --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int )) as TotalDeaths, SUM(cast(new_deaths as int ))/SUM(New_Cases)*100 as DeathPercentage  --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM [SQL Covid Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2 

--Looking at Total Population vs Vaccinations (new)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [SQL Covid Portfolio Project].DBO.CovidDeaths$ dea
JOIN [SQL Covid Portfolio Project].dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

--Looking at Total Population vs Vaccinations (new)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM [SQL Covid Portfolio Project].DBO.CovidDeaths$ dea
JOIN [SQL Covid Portfolio Project].dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM [SQL Covid Portfolio Project].DBO.CovidDeaths$ dea
JOIN [SQL Covid Portfolio Project].dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
FROM PopvsVac

--Temp Table

DROP TABLE IF exists #PercentpopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM [SQL Covid Portfolio Project].DBO.CovidDeaths$ dea
JOIN [SQL Covid Portfolio Project].dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM [SQL Covid Portfolio Project].DBO.CovidDeaths$ dea
JOIN [SQL Covid Portfolio Project].dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
