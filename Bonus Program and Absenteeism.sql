-- Create a join table
select * from Absenteeism a
left join Compensation b on a.ID = b.ID
left join Reasons r on a.Reason_for_absence = r.Number;

-- Find the healthiest 100 employees for the bonus
-- No measure was given, so we can try find the best measures we can
select * from Absenteeism
where Social_drinker = 0 and Social_smoker = 0 and Body_mass_index < 25
and Absenteeism_time_in_hours <	(select AVG(Absenteeism_time_in_hours) from Absenteeism)

-- Calculating the compensation rate increase for non-smokers 
-- Budget is $983,221 / 1year of work = 5*40*52*686(employees) = 1,426,880 hours -> 0.68 increase/hour
select count(*) as nonsmokers from Absenteeism
where Social_smoker = 0

--Optimize (Reasons: Identical columns, too many columns that aren't needed, create categories)
select 
a.ID, r.Reason, Month_of_absence, Age, Service_time, Work_load_Average_day, Body_mass_index, 
case
	when Body_mass_index < 19 then 'Underweight'
	when Body_mass_index between 19 and 25 then 'Healthy'
	when Body_mass_index between 25 and 30 then 'Overweight'
	when Body_mass_index > 30 then 'Obese'
	else 'Unknown' end as BMI_Category,
case 
	when Month_of_absence in (12, 1, 2) then 'Winter'
	when Month_of_absence in (3, 4, 5) then 'Spring'
	when Month_of_absence in (6, 7, 8) then 'Summer'
	when Month_of_absence in (9, 10, 11) then 'Fall'
	else 'Unknown' end as Season,
case
	when Social_drinker = 1 then 'Social Drinker'
	when Social_drinker = 0 then 'Non-Drinker'
	else 'Unknown' end as Drinking_Habit,
case 
	when Social_smoker = 1 then 'Social Smoker'
	when Social_smoker = 0 then 'Non-Smoker'
	else 'Unknown' end as Smoking_Habit
from Absenteeism a
left join Compensation b on a.ID = b.ID
left join Reasons r on a.Reason_for_absence = r.Number;