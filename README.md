# SQL_PROJECTS_NAMMA_YATRI_APP

--Total number of trips?
select count(distinct tripid) no_of_trip from trips

--For the above to check any duplicates?     THE RESULT SHOWS THERE ARE NO DUPLICATES
select tripid, count(tripid) as cnt from trips_details4
group by tripid having count(tripid)>1 

--Toatl number of drivers?
select count(distinct driverid) no_of_drivers from trips

--NUMBER OF DRIVER FOR EACH DRIVERID (MN)

select driverid, count(driverid) as no_of_drivers from trips
group by driverid having count(driverid)>1 

--To find total earnings 
Select SUM(fare) TotEarn from trips

--Total completed Trips
select count(distinct tripid) from trips 

--Total number of searches for trips
Select sum(searches) from trips_details4

--Aliter
Select sum(searches) from trips_details4

--Total number of searches that got estimates for ride bookings
select sum(searches_got_estimate) Totest from trips_details4

--ALITER
select count(searches_got_estimate) Totest from trips_details4 where searches_got_estimate=1

--Total searches for quotes
select sum(searches_for_quotes) quotes from trips_details4



--Number of trips not cancelled by drivers
select sum(driver_not_cancelled) TotCAN from trips_details4 

--Number of Trips cancelled by drivers
select count(driver_not_cancelled) -  sum(driver_not_cancelled) TotCAN from trips_details4 

--Aliter
select count(*) -  sum(driver_not_cancelled) TotCAN from trips_details4 

--Total OTP entered

select SUM(otp_entered) TotOTP from trips_details4 

--Total end ride
select sum(end_ride) TotERIDE from trips_details4 

--Average Distance per trip
select AVG(distance) from trips

--Average fare per trip
select AVG(fare) from trips

--Total distance travelled
select sum(distance) from trips

--To check the presence for any duplicates in tripid

Select tripid, count(tripid) as count from trips_details4 group by tripid having count(tripid)>1
--Since this doesnt produce any results for tripid>1 means tripid has all unique values, i.e a PRIMARY Key based on which tables could be joined

--To find total number of drivers
select  count(distinct driverid) Tot_Drivers from trips

-- which is the most used payment method
select top 1 faremethod, count(faremethod) as Topfare from trips
group by faremethod order by count(faremethod) desc -- 262 for faremethod 4, but we also need to find the name of the method; SO-

--USING INNER JOIN BECOZ OF COMMONALITY
select a.method from payment a inner join
(select top 1 faremethod, count(faremethod) as Topfare from trips
group by faremethod order by count(faremethod) desc)b
on a.id = b.faremethod


-- the highest payment was made through which instrument
select a.method from payment a inner join
(select top 1 faremethod, sum(fare) as Topfare from trips group by faremethod order by count(faremethod) desc) b
on a.id=b.faremethod-------ANS IS CREDIT WITH TOTAL FARES BEING HIGHEST AS 197941

--Aliter
select a.method from payment a inner join
(select top 1 faremethod, sum(fare) as topfare from trips group by faremethod order by sum(fare) desc) b
on a.id = b.faremethod

--Another
select top 1* from trips order by fare desc

-- which two locations had the most trips
Select* from
(select*,dense_rank() over (order by trip desc) rnk
from 
(select loc_from,loc_to, count(distinct tripid) trip from trips group by loc_from,loc_to )a)b where rnk=1 
--Here a,b are subqueries

--top 5 earning drivers
select top 5 driverid, sum(fare) as Topfare from trips group by driverid order by topfare desc

--Aliter:--(using dense rank n sub-query)--Dense rank was used coz there may be repetitions of drivers earning same amount

select* from
(select*, dense_rank() over(order by fare desc) rnk
from
(select driverid, sum(fare) fare from trips group by driverid)b)c where rnk<6;


-- which duration had more trips
select top 1 duration, count(duration) TotDur from trips group by duration order by TotDur desc

--Aliter [WE PRODUCE RESULTS USING RANKS COZ THERE MAY BE A CHANCE OF INCURRING ERROR DUE TO REPETITIONS]
select* from
(select*, dense_rank() over(order by TotDur desc) rak
from
(select duration, count(duration) TotDur from trips group by duration)as b) as c where rak=1


-- which driver , customer pair had more orders
select* from
(select*, dense_rank() over (order by td desc) as rak
from
(select custid,driverid, count(distinct tripid) as td from trips group by custid,driverid)b)g where rak<2

--Aliter

Select* from
(select*, rank() over(order by cnt desc) rnk from
(select driverid,custid,count (distinct tripid) cnt from trips group by driverid,custid)c)d
where rnk=1


-- search to estimate rate
select sum(searches_got_estimate)*1/sum(searches) from trips_details4  

select sum(searches_got_estimate)*100.0/sum(searches) from trips_details4  --here multiplied with 100 to get a decimal value

-- estimate to search for quote rates

select sum(searches_got_estimate)*100.0/sum(searches_got_quotes) from trips_details4--137.66


-- quote to acceptance rate
select sum(searches_for_quotes)*100.0/sum(driver_not_cancelled) from trips_details4--115.54

-- quote to booking rate
select sum(searches_for_quotes)*100.0/sum(otp_entered) from trips_details4--124.77

-- booking cancellation rate [TO DO]
select count(driver_not_cancelled) -  sum(driver_not_cancelled)*100/sum(otp_entered) from trips_details4 


-- conversion rate
select sum(end_ride)*100.0/sum(searches) from trips_details4--62.23


-- which area got the highest fares?

select* from (select*, rank() over (order by fare desc) rnk
from
(select loc_from, sum(fare) as Fare from trips group by loc_from)b)c
where rnk=1

select a.method from payment a inner join
(select top 1 faremethod, sum(fare) as Topfare from trips group by faremethod order by count(faremethod) desc) b
on a.id=b.faremethod

--Aliter1

select top 1 loc_from, sum(fare) as Fare from trips group by loc_from order by fare desc

--Aliter2  [THIS PROVIDES THE DETAIL FOR THE ASSEMBLY(AREA) AS WELL]
select l.assembly1 from loc l inner join
(select top 1 loc_from, sum(fare) as Fare from trips group by loc_from order by fare desc)b
on l.id = b.loc_from  --BANGALORE



--which area got the highest cancellations
select* from (select*, rank() over (order by can desc) rnk
from
(select loc_from, count(*) - sum(driver_not_cancelled) CAN from trips_details4 group by loc_from)b)c
where rnk=1

--ALITER--
select top 1  loc_from, count(driver_not_cancelled) as CAN from trips_details4 where driver_not_cancelled=0 group by loc_from order by CAN desc 

--Aliter2
select l.assembly1 from loc l inner join
(select top 1  loc_from, count(driver_not_cancelled) as CAN from trips_details4
where driver_not_cancelled=0 group by loc_from order by CAN desc)b
on l.id = b.loc_from --MahadevPura

--which area got the highest trips
select* from (select*, rank() over (order by can desc) rnk
from
(select loc_from, count(*) - sum(customer_not_cancelled) CAN from trips_details4 group by loc_from)b)c
where rnk=1


-- which area got highest trips in which duration---REPEAT
select* from
(select*,rank() over(partition by duration order by cnt desc) rnk from
(select duration,loc_from, count(distinct tripid) cnt from trips
group by duration,loc_from)b)c
where rnk=1
