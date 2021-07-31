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
  
#### Initial Analyses
  
##### recreate weekly active users chart as a table

SELECT DATE_TRUNC('week', occurred_at::timestamp) AS week_clean,
       COUNT(DISTINCT user_id) AS total_users_per_week
  FROM tutorial.yammer_events
 GROUP BY week_clean
 ORDER BY week_clean
 
###### same trend, though actual counts are not consistent between both, see differences in query:
 
SELECT DATE_TRUNC('week', e.occurred_at),
       COUNT(DISTINCT e.user_id) AS weekly_active_users
  FROM tutorial.yammer_events e
 WHERE e.event_type = 'engagement'
   AND e.event_name = 'login'
 GROUP BY 1
 ORDER BY 1
 
##### the above query is more accurate as it discriminates between event_types though event_name = 'login' seems to have a trivial affect on the results

##### Look at new user counts per day:

SELECT DATE_TRUNC('day', created_at::timestamp) AS day_created,
       COUNT(CASE WHEN state = 'active' THEN 1 ELSE NULL END) AS count_active,
       COUNT(CASE WHEN state = 'pending' THEN 1 ELSE NULL END) AS count_pending
  FROM tutorial.yammer_users
 GROUP BY day_created
 ORDER BY day_created
 
##### the above query when plotted on a line chart shows me there are more pending users being created and less active users being created when compared to earlier time frames, see below:

https://app.mode.com/johnantolikiii/reports/a0525c9f7e51/viz/956d02b5b37a/explore

##### See given query for growth analysis:

SELECT DATE_TRUNC('day',created_at) AS day,
       COUNT(*) AS all_users,
       COUNT(CASE WHEN activated_at IS NOT NULL THEN u.user_id ELSE NULL END) AS activated_users
  FROM tutorial.yammer_users u
 WHERE created_at >= '2014-06-01'
   AND created_at < '2014-09-01'
 GROUP BY 1
 ORDER BY 1
 
##### This is similar, but looks at all users instead of comparing active VS pending users. My analysis may be a little misleading because I'm only using created_at and not activated_at though spotchecking tells me they are mostly occuring in the same day, so it should have little material difference.

##### Given the created_at VS activated_at potential issue, I want to see the average difference in created_at VS activated_at:

SELECT state,
       AVG(activated_at::timestamp - created_at::timestamp) AS avg_diff_create_vs_activate,
       
  FROM tutorial.yammer_users
 WHERE activated_at IS NOT NULL
 GROUP BY state
 
##### Confirmed, average time to activcation is less than 1.5 min.

##### Now, look at engagement of old users over time to see if there's a drop off

SELECT u.state,
       AVG(u.activated_at - e.occurred_at)
  FROM tutorial.yammer_events e
  JOIN tutorial.yammer_users u
    ON u.user_id = e.user_id
 WHERE u.state = 'active'
GROUP BY u.state



SELECT 
  FROM tutorial.yammer_events e
  JOIN tutorial.yammer_users u
 WHERE u.activated_at - occurred_at < 