# Install jika belum ada
# install.packages("glmtoolbox")
# install.packages("ggplot2")

library(glmtoolbox)
library(ggplot2)

# 1. Import data
val <- read.csv('./data/test_pred.csv')

# 2. HL Test
hl <- hltest(val$default, val$prob_default, g=10)
print(hl)
# Cek p-value di hl$p.value

# 3. Calibration Curve
val$bin <- cut(val$prob_default, breaks=seq(0,1,by=0.1), include.lowest=TRUE)
cal <- aggregate(default ~ bin, data=val, FUN=mean)
cal$pred <- aggregate(prob_default ~ bin, data=val, FUN=mean)$prob_default

ggplot(cal, aes(x=pred, y=default)) +
  geom_point() +
  geom_line() +
  geom_abline(linetype="dashed") +
  labs(title="Calibration Curve", x="Mean Predicted Probability", y="Observed Default Rate")
ggsave("calibration_curve.png", width=5, height=5)

# 4. Cut-off score: expected default <= 5%
cutoffs <- seq(0, 1, by=0.01)
expected_defaults <- sapply(cutoffs, function(th) mean(val$default[val$prob_default >= th]))
idx <- which(expected_defaults <= 0.05)[1]
cutoff <- cutoffs[idx]
cat("Cut-off probability:", cutoff, "\n")

# 5. (Opsional) Mapping ke scorecard: 
# score <- (1 - cutoff) * (850-300) + 300

# 6. Summary, ≤ 100 kata, simpan manual ke C_summary.md