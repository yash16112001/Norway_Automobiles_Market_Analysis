use project_ftn;
-- top 5 row of table

select * from sales_by_make limit 5;

-- query 1 
select make, sum(quantity) as total_sales
from sales_by_make
group by make
order by total_sales desc
limit 10;

-- query 2
select year, make, sum(quantity) as yearly_sales
from sales_by_make
group by year, make
order by year, yearly_sales desc;

-- query 3
select make, model, sum(quantity) as total_sales
from sales_by_model
group by make, model
order by make, total_sales
limit 3;

-- query 4 we have to give recommendation also here 
SELECT Year, SUM(Quantity) AS TotalSales
FROM sales_by_make
GROUP BY Year
ORDER BY TotalSales DESC
LIMIT 4;

-- query 5 
select year, avg(avg_co2) as avgco2, 
avg(diesel_co2) as avgdieselco2,
avg(bensin_co2) as avgbensinco2 
from sales_by_month
group by year
order by avgbensinco2 desc; 

-- query 6
select make, avg(avg_co2) as avgco2
from sales_by_make as make
join 
sales_by_month as month
on 
make.year = month.year
group by make
order by avgco2 asc
limit 5;

-- query 7
select year, sum(quantity_electric) as electric_sales, sum(quantity) as total_sales,
round((sum(quantity_electric)/sum(quantity))*100,2) as electric_sales_percent from sales_by_month
group by year
order by year;

-- query 8
select model, sum(quantity) as total_sales from sales_by_model
where model like '%electric%' 
group by model 
order by total_sales;

-- query 9 
select make, model, sum(quantity) as total_sales
from sales_by_model
where model like 'Tesla%' or
model like 'Volkswagen%'or
model like '%Toyata%'
group by make, model
order by total_sales;

-- query 10
select year, model, sum(quantity) as total_sales
from sales_by_model
group by year, model
order by total_sales desc
limit 5;

-- query 11
SELECT 
    Year, 
    SUM(Quantity) AS TotalSales,
    LAG(SUM(Quantity)) OVER (ORDER BY Year) AS PreviousYearSales,
    ROUND((SUM(Quantity) - LAG(SUM(Quantity)) OVER (ORDER BY Year)) * 100.0 / 
          LAG(SUM(Quantity)) OVER (ORDER BY Year), 2) AS GrowthRate
FROM sales_by_month
GROUP BY Year
ORDER BY Year;

-- query 12
select month, sum(quantity) as total_sales
from sales_by_month
group by month
order by total_sales desc;

-- query 13
WITH YearlySales AS (
    SELECT 
        Year, 
        Make, 
        SUM(Quantity) AS TotalSales
    FROM sales_by_make
    GROUP BY 
        Year, Make
)
SELECT 
    Make, 
    Year, 
    TotalSales, 
    LAG(TotalSales) OVER (PARTITION BY Make ORDER BY Year) AS PreviousYearSales,
    ROUND((TotalSales - LAG(TotalSales) OVER (PARTITION BY Make ORDER BY Year)) * 100.0 / 
          LAG(TotalSales) OVER (PARTITION BY Make ORDER BY Year), 2) AS GrowthRate
FROM 
    YearlySales
ORDER BY 
    GrowthRate DESC;

-- query 14
select year, sum(import) as total_import,
sum(quantity) as total_sales,
round((sum(import)/sum(quantity))*100,2) as import_percents
from sales_by_month
group by year
order by year;

-- query 15
select year, sum(import) as total_import, 
sum(quantity) as total_sales,
round((sum(import)*100)/sum(quantity),2) as import_percent 
from sales_by_month
group by year
having import_percent >= 20
order by import_percent desc;

-- query 16
select count(*) as total_rows
from sales_by_month
where used_YOY = 'na' or quantity_electric = 'na';

-- query 17
select year, month, 
coalesce(used_yoy, 'na') as used_yoy,
coalesce(quantity_electric, 'na') as electric_quantity
from sales_by_month;

-- query 18
SELECT ncm.Year, 
SUM(ncm.Quantity_Diesel) AS TotalDieselSales,
SUM(ncm.Quantity_Hybrid) AS TotalHybridSales,
SUM(ncm.Quantity_Electric) AS TotalElectricSales, yts.TotalYearlySales,
ROUND(SUM(ncm.Quantity_Diesel) * 100.0 / yts.TotalYearlySales, 2) AS DieselSharePct,
ROUND(SUM(ncm.Quantity_Hybrid) * 100.0 / yts.TotalYearlySales, 2) AS HybridSharePct,
ROUND(SUM(ncm.Quantity_Electric) * 100.0 / yts.TotalYearlySales, 2) AS ElectricSharePct
FROM (SELECT Year,
SUM(Quantity_Diesel + Quantity_Hybrid + Quantity_Electric) AS TotalYearlySales
FROM sales_by_month
GROUP BY Year) AS yts
INNER JOIN sales_by_month as ncm 
ON yts.Year = ncm.Year
GROUP BY ncm.Year, yts.TotalYearlySales
ORDER BY ncm.Year;

-- query 19
select year, sum(quantity) as total_sales,
sum(sum(quantity)) over (order by year) as cumalative_sales
from sales_by_month
group by year
order by cumalative_sales desc;

-- query 20
SELECT 
    Year, 
    Make, 
    TotalSales
FROM 
    (
        SELECT 
            Year, 
            Make, 
            SUM(Quantity) AS TotalSales,
            RANK() OVER (PARTITION BY Year ORDER BY SUM(Quantity) DESC) AS RankBySales
        FROM 
            sales_by_make
        GROUP BY 
            Year, Make
    ) AS RankedSales
WHERE 
    RankBySales <= 3
ORDER BY 
    Year, RankBySales;

-- query 21
select make, sum(quantity) as total_sales,
case 
when sum(quantity) < 500 then 'low'
when sum(quantity) between 500 and 1000 then 'midium'
else 'high' end as sales_category
from sales_by_make
group by make
order by total_sales desc;

-- query 22
SELECT 
    Year, 
    Model, 
    TotalSales, 
    PreviousYearSales,
    CASE 
        WHEN PreviousYearSales IS NOT NULL AND (TotalSales > 2 * PreviousYearSales) THEN 'Exceptional Growth'
        ELSE 'Normal Growth'
    END AS GrowthCategory
FROM 
    (
        SELECT 
            nm.Year, 
            nm.Model, 
            SUM(nm.Quantity) AS TotalSales,
            (
                SELECT 
                    SUM(nm_inner.Quantity)
                FROM sales_by_model as nm_inner
                WHERE 
                    nm_inner.Model = nm.Model AND nm_inner.Year = nm.Year - 1
            ) AS PreviousYearSales
        FROM sales_by_model nm
        GROUP BY 
            nm.Year, nm.Model
    ) AS ModelSalesWithGrowth
ORDER BY 
    Model, Year;

-- query 23 
SELECT Year, Make, TotalSales
FROM (SELECT Year, Make, 
SUM(Quantity) AS TotalSales,
RANK() OVER (PARTITION BY Year ORDER BY SUM(Quantity) DESC) AS RankBySales
FROM sales_by_make
GROUP BY Year, Make) AS RankedSales
WHERE RankBySales = 1
ORDER BY Year;
 
-- query 24
select year, month, diesel_share, 
case 
when diesel_share < 25 then 'low'
when diesel_share between 25 and 50 then 'midium'
else 'high' end as profitablity_share 
from sales_by_month
order by year, month;

-- query 25
SELECT Year, ElectricSales, PreviousYearSales,
    CASE 
        WHEN ElectricSales > PreviousYearSales THEN 'Growth'
        WHEN ElectricSales < PreviousYearSales THEN 'Decline'
        ELSE 'Stable'
    END AS SalesTrend
FROM (SELECT ncm.Year, SUM(ncm.Quantity_Electric) AS ElectricSales,
(SELECT SUM(ncm_inner.Quantity_Electric)
FROM sales_by_month as ncm_inner
WHERE 
ncm_inner.Year = ncm.Year - 1) AS PreviousYearSales
FROM sales_by_month as ncm
GROUP BY ncm.Year) AS ElectricSalesWithGrowth
ORDER BY Year;