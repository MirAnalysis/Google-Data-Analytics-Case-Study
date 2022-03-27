## Verifying IDs are consistent across tables and shows which Ids are shared or absent from tables
SELECT DISTINCT activity_w_days.Id AS act_id, sleep_w_days.Id AS slp_id, weight_w_days.Id AS wght_id, step_hr.Id AS step_id
FROM fitbit.activity_w_days 
##Full Join allows results including null values from all tables joined
FULL JOIN fitbit.sleep_w_days ON activity_w_days.Id = sleep_w_days.Id
FULL JOIN fitbit.weight_w_days ON activity_w_days.Id = weight_w_days.Id
FULL JOIN fitbit.step_hr ON activity_w_days.Id = step_hr.Id;