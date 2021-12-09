SELECT * 

FROM Nov2021.dbo.CovidDeaths$
ORDER BY 3,4;


--SELECT * 
--FROM Nov2021.dbo.CovidVaccinations$
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Nov2021.dbo.CovidDeaths$
ORDER BY 1,2;

--Looking Total Deaths vs Total Cases


SELECT location, date, total_cases, total_deaths, ROUND(total_deaths/total_cases*100, 1) AS Perc_Dearths
FROM Nov2021.dbo.CovidDeaths$
WHERE LOCATION like '%States%' 
ORDER BY 1,2;


SELECT location, date, total_cases, total_deaths, ROUND(total_deaths/total_cases*100, 3) AS Perc_Dearths
FROM Nov2021.dbo.CovidDeaths$
WHERE LOCATION like 'Rus%'
ORDER BY 2 desc;


--What % of population got Covid


SELECT location, date, total_cases, population, ROUND(total_cases/population*100, 1) AS Perc_Infected
FROM Nov2021.dbo.CovidDeaths$
WHERE LOCATION like '%State%'
ORDER BY 1,2;


SELECT location, date, total_cases, population, ROUND(total_cases/population*100, 1) AS Perc_Infected
FROM Nov2021.dbo.CovidDeaths$
WHERE LOCATION like 'Rus%'
ORDER BY 1,2;


-- Counriest with the highest Infection rate

SELECT location, MAX(total_cases) , ROUND(MAX(total_cases/population)*100,1) AS Perc_infected
  FROM Nov2021.dbo.CovidDeaths$
  GROUP BY location
  ORDER BY Perc_infected desc;

  -- Showing countries with highest dearth rate per population
  

  SELECT DISTINCT location, MAX(CAST(total_deaths AS int)) AS TotalDeaths, ROUND(MAX(cast(total_deaths AS int)/population)*100,3) AS Perc_dearth_of_pop
  FROM Nov2021.dbo.CovidDeaths$
  WHERE continent IS NOT null
  GROUP BY location, population
  -- ORDER BY TotalDeaths desc;
  ORDER BY Perc_dearth_of_pop desc;


  --- By continents 
    SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeaths, ROUND(MAX(cast(total_deaths AS int)/population)*100,3) AS Perc_dearth_of_pop
  FROM Nov2021.dbo.CovidDeaths$
  WHERE continent IS NOT null
  GROUP BY continent
  -- ORDER BY TotalDeaths desc;
  ORDER BY 3 desc;


  --- Global statistics

  SELECT location, MAX(population) AS Population, SUM(new_cases) AS Total_Cases, 
                   ROUND(SUM(new_cases)/max(population)*100, 3) AS Percent_infected,
				   SUM(cast(new_deaths AS int)) AS Total_Deaths,
				   ROUND(SUM(cast(new_deaths AS int))/SUM(new_cases)*100,4) AS Percent_of_Deaths_from_Infected,
				   ROUND(SUM(cast(new_deaths AS int))/MAX(population)*100,4) AS Percent_of_Deaths_from_Population
    FROM Nov2021.dbo.CovidDeaths$
   WHERE continent IS NOT null AND location = 'Russia' OR location LIKE '%States'
   GROUP BY location
     -- ORDER BY TotalDeaths desc;
  ORDER BY 4 desc;


  -- Join both tables:
  SELECT * 
  FROM Nov2021.dbo.CovidDeaths$ AS dea
  JOIN Nov2021.dbo.CovidVaccinations$ AS vac 
     ON dea.location = vac.location AND dea.date=vac.date;


-- Running sum on vaccinations

  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS Int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingVaccinations
  FROM Nov2021.dbo.CovidDeaths$ AS dea
  JOIN Nov2021.dbo.CovidVaccinations$ AS vac 
     ON dea.location = vac.location AND dea.date=vac.date
  WHERE dea.continent IS NOT NULL
  ORDER BY 2,3;



  ---- Percent of vaccinated
  WITH VacTable (continent, location, date, population, new_vaccinations, RollingVaccinations) 
  AS
    (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS Int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingVaccinations
  FROM Nov2021.dbo.CovidDeaths$ AS dea
  JOIN Nov2021.dbo.CovidVaccinations$ AS vac 
     ON dea.location  = vac.location AND dea.date=vac.date
  WHERE dea.continent IS NOT NULL
  )
  SELECT location, population, date, new_vaccinations, RollingVaccinations, RollingVaccinations, 
  round(RollingVaccinations/population*100,3)
  FROM VacTable
  --GROUP BY location
  WHERE location LIKE '%state%'

