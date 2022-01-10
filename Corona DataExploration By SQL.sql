/* COVID DATA */


--1.Showing CovidDeath table --
SELECT * FROM PortFolioProject..CovidDeaths
ORDER BY 3,4;

--2. Showing Covidvaccinations table-- 
SELECT * FROM PortFolioProject..CovidVaccinations
order by 3,4;

--3.select data we are using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortFolioProject.dbo.CovidDeaths
order by 1,2;

--4.looking deathpercent in India
select location,date,total_cases,new_cases,total_deaths,population,(total_deaths/total_cases)*100 as deathpercent 
from PortFolioProject.dbo.CovidDeaths
where location in ('United States')
order by (total_deaths/total_cases)*100 desc ;


--5.looking at totalcases vs population
select location,sum(total_cases) as TotalCases,sum(population) as TotalPopulation,Round((sum(total_cases)/sum(population))*100,2) as Covidpercent 
from PortFolioProject.dbo.CovidDeaths
where  location not in ('World','High income','Upper middle income') 
group by location
order by TotalCases desc;

--6.Looking at Countries with highest infection rate compared to population

select location,Population,max(total_cases) as HighestInfectionCount, Round(Max(total_cases/population)*100,2)as PercentPopulationInfected 
from PortFolioProject.dbo.CovidDeaths
group by location,Population
order by PercentPopulationInfected desc;

--7.Countries with Total Infection rate per Population and Death Per Population
select continent, Round(Sum(total_cases/population *100),2) as "Cases Per Population",
Round(Sum(cast(total_deaths as int)/population)*100,2) as "Death Per Population"
from PortFolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by "Cases Per Population" desc;

--8.	Total Population Vs People Fully Vaccinated
select d.location,Sum(d.population) as Total_population,sum(cast(v.[total_vaccinations] as float))as TotalVaccination,
sum(cast(v.[people_fully_vaccinated] as float)) as PeopleVaccinated 
from PortFolioProject.dbo.CovidDeaths d
join PortFolioProject.dbo.CovidVaccinations v
on d.continent = v.continent
and d.date = v.date
where d.location is not null
group by d.location
order by d.location,PeopleVaccinated desc;

-- 9. Using Partition by 
select d.continent,d.location,d.date, d.population,v.new_vaccinations,
SUM(CONVERT(float,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortFolioProject.dbo.CovidDeaths d
join PortFolioProject.dbo.CovidVaccinations v 
on d.location =v.location
and d.date = v.date
where d.continent is not null
order by 2,3;

-- --CTE

With POPvsVAC (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as
(
select d.continent,d.location,d.date, d.population,v.new_vaccinations,
SUM(CONVERT(float,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortFolioProject.dbo.CovidDeaths d
join PortFolioProject.dbo.CovidVaccinations v 
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
select *,Round((RollingPeopleVaccinated/Population)*100,2) as RollingPeopleVaccinatedPerPopulation from  POPvsVAC


-- Temp table 
Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date Datetime,
Population float,
New_vaccination float,
RollingPeopleVaccinated float
)

Insert into #PercentPopulationVaccinated
select d.continent,d.location,d.date, d.population,v.new_vaccinations,
SUM(CONVERT(float,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortFolioProject.dbo.CovidDeaths d
join PortFolioProject.dbo.CovidVaccinations v 
on d.location = v.location
and d.date = v.date
--where d.continent is not null

select *,Round((RollingPeopleVaccinated/Population)*100,2) as RollingPeopleVaccinatedPerPopulation from  #PercentPopulationVaccinated


-- Creating View for Later Visualization

Create view PercentPopualtionVacciantedView as
select d.continent,d.location,d.date, d.population,v.new_vaccinations,
SUM(CONVERT(float,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortFolioProject.dbo.CovidDeaths d
join PortFolioProject.dbo.CovidVaccinations v 
on d.location = v.location
and d.date = v.date
--where d.continent is not null

select * from [PortFolioProject].[dbo].[PercentPopualtionVacciantedView]