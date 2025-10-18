
-- 1. find the discount ranges for a product id
select 
productid, 
min_discount,
max_discount 
from (
    select 
    productid, 
    min(discountpct) as min_discount, 
    max(discountpct) as max_discount
    from sales_order_details sod 
    join sales_order_header soh 
    on sod.salesorderid = soh.salesorderid
    group by productid
) v
where min_discount <> max_discount
order by productid;

-----------------------------------------------------------------------------------------------
-- 2. find the top 10 customers with highest sales contribution
select 
soh.CustomerID, 
sum(soh.SubTotal) subtotal,
sum(soh.TaxAmt) Taxamt, 
sum(soh.Freight) Freight,
sum(sod.DiscountPct) discountpercent, 
sum(soh.TotalDue) Totaldue
from sales_order_details sod 
join sales_order_header soh 
on sod.salesorderid = soh.salesorderid
group by soh.CustomerID 
order by Totaldue desc
limit 10;

-----------------------------------------------------------------------------------------------
-- 3. purchase pattern of customers based on salary, education, and gender
select 
grouping__id, --unique group id generated internally for different rollup groups
yearlyincome, 
education, 
gender, 
sum(totalpurchaseytd) sales_value 
from customer_demo
group by yearlyincome, education, gender
with rollup 
order by sales_value desc;

-- alternate query by explicitly mentioning grouping sets
select 
grouping__id, 
yearlyincome, 
education, gender, 
sum(totalpurchaseytd) sales_value 
from customer_demo
group by yearlyincome, education, gender
grouping sets ((yearlyincome, education,gender), (yearlyincome, education), (yearlyincome), ())
order by sales_value desc;

-----------------------------------------------------------------------------------------------
-- 4. sales contribution percentage of each customer and sales contribution percentage based on gender and salary 

-- sales contribution percentage of each customer
select 
customerid, 
(sum(totalpurchaseytd) over (partition by customerid) / sum(totalpurchaseytd) over ()) sales_contribution_percentage 
from customer_demo cd
order by customerid;

-- sales contribution percentage based on gender and salary
with customer_sales_contribution as (
    select 
    customerid, 
    (sum(totalpurchaseytd) over (partition by customerid) / sum(totalpurchaseytd) over ())*100 sales_contribution_percentage 
    from customer_demo
)
select 
gender, 
yearlyincome,
sum(v.sales_contribution_percentage) as percentage_of_purchase 
from customer_demo cd
join customer_sales_contribution csc
on csc.customerid = cd.customerid
group by gender, yearlyincome
order by percentage_of_purchase desc;
--OR--
select 
gender,
yearlyincome,
(sum(totalpurchaseytd) over (partition by gender, yearlyincome) / sum(totalpurchaseytd) over ())*100 sales_contribution_percentage 
from customer_demo cd
order by customerid;

-----------------------------------------------------------------------------------------------
-- 5. identify the top performing territory based on sales
select 
TerritoryID,
sum(soh.TotalDue) as territory_sales
from sales_order_header soh
join store_details store
on store.TerritoryID = soh.TerritoryID
group by soh.TerritoryID
order by territory_sales desc;

-----------------------------------------------------------------------------------------------
-- 6. find the territory wise sales and adherence to their defined sales quota
select distinct 
TerritoryID, 
(sum(SalesYTD) over (partition by TerritoryID) / sum(SalesQuota) over (partition by TerritoryID)) territory_target_achieved 
from store_details st
order by territory_target_achieved desc;
-- territory_target_achieved>=1 means that TerritoryID has adhered to its defined sales quota

-----------------------------------------------------------------------------------------------