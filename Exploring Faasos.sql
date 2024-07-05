drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2020 21:30:45','25km','25mins',null),
(8,2,'01-10-2020 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2020 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

--HOW MANY ROLLS WERE ORDERED?
 select COUNT(customer_id) from customer_orders
 --ALITER
 select COUNT(roll_id) from customer_orders

 --HOW MANY UNIQUE CUSTOMERS ORDERS WERE MADE?
 select COUNT(distinct customer_id) from customer_orders

 --How many successful orders WERE DELIVERED BY EACH OF DRIVERS?
 select driver_id, count(distinct order_id) as suc_orders from driver_order 
 where cancellation not in ('Cancellation', 'Customer Cancellation') group by driver_id

 --HOW MANY EACH TYPE OF ROLL WAS DELIVERED? 22:00
 select roll_id, count(roll_id) from customer_orders group by roll_id --(BUT THIS INCLUDES THE CNCELLED ONE'S, HENCE NEEDS TO CLEAN)

 --ALITER

 --HERE FIRST WE NEED TO CLEAN THE DATASET

 select*, case when cancellation in('Cancellation','Customer Cancellation') then 'C' else 'NC' end as order_Cancelled from driver_order;
 -- SO NOW USING THE SAME RESULT WE'LL FIND THE ORDER_ID WHERE ORDE_CANCELLED = 'NC'

select* from
( select*, case when cancellation in('Cancellation','Customer Cancellation') then 'C' else 'NC' 
end as order_Cancelled from driver_order)a where order_Cancelled = 'NC' --THIS WUD GIVE US THE ALL THE ORDERED ROLLS

--ALSO THE COUNT
select
count('NC') Count_of_roll_type FROM ( select*, case when cancellation in('Cancellation','Customer Cancellation') then 'C' else 'NC' 
end as order_Cancelled from driver_order)a where order_Cancelled = 'NC'


--BUT NOW TO FIND THE NUMBER OF ROLLS ORDERED, THE DATA ACTUALLY IS AVAILABLE ON CUSTOMERS ORDER.
--SO INSTEAD OF JOINING THIS RESULT WITH THE CUATOMER_ORDER TABLE, WE CAN FIRST SELECT THE IRDER_ID FROM THIS RESULT AND 
--THEN USE IT TO IDENTIFY THE THOSE ORDER_ID WHICH ARE AS 'NC' WIZ BASED ON THEIR MATCHING,SO[select * from customer_orders]

select order_id from
( select*, case when cancellation in('Cancellation','Customer Cancellation') then 'C' else 'NC' 
end as order_Cancelled from driver_order)a where order_Cancelled = 'NC'

--Now joining this result to get all the details from the customer_id table including the roll_id
select* from customer_orders where order_id in(
select order_id from
( select*, case when cancellation in('Cancellation','Customer Cancellation') then 'C' else 'NC' 
end as order_Cancelled from driver_order)a where order_Cancelled = 'NC')--NOW THESE ARE THOSE WHICH ACTUALLY INCLUDES THE NON-CANC ORDERS

--FINALLY, Now counting the rolls
select roll_id, count(roll_id) from
 customer_orders where order_id in(
select order_id from
( select*, case when cancellation in('Cancellation','Customer Cancellation') then 'C' else 'NC' 
end as order_Cancelled from driver_order)a where order_Cancelled = 'NC') group by roll_id


--Q) how many veg and non veg rolls were ordered by each of the customers?
select customer_id, roll_id, count(roll_id) as cnt from customer_orders group by customer_id,roll_id

--ALITER

select a.*,b.roll_name from(
select customer_id, roll_id, count(roll_id) as cnt from customer_orders group by customer_id,roll_id
)a inner join rolls b on a.roll_id = b.roll_id

--Q) What was the maximum number of rolls delivered in a single order?
select order_id,  count(roll_id) as cnt from customer_orders group by order_id order by cnt desc

--BUT HERE SINCE WE ARE ONLY CONCERNED WITH THE MAX NUMBER OF ROLLS DELIVERED, SO HERE WE NEED TO CONCENTRATE ON THOSE ORDE_ID'S 
--WHICH WERE DELIVERED SUCCESSFULLY. FOR THIS WE'LL USE THE PREVIOUS COMMAND WHERE WE HAVE FOUND N FILTERED THOSE ORDER IDS 
--WHICH WERE DELIVERED AND THEN MERGING IT WITH THE CUSTOMER_ORDERS TABLE.

select* from customer_orders where order_id in(
select order_id from
( select*, case when cancellation in('Cancellation','Customer Cancellation') then 'C' else 'NC' 
end as order_Cancelled from driver_order)a where order_Cancelled = 'NC')
--THIS MERGING GIVES RESULTS OF THOSE ORDERS WHICH WERE DELIVERED FROM THE CUST_ORDERS

--NOW WE'LL GROUP N COUNT THE ROLL_ID TO FIND THE NUMBER OF ROLL FOR EACH ORDERS
select order_id,COUNT(roll_id) from(
select* from customer_orders where order_id in(
select order_id from
( select*, case when cancellation in('Cancellation','Customer Cancellation') then 'C' else 'NC' 
end as order_Cancelled from driver_order)a where order_Cancelled = 'NC'))b group by order_id

-- FIND THE MAX NUMBER OF ROLLS DELIVERED 
select* from (
select*, rank() over (order by cnt desc) rak from (
select order_id,COUNT(roll_id) cnt from(
select* from customer_orders where order_id in(
select order_id from
( select*, case when cancellation in('Cancellation','Customer Cancellation') then 'C' else 'NC' 
end as order_Cancelled from driver_order)a where order_Cancelled = 'NC'))b group by order_id)c)d where rak<2

select order_id,  count(roll_id) as cnt from customer_orders group by order_id order by cnt desc


--Q) FOR EACH CUSTOMER, HOW MANY DELIVERED ROLLS HAD ATLEAST 1 CHANGE AND HOW MANY HAD NO CHANGES?
select* from customer_orders
--FOR THIS WE NEED TO USE THE EXTRA_ITEMS_INCLUDED COLUMN OF THE CUSTOMER_ORDERS TABLE. BUT SINCE IT'S AN UNCLEANED ONE, 
--SO WE SHALL FIRST CLEAN AND CREATE TEMPORARY TABLE USING WHICH WE CAN WORK WITH THE QUERIES

with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is NULL or not_include_items = ' ' then '0' else not_include_items end as new_not_included_items,
case when extra_items_included is null or extra_items_included = ' ' or extra_items_included = 'NaN' or 
extra_items_included = 'NULL' then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)

select* from temp_customer_orders

--NOW PERFORMING THE SAME CLEANING DRIVER_ORDER

with temp_driver_order (order_id,driver_id,pickup_time,distance,duration,cancellation) as
(
select order_id,driver_id,pickup_time,

case when distance is null then '0' else distance end as new_distance,
case when duration is null then '0' else duration end as new_duration,
case when cancellation in ('Cancellation', 'Customer Cancellation') then '0' else 1 end as new_cancellation
from driver_order
)
select* from temp_driver_order

--Now coming to the question
--Q) FOR EACH CUSTOMER, HOW MANY DELIVERED ROLLS HAD ATLEAST 1 CHANGE AND HOW MANY HAD NO CHANGES?
with temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,

case when distance is null then '0' else distance end as new_distance,
case when duration is null then '0' else duration end as new_duration,
case when cancellation in ('Cancellation', 'Customer Cancellation') then '0' else 1 end as new_cancellation
from driver_order
)
select* from temp_driver_order where new_cancellation != 0  --orders which were successfully delivered

--now to find the delivered rolls which had atleast one change, for that we need to join the two tables
--[new customer orders N new driver ordes]
with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is NULL or not_include_items = ' ' then '0' else not_include_items end as new_not_included_items,
case when extra_items_included is null or extra_items_included = ' ' or extra_items_included = 'NaN' or 
extra_items_included = 'NULL' then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)
,
temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,

case when distance is null then '0' else distance end as new_distance,
case when duration is null then '0' else duration end as new_duration,
case when cancellation in ('Cancellation', 'Customer Cancellation') then '0' else 1 end as new_cancellation
from driver_order
)
select* from temp_customer_orders where order_id in (
select order_id from temp_driver_order where new_cancellation != 0)--Now from this we'll find those orders which made any changes

--NOW TO INCLUDE ORDERS that had atleast one change we need to count both whether extra item added as well as items, so in the EQN
with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is NULL or not_include_items = ' ' then '0' else not_include_items end as new_not_included_items,
case when extra_items_included is null or extra_items_included = ' ' or extra_items_included = 'NaN' or extra_items_included = 'NULL'
then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)
,
temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,

case when distance is null then '0' else distance end as new_distance,
case when duration is null then '0' else duration end as new_duration,
case when cancellation in ('Cancellation', 'Customer Cancellation') then '0' else 1 end as new_cancellation
from driver_order
)
select*, case when not_include_items = '0' and extra_items_included = '0' then 'no change' else 'change' end as chg_no_chg
from temp_customer_orders where order_id in (
select order_id from temp_driver_order where new_cancellation != 0)
-- THIS QUERY HELPS IDENTIFY THOSE ORDERS WHERE CHANGES WERE MADE WHERE ALL NO CHANGES


--NOW FINALLY FINDING THE ANSWERS--Q) FOR EACH CUSTOMER, HOW MANY DELIVERED ROLLS HAD ATLEAST 1 CHANGE AND HOW MANY HAD NO CHANGES?
with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is NULL or not_include_items = ' ' then '0' else not_include_items end as new_not_included_items,
case when extra_items_included is null or extra_items_included = ' ' or extra_items_included = 'NaN' or 
extra_items_included = 'NULL' then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)
,
temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,

case when distance is null then '0' else distance end as new_distance,
case when duration is null then '0' else duration end as new_duration,
case when cancellation in ('Cancellation', 'Customer Cancellation') then '0' else 1 end as new_cancellation
from driver_order
)
select customer_id,chg_no_chg, count(customer_id) as atleast_change from
(
select*, case when not_include_items = '0' and extra_items_included = '0' then 'no change' else 'change' end as chg_no_chg
from temp_customer_orders where order_id in (
select order_id from temp_driver_order where new_cancellation != 0))a
group by customer_id,chg_no_chg


--Q) HOW MANY ROLLS WERE DELIVERED THAT HAD [BOTH] EXCLUSIONS AND EXTRAS?
with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is NULL or not_include_items = ' ' then '0' else not_include_items end as new_not_included_items,
case when extra_items_included is null or extra_items_included = ' ' or extra_items_included = 'NaN' or 
extra_items_included = 'NULL' then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)
,
temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,

case when distance is null then '0' else distance end as new_distance,
case when duration is null then '0' else duration end as new_duration,
case when cancellation in ('Cancellation', 'Customer Cancellation') then '0' else 1 end as new_cancellation
from driver_order
)
select chg_no_chg, count(chg_no_chg) as atleast_change from
(
select*, case when not_include_items > '0' and extra_items_included > '0' then 'both incl-excl' else 
'either -nc-excl' end as chg_no_chg
from temp_customer_orders where order_id in (
select order_id from temp_driver_order where new_cancellation != 0))a
group by chg_no_chg


--Q) WHAT WAS THE TOTAL NUMBER OF ROLLS ORDERED FOR EACH HOUR OF THE DAY?
select* from customer_orders
--from this we need to first extract the time and then group them in hour wise by dividing the hrs into hours of the day

select*, datepart(hh,order_date) as HRS from customer_orders--now to create time stamp like data, we'll first
--add +1 hr to the hour extracted using which we'll create a time-interval

select*, datepart(hh,order_date), datepart(hh,order_date)+1 as HRS from customer_orders--now we can concatenate the two times found

select*, concat(cast(datepart(hh,order_date) as varchar),'-',cast(datepart(hh,order_date)+1 as varchar)) as HRS_BUCKET from 
customer_orders
--ALSO WITHOUT VARCHAR
select*, concat(datepart(hh,order_date),'-',datepart(hh,order_date)+1) as HRS_BUCKET from customer_orders

--NOW COMING BACK TO THE QUESTION
select HRS_BUCKET,COUNT(HRS_BUCKET)as rolls_ordered from
(select*, concat(cast(datepart(hh,order_date) as varchar),'-',cast(datepart(hh,order_date)+1 as varchar))
as HRS_BUCKET from customer_orders)a
group by HRS_BUCKET

--Q) WHAT WAS THE NUMBER OF ORDERS FOR EACH DAY OF THE WEEK?
select day_week,count(distinct order_id) from
(select*, datename(Dw,order_date) as day_week from customer_orders)a
group by day_week


--Q)WHAT WAS THE AVERAGE TIME IN MINUTES IT TOOK FOR EACH DRIVER TO ARRIVE AT THE FAASOS HQ TO PICKUP THE ORDER?

--Now to calculate the average time taken by each driver, we first need to find the actual time diff
--b/w when order was placed and when and driver reached the HQ, which is availble in both customer_order, and driver_order. 
--Hence we'' first join the 2 based on order_id, count the difference in in mints, 
--then count the orders to finally divide to obtain the average.

--Here we'll perform the inner join to join the customer and driver table
select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation from customer_orders
a inner join driver_order b on a.order_id = b.order_id;
--as we can see there nul values in pickup time for cancelled items, hence have to be removed

select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.pickup_time is not null
--now need to find the diff in time in minutes

select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.pickup_time is not null
--here as we can observe duplicacy of order_id as the data may be stored when placing the order and 
--the pickup was done for thwe same order hence we need to remove it

select*, row_number() over(partition by order_id order by diff) rak from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.pickup_time is not null)a;
--now using this finding only the single order_id

select* from
(select*, row_number() over(partition by order_id order by diff) rak from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.pickup_time is not null)a)b where rak = 1

--Finally using this we'll find the average time(FOR EACH DRIVER)-

--Q)WHAT WAS THE AVERAGE TIME IN MINUTES IT TOOK FOR EACH DRIVER TO ARRIVE AT THE FAASOS HQ TO PICKUP THE ORDER?
select driver_id,sum(diff)/count(order_id) as avg from
(select* from
(select*, row_number() over(partition by order_id order by diff) rak from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.pickup_time is not null)a)b where rak = 1)c
group by driver_id

--P3
--Q) IS THERE ANY RELATIONSHIP BETWEEN THE NUMBER OF ROLLS AND HOW LONG THE ORDER TAKES TO PREPARE?

--To calculate any relation b/w number of rols ordered n the time it takes to prepare, we'll use query that finds the time diff b/w 
--order_date n pickup_time, and from this count the roll_id group by order_id

--Q) IS THERE ANY RELATIONSHIP BETWEEN THE NUMBER OF ROLLS AND HOW LONG THE ORDER TAKES TO PREPARE?
select order_id, count(roll_id) as count_roll, sum(diff)/count(roll_id) avg_tym from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.pickup_time is not null)a
group by order_id;
-- Here count of roll_id gives the number of rolls ordered. Further, we've found sum of diff and div by count of roll_id coz
-- as we can see in the time querry there are repetitive orders(like 3, 4) means diff number of roll were ordered for the same order id
--and since for each order the time should remain the same, so we need to divide sum of diff by no. of roll_id, otherwise just summing 
--would show 42 for order_id 102 instead should have been 21.

--Q) AVERAGE DISTANCE TRAVELLED FOR EACH OF CUSTOMER?

select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.distance is not null 
--from this we need to use rank so that there is only 1 order_id for each customer i.e to have single row for single order[coz makes no sense as it wud repesat the values]

select* from
(select*, row_number() over(partition by order_id order by diff) rak from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.distance is not null)a)b where rak = 1
--But still with this we still cant find the avg distance coz distance column is not complete integer or float. Hence, we first need to
--replace the 'km' values

select* from
(select*, row_number() over(partition by order_id order by diff) rak from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,replace(lower(b.distance),'km','') as distance,
b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.distance is not null)a)b where rak = 1--Now we can find the average

select customer_id,sum(distance)/count(order_id)from
(select* from
(select*, row_number() over(partition by order_id order by diff) rak from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,replace(lower(b.distance),'km','') as distance,
b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.distance is not null)a)b where rak = 1)c
group by customer_id;
--but tis result wud still show error coz if we closely look in the original distance col, we'll find that 
--there is some space b/w the last digit of the value and 'km'. So that also needs to be removed using trim

select customer_id,sum(distance)/count(order_id)from
(select* from
(select*, row_number() over(partition by order_id order by diff) rak from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,trim(replace(lower(b.distance),'km','')) as distance,
b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.distance is not null)a)b where rak = 1)c
group by customer_id;
--but still it shows error coz the distance col is varchar type. Hence we also need to convert it into decimal type.

--SO FINALLY-
select customer_id,sum(distance)/count(order_id) avg_dist from
(select* from
(select*, row_number() over(partition by order_id order by diff) rak from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,cast(trim(replace(lower(b.distance),'km','')) as decimal(4,2))as distance,
b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) diff from customer_orders
a inner join driver_order b on a.order_id = b.order_id where b.distance is not null)a)b where rak = 1)c
group by customer_id

--Q) WHAT WAS THE DIFFERENCE B/W THE LONGEST AND THE SHORTEST DELIVERY TIMES FOR ALL ORDERS?

--For this we first ned to clean and extract integer value from the duration column as well as remove null values
select* from driver_order where duration is not null

--now to obtain the integer values from the column we'll use left and charindex fns
select duration,case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration
end as duration from driver_order
where duration is not null;
--[%min% means min is present in whichever row] - n if like opertor is not used then wud throw error coz not all
-- rows had 'm' present within

--Also, like the previuos case, this calculated duration column is a varchar type. hence needs to covert this as well
select duration,cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration
end as integer)as duration from driver_order
where duration is not null

--just to check
select sum(duration) from
(select cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration
end as integer)as duration from driver_order
where duration is not null)a

--Now to finally find the difference b/w the longest and shortes delivery time
select max(duration) MX, min(duration)MN from
(select cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration
end as integer)as duration from driver_order
where duration is not null)a

--Finally--WHAT WAS THE DIFFERENCE B/W THE LONGEST AND THE SHORTEST DELIVERY TIMES FOR ALL ORDERS?

select max(duration) - min(duration) as DIFF from
(select cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration
end as integer)as duration from driver_order
where duration is not null)a


--Q) WHAT WAS THE AVERAGE SPEED FOR EACH DELIVERY AND WHAT TREND DO YOU NOTICE FOR THESE VALUES?
select driver_id, round((sum(distance)/sum(duration)),3) as avg from
(select order_id,driver_id, cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration
end as integer)as duration,
cast(trim(replace(lower(distance),'km','')) as decimal(4,2))as distance
from driver_order
where duration is not null)a group by driver_id

--ALITER
select driver_id, distance/duration as avgspeed from
(select order_id,driver_id, cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration
end as integer)as duration,
cast(trim(replace(lower(distance),'km','')) as decimal(4,2))as distance
from driver_order
where duration is not null)a --as here we may see that it does not include any relation of driver_id and avg speed,hence
--we'll try a relation b/w no.of rolls vs speed. so,

--Q) WHAT WAS THE AVERAGE SPEED FOR EACH DELIVERY AND WHAT TREND DO YOU NOTICE FOR THESE VALUES?
select a.driver_id, a.distance/duration as avgspeed,b.cnt from
(select order_id,driver_id, cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration
end as integer)as duration,
cast(trim(replace(lower(distance),'km','')) as decimal(4,2))as distance
from driver_order
where duration is not null)a inner join
(select order_id,count(roll_id) cnt from customer_orders group by order_id)b on a.order_id = b.order_id


--Q)WHAT IS THE SUCCESSFUL DELIVERY PERCENTAGE FOR EACH DRIVER?

--Now to find the successful delivery percentage, the formula is total orders successfuly delivered/ total orders taken
--but for this, we need to find the succesful delveries by removing cancelled orders from the cancellation column
select* from driver_order

select driver_id,sum(can_num) as s,count(driver_id) as t from
(select driver_id,case when lower(cancellation) like '%cancel%' then 0 else 1 end as can_num from driver_order)a
group by driver_id--now using this data we'll find the %age for each driver

--Finally
select driver_id,s*100/t from
(select driver_id,sum(can_num) as s,count(driver_id) as t from
(select driver_id,case when lower(cancellation) like '%cancel%' then 0 else 1 end as can_num from driver_order)a
group by driver_id)b 