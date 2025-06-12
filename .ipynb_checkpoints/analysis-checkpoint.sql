-- ==========================================
-- INDEXING PERCEPAT QUERY
-- ==========================================
CREATE INDEX IF NOT EXISTS idx_ecom_customer_date ON e_commerce_transactions(customer_id, order_date);
CREATE INDEX IF NOT EXISTS idx_ecom_noise ON e_commerce_transactions(decoy_noise);

-- ==========================================
-- 1. HITUNG RFM + ≥ 6 SEGMEN PELANGGAN DENGAN NAMA
-- ==========================================
DROP TABLE IF EXISTS customer_segment;

CREATE TABLE customer_segment AS
WITH
  base AS (
    SELECT
      customer_id,
      CAST(
        julianday((SELECT MAX(order_date) FROM e_commerce_transactions))
        - julianday(MAX(order_date))
      AS INT) AS recency,
      COUNT(*)       AS frequency,
      SUM(payment_value) AS monetary
    FROM e_commerce_transactions
    GROUP BY customer_id
  ),
  stats AS (
    SELECT
      AVG(recency)   AS avg_recency,
      AVG(frequency) AS avg_frequency,
      AVG(monetary)  AS avg_monetary
    FROM base
  ),
  flags AS (
    SELECT
      b.customer_id,
      b.recency,
      b.frequency,
      b.monetary,
      CASE WHEN b.recency   <= s.avg_recency   THEN 'RH' ELSE 'RL' END AS recency_flag,
      CASE WHEN b.frequency >= s.avg_frequency THEN 'FH' ELSE 'FL' END AS frequency_flag,
      CASE WHEN b.monetary  >= s.avg_monetary  THEN 'MH' ELSE 'ML' END AS monetary_flag
    FROM base b
    CROSS JOIN stats s
  )
SELECT
  customer_id,
  recency,
  frequency,
  monetary,
  recency_flag || '-' || frequency_flag || '-' || monetary_flag AS rfm_segment,
  CASE
    WHEN recency_flag='RH' AND frequency_flag='FH' AND monetary_flag='MH' THEN 'Unggulan'
    WHEN recency_flag='RL' AND frequency_flag='FL' AND monetary_flag='ML' THEN 'Berisiko'
    WHEN recency_flag='RL' AND frequency_flag='FH' AND monetary_flag='MH' THEN 'Pasif'
    WHEN recency_flag='RH' AND frequency_flag='FL' AND monetary_flag='ML' THEN 'Baru'
    WHEN recency_flag='RH' AND frequency_flag='FH' AND monetary_flag='ML' THEN 'Menjanjikan'
    WHEN recency_flag='RL' AND frequency_flag='FL' AND monetary_flag='MH' THEN 'Eksklusif'
    ELSE 'Lainnya'
  END AS segment_label
FROM flags;

-- ==========================================
-- 2. QUERY REPEAT–PURCHASE BULANAN + EXPLAIN
-- ==========================================
DROP TABLE IF EXISTS repeat_purchase_monthly;

CREATE TABLE repeat_purchase_monthly AS
SELECT
  customer_id,
  strftime('%Y-%m', order_date) AS year_month,
  COUNT(*) AS order_count
FROM e_commerce_transactions
GROUP BY customer_id, year_month
HAVING order_count > 1;

EXPLAIN QUERY PLAN
SELECT
  customer_id,
  strftime('%Y-%m', order_date) AS year_month,
  COUNT(*) AS order_count
FROM e_commerce_transactions
GROUP BY customer_id, year_month
HAVING order_count > 1;

-- ==========================================
-- 3. OUTLIER DETECTION (IQR DAN Z-SCORE) DECOY_NOISE
-- ==========================================

-- Step 1: Buat view untuk batas IQR
DROP VIEW IF EXISTS iqr_bounds;
CREATE VIEW iqr_bounds AS
WITH percentiles AS (
  SELECT
    (
      SELECT decoy_noise
      FROM e_commerce_transactions
      ORDER BY decoy_noise
      LIMIT 1 OFFSET (SELECT CAST(COUNT(*) * 0.25 AS INT) FROM e_commerce_transactions)
    ) AS q1,
    (
      SELECT decoy_noise
      FROM e_commerce_transactions
      ORDER BY decoy_noise
      LIMIT 1 OFFSET (SELECT CAST(COUNT(*) * 0.75 AS INT) FROM e_commerce_transactions)
    ) AS q3
)
SELECT
  q1,
  q3,
  (q3 - q1) AS iqr,
  (q1 - 1.5 * (q3 - q1)) AS lower_bound,
  (q3 + 1.5 * (q3 - q1)) AS upper_bound
FROM percentiles;

-- Step 2: Buat view untuk statistik decoy_noise (mean & stddev)
DROP VIEW IF EXISTS noise_stats;
CREATE VIEW noise_stats AS
SELECT
  AVG(decoy_noise) AS mean_noise,
  -- stddev manual: sqrt(avg(x^2) - avg(x)^2)
  sqrt(AVG(decoy_noise * decoy_noise) - AVG(decoy_noise) * AVG(decoy_noise)) AS stddev_noise
FROM e_commerce_transactions;

-- Step 3: Flag outlier (IQR & Z-score) untuk seluruh data
DROP TABLE IF EXISTS decoy_noise_outliers;
CREATE TABLE decoy_noise_outliers AS
WITH decoy_noise_flagged AS (
  SELECT
    t.*,
    i.lower_bound,
    i.upper_bound,
    s.mean_noise,
    s.stddev_noise,
    -- IQR Outlier Flag
    CASE
      WHEN t.decoy_noise < i.lower_bound OR t.decoy_noise > i.upper_bound THEN 1
      ELSE 0
    END AS is_outlier_iqr,
    -- Z-score
    CASE
      WHEN s.stddev_noise > 0 THEN (t.decoy_noise - s.mean_noise) / s.stddev_noise
      ELSE NULL
    END AS z_score,
    -- Z-score Outlier Flag
    CASE
      WHEN s.stddev_noise > 0 AND ABS((t.decoy_noise - s.mean_noise) / s.stddev_noise) > 3 THEN 1
      ELSE 0
    END AS is_outlier_zscore
  FROM
    e_commerce_transactions t
    CROSS JOIN iqr_bounds i
    CROSS JOIN noise_stats s
)
SELECT * FROM decoy_noise_flagged WHERE is_outlier_iqr = 1
UNION
SELECT * FROM decoy_noise_flagged WHERE is_outlier_zscore = 1;