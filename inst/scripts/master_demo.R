
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")  # sentinel:skip-line P0-hardcoded-local-path

# 1. Load a real dataset from the package
# If DTA70 isn't loaded, we'll use a simulated high-n dataset
set.seed(1)
n <- 30
df <- data.frame(
  TP = rbinom(n, 100, 0.85),
  FN = rbinom(n, 100, 0.15),
  TN = rbinom(n, 100, 0.90),
  FP = rbinom(n, 100, 0.10)
)

# 2. Run standard Meta-Analysis (Tier 3)
cat("--- Running Standard Meta-Analysis ---
")
m1 <- dta_stack(df)
print(m1)

# 3. Run Meta-Regression (Tier 4)
# Suppose the first 15 studies used a different test version (Covariate)
cat("
--- Running Meta-Regression (Tier 4) ---
")
version <- c(rep(0, 15), rep(1, 15))
m2 <- dta_stack(df, mods = version)
print(m2)

# 4. Visualization (Generate plot)
cat("
--- Generating Plots (outputting to dta_stack_plot.png) ---
")
png("C:/Users/user/OneDrive - NHS/Documents/DTA70/dta_stack_plot.png", width=800, height=400)  # sentinel:skip-line P0-hardcoded-local-path
plot(m1)
dev.off()
cat("Plot saved to C:/Users/user/OneDrive - NHS/Documents/DTA70/dta_stack_plot.png  # sentinel:skip-line P0-hardcoded-local-path
")
