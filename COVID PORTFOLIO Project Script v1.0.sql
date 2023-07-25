Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2

----Check the data type of columns
SELECT COLUMN_NAME,DATA_TYPE
From INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths'


------Change the datatype 
--ALTER TABLE CovidDeaths
--ALTER COLUMN total_deaths nvarchar(255)

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_cases nvarchar(255)

--Looking at Population vs Total Deaths
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
--Where location like 'P%'
order by 1,2

--Looking at Countries with highes infection rate compared to populaiton
Select location, population,MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'P%'
group by location, population
order by PercentagePopulationInfected desc

--Looking at Countries with highest deathCount per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'P%'
Where continent is not null
group by location
order by TotalDeathCount desc

--Looking at Continents with highest deathCount per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
group by location
order by TotalDeathCount desc

--Total cases vs total deaths Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_Death,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--group by date
order by 1,2


--Join Two Tables

Select *
From CovidDeaths as dea
	Join CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date

--Total population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) over (Partition by dea.Location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table
DROP TABLE if EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) over (Partition by dea.Location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) over (Partition by dea.Location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated