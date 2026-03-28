# ============================================================================
# method_wrappers.R - Standardized Interface Functions for DTA Meta-Analysis Methods
# ============================================================================
#
# This file provides wrapper functions that create consistent input/output formats
# across all 12+ different DTA meta-analysis methods from various R packages.
#
# Each wrapper function:
# - Takes standardized input (data frame with TP, FP, FN, TN columns)
# - Returns a list with consistent output format
# - Handles errors gracefully and returns diagnostic information
# - Records computational performance metrics
#
# ============================================================================

# -----------------------------------------------------------------------------
# Standard Output Format Definition
# -----------------------------------------------------------------------------

#' @title Standard Output Format for Method Wrappers
#' @description All wrapper functions return a list with this structure:
#' @return List containing:
#'   \itemize{
#'     \item method: Character string with method name
#'     \item converged: Logical indicating if method converged
#'     \item pooled_sens: Numeric - pooled sensitivity estimate
#'     \item pooled_sens_se: Numeric - standard error of sensitivity
#'     \item pooled_sens_ci_lb: Numeric - lower bound of 95% CI for sensitivity
#'     \item pooled_sens_ci_ub: Numeric - upper bound of 95% CI for sensitivity
#'     \item pooled_spec: Numeric - pooled specificity estimate
#'     \item pooled_spec_se: Numeric - standard error of specificity
#'     \item pooled_spec_ci_lb: Numeric - lower bound of 95% CI for specificity
#'     \item pooled_spec_ci_ub: Numeric - upper bound of 95% CI for specificity
#'     \item pooled_dor: Numeric - pooled diagnostic odds ratio
#'     \item pooled_dor_se: Numeric - standard error of log(DOR)
#'     \item pooled_dor_ci_lb: Numeric - lower bound of 95% CI for DOR
#'     \item pooled_dor_ci_ub: Numeric - upper bound of 95% CI for DOR
#'     \item tau2_sens: Numeric - between-study variance for sensitivity (if applicable)
#'     \item tau2_spec: Numeric - between-study variance for specificity (if applicable)
#'     \item cov_sens_spec: Numeric - covariance between sens and spec (if applicable)
#'     \item i2_sens: Numeric - I-squared for sensitivity
#'     \item i2_spec: Numeric - I-squared for specificity
#'     \item q_stat: Numeric - Q-statistic
#'     \item q_pval: Numeric - p-value for Q-statistic
#'     \item aic: Numeric - Akaike Information Criterion (if applicable)
#'     \item bic: Numeric - Bayesian Information Criterion (if applicable)
#'     \item iterations: Integer - number of iterations
#'     \item runtime_seconds: Numeric - computation time
#'     \item warning: Character string (any warnings)
#'     \item error_message: Character string (if error occurred)
#'   }

# -----------------------------------------------------------------------------
# Data Validation Helper
# -----------------------------------------------------------------------------

#' Validate DTA Input Data
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @return Logical; TRUE if valid, stops with error if invalid
validate_dta_data <- function(data) {
  required_cols <- c("TP", "FP", "FN", "TN")
  if (!all(required_cols %in% names(data))) {
    stop("Data must contain TP, FP, FN, TN columns")
  }

  # Check for negative values
  if (any(data[, required_cols] < 0, na.rm = TRUE)) {
    stop("Cell counts cannot be negative")
  }

  # Check for non-numeric types
  if (!all(sapply(data[, required_cols], is.numeric))) {
    stop("Cell counts must be numeric")
  }

  return(TRUE)
}

# -----------------------------------------------------------------------------
# MADA Package Wrappers
# -----------------------------------------------------------------------------

#' Wrapper for mada::reitsma() - Bivariate Model
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param correction Continuity correction for zero cells (default: 0.5)
#' @return List with standard output format
wrapper_reitsma <- function(data, correction = 0.5) {
  start_time <- Sys.time()

  result <- list(
    method = "reitsma_bivariate",
    converged = NA,
    pooled_sens = NA,
    pooled_sens_se = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec = NA,
    pooled_spec_se = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    pooled_dor = NA,
    pooled_dor_se = NA,
    pooled_dor_ci_lb = NA,
    pooled_dor_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    cov_sens_spec = NA,
    i2_sens = NA,
    i2_spec = NA,
    q_stat = NA,
    q_pval = NA,
    aic = NA,
    bic = NA,
    iterations = NA,
    runtime_seconds = NA,
    warning = NA,
    error_message = NA
  )

  tryCatch({
    # Apply continuity correction if needed
    data_corr <- data
    zero_cells <- (data$TP == 0) | (data$FP == 0) | (data$FN == 0) | (data$TN == 0)
    if (any(zero_cells) && correction > 0) {
      data_corr[, c("TP", "FP", "FN", "TN")] <-
        data_corr[, c("TP", "FP", "FN", "TN")] + correction
    }

    # Run reitsma method
    fit <- mada::reitsma(data_corr)

    # Extract results
    result$converged <- !is.null(fit) && !any(is.na(fit$coef))

    if (result$converged) {
      # Sensitivity
      result$pooled_sens <- plogis(fit$coef[1])
      result$pooled_sens_se <- sqrt(fit$vcov[1, 1])
      sens_ci <- plogis(fit$coef[1] + c(-1, 1) * 1.96 * sqrt(fit$vcov[1, 1]))
      result$pooled_sens_ci_lb <- sens_ci[1]
      result$pooled_sens_ci_ub <- sens_ci[2]

      # Specificity
      result$pooled_spec <- plogis(fit$coef[2])
      result$pooled_spec_se <- sqrt(fit$vcov[2, 2])
      spec_ci <- plogis(fit$coef[2] + c(-1, 1) * 1.96 * sqrt(fit$vcov[2, 2]))
      result$pooled_spec_ci_lb <- spec_ci[1]
      result$pooled_spec_ci_ub <- spec_ci[2]

      # DOR = exp(Se_coef + Sp_coef) on logit scale
      log_dor <- fit$coef[1] + fit$coef[2]
      result$pooled_dor <- exp(log_dor)
      result$pooled_dor_se <- sqrt(sum(fit$vcov[1:2, 1:2]))
      dor_ci <- exp(log_dor + c(-1, 1) * 1.96 * result$pooled_dor_se)
      result$pooled_dor_ci_lb <- dor_ci[1]
      result$pooled_dor_ci_ub <- dor_ci[2]

      # Random effects variances
      result$tau2_sens <- fit$theta[1]
      result$tau2_spec <- fit$theta[2]
      result$cov_sens_spec <- fit$theta[3]

      # I-squared (approximate)
      n <- nrow(data)
      result$i2_sens <- max(0, 100 * (result$tau2_sens / (result$tau2_sens + pi^2/3)))
      result$i2_spec <- max(0, 100 * (result$tau2_spec / (result$tau2_spec + pi^2/3)))

      # Q-statistic (if available)
      if (!is.null(fit$Q)) {
        result$q_stat <- fit$Q
        result$q_pval <- 1 - pchisq(result$q_stat, n - 2)
      }
    }

    # Get warnings
    result$warning <- paste(if_any(any(zero_cells) && correction > 0,
                                   paste0("Continuity correction (", correction, ") applied"), ""),
                           collapse = "; ")

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  }, warning = function(w) {
    result$warning <- paste(result$warning, w$message, sep = "; ")
  })

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  return(result)
}

#' Wrapper for mada::MosesL() - Moses-Littenberg Model
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param weighted Use weighted version (default: TRUE)
#' @param correction Continuity correction for zero cells
#' @return List with standard output format
wrapper_mosesl <- function(data, weighted = TRUE, correction = 0.5) {
  start_time <- Sys.time()

  result <- list(
    method = ifelse(weighted, "MosesL_weighted", "MosesL_unweighted"),
    converged = NA,
    pooled_sens = NA,
    pooled_sens_se = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec = NA,
    pooled_spec_se = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    pooled_dor = NA,
    pooled_dor_se = NA,
    pooled_dor_ci_lb = NA,
    pooled_dor_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    cov_sens_spec = NA,
    i2_sens = NA,
    i2_spec = NA,
    q_stat = NA,
    q_pval = NA,
    aic = NA,
    bic = NA,
    iterations = NA,
    runtime_seconds = NA,
    warning = NA,
    error_message = NA
  )

  tryCatch({
    # Apply continuity correction
    data_corr <- data
    zero_cells <- (data$TP == 0) | (data$FP == 0) | (data$FN == 0) | (data$TN == 0)
    if (any(zero_cells) && correction > 0) {
      data_corr[, c("TP", "FP", "FN", "TN")] <-
        data_corr[, c("TP", "FP", "FN", "TN")] + correction
    }

    # Run Moses-Littenberg
    fit <- mada::MosesL(data_corr, correction = FALSE, weighted = weighted)

    result$converged <- !is.null(fit)

    if (result$converged && !is.null(fit$SROC)) {
      # Extract SROC curve parameters
      # MosesL returns SROC parameters: intercept (a) and slope (b)
      # DOR at point where sens + spec = 1 (negative诊断 odds ratio)
      a <- fit$coef[1]  # intercept
      b <- fit$coef[2]  # slope

      # Calculate DOR at operating point
      result$pooled_dor <- exp(-a / b)

      # Get CI for DOR from SROC fit
      if (!is.null(fit$ci)) {
        result$pooled_dor_ci_lb <- exp(fit$ci[1])
        result$pooled_dor_ci_ub <- exp(fit$ci[2])
      }

      # Note: MosesL doesn't directly provide pooled sens/spec
      # We can approximate at the optimal operating point
      result$pooled_sens <- NA  # Requires SROC curve calculation
      result$pooled_spec <- NA
    }

    result$warning <- ifelse(any(zero_cells) && correction > 0,
                            paste0("Continuity correction (", correction, ") applied"), "")

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  }, warning = function(w) {
    result$warning <- paste(result$warning, w$message, sep = "; ")
  })

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  return(result)
}

#' Wrapper for mada::marginal() - Marginal Pooling
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param correction Continuity correction
#' @return List with standard output format
wrapper_marginal <- function(data, correction = 0.5) {
  start_time <- Sys.time()

  result <- list(
    method = "marginal_pooling",
    converged = NA,
    pooled_sens = NA,
    pooled_sens_se = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec = NA,
    pooled_spec_se = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    pooled_dor = NA,
    pooled_dor_se = NA,
    pooled_dor_ci_lb = NA,
    pooled_dor_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    cov_sens_spec = NA,
    i2_sens = NA,
    i2_spec = NA,
    q_stat = NA,
    q_pval = NA,
    aic = NA,
    bic = NA,
    iterations = NA,
    runtime_seconds = NA,
    warning = NA,
    error_message = NA
  )

  tryCatch({
    data_corr <- data
    zero_cells <- (data$TP == 0) | (data$FP == 0) | (data$FN == 0) | (data$TN == 0)
    if (any(zero_cells) && correction > 0) {
      data_corr[, c("TP", "FP", "FN", "TN")] <-
        data_corr[, c("TP", "FP", "FN", "TN")] + correction
    }

    # Calculate marginal pooled estimates
    total_TP <- sum(data_corr$TP)
    total_FN <- sum(data_corr$FN)
    total_TN <- sum(data_corr$TN)
    total_FP <- sum(data_corr$FP)

    # Pooled sensitivity
    result$pooled_sens <- total_TP / (total_TP + total_FN)
    se_sens <- sqrt((result$pooled_sens * (1 - result$pooled_sens)) /
                    (total_TP + total_FN))
    result$pooled_sens_se <- se_sens
    result$pooled_sens_ci_lb <- max(0, result$pooled_sens - 1.96 * se_sens)
    result$pooled_sens_ci_ub <- min(1, result$pooled_sens + 1.96 * se_sens)

    # Pooled specificity
    result$pooled_spec <- total_TN / (total_TN + total_FP)
    se_spec <- sqrt((result$pooled_spec * (1 - result$pooled_spec)) /
                    (total_TN + total_FP))
    result$pooled_spec_se <- se_spec
    result$pooled_spec_ci_lb <- max(0, result$pooled_spec - 1.96 * se_spec)
    result$pooled_spec_ci_ub <- min(1, result$pooled_spec + 1.96 * se_spec)

    # DOR
    result$pooled_dor <- (total_TP * total_TN) / (total_FP * total_FN)
    log_dor <- log(result$pooled_dor)
    se_log_dor <- sqrt(1/total_TP + 1/total_TN + 1/total_FP + 1/total_FN)
    result$pooled_dor_se <- se_log_dor
    result$pooled_dor_ci_lb <- exp(log_dor - 1.96 * se_log_dor)
    result$pooled_dor_ci_ub <- exp(log_dor + 1.96 * se_log_dor)

    result$converged <- TRUE

    # Cochran's Q for heterogeneity
    n <- nrow(data)
    w_sens <- (data$TP + data$FN)
    w_spec <- (data$TN + data$FP)

    sens_i <- data$TP / (data$TP + data$FN)
    spec_i <- data$TN / (data$TN + data$FP)

    # Q for sensitivity
    result$q_stat <- sum(w_sens * (sens_i - result$pooled_sens)^2) /
                     (result$pooled_sens * (1 - result$pooled_sens))
    result$q_pval <- 1 - pchisq(result$q_stat, n - 1)

    # I-squared
    result$i2_sens <- max(0, 100 * ((result$q_stat - (n - 1)) / result$q_stat))
    result$i2_spec <- result$i2_sens  # Same for marginal pooling

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  }, warning = function(w) {
    result$warning <- w$message
  })

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  return(result)
}

# -----------------------------------------------------------------------------
# DIAGMETA Package Wrapper
# -----------------------------------------------------------------------------

#' Wrapper for diagmeta::diagmeta() - Multiple Thresholds
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param threshold Optional threshold values if available
#' @param correction Continuity correction
#' @return List with standard output format
wrapper_diagmeta <- function(data, threshold = NULL, correction = 0.5) {
  start_time <- Sys.time()

  result <- list(
    method = "diagmeta",
    converged = NA,
    pooled_sens = NA,
    pooled_sens_se = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec = NA,
    pooled_spec_se = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    pooled_dor = NA,
    pooled_dor_se = NA,
    pooled_dor_ci_lb = NA,
    pooled_dor_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    cov_sens_spec = NA,
    i2_sens = NA,
    i2_spec = NA,
    q_stat = NA,
    q_pval = NA,
    aic = NA,
    bic = NA,
    iterations = NA,
    runtime_seconds = NA,
    warning = NA,
    error_message = NA
  )

  tryCatch({
    # diagmeta requires threshold column
    if (is.null(threshold)) {
      # Create pseudo-thresholds if not available
      data$threshold <- 1:nrow(data)
      result$warning <- "No thresholds provided, using study indices as pseudo-thresholds"
    } else {
      data$threshold <- threshold
    }

    # diagmeta needs data in specific format
    data_corr <- data
    zero_cells <- (data$TP == 0) | (data$FP == 0) | (data$FN == 0) | (data$TN == 0)
    if (any(zero_cells) && correction > 0) {
      data_corr[, c("TP", "FP", "FN", "TN")] <-
        data_corr[, c("TP", "FP", "FN", "TN")] + correction
    }

    # Run diagmeta
    fit <- diagmeta::diagmeta(TP, TN, FP, FN,
                               threshold = threshold,
                               data = data_corr,
                               n.chains = 2, n.iter = 2000)

    result$converged <- !is.null(fit)

    if (result$converged) {
      # Extract summary estimates
      summary_fit <- summary(fit)

      # Get estimates at optimal threshold or mean threshold
      if (!is.null(summary_fit$sensitivity)) {
        result$pooled_sens <- summary_fit$sensitivity
      }
      if (!is.null(summary_fit$specificity)) {
        result$pooled_spec <- summary_fit$specificity
      }

      # CIs
      if (!is.null(summary_fit$sensitivity.lower)) {
        result$pooled_sens_ci_lb <- summary_fit$sensitivity.lower
        result$pooled_sens_ci_ub <- summary_fit$sensitivity.upper
      }
      if (!is.null(summary_fit$specificity.lower)) {
        result$pooled_spec_ci_lb <- summary_fit$specificity.lower
        result$pooled_spec_ci_ub <- summary_fit$specificity.upper
      }
    }

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  }, warning = function(w) {
    result$warning <- paste(result$warning, w$message, sep = "; ")
  })

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  return(result)
}

# -----------------------------------------------------------------------------
# METADTA Package Wrapper
# -----------------------------------------------------------------------------

#' Wrapper for metadta Package
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param method Method to use ("bivariate", "hsroc", "regression")
#' @param correction Continuity correction
#' @return List with standard output format
wrapper_metadta <- function(data, method = "bivariate", correction = 0.5) {
  start_time <- Sys.time()

  result <- list(
    method = paste0("metadta_", method),
    converged = NA,
    pooled_sens = NA,
    pooled_sens_se = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec = NA,
    pooled_spec_se = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    pooled_dor = NA,
    pooled_dor_se = NA,
    pooled_dor_ci_lb = NA,
    pooled_dor_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    cov_sens_spec = NA,
    i2_sens = NA,
    i2_spec = NA,
    q_stat = NA,
    q_pval = NA,
    aic = NA,
    bic = NA,
    iterations = NA,
    runtime_seconds = NA,
    warning = NA,
    error_message = NA
  )

  tryCatch({
    data_corr <- data
    zero_cells <- (data$TP == 0) | (data$FP == 0) | (data$FN == 0) | (data$TN == 0)
    if (any(zero_cells) && correction > 0) {
      data_corr[, c("TP", "FP", "FN", "TN")] <-
        data_corr[, c("TP", "FP", "FN", "TN")] + correction
    }

    # metadta::dta_pooled
    fit <- metadta::dta_pooled(
      TP = data_corr$TP,
      FP = data_corr$FP,
      FN = data_corr$FN,
      TN = data_corr$TN,
      method = method
    )

    result$converged <- !is.null(fit)

    if (result$converged) {
      # Extract pooled estimates
      result$pooled_sens <- fit$sensitivity
      result$pooled_spec <- fit$specificity
      result$pooled_sens_ci_lb <- fit$sensitivity_lower
      result$pooled_sens_ci_ub <- fit$sensitivity_upper
      result$pooled_spec_ci_lb <- fit$specificity_lower
      result$pooled_spec_ci_ub <- fit$specificity_upper

      if (!is.null(fit$dor)) {
        result$pooled_dor <- fit$dor
        result$pooled_dor_ci_lb <- fit$dor_lower
        result$pooled_dor_ci_ub <- fit$dor_upper
      }

      # Heterogeneity
      if (!is.null(fit$I2)) {
        result$i2_sens <- fit$I2
        result$i2_spec <- fit$I2
      }
    }

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  }, warning = function(w) {
    result$warning <- w$message
  })

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  return(result)
}

# -----------------------------------------------------------------------------
# META Package Wrapper
# -----------------------------------------------------------------------------

#' Wrapper for meta Package (metaprop, metabin)
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param sm Summary measure (PLOGIT, PLN, etc.)
#' @param correction Continuity correction
#' @return List with standard output format
wrapper_meta <- function(data, sm = "PLOGIT", correction = 0.5) {
  start_time <- Sys.time()

  result <- list(
    method = paste0("meta_", sm),
    converged = NA,
    pooled_sens = NA,
    pooled_sens_se = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec = NA,
    pooled_spec_se = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    pooled_dor = NA,
    pooled_dor_se = NA,
    pooled_dor_ci_lb = NA,
    pooled_dor_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    cov_sens_spec = NA,
    i2_sens = NA,
    i2_spec = NA,
    q_stat = NA,
    q_pval = NA,
    aic = NA,
    bic = NA,
    iterations = NA,
    runtime_seconds = NA,
    warning = NA,
    error_message = NA
  )

  tryCatch({
    data_corr <- data
    zero_cells <- (data$TP == 0) | (data$FP == 0) | (data$FN == 0) | (data$TN == 0)
    if (any(zero_cells) && correction > 0) {
      data_corr[, c("TP", "FP", "FN", "TN")] <-
        data_corr[, c("TP", "FP", "FN", "TN")] + correction
    }

    # Sensitivity using metaprop
    n1 <- data_corr$TP + data_corr$FN
    events1 <- data_corr$TP
    sens_fit <- meta::metaprop(events1, n1, sm = sm, method.tau = "DL")

    # Specificity using metaprop
    n2 <- data_corr$TN + data_corr$FP
    events2 <- data_corr$TN
    spec_fit <- meta::metaprop(events2, n2, sm = sm, method.tau = "DL")

    result$converged <- !is.null(sens_fit) && !is.null(spec_fit)

    if (result$converged) {
      # Extract sensitivity
      result$pooled_sens <- sens_fit$TE.common
      result$pooled_sens_se <- sqrt(sens_fit$seTE.common^2)
      result$pooled_sens_ci_lb <- sens_fit$lower.common
      result$pooled_sens_ci_ub <- sens_fit$upper.common

      # Extract specificity
      result$pooled_spec <- spec_fit$TE.common
      result$pooled_spec_se <- sqrt(spec_fit$seTE.common^2)
      result$pooled_spec_ci_lb <- spec_fit$lower.common
      result$pooled_spec_ci_ub <- spec_fit$upper.common

      # Heterogeneity
      result$tau2_sens <- sens_fit$tau2
      result$tau2_spec <- spec_fit$tau2
      result$i2_sens <- sens_fit$I2
      result$i2_spec <- spec_fit$I2
      result$q_stat <- sens_fit$Q
      result$q_pval <- sens_fit$pval.Q

      # Back-transform if using logit scale
      if (sm == "PLOGIT") {
        result$pooled_sens <- plogis(result$pooled_sens)
        result$pooled_sens_ci_lb <- plogis(result$pooled_sens_ci_lb)
        result$pooled_sens_ci_ub <- plogis(result$pooled_sens_ci_ub)
        result$pooled_spec <- plogis(result$pooled_spec)
        result$pooled_spec_ci_lb <- plogis(result$pooled_spec_ci_lb)
        result$pooled_spec_ci_ub <- plogis(result$pooled_spec_ci_ub)
      }

      # Calculate DOR
      log_dor <- log(result$pooled_sens / (1 - result$pooled_sens)) -
                 log((1 - result$pooled_spec) / result$pooled_spec)
      result$pooled_dor <- exp(log_dor)
    }

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  }, warning = function(w) {
    result$warning <- w$message
  })

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  return(result)
}

# -----------------------------------------------------------------------------
# META4DIAG Package Wrapper (Bayesian)
# -----------------------------------------------------------------------------

#' Wrapper for meta4diag - Bayesian Bivariate Meta-Analysis
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param n.chains Number of MCMC chains
#' @param n.iter Number of iterations
#' @param n.burn Number of burn-in iterations
#' @return List with standard output format
wrapper_meta4diag <- function(data, n.chains = 3, n.iter = 5000, n.burn = 1000) {
  start_time <- Sys.time()

  result <- list(
    method = "meta4diag_bayesian",
    converged = NA,
    pooled_sens = NA,
    pooled_sens_se = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec = NA,
    pooled_spec_se = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    pooled_dor = NA,
    pooled_dor_se = NA,
    pooled_dor_ci_lb = NA,
    pooled_dor_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    cov_sens_spec = NA,
    i2_sens = NA,
    i2_spec = NA,
    q_stat = NA,
    q_pval = NA,
    aic = NA,
    bic = NA,
    dic = NA,
    iterations = n.iter,
    runtime_seconds = NA,
    warning = NA,
    error_message = NA
  )

  tryCatch({
    # meta4diag requires data in specific format
    # Create study identifiers
    data$study_id <- 1:nrow(data)

    # Run Bayesian meta-analysis
    fit <- meta4diag::meta4diag(
      data = data,
      var.names = c("TP", "FP", "FN", "TN"),
      n.chains = n.chains,
      n.iter = n.iter,
      n.burnin = n.burn,
      thin = 1
    )

    # Check convergence
    result$converged <- !is.null(fit)

    if (result$converged) {
      # Extract posterior summaries
      post_summary <- summary(fit)

      if (!is.null(post_summary$Sens)) {
        result$pooled_sens <- mean(post_summary$Sens)
        result$pooled_sens_ci_lb <- quantile(post_summary$Sens, 0.025)
        result$pooled_sens_ci_ub <- quantile(post_summary$Sens, 0.975)
        result$pooled_sens_se <- sd(post_summary$Sens)
      }

      if (!is.null(post_summary$Spec)) {
        result$pooled_spec <- mean(post_summary$Spec)
        result$pooled_spec_ci_lb <- quantile(post_summary$Spec, 0.025)
        result$pooled_spec_ci_ub <- quantile(post_summary$Spec, 0.975)
        result$pooled_spec_se <- sd(post_summary$Spec)
      }

      # DOR from posterior
      if (!is.null(post_summary$Sens) && !is.null(post_summary$Spec)) {
        post_dor <- (post_summary$Sens * post_summary$Spec) /
                    ((1 - post_summary$Sens) * (1 - post_summary$Spec))
        result$pooled_dor <- mean(post_dor)
        result$pooled_dor_ci_lb <- quantile(post_dor, 0.025)
        result$pooled_dor_ci_ub <- quantile(post_dor, 0.975)
      }

      # Heterogeneity parameters
      if (!is.null(fit$tau2s)) {
        result$tau2_sens <- mean(fit$tau2s)
      }
      if (!is.null(fit$tau2sp)) {
        result$tau2_spec <- mean(fit$tau2sp)
      }

      # DIC
      if (!is.null(fit$DIC)) {
        result$dic <- fit$DIC
      }
    }

    result$iterations <- n.iter

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  }, warning = function(w) {
    result$warning <- w$message
  })

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  return(result)
}

# -----------------------------------------------------------------------------
# BAMDTA Package Wrapper (Bayesian)
# -----------------------------------------------------------------------------

#' Wrapper for bamdit - Bayesian Meta-Analysis of Diagnostic Test Accuracy
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param n.iter Number of iterations
#' @param n.burn Number of burn-in iterations
#' @return List with standard output format
wrapper_bamdit <- function(data, n.iter = 10000, n.burn = 2000) {
  start_time <- Sys.time()

  result <- list(
    method = "bamdit_bayesian",
    converged = NA,
    pooled_sens = NA,
    pooled_sens_se = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec = NA,
    pooled_spec_se = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    pooled_dor = NA,
    pooled_dor_se = NA,
    pooled_dor_ci_lb = NA,
    pooled_dor_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    cov_sens_spec = NA,
    i2_sens = NA,
    i2_spec = NA,
    q_stat = NA,
    q_pval = NA,
    aic = NA,
    bic = NA,
    dic = NA,
    iterations = n.iter,
    runtime_seconds = NA,
    warning = NA,
    error_message = NA
  )

  tryCatch({
    # bamdit uses JAGS for Bayesian inference
    fit <- bamdit::bamdit(
      data = data,
      n.iter = n.iter,
      n.burn = n.burn
    )

    result$converged <- !is.null(fit)

    if (result$converged) {
      # Extract posterior summaries
      result$pooled_sens <- fit$sensitivity
      result$pooled_spec <- fit$specificity

      # Credible intervals
      if (!is.null(fit$sensitivity_ci)) {
        result$pooled_sens_ci_lb <- fit$sensitivity_ci[1]
        result$pooled_sens_ci_ub <- fit$sensitivity_ci[2]
      }
      if (!is.null(fit$specificity_ci)) {
        result$pooled_spec_ci_lb <- fit$specificity_ci[1]
        result$pooled_spec_ci_ub <- fit$specificity_ci[2]
      }

      # DOR
      if (!is.null(fit$dor)) {
        result$pooled_dor <- fit$dor
        if (!is.null(fit$dor_ci)) {
          result$pooled_dor_ci_lb <- fit$dor_ci[1]
          result$pooled_dor_ci_ub <- fit$dor_ci[2]
        }
      }

      # DIC
      if (!is.null(fit$dic)) {
        result$dic <- fit$dic
      }
    }

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  }, warning = function(w) {
    result$warning <- w$message
  })

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  return(result)
}

# -----------------------------------------------------------------------------
# GLMM Wrapper (lme4)
# -----------------------------------------------------------------------------

#' Wrapper for GLMM using lme4
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param correction Continuity correction
#' @return List with standard output format
wrapper_glmm <- function(data, correction = 0.5) {
  start_time <- Sys.time()

  result <- list(
    method = "glmm_bivariate",
    converged = NA,
    pooled_sens = NA,
    pooled_sens_se = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec = NA,
    pooled_spec_se = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    pooled_dor = NA,
    pooled_dor_se = NA,
    pooled_dor_ci_lb = NA,
    pooled_dor_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    cov_sens_spec = NA,
    i2_sens = NA,
    i2_spec = NA,
    q_stat = NA,
    q_pval = NA,
    aic = NA,
    bic = NA,
    iterations = NA,
    runtime_seconds = NA,
    warning = NA,
    error_message = NA
  )

  tryCatch({
    data_corr <- data
    zero_cells <- (data$TP == 0) | (data$FP == 0) | (data$FN == 0) | (data$TN == 0)
    if (any(zero_cells) && correction > 0) {
      data_corr[, c("TP", "FP", "FN", "TN")] <-
        data_corr[, c("TP", "FP", "FN", "TN")] + correction
    }

    # Create long format for glmer
    study_id <- rep(1:nrow(data_corr), each = 2)
    outcome <- c(data_corr$TP, data_corr$FN)  # Events for sensitivity
    total <- c(data_corr$TP + data_corr$FN, rep(NA, nrow(data_corr)))  # Will fill
    outcome2 <- c(data_corr$TN, data_corr$FP)  # Events for specificity
    total2 <- c(data_corr$TN + data_corr$FP, rep(NA, nrow(data_corr)))

    # Fit bivariate model using glmer
    # This is a simplified approach - full bivariate requires more complex setup

    # Sensitivity model
    data_long <- data.frame(
      study = factor(rep(1:nrow(data_corr), 2)),
      events = c(data_corr$TP, data_corr$FN),
      total = c(data_corr$TP + data_corr$FN, data_corr$TP + data_corr$FN),
      outcome = factor(c(rep(1, nrow(data_corr)), rep(0, nrow(data_corr))))
    )

    sens_fit <- lme4::glmer(
      cbind(events, total - events) ~ 1 + (1 | study),
      data = data_long,
      family = binomial
    )

    result$converged <- !is.null(sens_fit)

    if (result$converged) {
      # Get fixed effects (intercept = pooled sensitivity on logit scale)
      sens_intercept <- fixef(sens_fit)[1]
      result$pooled_sens <- plogis(sens_intercept)

      # SE from variance-covariance
      result$pooled_sens_se <- sqrt(vcov(sens_fit)[1, 1])
      result$pooled_sens_ci_lb <- plogis(sens_intercept - 1.96 * result$pooled_sens_se)
      result$pooled_sens_ci_ub <- plogis(sens_intercept + 1.96 * result$pooled_sens_se)

      # Random effect variance
      result$tau2_sens <- as.numeric(VarCorr(sens_fit)$study)

      # AIC/BIC
      result$aic <- AIC(sens_fit)
      result$bic <- BIC(sens_fit)

      # Similar for specificity (simplified - in practice would fit jointly)
      spec_data_long <- data.frame(
        study = factor(rep(1:nrow(data_corr), 2)),
        events = c(data_corr$TN, data_corr$FP),
        total = c(data_corr$TN + data_corr$FP, data_corr$TN + data_corr$FP)
      )

      spec_fit <- lme4::glmer(
        cbind(events, total - events) ~ 1 + (1 | study),
        data = spec_data_long,
        family = binomial
      )

      spec_intercept <- fixef(spec_fit)[1]
      result$pooled_spec <- plogis(spec_intercept)
      result$pooled_spec_se <- sqrt(vcov(spec_fit)[1, 1])
      result$pooled_spec_ci_lb <- plogis(spec_intercept - 1.96 * result$pooled_spec_se)
      result$pooled_spec_ci_ub <- plogis(spec_intercept + 1.96 * result$pooled_spec_se)
      result$tau2_spec <- as.numeric(VarCorr(spec_fit)$study)

      # DOR
      log_dor <- sens_intercept + spec_intercept
      result$pooled_dor <- exp(log_dor)
    }

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  }, warning = function(w) {
    result$warning <- w$message
  })

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  return(result)
}

# -----------------------------------------------------------------------------
# Master Wrapper Function - Runs All Methods
# -----------------------------------------------------------------------------

#' Run All DTA Meta-Analysis Methods on a Dataset
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param methods Character vector of methods to run (default: all available)
#' @param correction Continuity correction for zero cells
#' @return Data frame with results from all methods
run_all_methods <- function(data,
                             methods = c("reitsma", "mosesl_weighted", "mosesl_unweighted",
                                       "marginal", "meta", "glmm"),
                             correction = 0.5) {

  validate_dta_data(data)

  results_list <- list()

  # Run each method
  if ("reitsma" %in% methods) {
    message("Running reitsma bivariate...")
    results_list[["reitsma"]] <- wrapper_reitsma(data, correction)
  }

  if ("mosesl_weighted" %in% methods) {
    message("Running Moses-Littenberg (weighted)...")
    results_list[["mosesl_weighted"]] <- wrapper_mosesl(data, weighted = TRUE, correction)
  }

  if ("mosesl_unweighted" %in% methods) {
    message("Running Moses-Littenberg (unweighted)...")
    results_list[["mosesl_unweighted"]] <- wrapper_mosesl(data, weighted = FALSE, correction)
  }

  if ("marginal" %in% methods) {
    message("Running marginal pooling...")
    results_list[["marginal"]] <- wrapper_marginal(data, correction)
  }

  if ("meta" %in% methods) {
    message("Running meta package...")
    results_list[["meta"]] <- wrapper_meta(data, sm = "PLOGIT", correction)
  }

  if ("glmm" %in% methods) {
    message("Running GLMM...")
    results_list[["glmm"]] <- wrapper_glmm(data, correction)
  }

  # Convert list to data frame
  results_df <- do.call(rbind, lapply(names(results_list), function(m) {
    out <- results_list[[m]]
    out_df <- as.data.frame(t(unlist(out)))
    out_df$method_run <- m
    return(out_df)
  }))

  rownames(results_df) <- NULL
  return(results_df)
}

# -----------------------------------------------------------------------------
# Batch Processing Function
# -----------------------------------------------------------------------------

#' Apply Methods to Multiple Datasets
#'
#' @param dataset_list Named list of data frames, each with TP, FP, FN, TN
#' @param methods Methods to run
#' @param correction Continuity correction
#' @param parallel Use parallel processing (default: FALSE)
#' @return Data frame with all results
batch_process_datasets <- function(dataset_list,
                                    methods = c("reitsma", "mosesl_weighted",
                                               "marginal", "meta"),
                                    correction = 0.5,
                                    parallel = FALSE) {

  all_results <- list()

  dataset_names <- names(dataset_list)
  if (is.null(dataset_names)) {
    dataset_names <- paste0("dataset_", seq_along(dataset_list))
  }

  for (i in seq_along(dataset_list)) {
    dataset_name <- dataset_names[i]
    data <- dataset_list[[i]]

    message(paste("\n=== Processing dataset:", dataset_name, "==="))

    tryCatch({
      results <- run_all_methods(data, methods, correction)
      results$dataset_name <- dataset_name
      results$n_studies <- nrow(data)

      # Add data characteristics
      results$zero_cells <- sum(data$TP == 0 | data$FP == 0 | data$FN == 0 | data$TN == 0)
      results$total_n <- sum(data$TP + data$FP + data$FN + data$TN)

      all_results[[dataset_name]] <- results

    }, error = function(e) {
      warning(paste("Error processing dataset", dataset_name, ":", e$message))
    })
  }

  # Combine all results
  combined_results <- do.call(rbind, all_results)
  rownames(combined_results) <- NULL

  return(combined_results)
}

# =============================================================================
# END OF method_wrappers.R
# =============================================================================
