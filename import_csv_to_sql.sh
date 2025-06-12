#!/bin/bash

DB_NAME="ecommerce.db"
TABLE_IMPORT="e_commerce_transactions_import"
TABLE_FINAL="e_commerce_transactions"
CSV_FILE="data/e_commerce_transactions.csv"

rm -f $DB_NAME

sqlite3 $DB_NAME <<EOF
PRAGMA journal_mode = OFF;
PRAGMA synchronous = OFF;

.mode csv
.import $CSV_FILE $TABLE_IMPORT

DROP TABLE IF EXISTS $TABLE_FINAL;
CREATE TABLE $TABLE_FINAL (
    order_id      TEXT,
    customer_id   TEXT,
    order_date    DATE,
    payment_value REAL,
    decoy_flag    TEXT,
    decoy_noise   REAL
);

BEGIN TRANSACTION;
INSERT INTO $TABLE_FINAL (
    order_id, customer_id, order_date, payment_value, decoy_flag, decoy_noise
)
SELECT
    order_id,
    customer_id,
    order_date,
    CAST(payment_value AS REAL),
    decoy_flag,
    CAST(decoy_noise AS REAL)
FROM $TABLE_IMPORT;
COMMIT;

DROP TABLE $TABLE_IMPORT;

PRAGMA journal_mode = DELETE;
PRAGMA synchronous = FULL;
EOF

echo "Import CSV ke SQL Lite Selesai!"