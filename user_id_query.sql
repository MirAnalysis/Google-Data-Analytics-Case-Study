/* All queries used for project. Each query seperated by number and leading question. */

--1. How many unique user Ids are in each table?

-- Counting number of Ids in each table
SELECT COUNT (DISTINCT activity_w_days.Id) AS act_id, COUNT(DISTINCT sleep_w_days.Id) AS slp_id, COUNT(DISTINCT weight_w_days.Id) AS wght_id, COUNT(DISTINCT step_hr.Id) AS step_id
FROM fitbit.activity_w_days
-- Full join gives results from all tables listed independent of other table's content
FULL JOIN fitbit.sleep_w_days ON activity_w_days.Id = sleep_w_days.Id
FULL JOIN fitbit.weight_w_days ON activity_w_days.Id = weight_w_days.Id
FULL JOIN fitbit.step_hr ON activity_w_days.Id = step_hr.Id;


-- 2. How many of users overlap in each table?

-- Counting number of distinct IDs shared by all tables
SELECT COUNT (DISTINCT activity_w_days.Id) AS act_id, COUNT(DISTINCT sleep_w_days.Id) AS slp_id, COUNT(DISTINCT weight_w_days.Id) AS wght_id, COUNT(DISTINCT step_hr.Id) AS step_id
FROM fitbit.activity_w_days 
-- Inner Join results in only matching Ids found in all tables listed
JOIN fitbit.sleep_w_days ON activity_w_days.Id = sleep_w_days.Id
JOIN fitbit.weight_w_days ON activity_w_days.Id = weight_w_days.Id
JOIN fitbit.step_hr ON activity_w_days.Id = step_hr.Id;


-- 3. What specific user Ids are in or lacking from each table?

-- Verifying IDs are consistent across tables and shows which Ids are shared or absent from tables
SELECT DISTINCT activity_w_days.Id AS act_id, sleep_w_days.Id AS slp_id, weight_w_days.Id AS wght_id, step_hr.Id AS step_id
FROM fitbit.activity_w_days 
-- Full Join allows results including null values from all tables joined
FULL JOIN fitbit.sleep_w_days ON activity_w_days.Id = sleep_w_days.Id
FULL JOIN fitbit.weight_w_days ON activity_w_days.Id = weight_w_days.Id
FULL JOIN fitbit.step_hr ON activity_w_days.Id = step_hr.Id;


--4. 