create table car_data(
car_id serial primary key,
make text,
model text,
fuel text,
gear text,
mileage integer,
price integer,
hp integer,
manufacture_year integer,
offerType text
);

COPY car_data(car_id, make, model, fuel, gear, mileage, price, hp, manufacture_year, offertype)
FROM 'C:/tmp/autoscout24-germany-dataset.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- checking if dataset is correctly imported
select * from car_data limit 5;

-- counting total rows
select count(*) from car_data;
select make,model,count(*) from car_data group by make,model having count(*) >1;

-- Identify the null values
select * from car_data
where 
make is null 
or model is null 
or fuel is null 
or gear is null 
or mileage is null 
or price is null 
or hp is null 
or manufacture_year is null 
or offertype is null;

-- Creating a Temp Table instred of deleting
create table temp_table as
select * from car_data
where 
make is not null 
or model is not null 
or fuel is not null 
or gear is not null 
or mileage is not null 
or price is not null 
or hp is not null 
or manufacture_year is not null 
or offertype is not null;

drop table car_data;

alter table temp_table rename to main_cars;

select * from main_cars;
-- deleting null values 
delete from main_cars
where 
make is null 
or model is null 
or fuel is null 
or gear is null 
or mileage is null 
or price is null 
or hp is null 
or manufacture_year is null 
or offertype is null;

select count(*) from main_cars where fuel='Electric';
select count(*) from main_cars where fuel in ('-/-(Fuel)','LPG','Hydrogen','CNG','Ethanol','Others');

-- Creating separate tables for cars based on their fuel type
create table gas_cars as 
select * from main_cars where fuel='Gasoline';

create table diesel_cars as
select * from main_cars where fuel='Diesel';

create table electric_cars as
select * from main_cars where fuel='Electric/Gasoline';
alter table electric_cars rename to Ele_Gas_cars;

create table Ele_die_cars as 
select * from main_cars where fuel='Electric/Diesel';

create table electric_cars as 
select * from main_cars where fuel='Electric';

create table other_fuel_cars as 
select * from main_cars 
where fuel in ('-/-(Fuel)','LPG','Hydrogen','CNG','Ethanol','Others');


select distinct(gear) from main_cars;

-- Create tables based on Car Gear type
create table manual_gear as 
select * from main_cars where gear='Manual';

create table automatic_gear as 
select * from main_cars where gear='Automatic';

create table semi_auto_gear as 
select * from main_cars where gear='Semi-automatic';

-- Counting all car model in an individual make(means car_company)
select distinct(make),count(model) from main_cars group by make;

select make,model,max(mileage) from main_cars group by main_cars.model,main_cars.make,main_cars.mileage order by main_cars.mileage desc limit 10;
-- Above lengthy code can also write as below
SELECT make, model, mileage,price
FROM main_cars
ORDER BY mileage
LIMIT 5;

-- Above mileage of maximum is showing very high like 11 lakhs so make that as short
update main_cars 
set mileage=mileage/10;

select count(make) from main_cars where mileage between 30000 and 50000;

select make,model,price,mileage from main_cars where mileage between 0 and 15000 limit 10;

select make,model,mileage,max(price) as maxi from main_cars group by make,model,mileage order by maxi desc limit 5;

-- creating a new column to categorising mileage(low,medium,high,very-high)
alter table main_cars
add column mileage_category text;

update main_cars
set mileage_category=
case
when mileage between 0 and 15000 then 'Low Mileage'
when mileage between 15001 and 30000 then 'Medium Mileage'
when mileage between 30001 and 50000 then 'High Mileage'
when mileage >50000 then 'Very High Mileage'
else 'unknown'
end;

select * from main_cars limit 5;
-- Note: If we don’t want to modify the table directly, then we can create a view instead.

-- creating separate tables to cars based on their horsepower 

select count(*) from main_cars where hp<200;

select max(hp) from main_cars;
select make,model,min(hp) from main_cars group by make,model,hp order by hp;

-- As per standards minimum hp of a car is around 50 so delete cars less than 40
delete from main_cars where hp<40;

select count(*) from main_cars where hp between 40 and 120; -- low power(family)
select count(*) from main_cars where hp between 121 and 220; -- moderate(family)
select count(*) from main_cars where hp between 221 and 500; -- high power(racing)
select count(*) from main_cars where hp>500; -- max power(racing)

-- create a separate column for categorising horse power of car
alter table main_cars
add column hp_category text;

update main_cars
set hp_category =
case 
when hp between 40 and 120 then 'Low Power'
when hp between 121 and 220 then 'Moderate Power'
when hp between 221 and 500 then 'High Power'
when hp>500 then 'Max Power'
else 'No Power'
end;

select * from main_cars where hp>500 limit 5;
select max(manufacture_year) from main_cars;
select count(model) from main_cars where manufacture_year between 2011 and 2015;

select count(model) from main_cars where manufacture_year between 2016 and 2021;

-- Add column for separating cars based on their manufacture year
-- manufactured from 2010 to 2015 as old cars and 2016 to 2021 as new cars
alter table main_cars
add column separate_cars text;

update main_cars
set separate_cars=
case
when manufacture_year between 2011 and 2015 then 'Old Car'
when manufacture_year between 2016 and 2021 then 'Latest Car'
else 'No car'
end;

select * from main_cars where limit 3;

-- Generate Average Car price
select avg(price) as oldcars from main_cars where separate_cars='Old Car'; -- for old cars
select avg(price) as newcars from main_cars where separate_cars='Latest Car'; -- for new cars
select avg(price) as allcars from main_cars; -- for all cars

-- Advance SQL Topics to make data clean and clear.
-- CTE and SubQuery means query inside the query, to generate temporary tables.

-- 1) Finding expensive car in each fuel type
select make,model,price,fuel,hp from main_cars as mc
where price =(
select max(price) from main_cars
where fuel=mc.fuel
);
-- In above i used subquery for a large dataset so it run that query for more than 3 min but the result is not displayed,
-- So we dont perform tasks with sub querirs for larger dataset use CTE instread

with max_price_fuel as (
select fuel, max(price) as maxi from main_cars group by fuel
)
select mc.make,mc.model,mc.price,mc.fuel,mc.hp from main_cars as mc
join max_price_fuel as mpf 
on mc.fuel=mpf.fuel and mc.price=mpf.maxi;

-- 2) Calculate the average price of each mileage group
with mileage_groups as (
select *,
case
when mileage between 0 and 15000 then 'Low Mileage'
when mileage between 15001 and 30000 then 'Medium Mileage'
when mileage between 30001 and 50000 then 'High Mileage'
when mileage >50000 then 'Very High Mileage'
else 'unknown'
end as mileage_group
from main_cars
)
select mileage_group,round(avg(price))  as average_price
from mileage_groups
group by mileage_group
order by average_price desc;

-- 3)Count the Number of Cars for Each Manufacturer in a Given Year Range
select make,count(*) as total_cars from main_cars
where manufacture_year between 2015 and 2021 
group by make
order by total_cars desc;

-- 4) Identify Cars with Above-Average Horsepower for Each Fuel Type
with abv_cars_hp as(
select fuel,avg(hp) as avg_hp from main_cars
group by fuel
)
select mc.make,mc.model,mc.fuel,mc.hp,mc.price from main_cars as mc
join abv_cars_hp as chp
on mc.fuel=chp.fuel
where mc.hp>chp.avg_hp
order by mc.hp desc;

-- 5) Find the Cheapest Car for Each Mileage Group
with cheap_cars as(
select *,
case
when mileage between 0 and 15000 then 'Low Mileage'
when mileage between 15001 and 30000 then 'Medium Mileage'
when mileage between 30001 and 50000 then 'High Mileage'
when mileage >50000 then 'Very High Mileage'
else 'unknown'
end as mileage_group
from main_cars
)
select make,model,mileage_group,min(price) as cheap_one 
from cheap_cars
group by mileage_group,make,model
order by mileage_group,cheap_one asc;

-- 6) Analyze Trends in Horsepower Over the Years
with trends_hp as(
select manufacture_year,round(avg(hp)) as avg_hp,max(hp) as maxi,min(hp) as mini from main_cars
group by manufacture_year
)
select * from trends_hp 
order by manufacture_year desc;

select * from main_cars;

-- 7) Find Cars with the Highest Mileage in Each HP Category
with hp_cate as (
select hp_category,max(mileage) as maxi_m from main_cars
group by hp_category
)
select mc.make,mc.model,mc.hp_category,mc.mileage from main_cars as mc
join hp_cate as hc
on mc.hp_category=hc.hp_category and mc.mileage=hc.maxi_m;

-- 8) Determine the Percentage of Each Fuel Type in the Dataset
with fuel_percent as (
select fuel,count(*) as fuel_count from main_cars
group by fuel
)
select fuel,fuel_count,round((fuel_count*100.0)/(select count(*) from main_cars),2) as percentage
from fuel_percent
order by percentage desc; 

-- 9) Identify the Manufacturer with the Most Expensive Average Price
with most_avg_exp as (
select make,avg(price) as amp from main_cars
group by make
)
select make,amp from most_avg_exp 
where amp=(select max(amp) from most_avg_exp);

-- Window Functions
-- 1) find most expensive car in each fuel type
select make,model,fuel,price,
rank() over(partition by fuel order by price desc) as car_rank
from main_cars;

-- 2) Rank cars based on mileage within each hp_category and display the top 3 cars.
with ranked_cars as (
select make,model,mileage,hp_category,
row_number() over(partition by hp_category order by mileage desc) as row_num
from main_cars)
select make,model,mileage,hp_category,row_num from ranked_cars
where row_num <= 3;

-- 3) Calculate the cumulative sum of mileage for cars grouped by their fuel type.
select make,model,fuel,mileage,
sum(mileage) over(partition by fuel order by mileage) as cumulative_mileage
from main_cars;

-- 4) Compute the average price of cars in each fuel type and compare it with individual car prices.
select make,model,fuel,price as original_price,
avg(price) over (partition by fuel) as average_price
from main_cars;

-- 5) Find the difference in price between consecutive cars based on their manufacture year.
select make,model,manufacture_year,price,
price-lag(price) over (order by manufacture_year) as lag_price
from main_cars;

-- 6) Show the next car's price for each car based on descending mileage.
select make,model,price,mileage,
lead(price) over(order by mileage desc) as lead_price
from main_cars;

-- 7) Divide the cars into 4 price categories (quartiles) based on their price.
-- solve this using NTILE -> it distribute rows into buckets
select make,model,price,
ntile(4) over (order by price) as price_quartile
from main_cars;

-- 8) Find the median mileage for cars grouped by fuel type.
-- PERCENT_RANK() or calculate mid-points using window functions.
select make,model,fuel,mileage,
percent_rank() over(partition by fuel order by mileage desc) as median_mileage
from main_cars;

-- 9)Find the first and last car based on mileage for each fuel type.
-- Use FIRST_VALUE() and LAST_VALUE().
select fuel,make,model,mileage,
first_value(make) over (partition by fuel order by mileage) as first_car,
last_value(make) over(partition by fuel order by mileage 
rows between unbounded preceding and unbounded following) as last_car 
-- above line tells us unbounded preceding means start row and following me end row
from main_cars;

select * from main_cars;
-- 10) Find cars with the highest horsepower in each mileage category.
select make,model,hp,mileage_category,
rank() over(partition by mileage_category order by hp desc) as car_power
from main_cars;

-- learn about all joins how it works
-- SQL END HERE