
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")

# 1. Health Check
cat("
--- Checking System Health ---
")
if(exists(".dta_healthy") && .dta_healthy) cat("PASS: BLAS/LAPACK stable.
") else cat("FAIL: System unstable.
")

# 2. Challenge: High-Accuracy but Old Data (1995)
cat("
--- Testing v18.0: Ancient but Accurate Data ---
")
set.seed(123)
N <- 15
df_old <- data.frame(
  TP = rbinom(N, 100, 0.95), FN = rbinom(N, 100, 0.05),
  TN = rbinom(N, 100, 0.95), FP = rbinom(N, 100, 0.05),
  Year = rep(1995, N)
)
m_old <- dta_stack(df_old)
print(m_old)

# 3. Challenge: Moderate-Accuracy but Modern Data (2024)
cat("
--- Testing v18.0: Modern Data ---
")
df_new <- data.frame(
  TP = rbinom(N, 100, 0.85), FN = rbinom(N, 100, 0.15),
  TN = rbinom(N, 100, 0.85), FP = rbinom(N, 100, 0.15),
  Year = rep(2024, N)
)
m_new <- dta_stack(df_new)
print(m_new)

# 4. Posterior Archive Demo
cat("
--- Archiving Posterior (Simulation) ---
")
saveRDS(m_new$estimates, "C:/Users/user/OneDrive - NHS/Documents/DTA70/Posterior_Archive_Demo.rds")
cat("Posterior saved to Posterior_Archive_Demo.rds
")
