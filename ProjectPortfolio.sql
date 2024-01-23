select * 
from PortfolioProject..CovidDeaths$
where continent is not null

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4



-- Select data that we're going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null


-- Looking at Total cases vs Total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage

from PortfolioProject..CovidDeaths$
where location like '%arab%'
and continent is not null


-- Looking at total cases vs Population
-- shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%united arab%'


-- Looking at Countries with highest Infection Rate compared to Population

select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%united arab%'
Group by location, population
order by PercentPopulationInfected desc



-- showing the highest death counts between two or more countries.
-- comparing two or more countries


select location, MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths$
--where location like '%united arab%'
where location in ('Pakistan','India')
Group by location 
order by TotalDeathCounts desc

-- Showing the countries with highest death counts making sure that continents are skipped but using not null statement.

select location, MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths$
--where location like '%united arab%'
where continent is not null
Group by location 
order by TotalDeathCounts desc


--Showing the continents with highest death counts by selecting continents where it'll not show the overall world death count.

select continent, MAX(cast(total_deaths as int)) as TotalDeathCountsForContinents
from PortfolioProject..CovidDeaths$
--where location like '%united arab%'
where continent is not null
Group by continent 
order by TotalDeathCountsForContinents desc

--Showing the continents with highest death counts by selecting continents

select location, MAX(cast(total_deaths as int)) as TotalDeathCountsForContinents
from PortfolioProject..CovidDeaths$
--where location like '%united arab%'
where continent is null
Group by location 
order by TotalDeathCountsForContinents desc


-- showing death counts for continents per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCountsForContinents
from PortfolioProject..CovidDeaths$
--where location like '%united arab%'
where continent is not null
Group by continent
order by TotalDeathCountsForContinents desc


-- showing total death count in the world
--GLOBAL NUMBERS

select location, population, MAX(cast(total_deaths as int)) as TotalDeathCountsForContinents
from PortfolioProject..CovidDeaths$
--where location like '%united arab%'
where location = 'World'
Group by location,population 
order by TotalDeathCountsForContinents desc


-- Now included the vaccination table, combined them by location and date. 
-- Looking at total population vs total vaccinations each day and adding them up.

select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidVaccinations$	 vacc 
join PortfolioProject..CovidDeaths$ 	dea
  on dea.location = vacc.location
  and dea.date = vacc.date

where dea.continent is not null
and dea.population is not null
and vacc.new_vaccinations is not null
order by 2,3


-- Also looking at people vaccinated in percentage using CTE.
--USE CTE

with PopvsVacc (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidVaccinations$	 vacc 
join PortfolioProject..CovidDeaths$ 	dea
  on dea.location = vacc.location
  and dea.date = vacc.date

where dea.continent is not null
--and dea.population is not null
--and vacc.new_vaccinations is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccCount
from PopvsVacc
order by 1,2,3




-- TEMP TABLE

Drop table if exists #PecentPopulationVaccinated

CREATE TABLE #PecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PecentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidVaccinations$	 vacc 
join PortfolioProject..CovidDeaths$ 	dea
  on dea.location = vacc.location
  and dea.date = vacc.date

where dea.continent is not null
--and dea.population is not null
--and vacc.new_vaccinations is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccCount
from #PecentPopulationVaccinated
order by 1,2,3

-- Creating View to store data for later Visualizations

create view PecentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidVaccinations$	 vacc 
join PortfolioProject..CovidDeaths$ 	dea
  on dea.location = vacc.location
  and dea.date = vacc.date

where dea.continent is not null
--and dea.population is not null
--and vacc.new_vaccinations is not null
--order by 2,3


-- Creating View by Location(USA) only.

create view PercentagePopulationVaccinatedinUSA as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidVaccinations$	 vacc 
join PortfolioProject..CovidDeaths$ 	dea
  on dea.location = vacc.location
  and dea.date = vacc.date

where dea.continent is not null
and dea.location like 'UNITED STATES'
--and dea.population is not null
--and vacc.new_vaccinations is not null
--order by 2,3


select * 
from PercentagePopulationVaccinatedinUSA