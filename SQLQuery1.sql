SELECT *
FROM [dbo].[CovidDeaths]
ORDER BY 3,4

SELECT *
FROM [dbo].CovidVaccinations
ORDER BY 3,4

-- Selecting the data that will be used.

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

-- looking at the total cases vs total deaths.
SELECT Location,
	DATE,
	Total_cases,
	New_cases,
	Total_Deaths,
	CAST(ROUND(100 * Total_deaths/Total_cases ,2) AS nvarchar)+'%' AS DeathPercentage
FROM 
	PortfolioProjects ..CovidDeaths
WHERE 
	location lIKE '%serbia%'

-- looking at the Total cases vs population

SELECT 
	Location,
	total_cases, 
	population,  
	CAST(ROUND(100 * Total_cases/population ,2) AS nvarchar)+'%' AS Infected_Population_Percentage
FROM 
	PortfolioProjects ..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY
	100 * Total_cases/population  DESC

-- Looking at the highest infections rates

SELECT 
	Location,  
	population, 
	CAST(ROUND(MAX(100 * Total_cases/population) ,2) AS nvarchar)+'%' AS Infected_Population_Percentage
FROM 
	PortfolioProjects ..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	Location,  
	population
ORDER BY
	ROUND(MAX(100 * Total_cases/population) ,2) DESC

-- looking at the countries with highest death percentages

SELECT
	Location,  
	MAX(CAST(total_deaths AS int)) AS Total_Death,
	CAST(ROUND(MAX(100 * CAST(total_deaths AS int)/population) ,2) AS nvarchar)+'%' AS Death_Percentage
FROM 
	PortfolioProjects ..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	Location,
	population
ORDER BY
	MAX(100 * CAST(total_deaths AS int)/population) DESC

-- Looking at death by continent

SELECT
	Location,
	MAX(CAST(total_deaths AS int)) AS Total_Death
FROM 
	PortfolioProjects ..CovidDeaths
WHERE 
	continent IS NULL
GROUP BY 
	Location
ORDER BY
	MAX(100 * CAST(total_deaths AS int)/population) DESC

-- Looking at Death Percentage by Date.

WITH Global AS -- Creating a Table with Totals to use it in (Over) so we can calculate the cumulative numbers.
(SELECT 
	date, 
	SUM(new_cases) As NewCases, 
	SUM(CAST(new_deaths AS INT)) AS NewDeath
FROM
	PortfolioProjects..CovidDeaths
GROUP BY
	date)

SELECT 
	date, 
	NewCases,
	NewDeath,
	SUM(NewCases) OVER(ORDER BY date) As Total_Cases,
	SUM(NewDeath) OVER(ORDER BY date) As Total_Death,
	SUM(NewDeath) OVER(ORDER BY date) / SUM(NewCases) OVER(ORDER BY date) * 100 AS DeathPercentage
FROM
	Global
WHERE NewCases > 0
ORDER BY date

 -- Looking at the Vaccinated Percentage of the Population
 -- CREATE A TABLE

DROP TABLE IF EXISTS CUMLATIVE_VACINATIONS
CREATE TABLE CUMLATIVE_VACINATIONS 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
CumulativeNewVaccinations numeric
)

INSERT INTO CUMLATIVE_VACINATIONS
	SELECT 
		Death.continent,
		Death.location,
		Death.date,
		Death.population,
		Vac.new_vaccinations,
		SUM(CAST(Vac.new_Vaccinations AS INT)) OVER(PARTITION BY Death.Location ORDER BY Death.Date) AS CumulativeNewVaccinations
	FROM
		[dbo].[CovidDeaths] Death
		JOIN 
		[dbo].[CovidVaccinations] Vac
		ON  
		Death.location = Vac.location
		AND 
		Death.date = Vac.date
	WHERE 
		Death.continent IS NOT NULL
	ORDER BY
		2,3

SELECT 
	*, 
	CumulativeNewVaccinations / Population * 100
FROM 
	CUMLATIVE_VACINATIONS
ORDER BY 
	2,3

			
	


