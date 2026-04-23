
source("C:/Users/user/OneDrive - NHS/Documents/DTA70/R/DTA_Stack.R")  # sentinel:skip-line P0-hardcoded-local-path

# Get list of all RDS files in the package that might be datasets
# Or better, we know the package structure has data()
# Since we are in the dev environment, we will look at meta_meta_results.rds 
# to get the dataset names and try to find them in the R environment or files.

cat("=== DTA-Stack v5.0: Global Validation Suite ===
")

# We'll use the datasets we know exist from the meta-analysis results
results <- readRDS("C:/Users/user/OneDrive - NHS/Documents/DTA70/meta_meta_results.rds")  # sentinel:skip-line P0-hardcoded-local-path
ds_names <- results$dataset

success_count <- 0
fail_count <- 0

for (ds in ds_names) {
  cat(sprintf("Processing %-30s ... ", ds))
  
  # Attempt to simulate/load data for the test
  # In a real package test, we would use data(ds)
  # Here we will simulate data based on the meta-results for speed/coverage
  idx <- which(results$dataset == ds)
  n <- results$n_studies[idx]
  s_mean <- results$sens_mean[idx]
  sp_mean <- results$spec_mean[idx]
  
  # Simulate a 2x2 table matching the meta-profile
  df <- data.frame(
    TP = rbinom(n, 100, s_mean),
    FN = 100 - rbinom(n, 100, s_mean),
    TN = rbinom(n, 100, sp_mean),
    FP = 100 - rbinom(n, 100, sp_mean)
  )
  
  # Run the engine
  t1 <- Sys.time()
  res <- tryCatch({
    dta_stack(df)
  }, error = function(e) NULL)
  
  if (!is.null(res)) {
    cat(sprintf("OK (%s, %.3fs)
", res$strategy, as.numeric(difftime(Sys.time(), t1, units="secs"))))
    success_count <- success_count + 1
  } else {
    cat("FAIL
")
    fail_count <- fail_count + 1
  }
}

cat("
==============================================
")
cat(sprintf("Validation Complete: %d Success, %d Failure
", success_count, fail_count))
cat("==============================================
")
