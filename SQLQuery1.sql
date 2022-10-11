select *
from CovidDeaths
where continent is not Null
order by 3,4


select Location, date, total_cases,new_cases,total_deaths, population
from CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths (The likelihood of dying)
select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location ='United States'
order by 1,2

--Looking at the Total Cases vs Population (Show the percentage of population got COVID)
select Location, date, total_cases,population,(total_cases/population)*100 as COVIDPercentage
from CovidDeaths
where location ='United States'
order by 1,2

--What countries has the Highest Infection Rate compared to the Population?
select Location, population, max(total_cases) As HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
group by Location, population
order by PercentPopulationInfected desc

--Breaking things down by continent
--Show the continents with the highest death count per population
select continent,  max(cast(total_deaths as int)) As TotalDeathCount
from CovidDeaths
where continent is not Null
group by Continent
order by TotalDeathCount desc

--What countries has the Highest Death Count per Population?
select Location,  max(cast(total_deaths as int)) As TotalDeathCount
from CovidDeaths
where continent is not Null
group by Location
order by TotalDeathCount desc


--Global Numbers
select  date, sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

select  sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--Joining CovidDeaths and CovidVaccinations Tables
select *
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date


--Looking at Total Population vs Vaccinations
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac(Continent,Location, Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as (
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated


select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later Visualization

Create View PercentPopulationVaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null