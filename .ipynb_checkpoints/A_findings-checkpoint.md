## 1. Penjelasan RFM:
**Metrik utama hasil RFM (Recency, Frequency, Monetary):**
* RH/RL (Recency High/Low). Pada proses ini definisi RH adalah nilai recency yang paling baru dan RL adalah nilai yang paling lama. Pada script sudah ada proses pembalikan.
* FH/FL (Frequency High/Low)
* MH/ML (Monetary High/Low)

**Penamaan Segmen**
* **Unggulan:** RH-FH-MH — Pelanggan paling baru, sering, dan nilai besar. Loyal dan sangat berharga.
* **Berisiko:** RL-FL-ML — Lama tidak aktif, jarang, nilai kecil. Berpotensi churn.
* **Pasif:** RL-FH-MH — Tidak baru, tapi dulunya loyal dengan nilai besar.
* **Baru:** RH-FL-ML — Baru saja belanja, tapi masih sedikit dan nilainya kecil.
* **Menjanjikan:** RH-FH-ML — Sering dan baru, tapi nilai transaksinya kecil. Potensi naik kelas.
* **Eksklusif:** RL-FL-MH — Jarang transaksi, lama, tapi tiap transaksi nilainya besar.
* **Lainnya:** Kombinasi lain yang tidak masuk kategori utama di atas.

## 2. Cek Anomali/Outlier:
Script mendeteksi outlier pada kolom decoy_noise menggunakan dua metode (IQR dan Z-score) dengan ketentuan:
* IQR dengan range nilai diantara Q1 (0.25) sampai Q3 (0.75).
* Nilai z-score diatas absolut 3, karena nilai diatas 3 berarti sangat jauh dengan nilai rata-rata data.

## 3. Query Repeat-Purchase Bulanan
Query repeat-purchase bulanan dibuat untuk mengetahui pelanggan yang bertransaksi lebih dari sekali per bulan.