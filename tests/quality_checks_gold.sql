

/*
==============================================================================================
Quality Checks
==============================================================================================

Script Purpose:
	This script performs quality checks to validate the integrity, consistency, and accuracy
	of the Gold Layer. These check ensures:
	-Uniqueness of surrogate keys in dimension tables.
	-Referential integrity between fact   and dimension tables.
	-validation of relationship in the data model for analytical purposes.

Usage: 
	- Run these checks after data loading silver Layer.
	-Investigate and resolve any discrepancies found during the checks.
===========================================================================================
*/

--==============================================================================================
--Checking 'gold.dim-customer'
--==============================================================================================


-- Check for Uniqueness of Customer key in gold.dim_customers
-- Expectation: No results

SELECT 
	customer_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_customer
GROUP BY customer_key
HAVING COUNT(*) > 1;

--==============================================================================================
--Checking 'gold.dim-products'
--==============================================================================================

-- Check for Uniqueness of product key in gold.dim_product
-- Expectation: No results

SELECT
	product_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

--==============================================================================================
--Checking 'gold.fact_sales'
--==============================================================================================

-- Check the data model connectivity between fact and dimensions

SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customer c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;

