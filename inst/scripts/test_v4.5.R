
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")
set.seed(42)
df <- data.frame(TP=rbinom(12, 100, 0.8), FN=rbinom(12, 100, 0.2), TN=rbinom(12, 100, 0.9), FP=rbinom(12, 100, 0.1))

cat("
--- Testing v4.5: Bayesian Mode ---
")
print(dta_stack(df, method="bayesian", mcmc_iter=1000))

cat("
--- Testing v4.5: Auto Mode (Tier 2) ---
")
print(dta_stack(df))
