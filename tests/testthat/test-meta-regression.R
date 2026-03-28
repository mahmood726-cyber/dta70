library(testthat)
library(DTA70)

context("DTA-Stack Meta-Regression Enhancements")

test_that("run_regression_glmm handles covariates properly", {
  data_test <- data.frame(
    TP = c(45, 38, 52, 40, 50),
    FN = c(5, 7, 3, 10, 2),
    FP = c(10, 12, 8, 15, 5),
    TN = c(90, 88, 92, 85, 95),
    Year = c(2015, 2018, 2022, 2010, 2023)
  )
  mods <- data.frame(Year = data_test$Year)
  
  # Note: Need to use internal functions directly if dta_stack isn't exporting mods yet
  fit <- DTA70:::run_regression_glmm(data_test, mods)
  
  expect_true(!is.null(fit$estimates$beta_sens))
  expect_true(length(fit$estimates$beta_sens) == 2) # Intercept + Year
  expect_true(!is.null(fit$estimates$tau2_sens))
})

test_that("select_dta_strategy chooses tier4_regression when mods provided", {
  data_test <- data.frame(TP=1, FN=1, FP=1, TN=1)
  mods <- data.frame(Mod=1)
  expect_equal(DTA70:::select_dta_strategy(data_test, mods, "auto"), "tier4_regression")
})
