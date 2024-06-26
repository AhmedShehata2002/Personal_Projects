Main Objectives:

This project aims to calculate churn rates for Codeflix subscriptions and compare them between two user segments. Through data exploration and analysis, we seek to identify patterns influencing churn behavior, ensuring data integrity and compliance with subscription policies. Visualization and reporting will be utilized to communicate findings effectively, empowering stakeholders to optimize retention strategies and drive growth.

/*Key Concepts Used 
 -Aggregates 
 -Unions
 - Temporary Tables
 - Cross Joins 
 - Case statements 
 - Aliasing
 - Churn rate */

SELECT * 
FROM subscriptions
LIMIT 100;

-- What is the range of months of data provided, which months will you be able to calculate churn for? 
SELECT MIN (subscription_start), MAX (subscription_end)
FROM subscriptions;

-- Calculate Churn Rate 
WITH months AS 
  (SELECT
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
UNION 
SELECT
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
UNION 
SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day 
),
 -- Create a temporary table from subscriptions and months. 
cross_join AS 
  (SELECT * FROM subscriptions 
  CROSS JOIN months
),
-- Status Table 
status AS 
(SELECT 
id,
first_day AS month,
CASE 
  WHEN (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end ISNULL) AND (segment=87) THEN 1 ELSE 0 
END AS is_active_87,
CASE 
  WHEN (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end ISNULL) AND (segment=30) THEN 1 ELSE 0 
END AS is_active_30, 
CASE 
  WHEN (subscription_end BETWEEN first_day AND last_day) AND (segment = 87) THEN 1 ELSE 0  
END AS is_canceled_87,
CASE 
  WHEN (subscription_end BETWEEN first_day AND last_day) AND (segment = 30) THEN 1 ELSE 0  
END AS is_canceled_30
FROM cross_join
),
-- Create a status_aggregate temp table that is a SUM of the active and canceled subscriptions for each segment, for each month. 
status_aggregate AS 
(SELECT 
  month,
  SUM(is_active_87) AS sum_active_87,
  SUM(is_active_30) AS sum_active_30,
  SUM(is_canceled_87) AS sum_canceled_87,
  SUM(is_canceled_30) AS sum_canceled_30
FROM status 
GROUP BY month
),
-- Calculate the churn rates for the two segments over the three month period. Which segment has a lower churn rate?SELECT month,
  1.0 * sum_canceled_87/sum_active_87 AS churn_rate_87,
  1.0 * sum_canceled_30/sum_active_30 AS sum_active_30
FROM status_aggregate;


