
USE corona;


-- Total Daily Cases vs. Population
-- It shows the daily percentage of the population infected with covid per country.

SELECT 
    location, date, population, total_cases, (total_cases / population) * 100 AS PercentPopulationInfected 
FROM
    corona.coviddeaths
ORDER BY location, date;



-- Shows the Countries With the Highest Infection Rate

SELECT 
    location, population, MAX(total_cases) AS TotalNumInfectedPeople, MAX((total_cases/ population)) * 100 as PercentPopulationInfected
FROM
    corona.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Shows the Highest Count of Deaths per Country.

SELECT 
    location, population, MAX(total_deaths) AS TotalNumDeaths
FROM
    corona.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalNumDeaths DESC;



-- Shows the Total Number/Percentage of Death and Infected People per Country
SELECT 
    location, MAX(total_cases) AS TotalNumCases, MAX(total_deaths) AS TotalNumDeaths, MAX(total_deaths)/MAX(total_cases) * 100 AS DeathPercentage 
FROM
    coviddeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location;


-- Shows the Daily Increase in the Number of Infected People and the Number/Percentage of Deaths Per Country

SELECT 
    location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage 
FROM
    corona.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location;




################################################################ Continent ################################################################ 

-- Shows Continents With the Highest Death Count

SELECT continent, SUM(TotalNumDeaths) AS TotalNumDeaths FROM 
(SELECT 
    continent , location, MAX(total_deaths) AS TotalNumDeaths
FROM
    corona.coviddeaths
WHERE continent is not null
GROUP BY continent,location
ORDER BY TotalNumDeaths DESC) AS tmp_df
GROUP BY continent;





################################################################ Corona-19 information around the world ################################################################ 


-- Shows the Total Daily Cases of People Infected and the Total Number/Percentage of Death

SELECT 
    date,
    SUM(new_cases) AS TotalNumCases,
    SUM(new_deaths) AS TotalNumDeaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS DeathPercentage
FROM
    coviddeaths
 WHERE continent IS NOT NULL
 GROUP BY date
 ORDER BY date;


-- Shows the Total Cases (number of deaths and people infected) Across the World

SELECT 
    SUM(new_cases) AS TotalNumCases,
    SUM(new_deaths) AS TotalNumDeaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE continent IS NOT NULL;




-- Shows the Daily Vaccination Percentage per Country.
-- This query shows the daily percentage change and cumulative count of vaccinated people per Country.

SELECT vac_table.*, (CumulativeCountVaccPeople / population) * 100 AS PercentageVaccinatedPeople
FROM 
(SELECT 
	de.continent,
    de.date, 
	de.location,
    de.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER ( PARTITION BY de.location ORDER BY de.location,de.date) AS CumulativeCountVaccPeople
FROM
    coviddeaths de
        JOIN
    covidvaccinations vac ON de.location = vac.location AND de.date = vac.date
        WHERE de.continent IS NOT NULL) AS vac_table;





# CREATING a TABLE and INSERTING Vaccination Information
DROP TABLE IF EXISTS PercentageVaccinatedPeople;
CREATE TABLE PercentageVaccinatedPeople
	(
    Continent NVARCHAR(250),
    Date datetime,
    Location NVARCHAR(250),
    Population NUMERIC,
    New_Vasccinations NUMERIC,
    CumulativeCountVaccPeople NUMERIC,
    PercentageVaccinatedPeople DOUBLE
);

INSERT INTO PercentageVaccinatedPeople
SELECT vac_table.*, (CumulativeCountVaccPeople / population) * 100 AS PercentageVaccinatedPeople
FROM 
(SELECT 
	de.continent,
    de.date, 
	de.location,
    de.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER ( PARTITION BY de.location ORDER BY de.location,de.date) AS CumulativeCountVaccPeople
FROM
    coviddeaths de
        JOIN
    covidvaccinations vac ON de.location = vac.location AND de.date = vac.date
        WHERE de.continent IS NOT NULL) AS vac_table;

                                                                    
                                                                    
                                                                    


-- Shows the Total Percentage of Fully Vaccinated, Partially Vaccinated, and Booster Shot Received by the Population per Country.
SELECT 
    vac.location,
    de.population,
    MAX(vac.people_vaccinated/ de.population) * 100 AS PartiallyVaccinated, 
    MAX(vac.people_fully_vaccinated/de.population) * 100 AS FullyVaccinated,
    MAX(vac.total_boosters/de.population) * 100 AS BoosterShot
FROM
    covidvaccinations vac
    JOIN coviddeaths de ON  de.location = vac.location AND de.date = vac.date
    WHERE vac.continent IS NOT NULL
GROUP BY vac.location, de.population;




################################################################# Creating Views #########################################################################




-- Shows the Total Cases Across the World (People Infected and Number/Percentage of Deaths)
CREATE VIEW TotalCases AS
SELECT 
    SUM(new_cases) AS TotalNumCases,
    SUM(new_deaths) AS TotalNumDeaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS DeathPercentage
FROM
    coviddeaths
 WHERE continent IS NOT NULL;





-- Shows the Daily Percentage Change and Cumulative Count of Vaccinated People per Country
CREATE VIEW PercentageVaccinatedPopulation AS
	SELECT *, 
    (CumulativeCountVaccPeople / population) * 100 AS PercentageVaccinatedPeople
FROM 
(SELECT 
	de.continent,
    de.date, 
	de.location,
    de.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER ( PARTITION BY de.location ORDER BY de.location,de.date) AS CumulativeCountVaccPeople
FROM
    coviddeaths de
        JOIN
    covidvaccinations vac ON de.location = vac.location AND de.date = vac.date
        WHERE de.continent IS NOT NULL) AS vac_table;
        
        


-- Shows the Total Number/Percentage of Death and Infected People per Country
CREATE VIEW DeathPercentage AS
    SELECT 
		location, MAX(total_cases) AS TotalNumCases, MAX(total_deaths) AS TotalNumDeaths, MAX(total_deaths)/MAX(total_cases) * 100 AS DeathPercentage 
	FROM
		coviddeaths 
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY location;



-- Shows the Highest Infection Rate Per Country 
CREATE VIEW HighestInfectionRateperCountry AS
	SELECT 
    location, population, MAX(total_cases) AS TotalInfectedPeople, MAX((total_cases/ population)) * 100 as PercentPopulationInfected
FROM
    corona.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;



-- Shows the Highest Death Count per Country
CREATE VIEW HighestDeathCount AS
	SELECT 
		location, population, MAX(total_deaths) AS TotalNumDeaths
	FROM
		corona.coviddeaths
	WHERE continent IS NOT NULL
	GROUP BY location, population
	ORDER BY TotalNumDeaths DESC;


-- Shows the Highest Death Count per Continent
CREATE VIEW ContinentDeathCount AS
	SELECT continent, SUM(TotalNumDeaths) AS TotalNumDeaths FROM 
	(SELECT 
		continent , location, MAX(total_deaths) AS TotalNumDeaths
	FROM
		corona.coviddeaths
	WHERE continent IS NOT NULL
	GROUP BY continent,location
	ORDER BY TotalNumDeaths DESC) AS tmp_df
	GROUP BY continent                   
    ORDER BY TotalNumDeaths DESC ;


-- Shows the Total Percentage of Fully Vaccinated, Partially Vaccinated, and Booster Shot Received by the Population per Country.
CREATE VIEW TotalVacInfo AS SELECT 
    vac.location,
    de.population,
    MAX(vac.people_vaccinated/ de.population) * 100 AS PartiallyVaccinatedPercentage, 
    MAX(vac.people_fully_vaccinated/de.population) * 100 AS FullyVaccinatedPercentage,
    MAX(vac.total_boosters/de.population) * 100 AS BoosterShotsPercentage
FROM
    covidvaccinations vac
    JOIN coviddeaths de ON  de.location = vac.location AND de.date = vac.date
    WHERE vac.continent IS NOT NULL
GROUP BY vac.location, de.population;

################################################################# Creating Procedure #########################################################################


-- The PROCEDURE will retrieve information about covid-19 in a certain country:
-- (death percentage, confirmed cases, and percentage of partially vaccinated, fully vaccinated, and booster shot)
DELIMITER $$
CREATE PROCEDURE CountryCovidInfo(IN Country VARCHAR(250))
BEGIN
	SELECT 
	vac.location,
	de.population,
	MAX(de.total_cases) AS ConfirmCases,
	MAX(de.total_deaths) / MAX(de.total_cases) * 100 AS DeathPercentage,
	MAX(vac.people_vaccinated/ de.population) * 100 AS PartiallyVaccinatedPercentage, 
	MAX(vac.people_fully_vaccinated/de.population) * 100 AS FullyVaccinatedPercentage,
	MAX(vac.total_boosters/de.population) * 100 AS BoosterShotsPecentage
FROM
	coviddeaths de
JOIN covidvaccinations vac ON  de.location = vac.location AND de.date = vac.date
WHERE vac.continent IS NOT NULL AND de.location = Country
GROUP BY vac.location,de.population;
END$$
DELIMITER ;












