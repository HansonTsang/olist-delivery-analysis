-- 03_review_analysis.sql
USE olist_project;

SELECT
    COUNT(*) AS review_rows,
    COUNT(DISTINCT order_id) AS reviewed_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_rows
FROM olist_order_reviews_dataset;

DROP TABLE IF EXISTS review_latest_base;

CREATE TABLE review_latest_base AS
SELECT
    r.order_id,
    r.review_score
FROM olist_order_reviews_dataset r
LEFT JOIN olist_order_reviews_dataset r2
    ON r.order_id = r2.order_id
    AND (
        r2.review_answer_timestamp > r.review_answer_timestamp
        OR (
            r2.review_answer_timestamp = r.review_answer_timestamp
            AND r2.review_id > r.review_id
        )
    )
WHERE r2.order_id IS NULL;

ALTER TABLE review_latest_base MODIFY order_id VARCHAR(32);
ALTER TABLE review_latest_base ADD INDEX idx_review_order_id (order_id);

SELECT
    CASE
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 0 THEN 'On time'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) BETWEEN 1 AND 3 THEN '1-3 days late'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) BETWEEN 4 AND 7 THEN '4-7 days late'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) BETWEEN 8 AND 14 THEN '8-14 days late'
        ELSE '15+ days late'
    END AS delay_group,
    COUNT(*) AS reviewed_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS low_score_orders,
    ROUND(
        SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) AS low_score_rate
FROM olist_orders_dataset o
JOIN review_latest_base r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY delay_group
ORDER BY
    CASE delay_group
        WHEN 'On time' THEN 1
        WHEN '1-3 days late' THEN 2
        WHEN '4-7 days late' THEN 3
        WHEN '8-14 days late' THEN 4
        WHEN '15+ days late' THEN 5
    END;
