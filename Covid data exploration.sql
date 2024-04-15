
	 Select *
	 From [Covid Project]..CovidDeaths
	 order by 3,4

	 --Select *
	 --from [Covid Project] ..Covidvaccineation
	 --order by 3,4

	 -- Select data that we are using

	 select location, date, total_cases, new_cases, total_deaths, population 
	 from [Covid Project]..CovidDeaths
	 where continent is not null
	 order by 1,2

	 -- looking at total cases vs total deaths in india

	 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
	 from [Covid Project]..CovidDeaths
	 where location like 'india' and continent is not null
	 order by 1,2

	 -- looking at total cases vs the population

	 select location, date, population, total_cases, (total_cases/population)*100 as Casepercentage
	 from [Covid Project]..CovidDeaths
	 where location like 'india' and continent is not null
	 order by 1,2

	 -- looking at countries with highest infection rate compared to population
	 
     select location, date, population, MAX(total_cases) as highestInfectioncount, MAX((total_cases/population))*100 as Maxcasepercentage
	 from [Covid Project]..CovidDeaths
	 where location like 'india' and continent is not null
	 group by location, date, population
	 order by Maxcasepercentage desc

	 select location, date, population, MAX(total_cases) as highestInfectioncount, MAX((total_cases/population))*100 as Maxcasepercentage
	 from [Covid Project]..CovidDeaths
	 -- where location like 'india' and continent is not null
	 group by location, date, population
	 order by Maxcasepercentage desc

	  -- showing countries with highest death count per population

	  select location, MAX(cast(Total_deaths as int)) as Totaldeathcount
	  from [Covid Project]..CovidDeaths
	  where continent is not null
	 group by location
	 order by Totaldeathcount desc


	 -- showing the continent with the highest death count per population

	-- continent death count
	 
	 select continent, MAX(cast(Total_deaths as int)) as Totaldeathcount
	 from [Covid Project]..CovidDeaths
	 where continent is not null
	 group by continent
	 order by Totaldeathcount desc

-- Global numbers

 select  date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
	 from [Covid Project]..CovidDeaths
	 where continent is not null
	 group by date
	 order by 1,2

-- no date
 select  date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
	 from [Covid Project]..CovidDeaths
	 where continent is not null
	 --group by date
	 order by 1,2


-- Total death count
select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
	 from [Covid Project]..CovidDeaths
	 where continent is not null
	 order by 1,2


--3

 Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--4

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


	 --  Looking at total population vs vaccination

	select dea.continent, dea.location,dea.date,population, vac.new_vaccinations,
	SUM(convert(int,new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as Total_vacc
	from [Covid Project]..CovidDeaths dea 
	join [Covid Project]..Covidvaccineation vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


	-- using CTE
	 With PopvsVac (continent, location, date, population, new_vaccination, Total_vacc)
	 as 
	 (
	 select dea.continent, dea.location,dea.date,population, vac.new_vaccinations,
	SUM(convert(int,new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as Total_vacc
	from [Covid Project]..CovidDeaths dea 
	join [Covid Project]..Covidvaccineation vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	--order by 1,2
	)
	Select * , (Total_vacc/population)*100 as PopvsVaccPer
	from PopvsVac

	Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..Covidvaccineation vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3

	-- temp table


	drop table if exists #Percentpopulationvacc 
	Create table #Percentpopulationvacc
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	total_vacc numeric
	)
	
	insert into #Percentpopulationvacc
	
	 select dea.continent, dea.location,dea.date,population, vac.new_vaccinations,
	SUM(convert(int,new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as Total_vacc
	from [Covid Project]..CovidDeaths dea 
	join [Covid Project]..Covidvaccineation vac
	on dea.location = vac.location and dea.date = vac.date
	--where dea.continent is not null
	--order by 1,2

	Select * , (Total_vacc/population)*100 as PopvsVaccPer
	from #Percentpopulationvacc

	--creating view to store data for later visualization
	
	create view Percentpopulationvacc as 
	select dea.continent, dea.location,dea.date,population, vac.new_vaccinations,
	SUM(convert(int,new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as Total_vacc
	from [Covid Project]..CovidDeaths dea 
	join [Covid Project]..Covidvaccineation vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	-- order by 1,2

	
	
	select * from Percentpopulationvacc


	---- Extras

	

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid Project]..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From [Covid Project]..CovidDeaths
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc












-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..Covidvaccineation vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid Project]..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From [Covid Project]..CovidDeaths

--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.


Select Location, date, population, total_cases, total_deaths
From [Covid Project]..CovidDeaths
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..Covidvaccineation vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc






