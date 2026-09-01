# Methodology

## 分析粒度
核心履约分析以订单为单位；加入品类后使用 `order_id × category` 粒度。

## 一对多关系处理
- payment：先按 `order_id` 聚合
- review：保留每个订单最新评价
- category：同一订单同一品类只保留一条

## 延迟口径
```sql
DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0
```

## 时间窗口
2017-01-01 至 2018-08-31。

## 解释边界
延迟与低评分呈明显负向关联，但本项目不将其表述为严格因果关系。
