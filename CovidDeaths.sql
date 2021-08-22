--select * 
--from PortfolioProject..CovidDeaths
--order by 3,4


--select * 
--from PortfolioProject..CovidVax
--order by 3,4

--Selecting data for project purpose

select location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where population is not null
order by 1,2

--Total cases vs total deaths
--Death probability if you contract covid in your country

select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 

--Calculating total cases vs population
--Calculationg population % with covid

select location, date,population,total_cases,(total_cases/population)*100 as PopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%' and population is not null
order by 1,2 

--Countries with high infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PopulationInfected
from PortfolioProject..CovidDeaths
where population is not null
group by location,population
order by PopulationInfected desc

--Countries with high death count

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where population is not null
where continent is not null
group by location
order by TotalDeathCount desc

--Continentwise cases

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where population is not null
where continent is not null
group by continent
order by TotalDeathCount desc

--Continents with High death count

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where population is not null
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 

--Joining of CovidDeaths and CovidVax tables
--Total Population vs Vaccinations
--CTE

with PopvsVax (continent,location,date,population,new_vaccinations,CumulativeVaccinations)
as
(
select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations
,sum(convert(int,vax.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
and dea.population is not null
--order by 2,3 
)

select * ,(CumulativeVaccinations/population)*100 as CumVaxPercent
from PopvsVax



--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeVaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations
,sum(convert(int,vax.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
--where dea.continent is not null
where dea.population is not null
--order by 2,3 

select * ,(CumulativeVaccinations/population)*100 as CumVaxPercent
from #PercentPopulationVaccinated


--Creating View to store data for visualisations

create view PercentPopVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations
,sum(convert(int,vax.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
and dea.population is not null
--order by 2,3 

--Views dbo percentpopvacc
Select * 
from PercentPopulationVaccinated