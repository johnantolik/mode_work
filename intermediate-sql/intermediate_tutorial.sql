# Exercises

SELECT COUNT(*) 
  FROM tutorial.aapl_historical_stock_price

SELECT COUNT(high) 
  FROM tutorial.aapl_historical_stock_price

## COUNT

### Practice Problem 1 : Write a query to count the number of non-null rows in the low column.

SELECT COUNT(low) AS count_of_low 
  FROM tutorial.aapl_historical_stock_price

### Practice Problem 2 : Write a query that determines counts of every single column. Which column has the most null values?

SELECT * 
  FROM tutorial.aapl_historical_stock_price

SELECT COUNT(date) AS count_of_date, 
  COUNT(year) AS count_of_year, 
  COUNT(month) AS count_of_month, 
  COUNT(high) AS count_of_high, 
  COUNT(low) AS count_of_low, 
  COUNT(close) AS count_of_close, 
  COUNT(volume) AS count_of_volume, 
  COUNT(id) AS count_of_id 
    FROM tutorial.aapl_historical_stock_price

## SUM

### Practice Problem 3 : Write a query to calculate the average opening price (hint: you will need to use both COUNT and SUM, as well as some simple arithmetic.).

SELECT * FROM tutorial.aapl_historical_stock_price

SELECT SUM(open) / COUNT(open) AS avg_open 
  FROM tutorial.aapl_historical_stock_price

## MIN / MAX

### Practice Problem 4 : What was Apple's lowest stock price (at the time of this data collection)?

SELECT MIN(low) AS min_of_low
  FROM tutorial.aapl_historical_stock_price

### Practice Problem 5 : What was the highest single-day increase in Apple's share value?

SELECT MAX(close - open) AS max_of_diff 
  FROM tutorial.aapl_historical_stock_price

## AVG

### Practice Problem 6 : Write a query that calculates the average daily trade volume for Apple stock.

SELECT AVG(volume) AS avg_daily_volume
  FROM tutorial.aapl_historical_stock_price

## GROUP BY

### Practive Problem 7 : Calculate the total number of shares traded each month. Order your results chronologically.

SELECT year, month, SUM(volume) AS total_volume
  FROM tutorial.aapl_historical_stock_price
 GROUP BY year, month
 ORDER BY year, month

### Practice Problem 8 : Write a query to calculate the average daily price change in Apple stock, grouped by year.

SELECT year, 
       AVG(close - open) AS avg_daily_change
  FROM tutorial.aapl_historical_stock_price
 GROUP BY year
 ORDER BY year

### Practice Problem 9 : Write a query that calculates the lowest and highest prices that Apple stock achieved each month.

SELECT year,
       month,
       MIN(low) AS min_low, 
       MAX(high) AS max_high
  FROM tutorial.aapl_historical_stock_price
 GROUP BY year, month
 ORDER BY year, month
 
## HAVING

SELECT year,
       month,
       MAX(high) AS month_high
  FROM tutorial.aapl_historical_stock_price
 GROUP BY year, month
HAVING MAX(high) > 400
 ORDER BY year, month
 
## CASE : WHEN, THEN, ELSE, END

SELECT * 
  FROM benn.college_football_players

SELECT player_name,
       year,
       CASE WHEN year = 'SR' THEN 'yes'
            ELSE 'no' END AS is_a_senior
  FROM benn.college_football_players
  
### Practice Problem 10 : Write a query that includes a column that is flagged "yes" when a player is from California, and sort the results with those players first.

SELECT player_name,
       state,
       CASE WHEN state = 'CA' THEN 'TRUE'
            ELSE 'FALSE' END AS from_california
  FROM benn.college_football_players
ORDER BY from_california DESC

### Practice Problem 11 : Write a query that includes players' names and a column that classifies them into four categories based on height. Keep in mind that the answer we provide is only one of many possible answers, since you could divide players' heights in many ways.

SELECT player_name, 
       height, 
       CASE WHEN height > 78 THEN 'very_tall'
            WHEN height > 72 AND height < 77 THEN 'tall'
            WHEN height > 68 AND height < 72 THEN 'short'
            ELSE 'very_short' END AS height_group
  FROM benn.college_football_players
ORDER BY height_group

### Practice Problem 12 : Write a query that selects all columns from benn.college_football_players and adds an additional column that displays the player's name if that player is a junior or senior.

SELECT *,
       CASE WHEN year = 'JR' OR year = 'SR' THEN player_name
            ELSE NULL END AS JR_or_SR
  FROM benn.college_football_players
  
SELECT CASE WHEN year = 'FR' THEN 'FR'
            ELSE 'Not FR' END AS year_group,
            COUNT(1) AS count
  FROM benn.college_football_players
 GROUP BY CASE WHEN year = 'FR' THEN 'FR'
               ELSE 'Not FR' END
               
SELECT CASE WHEN year = 'FR' THEN 'FR'
            WHEN year = 'SO' THEN 'SO'
            WHEN year = 'JR' THEN 'JR'
            WHEN year = 'SR' THEN 'SR'
            ELSE 'No Year Data' END AS year_group,
            COUNT(1) AS count
  FROM benn.college_football_players
 GROUP BY 1
 
### Practice Problem 13 : Write a query that counts the number of 300lb+ players for each of the following regions: West Coast (CA, OR, WA), Texas, and Other (Everywhere else).

SELECT CASE WHEN state IN ('CA', 'OR', 'WA') THEN 'west coast'
            WHEN state = 'TX' THEN 'Texas'
            ELSE 'other' END AS region, 
       COUNT(1) AS count_region
  FROM benn.college_football_players
 WHERE weight >= 300
 GROUP BY region
            
### Practice Problem 14 : Write a query that calculates the combined weight of all underclass players (FR/SO) in California as well as the combined weight of all upperclass players (JR/SR) in California.

SELECT CASE WHEN year = 'FR' OR year = 'SO' THEN 'under_class'
            WHEN year = 'JR' OR year = 'SR' THEN 'upper_class'
            ELSE NULL END AS class_group, 
       SUM(weight) AS total_weight
  FROM benn.college_football_players
 WHERE state = 'CA'
 GROUP BY class_group

### Practice Problem 15 : Write a query that displays the number of players in each state, with FR, SO, JR, and SR players in separate columns and another column for the total number of players. Order results such that states with the most players come first.

SELECT state,
       COUNT(CASE WHEN year = 'FR' THEN 1 ELSE NULL END) AS fr_count, 
       COUNT(CASE WHEN year = 'SO' THEN 1 ELSE NULL END) AS so_count, 
       COUNT(CASE WHEN year = 'JR' THEN 1 ELSE NULL END) AS jr_count, 
       COUNT(CASE WHEN year = 'SR' THEN 1 ELSE NULL END) AS sr_count,
       COUNT(*) AS total_player_count
  FROM benn.college_football_players
 GROUP BY state
 ORDER BY total_player_count DESC
       
### Practice Problem 16 : Write a query that shows the number of players at schools with names that start with A through M, and the number at schools with names starting with N - Z.

SELECT CASE WHEN school_name < 'n' THEN 'a-m school'
            WHEN school_name >= 'n' THEN 'n-z school'
            ELSE NULL END AS school_name_group, 
       COUNT(1) AS player_count
  FROM benn.college_football_players
 GROUP BY school_name_group

## DISTINCT

SELECT DISTINCT year, month
  FROM tutorial.aapl_historical_stock_price
  
### Practice Problem 17 : Write a query that returns the unique values in the year column, in chronological order.

SELECT DISTINCT year
  FROM tutorial.aapl_historical_stock_price
 ORDER BY year
  
SELECT COUNT(DISTINCT month) AS unique_months
  FROM tutorial.aapl_historical_stock_price
  
### Practice Problem 18 : Write a query that counts the number of unique values in the month column for each year.

SELECT year, COUNT(DISTINCT month) AS count_of_months
  FROM tutorial.aapl_historical_stock_price
 GROUP BY year
 ORDER BY year

### Practice Problem 19 : Write a query that separately counts the number of unique values in the month column and the number of unique values in the `year` column.

SELECT year, 
       month, 
       COUNT(DISTINCT year) AS count_of_year, 
       COUNT(DISTINCT month) AS count_of_month
  FROM tutorial.aapl_historical_stock_price
GROUP BY year, month
ORDER BY year, month

## JOIN

### Practice Problem 20 : Write a query that selects the school name, player name, position, and weight for every player in Georgia, ordered by weight (heaviest to lightest). Be sure to make an alias for the table, and to reference all column names in relation to the alias.

SELECT *
  FROM benn.college_football_players
  
SELECT * 
  FROM benn.college_football_teams

SELECT school_name, player_name, position, weight
  FROM benn.college_football_players
 WHERE state = 'GA'
 ORDER BY weight DESC
 
 SELECT *
  FROM benn.college_football_players players
  JOIN benn.college_football_teams teams
    ON teams.school_name = players.school_name

## INNER JOIN

### Practice Problem 21 : Write a query that displays player names, school names and conferences for schools in the "FBS (Division I-A Teams)" division.

SELECT players.player_name, players.full_school_name, teams.conference
  FROM benn.college_football_players players
  JOIN benn.college_football_teams teams
  ON players.school_name = teams.school_name
 WHERE teams.division = 'FBS (Division I-A Teams)'

## OUTER JOIN : LEFT, RIGHT, FULL OUTER

SELECT *
  FROM tutorial.crunchbase_companies
  
SELECT *
  FROM tutorial.crunchbase_acquisitions
  
https://joins.spathon.com/

## LEFT JOIN

SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
  FROM tutorial.crunchbase_companies companies
  JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
    
####  VS
    
SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink

### Practice Problem 22 : Write a query that performs an inner join between the tutorial.crunchbase_acquisitions table and the tutorial.crunchbase_companies table, but instead of listing individual rows, count the number of non-null rows in each table.

SELECT COUNT(c.permalink) AS company_count,
       COUNT(a.company_permalink) AS acquisition_count
  FROM tutorial.crunchbase_companies c
  JOIN tutorial.crunchbase_acquisitions a
    ON c.permalink = a.company_permalink

### Practice Problem 23 : Modify the query above to be a LEFT JOIN. Note the difference in results.

SELECT COUNT(c.permalink) AS company_count,
       COUNT(a.company_permalink) AS acquisition_count
  FROM tutorial.crunchbase_companies c
  LEFT JOIN tutorial.crunchbase_acquisitions a
    ON c.permalink = a.company_permalink

### Practice Problem 24 : Count the number of unique companies (don't double-count companies) and unique acquired companies by state. Do not include results for which there is no state data, and order by the number of acquired companies from highest to lowest.

SELECT c.state_code,
       COUNT(DISTINCT c.permalink) AS distinct_company_count,
       COUNT(DISTINCT a.company_permalink) AS distinct_aquired_company_count
  FROM tutorial.crunchbase_companies c
  LEFT JOIN tutorial.crunchbase_acquisitions a
    ON c.permalink = a.company_permalink
 WHERE c.state_code IS NOT NULL
 GROUP BY c.state_code
 ORDER BY 3 DESC
 
## RIGHT JOIN
 
SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
    
#### Equivalent to

SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
  FROM tutorial.crunchbase_acquisitions acquisitions
 RIGHT JOIN tutorial.crunchbase_companies companies
    ON companies.permalink = acquisitions.company_permalink
    
### Practice Problem 25 : Rewrite the previous practice query in which you counted total and acquired companies by state, but with a RIGHT JOIN instead of a LEFT JOIN. The goal is to produce the exact same results.

SELECT c.state_code,
       COUNT(DISTINCT c.permalink) AS distinct_company_count,
       COUNT(DISTINCT a.company_permalink) AS distinct_aquired_company_count
  FROM tutorial.crunchbase_acquisitions a
  RIGHT JOIN tutorial.crunchbase_companies c
    ON c.permalink = a.company_permalink
 WHERE c.state_code IS NOT NULL
 GROUP BY c.state_code
 ORDER BY 3 DESC

## JOIN using WHERE, ON, and AND

SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
   AND acquisitions.company_permalink != '/company/1000memories'
 ORDER BY 1
 
#### AND... is evaluated before the join occurs

#### VS

SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
 WHERE acquisitions.company_permalink != '/company/1000memories'
    OR acquisitions.company_permalink IS NULL
 ORDER BY 1
 
SELECT * 
  FROM tutorial.crunchbase_investments
  
SELECT * 
  FROM tutorial.crunchbase_companies
  
### Practice Problem 26 : Write a query that shows a company's name, "status" (found in the Companies table), and the number of unique investors in that company. Order by the number of investors from most to fewest. Limit to only companies in the state of New York.

SELECT c.name, 
       c.status, 
       COUNT(DISTINCT i.investor_permalink) AS unique_investors_count
  FROM tutorial.crunchbase_companies c
  LEFT JOIN tutorial.crunchbase_investments i
    ON c.permalink = i.company_permalink
    AND c.state_code = 'NY'
 GROUP BY c.name, c.status
 ORDER BY 3 DESC
  
### Practice Problem 27 : Write a query that lists investors based on the number of companies in which they are invested. Include a row for companies with no investor, and order from most companies to least.

SELECT i.investor_permalink,
       i.investor_name,
       COUNT(DISTINCT c.permalink) AS unique_company_count
  FROM tutorial.crunchbase_investments i
  LEFT JOIN tutorial.crunchbase_companies c
    ON i.company_permalink = c.permalink
 GROUP BY i.investor_permalink, i.investor_name
 ORDER BY 3 DESC
 
#### The above query does NOT return the required companies with no investors count.
 
 SELECT CASE WHEN investments.investor_name IS NULL THEN 'No Investors'
            ELSE investments.investor_name END AS investor,
       COUNT(DISTINCT companies.permalink) AS companies_invested_in
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments investments
    ON companies.permalink = investments.company_permalink
 GROUP BY 1
 ORDER BY 2 DESC
 
 #### The query resolves that issue using a CASE WHEN to populate NULL values into the newly created field.
 
## FULL (OUTER) JOIN

SELECT COUNT(CASE WHEN companies.permalink IS NOT NULL AND acquisitions.company_permalink IS NULL
                  THEN companies.permalink ELSE NULL END) AS companies_only,
       COUNT(CASE WHEN companies.permalink IS NOT NULL AND acquisitions.company_permalink IS NOT NULL
                  THEN companies.permalink ELSE NULL END) AS both_tables,
       COUNT(CASE WHEN companies.permalink IS NULL AND acquisitions.company_permalink IS NOT NULL
                  THEN acquisitions.company_permalink ELSE NULL END) AS acquisitions_only
  FROM tutorial.crunchbase_companies companies
  FULL JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
    
### Practice Problem 28 : Write a query that joins tutorial.crunchbase_companies and tutorial.crunchbase_investments_part1 using a FULL JOIN. Count up the number of rows that are matched/unmatched as in the example above.

SELECT COUNT(CASE WHEN c.permalink IS NOT NULL AND i.company_permalink IS NULL 
                  THEN c.permalink END) AS c_notmatched_i,
       COUNT(CASE WHEN i.company_permalink IS NOT NULL AND c.permalink IS NULL 
                  THEN i.company_permalink END) AS i_notmatched_c, 
       COUNT(CASE WHEN c.permalink IS NOT NULL AND i.company_permalink IS NOT NULL 
                  THEN c.permalink END) AS c_matched_i
  FROM tutorial.crunchbase_companies c
  FULL JOIN tutorial.crunchbase_investments_part1 i
    ON c.permalink = i.company_permalink
    
## UNION

SELECT *
  FROM tutorial.crunchbase_investments_part1

 UNION

 SELECT *
   FROM tutorial.crunchbase_investments_part2
   
#### above query combines unique data only

SELECT *
  FROM tutorial.crunchbase_investments_part1

 UNION ALL

 SELECT *
   FROM tutorial.crunchbase_investments_part2
   
#### above query combines all data

#### SQL has strict rules for appending data:
##### Both tables must have the same number of columns
##### The columns must have the same data types in the same order as the first table

### Practice Problem 29 : Write a query that appends the two crunchbase_investments datasets above (including duplicate values). Filter the first dataset to only companies with names that start with the letter "T", and filter the second to companies with names starting with "M" (both not case-sensitive). Only include the company_permalink, company_name, and investor_name columns.

SELECT company_permalink, company_name, investor_name
  FROM tutorial.crunchbase_investments_part1
 WHERE company_name ILIKE 'T%'
 
 UNION ALL
 
 SELECT company_permalink, company_name, investor_name
  FROM tutorial.crunchbase_investments_part2
 WHERE company_name ILIKE 'M%'
 
 ### Practice Problem 30 : Write a query that shows 3 columns. The first indicates which dataset (part 1 or 2) the data comes from, the second shows company status, and the third is a count of the number of investors. Hint: you will have to use the tutorial.crunchbase_companies table as well as the investments tables. And you'll want to group by status and dataset.
 
SELECT CASE WHEN c.permalink IS NOT NULL
             THEN 'from_part1' END AS data_set, 
        c.status, 
        COUNT(DISTINCT i.company_permalink) AS unique_investor_count
  FROM tutorial.crunchbase_companies c
  LEFT JOIN tutorial.crunchbase_investments_part1 i
    ON c.permalink = i.company_permalink
 GROUP BY c.status, data_set
  
 
 UNION ALL
 
 SELECT CASE WHEN c.permalink IS NOT NULL
             THEN 'from_part2' END AS data_set, 
        c.status, 
        COUNT(DISTINCT i.company_permalink) AS unique_investor_count
  FROM tutorial.crunchbase_companies c
  LEFT JOIN tutorial.crunchbase_investments_part2 i
    ON c.permalink = i.company_permalink
 GROUP BY c.status, data_set

#### above query differs from given answer below:

SELECT 'investments_part1' AS dataset_name,
       companies.status,
       COUNT(DISTINCT investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part1 investments
    ON companies.permalink = investments.company_permalink
 GROUP BY 1,2

 UNION ALL
 
 SELECT 'investments_part2' AS dataset_name,
       companies.status,
       COUNT(DISTINCT investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part2 investments
    ON companies.permalink = investments.company_permalink
 GROUP BY 1,2
 
#### Below, filtering for permalink IS NULL yields no results so not sure when using CASE WHEN... instead of '<value>' AS data_set makes a difference to counts.

SELECT * 
  FROM tutorial.crunchbase_companies
 WHERE permalink IS NULL
 
 ## JOIN with comparison operators

SELECT companies.permalink,
       companies.name,
       companies.status,
       COUNT(investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part1 investments
    ON companies.permalink = investments.company_permalink
   AND investments.funded_year > companies.founded_year + 5
 GROUP BY 1,2, 3
 
#### VS 

SELECT companies.permalink,
       companies.name,
       companies.status,
       COUNT(investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part1 investments
    ON companies.permalink = investments.company_permalink
 WHERE investments.funded_year > companies.founded_year + 5
 GROUP BY 1,2, 3
 
#### pre-JOIN, post-JOIN
 
## JOIN on multiple keys : generally, speeds queries up

SELECT companies.permalink,
       companies.name,
       investments.company_name,
       investments.company_permalink
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part1 investments
    ON companies.permalink = investments.company_permalink
   AND companies.name = investments.company_name
   
## Self JOIN

SELECT DISTINCT japan_investments.company_name,
       japan_investments.company_permalink
  FROM tutorial.crunchbase_investments_part1 japan_investments
  JOIN tutorial.crunchbase_investments_part1 gb_investments
    ON japan_investments.company_name = gb_investments.company_name
   AND gb_investments.investor_country_code = 'GBR'
   AND gb_investments.funded_at > japan_investments.funded_at
 WHERE japan_investments.investor_country_code = 'JPN'
 ORDER BY 1
 
#### Note how the same table can easily be referenced multiple times using different aliases-in this case, japan_investments and gb_investments.

#### Also, keep in mind as you review the results from the above query that a large part of the data has been omitted for the sake of the lesson (much of it is in the tutorial.crunchbase_investments_part2 table).

