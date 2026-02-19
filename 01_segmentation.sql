-- Goal: Segment customers into "New" and "Returning" groups
-- based on their purchase behavior in the most recent month available in the dataset (determined by MAX(order_time))

WITH
  first_order AS (
    SELECT
      o.customer_id,
      MIN(o.order_time) AS first_purchase
    FROM `e_commerce_dataset.orders` o
    GROUP BY o.customer_id
  ),

  segmentation AS (
    SELECT
      o.customer_id,
      COUNT(order_id) AS total_orders,
      CASE
        WHEN DATE(DATE_TRUNC(fo.first_purchase, MONTH)) = DATE('2025-10-01')
          THEN 'New'
        ELSE 'Returning'
        END AS customer_type
    FROM `e_commerce_dataset.orders` o
    JOIN first_order fo
      ON fo.customer_id = o.customer_id
    WHERE DATE(DATE_TRUNC(o.order_time, MONTH)) = DATE('2025-10-01')
    GROUP BY o.customer_id, fo.first_purchase
  )
  
-- Count distinct customers in each group and calculate average orders  
SELECT
  customer_type,
  COUNT(DISTINCT customer_id) AS num_customers,
  AVG(total_orders) AS avg_orders
FROM segmentation
GROUP BY customer_type;
