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
 
# Subqueries

SELECT * 
  FROM tutorial.sf_crime_incidents_cleandate
  
SELECT sub.*
  FROM (
        SELECT *
          FROM tutorial.sf_crime_incidents_2014_01
         WHERE day_of_week = 'Friday'
       ) sub
 WHERE sub.resolution = 'NONE'
 
### the below runs first

SELECT *
  FROM tutorial.sf_crime_incidents_2014_01
 WHERE day_of_week = 'Friday'
 
## Subqueries are required to have names, which are added after parentheses the same way you would add an alias to a normal table.

## Practice Problem 11 : Write a query that selects all Warrant Arrests from the tutorial.sf_crime_incidents_2014_01 dataset, then wrap it in an outer query that only displays unresolved incidents.

SELECT * 
  FROM tutorial.sf_crime_incidents_2014_01
  
SELECT sub.*
  FROM (
       SELECT * 
         FROM tutorial.sf_crime_incidents_2014_01
        WHERE descript = 'WARRANT ARREST'
       ) sub
 WHERE sub.resolution = 'NONE'
 OR sub.resolution = NULL
 
## Using subqueries to aggregate in multiple stages

SELECT LEFT(sub.date, 2) AS cleaned_month,
       sub.day_of_week,
       AVG(sub.incidents) AS average_incidents
  FROM (
        SELECT day_of_week,
               date,
               COUNT(incidnt_num) AS incidents
          FROM tutorial.sf_crime_incidents_2014_01
         GROUP BY 1,2
       ) sub
 GROUP BY 1,2
 ORDER BY 1,2
 
## Practice Problem 12 : Write a query that displays the average number of monthly incidents for each category. Hint: use tutorial.sf_crime_incidents_cleandate to make your life a little easier.

SELECT * 
  FROM tutorial.sf_crime_incidents_cleandate
  
SELECT sub.category,
       AVG(sub.incident_count) AS avg_monthly_incidents
  FROM (
       SELECT category,
              DATE_TRUNC('month', cleaned_date) as month,
              COUNT(*) as incident_count
         FROM tutorial.sf_crime_incidents_cleandate 
        GROUP BY 1, 2
       ) sub
 GROUP BY 1
 ORDER BY 1
 
## Subqueries in conditional logic


### for a single data point condition, i.e., MIN/MAX: 

SELECT *
  FROM tutorial.sf_crime_incidents_2014_01
 WHERE Date = (SELECT MIN(date)
                 FROM tutorial.sf_crime_incidents_2014_01
              )
              
### for a set of data points: 

SELECT *
  FROM tutorial.sf_crime_incidents_2014_01
 WHERE Date IN (SELECT date
                 FROM tutorial.sf_crime_incidents_2014_01
                ORDER BY date
                LIMIT 5
              )
 
### Note that you should not include an alias when you write a subquery in a conditional statement. This is because the subquery is treated as an individual value (or set of values in the IN case) rather than as a table.

## Joining subqueries

SELECT *
  FROM tutorial.sf_crime_incidents_2014_01 incidents
  JOIN ( SELECT date
           FROM tutorial.sf_crime_incidents_2014_01
          ORDER BY date
          LIMIT 5
       ) sub
    ON incidents.date = sub.date
    
SELECT incidents.*,
       sub.incidents AS incidents_that_day
  FROM tutorial.sf_crime_incidents_2014_01 incidents
  JOIN ( SELECT date,
          COUNT(incidnt_num) AS incidents
           FROM tutorial.sf_crime_incidents_2014_01
          GROUP BY 1
       ) sub
    ON incidents.date = sub.date
 ORDER BY sub.incidents DESC, time
 
## Practice Problem 12 : Write a query that displays all rows from the three categories with the fewest incidents reported.

SELECT * 
  FROM tutorial.sf_crime_incidents_cleandate
  
SELECT a.*,
       sub.incidents_by_category
  FROM tutorial.sf_crime_incidents_2014_01 AS a
  JOIN (
       SELECT category,
              COUNT(*) AS incidents_by_category
         FROM tutorial.sf_crime_incidents_2014_01
        GROUP BY 1
        ORDER BY 2
        LIMIT 3
       ) sub
    ON a.category = sub.category
    
### Example of long query:
    
SELECT COALESCE(acquisitions.acquired_month, investments.funded_month) AS month,
       COUNT(DISTINCT acquisitions.company_permalink) AS companies_acquired,
       COUNT(DISTINCT investments.company_permalink) AS investments
  FROM tutorial.crunchbase_acquisitions acquisitions
  FULL JOIN tutorial.crunchbase_investments investments
    ON acquisitions.acquired_month = investments.funded_month
 GROUP BY 1
 
### 7K+ results:

SELECT COUNT(*) FROM tutorial.crunchbase_acquisitions

### 83K+ results:

SELECT COUNT(*) FROM tutorial.crunchbase_investments

### 6.2M+ results:

SELECT COUNT(*)
      FROM tutorial.crunchbase_acquisitions acquisitions
      FULL JOIN tutorial.crunchbase_investments investments
        ON acquisitions.acquired_month = investments.funded_month
        
### Improved query using subqueries:

SELECT COALESCE(acquisitions.month, investments.month) AS month,
       acquisitions.companies_acquired,
       investments.companies_rec_investment
  FROM (
        SELECT acquired_month AS month,
               COUNT(DISTINCT company_permalink) AS companies_acquired
          FROM tutorial.crunchbase_acquisitions
         GROUP BY 1
       ) acquisitions

  FULL JOIN (
        SELECT funded_month AS month,
               COUNT(DISTINCT company_permalink) AS companies_rec_investment
          FROM tutorial.crunchbase_investments
         GROUP BY 1
       )investments

    ON acquisitions.month = investments.month
 ORDER BY 1 DESC
 
## Practice Problem 13 : Write a query that counts the number of companies founded and acquired by quarter starting in Q1 2012. Create the aggregations in two separate queries, then join them.

SELECT *
  FROM tutorial.crunchbase_companies
  
SELECT *
  FROM tutorial.crunchbase_acquisitions
  
SELECT COALESCE(c.founded_quarter, a.acquired_quarter) AS quarter, 
       c.count_founded_quarter,
       a.count_acquired_quarter
  FROM (
       SELECT founded_quarter,
              COUNT(permalink) AS count_founded_quarter
         FROM tutorial.crunchbase_companies
        WHERE founded_year >= 2012
        GROUP BY 1
       ) c
  LEFT JOIN (
            SELECT acquired_quarter,
                   COUNT(DISTINCT company_permalink) AS count_acquired_quarter
              FROM tutorial.crunchbase_acquisitions
             WHERE acquired_year >= 2012
             GROUP BY 1
            ) a
    ON c.founded_quarter = a.acquired_quarter
 ORDER BY 2 DESC

## Subqueries and UNION

SELECT *
  FROM tutorial.crunchbase_investments_part1

 UNION ALL

 SELECT *
   FROM tutorial.crunchbase_investments_part2
   
### operations across whole data set:

SELECT COUNT(*) AS total_rows
  FROM (
        SELECT *
          FROM tutorial.crunchbase_investments_part1

         UNION ALL

        SELECT *
          FROM tutorial.crunchbase_investments_part2
       ) sub
       
## Practice Problem 14 : Write a query that ranks investors from the combined dataset above by the total number of investments they have made.

SELECT *
  FROM tutorial.crunchbase_investments_part1
  
SELECT t.investor_permalink,
       t.investor_name,
       COUNT(*) AS count_investment
  FROM (
       SELECT *
         FROM tutorial.crunchbase_investments_part1
        
        UNION ALL
        
        SELECT * 
          FROM tutorial.crunchbase_investments_part2
        ) t
 GROUP BY 1, 2
 ORDER BY 3 DESC

## Practice Problem 15 : Write a query that does the same thing as in the previous problem, except only for companies that are still operating. Hint: operating status is in tutorial.crunchbase_companies.

SELECT i.investor_permalink,
       i.investor_name,
       COUNT(*) AS count_investment
  FROM (
       SELECT *
         FROM tutorial.crunchbase_investments_part1
        
        UNION ALL
        
        SELECT * 
          FROM tutorial.crunchbase_investments_part2
        ) i
  JOIN (
       SELECT permalink,
              status
         FROM tutorial.crunchbase_companies
        WHERE status = 'operating'
       ) c
    ON i.company_permalink = c.permalink
 GROUP BY 1, 2
 ORDER BY 3 DESC
 
### given solution is simpler, removes subquery:

SELECT investments.investor_name,
       COUNT(investments.*) AS investments
  FROM tutorial.crunchbase_companies companies
  JOIN (
        SELECT *
          FROM tutorial.crunchbase_investments_part1
         
         UNION ALL
        
         SELECT *
           FROM tutorial.crunchbase_investments_part2
       ) investments
    ON investments.company_permalink = companies.permalink
 WHERE companies.status = 'operating'
 GROUP BY 1
 ORDER BY 2 DESC
 
# Window Functions : OVER

SELECT * 
  FROM tutorial.dc_bikeshare_q1_2012

SELECT duration_seconds,
       SUM(duration_seconds) OVER (ORDER BY start_time) AS running_total
  FROM tutorial.dc_bikeshare_q1_2012
  
###  the result is an aggregation without a GROUP BY

### If you'd like to narrow the window from the entire dataset to individual groups within the dataset, you can use PARTITION BY to do so:

SELECT start_time,
       start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_total
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
### similar query as above but without ORDER BY within the OVER clause

SELECT start_time, 
       start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal) AS start_terminal_total
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'

### can't use window funcitons (OVER clauses) with GROUP BY

## Practice Problem 16 : Write a query modification of the above example query that shows the duration of each ride as a percentage of the total time accrued by riders from each start_terminal

SELECT start_terminal,
       duration_seconds, 
       SUM(duration_seconds) OVER (PARTITION BY start_terminal) AS total_by_start_terminal, 
       (duration_seconds / SUM(duration_seconds) OVER 
         (PARTITION BY start_terminal))*100 AS start_terminal_percentage
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY 1, 4 DESC

## SUM, COUNT, AVG

SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal) AS running_total,
       COUNT(duration_seconds) OVER
         (PARTITION BY start_terminal) AS running_count,
       AVG(duration_seconds) OVER
         (PARTITION BY start_terminal) AS running_avg
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'

### additional example below to ingrain PARTITION BY VS PARTITION BY + ORDER BY: 

### the difference is baiscally a static aggregate function (no ORDER BY) VS a running aggregate function (with ORDER BY)

SELECT start_time,
       start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER 
         (PARTITION BY start_terminal) AS sum_by_start_terminal,
       COUNT(duration_seconds) OVER 
         (PARTITION BY start_terminal) AS count_by_start_terminal,
       AVG(duration_seconds) OVER 
         (PARTITION BY start_terminal) AS avg_by_start_terminal
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY 2, 1 
 
### all OVER clauses with ORDER BY:
 
SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_total,
       COUNT(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_count,
       AVG(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_avg
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
Practice Problem 17 : Write a query that shows a running total of the duration of bike rides (similar to the last example), but grouped by end_terminal, and with ride duration sorted in descending order.

SELECT end_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER 
         (PARTITION BY end_terminal ORDER BY duration_seconds DESC) AS running_sum_duration
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
## ROW_NUMBER()

### ROW_NUMBER() does just what it sounds like-displays the number of a given row. It starts are 1 and numbers the rows according to the ORDER BY part of the window statement. ROW_NUMBER() does not require you to specify a variable within the parentheses:

SELECT start_terminal,
       start_time,
       duration_seconds,
       ROW_NUMBER() OVER (ORDER BY start_time)
                    AS row_number
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
### ROW_NUMBER() VS COUNT()?

SELECT start_terminal,
       start_time,
       duration_seconds,
       ROW_NUMBER() OVER (ORDER BY start_time)
                    AS row_number, 
       COUNT(start_time) OVER (ORDER BY start_time) AS count_start_time
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'

### would NULL values be "counted" by ROW_NUMBER() funciton?
### there is a diff. COUNT() stays adds multiple duplicate start_time entries together initially, whereas ROW_NUMBER() adds one at a time even if there are multiple duplicate start_time entries. ROW_NUMBER() seems accurate within groupings.

### using partition restarts ROW_NUMBER() / COUNT() funcitons:

SELECT start_terminal,
       start_time,
       duration_seconds,
       ROW_NUMBER() OVER (PARTITION BY start_terminal
                          ORDER BY start_time)
                    AS row_number
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
 ## RANK(), DENSE_rank()
 
 SELECT start_terminal,
       duration_seconds,
       RANK() OVER (PARTITION BY start_terminal
                    ORDER BY start_time)
              AS rank
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
 ### RANK() VS COUNT() VS ROW_NUMBER()
 
SELECT start_time, 
       start_terminal,
       duration_seconds,
       RANK() OVER (PARTITION BY start_terminal ORDER BY start_time) AS rank, 
       COUNT(start_time) OVER (PARTITION BY start_terminal ORDER BY start_time) AS count, 
       ROW_NUMBER() OVER (PARTITION BY start_terminal ORDER BY start_time) AS row_num
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
### COUNT() takes the last value, RANK() takes the first, ROW_NUMBER doesn't differentiate

### DENSE_RANK() would still give all the identical rows a rank of 2, but the following row would be 3-no ranks would be skipped.

## Practice Problem 18 : Write a query that shows the 5 longest rides from each starting terminal, ordered by terminal, and longest to shortest rides within each terminal. Limit to rides that occurred before Jan. 8, 2012.

SELECT sub.*
  FROM (
  SELECT start_terminal,
       duration_seconds,
       RANK() OVER (PARTITION BY start_terminal ORDER BY duration_seconds DESC) AS rank
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
       ) sub
 WHERE sub.rank <= 5
 
## NTILE : NTILE(*num_of_buckets*)

SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
          AS quartile,
       NTILE(5) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS quintile,
       NTILE(100) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 
### NTILE(100) doesn't work as we'd expect here because there are less than 100 rows to label with percentile. 

## Practice Problem 19 : Write a query that shows only the duration of the trip and the percentile into which that duration falls (across the entire dataset-not partitioned by terminal).

SELECT duration_seconds,
       NTILE(100) OVER (ORDER BY duration_seconds) AS percentile_duration
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'

## LAG, LEAD

SELECT start_terminal,
       duration_seconds,
       LAG(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds) AS lag,
       LEAD(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds) AS lead
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 
### useful for find differences between rows:

SELECT start_terminal,
       duration_seconds,
       duration_seconds -LAG(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS difference
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds

### remove LEAD or LAG NULL by wrapping in subquery:

SELECT *
  FROM (
    SELECT start_terminal,
           duration_seconds,
           duration_seconds -LAG(duration_seconds, 1) OVER
             (PARTITION BY start_terminal ORDER BY duration_seconds)
             AS difference
      FROM tutorial.dc_bikeshare_q1_2012
     WHERE start_time < '2012-01-08'
     ORDER BY start_terminal, duration_seconds
       ) sub
 WHERE sub.difference IS NOT NULL
 
## Aliases for window funcitons : WINDOW

SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS quartile,
       NTILE(5) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS quintile,
       NTILE(100) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 
### can be written as follows using aliases:

SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER ntile_window AS quartile,
       NTILE(5) OVER ntile_window AS quintile,
       NTILE(100) OVER ntile_window AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
WINDOW ntile_window AS
         (PARTITION BY start_terminal ORDER BY duration_seconds)
 ORDER BY start_terminal, duration_seconds
 
### The WINDOW clause, if included, should always come after the WHERE clause.

# Performance tuning queries

## Reduce table size

SELECT *
  FROM benn.sample_event_table
 WHERE event_date >= '2014-03-01'
   AND event_date <  '2014-04-01'

### with WHERE clause

SELECT COUNT(*)
  FROM benn.sample_event_table
 LIMIT 100
 
### LIMIT can be useful in queries without aggregations

SELECT COUNT(*)
  FROM (
    SELECT *
      FROM benn.sample_event_table
     LIMIT 100
       ) sub
       
## Make JOIN less complicated

SELECT teams.conference AS conference,
       players.school_name,
       COUNT(1) AS players
  FROM benn.college_football_players players
  JOIN benn.college_football_teams teams
    ON teams.school_name = players.school_name
 GROUP BY 1,2

### many rows in result in above query
 
SELECT players.school_name,
       COUNT(*) AS players
  FROM benn.college_football_players players
 GROUP BY 1
 
### drop in the above subquery to reduce the load on this query: 

SELECT teams.conference,
       sub.*
  FROM (
        SELECT players.school_name,
               COUNT(*) AS players
          FROM benn.college_football_players players
         GROUP BY 1
       ) sub
  JOIN benn.college_football_teams teams
  ON teams.school_name = sub.school_name
  
## EXPLAIN

EXPLAIN
SELECT *
  FROM benn.sample_event_table
 WHERE event_date >= '2014-03-01'
   AND event_date < '2014-04-01'
 LIMIT 100
 
### EXPLAIN before a query will tell you roughly how long the query will take

# Pivoting data in SQL

## Pivoting rows to columns

SELECT teams.conference AS conference,
       players.year,
       COUNT(1) AS players
  FROM benn.college_football_players players
  JOIN benn.college_football_teams teams
    ON teams.school_name = players.school_name
 GROUP BY 1,2
 ORDER BY 1,2
 
### using the above query, turn into sub query

SELECT *
  FROM (
        SELECT teams.conference AS conference,
               players.year,
               COUNT(1) AS players
          FROM benn.college_football_players players
          JOIN benn.college_football_teams teams
            ON teams.school_name = players.school_name
         GROUP BY 1,2
       ) sub
       
### pivot rows into columns
       
SELECT conference,
       SUM(CASE WHEN year = 'FR' THEN players ELSE NULL END) AS fr,
       SUM(CASE WHEN year = 'SO' THEN players ELSE NULL END) AS so,
       SUM(CASE WHEN year = 'JR' THEN players ELSE NULL END) AS jr,
       SUM(CASE WHEN year = 'SR' THEN players ELSE NULL END) AS sr
  FROM (
        SELECT teams.conference AS conference,
               players.year,
               COUNT(1) AS players
          FROM benn.college_football_players players
          JOIN benn.college_football_teams teams
            ON teams.school_name = players.school_name
         GROUP BY 1,2
       ) sub
 GROUP BY 1
 ORDER BY 1
 
### order the previous query by adding sum_total to order by:
 
SELECT conference,
       SUM(players) AS total_players,
       SUM(CASE WHEN year = 'FR' THEN players ELSE NULL END) AS fr,
       SUM(CASE WHEN year = 'SO' THEN players ELSE NULL END) AS so,
       SUM(CASE WHEN year = 'JR' THEN players ELSE NULL END) AS jr,
       SUM(CASE WHEN year = 'SR' THEN players ELSE NULL END) AS sr
  FROM (
        SELECT teams.conference AS conference,
               players.year,
               COUNT(1) AS players
          FROM benn.college_football_players players
          JOIN benn.college_football_teams teams
            ON teams.school_name = players.school_name
         GROUP BY 1,2
       ) sub
 GROUP BY 1
 ORDER BY 2 DESC
 
## Pivoting columns to rows : (VALUES ... V(*col_name*))

SELECT *
  FROM tutorial.worldwide_earthquakes
  
### now turn column names into rows:

SELECT year
  FROM (VALUES (2000),(2001),(2002),(2003),(2004),(2005),(2006),
               (2007),(2008),(2009),(2010),(2011),(2012)) v(year)
            
### now combine with original table:
               
SELECT years.*,
       earthquakes.*
  FROM tutorial.worldwide_earthquakes earthquakes
 CROSS JOIN (
       SELECT year
         FROM (VALUES (2000),(2001),(2002),(2003),(2004),(2005),(2006),
                      (2007),(2008),(2009),(2010),(2011),(2012)) v(year)
       ) years
   
### now each row is replicated 13 times
       
SELECT years.*,
       earthquakes.magnitude,
       CASE year
         WHEN 2000 THEN year_2000
         WHEN 2001 THEN year_2001
         WHEN 2002 THEN year_2002
         WHEN 2003 THEN year_2003
         WHEN 2004 THEN year_2004
         WHEN 2005 THEN year_2005
         WHEN 2006 THEN year_2006
         WHEN 2007 THEN year_2007
         WHEN 2008 THEN year_2008
         WHEN 2009 THEN year_2009
         WHEN 2010 THEN year_2010
         WHEN 2011 THEN year_2011
         WHEN 2012 THEN year_2012
         ELSE NULL END
         AS number_of_earthquakes
  FROM tutorial.worldwide_earthquakes earthquakes
 CROSS JOIN (
       SELECT year
         FROM (VALUES (2000),(2001),(2002),(2003),(2004),(2005),(2006),
                      (2007),(2008),(2009),(2010),(2011),(2012)) v(year)
       ) years



