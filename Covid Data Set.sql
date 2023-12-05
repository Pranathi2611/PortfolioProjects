Select *
From [Portfolio Projects]..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From [Portfolio Projects]..CovidVaccination$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Projects]..CovidDeaths
where continent is not null
order by 1,2

--for totalcases vs deaths in your country
Select location, date, total_cases, total_deaths,(cast(total_deaths as float)/cast (total_cases as float))*100 as DeathPercent
From [Portfolio Projects]..CovidDeaths
where location like '%India%'
order by 1,2

--for totalcases vs population
Select location, date,population, total_cases,(cast(total_cases as float)/cast ( population as float))*100 as CasePercent
From [Portfolio Projects]..CovidDeaths
where location like '%India%'
where continent is not null
order by 1,2

-- Countries with highest infestation rate
Select location,population, MAX(total_cases) as MaxCases,MAX((cast(total_cases as float)/cast ( population as float))*100) as MaxCasePercent
From [Portfolio Projects]..CovidDeaths
--where location like '%India%'
where continent is not null
group by location, population
order by MaxCasePercent desc

--Countries with highest death percent
Select location, MAX(cast(total_deaths as int)) as MaxDeaths
From [Portfolio Projects]..CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by MaxDeaths desc

--breaking things down by continent
-- this is correct
Select location, MAX(cast(total_deaths as int)) as MaxDeaths
From [Portfolio Projects]..CovidDeaths
--where location like '%India%'
where continent is null
group by location
order by MaxDeaths desc


Select continent, MAX(cast(total_deaths as int)) as MaxDeaths
From [Portfolio Projects]..CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by MaxDeaths desc


--Global numbers

Select date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths,(SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 as DeathPercent
from [Portfolio Projects]..CovidDeaths
where continent is not null
group by date
order by date


--now we join the vaccination table also 
--total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
 as TotalVaccinationsTillThatDay
from [Portfolio Projects]..CovidDeaths dea 
join [Portfolio Projects]..CovidVaccination vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--using cte to calculate vaccination percent per population coz we cant use TotalVaccinationsTillThatDay
--the cte popsvac should have same number of column names as the column names inside cte)
with PopvsVac(Continent, Location, Date, Population, New_vaccinations, TotalVaccinationsTillThatDay)
 as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
 as TotalVaccinationsTillThatDay
from [Portfolio Projects]..CovidDeaths dea 
join [Portfolio Projects]..CovidVaccination vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (TotalVaccinationsTillThatDay/Population)*100 as VacPercent
from PopvsVac



--Using temp table
Drop table if exists #PercentPopVacc
Create Table #PercentPopVacc
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacc numeric,
TotalVaccinationsTillThatDay numeric,
)

Insert into #PercentPopVacc
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
 as TotalVaccinationsTillThatDay
from [Portfolio Projects]..CovidDeaths dea 
join [Portfolio Projects]..CovidVaccination vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select*, (TotalVaccinationsTillThatDay/Population)*100 as VacPercent
from #PercentPopVacc


-- to create view of data for future visualisation

CREATE VIEW PercentPopVacci as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
 as TotalVaccinationsTillThatDay
from [Portfolio Projects]..CovidDeaths dea 
join [Portfolio Projects]..CovidVaccination vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
--order by is not used in create view


select*
from PercentPopVacci
