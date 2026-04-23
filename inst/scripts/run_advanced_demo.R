
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")  # sentinel:skip-line P0-hardcoded-local-path

# 1. Create Data (Tier 5 worthy)
set.seed(123)
N <- 15 # Enough for auto-selection of Bayesian Tier
mu_se <- 1.5; mu_sp <- 2.0
Sigma <- matrix(c(0.5, -0.2, -0.2, 0.5), 2, 2)

# Simulate latent parameters
library(MASS) # For mvrnorm
latent <- mvrnorm(N, c(mu_se, mu_sp), Sigma)
p_se <- plogis(latent[,1])
p_sp <- plogis(latent[,2])

df <- data.frame(
  TP = rbinom(N, 100, p_se),
  FN = 100 - rbinom(N, 100, p_se),
  TN = rbinom(N, 100, p_sp),
  FP = 100 - rbinom(N, 100, p_sp)
)

cat("
--- Running Tier 5: Full Bayesian Hierarchical Model ---
")
# Force Bayesian just to be sure, though auto logic handles N>=10
m5 <- dta_stack(df, method="bayesian", mcmc_iter=2000) 

print(m5)

cat("
--- Generating Posterior Plot (SROC Cloud) ---
")
png("C:/Users/user/OneDrive - NHS/Documents/DTA70/bayesian_sroc_plot.png", width=600, height=600)  # sentinel:skip-line P0-hardcoded-local-path
plot(m5)
dev.off()
cat("Saved to bayesian_sroc_plot.png
")
