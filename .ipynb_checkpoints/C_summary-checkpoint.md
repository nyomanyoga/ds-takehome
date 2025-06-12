## Result
data:  val$default, val$prob_default
X-squared = 561.65, df = 8, p-value < 2.2e-16

HL test p-value: 0 
Cut-off probability (expected default ≤ 5%): 0 

## Summary
Berdasarkan hasil uji Hosmer-Lemeshow, diperoleh nilai p-value = 0, yang menunjukkan ketidaksesuaian antara prediksi model dan data aktual pada validation set. Kalibrasi model juga mengindikasikan bahwa model cenderung overconfident pada prediksi probabilitas rendah. Cut-off probability agar expected default ≤ 5% berada di nilai 0.00, setara dengan scorecard maksimum 850. Artinya, hanya peminjam dengan kemungkinan gagal bayar hampir nol yang direkomendasikan untuk disetujui. Hal ini menunjukkan model terlalu konservatif dan perlu perbaikan kalibrasi atau threshold agar lebih seimbang dalam praktik pemeringkatan risiko. namun hal ini saya pilih karena saya berharap memilih model yang benar-benar berhati-hati dalam menyetujui peminjaman.