-- Monthly totals
SELECT
  FORMAT_DATE("%Y-%m", DATE(o.order_time)) AS year_month,
  SUM(o.total_usd) AS total_revenue,
  COUNT(o.order_id) AS num_orders,
  COUNT(DISTINCT o.customer_id) AS num_unique_customers
FROM `e_commerce_dataset.orders` o
GROUP BY year_month
ORDER BY year_month DESC;

--Top products
SELECT
  p.product_id,
  p.name AS product_name,
  p.category,
  COUNT(o.order_id) AS num_orders,
  SUM(oi.quantity) AS items_sold,
  ROUND(SUM(oi.unit_price_usd * oi.quantity), 2) AS total_revenue, --let's imagine that 'line_total_usd' does not exist
  ROUND(AVG(oi.unit_price_usd * oi.quantity), 2) AS avg_order_price
FROM `e_commerce_dataset.orders` o
JOIN `e_commerce_dataset.order_items` oi
  ON o.order_id = oi.order_id
JOIN `e_commerce_dataset.products` p
  ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name, category
ORDER BY total_revenue DESC;
