# Relevant Tables

SELECT *
  FROM tutorial.yammer_users
  
SELECT *
  FROM tutorial.yammer_events
  
SELECT *
  FROM tutorial.yammer_emails
  
SELECT * 
  FROM tutorial.yammer_experiments
  
# Data Orientation

SELECT *
  FROM tutorial.yammer_events
  
SELECT DISTINCT event_name
  FROM tutorial.yammer_events
  WHERE event_name ILIKE 'search%'

# Question/s

Should the search function be improved?

If so, how should the search function be improved?
  
# Followup Questions and Hypotheses

* Look at per session logs to see if using the search function results in more engagement
  * i.e., "search_click_result_X" event following either "search_run" or "search_autocomplete"
  
* Look at mobile VS desktop search effectiveness

* Is there a difference in engagement between "search_autocomplete" events VS "search_run" events?

* Is it helpful to show autocomplate search restuls by category?
  * Is there a better display order for categories, i.e., are some categories generally more likely to be clicked as a search result?

* If search_autocomplete isn't effective, maybe replace it with "search_run"

* What is the role of advanced search VS other forms of search?
  * is there an event log for the advanced search feature?
  
# Definitions

* Define effectivess for searches
  * if engagement equals effectiveness, define engagement
  
# Data Aanlyses

## Ratio of sessions per device type over time

SELECT DATE_TRUNC('month', x.session_day) AS session_month,
       SUM(x.computer)/SUM(x.weekly_active_users) AS avg_ratio_computer,
       SUM(x.phone)/SUM(x.weekly_active_users) AS avg_ratio_phone,
       SUM(x.tablet)/SUM(x.weekly_active_users) AS avg_ratio_tablet
  FROM (
        SELECT DATE_TRUNC('day', occurred_at) AS session_day,
               COUNT(DISTINCT e.user_id) AS weekly_active_users,
               COUNT(DISTINCT CASE WHEN e.device IN ('macbook pro','lenovo thinkpad','macbook air','dell inspiron notebook',
                  'asus chromebook','dell inspiron desktop','acer aspire notebook','hp pavilion desktop','acer aspire desktop','mac mini')
                  THEN e.user_id ELSE NULL END) AS computer,
               COUNT(DISTINCT CASE WHEN e.device IN ('iphone 5','samsung galaxy s4','nexus 5','iphone 5s','iphone 4s','nokia lumia 635',
               'htc one','samsung galaxy note','amazon fire phone') THEN e.user_id ELSE NULL END) AS phone,
               COUNT(DISTINCT CASE WHEN e.device IN ('ipad air','nexus 7','ipad mini','nexus 10','kindle fire','windows surface',
                'samsumg galaxy tablet') THEN e.user_id ELSE NULL END) AS tablet
          FROM tutorial.yammer_events e
         WHERE e.event_type = 'engagement'
           AND e.event_name = 'login'
         GROUP BY 1
         ORDER BY 1
    ) x
 GROUP BY 1
 ORDER BY 1
 LIMIT 100
 
## search_run AND search_click_result_X VS search_autoomplete

