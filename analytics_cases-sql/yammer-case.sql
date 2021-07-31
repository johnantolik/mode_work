# Yammer : analytics case study

## Problem : "Drop in user engagement", show here : https://app.mode.com/modeanalytics/reports/cbb8c291ee96/runs/7925c979521e/embed

### Self-generated hypotheses:

* seasonality : typical late summer consumer behavior for one or all products, i.e., August vacations
* expired customer contract : some subset of customers had their contracts expire end of July
* product bug : preventing subset of users engagement
* data pipeline bug : data is incorrect or imcomplete
* competitor gaining market share

### Given hypotheses: https://mode.com/sql-tutorial/a-drop-in-user-engagement-answers:

### Test against hypotheses

#### Data Exploration

##### Users

SELECT * 
  FROM tutorial.yammer_users
  
##### Events

SELECT * 
  FROM tutorial.yammer_events

##### Email Events

SELECT *
  FROM tutorial.yammer_emails
  
##### Rollups

SELECT * 
  FROM benn.dimension_rollup_periods
  
