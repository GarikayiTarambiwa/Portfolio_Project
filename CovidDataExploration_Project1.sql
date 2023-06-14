select *
From PortfolioProject..CovidDeathsql
Where continent != ''


--select *
--From PortfolioProject..CovidVaccinationsql
--Where continent != ''

------------------------------1. Select Data that we are going to be using--------------------------------------------
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeathsql
Where continent != ''
order by 1, 2  

--------------------------------------------------------------------------------------------------------------------------------------
Alter Table PortfolioProject..CovidDeathsql
Alter Column total_cases  int

Alter Table PortfolioProject..CovidDeathsql
Alter Column total_deaths  int

Alter Table PortfolioProject..CovidDeathsql
Alter Column population bigint

Alter Table PortfolioProject..CovidDeathsql
Alter Column new_cases bigint

Alter Table PortfolioProject..CovidDeathsql
Alter Column new_deaths bigint


Alter Table PortfolioProject..CovidVaccinationsql
Alter Column new_vaccinations int

Alter Table PortfolioProject..CovidVaccinationsql
Alter Column date date

------------------------------2. Looking at Total cases vs Total Deaths------------------------------------------

Select Location,Date,total_cases,total_deaths, (convert(float,total_deaths)/convert(float,nullif(total_cases,0)))*100 As DeathPercentage
From PortfolioProject..CovidDeathsql
Where continent != ''
--and location like '%states%'
--order by 1,3

--------------------------------3. Looking at Total cases vs Population------------------------------------------

Select Location, date, total_cases ,population,(convert(float,total_cases)/convert(float,nullif(population,0)))*(100) As Infection_Density
From PortfolioProject..CovidDeathsql
Where continent != '' 
--and location like '%states%'
order by 1,3
 

 -----------------------4. Looking at Countries with highest Infection Rates compared to Population--------------------------
Select Location, Population, max(total_cases) as HighestInfectionCount, Max(convert(float,total_cases)/convert(float,nullif(population,0)))*100 as Highest_Infection_Density
From PortfolioProject..CovidDeathsql
Where continent != ''
Group by Location, Population
Order by Highest_Infection_Density desc

----------------------- 5. Showing countries with Highest death count
Select Location, Max(total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeathsql
Where continent != ''
--and location like '%states%'
group by location
order by Total_Death_Count desc

-------------------------------6. Continent with the highest death count per population---------------------------
Select continent, Max(total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeathsql
Where continent != ''
--and location like '%states%'
group by continent
order by Total_Death_Count desc

-------------------------------------------------7. GLOBAL NUMBERS---------------------------------------------------
Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(convert(float,total_deaths)))/(sum(convert(float,total_cases)))*(100) as DeathPercentage
From PortfolioProject..CovidDeathsql
where continent!= ''
order by 1,2 

--------------------------------- 8. Looking at Total Population vs Vaccinations--------------------------------------

--------Using CTE-----------
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathsql dea
Join PortfolioProject..CovidVaccinationsql vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3
)
select *, (convert(float,RollingPeopleVaccinated)/convert(float,nullif(Population,0)))*100
From PopvsVac


------------USING TEMP TABLES----------------

Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathsql dea
Join PortfolioProject..CovidVaccinationsql vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3

select *, (RollingPeopleVaccinated/nullif(Population,0))*100
From #PercentagePopulationVaccinated
----------------------------------------------------------------------------------------------------------------------------------------------

USE PortfolioProject

sp_help CovidDeathsql;

--------------------------------------------Create views for tableau-------------------------------------------------------------------------------------


--1. All Data in use 
Create View AllData as 
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeathsql
Where continent != ''
-- order by 1, 2  



--2. Total Cases Vs Total Deaths
Create View TotalCasesVTotalDeaths as 
Select Location,Date,total_cases,total_deaths, (convert(float,total_deaths)/convert(float,nullif(total_cases,0)))*100 As DeathPercentage
From PortfolioProject..CovidDeathsql
Where continent != ''
--and location like '%states%'
--order by 1,3



--3. Total cases vs Population

Create View TotalcasesVPopulation as 
Select Location, date, total_cases ,population,(convert(float,total_cases)/convert(float,nullif(population,0)))*(100) As Infection_Density
From PortfolioProject..CovidDeathsql
Where continent != '' 
--and location like '%states%'
--order by 1,3
 
 

--4. Countries with highest Infection Rates compared to Population

Create View HighestInfectionRatesPerPopulation as 
Select Location, Population, max(total_cases) as HighestInfectionCount, Max(convert(float,total_cases)/convert(float,nullif(population,0)))*100 as Highest_Infection_Density
From PortfolioProject..CovidDeathsql
Where continent != ''
Group by Location, Population
--Order by Highest_Infection_Density desc



--5. Showing countries with Highest death count

Create View HighestDeathCountPerCountry as
Select Location, Max(total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeathsql
Where continent != ''
--and location like '%states%'
group by location
--order by Total_Death_Count desc




--6. Continent with the highest death count per population

Create View HighestDeathTollPerContinent As
Select continent, Max(total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeathsql
Where continent != ''
--and location like '%states%'
group by continent
--order by Total_Death_Count desc



--7. Global Numbers 

Create View GlobalNumbers As
Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(convert(float,total_deaths)))/(sum(convert(float,total_cases)))*(100) as DeathPercentage
From PortfolioProject..CovidDeathsql
where continent!= ''
--order by 1,2 


--8. Total Population vs Vaccinations-Using CTE-------------------------------------

Create View TotalPopulationVVaccinations As
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathsql dea
Join PortfolioProject..CovidVaccinationsql vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3
)
select *, (convert(float,RollingPeopleVaccinated)/convert(float,nullif(Population,0)))*100 As RollingpeopleVaccinatedPercentage
From PopvsVac

