Select *
from PortfolioProj_SQL_Covid..CovidDeaths
order by 3,4

Select *
from PortfolioProj_SQL_Covid..CovidVaccinations
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProj_SQL_Covid..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if you contract in your country
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from PortfolioProj_SQL_Covid..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProj_SQL_Covid..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, max (total_cases) as HighestInfectionCount, max ((total_cases/population))*100 as MaxCovidPercentage
from PortfolioProj_SQL_Covid..CovidDeaths
Group By location, population
Order By MaxCovidPercentage desc

-- Looking at Countries with Highest Death Count
Select location, population, max (total_deaths) as HighestDeathCount
from PortfolioProj_SQL_Covid..CovidDeaths
where continent is not null
Group By location, population
Order By HighestDeathCount desc

-- Looking at Continents with Highest Death Count
Select location, max (total_deaths) as HighestDeathCount
from PortfolioProj_SQL_Covid..CovidDeaths
where continent is null
Group By location
Order By HighestDeathCount desc

-- GLOBAL NUMBERS
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProj_SQL_Covid..CovidDeaths
-- where location like '%states%'
where continent is not null
Group By date
order by 1,2

-- Total Populations vs Vaccinations
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(vaccine.new_vaccinations) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProj_SQL_Covid..CovidDeaths as death
Join PortfolioProj_SQL_Covid..CovidVaccinations as vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(vaccine.new_vaccinations) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProj_SQL_Covid..CovidDeaths as death
Join PortfolioProj_SQL_Covid..CovidVaccinations as vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(vaccine.new_vaccinations) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProj_SQL_Covid..CovidDeaths as death
Join PortfolioProj_SQL_Covid..CovidVaccinations as vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
Order by 2,3


--Create View to store data for later Visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(vaccine.new_vaccinations) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProj_SQL_Covid..CovidDeaths as death
Join PortfolioProj_SQL_Covid..CovidVaccinations as vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--Order by 2,3

Select *
from PercentPopulationVaccinated