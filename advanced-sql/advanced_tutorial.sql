# Data Types

## Data Types

### <import> = <stored>
### string = varchar
### date/time = timestamp
### number = double precision (which is numberical with up to 17 significant digits)
### boolean = boolean

## CAST or CONVERT

## For example, CAST(column_name AS integer) and column_name::integer produce the same result.

## Practice Problem 1 : Convert the funding_total_usd and founded_at_clean columns in the tutorial.crunchbase_companies_clean_date table to strings (varchar format) using a different formatting function for each one.

SELECT funding_total_usd::varchar AS funding_total_usd_string,
       CAST(founded_at_clean AS varchar) AS founded_at_clean_string
  FROM tutorial.crunchbase_companies_clean_date

# Date Format

## yyyy-mm-dd makes sense as a format becausae it can be sorted chronologically as a string
## excel's date formatting is generally messy

## bad date data example

SELECT permalink,
       founded_at
  FROM tutorial.crunchbase_companies_clean_date
 ORDER BY founded_at

## good date data example

SELECT permalink,
       founded_at,
       founded_at_clean
  FROM tutorial.crunchbase_companies_clean_date
 ORDER BY founded_at_clean
 
## When you perform arithmetic on dates (such as subtracting one date from another), the results are often stored as the interval.

## In example below, note that because the companies.founded_at_clean

SELECT companies.permalink,
       companies.founded_at_clean,
       acquisitions.acquired_at_cleaned,
       acquisitions.acquired_at_cleaned -
         companies.founded_at_clean::timestamp AS time_to_acquisition
  FROM tutorial.crunchbase_companies_clean_date companies
  JOIN tutorial.crunchbase_acquisitions_clean_date acquisitions
    ON acquisitions.company_permalink = companies.permalink
 WHERE founded_at_clean IS NOT NULL
 
 ## You can introduce intervals using the INTERVAL function as well:
 
 SELECT companies.permalink,
       companies.founded_at_clean,
       companies.founded_at_clean::timestamp +
         INTERVAL '1 week' AS plus_one_week
  FROM tutorial.crunchbase_companies_clean_date companies
 WHERE founded_at_clean IS NOT NULL
 
## Also note that adding or subtracting a date column and an interval column results in another date column as in the above query.

## You can add the current time (at the time you run the query) into your code using the NOW()function:

SELECT companies.permalink,
       companies.founded_at_clean,
       NOW() - companies.founded_at_clean::timestamp AS founded_time_ago
  FROM tutorial.crunchbase_companies_clean_date companies
 WHERE founded_at_clean IS NOT NULL
 
## Practice Problem 2 : Write a query that counts the number of companies acquired within 3 years, 5 years, and 10 years of being founded (in 3 separate columns). Include a column for total companies acquired as well. Group by category and limit to only rows with a founding date.

SELECT * 
  FROM tutorial.crunchbase_companies_clean_date companies
  
SELECT * 
  FROM tutorial.crunchbase_acquisitions_clean_date
  
SELECT c.category_code, 
       COUNT(CASE WHEN a.acquired_at_cleaned::timestamp <= c.founded_at_clean::timestamp + INTERVAL '3 years' THEN 1 ELSE NULL END) AS acquired_3_yrs_count, 
       COUNT(CASE WHEN a.acquired_at_cleaned::timestamp <= c.founded_at_clean::timestamp + INTERVAL '5 years' THEN 1 ELSE NULL END) AS acquired_5_yrs_count, 
       COUNT(CASE WHEN a.acquired_at_cleaned::timestamp <= c.founded_at_clean::timestamp + INTERVAL '10 years' THEN 1 ELSE NULL END) AS acquired_3_yrs_count, 
       COUNT(1) AS total_count
  FROM tutorial.crunchbase_companies_clean_date c
  JOIN tutorial.crunchbase_acquisitions_clean_date a
    ON c.permalink = a.company_permalink
    AND c.founded_at_clean IS NOT NULL
 GROUP BY c.category_code
 ORDER BY 5 DESC
 
# SQL String Functions to Clean Data

SELECT *
  FROM tutorial.sf_crime_incidents_2014_01
  
## LEFT, RIGHT, TRIM treat all data types as strings
  
## LEFT : LEFT(string, number of characters)

SELECT incidnt_num,
       date,
       LEFT(date, 10) AS cleaned_date
  FROM tutorial.sf_crime_incidents_2014_01
  
## RIGHT does the same thing, but from the right side:

SELECT incidnt_num,
       date,
       LEFT(date, 10) AS cleaned_date,
       RIGHT(date, 17) AS cleaned_time
  FROM tutorial.sf_crime_incidents_2014_01
  
## LENGTH

SELECT incidnt_num,
       date,
       LEFT(date, 10) AS cleaned_date,
       RIGHT(date, LENGTH(date) - 11) AS cleaned_time
  FROM tutorial.sf_crime_incidents_2014_01
  
### When using functions within other functions, it's important to remember that the innermost functions will be evaluated first, followed by the functions that encapsulate them.
  
## TRIM
  
SELECT location,
       TRIM(both '()' FROM location)
  FROM tutorial.sf_crime_incidents_2014_01
  
### The TRIM function takes 3 arguments. First, you have to specify whether you want to remove characters from the beginning ('leading'), the end ('trailing'), or both ('both', as used above). Next you must specify all characters to be trimmed. Any characters included in the single quotes will be removed from both beginning, end, or both sides of the string. Finally, you must specify the text you want to trim using FROM.

## POSITION and STRPOS

SELECT incidnt_num,
       descript,
       POSITION('A' IN descript) AS a_position
  FROM tutorial.sf_crime_incidents_2014_01
  
### equivalent to:

SELECT incidnt_num,
       descript,
       STRPOS(descript, 'A') AS a_position
  FROM tutorial.sf_crime_incidents_2014_01
  
### Use UPPER or LOWER when necessary as post POSITION and STRPOS are case sensitive

## SUBSTR : SUBSTR(*string*, *starting character position*, *# of characters*)

SELECT incidnt_num,
       date,
       SUBSTR(date, 4, 2) AS day
  FROM tutorial.sf_crime_incidents_2014_01
  
## Practice Problem 3 : Write a query that separates the `location` field into separate fields for latitude and longitude. You can compare your results against the actual `lat` and `lon` fields in the table.

SELECT *
  FROM tutorial.sf_crime_incidents_2014_01
  
SELECT location,
       lat,
       lon, 
       TRIM(leading '(' FROM LEFT(location, STRPOS(location, ',') - 1)) AS derived_lat,
       TRIM(trailing ')' FROM RIGHT(location, LENGTH(location) - STRPOS(location, ','))) AS derived_lon
  FROM tutorial.sf_crime_incidents_2014_01
  
## CONCAT

SELECT incidnt_num,
       day_of_week,
       LEFT(date, 10) AS cleaned_date,
       CONCAT(day_of_week, ', ', LEFT(date, 10)) AS day_and_date
  FROM tutorial.sf_crime_incidents_2014_01
  
## Practice Problem 4 : Concatenate the lat and lon fields to form a field that is equivalent to the location field. (Note that the answer will have a different decimal precision.)

SELECT location,
       CONCAT('(', lat, ', ', lon, ')') AS derived_location
  FROM tutorial.sf_crime_incidents_2014_01
  
## Alternatively, you can use || to perform the same action:

SELECT incidnt_num,
       day_of_week,
       LEFT(date, 10) AS cleaned_date,
       day_of_week || ', ' || LEFT(date, 10) AS day_and_date
  FROM tutorial.sf_crime_incidents_2014_01
  
## Practice Problem 5 : Create the same concatenated location field, but using the || syntax instead of CONCAT.

SELECT location,
       '(' || lat || ', ' || lon || ')' AS derived_location
  FROM tutorial.sf_crime_incidents_2014_01
  
## Practice Problem 6 : Write a query that creates a date column formatted YYYY-MM-DD.

SELECT *
  FROM tutorial.sf_crime_incidents_2014_01
  
SELECT date,
       SUBSTR(date, 7, 4) || '-' || SUBSTR(date, 1, 2) || '-' || SUBSTR(date, 4, 2) AS newly_formatted_date
  FROM tutorial.sf_crime_incidents_2014_01
  
## UPPER and LOWER

SELECT incidnt_num,
       address,
       UPPER(address) AS address_upper,
       LOWER(address) AS address_lower
  FROM tutorial.sf_crime_incidents_2014_01
  
## Practice Problem 7 : Write a query that returns the `category` field, but with the first letter capitalized and the rest of the letters in lower-case.

SELECT * 
  FROM tutorial.sf_crime_incidents_2014_01
  
SELECT category,
       UPPER(LEFT(category, 1)) || LOWER(RIGHT(category, LENGTH(category) - 1)) AS proper_case_category
  FROM tutorial.sf_crime_incidents_2014_01
  
## Strings to dates

SELECT incidnt_num,
       date,
       (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) ||
        '-' || SUBSTR(date, 4, 2))::date AS cleaned_date
  FROM tutorial.sf_crime_incidents_2014_01
  
## Practice Problem 8 : Write a query that creates an accurate timestamp using the date and time columns in tutorial.sf_crime_incidents_2014_01. Include a field that is exactly 1 week later as well.

SELECT * 
  FROM tutorial.sf_crime_incidents_2014_01

SELECT incidnt_num,
       date,
       (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) ||
        '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00')::timestamp AS cleaned_date_as_timestamp, 
       (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) ||
        '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00')::timestamp + INTERVAL '1 week' AS date_timestamp_week_later
  FROM tutorial.sf_crime_incidents_2014_01
  
## Dates into more useful dates : EXTRACT, DATE_TRUNC

SELECT *
  FROM tutorial.sf_crime_incidents_cleandate
  
SELECT cleaned_date,
       EXTRACT('year'   FROM cleaned_date) AS year,
       EXTRACT('month'  FROM cleaned_date) AS month,
       EXTRACT('day'    FROM cleaned_date) AS day,
       EXTRACT('hour'   FROM cleaned_date) AS hour,
       EXTRACT('minute' FROM cleaned_date) AS minute,
       EXTRACT('second' FROM cleaned_date) AS second,
       EXTRACT('decade' FROM cleaned_date) AS decade,
       EXTRACT('dow'    FROM cleaned_date) AS day_of_week
  FROM tutorial.sf_crime_incidents_cleandate
  
### round with DATE_TRUNC
  
SELECT cleaned_date,
       DATE_TRUNC('year'   , cleaned_date) AS year,
       DATE_TRUNC('month'  , cleaned_date) AS month,
       DATE_TRUNC('week'   , cleaned_date) AS week,
       DATE_TRUNC('day'    , cleaned_date) AS day,
       DATE_TRUNC('hour'   , cleaned_date) AS hour,
       DATE_TRUNC('minute' , cleaned_date) AS minute,
       DATE_TRUNC('second' , cleaned_date) AS second,
       DATE_TRUNC('decade' , cleaned_date) AS decade
  FROM tutorial.sf_crime_incidents_cleandate
  
Practice Problem 9 : Write a query that counts the number of incidents reported by week. Cast the week as a date to get rid of the hours/minutes/seconds.

SELECT *
  FROM tutorial.sf_crime_incidents_cleandate
  
### Understanding date range of data set

SELECT day_of_week, 
       MIN(cleaned_date),
       MAX(cleaned_date)
  FROM tutorial.sf_crime_incidents_cleandate
 GROUP BY 1

SELECT cleaned_date,
       DATE_TRUNC('week', cleaned_date)::date AS week_beginning
  FROM tutorial.sf_crime_incidents_cleandate

SELECT DATE_TRUNC('week', cleaned_date)::date AS week_beginning, 
       COUNT(*) AS incidents
  FROM tutorial.sf_crime_incidents_cleandate
 GROUP BY 1
 ORDER BY 1
 
## from NOW

SELECT CURRENT_DATE AS date,
       CURRENT_TIME AS time,
       CURRENT_TIMESTAMP AS timestamp,
       LOCALTIME AS localtime,
       LOCALTIMESTAMP AS localtimestamp,
       NOW() AS now
       
### no FROM clause necessary
### run from CMT (roughly equivalent to GMT)

## AT TIME ZONE

SELECT CURRENT_TIME AS time,
       CURRENT_TIME AT TIME ZONE 'PST' AS time_pst
       
## Practice Problem 10 : Write a query that shows exactly how long ago each indicent was reported. Assume that the dataset is in Pacific Standard Time (UTC - 8).

SELECT * 
  FROM tutorial.sf_crime_incidents_cleandate
  
SELECT incidnt_num,
       cleaned_date::timestamp - CURRENT_TIMESTAMP AT TIME ZONE 'PST' AS date_time_diff
  FROM tutorial.sf_crime_incidents_cleandate
  
## COALESCE : to replace NULL values in numerical data with O

SELECT incidnt_num,
       descript,
       COALESCE(descript, 'No Description')
  FROM tutorial.sf_crime_incidents_cleandate
 ORDER BY descript DESC
 






