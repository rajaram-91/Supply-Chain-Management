use mahendra;
-- 1) Total Sales(MTD,QTD,YTD)
-- YTD

SELECT 
    SUM(point_of_sale.sales_amount) AS YTD_Sales
FROM
    f_sales
        JOIN
    point_of_sale ON f_sales.order_number = point_of_sale.order_number
WHERE
    YEAR(f_sales.date) = 2023;

-- MTD

SELECT 
   SUM(point_of_sale.sales_amount) AS MTD_Sales
FROM
    f_sales
        JOIN
    point_of_sale ON f_sales.order_number = point_of_sale.order_number
where year(f_sales.date) = 2023 and quarter(f_sales.date) = 1 and month(f_sales.date) = 3 ;

-- QTD

SELECT 
  SUM(point_of_sale.sales_amount) AS QTD_Sales
FROM
    f_sales
        JOIN
    point_of_sale ON f_sales.order_number = point_of_sale.order_number 
    where year(f_sales.date) = 2023 and quarter(f_sales.date) = 1;

-- 2) Product Wise Sales

SELECT 
    Product_type, SUM(Sales_Amount) AS Sales
FROM
    d_product
        JOIN
    point_of_sale ON d_product.Product_Key = point_of_sale.product_key
GROUP BY Product_type
ORDER BY sales DESC;

-- 3) Sales Growth

with cte as(SELECT 
    year(f_sales.date) as Year,sum(point_of_sale.sales_amount) AS Sales
FROM
    f_sales
        JOIN
    point_of_sale ON f_sales.order_number = point_of_sale.order_number group by year(f_sales.date) order by year(f_sales.date))
    SELECT 
    year, Sales, lag(sales) over(order by year) as previous_year_sales,
    ((sales-lag(sales) over(order by year))/lag(sales) over(order by year)*100) as Sales_growth from cte;
    
-- 4) Sales Trend

SELECT 
   year(f_sales.date) as Year, quarter(f_sales.date) as Quarter, month(f_sales.date) as Month, SUM(point_of_sale.sales_amount) AS Sales
FROM
    f_sales
        JOIN
    point_of_sale ON f_sales.order_number = point_of_sale.order_number
group by year(f_sales.date), quarter(f_sales.date), month(f_sales.date)
order by year(f_sales.date), quarter(f_sales.date), month(f_sales.date);
-- 5)State Wise Sales

SELECT 
    d_store.store_state AS State, SUM(sales_amount) AS Sales
FROM
    d_store
        JOIN
    f_sales ON d_store.store_key = f_sales.store_key
        JOIN
    point_of_sale ON f_sales.order_number = point_of_sale.order_number
GROUP BY state ORDER BY sales DESC;
-- 6)Top 5 Store Wise Sales

SELECT 
    d_store.store_name AS "Store Name", SUM(sales_amount) AS Sales
FROM
    d_store
        JOIN
    f_sales ON d_store.store_key = f_sales.store_key
        JOIN
    point_of_sale ON f_sales.order_number = point_of_sale.order_number
GROUP BY store_name ORDER BY sales DESC limit 5;
-- 7)Region Wise Sales

SELECT 
    d_store.store_region AS Region, SUM(sales_amount) AS Sales
FROM
    d_store
        JOIN
    f_sales ON d_store.store_key = f_sales.store_key
        JOIN
    point_of_sale ON f_sales.order_number = point_of_sale.order_number
GROUP BY Region ORDER BY sales DESC;
-- 8)Purchase Method Wise Sales

SELECT 
    f_sales.purchase_method AS "Purchase Method", SUM(sales_amount) AS Sales
FROM
    f_sales 
        JOIN
    point_of_sale ON f_sales.order_number = point_of_sale.order_number
GROUP BY Purchase_Method
ORDER BY sales DESC;
-- 9)Total Inventory

SELECT 
    Product_type AS 'Product type',
    SUM(quantity_on_hand) AS Stock
FROM
    f_inventory_adjusted
GROUP BY Product_type
ORDER BY stock DESC;
-- 10)Inventory Value

SELECT 
    Product_type AS 'Product type',
    SUM(quantity_on_hand * Cost_Amount) AS "Inventory value"
FROM
    f_inventory_adjusted
GROUP BY Product_type
ORDER BY "Inventory value" DESC;

-- 11)Under/Overstock
ALTER TABLE `mahendra`.`f_inventory_adjusted`
ADD COLUMN `Stock_quantity` VARCHAR(45) NULL AFTER `Stock_status`;
SET SQL_SAFE_UPDATES = 0;
update f_inventory_adjusted set Stock_quantity = ROUND(RAND() * 5, 0) where Stock_quantity is null;
update f_inventory_adjusted set Stock_status = 
case
when (Quantity_on_Hand - Stock_quantity) > 0 then 'In Stock'
when (Quantity_on_Hand - Stock_quantity) = 0 then 'Out of Stock'
when (Quantity_on_Hand - Stock_quantity) < 0 then 'Under Stock'
end
where Stock_status is null;
select Stock_status, count(stock_status) as Count from f_inventory_adjusted group by Stock_status;

 





