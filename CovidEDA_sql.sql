-- covid deaths exploratory data analysis --

-- Column data working on--

select continent, location, date, population, total_cases, new_cases, total_deaths
from [Portfolio Project].dbo.CovidDeaths
where continent is not  null 
order by 2,3 ;

--Infromation about covid deaths--

--percentage of total deaths every day--

select  location, date, total_cases,  total_deaths, round((total_deaths/total_cases)*100, 4)  as total_deaths_percent
from [Portfolio Project].dbo.CovidDeaths
where continent is not null 
order by 1,2;


--Countries with maximum number of death count --

select location , sum(new_deaths) as Total_deaths_count FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
group by Location
order by Total_deaths_count  desc; 

-- Countries with Highest death Rate compared to total cases--

select location,population,max(total_cases) as total_cases, max(total_deaths) as Total_deaths_counts , (max (total_deaths)/max(total_cases))*100 as total_deaths_percent
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by location, population
order by total_deaths_percent desc; 

--Information about covid cases--

-- everyday percentage of total cases among population --

select  location,date, population, total_cases , round((total_cases/population)*100,4) as percent_of_infected_cases
from [Portfolio Project].dbo.CovidDeaths
order by 1,2; 

-- Countries with Highest Infection Rate compared to Population--

select location, population, max(total_cases) as Total_cases, (max(total_cases)/population)*100  as percent_of_infected_cases
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by location, population
order by 4 desc; 

--Country where maximum number of cases recorded --

select location,max(total_cases) as Total_cases_count
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by location
order by  Total_cases_count desc; 

--Information based on continent--

--continent with highest number of cases --

select continent,max(total_cases ) as Total_cases 
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by continent 
order by 2 desc;

--continent with highest number of deaths --

select continent,max(total_deaths ) as Total_deaths
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by continent 
order by 2 desc;

-- recorded cases by year --
-- shows which year recorded the highest no of cases--

select substring(date ,1,4)as year, sum(new_cases) as total_cases
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
--where location='india'--
group by substring(date ,1,4)
order by 2 desc;

 -- Death count by year--
 -- shows which year recorded the highest no of deaths--

select substring(date ,1,4)as year, sum(new_deaths) as total_deaths
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
--where location='india'--
group by substring(date ,1,4)
order by 2 desc;

--percentage of death by year--
--shows which year has highest deathcount relative to total cases--

Select substring(date,1,4) as year, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, round(SUM(new_deaths)/SUM(new_Cases)*100 ,2)as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By  substring(date,1,4)
order by 4 desc;

--Global Numbers--

select sum(new_cases)as Overall_cases, sum(new_deaths) as Overall_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null;

--COVID DEATHS AND COVID VACCINATIONS--

select * from [Portfolio Project].dbo.CovidVaccinations$;


--Rolling total of vaccinated people--

select dea.date,dea.continent, dea.location, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.CovidVaccinations$ as vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
order by dea.location, dea.date;

--percentage of rolling vaccinated people--

With PercVac as
(
select dea.date,dea.continent, dea.location, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.CovidVaccinations$ as vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 

)
select * , (RollingVaccinatedPeople/population)*100 as PercOfRollingTotal from PercVac
order by location, date

-- using Temp table for previous query --

drop table if exists #PercentPopulationVaccinated
create table  #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.CovidVaccinations$ as vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 

select * , (Rollingpeoplevaccinated/population)*100 as PercOfRollingTotal from #PercentPopulationVaccinated
order by location, date;

--create view to store data for later visualization--

use [Portfolio Project]
go 
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.CovidVaccinations$ as vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null ;


--Total population vs vaccinations by country --

select dea.location, dea.population, sum(vac.new_vaccinations) as VaccinatedPopulation,(sum(vac.new_vaccinations) /population)*100 as percenatgeofvaccinated
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.CovidVaccinations$ as vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
group by dea.location, dea.population
order by 1 ;

--yearly vaccination count--

select substring(dea.date,1,4) as year, sum(vac.new_vaccinations) as vaccinationCount
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.CovidVaccinations$ as vac 
on dea.location=vac.location and dea.date=vac.date
group by substring(dea.date,1,4)
order by 2 desc;



