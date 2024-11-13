SELECT * FROM dim_customer;

SELECT * FROM dim_product;

SELECT * FROM fact_gross_price;

SELECT * FROM fact_manufacturing_cost;

SELECT * FROM fact_pre_invoice_deductions;

SELECT * FROM fact_sales_monthly;

/*
1. Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region.
*/
SELECT 
	DISTINCT market
FROM dim_customer
WHERE 
	region = "APAC" AND 
    customer = "Atliq Exclusive";


/*
2. What is the percentage of unique product increase in 2021 vs. 2020? The
final output contains these fields,
unique_products_2020
unique_products_2021
percentage_chg
*/
SELECT (
	SELECT 
		COUNT(DISTINCT product_code) 
	FROM fact_sales_monthly
    WHERE fiscal_year = 2020) AS unique_products_2020, 
    (SELECT 
		COUNT(DISTINCT product_code)
	FROM fact_sales_monthly
    WHERE fiscal_year = 2021) AS unique_products_2021,
	((SELECT 
		COUNT(DISTINCT product_code) 
	FROM fact_sales_monthly
	WHERE fiscal_year = 2021) - 
    (SELECT 
		COUNT(DISTINCT product_code)
    FROM fact_sales_monthly
    WHERE fiscal_year = 2020)) / NULLIF( (SELECT COUNT(DISTINCT product_code)
										FROM fact_sales_monthly
										WHERE fiscal_year = 2020),0) * 100 AS percentage_chg;

SELECT 
	COUNT(DISTINCT CASE 
		WHEN fiscal_year = 2020 THEN product_code END) AS product_count_2020,
    COUNT(DISTINCT CASE 
		WHEN fiscal_year = 2021 THEN product_code END) AS product_count_2021,
    (COUNT(DISTINCT CASE 
		WHEN fiscal_year = 2021 THEN product_code END) -
	COUNT(DISTINCT CASE 
		WHEN fiscal_year = 2020 THEN product_code END)) /
    COUNT(DISTINCT CASE 
		WHEN fiscal_year = 2020 THEN product_code END) * 100 AS percentage_chg
FROM fact_sales_monthly;
        
/*
3. Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts. The final output contains
2 fields,
segment
product_count
*/
SELECT 
	segment,
    COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY 1
ORDER BY 2 DESC;
    


/*
4. Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference
*/
SELECT segment,
	COUNT(DISTINCT 
		CASE 
			WHEN fiscal_year = 2020 
			THEN dp.product_code 
            END) AS product_count_2020,
    COUNT(DISTINCT 
		CASE 
			WHEN fiscal_year = 2021 
			THEN dp.product_code 
            END) AS product_count_2021,
    (COUNT(DISTINCT 
		CASE 
			WHEN fiscal_year = 2020 
            THEN dp.product_code 
            END) - 
    COUNT(DISTINCT 
		CASE 
			WHEN fiscal_year = 2021 
            THEN dp.product_code 
            END)) AS difference
FROM fact_sales_monthly fs
JOIN dim_product dp 
	ON fs.product_code = dp.product_code
GROUP BY 1;

/*
5. Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields,
product_code
product
manufacturing_cost
*/
SELECT 
	dp.product_code,
	dp.product,
    manufacturing_cost
FROM fact_manufacturing_cost fm
JOIN dim_product dp 
	ON dp.product_code = fm.product_code
WHERE fm.manufacturing_cost = (SELECT MAX(manufacturing_cost)
								FROM fact_manufacturing_cost)
UNION
SELECT 
	dp.product_code,
	dp.product,
    manufacturing_cost
FROM fact_manufacturing_cost fm
JOIN dim_product dp 
	ON dp.product_code = fm.product_code
WHERE fm.manufacturing_cost = (SELECT MIN(manufacturing_cost)
								FROM fact_manufacturing_cost);

/*
6. Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage
*/
SELECT 
	dc.customer_code,
    dc.customer,
    ROUND(AVG(pre_invoice_discount_pct) * 100, 2) AS pre_invoice_discount_pct
FROM dim_customer dc
JOIN fact_pre_invoice_deductions fp
	ON dc.customer_code = fp.customer_code
WHERE 
	fp.fiscal_year = 2021 AND 
    dc.market = "India"
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;


/*
7. Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount
*/
SELECT 
	MONTHNAME(fs.date) AS Month,
    YEAR(fs.date) AS Year,
    ROUND(SUM(fg.gross_price), 2) AS Gross_sales_Amount
FROM dim_customer dc
JOIN fact_sales_monthly fs
	ON dc.customer_code = fs.customer_code
JOIN fact_gross_price fg
	ON fs.product_code = fg.product_code
WHERE dc.customer = "Atliq Exclusive"
GROUP BY 1, 2;


/*
8. In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity
*/
SELECT 
	quarter(date) AS Quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;



/*
9. Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage
*/
SELECT 
	channel,
    SUM(fg.gross_price) AS gross_price_mln,
    (SUM(fg.gross_price) / (SELECT SUM(fg.gross_price)
							FROM fact_gross_price fg
                            JOIN fact_sales_monthly fs
								ON fg.product_code = fs.product_code
							WHERE fg.fiscal_year = 2021) * 100) AS percentage
FROM dim_customer dc
LEFT JOIN fact_sales_monthly fs
	ON dc.customer_code = fs.customer_code
LEFT JOIN fact_gross_price fg
	ON fs.product_code = fg.product_code
WHERE fg.fiscal_year = 2021
GROUP BY 1;



/*
10. Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? The final output contains these
fields,
division
product_code
*/
WITH cte AS(
SELECT 
	dp.division,
    dp.product_code,
    SUM(fs.sold_quantity) as total_sold_quantity,
    RANK() OVER(
				PARTITION BY division 
                ORDER BY SUM(fs.sold_quantity) DESC) as ranking
FROM dim_product dp
JOIN fact_sales_monthly fs
	ON dp.product_code = fs.product_code
WHERE fs.fiscal_year = 2021
GROUP BY 1, 2)
SELECT
	division,
    product_code
FROM cte
WHERE ranking <= 3