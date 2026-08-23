/* 
PROJECT: CUSTOMER SHOPPING TRENDS ANALYSIS
AUTHOR: [YOGITHA PRASAD]
DESCRIPTION: Advanced SQL queries to extract business KPIs and customer behavior insights.
*/

-- Q1. Revenue Contribution & Market Share by Gender

SELECT 
    gender, 
    SUM(purchase_amount) AS total_revenue,
    ROUND(100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER(), 2) AS revenue_percentage
FROM customer
GROUP BY gender;


-- Q2. High-Value Discount Seekers
SELECT 
    customer_id, 
    purchase_amount, 
    spending_tier,
    location
FROM customer 
WHERE discount_applied = 'Yes' 
  AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer)
ORDER BY purchase_amount DESC;


-- Q3. Top Rated Products (Weighted by Popularity)
SELECT 
    item_purchased, 
    COUNT(*) AS review_count,
    ROUND(AVG(CAST(review_rating AS NUMERIC)), 2) AS avg_rating
FROM customer
GROUP BY item_purchased
HAVING COUNT(*) > 5 -- Shows you think about statistical significance
ORDER BY avg_rating DESC
LIMIT 5;


-- Q4. Shipping Efficiency: Impact on Average Order Value (AOV)
SELECT 
    shipping_type, 
    COUNT(*) AS order_volume,
    ROUND(AVG(purchase_amount), 2) AS average_order_value
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;


-- Q5. Subscription ROI: Do Subscribers drive higher value?
SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(SUM(purchase_amount) / COUNT(customer_id), 2) AS rev_per_customer
FROM customer
GROUP BY subscription_status;


-- Q6. Discount Sensitivity Analysis by Product
SELECT 
    item_purchased,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS discounted_sales,
    COUNT(*) AS total_sales,
    ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS discount_sensitivity_pct
FROM customer
GROUP BY item_purchased
ORDER BY discount_sensitivity_pct DESC
LIMIT 5;


-- Q7. Customer Loyalty Segmentation (Advanced CTE)
WITH loyalty_calc AS (
    SELECT 
        customer_id, 
        previous_purchases,
        CASE 
            WHEN previous_purchases <= 3 THEN 'New/Occasional'
            WHEN previous_purchases BETWEEN 4 AND 15 THEN 'Frequent'
            ELSE 'Brand Ambassador'
        END AS loyalty_segment
    FROM customer
)
SELECT 
    loyalty_segment, 
    COUNT(*) AS segment_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS pct_of_base
FROM loyalty_calc
GROUP BY loyalty_segment;


-- Q8. Top 3 Best-Sellers Per Category (Window Function)
WITH product_rankings AS (
    SELECT 
        category,
        item_purchased,
        COUNT(*) AS units_sold,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT * 
FROM product_rankings 
WHERE rank <= 3;


-- Q9. Subscription Propensity of Power Users
SELECT 
    subscription_status,
    COUNT(*) AS power_user_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS conversion_rate
FROM customer
WHERE previous_purchases > 10
GROUP BY subscription_status;


-- Q10. Revenue Heatmap by Age Group & Tier
SELECT 
    age_group,
    spending_tier,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group, spending_tier
ORDER BY age_group, total_revenue DESC;