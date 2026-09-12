--BUSINESS ANALYSIS
--===================================================


------------------------------------------------------------------------------------------------------------------------
--1.EXECUTIVE KPIs
-----------------------------------------------------------------------------------------------------------------------
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
	SUM(quantity) As total_units,
	COUNT(DISTINCT order_id) FILTER (WHERE delivery_status = 'Delivered') AS delivered_orders,
    SUM(quantity) FILTER (WHERE delivery_status = 'Delivered') AS delivered_units,
	SUM(gross_sales) FILTER (WHERE delivery_status = 'Delivered') AS gross_sales,
    SUM(discount) FILTER (WHERE delivery_status = 'Delivered') AS total_discount,
    SUM(sales) AS total_sales,
	SUM(total_cost) FILTER (WHERE delivery_status = 'Delivered') AS total_cost,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)::TEXT || '%' AS profit_margin_pct,
    COUNT(*) FILTER (WHERE returns = 'Yes') AS returned_orders,
	SUM(quantity) FILTER (WHERE delivery_status = 'Returned') AS returned_units,
    ROUND(COUNT(*) FILTER (WHERE returns = 'Yes')::NUMERIC/ NULLIF(COUNT(DISTINCT order_id), 0) * 100,2)::TEXT || '%' AS return_rate_pct,
    COUNT(*) FILTER (WHERE delivery_status = 'Cancelled') AS cancelled_orders,
	SUM(quantity) FILTER (WHERE delivery_status = 'Cancelled') AS cancelled_units,
    ROUND(COUNT(*) FILTER (WHERE delivery_status = 'Cancelled')::NUMERIC/ NULLIF(COUNT(DISTINCT order_id), 0) * 100,2)::TEXT || '%' AS cancel_rate_pct
FROM amazon_sales_clean;




--CUSTOMERS
WITH customer_contribution AS (
    SELECT
        customer_id,
        SUM(CASE
                WHEN delivery_status = 'Delivered'
                THEN sales
                ELSE 0
            END) AS delivered_sales
    FROM amazon_sales_clean
    GROUP BY customer_id)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE delivered_sales > 0) AS contributed_customers,
    COUNT(*) FILTER (WHERE delivered_sales = 0) AS never_contributed_customers
FROM customer_contribution;


-----------------------------------------------------------------------------------------------------------------------
--2.MONTHLY SALES TREND
-----------------------------------------------------------------------------------------------------------------------
SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    COUNT(DISTINCT order_id) FILTER (WHERE delivery_status = 'Delivered') AS delivered_orders,
    SUM(quantity) FILTER (WHERE delivery_status = 'Delivered') AS delivered_units,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)::TEXT || '%' AS profit_margin_pct
FROM amazon_sales_clean
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;



-----------------------------------------------------------------------------------------------------------------------
--3.CATEGORY PERFORMANCE
-----------------------------------------------------------------------------------------------------------------------
SELECT
    category,
    COUNT(DISTINCT order_id) FILTER (WHERE delivery_status = 'Delivered') AS delivered_orders,
    SUM(quantity) FILTER (WHERE delivery_status = 'Delivered') AS delivered_units,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)::TEXT || '%' AS profit_margin_pct
FROM amazon_sales_clean
GROUP BY category
ORDER BY total_sales DESC;



-----------------------------------------------------------------------------------------------------------------------
--4.PRODUCT PERFORMANCE & PROFITABILITY
-----------------------------------------------------------------------------------------------------------------------
SELECT
    product,
    COUNT(DISTINCT order_id) FILTER (WHERE delivery_status = 'Delivered') AS delivered_order,
    SUM(quantity) FILTER (WHERE delivery_status = 'Delivered') AS delivered_units,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)::TEXT || '%' AS profit_margin_pct
FROM amazon_sales_clean
GROUP BY product
HAVING SUM(sales) > 0
ORDER BY total_sales DESC;




-----------------------------------------------------------------------------------------------------------------------
--5.DISCOUNT & PROFITABILITY
-----------------------------------------------------------------------------------------------------------------------
WITH distinct_delivered_discounts AS (
    SELECT DISTINCT discount
    FROM amazon_sales_clean
    WHERE discount > 0
      	  AND delivery_status = 'Delivered'),

discount_quartiles AS (
    SELECT
        PERCENTILE_CONT(0.25)WITHIN GROUP (ORDER BY discount) AS q1,
        PERCENTILE_CONT(0.50)WITHIN GROUP (ORDER BY discount) AS median,
        PERCENTILE_CONT(0.75)WITHIN GROUP (ORDER BY discount) AS q3
    FROM distinct_delivered_discounts),

classified_data AS (
    SELECT a.*,
        CASE
            WHEN a.delivery_status IS NULL
                THEN 'Unknown'
            WHEN a.delivery_status <> 'Delivered'
                THEN 'Not Applicable'
            WHEN a.discount = 0
                THEN 'No Discount'
            WHEN a.discount <= q.q1
                THEN 'Low Discount'
            WHEN a.discount <= q.median
                THEN 'Medium Discount'
            WHEN a.discount <= q.q3
                THEN 'High Discount'
            ELSE 'Very High Discount'
        END AS discount_band
    FROM amazon_sales_clean a
    CROSS JOIN discount_quartiles q)

SELECT
    discount_band,
    COUNT(DISTINCT order_id) AS delivered_orders,
    SUM(discount) AS total_discount,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)::TEXT || '%' AS profit_margin_pct
FROM classified_data
WHERE delivery_status = 'Delivered'
GROUP BY discount_band
ORDER BY
    CASE discount_band
        WHEN 'No Discount' THEN 1
        WHEN 'Low Discount' THEN 2
        WHEN 'Medium Discount' THEN 3
        WHEN 'High Discount' THEN 4
        WHEN 'Very High Discount' THEN 5
    END;	




-----------------------------------------------------------------------------------------------------------------------
--6.CUSTOMER TYPE PERFORMANCE
-----------------------------------------------------------------------------------------------------------------------
SELECT
    customer_type,
    COUNT(DISTINCT order_id) AS total_orders,
	COUNT(DISTINCT order_id) FILTER (WHERE delivery_status = 'Delivered') AS delivered_orders,
    SUM(quantity) FILTER (WHERE delivery_status = 'Delivered') AS delivered_units,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)::TEXT || '%' AS profit_margin_pct
FROM amazon_sales_clean
GROUP BY customer_type
ORDER BY total_sales DESC;




-----------------------------------------------------------------------------------------------------------------------
--7.CUSTOMER PURCHASE FREQUENCY
-----------------------------------------------------------------------------------------------------------------------
WITH customer_summary AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS customer_orders
    FROM amazon_sales_clean
    GROUP BY customer_id),

purchase_frequency AS (
    SELECT
        customer_id,
        CASE
            WHEN customer_orders = 1
                THEN 'One-Time'
            WHEN customer_orders BETWEEN 2 AND 4
                THEN 'Occasional'
            WHEN customer_orders BETWEEN 5 AND 7
                THEN 'Frequent'
            ELSE 'Highly Frequent'
        END AS purchase_frequency
    FROM customer_summary)

SELECT
    cs.purchase_frequency,
    COUNT(DISTINCT a.customer_id) AS total_customers,
    COUNT(DISTINCT a.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN a.delivery_status = 'Delivered'
        THEN a.order_id
    END) AS delivered_orders,
    SUM(CASE
        WHEN a.delivery_status = 'Delivered'
        THEN a.quantity
        ELSE 0
    END) AS delivered_units,
    SUM(a.sales) AS total_sales,
    SUM(a.profit) AS total_profit,
    ROUND(SUM(a.profit) /
            NULLIF(SUM(a.sales), 0) * 100, 2):: TEXT || '%' AS profit_margin_pct,
    ROUND(SUM(CASE
            WHEN a.delivery_status = 'Delivered'
            THEN a.sales
            ELSE 0
        END)
        /
        NULLIF(
            COUNT(DISTINCT CASE
                WHEN a.delivery_status = 'Delivered'
                THEN a.order_id
            END), 0), 2) AS avg_order_value
FROM amazon_sales_clean a
JOIN purchase_frequency cs
    ON a.customer_id = cs.customer_id
GROUP BY
    cs.purchase_frequency
ORDER BY
    total_sales DESC;




-----------------------------------------------------------------------------------------------------------------------
--8.CUSTOMER VALUE
-----------------------------------------------------------------------------------------------------------------------
WITH customer_value_summary AS (
    SELECT
        customer_id,
        COUNT(DISTINCT CASE
            			   WHEN delivery_status = 'Delivered'
            			   THEN order_id
        				END) AS delivered_orders,
        SUM(CASE
               WHEN delivery_status = 'Delivered'
               THEN sales
               ELSE 0
           END) AS delivered_sales,
        SUM(CASE
               WHEN delivery_status = 'Delivered'
               THEN profit
               ELSE 0
            END) AS delivered_profit
    FROM amazon_sales_clean
    GROUP BY customer_id),

classified_customers AS (
    SELECT
        customer_id,
        delivered_orders,
        delivered_sales,
        delivered_profit,
        CASE
            WHEN delivered_sales < 5000
                THEN 'Budget'
            WHEN delivered_sales < 15000
                THEN 'Regular'
            ELSE 'Premium'
        END AS customer_value
    FROM customer_value_summary)

SELECT
    customer_value,
    COUNT(DISTINCT customer_id) AS total_customers,
	COUNT(DISTINCT CASE
        WHEN delivered_sales > 0
        THEN customer_id
    END) AS contributed_customers,
    SUM(delivered_orders) AS delivered_orders,
    ROUND(SUM(delivered_sales), 2) AS total_sales,
    ROUND(SUM(delivered_profit), 2) AS total_profit,
    ROUND(SUM(delivered_profit)
        				/ NULLIF(SUM(delivered_sales), 0) * 100, 2):: TEXT || '%' AS profit_margin_pct,
    ROUND(SUM(delivered_sales)
                        / NULLIF(SUM(delivered_orders), 0), 2) AS avg_order_value
FROM classified_customers
GROUP BY customer_value
ORDER BY
    CASE customer_value
        WHEN 'Budget' THEN 1
        WHEN 'Regular' THEN 2
        WHEN 'Premium' THEN 3
    END;




-----------------------------------------------------------------------------------------------------------------------
--9.CUSTOMER RATING
-----------------------------------------------------------------------------------------------------------------------
SELECT
    rating,
    COUNT(DISTINCT order_id) AS total_orders
FROM amazon_sales_clean
WHERE rating IS NOT NULL
  AND TRIM(LOWER(rating::text)) NOT IN ('', 'n/a', 'na')
GROUP BY rating
ORDER BY rating desc;	



-----------------------------------------------------------------------------------------------------------------------
--10.GEOGRAPHIC PERFORMANCE
-----------------------------------------------------------------------------------------------------------------------
SELECT
	state,
	city,
    COUNT(DISTINCT order_id) FILTER (WHERE delivery_status = 'Delivered') AS delivered_orders,
    SUM(quantity) FILTER (WHERE delivery_status = 'Delivered') AS delivered_units,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2):: TEXT || '%' AS profit_margin_pct
FROM amazon_sales_clean
GROUP BY state, city
ORDER BY total_sales DESC;






-----------------------------------------------------------------------------------------------------------------------
--11.DELIVERY PERFORMANCE
-----------------------------------------------------------------------------------------------------------------------
SELECT
	delivery_status,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id) * 100.0/
        						NULLIF(SUM(COUNT(DISTINCT order_id)) OVER (), 0), 2) AS delivery_status_rate_pct,
    SUM(quantity) AS total_units,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) /
        		NULLIF(SUM(sales), 0) * 100, 2):: TEXT || '%' AS profit_margin_pct
FROM amazon_sales_clean
GROUP BY 
	     delivery_status
ORDER BY total_orders DESC;




-----------------------------------------------------------------------------------------------------------------------
--12.SHIPPING & DELIVERY PERFORMANCE
-----------------------------------------------------------------------------------------------------------------------
SELECT
    shipping_mode,
    delivery_status,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) FILTER (WHERE delivery_status = 'Delivered') AS total_units,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2):: TEXT || '%' AS profit_margin_pct
FROM amazon_sales_clean
WHERE delivery_status='Delivered'
GROUP BY
    shipping_mode,
    delivery_status
ORDER BY
    total_sales DESC;





-----------------------------------------------------------------------------------------------------------------------
--13.REGIONAL DELIVERY TIME
-----------------------------------------------------------------------------------------------------------------------
SELECT
    city,
    COUNT(DISTINCT order_id) AS delivered_orders,
    ROUND(AVG(delivery_date::date - order_date::date), 2) AS avg_delivery_days,
    MIN(delivery_date::date - order_date::date) AS min_delivery_days,
    MAX(delivery_date::date - order_date::date) AS max_delivery_days
FROM amazon_sales_clean
WHERE delivery_status = 'Delivered'
  AND order_date IS NOT NULL
  AND delivery_date IS NOT NULL
GROUP BY city
ORDER BY avg_delivery_days DESC;






-----------------------------------------------------------------------------------------------------------------------
--14.RETURN PERFORMANCE
-----------------------------------------------------------------------------------------------------------------------
SELECT
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT order_id) FILTER (WHERE returns = 'Yes') AS returned_orders,
    ROUND(COUNT(DISTINCT order_id) FILTER (WHERE returns = 'Yes')::NUMERIC
										/ NULLIF(COUNT(DISTINCT order_id), 0) * 100, 2) AS return_rate_pct
FROM amazon_sales_clean
GROUP BY category
ORDER BY return_rate_pct DESC;




-----------------------------------------------------------------------------------------------------------------------
--15.RETURN REASON
-----------------------------------------------------------------------------------------------------------------------
SELECT
    return_reason,
    COUNT(DISTINCT order_id) AS returned_orders,
    SUM(quantity) AS returned_units,
    ROUND(COUNT(DISTINCT order_id) * 100.0 /
        					SUM(COUNT(DISTINCT order_id)) OVER (), 2) AS return_reason_pct
FROM amazon_sales_clean
WHERE returns = 'Yes'
  AND delivery_status = 'Returned'
  AND return_reason IS NOT NULL
GROUP BY return_reason
ORDER BY returned_orders DESC;

















