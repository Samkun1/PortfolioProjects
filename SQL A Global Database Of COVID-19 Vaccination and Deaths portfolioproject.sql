select *
from PortfolioProject..CovidDeaths
order by 3,4 

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


--Select Data that we are goinng to be using

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2 


--Looking at total cases vs toal deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Deathpercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 


--Looking at total cases vs population
--Shows us what percentage of population got covid

select location, date, population, total_cases,  (total_cases/population) * 100 as PercentageofTotalCases
From PortfolioProject..CovidDeaths
--where location = 'India'
order by 1,2 


--Looking at the Countries with highest Infection rate

select location,  population,MAX (total_cases) as MaxTotalCases, MAX((total_cases/population)) * 100 as PercentageofTotalCases
From PortfolioProject..CovidDeaths
--where location = 'India'
Group by location, population
order by  PercentageofTotalCases Desc

--Showing the countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location = 'Bulgaria'
where continent is not null
Group by location, population
order by  location 

--Showing the continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location = 'Bulgaria'
where continent is not null
Group by continent 
order by  TotalDeathCount desc

--Globa Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)  * 100 as Deathpercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 

--Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RolllingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2, 3

--USING CTE

with Tpopvsvacc (continent, location, date, population, new_vaccinations, RolllingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RolllingPeopleVaccinated 
--(RolllingPeopleVaccinated/population) * 100 
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)
select *, (RolllingPeopleVaccinated/population) * 100 
from Tpopvsvacc

--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RolllingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RolllingPeopleVaccinated 
--(RolllingPeopleVaccinated/population) * 100 
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3

select *, (RolllingPeopleVaccinated/population) * 100 
from #PercentPopulationVaccinated


-- Creating view to store data for later visualization


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RolllingPeopleVaccinated 
--(RolllingPeopleVaccinated/population) * 100 
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3

select * from PercentPopulationVaccinated


