# Sale Data Analytics

## Project Overview
This project involves a comprehensive SQL analysis of sales data, where I answered 24 targeted questions to derive actionable insights. The dataset includes detailed information on transactions, such as sales dates, customer demographics, product categories, quantities sold, and pricing information. The objective was to use SQL to explore various aspects of the data, including customer behavior, product performance, seasonal trends, and profitability.

### The project includes SQL queries covering diverse analytical needs, such as:
Customer segmentation based on purchase frequency and spending patterns.
* Sales performance by product category and customer demographic.
* Monthly and seasonal sales trends.
* Profitability analysis based on cost of goods sold (COGS) and total sales.

This project demonstrates the use of SQL in a practical business context, emphasizing data exploration and analysis techniques that can inform business decisions.

### Creating Table

```SQL
CREATE TABLE sales (
	transactions_id	INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(10),
	age INT,
	category VARCHAR(20),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);
```

## Business Probelms

### 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05:
```SQL
SELECT * 
FROM sales
WHERE sale_date = '2022-11-05';
```
### 2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
```SQL
SELECT *
FROM sales
WHERE
    category = 'Clothing' AND
    quantity > 3;
```
### 3. Write a SQL query to calculate the total sales (total_sale) for each category.:
```SQL
SELECT
    category,
    SUM(total_sale) AS Total_Sales
FROM sales
GROUP BY 1;
```
### 4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
```SQL
SELECT AVG(AGE) AS Avg_Age
FROM sales
WHERE category = 'Beauty';
```
### 5. Write a SQL query to find all transactions where the total_sale is greater than 1000.:
```SQL
SELECT *
FROM sales
WHERE total_sale > 1000;
```

### 6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
```SQL
SELECT
    gender,
    category,
    COUNT(*) AS Total_Transactions
FROM sales
GROUP BY 1, 2;
```
### 7. Write a SQL query to calculate the average sale for each month. 
```SQL
SELECT
    MONTHNAME(sale_date),
    ROUND(AVG(total_sale), 2) AS Avg_Sale
FROM sales
GROUP BY 1;
```

### 8. Write a SQL query to find out best selling month in each year:
```SQL
SELECT 
    years, 
    months, 
    Total_Sale
FROM ( 
      SELECT
          YEAR(sale_date) AS years,
          MONTHNAME(sale_date) AS months,
          SUM(total_sale) AS Total_Sale,
          RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY SUM(total_sale) DESC) AS ranking
      FROM sales
      GROUP BY 1, 2) AS ranks
WHERE ranking = 1;
```
### 9. Write a SQL query to find the top 5 customers based on the highest total sales
```SQL
SELECT
    customer_id,
    SUM(total_sale) AS Total_Sale
FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

### 10. Write a SQL query to find the number of unique customers who purchased items from each category.:
```SQL
SELECT
    category,
    COUNT(DISTINCT customer_id) AS Total_Customer
FROM sales
GROUP BY 1;
```

### 11. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
```SQL
SELECT
    CASE WHEN HOUR(sale_time) < 12 THEN 'Morning'
    WHEN HOUR(sale_time) BETWEEN 12 AND 16 THEN 'Afternoon'
    ELSE 'Evening' END AS shift,
    COUNT(*) as Total_Orders
FROM sales
GROUP BY 1;
```
### 12. Write a SQL query to calculate the total quantity sold for each product category.
```SQL
SELECT
    category,
    SUM(quantity) AS Total_Quantity
FROM sales
GROUP BY 1;
```
### 13. Write a SQL query to retrieve all transactions where the customer's age is between 18 and 25.
```SQL
SELECT *
FROM sales
WHERE age BETWEEN 18 AND 25;
```
### 14. Write a SQL query to calculate the total profit (total_sale - cogs) for each category.
```SQL
SELECT
    category,
    ROUND(SUM(total_sale - (cogs * quantity)), 2) AS Total_Profit
FROM sales
GROUP BY 1;
```
### 15. Write a SQL query to find the transaction with the lowest total sale amount.
```SQL
SELECT *
FROM sales
WHERE
    total_sale = (SELECT MIN(total_sale) FROM sales);
```
### 16. Write a SQL query to find the total sales amount for each customer by month.
```SQL
SELECT
    customer_id AS customers,
    MONTHNAME(sale_date) AS months,
    SUM(total_sale) AS Total_Sales
FROM sales
GROUP BY 1, 2
ORDER BY 1;
```
### 17. Write a SQL query to find the average quantity sold per transaction for each product category.
```SQL
SELECT
    category,
    ROUND(AVG(quantity), 2) AS Avg_Quantity
FROM sales
GROUP BY 1;
```
### 18. Write a SQL query to identify the gender with the highest total sales in each category.
```SQL
SELECT 
    gender,
    category,
    Total_Sales
FROM (
      SELECT
          gender,
          category,
          SUM(total_sale) AS Total_Sales,
          RANK() OVER(PARTITION BY category ORDER BY SUM(total_sale) DESC) AS ranking
      FROM sales
      GROUP BY 1, 2) AS rankings
WHERE ranking = 1;
```
### 19. Write a SQL query to find all transactions where the total_sale is greater than the average total sale for the 'Clothing' category.
```SQL
SELECT *
FROM sales
WHERE total_sale > (
                    SELECT 
                        AVG(total_sale) AS Avg_Sales
                    FROM sales
                    WHERE category = 'Clothing');
```
### 20. Write a SQL query to find the most purchased category by customers aged 30 and under.
```SQL
SELECT category
FROM (
      SELECT
          category, 
          COUNT(*) AS Total_Purchases
	    FROM sales
      WHERE age < 30
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 1) Total;
```

### 21. Write a SQL query to calculate the total sales made each day in the month of December 2022.
```SQL
SELECT
    DAY(sale_date),
    SUM(total_sale) AS Total_Sales
FROM sales
WHERE MONTH(sale_date) = 12
GROUP BY 1
ORDER BY 1;
```
### 22. Write a SQL query to retrieve all transactions where the profit (total_sale - cogs) is below zero (indicating a loss).
```SQL
SELECT
    *,
    (total_sale - cogs) AS Profit
FROM sales
WHERE (total_sale - cogs) < 0;
```
### 23. Write a SQL query to count the total number of transactions for each day of the week (e.g., Monday, Tuesday, etc.).
```SQL
SELECT
    CASE WHEN WEEKDAY(sale_date) = 0 THEN 'Monday'
    WHEN WEEKDAY(sale_date) = 1 THEN 'Tuesday'
    WHEN WEEKDAY(sale_date) = 2 THEN 'Wednesday'
    WHEN WEEKDAY(sale_date) = 3 THEN 'Thursday'
    WHEN WEEKDAY(sale_date) = 4 THEN 'Friday'
    WHEN WEEKDAY(sale_date) = 5 THEN 'Saturday'
    ELSE 'Sunday' END day_of_week,
    COUNT(*) AS Total_Transactions
FROM sales
GROUP BY 1
ORDER BY 2 DESC;
```
### 24. Write a SQL query to retrieve the transaction ID, customer ID, and category for the top 3 highest sales transactions in each category.
```SQL
SELECT
    category,
    transactions_id,
    customer_id
FROM(
      SELECT 
          category,
          transactions_id,
          customer_id,
          SUM(total_sale) AS Total_Sales,
          ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(total_sale) DESC) ranking
      FROM sales
      GROUP BY 1, 2, 3) AS rankings
WHERE ranking <=3;
```

## Conclusion
Through this project, I've demonstrated how SQL can be effectively used to analyze large datasets, uncover insights, and answer critical business questions. The analysis revealed patterns and trends within the sales data that can be valuable for strategic planning, customer segmentation, and product optimization.

### Key takeaways include:
* High-performing categories and products contribute significantly to total revenue.
* Customer demographic factors, like age and gender, influence purchasing behavior.
* Seasonal trends impact sales volumes, indicating potential periods for promotional efforts.

This project highlights the power of SQL as a tool for extracting meaningful insights from data and supports data-driven decision-making in sales and marketing.
