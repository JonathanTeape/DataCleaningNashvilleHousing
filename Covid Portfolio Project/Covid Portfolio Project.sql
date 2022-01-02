--Shows all Covid related information
select *
from PortfolioProject..CovidDeaths
order by 3,4

--Breaks down Data by Location, date, total cases, new cases, total death and population
Select Location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows Death percentage 
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as Death_Percentage 
from PortfolioProject..CovidDeaths
Where location like '%Canada%' -- Location can be specified
order by 1,2

--Looking at Total Cases vs Population
--Shows what Percentage of population got Covid
Select Location, date,Population, total_cases, (total_cases/population)*100 as InfectedPopulation
from PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2

--Total Death Count by Continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
and location not in ('World','European Union','International', 'Upper Middle income', 'High income', 'Lower middle income', 'low income') -- removed extra locations which was unnecessary in data 
Group by location 
Order by TotalDeathCount desc

--Showing the continents with the highest Death Count ***
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group By continent
order by TotalDeathCount desc

--Looking at Countries with highest infection rate compared to population
Select Location,Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulation
from PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Group By Location,Population
order by InfectedPopulation desc

--Looking at Countries with highest infection rate compared to population
Select Location,Population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Group By Location,Population,date
order by PercentPopulationInfected desc

--Showing Countries with the Highest Death Count per Population
Select Location,Population,MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group By Location,Population
order by HighestDeathCount desc

--Global Covid deaths Per Day
Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group By Date
order by 1,2

--Global Covid Deaths as of December 4th
Select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group By Date
--order by 1,2


--Looking at Total Population Vs Total Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null --and dea.location like '%canada%'
order by 2,3

-- Rolling Count of Total Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalRollingVaccinations
From PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Rolling Count of Total Vaccinations With CTE
With PopvsVac (Continent, location, date,population, new_vaccinations, TotalRollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalRollingVaccinations --(TotalVaccinations/Population)*100
From PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, (TotalRollingVaccinations/Population)*100 as Percentage_Population_Vaccinated
From PopvsVac


--Table Creation with Percentage of Population Vaccinated 
DROP TABLE If exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccincations numeric,
TotalRollingVaccinations numeric,
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalRollingVaccinations --(TotalVaccinations/Population)*100
From PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (TotalRollingVaccinations/Population)*100 As Pecentage_of_population_vaccinated 
From #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualutions
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalRollingVaccinations --(TotalVaccinations/Population)*100
From PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3