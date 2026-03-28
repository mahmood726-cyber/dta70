
# Test script for DTA-Stack
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")

# Load mada for sample datasets if needed, or create dummy
# We know the column names are TP, FP, FN, TN

test_method <- function(name, data) {
  cat("
--- Testing Dataset:", name, "---
")
  cat("N studies:", nrow(data), "
")
  results <- dta_stack(data)
  cat("Strategy used:", results$strategy, "
")
  cat("Pooled Sensitivity:", round(results$pooled_sens, 3), 
      "(95% CI:", round(results$pooled_sens_ci_lb, 3), "-", round(results$pooled_sens_ci_ub, 3), ")
")
  cat("Pooled Specificity:", round(results$pooled_spec, 3), 
      "(95% CI:", round(results$pooled_spec_ci_lb, 3), "-", round(results$pooled_spec_ci_ub, 3), ")
")
}

# Example 1: Sparse small data
data_sparse <- data.frame(
  TP = c(2, 0, 1),
  FP = c(0, 1, 0),
  FN = c(1, 2, 0),
  TN = c(5, 4, 6)
)
test_method("Sparse Small", data_sparse)

# Example 2: Larger data (using AuditC from mada if possible, or simulate)
# Simulating a larger dataset
set.seed(123)
n <- 20
data_large <- data.frame(
  TP = rbinom(n, 100, 0.8),
  FN = rbinom(n, 100, 0.2),
  FP = rbinom(n, 100, 0.1),
  TN = rbinom(n, 100, 0.9)
)
test_method("Large Simulated", data_large)
