-- Identify each customer's first purchase month in 2025
WITH
  customer_first_purchase_2025 AS (
    SELECT
      customer_id,
      DATE_TRUNC(DATE(MIN(order_time)), MONTH) AS first_purchase_month
    FROM e_commerce_dataset.orders
    GROUP BY customer_id
    HAVING EXTRACT(YEAR FROM MIN(order_time)) = 2025
  ),

  -- Count active customers by month since their first purchase
  cohort_activity AS (
    SELECT
      cfp.first_purchase_month,
      DATE_DIFF(
        DATE_TRUNC(DATE(o.order_time), MONTH), cfp.first_purchase_month, MONTH)
        AS months_since_first,
      COUNT(DISTINCT o.customer_id) AS active_customers
    FROM e_commerce_dataset.orders o
    JOIN customer_first_purchase_2025 cfp
      ON o.customer_id = cfp.customer_id
    GROUP BY cfp.first_purchase_month, months_since_first
  ),

  -- Calculate cohort size (number of customers at M0)
  cohort_size AS (
    SELECT
      first_purchase_month,
      COUNT(DISTINCT customer_id) AS cohort_size
    FROM customer_first_purchase_2025
    GROUP BY first_purchase_month
  ),

  -- Compute retention percentage for each month
  retention AS (
    SELECT
      FORMAT_DATE("%Y-%m", ca.first_purchase_month) AS cohort_month,
      months_since_first,
      ROUND(100 * active_customers / cs.cohort_size, 1) AS retention_percent
    FROM cohort_activity ca
    JOIN cohort_size cs
      ON ca.first_purchase_month = cs.first_purchase_month
  )

-- Pivot results into wide format (M0–M6)
SELECT *
FROM
  retention
    PIVOT(
      MAX(retention_percent)
        FOR
          months_since_first IN (
            0 AS M0, 1 AS M1, 2 AS M2, 3 AS M3, 4 AS M4, 5 AS M5, 6 AS M6))
ORDER BY cohort_month;
