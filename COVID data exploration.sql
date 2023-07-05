
Select *
From Project01..CovidDeaths
--Where continent is not null
order by 3,4

--Select *
--From Project01..CovidVaccinations
--order by 3,4


--Selecting Data

Select Location, date, total_cases,  new_cases, total_deaths, population
From Project01..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project01..CovidDeaths
order by 1,2

---- Show likelihood of dying at specific covid contacted country
--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From Project01..CovidDeaths
--Where location like '%India%'
--order by 1,2


-- Total Cases vs Population

Select Location, date, population, total_cases, (total_deaths/population)*100 as PercentPopultaionInfected
From Project01..CovidDeaths
Where location like '%India%'
order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopultaionInfected
From Project01..CovidDeaths
Group by Location, Population
order by PercentPopultaionInfected desc


-- Looking for countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCountCount
From Project01..CovidDeaths
Where continent is not null
Group by Location
order by  TotalDeathCountCount desc 


-- Continents with Highest Death Count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCountCount
From Project01..CovidDeaths
Where continent is not null
Group by continent
order by  TotalDeathCountCount desc 


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From Project01..CovidDeaths
Where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From Project01..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccination

Select *
From Project01..CovidDeaths dea
Join Project01..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by 
  dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From Project01..CovidDeaths dea
Join Project01..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
order by 2, 3


 -- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by 
  dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From Project01..CovidDeaths dea
Join Project01..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
 )

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by 
  dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From Project01..CovidDeaths dea
Join Project01..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for visualization

Create View PercentPopulationVaccianated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by 
  dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From Project01..CovidDeaths dea
Join Project01..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccianated

