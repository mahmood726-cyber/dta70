
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")

# Create a challenging "Tier 3" dataset with a strong threshold effect
# (Sensitivity and Specificity are negatively correlated)
set.seed(99)
n <- 25
# Threshold effect: as sens goes up, spec goes down
theta <- seq(-1, 2, length.out = n)
l_se <- 1 + theta + rnorm(n, 0, 0.2)
l_sp <- 1 - theta + rnorm(n, 0, 0.2)

challenging_data <- data.frame(
  TP = rbinom(n, 100, plogis(l_se)),
  FN = 100 - rbinom(n, 100, plogis(l_se)),
  TN = rbinom(n, 100, plogis(l_sp)),
  FP = 100 - rbinom(n, 100, plogis(l_sp))
)

cat("
--- Testing Full DTA-Stack Model ---
")
results <- dta_stack(challenging_data)
print(results)

# Verify diagnostics
if (results$tier == "Tier 3: SROC-Informed Ensemble") {
  cat("SUCCESS: Correctly identified Tier 3 scenario.
")
} else {
  cat("NOTE: Model selected", results$tier, "
")
}
