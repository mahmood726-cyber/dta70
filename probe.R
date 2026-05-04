# Baseline probe for DTA70 (DTA-Stack diagnostic test accuracy package).
#
# Deterministic dta_stack() fit on a fixed 3-study TP/FN/FP/TN dataset
# (frequentist method only — Bayesian uses MCMC which can drift).
#
# Run: Rscript probe.R

suppressPackageStartupMessages({
  if (!"DTA70" %in% loadedNamespaces()) {
    pkgload::load_all(rprojroot::find_package_root_file(), quiet = TRUE)
  }
})

# Same fixture as tests/testthat/test-dta-oracle.R
data_test <- data.frame(
  TP = c(45, 38, 52),
  FN = c(5,  7,  3),
  FP = c(10, 12, 8),
  TN = c(90, 88, 92),
  Year = c(2015, 2018, 2022)
)

fit <- dta_stack(data_test, method = "frequentist")

# Stable 2x2-derived signals (deterministic — no randomness)
total_TP <- sum(data_test$TP)
total_FN <- sum(data_test$FN)
total_FP <- sum(data_test$FP)
total_TN <- sum(data_test$TN)
n_studies <- nrow(data_test)
sens_pooled <- total_TP / (total_TP + total_FN)
spec_pooled <- total_TN / (total_TN + total_FP)

out <- list(
  n_studies = n_studies,
  total_TP = total_TP,
  total_FN = total_FN,
  total_FP = total_FP,
  total_TN = total_TN,
  sens_pooled = round(sens_pooled, 6),
  spec_pooled = round(spec_pooled, 6),
  fit_class = class(fit)[1],
  averaged = isTRUE(fit$diagnostics$averaged)
)

cat(jsonlite::toJSON(out, auto_unbox = TRUE, digits = 6))
cat("\n")
