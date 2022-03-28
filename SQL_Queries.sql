/* 
All queries used for project. Each query seperated by number and leading question.
*/

--1. How many unique user Ids are in each table?
-- Counting number of Ids in each table
SELECT COUNT (DISTINCT activity_w_days.Id) AS act_id, COUNT(DISTINCT sleep_w_days.Id) AS slp_id, COUNT(DISTINCT weight_w_days.Id) AS wght_id, COUNT(DISTINCT step_hr.Id) AS step_id
FROM fitbit.activity_w_days
-- Full join gives results from all tables listed independent of other table's content
FULL JOIN fitbit.sleep_w_days ON activity_w_days.Id = sleep_w_days.Id
FULL JOIN fitbit.weight_w_days ON activity_w_days.Id = weight_w_days.Id
FULL JOIN fitbit.step_hr ON activity_w_days.Id = step_hr.Id


-- 2. How many of users overlap in each table?
-- Counting number of distinct IDs shared by all tables
SELECT COUNT (DISTINCT activity_w_days.Id) AS act_id, COUNT(DISTINCT sleep_w_days.Id) AS slp_id, COUNT(DISTINCT weight_w_days.Id) AS wght_id, COUNT(DISTINCT step_hr.Id) AS step_id
FROM fitbit.activity_w_days 
-- Inner Join results in only matching Ids found in all tables listed
JOIN fitbit.sleep_w_days ON activity_w_days.Id = sleep_w_days.Id
JOIN fitbit.weight_w_days ON activity_w_days.Id = weight_w_days.Id
JOIN fitbit.step_hr ON activity_w_days.Id = step_hr.Id


-- 3. What specific user Ids are in or lacking from each table?
-- Verifying IDs are consistent across tables and shows which Ids are shared or absent from tables
SELECT DISTINCT activity_w_days.Id AS act_id, sleep_w_days.Id AS slp_id, weight_w_days.Id AS wght_id, step_hr.Id AS step_id
FROM fitbit.activity_w_days 
-- Full Join allows results including null values from all tables joined
FULL JOIN fitbit.sleep_w_days ON activity_w_days.Id = sleep_w_days.Id
FULL JOIN fitbit.weight_w_days ON activity_w_days.Id = weight_w_days.Id
FULL JOIN fitbit.step_hr ON activity_w_days.Id = step_hr.Id 


-- 4. What user ids overlap sets?
-- Change Join method to Inner Join which results in only user Ids that are found in all listed tables, exclude null values. Results in user Ids that overlap all tables
SELECT DISTINCT activity_w_days.Id AS act_id, sleep_w_days.Id AS slp_id, weight_w_days.Id AS wght_id, step_hr.Id AS step_id
FROM fitbit.activity_w_days 
JOIN fitbit.sleep_w_days ON activity_w_days.Id = sleep_w_days.Id
JOIN fitbit.weight_w_days ON activity_w_days.Id = weight_w_days.Id
JOIN fitbit.step_hr ON activity_w_days.Id = step_hr.Id
-- These users will be used later as the "overlap" group to see if any trends are present for users that use all sets vs those that do not.
-- Analysis: Only 6 users overlap in all of the datasets used


-- 5. How much activity are users performing on average? 
-- Average Activity data and grouping by User Id. 
SELECT DISTINCT Id,
 COUNT(Id) AS logs,
 AVG(Steps) AS avg_steps,
 AVG(Total_Distance) AS avg_total_distance, 
 AVG(Very_Active_Minutes) AS avg_very_min,
 AVG(Fairly_Active_Minutes) AS avg_fair_min,
 AVG(Lightly_Active_Minutes) AS avg_light_min,
 AVG(Sedentary_Minutes) AS avg_sedentary_min,
 AVG(Calories) AS avg_calories_burned
FROM fitbit.activity_w_days
GROUP BY Id
ORDER BY Id
-- Saved table as dataset: “activity_avgs_by_id”
/* Analysis: 
-21 of the 33 users tracked data for the full month.
-20 got at least 7,000 steps, 7 over 10,000 steps, and 14 had below 7,000 steps. 
-20 users are getting at least 20 min of a combination of vigorous(very) and moderate(fairly) level of activity. Many exceed 20 minutes with 6 users getting over an hour of this level of activity on average.
*/ 


-- 6. How much sleep do users get on average?
-- Compile sleep data into averages by user Id
SELECT *,
(avg_min_asleep/60) AS avg_hour_asleep     
FROM (      
   SELECT DISTINCT Id,      
    COUNT(Id) AS total_logs,      
    SUM(Time_Not_Asleep) AS total_min_awake_in_bed,     
    AVG(Time_Not_Asleep) AS avg_min_awake_in_bed,     
    SUM(Total_Minutes_Asleep) AS total_min_asleep,      
    AVG(Total_Minutes_Asleep) AS avg_min_asleep     
 FROM fitbit.sleep_w_days     
 GROUP BY Id      
 ORDER BY Id )
-- Saved table as dataset: "sleep_totals_by_id"
/* Analysis:
-Only 3 users tracked their sleep for the full month. 
-15 of the 24 did complete at least half of the month at 15 daily logs or more 
-12 got at least 7 hours of sleep. the other 12 got less than 7 hours. 
-Most users have time disrupted from sleep, 19 of the 24 had more than 15 minutes of being awake during their sleep cycle.
*/


-- 7. Combine activity and sleep averages
-- Combine the sleep and activity data grouped by Id into one table
SELECT *
FROM fitbit.activity_avg_by_id
JOIN fitbit.sleep_totals_by_id ON activity_avg_by_id.Id = sleep_totals_by_id.Id
ORDER BY sleep_totals_by_id.Id
-- Saved table as avg_act_sleep_by_id


-- 8. What days do the most and least activity take place on?
-- Average user activity and sleep data. Group by day to see day to day and weekly trends.
SELECT day, COUNT(Day) AS logs,
 AVG(Steps) AS avg_steps,
 AVG(Very_Active_Minutes) AS avg_very_act_min,
 AVG(Fairly_Active_Minutes) AS avg_fairly_act_min,
 AVG(Lightly_Active_Minutes) AS avg_lightly_act_min,
 AVG(Sedentary_Minutes) AS avg_sedentary_min,
 AVG(Total_Distance) AS avg_total_dist,
 AVG(Calories) AS avg_calories_burned
FROM fitbit.activity_w_days
GROUP BY day
ORDER BY
-- Assign a numerical value to the days so they can be ordered correctly (Otherwise SQL orders alphabetically)                  
     CASE
WHEN Day = 'Sunday' THEN 1
WHEN Day = 'Monday' THEN 2  
WHEN Day = 'Tuesday' THEN 3  
WHEN Day = 'Wednesday' THEN 4
WHEN Day = 'Thursday' THEN 5
WHEN Day = 'Friday' THEN 6
WHEN Day = 'Saturday' THEN 7
     END ASC
-- Saved this table as dataset: “avg_activity_day”
/* Analysis:
-On average users are getting over 7,000 steps except on Sundays. Users are getting over 8,000 on Tuesdays and Saturdays 
-Users are meeting the weekly recommended 150-300 minutes of activity (combination of  vigorous and moderate) at 243.44 minutes on average. 
-Users are traveling over 5 Km on average each day 
-The amount of calories burned is consistently around 2300 kcal a day with the exception of Sundays and Thursdays
-The most active day is Saturday with  244 minutes of combined activity (very, fairly, and light active levels), and the least is Sunday with 208 minutes 
-The most sedentary day is Monday with 1027.9 min and the least is Thursday with 961.9 min 
*/


-- 9. What days do users have the most and least sleep?
SELECT *,
-- Add column for minutes asleep converted to hours
(avg_min_asleep/60) AS avg_hour_asleep 
FROM (
SELECT Day, COUNT(Day) AS number_of_days,
-- Counting how many of each day is included in its grouped row.
AVG(Time_Not_Asleep) AS avg_min_awake_in_bed,   
AVG(Total_Minutes_Asleep) AS avg_min_asleep     
FROM fitbit.sleep_w_days     
GROUP BY Day
ORDER BY
CASE      
WHEN Day = 'Sunday' THEN 1      
WHEN Day = 'Monday' THEN 2      
WHEN Day = 'Tuesday' THEN 3     
WHEN Day = 'Wednesday' THEN 4     
WHEN Day = 'Thursday' THEN 5      
WHEN Day = 'Friday' THEN 6      
WHEN Day = 'Saturday' THEN 7      
 END ASC )
-- Saved this table as dataset: “avg_sleep_by_day”
/* Analysis: 
-Users get the most sleep and the recommended at least 7 hours on Sundays, Wednesdays, and Saturdays. The rest of the week users get 6.7-6.9 hours of sleep.  
-The more sleep users get the greater amount of time they spend in bed awake throughout the week with Sundays having an average 50 minutes of restless sleep. 
*/


-- 10. Combine activity and sleep data
-- Selecting sleep and activity level columns from activity and sleep datasets
SELECT 
 avg_sleep_by_day.Day,
 avg_sleep_by_day.number_of_days AS sleep_logs,
 avg_activity_day.logs AS activity_logs,
 avg_min_awake_in_bed, avg_min_asleep,
 avg_hour_asleep, avg_very_act_min,
 avg_fairly_act_min, avg_lightly_act_min, avg_sedentary_min
FROM fitbit.avg_sleep_by_day
-- Joining datasets to have both activity and sleep data in one set
JOIN fitbit.avg_activity_day ON avg_activity_day.Day = avg_sleep_by_day.Day
 ORDER BY   
      CASE              
          WHEN Day = 'Sunday' THEN 1
          WHEN Day = 'Monday' THEN 2
          WHEN Day = 'Tuesday' THEN 3
          WHEN Day = 'Wednesday' THEN 4
          WHEN Day = 'Thursday' THEN 5
          WHEN Day = 'Friday' THEN 6
          WHEN Day = 'Saturday' THEN 7
        END ASC;
     

-- 11. Are there any activity trends over time?
-- Average all results by date and sort into one row for each specific date
SELECT DISTINCT Date,
 COUNT(Id) AS logs,
 AVG(Steps) AS avg_steps,
 AVG(Total_Distance) AS avg_total_distance, 
 AVG(Very_Active_Minutes) AS avg_very_act_min,
 AVG(Fairly_Active_minutes) AS avg_fairly_act_min,
 AVG(Lightly_Active_Minutes) AS avg_light_min,
 AVG(Sedentary_Minutes) AS avg_sedentary_min,
 AVG(Calories) AS avg_calories_burned
FROM fitbit.activity_w_days
GROUP BY Date 
ORDER BY Date
-- Saved table as "avg_act_dates"
/* Analysis:
-Users gradually stopped logging activity data over the month with the largest decline occurring from may 8 - 12th 27 users to 21 users. 
-Users had at least 7,000 steps on 27 of the 31 days and less than 7,000 on only 4 days.
*/


-- 12. Are there any sleep trends over time?
SELECT *,
(avg_min_asleep/60) AS avg_hour_asleep ## Add column with minutes asleep converted to hours
FROM (
 SELECT DISTINCT Date,      
 COUNT(date) AS logs,      
 SUM(Time_Not_Asleep) AS total_min_awake_in_bed,     
 AVG(Time_Not_Asleep) AS avg_min_awake_in_bed,     
 SUM(Total_Minutes_Asleep) AS total_min_asleep,      
 AVG(Total_Minutes_Asleep) AS avg_min_asleep     
 FROM fitbit.sleep_w_days     
 GROUP BY Date  ## Results in user ids being grouped into single average entry for each date
 ORDER BY Date ) 
/* Analysis:
-Users did not use the sleep tracker consistently as seen by the variance in logs from day to day.
-16 of the 31 days users met the recommended 7 hours of sleep 
-When averaged users do get 7 hours of sleep over the month long timeline 
*/


-- 13. Combine activity and sleep data
-- Combine average activity and sleep data into one table organized by date
SELECT avg_sleep_dates.Date, avg_steps, avg_total_distance, avg_very_act_min, avg_fairly_act_min, avg_light_min, avg_sedentary_min, avg_calories_burned, avg_min_awake_in_bed, avg_min_asleep, avg_hour_asleep,
FROM fitbit.avg_act_by_date
JOIN fitbit.avg_sleep_dates ON avg_act_by_date.Date = avg_sleep_dates.Date
ORDER BY Date


-- 14. What are the average weights and how often are they logged?
-- Find number of times users logged weight data and average weight data entered
SELECT 
 DISTINCT Id,
 COUNT(Id) AS total_logs,
 AVG(Weight_Pounds) AS avg_weight_lbs,
 AVG(BMI) AS avg_BMI
FROM fitbit.weight_w_days
GROUP BY Id
ORDER BY Id
-- Saved table as dataset: "weight_avgs"
/* Analysis:
-The average weight is 171.54 pounds 
-Average BMI is 27.98
-Only 8 users tracked weight and of those only 2 checked weight a significant amount of time (24 and 30 logs)
*/


-- 15a. When are users tracking weight? (The following 2 queries are used to group the data before joining into one table)
-- Find first weight data logged
SELECT weight_w_days.Id, start_date, weight_pounds
FROM fitbit.weight_w_days
JOIN fitbit.weight_start_end_dates ON weight_w_days.Id = weight_start_end_dates.Id
WHERE Date = start_date
-- Saved table as: “weight_start_date”


-- 15b.
-- Find the last weight data logged 
SELECT weight_w_days.Id, end_date, weight_pounds AS end_pounds
FROM fitbit.weight_w_days
JOIN fitbit.weight_start_end_dates ON weight_w_days.Id = weight_start_end_dates.Id
WHERE Date = end_date
-- Saved table as: "weight_end_date"


-- 15c. What are the changes in weight over time?
-- Calculate percent change from start to end weight
SELECT *, (end_weight / start_weight) -1 AS percent_change
FROM (
-- Combine start and end date weight data into one table 
SELECT weight_w_days.Id, BMI, Report_Type, start_date, weight_start_date.weight_pounds AS start_weight,
 end_date, weight_end_date.weight_pounds AS end_weight
FROM fitbit.weight_w_days
JOIN fitbit.weight_start_date ON weight_w_days.Id = weight_start_date.Id
JOIN fitbit.weight_end_date ON weight_w_days.Id = weight_end_date.Id
WHERE Date = start_date
ORDER BY weight_w_days.Id )
-- Saved table as: "Weight_percent_change"
/*Analysis:
-Three of the 8 users only checked their weight between 2-5 times however the logs were spaced out with the difference from their start and end date being on average 19 days. 
-There is not significant weight change for any users. 
-Of the weight users the 2 that had the most logs showed the most percent change in weight. Users with 2 logs showed little change between their 2 logs in comparison. 
*/


-- 16. How do number of steps vary by day?
-- Find average steps by day                        
SELECT Day, AVG(Steps) AS avg_steps                     
FROM fitbit.activity_w_days
GROUP BY Day                        
-- Order results by day of week. Case assigns numeric value to Days so that the order is based on value not alphabetical.                        
ORDER BY                        
     CASE                       
          WHEN Day = 'Sunday' THEN 1   
          WHEN Day = 'Monday' THEN 2
          WHEN Day = 'Tuesday' THEN 3
          WHEN Day = 'Wednesday' THEN 4
          WHEN Day = 'Thursday' THEN 5
          WHEN Day = 'Friday' THEN 6
          WHEN Day = 'Saturday' THEN 7
     END ASC 

/* Analysis: 
-Saturday has the highest step count and the least is Sunday
*/


-- 17. How do steps vary by time?
-- Find number of steps per hour
SELECT DISTINCT Time, AVG(Steps) AS avg_steps
FROM `bb-casestudy.fitbit.step_hr`
GROUP BY Time
ORDER BY LENGTH(Time), Time
/* Analysis: 
Users tend to gradually increase their number of steps as the morning progresses (3am to 10am).
Step count wavers up and down in the afternoon. There is a peak in the evening before a rapid decline into the night .
*/


-- 18a. re there differences in the activity performed by users that tracked activity, sleep, and weight compared to those who did not track weight?
--Compile user Ids that overlap across activity, sleep, and weight datasets
SELECT DISTINCT weight_avgs.Id          
FROM fitbit.sleep_totals_by_id          
JOIN fitbit.weight_avgs ON weight_avgs.Id = sleep_totals_by_id.Id           
WHERE sleep_totals_by_id.Id = weight_avgs.Id
-- Saved table as dataset: "overlap_ids"


-- 18b. 
-- Compile average activity data and number of activity logs for the six overlapped user Ids
SELECT DISTINCT sleep_totals_by_id.Id,          
 logs AS activity_logs,         
 sleep_totals_by_id.total_logs AS sleep_logs,           
 weight_avgs.total_logs AS weight_logs,         
 avg_steps, avg_total_distance, avg_very_min,
 avg_fair_min, avg_light_min, avg_sedentary_min,
 avg_calories_burned, avg_min_asleep,
 avg_min_awake_in_bed           
 FROM fitbit.activity_avg_by_id         
 JOIN fitbit.sleep_totals_by_id ON sleep_totals_by_id.Id = activity_avg_by_id.Id            
 JOIN fitbit.weight_avgs ON weight_avgs.Id = sleep_totals_by_id.Id
-- This pulls data for only the six user ids that are found in both the sleep and weight datasets           
 WHERE sleep_totals_by_id.Id = weight_avgs.Id           
 ORDER BY Id 
-- Saved table as dataset: "overlap_ids_avgs_logs"


-- 19a. How do overlap users' activity and sleep data vary by day? (The following 2 queries are used to group the data before joining into one table)
-- Averaging activity types of the six user Ids that overlap across activity, sleep, and weight datasets
SELECT Day,
 AVG(Steps) AS avg_steps,   
 AVG(Total_Distance) AS avg_total_distance,     
 AVG(Very_Active_Minutes) AS avg_very_min,  
 AVG(Fairly_Active_Minutes) AS avg_fair_min,    
 AVG(Lightly_Active_Minutes) AS avg_light_min,  
 AVG(Sedentary_Minutes) AS avg_sedentary_min,   
 AVG(Calories) AS avg_calories_burned
FROM fitbit.activity_w_days
JOIN fitbit.overlap_ids ON overlap_ids.Id = activity_w_days.Id
-- Designate to pull data from the six user ids in the overlap dataset
WHERE activity_w_days.Id = overlap_ids.Id
GROUP BY Day
ORDER BY      
    CASE            
          WHEN Day = 'Sunday' THEN 1            
          WHEN Day = 'Monday' THEN 2            
          WHEN Day = 'Tuesday' THEN 3           
          WHEN Day = 'Wednesday' THEN 4         
          WHEN Day = 'Thursday' THEN 5          
          WHEN Day = 'Friday' THEN 6            
          WHEN Day = 'Saturday' THEN 7          
     END ASC 


-- 19b. 
-- Averaging sleep activity data for six users with data in activity, sleep, and weight
SELECT Day,
 AVG(Total_Minutes_Asleep) AS avg_min_asleep,
 AVG(Time_Not_Asleep) AS avg_min_awake_in_bed
FROM fitbit.sleep_w_days 
JOIN fitbit.overlap_ids ON overlap_ids.Id = sleep_w_days.Id
-- Designate to pull data from the six user ids in the overlap dataset
WHERE sleep_w_days.Id = overlap_ids.Id
GROUP BY Day
ORDER BY      
    CASE            
          WHEN Day = 'Sunday' THEN 1
          WHEN Day = 'Monday' THEN 2
          WHEN Day = 'Tuesday' THEN 3
          WHEN Day = 'Wednesday' THEN 4
          WHEN Day = 'Thursday' THEN 5
          WHEN Day = 'Friday' THEN 6
          WHEN Day = 'Saturday' THEN 7
     END ASC
     -- Saved table as dataset: “overlap_sleep_avg”


-- 19c.
-- Combine datasets into one with both sleep and activity data for six users that overlapped datasets
SELECT overlap_daily_avg.*, avg_min_asleep, avg_min_awake_in_bed               
FROM fitbit.overlap_daily_avg               
JOIN fitbit.overlap_sleep_avg ON overlap_daily_avg.Day = overlap_sleep_avg.Day
ORDER BY      
    CASE            
          WHEN Day = 'Sunday' THEN 1            
          WHEN Day = 'Monday' THEN 2            
          WHEN Day = 'Tuesday' THEN 3           
          WHEN Day = 'Wednesday' THEN 4         
          WHEN Day = 'Thursday' THEN 5          
          WHEN Day = 'Friday' THEN 6            
          WHEN Day = 'Saturday' THEN 7          
     END ASC


-- 20. What percent does each activity make up of an average day for all users?
-- Calculating the percentage each activity type makes up of an average day
  SELECT *, (avg_very_act_min_wk /weekly_avg_min_total) AS very_act_percent,        
 (avg_fairly_act_min_wk /weekly_avg_min_total) AS fairly_act_percent,       
 (avg_lightly_act_min_wk /weekly_avg_min_total) AS lightly_act_percent,       
 (avg_sedentary_min_wk /weekly_avg_min_total) AS sedentary_percent,       
 (avg_min_asleep_wk /weekly_avg_min_total) AS asleep_percent,       
 (avg_min_awake_in_bed_wk /weekly_avg_min_total) AS awake_in_bed_percent        
FROM (
SELECT *, 
-- Calculating total average minutes of combined activity types
(avg_min_awake_in_bed_wk + avg_min_asleep_wk + avg_very_act_min_wk + avg_fairly_act_min_wk + avg_lightly_act_min_wk + avg_sedentary_min_wk) AS weekly_avg_min_total
FROM (
 SELECT 
 -- Averaging activity minutes from dataset grouped by week days into one daily average
 AVG(avg_min_awake_in_bed) AS avg_min_awake_in_bed_wk,
 AVG(avg_min_asleep) AS avg_min_asleep_wk,
 AVG(avg_hour_asleep) AS avg_hour_asleep_wk,
 SUM(avg_sleep_by_day.number_of_days) AS sleep_logs,        
 SUM(avg_act_day.logs) AS activity_logs,
 AVG(avg_very_act_min) AS avg_very_act_min_wk,
 AVG(avg_fairly_act_min) AS avg_fairly_act_min_wk,
 AVG(avg_lightly_act_min) AS avg_lightly_act_min_wk,
 AVG(avg_sedentary_min) AS avg_sedentary_min_wk      
FROM fitbit.avg_sleep_by_day
JOIN fitbit.avg_act_day ON avg_sleep_by_day.Day = avg_act_day.Day))
-- Dataset saved as “daily_avg_percents”. Placed into Excel: changed number format from decimals to percentages
/* Analysis:
-Most time was spent sedentary (59.1%) (16.5 hrs) and the least (.08%) performing fairly active level of activity.
-Activity light, fair, and very combined made up 12.8% (3.79 hours) of daily time.
-Sleep makes up 25 % (6.99 hours)
*/


-- 21. What percent does each activity make up of an average day overlap users?
-- Calculating percentage of each activity type out of the total daily activity minutes
SELECT *, (avg_very_min_wk / weekly_total_min) AS very_act_percent,
 (avg_fair_min_wk / weekly_total_min) AS fairly_act_percent,
 (avg_light_min_wk / weekly_total_min) AS lightly_act_percent,
 (avg_sedentary_min_wk / weekly_total_min) AS sedentary_percent,
 (avg_min_asleep_wk / weekly_total_min) AS asleep_percent,
 (avg_min_awake_bed_wk / weekly_total_min) AS awake_in_bed_percent
FROM (
SELECT *, 
-- Adding all activity minutes to find average daily total
(avg_very_min_wk + avg_fair_min_wk + avg_light_min_wk + avg_sedentary_min_wk + avg_min_asleep_wk + avg_min_awake_bed_wk) AS weekly_total_min
FROM (
SELECT AVG(avg_very_min) AS avg_very_min_wk,
 AVG(avg_fair_min) AS avg_fair_min_wk,
 AVG(avg_light_min) AS avg_light_min_wk,
 AVG(avg_sedentary_min) AS avg_sedentary_min_wk,
 AVG(avg_min_asleep) AS avg_min_asleep_wk,
 AVG(avg_min_awake_in_bed) AS avg_min_awake_bed_wk
 FROM fitbit.overlap_daily_avg
 -- Combining sleep data with activity level data
JOIN fitbit.overlap_sleep_avg ON overlap_daily_avg.day = overlap_sleep_avg.Day ))
-- Saved table as dataset as: “overlap_weekly_act_percents”
