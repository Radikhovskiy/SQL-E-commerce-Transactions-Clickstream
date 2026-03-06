-- Aggregate product-level sales and revenue
WITH
  product_info AS (
    SELECT
      p.product_id,
      p.name,
      SUM(oi.quantity) AS items_sold,
      ROUND(SUM(oi.line_total_usd)) AS revenue
    FROM e_commerce_dataset.orders o
    JOIN e_commerce_dataset.order_items oi
      ON o.order_id = oi.order_id
    JOIN e_commerce_dataset.products p
      ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.name
  )

-- Rank products and assign performance categories
-- Remove 'DESC' below in both cases to see the reverse order
SELECT
  *,
  DENSE_RANK() OVER (ORDER BY revenue DESC) AS rank,
  CASE NTILE(3) OVER (ORDER BY revenue DESC)
    WHEN 1 THEN 'Top'
    WHEN 2 THEN 'Mid'
    WHEN 3 THEN 'Underperformer'
    END AS performance_category
FROM product_info;
