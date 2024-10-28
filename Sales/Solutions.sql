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

-- Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT * 
FROM sales
WHERE sale_date = '2022-11-05';

-- Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
SELECT *
FROM sales
WHERE
	category = 'Clothing' AND
    quantity > 3;

-- Write a SQL query to calculate the total sales (total_sale) for each category.:
SELECT 
	category,
    SUM(total_sale) AS Total_Sales
FROM sales
GROUP BY 1;

-- Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
SELECT AVG(AGE) AS Avg_Age
FROM sales
WHERE category = 'Beauty';

-- Write a SQL query to find all transactions where the total_sale is greater than 1000.:
SELECT *
FROM sales
WHERE total_sale > 1000;

-- Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
SELECT
	gender,
    category,
    COUNT(*) AS Total_Transactions
FROM sales
GROUP BY 1, 2;

-- Write a SQL query to calculate the average sale for each month. 
SELECT 
	MONTHNAME(sale_date),
    ROUND(AVG(total_sale), 2) AS Avg_Sale
FROM sales
GROUP BY 1;

-- Write a SQL query to find out best selling month in each year:
SELECT years, months, Total_Sale
FROM (SELECT
	YEAR(sale_date) AS years,
    MONTHNAME(sale_date) AS months,
    SUM(total_sale) AS Total_Sale,
    RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY SUM(total_sale) DESC) AS ranking
FROM sales
GROUP BY 1, 2) AS ranks
WHERE ranking = 1;

-- Write a SQL query to find the top 5 customers based on the highest total sales
SELECT 
	customer_id,
    SUM(total_sale) AS Total_Sale
FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Write a SQL query to find the number of unique customers who purchased items from each category.:
SELECT
	category,
    COUNT(DISTINCT customer_id) AS Total_Customer
FROM sales
GROUP BY 1;


-- Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
SELECT 
	CASE WHEN HOUR(sale_time) < 12 THEN 'Morning'
    WHEN HOUR(sale_time) BETWEEN 12 AND 16 THEN 'Afternoon'
    ELSE 'Evening' END AS shift,
    COUNT(*) as Total_Orders
FROM sales
GROUP BY 1;

-- Write a SQL query to calculate the total quantity sold for each product category.
SELECT
	category,
    SUM(quantity) AS Total_Quantity
FROM sales
GROUP BY 1;

-- Write a SQL query to retrieve all transactions where the customer's age is between 18 and 25.
SELECT *
FROM sales
WHERE age BETWEEN 18 AND 25;

-- Write a SQL query to calculate the total profit (total_sale - cogs) for each category.
SELECT 
	category,
    ROUND(SUM(total_sale - (cogs * quantity)), 2) AS Total_Profit
FROM sales
GROUP BY 1;

-- Write a SQL query to find the transaction with the lowest total sale amount.
SELECT *
FROM sales
WHERE
	total_sale = (SELECT MIN(total_sale) FROM sales);

-- Write a SQL query to find the total sales amount for each customer by month.
SELECT 
	customer_id AS customers,
    MONTHNAME(sale_date) AS months,
	SUM(total_sale) AS Total_Sales
FROM sales
GROUP BY 1, 2
ORDER BY 1;

-- Write a SQL query to find the average quantity sold per transaction for each product category.
SELECT
	category,
    ROUND(AVG(quantity), 2) AS Avg_Quantity
FROM sales
GROUP BY 1;

-- Write a SQL query to identify the gender with the highest total sales in each category.
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

-- Write a SQL query to find all transactions where the total_sale is greater than the average total sale for the 'Clothing' category.
SELECT *
FROM sales
WHERE total_sale > (SELECT 
						AVG(total_sale) AS Avg_Sales
					FROM sales
					WHERE category = 'Clothing');


-- Write a SQL query to find the most purchased category by customers aged 30 and under.
SELECT category
FROM (SELECT 
		category, 
        COUNT(*) AS Total_Purchases
	FROM sales
    WHERE age < 30
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1) Total;


-- Write a SQL query to calculate the total sales made each day in the month of December 2022.
SELECT 
	DAY(sale_date),
    SUM(total_sale) AS Total_Sales
FROM sales
WHERE MONTH(sale_date) = 12
GROUP BY 1
ORDER BY 1;

-- Write a SQL query to retrieve all transactions where the profit (total_sale - cogs) is below zero (indicating a loss).
SELECT *, (total_sale - cogs) AS Profit
FROM sales
WHERE (total_sale - cogs) < 0;

-- Write a SQL query to count the total number of transactions for each day of the week (e.g., Monday, Tuesday, etc.).
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


-- Write a SQL query to retrieve the transaction ID, customer ID, and category for the top 3 highest sales transactions in each category.
SELECT category, transactions_id, customer_id
FROM( SELECT 
			category,
			transactions_id,
			customer_id,
			SUM(total_sale) AS Total_Sales,
			ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(total_sale) DESC) ranking
		FROM sales
		GROUP BY 1, 2, 3) AS rankings
WHERE ranking <=3;