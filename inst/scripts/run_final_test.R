
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")

# 1. Create Challenge Data (High Heterogeneity)
set.seed(999)
N <- 12
df <- data.frame(
  TP = rbinom(N, 50, 0.7),
  FN = 50 - rbinom(N, 50, 0.7),
  TN = rbinom(N, 50, 0.9),
  FP = 50 - rbinom(N, 50, 0.9)
)

# 2. Test Tier 5 (Bayesian Dual-Chain)
cat("
--- Running Tier 5: Robust Bayesian (Dual Chain) ---
")
m5 <- dta_stack(df, method="bayesian", mcmc_iter=2000)
print(m5)

# 3. Test Tier 3 (Bootstrap Ensemble)
cat("
--- Running Tier 3: Bootstrap Ensemble ---
")
m3 <- dta_stack(df, method="ensemble", boot_n=200)
print(m3)

# 4. Generate Diagnostics Plot
png("C:/Users/user/OneDrive - NHS/Documents/DTA70/dta_v4_diagnostics.png", width=800, height=400)
par(mfrow=c(1,2))
plot(m5) # Bayesian Trace + Cloud
# plot(m3) # Bootstrap Cloud (Skipped to keep 1x2 layout clean)
dev.off()
cat("Saved diagnostics to dta_v4_diagnostics.png
")
