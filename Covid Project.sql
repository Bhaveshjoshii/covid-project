select *
from Covid..CovidDeaths$
where continent is not null
order by 3,4

Select *
from covid..CovidVaccinations$
order by 3,4

Select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, Population
from covid..CovidDeaths$
order by 1,2


-- looking at total cases vs total deaths
-- shows likelihood of dying if you contractcovid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid..CovidDeaths$
where location like '%India%'
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid

select location, date, population, total_cases,  (total_cases/population)*100 as Percentpopulationinfected
from covid..CovidDeaths$
where location like '%India%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as Percentpopulationinfected
from covid..CovidDeaths$
--where location like '%india%'
group by location, population
order by Percentpopulationinfected desc


--Showing Countries with highest death count per population

select location, max(cast(total_deaths as int)) as Totaldeathcount 
from covid..CovidDeaths$
--where location like '%india%'
where continent is not null
group by location
order by Totaldeathcount desc


--LET'S BREAK THINGS DOWN BY CONTINENT 
--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as Totaldeathcount 
from covid..CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent
order by Totaldeathcount desc


-- Global Numbers

select   sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as toatal_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from covid..CovidDeaths$
--where location like '%India%'
where continent is not null
--group by date
order by 1,2



--looking at total population vs vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths$ dea
Join Covid..CovidDeaths$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Temp Table

 drop table if exists #percentpopulationvaccinated
  
Create Table #percentpopulationvaccinated
(
continet nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert Into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths$ dea
Join Covid..CovidDeaths$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From  #percentpopulationvaccinated



-- Creating view to store data for later visualizations

create view precentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea. location,
dea.date) as Rollingpeoplevaccinated
--,(RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths$ dea
Join Covid..CovidDeaths$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from precentpopulationvaccinated