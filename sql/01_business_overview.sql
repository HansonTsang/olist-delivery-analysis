-- 01_business_overview.sql
USE olist_project;

SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    ROUND(
        SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) AS delivery_rate
FROM olist_orders_dataset;

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_orders_dataset), 2) AS status_rate
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY order_count DESC;

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders
FROM olist_orders_dataset
WHERE YEAR(order_purchase_timestamp) = 2016
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(p.order_payment), 2) AS gmv,
    ROUND(AVG(p.order_payment), 2) AS avg_order_value
FROM olist_orders_dataset o
JOIN (
    SELECT order_id, SUM(payment_value) AS order_payment
    FROM olist_order_payments_dataset
    GROUP BY order_id
) p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;
