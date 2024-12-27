
-- Database: First
USE First;
-- Table: Global_Superstore
select * from Global_Superstore;

-- To see all data types of the columns in the table Global_Superstore
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH, 
    NUMERIC_PRECISION, 
    NUMERIC_SCALE 
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME, COLUMN_NAME;

-- To change the Null values of postal code to 000000
UPDATE Global_Superstore
SET Postal_Code = '000000'
WHERE Postal_Code IS NULL;

--> 1. Sales and Revenue Analysis
--> What are the total sales and profits generated over time?

SELECT 
  ROUND(SUM(Sales),2) AS Total_Sales, 
  ROUND(SUM(cast(Profit as float)),2) AS Total_Profit, 
  DATEPART(YEAR, Order_Date) AS Year
FROM Global_Superstore
GROUP BY DATEPART(YEAR, Order_Date)
ORDER BY Year;

/* Conclusion: Over the time, sales and profit has increased */

--> Which regions or markets contribute the most to total sales and profit?

WITH RegionalSales AS (
  SELECT 
    Region, 
    ROUND(SUM(Sales), 2) AS Total_Sales, 
    ROUND(SUM(CAST(Profit AS FLOAT)), 2) AS Total_Profit
  FROM Global_Superstore
  GROUP BY Region
)
SELECT 
  Region, 
  Total_Sales, 
  Total_Profit
FROM RegionalSales
ORDER BY Total_Sales DESC, Total_Profit DESC;

/* Conclusion 1: Central region has contributed the most to the total sales. */

WITH MarketSales AS (
  SELECT 
    Market, 
    ROUND(SUM(Sales), 2) AS Total_Sales, 
    ROUND(SUM(CAST(Profit AS FLOAT)), 2) AS Total_Profit
  FROM Global_Superstore
  GROUP BY Market
)
SELECT 
  Market, 
  Total_Sales, 
  Total_Profit
FROM MarketSales
ORDER BY Total_Sales DESC, Total_Profit DESC;

/* Conclusion 2: APAC Matrket has contributed the most to the total sales. */

WITH RMSales AS (
  SELECT 
    Region,Market, 
    ROUND(SUM(Sales), 2) AS Total_Sales, 
    ROUND(SUM(CAST(Profit AS FLOAT)), 2) AS Total_Profit
  FROM Global_Superstore
  GROUP BY Region,Market
)
SELECT 
  Region,Market, 
  Total_Sales, 
  Total_Profit
FROM RMSales
ORDER BY Region;


/* Conclusion: With this we can find the sales of the market in each region, 
which will give the opportunities to invest in the markets of specific types.*/

--> How do sales trends vary by category, sub-category, and product?

select Category, sum(sales) from global_superstore group by category order by sum(sales) DESC;
select Category,sub_category, sum(sales) as Total_sales from global_superstore group by Category,sub_category order by Category,sum(sales) DESC;


select Category,sub_category,product_name, sum(sales) as Total_sales 
from global_superstore 
group by Category,sub_category,product_name
order by Category,sum(sales) DESC;

/* Conclusion: Technology category has the highest sales and profit follwed by Furniture and Office Suppliers */

--> What are the best-selling products in each region?

WITH BestSellingProducts AS (
  SELECT 
    Region, 
    Product_Name, 
    SUM(Sales) AS Total_Sales
  FROM Global_Superstore
  GROUP BY Region, Product_Name
),
RankedProducts AS (
  SELECT 
    Region, 
    Product_Name, 
    Total_Sales,
    RANK() OVER (PARTITION BY Region ORDER BY Total_Sales DESC) AS SalesRank
  FROM BestSellingProducts
)
SELECT 
  Region, 
  Product_Name, 
  Total_Sales
FROM RankedProducts
WHERE SalesRank = 1
ORDER BY Region;

/* Conclusion: The Region followed by the product name .
Africa	Apple Smart Phone, Full Size
Canada	Motorola Smart Phone, Full Size
Caribbean	Dania Classic Bookcase, Traditional
Central	Nokia Smart Phone, Full Size
Central Asia	Apple Smart Phone, Full Size
East	Canon imageCLASS 2200 Advanced Copier
EMEA	Cisco Smart Phone, Full Size
North	Nokia Smart Phone, Full Size
North Asia	Samsung Smart Phone, VoIP
Oceania	Nokia Smart Phone, with Caller ID
South	Cisco TelePresence System EX90 Videoconferencing Unit
Southeast Asia	Nokia Smart Phone, with Caller ID
West	Canon imageCLASS 2200 Advanced Copier */

--> Are there any seasonal trends in sales or profit over time?
-- To see if there is Profit over months
SELECT 
  DATEPART(YEAR, Order_Date) AS Year, 
  DATEPART(MONTH, Order_Date) AS Month, 
  ROUND(SUM(Sales), 2) AS Total_Sales, 
  ROUND(SUM(CAST(Profit AS FLOAT)), 2) AS Total_Profit
FROM Global_Superstore
GROUP BY DATEPART(YEAR, Order_Date), DATEPART(MONTH, Order_Date)
ORDER BY Year, Month;

-- Sales per quarter is increasing and the sales in last quarter of each year is highest.

SELECT 
  DATEPART(YEAR, Order_Date) AS Year, 
  DATEPART(QUARTER, Order_Date) AS Quarter, 
  ROUND(SUM(Sales), 2) AS Total_Sales, 
  ROUND(SUM(CAST(Profit AS FLOAT)), 2) AS Total_Profit
FROM Global_Superstore
GROUP BY DATEPART(YEAR, Order_Date), DATEPART(QUARTER, Order_Date)
ORDER BY Year, Quarter;

-- 2. Customer and Segment Analysis
--> Which customer segments generate the most revenue and profit?

SELECT 
  Segment, 
  ROUND(SUM(Sales), 2) AS Total_Sales, 
  ROUND(SUM(CAST(Profit AS FLOAT)), 2) AS Total_Profit
FROM Global_Superstore
GROUP BY Segment
ORDER BY Total_Sales DESC, Total_Profit DESC;

SELECT 
  Segment, 
  COUNT(Order_ID) AS Total_Orders, 
  ROUND(SUM(Sales), 2) AS Total_Sales, 
  ROUND(SUM(CAST(Profit AS FLOAT)), 2) AS Total_Profit, 
  ROUND(AVG(Sales), 2) AS Avg_Order_Value, 
  ROUND(AVG(CAST(Profit AS FLOAT)), 2) AS Avg_Order_Profit
FROM Global_Superstore
GROUP BY Segment
ORDER BY Total_Sales DESC, Total_Profit DESC ;

/* Conclusion: Consumer segment has the highest sales and profit followed by Corporate and Home Office. 
Though Consumer has the highest sales, the average order profit i.e. profit per order is highest for Home Office. */

--> Which customers are the most valuable in terms of total purchases and profitability?

SELECT TOP 20 customer_name,COUNT(product_name) AS total_product, SUM(CAST(Profit AS FLOAT )) AS total_Profit 
FROM Global_Superstore 
GROUP BY Customer_Name
ORDER BY total_Profit DESC ;

--> Are certain customer segments associated with higher discounts or shipping costs?

SELECT Segment,AVG(CAST(Discount AS FLOAT)) AS avg_disc,AVG(Shipping_Cost) AS avg_shipcost
FROM Global_Superstore
GROUP BY Segment
ORDER BY avg_disc DESC,AVG(Shipping_Cost) DESC ;

/* Conclusion: All segments have same avg discount and shipping cost*/

--> Order and Shipping Analysis
--> What is the average delivery time across different regions or shipping modes?
-- Across Regions
select Region , AVG(DATEDIFF(DAY,Order_Date,Ship_Date))
from Global_Superstore 
group by Region ;

-- Across Shipping Modes
select Ship_Mode , AVG(DATEDIFF(DAY,Order_Date,Ship_Date))
from Global_Superstore 
group by Ship_Mode ;

-- Across Both
SELECT Region ,Ship_Mode, AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS avg_ship_days
FROM Global_Superstore 
GROUP BY Region ,Ship_Mode
ORDER BY Region, avg_ship_days DESC;

--> How does the shipping cost vary by region, segment, or product category?

SELECT Region, AVG(Shipping_Cost) AS avg_ship_cost FROM Global_Superstore 
GROUP BY Region 
ORDER BY avg_ship_cost DESC;

SELECT Segment, AVG(Shipping_Cost) AS avg_ship_cost FROM Global_Superstore 
GROUP BY Segment 
ORDER BY avg_ship_cost DESC;

SELECT Category, AVG(Shipping_Cost) AS avg_ship_cost FROM Global_Superstore 
GROUP BY Category 
ORDER BY avg_ship_cost DESC;

--> Which shipping mode is the most used, and how does it impact profitability?

SELECT Ship_mode, COUNT(Order_ID) as Total_orders, SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Ship_mode
ORDER BY Total_orders DESC, Total_Profit DESC;

/* Conclusion: Standard Class is the most used shipping mode and it has the highest profit 
followed by Second,First and Same Day SHiop mode*/

--> Are delayed shipments more common for certain shipping modes or regions?

SELECT Ship_mode, Region, COUNT(Order_ID) AS Total_orders, 
SUM(CASE WHEN DATEDIFF(DAY, Order_Date, Ship_Date) > 5 THEN 1 ELSE 0 END) AS Delayed_Shipments
FROM Global_Superstore
GROUP BY Ship_mode, Region
ORDER BY Delayed_Shipments DESC;

--> 4. Product Performance
--> Which product categories and sub-categories are the most profitable?

SELECT Category, Sub_Category, SUM(CAST(Profit AS FLOAT)) AS Total_Profit 
FROM Global_Superstore
GROUP BY Category, Sub_Category
ORDER BY Total_Profit DESC;

--> What is the relationship between discounts and product profitability?

SELECT Category, Sub_Category, AVG(CAST(Discount AS FLOAT)) AS Avg_Discount,
SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Category, Sub_Category
ORDER BY Total_Profit DESC;

--> Are there specific products that consistently underperform in terms of sales or profit?

SELECT Product_Name, Category, Sub_Category, SUM(Sales) AS Total_Sales, SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Product_Name, Category, Sub_Category
ORDER BY Total_Profit;

--> 5. Regional and Market Insights
--> How do sales and profits vary by country, state, and city?
SELECT Country, State, City, SUM(Sales) AS Total_Sales, SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore 
GROUP BY Country, State, City
ORDER BY Total_Sales DESC, Total_Profit DESC;

--> Which region has the highest average sales per order?

SELECT Top 1 Region, AVG(Sales) AS Avg_Sales_Per_Order 
FROM Global_Superstore
GROUP BY Region
ORDER BY Avg_Sales_Per_Order DESC;

--> Are there underperforming regions that need targeted marketing efforts?

SELECT Region, SUM(Sales) AS Total_Sales, SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Region
ORDER BY Total_Sales, Total_Profit;

--> 6. Discount and Profitability
--> How does offering discounts affect profitability across product categories and regions? 

SELECT Category, AVG(CAST(Discount AS FLOAT)) AS Avg_Discount, SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Category
ORDER BY Total_Profit DESC;

SELECT Region, AVG(CAST(Discount AS FLOAT)) AS Avg_Discount, SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Region
ORDER BY Total_Profit DESC;

--> Is there an optimal discount rate that maximizes both sales and profits?

SELECT Discount, SUM(Sales) AS Total_Sales, SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Discount
ORDER BY Total_Sales DESC, Total_Profit DESC;

--> Which products or categories suffer the most from excessive discounts?

SELECT Category, Sub_Category, AVG(CAST(Discount AS FLOAT)) AS Avg_Discount, SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Category, Sub_Category
ORDER BY Avg_Discount DESC, Total_Profit;

--> 7. Priority and Performance
--> How does the order priority impact shipping times and profitability?

SELECT Order_Priority, AVG(DATEDIFF(DAY, Order_Date, Ship_Date)) AS Avg_Shipping_Days, SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Order_Priority
ORDER BY Avg_Shipping_Days, Total_Profit DESC;

--> Are high-priority orders consistently delivered faster than low-priority ones?

SELECT Order_Priority, AVG(DATEDIFF(DAY, Order_Date, Ship_Date)) AS Avg_Shipping_Days
FROM Global_Superstore
GROUP BY Order_Priority
ORDER BY Avg_Shipping_Days;

--> Does prioritizing orders lead to higher profits or greater customer satisfaction?

SELECT Order_Priority, SUM(CAST(Profit AS FLOAT)) AS Total_Profit, COUNT(Order_ID) AS Total_Orders
FROM Global_Superstore
GROUP BY Order_Priority
ORDER BY Total_Profit DESC, Total_Orders DESC;

--> 8. Trend and Forecasting Analysis
--> Can sales trends over time be used to predict future sales and demand?

SELECT 
  DATEPART(YEAR, Order_Date) AS Year, 
  DATEPART(MONTH, Order_Date) AS Month, 
  ROUND(SUM(Sales), 2) AS Total_Sales, 
  ROUND(SUM(CAST(Profit AS FLOAT)), 2) AS Total_Profit
FROM Global_Superstore
GROUP BY DATEPART(YEAR, Order_Date), DATEPART(MONTH, Order_Date)
ORDER BY Year, Month;

-- TO write the modified one for this.
--> Are there identifiable patterns in customer behavior over months or years?

SELECT 
  DATEPART(YEAR, Order_Date) AS Year, 
  DATEPART(MONTH, Order_Date) AS Month, 
  COUNT(DISTINCT Customer_ID) AS Unique_Customers
FROM Global_Superstore
GROUP BY DATEPART(YEAR, Order_Date), DATEPART(MONTH, Order_Date)
ORDER BY Year, Month;

--> How does seasonality affect different markets, categories, or customer segments?

SELECT 
  DATEPART(YEAR, Order_Date) AS Year, 
  DATEPART(MONTH, Order_Date) AS Month, 
  Category, 
  SUM(Sales) AS Total_Sales
FROM Global_Superstore
GROUP BY DATEPART(YEAR, Order_Date), DATEPART(MONTH, Order_Date), Category
ORDER BY Year,Category, Total_Sales DESC;

--> 9. Outliers and Anomalies

--> Are there any outliers in sales, discounts, or shipping costs?
-- To modify the query for this
select Category,Sub_Category,Product_Name,Discount,Shipping_Cost 
from Global_Superstore where Discount > 0.5 or Shipping_Cost > 100;

select max(Shipping_Cost), MIN(Shipping_Cost), AVG(Shipping_Cost),
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Shipping_Cost) OVER (PARTITION BY Region) AS Median_Shipping_Cost
from Global_Superstore group by Region,Shipping_Cost;

--> 10. Cross-Category Relationships

--> Do customers who buy from one category frequently purchase from others?

SELECT 
  Customer_ID, Customer_Name, COUNT(DISTINCT Category) AS Unique_Categories
FROM Global_Superstore
GROUP BY Customer_ID, Customer_Name
having COUNT(DISTINCT Category) > 1
ORDER BY Unique_Categories DESC;


--> Are certain product categories linked to higher shipping costs?

SELECT 
  Category, 
  AVG(Shipping_Cost) AS Avg_Shipping_Cost
FROM Global_Superstore
GROUP BY Category
ORDER BY Avg_Shipping_Cost DESC;

--> 11. Data Enrichment and Comparison

--> How does the company’s performance compare across regions or markets globally?

SELECT 
  Market, 
  Region, 
  SUM(Sales) AS Total_Sales, 
  SUM(CAST(Profit AS FLOAT)) AS Total_Profit
FROM Global_Superstore
GROUP BY Market, Region
ORDER BY Total_Sales DESC, Total_Profit DESC;

