# Cara Menjalankan Semua Program

## Bagian A
Jalankan program ke terminal dengan menjalankan script:
1. chmod +x import_csv_to_sql.sh -> bertujuan memberikan hak akses ke file .sh
2. ./import_csv_to_sql.sh -> bertujuan menimport CSV ke SQLLite table
3. sqlite3 ecommerce.db < analysis.sql
4. Cek apakah semua sudah tersedia di table dengan menjalankan checking.ipynb (Optional)
5. Hasil detail RFM dan segmentasi yang dipilih serta alasannya dapat dilihat pada ./A_findings.md

## Bagian B
1. Running semua file ./notebooks/B_modeling.ipynb dengan kernel python
2. Cek semua hasil di folder path yang sama
3. Model masih harus diperbaiki, hal ini perlu hyperparameter tuning dan feature engineering yang baik.
4. Model terbaik dipilih berdasarkan nilai Recall terbaik, hal ini dipilih karena bertujuan untuk berhati-hati tidak melolosnya user yang akan gagal bayar dibanding melihat keseimbangan AUC-ROC.
5. Model terbaik saat in Logistic Regression, hal ini dapat terjadi karena model gradient overfititng dan tidak stabil terhadap karakter data yang terlalu sederhana.

## Bagian C
1. Pastikan R sudah terinstal, jika belum diharapkan instal R tersebih dahulu
2. Jalankan di terminal script ./validation.R dengan perinrtah Rscript validation.R
3. R akan mengambil data csv dari ./notebooks/test_pred.csv
4. Hasil analisa dapat dilihat pada ./C_Summary.md