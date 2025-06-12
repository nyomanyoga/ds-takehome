## 1. Penjelasan RFM
**Metrik utama hasil RFM (Recency, Frequency, Monetary):**
* RH/RL (Recency High/Low)
* FH/FL (Frequency High/Low)
* MH/ML (Monetary High/Low)

**Penamaan 6 Segmen Utama**
1. **Unggulan** (`RH-FH-MH`)
   * Loyal, aktif, dan bernilai besar. Jaga dan beri reward.
     
2. **Potensial** (`RH-FH-ML` & `RH-FL-MH`)
   * Pelanggan baru, baik yang sering belanja (nilai kecil) atau baru tapi langsung nilai besar. Dorong upsell/cross-sell.
     
3. **Baru** (`RH-FL-ML`)
   * Pelanggan benar-benar baru, jarang belanja, nilai kecil. Bangun pengalaman positif.
     
4. **Pasif/Berkembang** (`RL-FH-MH` & `RL-FH-ML`)
   * Pelanggan lama yang pernah aktif/bernilai. Perlu diaktivasi kembali, beri penawaran khusus.
     
5. **Eksklusif** (`RL-FL-MH`)
   * Tidak sering belanja, tapi setiap belanja nilainya besar. Berikan perlakuan VIP.
     
6. **Berisiko** (`RL-FL-ML`)
   * Sudah lama, jarang, nilai kecil. Prioritas rendah dalam pemasaran.

---

## 2. Cek Anomali/Outlier
Script mendeteksi outlier pada kolom decoy_noise menggunakan dua metode (IQR dan Z-score) dengan ketentuan:
* IQR dengan range nilai di antara Q1 (0.25) sampai Q3 (0.75).
* Nilai z-score di atas absolut 3, karena nilai di atas 3 berarti sangat jauh dengan nilai rata-rata data.

---

## 3. Query Repeat-Purchase Bulanan
Query repeat-purchase bulanan dibuat untuk mengetahui pelanggan yang bertransaksi lebih dari sekali per bulan.

---