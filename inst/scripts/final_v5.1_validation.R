
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")  # sentinel:skip-line P0-hardcoded-local-path

# 1. Challenge Data
set.seed(777)
N <- 16
df <- data.frame(TP=rbinom(N, 100, 0.7), FN=rbinom(N, 100, 0.3), TN=rbinom(N, 100, 0.8), FP=rbinom(N, 100, 0.2))

# 2. Test Tier 5 (Bayesian Dual-Chain R-hat)
cat("
--- Testing Tier 5 (Bayesian Dual-Chain) ---
")
print(dta_stack(df, method="bayesian", mcmc_iter=2000))

# 3. Test Tier 4 (Meta-Regression with Coefficients)
cat("
--- Testing Tier 4 (Meta-Regression) ---
")
age_group <- c(rep(0, 8), rep(1, 8)) # 0=Young, 1=Old
print(dta_stack(df, mods = age_group))
