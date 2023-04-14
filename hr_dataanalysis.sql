CREATE DATABASE dataset;
USE dataset;

CREATE TABLE hrdata (
	id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birthdate VARCHAR(50),
    gender VARCHAR(50),
    race VARCHAR(50),
    department VARCHAR(50),
    jobtitle VARCHAR(50),
    location VARCHAR(50),
    hire_date VARCHAR(50),
    termdate VARCHAR(50),
    location_city VARCHAR(50),
    location_state VARCHAR(50)
);

EXPLAIN hrdata;

SELECT COUNT(*) FROM hrdata;
SELECT DISTINCT COUNT(*) FROM hrdata;

-- We have 22,214 rows which are unique.
-- This means the id is indeed correctly represents only 1 employee at a time, so it's perfect for primary key.

SELECT * FROM hrdata
LIMIT 15;

-- Format the dates:

SET SQL_SAFE_UPDATES = 0;
UPDATE hrdata SET birthdate = STR_TO_DATE(birthdate, "%c.%e.%Y");
UPDATE hrdata SET hire_date = STR_TO_DATE(hire_date, "%c.%e.%Y");

SELECT DISTINCT termdate FROM hrdata;
UPDATE hrdata SET termdate = STR_TO_DATE(termdate, "%Y-%m-%d %H:%i");

/*
Error Code: 1411. Incorrect datetime value: '' for function str_to_date
Corrected in Excel. Added '0000.00.00 00:00' value to every empty cell.

Since in this part we would only like to explore the current employees, I could go ahead and drop the rows
where the termdate is before 2023. Although, I'll take into account the '0000.00.00 00:00' as active.
*/

SELECT COUNT(*) FROM hrdata
WHERE termdate = '0000-00-00 00:00';

-- This method will add 18,285 active employee to the analysis. 

SELECT COUNT(*) FROM hrdata
WHERE termdate > '2023-01-01 00:00';

-- This means I should delete 1,640 rows. But let's make sure that it doesn't containing any defaut Null value:

SELECT COUNT(*) FROM hrdata
WHERE '2001.04.15  2:05:00' < termdate AND termdate > '2023-01-01 00:00';

-- Same 1,640 rows. I'll go ahead and drop these.

DELETE FROM hrdata
WHERE '2001.04.15  2:05:00' < termdate AND termdate > '2023-01-01 00:00';

SELECT count(*) FROM hrdata;

-- Now we have a total 20,574 active employees.

-- Adding a full name column:
ALTER TABLE hrdata ADD full_name VARCHAR(50);
UPDATE hrdata
SET full_name = CONCAT_WS(" ", first_name, last_name);

-- Calculate age and add it as a new column:
SELECT DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), birthdate)), '%y') + 0 AS age FROM hrdata;

ALTER TABLE hrdata ADD age INT;
UPDATE hrdata
SET age = DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), birthdate)), '%y') + 0;

-- Calculate years of experience and add it as a new column:
SELECT birthdate, age, hire_date, DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), hire_date)), '%y') + 0 AS experience FROM hrdata;

-- Could be logical as the birthdates are in the 90's and the hire dates are after the 2000's.
-- Of course, only if we doesn't mind child labour! It seems like the creator of this database
-- didn't think about the relation between the birthdate and the experience, but for the sake
-- of this analysis let's pretend it's okay just for now.

ALTER TABLE hrdata ADD experience INT;
UPDATE hrdata
SET experience = DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), hire_date)), '%y') + 0;

SELECT * FROM hrdata
LIMIT 15;


-- EXPLORATORY DATA ANALYSIS

-- Let's check how many employees we have by jobtitle:
SELECT jobtitle, COUNT(jobtitle) AS nu_employee
FROM hrdata
GROUP BY jobtitle
ORDER BY nu_employee DESC;

-- Now let's see what jobs we have by department:
SELECT DISTINCT department, jobtitle
FROM hrdata
ORDER BY department;

/*
It seems like we have role levels for many jobs.
Would be interesting to check what is the average experience an employee need for each role:
*/

SELECT jobtitle, AVG(experience) AS avg_exp
FROM hrdata
GROUP BY jobtitle
ORDER BY jobtitle;

/*
We can see some inconsistency in the dataset as the experience in the company doesn't reflect the role level.
For example, if we look the first group with separeted role levels (the Accountants), we can see that there
is an average 11 or 12 years of experience for each of the four role levels.
This means that the company is prefering external hiring instead of promoting employees.
*/
-- What about the gender distribution on these role levels?

SELECT gender, jobtitle, AVG(experience) AS avg_exp
FROM hrdata
WHERE gender != 'Non-Conforming'
GROUP BY gender, jobtitle
ORDER BY avg_exp DESC;

/*
There are slightly more female at the top of the list, which means that the highest years of experience
in the company are currently owned by females.
I'm not able to detect anything else for the role levels with this pivot.
*/

SELECT gender, AVG(experience) AS avg_exp, COUNT(gender) AS nu_gender
FROM hrdata
WHERE gender != 'Non-Conforming'
GROUP BY gender
ORDER BY avg_exp;

/*
This is incorrect, because the order by function causes disturbance in calculation.
We should use the total count for calculating the average.
*/

SELECT COUNT(gender) AS total_count
FROM hrdata
WHERE gender != 'Non-Conforming';

-- The total count is 20,012.

SELECT gender, SUM(experience)/'20012' AS gender_exp
FROM hrdata
WHERE gender != 'Non-Conforming'
GROUP BY gender;

/*
So we can say that on average (based on the total employee count where the gender info is avaiable), the
males have more years of experience than the females.
We can also see that currently there are almost 1,000 more males working at the company. So the gender
distribution (from the avaiable data) doesn't seem to be bad.
*/

-- What about the age?

SELECT gender, age, COUNT(id) AS nu_employee
FROM hrdata
WHERE gender != 'Non-Conforming'
GROUP BY gender, age
ORDER BY age, nu_employee DESC;

/*
The count of employees grouped by age and gender could be a very interesting data for visualiation, which
we will do later. With bare eyes I don't detect any significant discrepancy between the genders.
*/

SELECT gender, age, experience
FROM hrdata
WHERE gender != 'Non-Conforming'
GROUP BY gender, age, experience
ORDER BY age, experience DESC;

/*
If we add the average experience we can see that the dataset is faulty in this aspect.
As we discussed at the very beginning, unfortunately the creator of the dataset forgot
to add more years between the birthdate and the hire_date.
*/

-- However, this fact won't stop us to make the most of our dataset, so let's continue the exporation!

-- We can check the distribution of the race as well, to see if there are any race inequalities.

SELECT DISTINCT race FROM hrdata;

-- There are no missing data here, so it means that our total count is the row number: 20,574.
SELECT COUNT(race) FROM hrdata;

SELECT race, (COUNT(race) / '20574') * 100 AS distr_race
FROM hrdata
GROUP BY race
ORDER BY distr_race DESC;

/*
Almost ~29% of the company are Whites, another bigger bites are Multiracials, Black/African Americans
and Asians with ~16% each.
Hispanic/Latinos are significantly less represented in the company with a 11%. Meanwhile the
American Indian/Alaska natives, the native Hawaiians or any other Pacific Isnlanders are present only ~6%.
*/

-- We can check the data regarding the experience:

SELECT race, (COUNT(race) / '20574') * 100 AS distr_race, AVG(experience) AS avg_exp
FROM hrdata
GROUP BY race
ORDER BY avg_exp DESC;

/*
There is no significant discrepancy in the experience between the different races.
Black/African Americans usually have slightly more experience than most of the company, but the
Native Hawaiians/Other Pacific Isnalders are at the top.

We can check the jobtitles for each race in a pivot as well, but it's too much information. We should check
this in a chart later.
*/

SELECT race, jobtitle, AVG(experience) AS avg_exp
FROM hrdata
GROUP BY race, jobtitle
ORDER BY avg_exp DESC;


-- We can also check the race distribution on each location:
SELECT location_city, race, COUNT(race) AS nu_race
FROM hrdata
GROUP BY location_city, race
ORDER BY location_city, nu_race DESC;

SELECT location_state, race, COUNT(race) AS nu_race
FROM hrdata
GROUP BY location_state, race
ORDER BY location_state, nu_race DESC;

SELECT * FROM hrdata
LIMIT 10;

SELECT DISTINCT location FROM hrdata;


-- There is one more interesting data we haven't check yet: remote vs office.

-- First we can check what is the distribution of the employees:
SELECT COUNT(id) AS nu_employee, location
FROM hrdata
GROUP BY location;

-- Currently the preferred working place is in the office.

-- What is the distribution between the genders?
SELECT COUNT(id) AS nu_employee, location, gender
FROM hrdata
WHERE gender != 'Non-Conforming'
GROUP BY location, gender
ORDER BY nu_employee DESC;


-- Nevertheless, we can check the location for race:
SELECT COUNT(id) / 20574 * 100 AS nu_employee, location, race
FROM hrdata
GROUP BY location, race
ORDER BY location, nu_employee DESC;

/*
It's good to see here that the race distribution percentages and the location distributions can be recognized here,
as that means the company doesn't decide on the working place based on gender or race.

From my experience, the jobtitle (and maybe the role level) would be the key factor, for which wouldn't be the
best idea to visualize in a pivot, but in a chart.
*/

SELECT location, jobtitle
FROM hrdata
GROUP BY location, jobtitle
ORDER BY location;

/*
With naked eyes it's really hard to detect patterns and apart from this fact, there is no guarantee that the
jobtitle would reflect the location since the best case scenario would be to let the employee decide where to work.
We will check later on this in a chart.
*/