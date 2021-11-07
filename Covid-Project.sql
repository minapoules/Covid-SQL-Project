SELECT 
	*
FROM
	PortfolioProject..coviddeaths


SELECT
	location, date, population,new_cases, total_cases, total_deaths 
FROM
	PortfolioProject..coviddeaths
ORDER BY 
	1,2

--How many poeple died vs the the total cases 

SELECT 
	location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathesPercentFromTotalCases
FROM
	PortfolioProject..coviddeaths
ORDER BY 
	1, 2

--Total cases vs population 
-- How many people infected versus the number of the country people 

SELECT
	location, date, population, total_cases, (total_cases/population)*100 total_cases_percent
FROM
	PortfolioProject..coviddeaths
ORDER BY 
	1, 2

--What is the highest infection rate  country compared with the population 

SELECT
	location, 
	population, 
	MAX(total_cases) TotalCases, 
	MAX((total_cases/population))*100 total_cases_percent_to_population
FROM
	PortfolioProject..coviddeaths
GROUP BY 
	location, population
ORDER BY 
	total_cases_percent_to_population DESC

-- Total cases vs Sum of the new cases 

SELECT 
	location, MAX(total_cases) TotalCases, SUM(new_cases) NewCasesSummation, population
FROM
	PortfolioProject..coviddeaths
--WHERE 
--	location = 'vatican'
GROUP BY 
	location, population
ORDER BY 
	1


-- The Highest number of people died per continent 

SELECT
	location, MAX(CAST(total_deaths AS int)) HighestDeaths#
FROM
	PortfolioProject..coviddeaths
WHERE
	continent is null
GROUP BY 
	location
ORDER BY 
	HighestDeaths# DESC


-- How many people died compared with the population

SELECT
	location, population, MAX(CAST(total_deaths AS int)) HighesttotalDeaths, MAX((CAST(total_deaths AS int)/population))*100 HighestTotalDeathsPerPopulation
FROM
	PortfolioProject..coviddeaths
WHERE
	continent is not null
GROUP BY
	location, population
ORDER BY 
	HighestTotalDeathsPerPopulation DESC

-- Global view 

SELECT
	date, SUM(new_cases) total_cases, SUM(CAST(new_deaths AS int)) total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) *100 DeathPercent
FROM
	PortfolioProject..coviddeaths
WHERE
	continent is not null
GROUP BY 
	date
ORDER BY 
	date, DeathPercent

-- The percentage of death vs total cases over the world 

SELECT
	 SUM(new_cases) total_cases, SUM(CAST(new_deaths AS int)) total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) *100 DeathPercent
FROM
	PortfolioProject..coviddeaths
WHERE
	continent is not null
--GROUP BY 
--	date
ORDER BY 
	DeathPercent

-- New vaccinated vs population 

WITH people_vac_progress (continent, location, date, population, new_vaccinations, PeopleVaccinatedProgress) 
	AS 
(
SELECT 
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) PeopleVaccinatedProgress 
FROM
	PortfolioProject..coviddeaths d
JOIN
	PortfolioProject..covidvaccinations v
ON
	d.location = v.location
	AND d.date = v.date
WHERE
	d.continent is not null
--GROUP BY
----ORDER BY 
--	d.location, d.date
)
SELECT *, (people_vac_progress.PeopleVaccinatedProgress/population)*100 RollingUpPeeplePerPop
FROM
	people_vac_progress


-- Temp table

DROP Table if exists #peoplevaccinatedprogress
Create Table #peoplevaccinatedprogress
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedProgress numeric
)

INSERT into #peoplevaccinatedprogress
SELECT 
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS numeric)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) PeopleVaccinatedProgress 
FROM
	PortfolioProject..coviddeaths d
JOIN
	PortfolioProject..covidvaccinations v
ON
	d.location = v.location
	AND d.date = v.date
WHERE
	d.continent is not null
--GROUP BY
ORDER BY 
	d.location, d.date
SELECT *, (PeopleVaccinatedProgress/population)*100 RollingUpPeeplePerPop
FROM
	#peoplevaccinatedprogress

-- Create view 

--DROP VIEW IF EXISTS peoplevaccinatedprogress
CREATE VIEW [peoplevaccinatedrolling] AS 
SELECT 
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS numeric)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) PeopleVaccinatedProgress 
FROM
	PortfolioProject..coviddeaths d
JOIN
	PortfolioProject..covidvaccinations v
ON
	d.location = v.location
	AND d.date = v.date
WHERE
	d.continent is not null
--GROUP BY
----ORDER BY 
--	d.location, d.date

--Test the view 

SELECT *
FROM
[peoplevaccinatedrolling]