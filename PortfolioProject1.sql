select * from PortfolioProject..CovidDeaths order by 3, 4
select * from PortfolioProject..CovidVaccinations order by 3, 4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths 
order by 1, 2

--Looking at total_cases vs total_deaths in India
--Shows likelihood of dying if you contract Covid
select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths 
where location = 'India'
order by 1, 2

--Looking at total_cases vs population 
--Shows what percentage of population got Covid
select Location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
from PortfolioProject..CovidDeaths 
where location = 'India'
order by 1, 2

--Looking at countries with highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population)*100) AS InfectionRate
from PortfolioProject..CovidDeaths 
group by Location, population
order by InfectionRate desc

--Showing the countries with highest death counts per population
select Location, population, max(cast(total_deaths as int)) as HighestDeaths
from PortfolioProject..CovidDeaths 
group by location, population
order by HighestDeaths desc

--Since the table returned has the Location of some records as International, Europe, North America, etc which are continents, we now add a WHERE clause to remove the 
--uncertainity in result
select Location, population, max(cast(total_deaths as int)) as HighestDeaths
from PortfolioProject..CovidDeaths 
where continent is not NULL
group by location, population
order by HighestDeaths desc

--Showing Death Counts by Continent
select continent, max(cast(total_deaths as int)) as HighestDeaths
from PortfolioProject..CovidDeaths 
where continent is not NULL
group by continent
order by HighestDeaths desc

--Global Numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not NULL

--Looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.Location = vac.Location
  and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Also add one more column to show percentage of people vaccinated to above query. We can use CTE or Temp Tables or this

--Use CTE
With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.Location = vac.Location
  and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/Population*100) from PopvsVac 

--Using Temp Table

DROP TABLE IF EXISTS #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
continent nvarchar(100),
Location nvarchar(100),
date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.Location = vac.Location
  and dea.date = vac.date
where dea.continent is not null

select * , (RollingPeopleVaccinated/Population*100) from #PercentPeopleVaccinated

--Create Views to store data for later visualizations

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.Location = vac.Location
  and dea.date = vac.date
where dea.continent is not null

Select * from PercentPeopleVaccinated