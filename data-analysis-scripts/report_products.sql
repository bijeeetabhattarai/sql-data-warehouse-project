/*
================================================================================================================
Product Report
================================================================================================================
Purpose: 
	- This report consolidates key product metrics and behaviours

Highlights:
	1. Gather essential fields such as product name, category, subcategory, and cost.
	2. Segments products by revenue identify High-performers, Mid-Range, or low-Performers.
	3. Aggregates product-level metrics:
		-Total orders
		-Total sales
		-Total quantity sold
		-Total customers (unique)
		-Lifespan (in months)
	4. Calculates valuable KPIs:
		-recency (months since last sale)
		-average order revenue
		-average monthly revenue

======================================================================================================================
*/

IF OBJECT_ID ('gold.report_products', 'V') IS NOT NULL
	 DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

--1) Base Query: Retrieves core columns from Tables 
WITH base_query AS(
	SELECT 
		f.order_number,
		f.customer_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL-- Only consider valid sales sates
),

--2) product Aggregations: Summarizes key metrics at the product level

Product_aggregation AS(
	SELECT 
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT customer_key) AS total_customers,
		MAX(order_date) AS last_sale_date,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
		ROUND(AVG(CAST (sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price

	FROM base_query 
	GROUP BY 
		product_key,
		product_name,
		category,
		subcategory,
		cost
)

--3) Final Query: Combine all product results into one output

SELECT 
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
DATEDIFF(month, last_sale_date, GETDATE())  AS recency_in_months,
CASE 
	WHEN total_sales > 50000 THEN 'High-performer'
	WHEN total_sales >= 10000 THEN 'Mid-Range'
	ELSE 'Low-Performer'
END AS product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,

--Average order Revenue
CASE 
	WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders
END AS avg_order_revenue,
-- Average monthly revenue
CASE
	 WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales/lifespan
END AS avg_monthly_revenue
FROM product_aggregation
