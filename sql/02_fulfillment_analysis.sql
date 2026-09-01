-- 02_fulfillment_analysis.sql
USE olist_project;

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 2) AS avg_delivery_days,
    SUM(
        CASE
            WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0
            THEN 1 ELSE 0
        END
    ) AS delayed_orders,
    ROUND(
        SUM(
            CASE
                WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0
                THEN 1 ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS delay_rate,
    ROUND(
        AVG(
            CASE
                WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0
                THEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)
            END
        ),
        2
    ) AS avg_delay_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp < '2018-09-01';

SELECT
    CASE
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 0 THEN 'On time'
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) BETWEEN 1 AND 3 THEN '1-3 days late'
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) BETWEEN 4 AND 7 THEN '4-7 days late'
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) BETWEEN 8 AND 14 THEN '8-14 days late'
        ELSE '15+ days late'
    END AS delay_group,
    COUNT(*) AS order_count
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp < '2018-09-01'
GROUP BY delay_group
ORDER BY
    CASE delay_group
        WHEN 'On time' THEN 1
        WHEN '1-3 days late' THEN 2
        WHEN '4-7 days late' THEN 3
        WHEN '8-14 days late' THEN 4
        WHEN '15+ days late' THEN 5
    END;
