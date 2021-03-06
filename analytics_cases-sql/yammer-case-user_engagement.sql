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
 
###### the above query is more accurate as it discriminates between event_types though event_name = 'login' seems to have a trivial affect on the results

##### Look at new user counts per day:

SELECT DATE_TRUNC('day', created_at::timestamp) AS day_created,
       COUNT(CASE WHEN state = 'active' THEN 1 ELSE NULL END) AS count_active,
       COUNT(CASE WHEN state = 'pending' THEN 1 ELSE NULL END) AS count_pending
  FROM tutorial.yammer_users
 GROUP BY day_created
 ORDER BY day_created
 
##### the above query when plotted on a line chart shows me there are more pending users being created and less active users being created when compared to earlier time frames, see below:

https://app.mode.com/johnantolikiii/reports/a0525c9f7e51/viz/956d02b5b37a/explore

###### See given query for growth analysis:

SELECT DATE_TRUNC('day',created_at) AS day,
       COUNT(*) AS all_users,
       COUNT(CASE WHEN activated_at IS NOT NULL THEN u.user_id ELSE NULL END) AS activated_users
  FROM tutorial.yammer_users u
 WHERE created_at >= '2014-06-01'
   AND created_at < '2014-09-01'
 GROUP BY 1
 ORDER BY 1
 
###### This is similar, but looks at all users instead of comparing active VS pending users. My analysis may be a little misleading because I'm only using created_at and not activated_at though spotchecking tells me they are mostly occuring in the same day, so it should have little material difference.

###### Given the created_at VS activated_at potential issue, I want to see the average difference in created_at VS activated_at:

SELECT state,
       AVG(activated_at::timestamp - created_at::timestamp) AS diff_create_vs_activate
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

SELECT e.week,
       MAX(e.count_per_week) AS count_per_week
  FROM (
       SELECT user_id,
              DATE_TRUNC('week', occurred_at::timestamp) AS week,
              COUNT(occurred_at) OVER (PARTITION BY DATE_TRUNC('week', occurred_at::timestamp), user_id) AS count_per_week
         FROM tutorial.yammer_events
        WHERE event_type = 'engagement'
        ORDER BY week
       ) e
  LEFT JOIN tutorial.yammer_users u
    ON u.user_id = e.user_id
 WHERE NOW()::timestamp - u.activated_at::timestamp > INTERVAL '10 weeks'
 GROUP BY e.week
 ORDER BY e.week

##### The above isn't very helpful, need to get true cohorts and some measure of engagement and age.
 
##### Given query below to plot users binned into age groups:
         
SELECT DATE_TRUNC('week',z.occurred_at) AS "week",
       AVG(z.age_at_event) AS "Average age during week",
       COUNT(DISTINCT CASE WHEN z.user_age > 70 THEN z.user_id ELSE NULL END) AS "10+ weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 70 AND z.user_age >= 63 THEN z.user_id ELSE NULL END) AS "9 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 63 AND z.user_age >= 56 THEN z.user_id ELSE NULL END) AS "8 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 56 AND z.user_age >= 49 THEN z.user_id ELSE NULL END) AS "7 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 49 AND z.user_age >= 42 THEN z.user_id ELSE NULL END) AS "6 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 42 AND z.user_age >= 35 THEN z.user_id ELSE NULL END) AS "5 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 35 AND z.user_age >= 28 THEN z.user_id ELSE NULL END) AS "4 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 28 AND z.user_age >= 21 THEN z.user_id ELSE NULL END) AS "3 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 21 AND z.user_age >= 14 THEN z.user_id ELSE NULL END) AS "2 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 14 AND z.user_age >= 7 THEN z.user_id ELSE NULL END) AS "1 week",
       COUNT(DISTINCT CASE WHEN z.user_age < 7 THEN z.user_id ELSE NULL END) AS "Less than a week"
  FROM (
        SELECT e.occurred_at,
               u.user_id,
               DATE_TRUNC('week',u.activated_at) AS activation_week,
               EXTRACT('day' FROM e.occurred_at - u.activated_at) AS age_at_event,
               EXTRACT('day' FROM '2014-09-01'::TIMESTAMP - u.activated_at) AS user_age
          FROM tutorial.yammer_users u
          JOIN tutorial.yammer_events e
            ON e.user_id = u.user_id
           AND e.event_type = 'engagement'
           AND e.event_name = 'login'
           AND e.occurred_at >= '2014-05-01'
           AND e.occurred_at < '2014-09-01'
         WHERE u.activated_at IS NOT NULL
       ) z

 GROUP BY 1
 ORDER BY 1
LIMIT 100

##### The above suggests older users are responsible to some extent to the drop in user engagement.

SELECT * 
  FROM tutorial.yammer_events
  
##### Look for drop off in device engagement : average engagement count by device over time

SELECT sub.engagement_week AS week,
       sub.device as device2,
       MAX(sub.count_engagement) AS count_engagement_per_week
  FROM (
       SELECT DATE_TRUNC('week', occurred_at::timestamp) AS engagement_week,
              device,
              COUNT(occurred_at::timestamp) OVER (PARTITION BY device, DATE_TRUNC('week', occurred_at::timestamp)) AS count_engagement
         FROM tutorial.yammer_events
        WHERE event_type = 'engagement'
        ORDER BY engagement_week
        ) sub
 GROUP BY sub.engagement_week, sub.device
 ORDER BY sub.device

###### Cannot for the life of me get the "rate_diff" of engagement per week by device, but have gross difference....

SELECT s.week,
       s.device2,
       s.engagement_per_week,
       LAG(s.engagement_per_week, 1) OVER (PARTITION BY s.device2 ORDER BY s.week) AS engagement_last_week, 
       (s.engagement_per_week -LAG(s.engagement_per_week, 1) OVER (PARTITION BY s.device2 ORDER BY s.week)) AS diff
  FROM (
        SELECT sub.engagement_week AS week,
               sub.device as device2,
               MAX(sub.count_engagement) AS engagement_per_week
          FROM (
               SELECT DATE_TRUNC('week', occurred_at::timestamp) AS engagement_week,
                      device,
                      COUNT(occurred_at::timestamp) OVER (PARTITION BY device, DATE_TRUNC('week', occurred_at::timestamp)) AS count_engagement
                 FROM tutorial.yammer_events
                WHERE event_type = 'engagement'
                ORDER BY engagement_week
                ) sub
         GROUP BY sub.engagement_week, sub.device
         ORDER BY sub.device
        ) s
 ORDER BY s.device2, s.week

###### The above query should be by device_type which would need to be derived and distinct user_id, see given solution below:

SELECT DATE_TRUNC('week', occurred_at) AS week,
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
LIMIT 100

###### the above solution is much simpler. pivoting the device type to rows was important. much easier to plot then, too.

##### Look last at digest emails and their effet driving users to engage, and look for drop off on mobile email engagement

SELECT * 
  FROM tutorial.yammer_emails
  
SELECT * 
  FROM tutorial.yammer_users
  
###### Encountering same issue where cannot get rate. I think this is because of NAs/NULLs. Need to look into this.
  
SELECT DATE_TRUNC('week', occurred_at::timestamp) AS week,
       COUNT(DISTINCT CASE WHEN action = 'email_open' THEN user_id ELSE NULL END) AS count_email_open,
       COUNT(DISTINCT CASE WHEN action = 'sent_weekly_digest' THEN user_id ELSE NULL END) AS count_email_sent,
       (COUNT(DISTINCT CASE WHEN action = 'email_open' THEN user_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN action = 'sent_weekly_digest' THEN user_id ELSE NULL END)) AS click_through_rate
  FROM tutorial.yammer_emails
 GROUP BY 1
 ORDER BY 1
 
##### Below is given solution:

SELECT week,
       weekly_opens/CASE WHEN weekly_emails = 0 THEN 1 ELSE weekly_emails END::FLOAT AS weekly_open_rate,
       weekly_ctr/CASE WHEN weekly_opens = 0 THEN 1 ELSE weekly_opens END::FLOAT AS weekly_ctr,
       retain_opens/CASE WHEN retain_emails = 0 THEN 1 ELSE retain_emails END::FLOAT AS retain_open_rate,
       retain_ctr/CASE WHEN retain_opens = 0 THEN 1 ELSE retain_opens END::FLOAT AS retain_ctr
  FROM (
SELECT DATE_TRUNC('week',e1.occurred_at) AS week,
       COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e1.user_id ELSE NULL END) AS weekly_emails,
       COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e2.user_id ELSE NULL END) AS weekly_opens,
       COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e3.user_id ELSE NULL END) AS weekly_ctr,
       COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e1.user_id ELSE NULL END) AS retain_emails,
       COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e2.user_id ELSE NULL END) AS retain_opens,
       COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e3.user_id ELSE NULL END) AS retain_ctr
  FROM tutorial.yammer_emails e1
  LEFT JOIN tutorial.yammer_emails e2
    ON e2.occurred_at >= e1.occurred_at
   AND e2.occurred_at < e1.occurred_at + INTERVAL '5 MINUTE'
   AND e2.user_id = e1.user_id
   AND e2.action = 'email_open'
  LEFT JOIN tutorial.yammer_emails e3
    ON e3.occurred_at >= e2.occurred_at
   AND e3.occurred_at < e2.occurred_at + INTERVAL '5 MINUTE'
   AND e3.user_id = e2.user_id
   AND e3.action = 'email_clickthrough'
 WHERE e1.occurred_at >= '2014-06-01'
   AND e1.occurred_at < '2014-09-01'
   AND e1.action IN ('sent_weekly_digest','sent_reengagement_email')
 GROUP BY 1
       ) a
 ORDER BY 1
 
 ###### They use some "CASE WHEN"s in the outer query that I don't quite understand intuitively. They look at retain emails as well.
 
 