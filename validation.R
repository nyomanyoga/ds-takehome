# --- Install package jika belum ada (jalankan hanya sekali) ---
# install.packages("ResourceSelection")
# install.packages("ggplot2")

library(ResourceSelection)
library(ggplot2)

# --- 1. Import data prediksi dari Python (ubah path sesuai kebutuhan) ---
val <- read.csv('./notebooks/test_pred.csv')

# --- 2. Pastikan kolom label dan prediksi probabilitas numeric dan benar 0/1 ---
# Ganti nama kolom sesuai dengan file Anda
val$default <- as.numeric(val$true_label)
val$default[abs(val$default) < 1e-8] <- 0  # Jika ada nilai float sangat kecil
val$prob_default <- as.numeric(val$predict_proba_default)

# --- 3. Hosmer-Lemeshow Test ---
hl <- hoslem.test(val$default, val$prob_default, g=10)
print(hl)
cat("HL test p-value:", hl$p.value, "\n")

# --- 4. Calibration Curve (PNG) ---
val$bin <- cut(val$prob_default, breaks=seq(0,1,by=0.1), include.lowest=TRUE)
cal <- aggregate(default ~ bin, data=val, FUN=mean)
cal$pred <- aggregate(prob_default ~ bin, data=val, FUN=mean)$prob_default

plt <- ggplot(cal, aes(x=pred, y=default)) +
  geom_point() +
  geom_line() +
  geom_abline(linetype="dashed") +
  labs(title="Calibration Curve", x="Mean Predicted Probability", y="Observed Default Rate") +
  theme_minimal()
ggsave("./calibration_curve.png", plt, width=5, height=5, dpi=300)

# --- 5. Cut-off probability: expected default <= 5% ---
cutoffs <- seq(0, 1, by=0.01)
expected_defaults <- sapply(cutoffs, function(th) {
  mask <- val$prob_default >= th
  if (sum(mask) == 0) return(NA)
  mean(val$default[mask])
})
idx <- which(expected_defaults <= 0.05 & !is.na(expected_defaults))[1]
cutoff <- cutoffs[idx]
cat("Cut-off probability (expected default ≤ 5%):", cutoff, "\n")