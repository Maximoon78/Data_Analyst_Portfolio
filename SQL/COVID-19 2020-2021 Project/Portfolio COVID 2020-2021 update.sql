-- location with most  covid death percentage
--location with death by covid percentage
select* , (x.total_deaths/x.total_cases * 100) as death_covid_percentage
from(
select location,MAX(cast(total_deaths as int)) as total_deaths, MAX(total_cases) as total_cases
from CovidDeaths
where continent is not null
group by location
)x
order by  death_covid_percentage desc



-- location with the population infected
with PopInf as(
select location, population,MAX(total_cases) as cases
from CovidDeaths
where continent is not null
group by location, population)

select *, (cases/population *100) as population_infected
from PopInf
order by 4 desc



-- location with the most population death
select*, (x.deaths/x.population *100) as population_death
from(
select location, population,MAX(cast(total_deaths as int)) as deaths
from CovidDeaths
where continent is not null
group by location, population
) x




-- Date with the higest death_percentage
select date, sum(new_cases)as new_case, sum(cast(new_deaths as int))as new_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidDeaths
where continent is not null
group by date
order by death_percentage desc



-- month with the highest death_percentage
Select 
    year,
    month,
    MAX(death_percentage) as highest_death_percentage
from (
    select
        year(date) AS year,
        month(date) AS month,
        sum(new_cases)as new_case,
        sum(cast(new_deaths as int))as new_death,
        sum(cast(new_deaths as int)) / nullif(sum(new_cases) *100, 0) as death_percentage
    from
        CovidDeaths
    group by year(date), month(date)
)x
group by x.year, x.month
 order by highest_death_percentage desc
 



  -- total vaccinations per day (variation 1st subquery)
 select 
	*,(x.total_vaccinations / x.population *100) as vaccination_percentage
 from(
	select 
		cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		sum(cast (cv.new_vaccinations as int)) over (partition by cd.location order by cd.date) as total_vaccinations
	from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	where cd.continent is not null
	)x


	 -- total vaccinations per day (variation 2nd cte)
 with VacvsPop as(
	select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(CONVERT (int, cv.new_vaccinations)) over (partition by cd.location order by cd.date) as total_vaccinations
 from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	where cd.continent is not null
 )
 select 
	*, (total_vaccinations/population *100) as vaccinations_percentage
 from VacvsPop
 order by 2,3
 

 -- number of days before the first vaccination
 with FirstNonNullDate as (
    select
        location,
        MIN(date) AS first_non_null_date
    from
        CovidDeaths
    where new_vaccinations IS NOT NULL
    group by location
)
select
    cd.location,
    COUNT(*) AS days_before_vaccination
from
    CovidDeaths cd
	JOIN FirstNonNullDate fnd
		on cd.location = fnd.location
	where cd.new_vaccinations IS NULL
    AND cd.date < fnd.first_non_null_date
group by cd.location
order by 2 desc

	
	--total of all the cases, deaths, vaccinations, and death percentage
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum (convert(int,new_vaccinations)) as total_vaccinations,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from
CovidDeaths
where continent is not null


--total of cases, deaths, vaccinations for each country
select location, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum (convert(int,new_vaccinations)) as total_vaccinations
from
CovidDeaths
where continent is not null
group by location


--total of cases, death, vaccinations for each continent
select location as continent, sum(new_cases) as total_cases_count,sum(convert(int,new_deaths)) as total_death_count,sum(cast(new_vaccinations as int)) as total_vacs_count
from CovidDeaths 
where continent is null
and location not in('World', 'International', 'European Union')
group by location





 -- Creating temp table
 drop table if exists PercentPopulationVaccinated
 create table PercentPopulationVaccinated(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	total_vaccinations numeric,
)

 insert into PercentPopulationVaccinated
	select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(CONVERT (int, cv.new_vaccinations)) over (partition by cd.location order by cd.date) as total_vaccinations
 from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	
 
 select 
	*, (total_vaccinations/population *100) as vaccinations_percentage
 from 
	PercentPopulationVaccinated






	-- creating view for data visualization
create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(CONVERT (int, cv.new_vaccinations)) over (partition by cd.location order by cd.date) as total_vaccinations
 from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	where cd.continent is not null
	and cd.location = 'Indonesia'




 create view InfectedinMonth as
    select
        year(date) AS year,
        month(date) AS month,
        sum(new_cases)as new_case
        
    from CovidDeaths
	where continent is not null
    group by year(date), month(date)
	
	
	


 create view TotalDeathinMonth as
    select
        year(date) AS year,
        month(date) AS month,
        sum(cast(new_deaths as int))as total_death
        
    from CovidDeaths
	where continent is not null
    group by year(date), month(date)
	

-- create view HighestDeathinMonth as
-- Select 
--    year,
--    month,
--    MAX(death_percentage) AS highest_death_percentage
--FROM (
--    SELECT
--        YEAR(date) AS year,
--        MONTH(date) AS month,
--        sum(new_cases)as new_case,
--        sum(cast(new_deaths as int))as new_death,
--        sum(cast(new_deaths as int)) / NULLIF(SUM(new_cases) *100, 0) AS death_percentage
--    FROM
--        CovidDeaths
--    GROUP BY
--        YEAR(date), MONTH(date)
--)x
--GROUP BY x.year, x.month




  create view Location_with_most_death as
select*, (x.deaths/x.population *100) as death_percentage
from(
select location, population,MAX(cast(total_deaths as int)) as deaths
from CovidDeaths
where continent is not null
group by location, population
) x



create view days_before_vaccination as
with FirstNonNullDate as (
    select
        location,
        MIN(date) AS first_non_null_date
    from CovidDeaths
    where new_vaccinations IS NOT NULL
    group by location)
select
    cd.location,
    COUNT(*) AS days_before_vaccination
from CovidDeaths cd
	join FirstNonNullDate fnd
	on cd.location = fnd.location
	where cd.new_vaccinations IS NULL
    AND cd.date < fnd.first_non_null_date
	group by cd.location
	




create view covid_death_with_median as
select x.location, x.total_deaths, x.total_cases, x.median_age, (x.total_deaths/x.total_cases *100) as death_percentage 
from (
select cd.location as location, MAX(cast(cd.total_deaths as int)) as total_deaths, MAX(cd.total_cases)as total_cases, cd.median_age as median_age
 from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	where cd.continent is not null
	group by cd.location, cd. median_age
	) x
	



