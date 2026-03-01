-- Aggregate unique sessions at each funnel stage
WITH
  funnel_counts AS (
    SELECT
      COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN session_id END)
        AS num_page_views,
      COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN session_id END)
        AS num_add_to_cart,
      COUNT(DISTINCT CASE WHEN event_type = 'checkout' THEN session_id END)
        AS num_checkout,
      COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN session_id END)
        AS num_purchase
    FROM e_commerce_dataset.events
  )
  
-- Build funnel table: each stage compared to the previous one to calculate conversion
SELECT
  'page_view' AS stage,
  num_page_views AS num_sessions,
  '100%' AS conversion_rate                                                  -- Baseline: all views = 100%
FROM funnel_counts
UNION ALL
SELECT
  'add_to_cart',
  num_add_to_cart,
  CONCAT(ROUND(SAFE_DIVIDE(num_add_to_cart, num_page_views) * 100, 1), '%')  -- Conversion = cart / views
FROM funnel_counts
UNION ALL
SELECT
  'checkout',
  num_checkout,
  CONCAT(ROUND(SAFE_DIVIDE(num_checkout, num_add_to_cart) * 100, 1), '%')    -- Conversion = checkout / cart
FROM funnel_counts
UNION ALL
SELECT
  'purchase',
  num_purchase,
  CONCAT(ROUND(SAFE_DIVIDE(num_purchase, num_checkout) * 100, 1), '%')       -- Conversion = purchase / checkout
FROM funnel_counts;
