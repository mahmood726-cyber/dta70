
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")  # sentinel:skip-line P0-hardcoded-local-path

# 1. Challenge Data - Small & Fragile
cat("
--- Testing v6.0: Fragile Scenario (Small Sample) ---
")
set.seed(1)
df_small <- data.frame(TP=c(5,2), FN=c(1,0), TN=c(10,8), FP=c(2,1))
m_small <- dta_stack(df_small)
print(m_small)

# 2. Challenge Data - Robust & Immutable
cat("
--- Testing v6.0: Immutable Truth Scenario (Large N) ---
")
set.seed(42)
N <- 20
df_large <- data.frame(
  TP = rbinom(N, 200, 0.95),
  FN = rbinom(N, 200, 0.05),
  TN = rbinom(N, 200, 0.95),
  FP = rbinom(N, 200, 0.05)
)
m_large <- dta_stack(df_large)
print(m_large)

# 3. Save Evidence Plot
png("C:/Users/user/OneDrive - NHS/Documents/DTA70/unified_v6_evidence.png", width=800, height=400)  # sentinel:skip-line P0-hardcoded-local-path
par(mfrow=c(1,2))
plot(m_small)
plot(m_large)
dev.off()
cat("Saved unified evidence plots to unified_v6_evidence.png
")
