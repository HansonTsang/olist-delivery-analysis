-- 00_data_preparation.sql
USE olist_project;

ALTER TABLE olist_orders_dataset
MODIFY COLUMN order_purchase_timestamp DATETIME,
MODIFY COLUMN order_approved_at DATETIME,
MODIFY COLUMN order_delivered_carrier_date DATETIME,
MODIFY COLUMN order_delivered_customer_date DATETIME,
MODIFY COLUMN order_estimated_delivery_date DATETIME;

ALTER TABLE olist_order_reviews_dataset
MODIFY COLUMN review_score TINYINT,
MODIFY COLUMN review_creation_date DATETIME,
MODIFY COLUMN review_answer_timestamp DATETIME;

ALTER TABLE olist_order_items_dataset
MODIFY COLUMN order_item_id TINYINT,
MODIFY COLUMN shipping_limit_date DATETIME,
MODIFY COLUMN price DECIMAL(10,2),
MODIFY COLUMN freight_value DECIMAL(10,2);

ALTER TABLE olist_order_payments_dataset
MODIFY COLUMN payment_sequential TINYINT,
MODIFY COLUMN payment_installments TINYINT,
MODIFY COLUMN payment_value DECIMAL(10,2);

ALTER TABLE olist_orders_dataset ADD INDEX idx_orders_order_id (order_id(32));
ALTER TABLE olist_order_payments_dataset ADD INDEX idx_payments_order_id (order_id(32));
ALTER TABLE olist_order_reviews_dataset ADD INDEX idx_reviews_order_id (order_id(32));
ALTER TABLE olist_orders_dataset ADD INDEX idx_orders_customer_id (customer_id(32));
ALTER TABLE olist_customers_dataset ADD INDEX idx_customers_customer_id (customer_id(32));
ALTER TABLE olist_order_items_dataset ADD INDEX idx_items_order_id (order_id(32));
ALTER TABLE olist_order_items_dataset ADD INDEX idx_items_product_id (product_id(32));
ALTER TABLE olist_products_dataset ADD INDEX idx_products_product_id (product_id(32));

-- Note:
-- product_category_name_translation 的第一列表头在导入时曾带 UTF-8 BOM，
-- 需要将隐藏前缀清理后再按 product_category_name 进行 JOIN。
