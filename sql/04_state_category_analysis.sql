-- 04_state_category_analysis.sql
USE olist_project;

DROP TABLE IF EXISTS order_delivery_base;

CREATE TABLE order_delivery_base AS
SELECT
    o.order_id,
    c.customer_state,
    DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delay_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01';

ALTER TABLE order_delivery_base MODIFY order_id VARCHAR(32);
ALTER TABLE order_delivery_base ADD INDEX idx_delivery_order_id (order_id);

DROP TABLE IF EXISTS order_category_base;

CREATE TABLE order_category_base AS
SELECT DISTINCT
    i.order_id,
    COALESCE(t.product_category_name_english, p.product_category_name) AS category_name
FROM olist_order_items_dataset i
JOIN olist_products_dataset p ON i.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL;

ALTER TABLE order_category_base MODIFY order_id VARCHAR(32);
ALTER TABLE order_category_base ADD INDEX idx_category_order_id (order_id);

DROP TABLE IF EXISTS order_category_review_base;

CREATE TABLE order_category_review_base AS
SELECT
    d.order_id,
    d.customer_state,
    c.category_name,
    d.delay_days,
    r.review_score
FROM order_delivery_base d
JOIN order_category_base c ON d.order_id = c.order_id
JOIN review_latest_base r ON d.order_id = r.order_id;

SELECT
    customer_state,
    category_name,
    COUNT(*) AS reviewed_orders,
    SUM(CASE WHEN delay_days > 0 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(
        SUM(CASE WHEN delay_days > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) AS delay_rate,
    SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) AS low_score_orders,
    SUM(
        CASE WHEN delay_days > 0 AND review_score <= 2 THEN 1 ELSE 0 END
    ) AS delayed_low_score_orders,
    ROUND(
        SUM(
            CASE WHEN delay_days > 0 AND review_score <= 2 THEN 1 ELSE 0 END
        ) / COUNT(*) * 100,
        2
    ) AS delayed_low_score_rate,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM order_category_review_base
GROUP BY customer_state, category_name
HAVING COUNT(*) >= 100
ORDER BY delayed_low_score_orders DESC;
