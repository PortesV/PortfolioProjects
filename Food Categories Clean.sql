--Removing irrelevant data:
--    For cleaning and categorizing data only, we'll drop open-ended questions columns:
/*ALTER TABLE coded_food
DROP COLUMN comfort_food, comfort_food_reasons, diet_current, eating_changes, father_profession, fav_cuisine, food_childhood, healthy_meal,
	ideal_diet, meals_dinner_friend, mother_profession, type_sports;
*/
--    or we can always select the same variables in case tables are being modified constantly avoiding big damages:
select distinct
	GPA, Gender, breakfast, calories_chicken, calories_day, calories_scone, coffee, cook, comfort_food_reasons_coded,
	cuisine, diet_current_coded, drink, eating_changes_coded, eating_changes_coded1, eating_out, employment, ethnic_food,
	exercise, father_education, fav_cuisine_coded, fav_food, fries, fruit_day, grade_level, greek_food, healthy_feeling,
	ideal_diet_coded, income, indian_food, italian_food, life_rewarding, marital_status, mother_education, 
	nutritional_check, on_off_campus, parents_cook, pay_meal_out, persian_food, self_perception_weight, soup, sports, thai_food, tortilla_calories, turkey_calories,
	veggies_day, vitamins, waffle_calories, weight
from coded_food

select * from coded_food;

select GPA, Gender, breakfast, calories_day,  cook, comfort_food_reasons_coded,
	diet_current_coded, eating_changes_coded, eating_changes_coded1, eating_out, employment,
	exercise, fav_cuisine_coded, fav_food, fruit_day, grade_level, healthy_feeling,
	ideal_diet_coded, income, life_rewarding, nutritional_check, on_off_campus, 
	self_perception_weight, sports, veggies_day, vitamins, weight
	from coded_food;

--Fixing structural errors:
	--    Looks like GPA doesn't contain only numbers and doesn't follow a standard format
	--    We want 3 digts for both GPA and weight, as all measures are in lbs.
update coded_food
set GPA = TRY_CONVERT (float,  left(GPA, 4))

update coded_food
set GPA = 
	(select AVG(CAST(GPA as float)) from coded_food)
where GPA IS NULL

update coded_food
set weight = TRY_CONVERT (float,  left(weight, 3))

	-- changing na values to its corresponding asnwer code from codebook, for example '4-other' for different types of employment.
update coded_food
set employment = 4 where employment = 'nan'

update coded_food
set cuisine = 6 where cuisine = 'nan'

update coded_food
set self_perception_weight = 6 where self_perception_weight = 'nan'
	-- We're not removing any outliers here. According to our codebook all questions are categoric aside from food calorie guesses.

-- Optimizing some variables for PowerBI according to codebook:
update coded_food
set calories_day = TRY_CONVERT (int, calories_day)

update coded_food
set ideal_diet_coded = TRY_CONVERT (int, ideal_diet_coded)

update coded_food
set comfort_food_reasons_coded = TRY_CONVERT (int, comfort_food_reasons_coded)

update coded_food
set nutritional_check = TRY_CONVERT (int, nutritional_check)

update coded_food
set diet_current_coded = TRY_CONVERT (int, diet_current_coded)

update coded_food
set on_off_campus = TRY_CONVERT (int, on_off_campus)

update coded_food
set grade_level = TRY_CONVERT (int, grade_level)

select 
	GPA, Gender, breakfast, calories_day,  cook, comfort_food_reasons_coded,
	diet_current_coded, eating_changes_coded, eating_changes_coded1, eating_out, employment,
	exercise, fav_cuisine_coded, fav_food, fruit_day, grade_level, healthy_feeling,
	ideal_diet_coded, income, life_rewarding, nutritional_check, on_off_campus, 
	self_perception_weight, sports, veggies_day, vitamins, weight,
case
	when calories_day= 1 then 'Does not know'
	when calories_day= 2 then 'Not at all important'
	when calories_day= 3 then 'Moderately important'
	when calories_day= 4 then 'Very Important'
	else 'Unknown' end as importance_calories,
case
	when Gender= 1 then 'Female'
	when Gender= 2 then 'Male'
	else 'Unknown' end as gender,
case 
	when ideal_diet_coded= 1 then 'Portion control'
	when ideal_diet_coded= 2 then 'Adding veggies/fruits'
	when ideal_diet_coded= 3 then 'Balance'
	when ideal_diet_coded= 4 then 'Less sugar'
	when ideal_diet_coded= 5 then 'Homecooked/Organic'
	when ideal_diet_coded= 6 then 'Current diet'
	when ideal_diet_coded= 7 then 'More protein'
	when ideal_diet_coded= 8 then 'Unclear'
	else 'Unknown' end as ideal_diet,
case 
	when comfort_food_reasons_coded= 1 then 'Stress'
	when comfort_food_reasons_coded= 2 then 'Boredom'
	when comfort_food_reasons_coded= 4 then 'Hunger'
	when comfort_food_reasons_coded= 5 then 'Laziness'
	when comfort_food_reasons_coded= 6 then 'Cold Weather'
	when comfort_food_reasons_coded= 7 then 'Happiness'
	when comfort_food_reasons_coded= 8 then 'Watching TV'
	when comfort_food_reasons_coded= 3 then 'Depression/Sadness'
	when comfort_food_reasons_coded= 9 then 'other'
	else 'Unknown' end as comfort_reasons,
case 
	when nutritional_check= 1 then 'Never'
	when nutritional_check= 2 then 'Certain products'
	when nutritional_check= 3 then 'Rarely'
	when nutritional_check= 4 then 'Most products'
	when nutritional_check= 5 then 'Always'
	else 'Unknown' end as nutritional_value,
case
	when diet_current_coded= 1 then 'Healthy/Balanced'
	when diet_current_coded= 2 then 'Unhealthy/Cheap/Random'
	when diet_current_coded= 3 then 'Same thing over and over'
	when diet_current_coded= 4 then 'Unclear'
	else 'Unknown' end as current_diet,
case 
	when on_off_campus= 1 then 'On campus'
	when on_off_campus= 2 then 'Off campus'
	when on_off_campus= 3 then 'Live with parents'
	when on_off_campus= 4 then 'Own house'
	else 'Unknown' end as campus_living,
case 
	when grade_level= 1 then 'Freshman'
	when grade_level= 2 then 'Sophomore'
	when grade_level= 3 then 'Junior'
	when grade_level= 4 then 'Senior'
	else 'Unknown' end as grade
from coded_food;
