create database coffe_shop;
select count(*) from coffee_shop_sales;
describe coffee_shop_sales;
set sql_safe_updates=0;

update coffee_shop_sales
set transaction_date= str_to_date( transaction_date,"%d-%m-%Y");

alter table coffee_shop_sales
modify column  transaction_date date;

describe coffee_shop_sales;

update coffee_shop_sales
set transaction_time= str_to_time(transaction_time,"%H:%i:%s");

alter table coffee_shop_sales
modify column  transaction_time time;

select * from coffee_shop_sales;

-- month wise Total sales 
select concat(round(sum(unit_price*transaction_qty))/1000,"k") as Total_Sales
from coffee_shop_sales
where 
month(transaction_date)=3;



-- month over month  sales increase percentage

with a as (select month(transaction_date) as Month_Of_year,
round(sum(unit_price*transaction_qty),1) as total_sales,
lag(round(sum(unit_price*transaction_qty),1))over(order by month(transaction_date) )as lag1
from coffee_shop_sales
group by month(transaction_date) 
order by month(transaction_date))
select *, round((total_sales-lag1)/lag1 * 100) as percent_change 
from a 
where month_of_year>1;


-- difference in total sales of selected and previous month

select month(transaction_date),
round((sum(unit_price*transaction_qty))-lag(sum(unit_price*transaction_qty))over(order by month(transaction_date) ),1)
  as change_in_sales_in_month
from coffee_shop_sales
group by month(transaction_date)
order by month(transaction_date);

-- total_orders of respective month

with a as (select  month(transaction_date) as month_of_year,
count(transaction_id) as no_of_orders
from coffee_shop_sales
group by month(transaction_date)
order by  month(transaction_date))

select no_of_orders 
from a
where month_of_year=3;

-- month over month  orders increase percentage
 with a as (select month(transaction_date) as Month_Of_year,
 count(transaction_id) as no_of_orders,
lag(count(transaction_id))over(order by month(transaction_date) )as lag1
from coffee_shop_sales
group by Month_of_year 
order by Month_of_year )

select Month_of_year,
round(((no_of_orders-lag1)/lag1*100),1) as diff_of_orders
from a
where Month_of_year=5;

-- total quantity sold of respective month

select sum(transaction_qty) as total_qty_sold from coffee_shop_sales
where month(transaction_date)= 6;


-- month over month qty sold increase per
with a as(select month(transaction_date) as Month_Of_year,
sum(transaction_qty) as total_qty_sold,
lag(sum(transaction_qty))over(order by month(transaction_date) )as lag1
from coffee_shop_sales
group by Month_of_year 
order by Month_of_year)

select Month_of_year,round(((total_qty_sold-lag1)/lag1*100),1) as diff_of_qty_sold
from a
where Month_of_year>1;


-- day wise total sales,qty sold, and no of orders

with a as(select transaction_date, 
concat(round(sum(transaction_qty)/1000,1),'k') as total_qty_sold, 
concat(round(count(transaction_id)/1000,1),'k') as total_orders,
concat(round((sum(unit_price*transaction_qty))/1000,1),'k') as total_sales
from coffee_shop_sales
group by transaction_date)

select * from a 
where transaction_date= '2023-03-27';


-- weekdays and weekends sales analysis wrt month 
-- weekends= sat=7, sun=1

with a as(select *,
case 
when dayofweek(transaction_date) in (1,7) then 'weekends'
else 'weekdays'
end as day_type
from coffee_shop_sales)

select day_type, 
concat(round(sum(unit_price*transaction_qty)/1000,1),'k') as total_sales
from a
where month(transaction_date)=5
group by day_type;

-- sales analysis with store loation month wise

select * from coffee_shop_sales;


select store_location,month(transaction_date),
concat(round(sum(unit_price*transaction_qty)/1000,1),'k') as total_sales
from coffee_shop_sales
where month(transaction_date)=6

group by store_location,month(transaction_date)
order by total_sales desc;


-- avg_sales of particular month 
select concat(round(avg(total_sales),1),'k') as avg_monthly_sales
from (
select concat(round(sum(unit_price*transaction_qty)/1000,1),'k') as total_sales,
 month(transaction_date) as Month_,transaction_date
from coffee_shop_sales
where month(transaction_date)=5
group by transaction_date) as t;

-- daily sales of particular month
select day(transaction_date) as day_,
 concat(round(sum(unit_price*transaction_qty)/1000,1),'k') as total_daily_sales
from coffee_shop_sales
where month(transaction_date)=5 -- may
group by transaction_date;


-- sales status per day on the  basis of avg sales of month

select day_,total_daily_Sales,
case 
when avg_monthly_sales>total_daily_Sales then "below average"
when avg_monthly_sales<total_daily_Sales then "above average"
else "equal"
end as sales_status

from(


select day(transaction_date) as day_,
round(sum(unit_price*transaction_qty),1) as total_daily_sales,
avg(round(sum(unit_price*transaction_qty),1)) over() as avg_monthly_sales
from coffee_shop_sales
where month(transaction_date)=5 -- may
group by transaction_date) as rrr;


-- sales analysis by product category

select product_category,round(sum(unit_price*transaction_qty),1) as total_sales
from coffee_shop_sales
where month(transaction_date)= 5
group by product_category
ORDER BY total_sales desc;

--  top 10 products 
select product_type,round(sum(unit_price*transaction_qty),1) as total_sales
from coffee_shop_sales
where month(transaction_date)= 5
group by product_type
ORDER BY total_sales desc
limit 10;

-- sales analysis on basis of day hour
select round(sum(unit_price*transaction_qty),1) as total_sales,

 
sum(transaction_qty) as total_qty_sold,
count(*) as total_orders
from coffee_shop_sales
where month(transaction_date)=5 and 
dayofweek(transaction_date)=2 and 
hour(transaction_time)=8;




-- SALES BY DAY | HOUR

select hour(transaction_time),
round(sum(unit_price*transaction_qty),1) as total_sales
from coffee_shop_sales
where month(transaction_date)=5
group by hour(transaction_time)
order by hour(transaction_time) ;



-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY

select
    case
        when DAYOFWEEK(transaction_date) = 2 then 'Monday'
         when DAYOFWEEK(transaction_date) = 3 then 'Tuesday'
         when DAYOFWEEK(transaction_date) = 4 then 'Wednesday'
         when DAYOFWEEK(transaction_date) = 5 then 'Thursday'
         when DAYOFWEEK(transaction_date) = 6 then 'Friday'
         when DAYOFWEEK(transaction_date) = 7 then 'Saturday'
        else 'Sunday'
    END AS Day_of_Week,
ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
coffee_shop_sales
WHERE
MONTH(transaction_date) = 5 
GROUP BY 
   case
        when DAYOFWEEK(transaction_date) = 2 then 'Monday'
         when DAYOFWEEK(transaction_date) = 3 then 'Tuesday'
         when DAYOFWEEK(transaction_date) = 4 then 'Wednesday'
         when DAYOFWEEK(transaction_date) = 5 then 'Thursday'
         when DAYOFWEEK(transaction_date) = 6 then 'Friday'
         when DAYOFWEEK(transaction_date) = 7 then 'Saturday'
        else 'Sunday'
    END;


