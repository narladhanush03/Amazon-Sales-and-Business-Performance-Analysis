DROP TABLE IF EXISTS amazon_sales_raw
-----------------------------------------------------------------------------------------------------------
--1.TABLE SCHEMA
-----------------------------------------------------------------------------------------------------------
CREATE TABLE amazon_sales_raw (
    order_id TEXT,
    customer_id TEXT,
    product_id TEXT,
    product TEXT,
    category TEXT,
    quantity TEXT,
    unit_price TEXT,
    discount TEXT,
    gross_sales TEXT,
    sales TEXT,
    product_cost TEXT,
    shipping_cost TEXT,
    total_cost TEXT,
    profit TEXT,
    returns TEXT,
    return_reason TEXT,
    payment_method TEXT,
    payment_status TEXT,
    customer_type TEXT,
    customer_value TEXT,
    warehouse TEXT,
    city TEXT,
    state TEXT,
    region TEXT,
    order_date TEXT,
    delivery_date TEXT,
    delivery_days TEXT,
    shipping_mode TEXT,
    delivery_status TEXT,
    rating TEXT,
    review_count TEXT
);

--======================================================================================================================
--2. DATA PROFILING
-----------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------
--2.1.TABLE STRUCTURE
-----------------------------------------------------------------------------------------------------------
SELECT
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns
WHERE table_schema = 'public'
  	  AND table_name = 'amazon_sales_raw'
ORDER BY ordinal_position;



-----------------------------------------------------------------------------------------------------------
--2.2.NO.OF RECORDS(ORDERS)
-----------------------------------------------------------------------------------------------------------
SELECT COUNT(*)
FROM amazon_sales_raw



-----------------------------------------------------------------------------------------------------------
--2.3.NO.OF DISTINCT ORDERS
-----------------------------------------------------------------------------------------------------------
SELECT COUNT(DISTINCT order_id)
FROM amazon_sales_raw



-----------------------------------------------------------------------------------------------------------
--2.4.INVESTIGATING 250 ORDER IDs
-----------------------------------------------------------------------------------------------------------
SELECT
    order_id,
    COUNT(*) AS row_count,
    COUNT(DISTINCT ROW(
        customer_id,
        product_id,
        product,
        category,
        quantity,
        unit_price,
        discount,
        gross_sales,
        sales,
        product_cost,
        shipping_cost,
        total_cost,
        profit,
        returns,
        return_reason,
        payment_method,
        payment_status,
        customer_type,
        customer_value,
        warehouse,
        city,
        state,
        region,
        order_date,
        delivery_date,
        delivery_days,
        shipping_mode,
        delivery_status,
        rating,
        review_count
    )) AS distinct_row_count
FROM amazon_sales_raw
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY order_id;



-----------------------------------------------------------------------------------------------------------
--DUPLICATE ROWS
-----------------------------------------------------------------------------------------------------------
SELECT *
FROM amazon_sales_raw
WHERE order_id IN (
    SELECT order_id
    FROM amazon_sales_raw
    GROUP BY order_id
    HAVING COUNT(*) > 1)
ORDER BY order_id;



-----------------------------------------------------------------------------------------------------------
--2.5.MISSING VALUES
-----------------------------------------------------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(order_id), '') IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(customer_id), '') IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(product_id), '') IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(product), '') IS NULL) AS missing_product,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(category), '') IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(quantity), '') IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(unit_price), '') IS NULL) AS missing_unit_price,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(discount), '') IS NULL) AS missing_discount,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(gross_sales), '') IS NULL) AS missing_gross_sales,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(sales), '') IS NULL) AS missing_sales,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(product_cost), '') IS NULL) AS missing_product_cost,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(shipping_cost), '') IS NULL) AS missing_shipping_cost,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(total_cost), '') IS NULL) AS missing_total_cost,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(profit), '') IS NULL) AS missing_profit,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(returns), '') IS NULL) AS missing_returns,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(return_reason), '') IS NULL) AS missing_return_reason,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(payment_method), '') IS NULL) AS missing_payment_method,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(payment_status), '') IS NULL) AS missing_payment_status,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(customer_type), '') IS NULL) AS missing_customer_type,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(customer_value), '') IS NULL) AS missing_customer_value,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(warehouse), '') IS NULL) AS missing_warehouse,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(city), '') IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(state), '') IS NULL) AS missing_state,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(region), '') IS NULL) AS missing_region,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(order_date), '') IS NULL) AS missing_order_date,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(delivery_date), '') IS NULL) AS missing_delivery_date,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(delivery_days), '') IS NULL) AS missing_delivery_days,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(shipping_mode), '') IS NULL) AS missing_shipping_mode,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(delivery_status), '') IS NULL) AS missing_delivery_status,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(rating), '') IS NULL) AS missing_rating,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(review_count), '') IS NULL) AS missing_review_count
FROM amazon_sales_raw;



-----------------------------------------------------------------------------------------------------------
--2.6.INVESTIGATING NULLs IN return_reason
-----------------------------------------------------------------------------------------------------------
SELECT
    returns,
    delivery_status,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(return_reason), '') IS NULL) AS missing_return_reason
FROM amazon_sales_raw
GROUP BY returns, delivery_status
ORDER BY returns, delivery_status;


-----------------------------------------------------------------------------------------------------------
--2.7.INSPECTING THOSE 89 NULLS
-----------------------------------------------------------------------------------------------------------
SELECT
    order_id,
    returns,
    return_reason,
    delivery_status,
    payment_status,
    category,
    product
FROM amazon_sales_raw
WHERE returns = 'Yes'
  AND delivery_status = 'Returned'
  AND NULLIF(TRIM(return_reason), '') IS NULL
ORDER BY order_id;


-----------------------------------------------------------------------------------------------------------
--2.8.INVESTIGATING NULLs IN delivery_date
-----------------------------------------------------------------------------------------------------------
SELECT
    delivery_status,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(delivery_date), '') IS NULL
    ) AS missing_delivery_date
FROM amazon_sales_raw
GROUP BY delivery_status
ORDER BY delivery_status;


-----------------------------------------------------------------------------------------------------------
--2.9.INVESTIGATING NULLs IN delivery_days
-----------------------------------------------------------------------------------------------------------
SELECT
    delivery_status,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(delivery_days), '') IS NULL
    ) AS missing_delivery_days
FROM amazon_sales_raw
GROUP BY delivery_status
ORDER BY delivery_status;


-----------------------------------------------------------------------------------------------------------
--2.10.INVESTIGATING NULLs IN rating
-----------------------------------------------------------------------------------------------------------
SELECT
    delivery_status,
    returns,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(rating), '') IS NULL
    ) AS missing_rating
FROM amazon_sales_raw
GROUP BY delivery_status, returns
ORDER BY delivery_status, returns;



--========================================================================================================
--3.QUALITY CHECKS
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--3.1.product
-----------------------------------------------------------------------------------------------------------
SELECT
    product,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY product
ORDER BY product;


-----------------------------------------------------------------------------------------------------------
--3.2.category
-----------------------------------------------------------------------------------------------------------
SELECT
    category,
    COUNT(*) AS row_count     
FROM amazon_sales_raw
GROUP BY category
ORDER BY category;


-----------------------------------------------------------------------------------------------------------
--3.3.returns
-----------------------------------------------------------------------------------------------------------
SELECT
    returns,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY returns
ORDER BY returns;


-----------------------------------------------------------------------------------------------------------
--3.4.return_reason
-----------------------------------------------------------------------------------------------------------
SELECT
    return_reason,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY return_reason
ORDER BY return_reason;


-----------------------------------------------------------------------------------------------------------
--3.5.payment_method
-----------------------------------------------------------------------------------------------------------
SELECT
    payment_method,
    COUNT(*) AS row_count    
FROM amazon_sales_raw
GROUP BY payment_method
ORDER BY payment_method;


-----------------------------------------------------------------------------------------------------------
--3.6.payment_status
-----------------------------------------------------------------------------------------------------------
SELECT
    payment_status,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY payment_status
ORDER BY payment_status;


-----------------------------------------------------------------------------------------------------------
--3.7.customer_type
-----------------------------------------------------------------------------------------------------------
SELECT
    customer_type,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY customer_type
ORDER BY customer_type;


-----------------------------------------------------------------------------------------------------------
--3.8.customer_value
-----------------------------------------------------------------------------------------------------------
SELECT
    customer_value,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY customer_value
ORDER BY customer_value;




-----------------------------------------------------------------------------------------------------------
--3.9.warehouse
-----------------------------------------------------------------------------------------------------------
SELECT
    warehouse,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY warehouse
ORDER BY warehouse;


-----------------------------------------------------------------------------------------------------------
--3.10.city
-----------------------------------------------------------------------------------------------------------
SELECT
    city,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY city
ORDER BY city;


-----------------------------------------------------------------------------------------------------------
--3.11.state
-----------------------------------------------------------------------------------------------------------
SELECT
    state,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY state
ORDER BY state;


-----------------------------------------------------------------------------------------------------------
--3.12.region
-----------------------------------------------------------------------------------------------------------
SELECT
    region,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY region
ORDER BY region;


-----------------------------------------------------------------------------------------------------------
--3.13.shipping_mode
-----------------------------------------------------------------------------------------------------------
SELECT
    shipping_mode,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY shipping_mode
ORDER BY shipping_mode;


-----------------------------------------------------------------------------------------------------------
--3.14.delivery_status
-----------------------------------------------------------------------------------------------------------
SELECT
    delivery_status,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY delivery_status
ORDER BY delivery_status;


--========================================================================================================
--4.NUMERIC DATA PROFILING
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE NULLIF(TRIM(quantity), '') IS NOT NULL
          				   AND quantity::NUMERIC <= 0) AS invalid_quantity,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(unit_price), '') IS NOT NULL
          			   	   AND unit_price::NUMERIC <= 0) AS invalid_unit_price,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(discount), '') IS NOT NULL
          				   AND (discount::NUMERIC < 0)) AS invalid_discount,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(gross_sales), '') IS NOT NULL
          				   AND gross_sales::NUMERIC < 0) AS negative_gross_sales,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(sales), '') IS NOT NULL
          				   AND sales::NUMERIC < 0) AS negative_sales,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(product_cost), '') IS NOT NULL
          				   AND product_cost::NUMERIC < 0) AS negative_product_cost,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(shipping_cost), '') IS NOT NULL
          				   AND shipping_cost::NUMERIC < 0) AS negative_shipping_cost,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(total_cost), '') IS NOT NULL
          				   AND total_cost::NUMERIC < 0) AS negative_total_cost,
							 
    COUNT(*) FILTER (WHERE NULLIF(TRIM(profit), '') IS NOT NULL
          				   AND profit::NUMERIC < 0) AS negative_profit,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(rating), '') IS NOT NULL
          				   AND (rating::NUMERIC < 1 OR rating::NUMERIC > 5)) AS invalid_rating,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(review_count), '') IS NOT NULL
          				   AND review_count::NUMERIC < 0) AS invalid_review_count,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(delivery_days), '') IS NOT NULL
          				   AND delivery_days::NUMERIC < 0) AS negative_delivery_days
FROM amazon_sales_raw;



-----------------------------------------------------------------------------------------------------------
-- 4.1.INVESTIGATING -VE PROFIT ROWS
-----------------------------------------------------------------------------------------------------------
SELECT
    order_id,
    ROUND(profit::NUMERIC, 2) AS profit,
    ROUND(sales::NUMERIC - product_cost::NUMERIC - shipping_cost::NUMERIC, 2) AS calculated_profit,
    ROUND(profit::NUMERIC - (sales::NUMERIC - product_cost::NUMERIC - shipping_cost::NUMERIC), 2) AS difference
FROM amazon_sales_raw
WHERE NULLIF(TRIM(profit), '') IS NOT NULL
  	  AND profit::NUMERIC < 0
ORDER BY order_id;


SELECT
    COUNT(*) AS mismatch_count
FROM amazon_sales_raw
WHERE NULLIF(TRIM(profit), '') IS NOT NULL
  AND profit::NUMERIC < 0
  AND ROUND(
        profit::NUMERIC
        - (sales::NUMERIC - product_cost::NUMERIC - shipping_cost::NUMERIC),
        2
      ) <> 0;

	  
--==================================================================================================================
--5.PROFILING CALCULATIONS ERRORS
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--5.1.GROSS SALES
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_gross_sales_rows
FROM amazon_sales_raw
WHERE ROUND(gross_sales::numeric, 2) <> ROUND(quantity::numeric * unit_price::numeric, 2);



-----------------------------------------------------------------------------------------------------------
--5.2.SALES
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_sales_rows
FROM amazon_sales_raw
WHERE delivery_status = 'Delivered'
  AND ROUND(sales::NUMERIC, 2) <> ROUND(gross_sales::NUMERIC - discount::NUMERIC, 2);	  



-----------------------------------------------------------------------------------------------------------
--5.3.TOTAL COST
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_total_cost_rows
FROM amazon_sales_raw
WHERE ROUND(total_cost::NUMERIC, 2) <> ROUND((product_cost::NUMERIC + shipping_cost::NUMERIC), 2);



-----------------------------------------------------------------------------------------------------------
--5.4.profit
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_profit_rows
FROM amazon_sales_raw
WHERE ROUND(profit::NUMERIC, 2) <> ROUND(sales::NUMERIC - product_cost::NUMERIC - shipping_cost::NUMERIC, 2);



-----------------------------------------------------------------------------------------------------------
--5.6.delivery_days
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_days
FROM amazon_sales_raw
WHERE delivery_date IS NOT NULL
  AND order_date IS NOT NULL
  AND ROUND(delivery_days::NUMERIC, 0) <> (delivery_date::DATE - order_date::DATE);



-----------------------------------------------------------------------------------------------------------
--5.7.delivery_date BEFORE order_date
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS delivery_before_order
FROM amazon_sales_raw
WHERE delivery_date IS NOT NULL
  AND order_date IS NOT NULL
  AND delivery_date::DATE < order_date::DATE;
	  
	  
--===================================================================================================================
--6.BUSINESS RULE PROFILING 
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
---6.1.delivery_status VS returns
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE delivery_status = 'Delivered'
            		 AND returns <> 'No') AS delivered_returns_no,

    COUNT(*) FILTER (WHERE delivery_status = 'Returned'
          		 	 AND returns <> 'Yes') AS returned_returns_yes,

    COUNT(*) FILTER (WHERE delivery_status = 'Cancelled'
          			 AND returns <> 'No') AS cancelled_returns_no
FROM amazon_sales_raw;



-----------------------------------------------------------------------------------------------------------
--6.2.payment_status vs delivery_status
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE delivery_status = 'Delivered'
						   AND payment_status <> 'Paid') AS delivered_not_paid,

    COUNT(*) FILTER (WHERE delivery_status = 'Returned'
          				   AND payment_status <> 'Refunded') AS returned_not_refunded,

    COUNT(*) FILTER (WHERE delivery_status = 'Cancelled'
          			       AND payment_status <> 'Refunded') AS cancelled_not_refunded
FROM amazon_sales_raw;
	  


-----------------------------------------------------------------------------------------------------------	
--6.3.return_reason VS delivery_status
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE delivery_status = 'Returned'
          				   AND NULLIF(TRIM(return_reason), '') IS NULL) AS returned_missing_reason,

    COUNT(*) FILTER (WHERE delivery_status IN ('Delivered', 'Cancelled')
          				   AND NULLIF(TRIM(return_reason), '') IS NOT NULL) AS delivered_cancelled_with_reason
FROM amazon_sales_raw;



-----------------------------------------------------------------------------------------------------------
--6.4.rating VS delivery_status
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS rating_recorded_for_cancelled
FROM amazon_sales_raw
WHERE delivery_status = 'Cancelled'
  AND NULLIF(TRIM(rating), '') IS NOT NULL;

  

--=========================================================================================================
--7.ZERO NUMERIC PROFILING
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE quantity::NUMERIC = 0) AS zero_quantity,
    COUNT(*) FILTER (WHERE unit_price::NUMERIC = 0) AS zero_unit_price,
    COUNT(*) FILTER (WHERE gross_sales::NUMERIC = 0) AS zero_gross_sales,
    COUNT(*) FILTER (WHERE sales::NUMERIC = 0) AS zero_sales,
    COUNT(*) FILTER (WHERE product_cost::NUMERIC = 0) AS zero_product_cost,
    COUNT(*) FILTER (WHERE shipping_cost::NUMERIC = 0) AS zero_shipping_cost,
    COUNT(*) FILTER (WHERE total_cost::NUMERIC = 0) AS zero_total_cost,
    COUNT(*) FILTER (WHERE profit::NUMERIC = 0) AS zero_profit
FROM amazon_sales_raw;



-----------------------------------------------------------------------------------------------------------
--7.1.INVESTIGATING
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS row_count
FROM amazon_sales_raw
WHERE sales::NUMERIC = 0
  AND product_cost::NUMERIC = 0
  AND shipping_cost::NUMERIC = 0
  AND total_cost::NUMERIC = 0
  AND profit::NUMERIC = 0
  AND delivery_status IN ('Returned','Cancelled');




--========================================================================================================
--8.GEOGRAPHICAL PROFILING
-----------------------------------------------------------------------------------------------------------
SELECT
    warehouse,
    city,
    state,
    region,
    COUNT(*) AS row_count
FROM amazon_sales_raw
GROUP BY
    warehouse,
    city,
    state,
    region
ORDER BY
    warehouse,
    state,
    city,
    region;


	
---=========================================================================================================	
---=========================================================================================================
DROP TABLE IF EXISTS amazon_sales_clean

-----------------------------------------------------------------------------------------------------------
--9.CLEANING
-----------------------------------------------------------------------------------------------------------
CREATE TABLE amazon_sales_clean AS
SELECT DISTINCT
    TRIM(order_id) AS order_id,
    TRIM(customer_id) AS customer_id,
    TRIM(product_id) AS product_id,
    TRIM(product) AS product,
	
	CASE
	    WHEN LOWER(TRIM(category)) = 'clothing'
	        THEN 'Clothing'
	    WHEN LOWER(TRIM(category)) = 'clothong'
	        THEN 'Clothing'
	    WHEN LOWER(TRIM(category)) = 'electronics'
	        THEN 'Electronics'
	    WHEN LOWER(TRIM(category)) = 'footwear'
	        THEN 'Footwear'
	    WHEN LOWER(TRIM(category)) = 'furniture'
	        THEN 'Furniture'
	    WHEN LOWER(TRIM(category)) = 'grocery'
	        THEN 'Grocery'
	    WHEN LOWER(TRIM(category)) IN ('home & kitchen', 'home and kitchen')
	        THEN 'Home & Kitchen'
	    WHEN LOWER(TRIM(category)) IN ('sports & fitness', 'sports and fitness')
	        THEN 'Sports & Fitness'
	    WHEN LOWER(TRIM(category)) IN ('toys & games', 'toys and games')
	        THEN 'Toys & Games'
	    WHEN LOWER(TRIM(category)) = 'books'
	        THEN 'Books'
	    WHEN LOWER(TRIM(category)) = 'beauty & personal care'
	        THEN 'Beauty & Personal Care'
	    ELSE TRIM(category)
	END AS category,
	
    TRIM(quantity)::NUMERIC AS quantity,
    TRIM(unit_price)::NUMERIC AS unit_price,
    TRIM(discount)::NUMERIC AS discount,
    TRIM(gross_sales)::NUMERIC AS gross_sales,
    TRIM(sales)::NUMERIC AS sales,
    TRIM(product_cost)::NUMERIC AS product_cost,
    TRIM(shipping_cost)::NUMERIC AS shipping_cost,
    TRIM(total_cost)::NUMERIC AS total_cost,
    TRIM(profit)::NUMERIC AS profit,
    TRIM(returns) AS returns,
	
    CASE
        WHEN delivery_status IN ('Delivered', 'Cancelled')
             AND NULLIF(TRIM(return_reason), '') IS NULL
        THEN 'N/A'
        ELSE NULLIF(TRIM(return_reason), '')
    END AS return_reason,
	
	CASE
	    WHEN LOWER(TRIM(payment_method)) IN ('upi')
	        THEN 'UPI'
	    WHEN LOWER(TRIM(payment_method)) IN ('cash on delivery', 'cod')
	        THEN 'Cash On Delivery'
	    WHEN LOWER(TRIM(payment_method)) = 'credit card'
	        THEN 'Credit Card'
	    WHEN LOWER(TRIM(payment_method)) = 'debit card'
	        THEN 'Debit Card'
	    WHEN LOWER(TRIM(payment_method)) IN ('net banking', 'netbanking')
	        THEN 'Net Banking'
	    WHEN LOWER(TRIM(payment_method)) = 'wallet'
	        THEN 'Wallet'
	    ELSE TRIM(payment_method)
	END AS payment_method,
	TRIM(payment_status) AS payment_status,
    TRIM(customer_type) AS customer_type,
    TRIM(customer_value) AS customer_value,
    TRIM(warehouse) AS warehouse,
    TRIM(city) AS city,
    CASE
        WHEN TRIM(city) = 'Ahmedabad' THEN 'Gujarat'
        WHEN TRIM(city) = 'Bengaluru' THEN 'Karnataka'
        WHEN TRIM(city) = 'Bhopal' THEN 'Madhya Pradesh'
        WHEN TRIM(city) = 'Bhubaneswar' THEN 'Odisha'
        WHEN TRIM(city) = 'Chandigarh' THEN 'Punjab'
        WHEN TRIM(city) = 'Chennai' THEN 'Tamil Nadu'
        WHEN TRIM(city) = 'Coimbatore' THEN 'Tamil Nadu'
        WHEN TRIM(city) = 'Delhi' THEN 'Delhi'
        WHEN TRIM(city) = 'Gurugram' THEN 'Haryana'
        WHEN TRIM(city) = 'Guwahati' THEN 'Assam'
        WHEN TRIM(city) = 'Hyderabad' THEN 'Telangana'
        WHEN TRIM(city) = 'Indore' THEN 'Madhya Pradesh'
        WHEN TRIM(city) = 'Jaipur' THEN 'Rajasthan'
        WHEN TRIM(city) = 'Karimnagar' THEN 'Telangana'
        WHEN TRIM(city) = 'Kochi' THEN 'Kerala'
        WHEN TRIM(city) = 'Kolkata' THEN 'West Bengal'
        WHEN TRIM(city) = 'Lucknow' THEN 'Uttar Pradesh'
        WHEN TRIM(city) = 'Mumbai' THEN 'Maharashtra'
        WHEN TRIM(city) = 'Nagpur' THEN 'Maharashtra'
        WHEN TRIM(city) = 'Noida' THEN 'Uttar Pradesh'
        WHEN TRIM(city) = 'Patna' THEN 'Bihar'
        WHEN TRIM(city) = 'Pune' THEN 'Maharashtra'
        WHEN TRIM(city) = 'Surat' THEN 'Gujarat'
        WHEN TRIM(city) = 'Vijayawada' THEN 'Andhra Pradesh'
        WHEN TRIM(city) = 'Visakhapatnam' THEN 'Andhra Pradesh'
        ELSE TRIM(state)
    END AS state,
    INITCAP(TRIM(region)) AS region,
    TRIM(order_date)::DATE AS order_date,
	
	CASE
	    WHEN NULLIF(TRIM(delivery_date), '') IS NULL
	        THEN NULL	
	    WHEN TRIM(delivery_date) ~ '^\d{4}-\d{2}-\d{2}$'
	        THEN TRIM(delivery_date)::DATE	
	    WHEN TRIM(delivery_date) ~ '^\d{2}-\d{2}-\d{4}$'
	        THEN TO_DATE(TRIM(delivery_date), 'DD-MM-YYYY')
	    ELSE NULL
	END AS delivery_date,
	
	CASE
	    WHEN NULLIF(TRIM(delivery_days), '') IS NULL
	        THEN NULL	
	    ELSE NULLIF(TRIM(delivery_days), '')::NUMERIC
	END AS delivery_days,
	
    TRIM(shipping_mode) AS shipping_mode,
    TRIM(delivery_status) AS delivery_status,
	
    CASE
        WHEN delivery_status = 'Cancelled'
             AND NULLIF(TRIM(rating), '') IS NULL
        THEN 'N/A'
        ELSE NULLIF(TRIM(rating), '')
    END AS rating,
	
    TRIM(review_count)::NUMERIC AS review_count
FROM amazon_sales_raw;

---========================================================================================================
---========================================================================================================
--10.VALIDATION


-----------------------------------------------------------------------------------------------------------
--10.1.DUPLICATES
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders
FROM amazon_sales_clean;



-----------------------------------------------------------------------------------------------------------	
--10.2.return_reason VS delivery_status
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE delivery_status = 'Returned'
          				   AND return_reason IS NULL) AS returned_missing_reason,
							 
    COUNT(*) FILTER (WHERE delivery_status = 'Returned'
          				   AND return_reason IS NOT NULL) AS returned_having_missing_reason,

    COUNT(*) FILTER (WHERE delivery_status IN ('Delivered', 'Cancelled')
          				   AND return_reason IS NOT NULL) AS delivered_cancelled_not_applicable
FROM amazon_sales_clean;



-----------------------------------------------------------------------------------------------------------
--10.3.rating VS delivery_status
----------------------------------------------------------------------------------------------------------- 
SELECT
    COUNT(*) FILTER (WHERE delivery_status = 'Cancelled'
          				   AND rating IS NULL) AS cancelled_rating_rows,
							 
    COUNT(*) FILTER (WHERE delivery_status = 'Cancelled'
          				   AND rating IS NOT NULL) AS cancelled_rating_not_applicable_rows,
							 
    COUNT(*) FILTER (WHERE delivery_status IN ('Delivered', 'Returned')
          				   AND rating IS NOT NULL) AS delivered_returned_rating_rows,

    COUNT(*) FILTER (WHERE delivery_status IN ('Delivered', 'Returned')
          				   AND rating IS NULL) AS delivered_returned_missing_rating_rows
FROM amazon_sales_clean;




-----------------------------------------------------------------------------------------------------------
--10.4.DATA QUALITY category
-----------------------------------------------------------------------------------------------------------
SELECT category, COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY category
ORDER BY category;



-----------------------------------------------------------------------------------------------------------
--10.5.DATA QUALITY payment_method
-----------------------------------------------------------------------------------------------------------
SELECT payment_method, COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY payment_method
ORDER BY payment_method;



-----------------------------------------------------------------------------------------------------------
--10.6.city state MATCH
-----------------------------------------------------------------------------------------------------------
SELECT city, state, COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY city, state
ORDER BY city, state;



-----------------------------------------------------------------------------------------------------------
--10.7.START, END DATES AND PERIOD
-----------------------------------------------------------------------------------------------------------
SELECT
    MIN(order_date) AS start_date,
    MAX(order_date) AS end_date,
	
    (EXTRACT(YEAR FROM MAX(order_date)) * 12 + EXTRACT(MONTH FROM MAX(order_date)))
    -(EXTRACT(YEAR FROM MIN(order_date)) * 12 + EXTRACT(MONTH FROM MIN(order_date)))
	+ 1 AS analysis_period_months
FROM amazon_sales_clean;


--========================================================================================================
--11.GENERAL VALIDATION
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--11.1.product
-----------------------------------------------------------------------------------------------------------
SELECT
    product,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY product
ORDER BY product;



-----------------------------------------------------------------------------------------------------------
--11.2.returns
-----------------------------------------------------------------------------------------------------------
SELECT
    returns,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY returns
ORDER BY returns;


-----------------------------------------------------------------------------------------------------------
--11.3.return_reason
-----------------------------------------------------------------------------------------------------------
SELECT
    return_reason,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY return_reason
ORDER BY return_reason;



-----------------------------------------------------------------------------------------------------------
--11.4.payment_status
-----------------------------------------------------------------------------------------------------------
SELECT
    payment_status,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY payment_status
ORDER BY payment_status;


-----------------------------------------------------------------------------------------------------------
--11.5.customer_type
-----------------------------------------------------------------------------------------------------------
SELECT
    customer_type,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY customer_type
ORDER BY customer_type;


-----------------------------------------------------------------------------------------------------------
--11.6.customer_value
-----------------------------------------------------------------------------------------------------------
SELECT
    customer_value,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY customer_value
ORDER BY customer_value;




-----------------------------------------------------------------------------------------------------------
--11.7.warehouse
-----------------------------------------------------------------------------------------------------------
SELECT
    warehouse,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY warehouse
ORDER BY warehouse;


-----------------------------------------------------------------------------------------------------------
--11.8.city
-----------------------------------------------------------------------------------------------------------
SELECT
    city,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY city
ORDER BY city;


-----------------------------------------------------------------------------------------------------------
--11.9.state
-----------------------------------------------------------------------------------------------------------
SELECT
    state,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY state
ORDER BY state;


-----------------------------------------------------------------------------------------------------------
--11.10.region
-----------------------------------------------------------------------------------------------------------
SELECT
    region,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY region
ORDER BY region;


-----------------------------------------------------------------------------------------------------------
--11.11.shipping_mode
-----------------------------------------------------------------------------------------------------------
SELECT
    shipping_mode,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY shipping_mode
ORDER BY shipping_mode;


-----------------------------------------------------------------------------------------------------------
--11.12.delivery_status
-----------------------------------------------------------------------------------------------------------
SELECT
    delivery_status,
    COUNT(*) AS row_count
FROM amazon_sales_clean
GROUP BY delivery_status
ORDER BY delivery_status;


--========================================================================================================
--11.13.NUMERIC DATA PROFILING
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE quantity IS NOT NULL
          				   AND quantity <= 0) AS invalid_quantity,

    COUNT(*) FILTER (WHERE unit_price IS NOT NULL
          			   	   AND unit_price <= 0) AS invalid_unit_price,

    COUNT(*) FILTER (WHERE discount IS NOT NULL
          				   AND discount < 0) AS invalid_discount,

    COUNT(*) FILTER (WHERE gross_sales IS NOT NULL
          				   AND gross_sales::NUMERIC < 0) AS negative_gross_sales,

    COUNT(*) FILTER (WHERE sales IS NOT NULL
          				   AND sales < 0) AS negative_sales,

    COUNT(*) FILTER (WHERE product_cost IS NOT NULL
          				   AND product_cost < 0) AS negative_product_cost,

    COUNT(*) FILTER (WHERE shipping_cost IS NOT NULL
          				   AND shipping_cost < 0) AS negative_shipping_cost,

    COUNT(*) FILTER (WHERE total_cost IS NOT NULL
          				   AND total_cost < 0) AS negative_total_cost,
							 
    COUNT(*) FILTER (WHERE profit IS NOT NULL
          				   AND profit < 0) AS negative_profit,

    COUNT(*) FILTER (WHERE NULLIF(TRIM(rating), '') IS NOT NULL
					      AND rating <> 'N/A'
					      AND (rating !~ '^[0-9]+(\.[0-9]+)?$'
					          OR rating::NUMERIC < 1
					          OR rating::NUMERIC > 5)) AS invalid_rating,

    COUNT(*) FILTER (WHERE review_count IS NOT NULL
          				   AND review_count < 0) AS invalid_review_count,

    COUNT(*) FILTER (WHERE delivery_days IS NOT NULL
          				   AND delivery_days < 0) AS negative_delivery_days
FROM amazon_sales_clean;




--==================================================================================================================
--VALIDATING CALCULATIONS 
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
--11.14.GROSS SALES
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_gross_sales_rows
FROM amazon_sales_clean
WHERE ROUND(gross_sales, 2) <> ROUND(quantity * unit_price, 2);



-----------------------------------------------------------------------------------------------------------
--11.15.SALES
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_sales_rows
FROM amazon_sales_clean
WHERE delivery_status = 'Delivered'
  AND ROUND(sales, 2) <> ROUND(gross_sales - discount, 2);	  



-----------------------------------------------------------------------------------------------------------
--11.16.TOTAL COST
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_total_cost_rows
FROM amazon_sales_clean
WHERE ROUND(total_cost, 2) <> ROUND((product_cost + shipping_cost), 2);



-----------------------------------------------------------------------------------------------------------
--11.17.profit
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_profit_rows
FROM amazon_sales_clean
WHERE ROUND(profit, 2) <> ROUND(sales - product_cost - shipping_cost, 2);



-----------------------------------------------------------------------------------------------------------
--11.18.delivery_days
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_days
FROM amazon_sales_clean
WHERE delivery_date IS NOT NULL
  AND order_date IS NOT NULL
  AND ROUND(delivery_days, 0) <> (delivery_date - order_date);



-----------------------------------------------------------------------------------------------------------
--11.19.delivery_date BEFORE order_date
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS delivery_before_order
FROM amazon_sales_clean
WHERE delivery_date IS NOT NULL
  AND order_date IS NOT NULL
  AND delivery_date < order_date;
	  
	  
--===================================================================================================================
--BUSINESS RULE validation 
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
---11.20.delivery_status VS returns
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE delivery_status = 'Delivered'
            		 AND returns <> 'No') AS delivered_returns_no,

    COUNT(*) FILTER (WHERE delivery_status = 'Returned'
          		 	 AND returns <> 'Yes') AS returned_returns_yes,

    COUNT(*) FILTER (WHERE delivery_status = 'Cancelled'
          			 AND returns <> 'No') AS cancelled_returns_no
FROM amazon_sales_clean;



-----------------------------------------------------------------------------------------------------------
--11.21.payment_status vs delivery_status
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE delivery_status = 'Delivered'
						   AND payment_status <> 'Paid') AS delivered_not_paid,

    COUNT(*) FILTER (WHERE delivery_status = 'Returned'
          				   AND payment_status <> 'Refunded') AS returned_not_refunded,

    COUNT(*) FILTER (WHERE delivery_status = 'Cancelled'
          			       AND payment_status <> 'Refunded') AS cancelled_not_refunded
FROM amazon_sales_clean;
	  






--=========================================================================================================
--11.22.ZERO NUMERIC VALIDATION
-----------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE quantity = 0) AS zero_quantity,
    COUNT(*) FILTER (WHERE unit_price = 0) AS zero_unit_price,
    COUNT(*) FILTER (WHERE gross_sales = 0) AS zero_gross_sales,
    COUNT(*) FILTER (WHERE sales = 0) AS zero_sales,
    COUNT(*) FILTER (WHERE product_cost = 0) AS zero_product_cost,
    COUNT(*) FILTER (WHERE shipping_cost = 0) AS zero_shipping_cost,
    COUNT(*) FILTER (WHERE total_cost = 0) AS zero_total_cost,
    COUNT(*) FILTER (WHERE profit = 0) AS zero_profit
FROM amazon_sales_clean;


SELECT
    COUNT(*) AS row_count
FROM amazon_sales_clean
WHERE sales = 0
  AND product_cost = 0
  AND shipping_cost = 0
  AND total_cost = 0
  AND profit = 0
  AND delivery_status IN ('Returned','Cancelled');
