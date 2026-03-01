WITH
  events AS (
    SELECT
      session_id,
      timestamp,
      event_type AS current_event,
      COALESCE(
        LEAD(event_type) OVER (PARTITION BY session_id ORDER BY timestamp),
        'Drop-off') AS next_event
    FROM e_commerce_dataset.events
    ORDER BY session_id, timestamp
  )
  
--navigation paths & drop-offs
SELECT
  current_event,
  next_event,
  COUNT(*) AS num_transition
FROM events
GROUP BY current_event, next_event
ORDER BY num_transition DESC;
