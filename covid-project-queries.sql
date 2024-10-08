Select * 
From SQLTutorial..CovidDeaths
Where continent is not null
Order by 3,4

Select 
  Location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
From SQLTutorial..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total cases vs Total Deaths

Select
   Location, 
   date, 
   total_cases, 
   total_deaths, 
   (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage 
From SQLTutorial..CovidDeaths
Where Location like '%states%'
Order by 1,2

--Looking at Total cases vs Population

Select 
  Location, 
  date, 
  Population, 
  total_cases, 
  (cast(total_cases as float)/cast(Population as float))*100 as PercentPopulationInfected
From SQLTutorial..CovidDeaths
Where Location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select 
  Location, 
  Population, 
  Max(total_cases) as HighestInfectionCount, 
  Max((cast(total_cases as float)/cast(Population as float)))*100 as PercentPopulationInfected
From SQLTutorial..CovidDeaths
--Where Location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc

--Showing Countires with Highest Death count per Population 

Select 
  Location, 
  Max(cast(Total_deaths as int)) as TotalDeathCount
From SQLTutorial..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Showing continents with highest death per population

Select 
  continent, 
  Max(cast(Total_deaths as int)) as TotalDeathCount
From SQLTutorial..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers 

Select 
  date, 
  SUM(new_cases) as total_cases,
  SUM(cast(new_deaths as float)) as total_deaths,
  SUM(cast(new_deaths as float)) / SUM(new_cases)*100 as DeathPercentage 
From SQLTutorial..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by date
Order by 1,2

--Total DeathPercetnage in the world

Select 
  SUM(new_cases) as total_cases,
  SUM(cast(new_deaths as float)) as total_deaths,
  SUM(cast(new_deaths as float)) / SUM(new_cases)*100 as DeathPercentage 
From SQLTutorial..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Order by 1,2

--Looking at Total Population and Vaccinations 
--This part is also using CovidVaccinations data

-- USE CTE 

With PopvsVac (continent, location, date, population, new_vaccincation, RollingPeopleVaccinated) 
As
(
Select 
  dea.continent,
  dea.location,
  dea.date,
  dea.population, 
  vac.new_vaccinations,
  SUM(Convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date)
    as RollingPeopleVaccinated
From SQLTutorial..CovidDeaths dea
Join SQLTutorial..CovidVaccinations vac 
    On dea.location = vac.location
    And dea.date = vac.date 
Where dea.continent is not null
)
Select *,
  (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    contient nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select 
  dea.continent,
  dea.location,
  dea.date,
  dea.population, 
  vac.new_vaccinations,
  SUM(Convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date)
    as RollingPeopleVaccinated
From SQLTutorial..CovidDeaths dea
Join SQLTutorial..CovidVaccinations vac 
    On dea.location = vac.location
    And dea.date = vac.date 
Where dea.continent is not null

Select *,
  (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later Visualizations 

GO

Create View PercentPopulationVaccinated as
Select 
  dea.continent,
  dea.location,
  dea.date,
  dea.population, 
  vac.new_vaccinations,
  SUM(Convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date)
    as RollingPeopleVaccinated
From SQLTutorial..CovidDeaths dea
Join SQLTutorial..CovidVaccinations vac 
    On dea.location = vac.location
    And dea.date = vac.date 
Where dea.continent is not null
