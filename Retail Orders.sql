select * from df_retail

--Top 10 Highest Revenue Generating Products
select top 10 product_id, sum(sale_price*quantity) as Revenue
from df_retail
group by product_id
order by Revenue desc

--Top Highest Selling Products In Each Region
with cte as (
select region,product_id,sum(sale_price) as Sales
from df_retail
group by region,product_id)
select * from (
select *
, row_number() over(partition by region order by Sales desc) as rn
from cte) A
where rn<=5

--Growth Comparison For 2022 and 2023 Sales eg : jan 2022 vs jan 2023
with cte as (
select year(order_date) as Order_Year,month(order_date) as Order_Month,sum(sale_price) as Sales
from df_retail
group by year(order_date),month(order_date)
--order by year(order_date),month(order_date)
	)
select Order_Month
, sum(case when Order_Year=2022 then Sales else 0 end) as Sales_2022
, sum(case when Order_Year=2023 then Sales else 0 end) as Sales_2023
from cte
group by Order_Month
order by Order_Month


--Highest Sales for Each Category by Month
with cte as (
select category,format(order_date,'yyyyMM') AS Order_Year_Month
, sum(sale_price) as Sales
from df_retail
group by category,format(order_date,'yyyyMM')
--order by category,format(order_date,'yyyyMM')
)
select * from (
select *,
ROW_NUMBER() over(partition by category order by Sales desc) as rn
from cte
) A
where rn=1


--Highest Growth by Profit for Sub category in 2023 Compare to 2022
with cte as (
select sub_category,year(order_date) as Order_Year,sum(sale_price) as Sales
from df_retail
group by sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when Order_Year=2022 then Sales else 0 end) as Sales_2022
, sum(case when Order_Year=2023 then Sales else 0 end) as Sales_2023
from cte
group by sub_category
)
select top 5*
,(sales_2023-sales_2022) as profit
from cte2
order by (sales_2023-sales_2022) desc

