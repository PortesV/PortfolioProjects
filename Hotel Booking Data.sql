/* 
Selecting all from the database for each tab/year of on the spreadsheet
	and joining them using the union command.
Alias used to stream the revenue from all hotels grouped by year and hotel
*/
WITH hotels as(
SELECT * FROM dbo.['2018$']
union
SELECT * FROM dbo.['2019$']
union
SELECT * FROM dbo.['2020$'])


-- Let's check if revenue is growing yearly:
SELECT 
arrival_date_year,
hotel,
sum((stays_in_week_nights + stays_in_weekend_nights)*adr) AS revenue 
FROM hotels
GROUP BY arrival_date_year, hotel


--SELECT * from dbo.market_segment$

-- Loading to PowerBI, querying hotels per segment joining both tabs and add column for meal cost
WITH hotels as(
SELECT * FROM dbo.['2018$']
union
SELECT * FROM dbo.['2019$']
union
SELECT * FROM dbo.['2020$'])

select * from hotels
join dbo.market_segment$ ON hotels.market_segment = market_segment$.market_segment
left join dbo.meal_cost$ ON meal_cost$.meal = hotels.meal