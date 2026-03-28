library(testthat)
library(DTA70)

context("DTA-Stack Oracle Enhancements")

# Sample data
data_test <- data.frame(
  TP = c(45, 38, 52),
  FN = c(5, 7, 3),
  FP = c(10, 12, 8),
  TN = c(90, 88, 92),
  Year = c(2015, 2018, 2022)
)

test_that("Refactored API works (renaming)", {
  # Test if dta_stack still runs with the new internal function names
  expect_silent(fit <- dta_stack(data_test, method = "frequentist"))
  expect_s3_class(fit, "dta_stack")
  expect_equal(fit$diagnostics$averaged, FALSE)
})

test_that("MCMC convergence diagnostics work", {
  # Small iterations to keep it fast
  fit <- dta_stack(data_test, method = "bayesian", mcmc_iter = 500)
  
  expect_true("mcmc_diag" %in% names(fit$diagnostics))
  expect_true(fit$diagnostics$mcmc_diag$rhat_sens > 0)
  expect_type(fit$diagnostics$mcmc_diag$converged, "logical")
})

test_that("Clinical Utility costs are applied", {
  # Default
  u1 <- calculate_aunbc_utility(list(sens=c(0.9,0.8,0.95), spec=c(0.9,0.8,0.95)), cost_fp=1, cost_fn=9)
  
  # Higher cost of False Positives
  u2 <- calculate_aunbc_utility(list(sens=c(0.9,0.8,0.95), spec=c(0.9,0.8,0.95)), cost_fp=10, cost_fn=1)
  
  expect_false(u1$score == u2$score)
})

test_that("TruthCert report generation works", {
  fit <- dta_stack(data_test, method = "frequentist")
  report_file <- "test_audit.html"
  
  expect_message(create_dta_report(fit, filename = report_file), "TruthCert report saved to")
  expect_true(file.exists(report_file))
  
  if (file.exists(report_file)) file.remove(report_file)
})

test_that("LOO influential analysis works", {
  data_loo <- data.frame(
    TP = c(45, 38, 52, 100), # 100 is an outlier
    FN = c(5, 7, 3, 1),
    FP = c(10, 12, 8, 2),
    TN = c(90, 88, 92, 150),
    Year = c(2015, 2018, 2022, 2023)
  )
  
  fit <- dta_stack(data_loo, method = "frequentist", loo = TRUE)
  
  expect_true(!is.null(fit$diagnostics$loo_analysis))
  expect_true("matrix" %in% names(fit$diagnostics$loo_analysis))
  # Should identify at least one influential study if threshold crossed
  expect_type(fit$diagnostics$loo_analysis$influential_studies, "integer")
})

test_that("Robust Huber-weighted method works", {
  data_robust <- data.frame(
    TP = c(45, 38, 52, 99), 
    FN = c(5, 7, 3, 1),
    FP = c(10, 12, 8, 2),
    TN = c(90, 88, 92, 150)
  )
  fit <- dta_stack(data_robust, method = "robust")
  expect_s3_class(fit, "dta_stack")
  expect_true(!is.null(fit$diagnostics$robust_weights))
  expect_equal(length(fit$diagnostics$robust_weights$sens), 4)
})

test_that("Latent Subgroup Mixture method works", {
  # Need >= 10 rows for mixture to not fallback to GLMM
  data_mix <- data.frame(
    TP = c(rep(45, 5), rep(10, 5)), 
    FN = c(rep(5, 5), rep(40, 5)),
    FP = c(rep(10, 5), rep(30, 5)),
    TN = c(rep(90, 5), rep(70, 5))
  )
  fit <- dta_stack(data_mix, method = "mixture")
  expect_s3_class(fit, "dta_stack")
  expect_true(!is.null(fit$diagnostics$subgroups))
  expect_true(!is.null(fit$diagnostics$subgroups$primary))
  
  # Test summary with personas
  expect_output(summary(fit), "MULTI-PERSONA RESEARCH SYNTHESIS REVIEW")
  expect_output(summary(fit), "\\[Strict Methodologist\\]")
  
  # Test subgroups plot
  expect_silent(plot(fit, type = "subgroups"))
})

test_that("Pseudo-IPD Reconstruction works", {
  data_ipd <- data.frame(TP=10, FN=5, FP=5, TN=20)
  fit <- dta_stack(data_ipd, method = "ipd")
  expect_s3_class(fit, "dta_stack")
  expect_true(!is.null(fit$diagnostics$pseudo_ipd))
  # Total rows in IPD should equal total sum of cells
  expect_equal(nrow(fit$diagnostics$pseudo_ipd), 40)
  expect_equal(sum(fit$diagnostics$pseudo_ipd$Test == 1 & fit$diagnostics$pseudo_ipd$Disease == 1), 10)
})

test_that("ML Bootstrapped Ensemble works", {
  data_ens <- data.frame(TP=c(10, 15), FN=c(5, 2), FP=c(5, 8), TN=c(20, 25))
  fit <- dta_stack(data_ens, method = "ensemble", boot_n = 50) # Small boot_n for speed
  expect_s3_class(fit, "dta_stack")
  expect_true(!is.null(fit$diagnostics$ensemble_dist))
  expect_equal(length(fit$diagnostics$ensemble_dist$sens), 50)
  expect_silent(plot(fit, type = "ensemble"))
})
