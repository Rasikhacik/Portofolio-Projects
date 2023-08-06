select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortofolioProject..CovidVaccinations
--order by 3,4

-- select Data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortofolioProject..CovidDeaths
order by 1,2

-- shows likelihood of dying if you contract covid in 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortofolioProject..CovidDeaths
where location like '%indonesia%'
order by 1,2

-- looking at total_cases vs population got covid in indonesia
select Location, date, population, total_cases,  (total_cases/population)*100 as Got_Covid
from PortofolioProject..CovidDeaths
where location like '%indonesia%'
order by 1,2

-- looking at countries with highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Got_Covid
from PortofolioProject..CovidDeaths
--where location like '%indonesia%'
group by Location, population
order by Got_Covid desc

-- showing countries with highest death count per population
select Location, max(cast(total_deaths as bigint)) as Total_DeathCount
from PortofolioProject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by Location
order by Total_DeathCount desc

-- showing continents with highest death count per population
select continent, max(cast(total_deaths as bigint)) as Total_DeathCount
from PortofolioProject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by Total_DeathCount desc

-- showing death percentage across the world per day
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_death, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as Death_Percentage
from PortofolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccinations
with PopulationVSVaccinated (continent, location, date, population, new_vaccinateions, Rolling_PeopleVaccinated)
as
(
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dth.location order by dth.location, dth.date) as Rolling_PeopleVaccinated
from PortofolioProject..CovidDeaths dth
join PortofolioProject..CovidVaccinations vac
on dth.location = vac.location
and dth.date = vac.date
where dth.continent is not null
--order by 2,3
) select *, (Rolling_PeopleVaccinated/Population)*100 as Rolling_VaccinationPercentage_PerLocation
from PopulationVSVaccinated

-- temp table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dth
join PortofolioProject..CovidVaccinations vac
on dth.location = vac.location
and dth.date = vac.date
--where dth.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as Rolling_VaccinationPercentage_PerLocation
from #PercentPopulationVaccinated

-- creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dth
join PortofolioProject..CovidVaccinations vac
on dth.location = vac.location
and dth.date = vac.date
where dth.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated