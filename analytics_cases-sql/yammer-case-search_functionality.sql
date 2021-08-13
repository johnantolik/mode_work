# Potentially Relevant Tables

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
  
# Hypotheses

* Look at per session logs to see if using the search function results in more engagement
  * i.e., "search_click_result_X" event following either "search_run" or "search_autocomplete"

* Is there a difference in engagement between "search_autocomplete" events VS "search_run" events?

* If search_autocomplete isn't effective, maybe replace it with "search_run"

* What is the role of advanced search VS other forms of search?
  * is there an event log for the advanced search feature?
  
