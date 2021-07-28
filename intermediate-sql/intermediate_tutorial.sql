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
