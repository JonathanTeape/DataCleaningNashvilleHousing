select *
from PortfolioProject..CovidDeaths
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows liklihood of dying if You contract Covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as Death_Percentage 
from PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percetnage got Covid
Select Location, date,Population, total_cases, (total_cases/population)*100 as InfectedPopulation
from PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2

--Looking at Countries with highest infection rate compared to population
Select Location,Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulation
from PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Group By Location,Population
order by InfectedPopulation desc

--Showing Countries with the Highest Death Count per Population
Select Location,Population,MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 as Deaths
from PortfolioProject..CovidDeaths
where continent is not null
Group By Location,Population
order by HighestDeathCount desc


----Showing the contients with the highest Death Count ***come back and fix***
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group By continent
order by TotalDeathCount desc

---Global Covid Deaths Per Day
Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group By Date
order by 1,2

---Global Covid Deaths 
Select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group By Date
--order by 1,2


--Looking at Total Population Vs Vaccination *******
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

-- Rolling Count of Total Vaccinations
--USE CTE
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


--TEMP TABLE

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