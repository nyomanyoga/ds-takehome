#!/bin/bash

# Nama file db dan tabel
DB_NAME="ecommerce_transactions.db"
TABLE_NAME="e_commerce_transactions"
CSV_FILE="data/e_commerce_transactions.csv"

# Hapus DB lama jika ada (opsional)
rm -f $DB_NAME

# Jalankan import ke SQLite
sqlite3 $DB_NAME <<EOF
.mode csv
.import $CSV_FILE $TABLE_NAME
EOF

echo "Import selesai! File $CSV_FILE sudah masuk ke $DB_NAME (tabel: $TABLE_NAME)"