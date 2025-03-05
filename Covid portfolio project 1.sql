--select *
--From PortfolioProject1..CovidDeaths
--Where continent is not NUll
--Order by 3, 4

--select *
--From PortfolioProject1..CovidVaccinations
--Order by 3, 4

-- select data that we are going to be using
select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
From PortfolioProject1..CovidDeaths
Where continent is not NUll
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%states%'
and continent is not NUll
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select 
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
order by 1, 2

-- Looking at countries with Highestt Infection Rate compared to Population
select 
	location,
	population,
	MAX(total_cases) As HighestInfectionCount,
	MAX(total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death count per Population
select 
	location,
	MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not NUll
group by location
order by TotalDeathCount desc


-- Let's break things down bt continent

-- showing continents with the highest deaths count per population
select 
	continent,
	MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not NUll
group by continent
order by TotalDeathCount desc

-- Global numbers
select 
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not NUll
--Group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations
select 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) 
		over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
	from PortfolioProject1..CovidDeaths dea
		join PortfolioProject1..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date =  vac.date
	where dea.continent is not null
	order by 2, 3

--use CTE
With Popvsvac  (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
	select 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) 
		over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
	from PortfolioProject1..CovidDeaths dea
		join PortfolioProject1..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date =  vac.date
	where dea.continent is not null
	--order by 2, 3
)

select *,(RollingPeopleVaccinated/population)*100
from Popvsvac

-- temp table

Drop Table if exists #PercentPopulationVaccinated
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
select 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) 
		over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
	from PortfolioProject1..CovidDeaths dea
		join PortfolioProject1..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date =  vac.date
	--where dea.continent is not null
	--order by 2, 3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
	join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
--order by 2, 3


select *
from PercentPopulationVaccinated