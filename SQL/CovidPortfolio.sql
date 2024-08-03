-- select data

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at Total case vs Total Deaths
-- Shows likelihood of dying if you contract covid in US

select 
location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPerc
from CovidDeaths
where location like '%states%'


-- Looking at Total Cases vs Pouplation 
-- Shows what percentage of population got covid in US

select 
location, date, total_cases, population, (total_cases / population) * 100 as CasePercByPop
from CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

-- Looking at Countries Highest Infection Rate compared to Population

select 
location, population, max(total_cases) as HighestInfectionCount,
max((total_cases / population)) * 100 as CasePercByPop
from CovidDeaths
group by location, population
order by CasePercByPop desc

-- Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select date, sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths, sum(cast(new_deaths as int)) / sum(new_cases) *100 as DeathPerc
from CovidDeaths
where continent is not null
group by date
order by 1,2


-- Looking at total population vs Vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as NewVacPerDay
from CovidDeaths dea
Join CovidVaccination vac 
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
order by 2,3




-- use cte 

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, NewVacPerDay)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as NewVacPerDay
from CovidDeaths dea
Join CovidVaccination vac 
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (NewVacPerDay / Population) * 100 from PopvsVac


-- temp table 
drop table if exists #PercentPopulationVac
create table #PercentPopulationVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
NewVacPerDay numeric)
insert into #PercentPopulationVac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as NewVacPerDay
from CovidDeaths dea
Join CovidVaccination vac 
	on dea.location = vac.location and
	dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (NewVacPerDay / Population) * 100 from #PercentPopulationVac


-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as NewVacPerDay
from CovidDeaths dea
Join CovidVaccination vac 
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
-- order by 2,3
