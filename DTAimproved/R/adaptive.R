# ============================================================================
# Adaptive DTA Meta-Analysis
# ============================================================================

#' Adaptive Diagnostic Test Accuracy Meta-Analysis
#'
#' Automatically selects the best meta-analysis method based on data
#' characteristics including number of studies, sparsity, and heterogeneity.
#'
#' @param data Data frame with columns TP, FP, FN, TN (true/false positives/negatives)
#' @param verbose Logical; print diagnostic information
#'
#' @return List containing:
#'   \itemize{
#'     \item \code{method}: Name of selected method
#'     \item \code{pooled_sens}: Pooled sensitivity estimate
#'     \item \code{pooled_spec}: Pooled specificity estimate
#'     \item \code{pooled_dor}: Pooled diagnostic odds ratio
#'     \item \code{pooled_sens_ci_lb, pooled_sens_ci_ub}: 95\% CI for sensitivity
#'     \item \code{pooled_spec_ci_lb, pooled_spec_ci_ub}: 95\% CI for specificity
#'     \item \code{converged}: Logical indicating convergence
#'     \item \code{runtime_seconds}: Computation time
#'     \item \code{criteria}: List of data characteristics used for selection
#'   }
#'
#' @details
#' The adaptive method uses a decision tree based on:
#' \itemize{
#'   \item N < 5 studies: Use marginal pooling (exact)
#'   \item Sparsity > 30\%: Use Bayesian regularized method
#'   \item I-squared > 80\%: Use robust bivariate (trimmed)
#'   \item Otherwise: Use standard bivariate model (Reitsma)
#' }
#'
#' @examples
#' \dontrun{
#' data(COVID_AntigenTests_Cochrane2021)
#' result <- dta_adaptive(COVID_AntigenTests_Cochrane2021)
#' print(result$pooled_sens)
#' print(result$pooled_spec)
#' }
#'
#' @export
#' @family main functions
dta_adaptive <- function(data, verbose = FALSE) {

  validate_dta_data(data)

  start_time <- Sys.time()

  # Assess data characteristics
  n_studies <- nrow(data)
  sparsity <- calculate_sparsity(data)

  # Calculate heterogeneity (I-squared)
  w_sens <- data$TP + data$FN
  sens_i <- data$TP / w_sens
  sens_pooled <- sum(w_sens * sens_i) / sum(w_sens)
  Q_sens <- sum(w_sens * (sens_i - sens_pooled)^2) / (sens_pooled * (1 - sens_pooled))
  i2 <- calculate_i2(Q_sens, n_studies - 1)

  # Decision tree for method selection
  selected_method <- NULL

  if (n_studies < 5) {
    # Very small number of studies: use marginal pooling
    selected_method <- "marginal"
    result <- dta_marginal(data)

  } else if (sparsity > 0.3) {
    # High sparsity: use regularized method
    selected_method <- "regularized"
    result <- dta_regularized(data)

  } else if (i2 > 80) {
    # High heterogeneity: use robust method
    selected_method <- "robust"
    result <- dta_robust(data)

  } else {
    # Default: use standard bivariate
    selected_method <- "bivariate"
    result <- dta_bivariate(data)
  }

  # Add adaptive-specific information
  result$method <- paste0("adaptive_", selected_method)
  result$selected_method <- selected_method
  result$criteria <- list(
    n_studies = n_studies,
    sparsity = sparsity,
    i2 = i2
  )

  result$runtime_seconds <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  if (verbose) {
    cat("Adaptive method selection:\n")
    cat(sprintf("  N = %d studies\n", n_studies))
    cat(sprintf("  Sparsity = %.1f%%\n", 100 * sparsity))
    cat(sprintf("  I-squared = %.1f%%\n", i2))
    cat(sprintf("  Selected method: %s\n", selected_method))
  }

  return(result)
}

# ============================================================================
# Standard Bivariate Model (Reitsma)
# ============================================================================

#' Bivariate Model for DTA Meta-Analysis (Reitsma)
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param correction Continuity correction for zero cells
#' @return List with results
#' @keywords internal
dta_bivariate <- function(data, correction = 0.5) {

  result <- list(
    method = "bivariate",
    converged = FALSE,
    pooled_sens = NA,
    pooled_spec = NA,
    pooled_dor = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    tau2_sens = NA,
    tau2_spec = NA,
    runtime_seconds = NA,
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

    # Run bivariate model
    fit <- mada::reitsma(data_corr)

    result$converged <- !is.null(fit) && !any(is.na(fit$coef))

    if (result$converged) {
      result$pooled_sens <- plogis(fit$coef[1])
      result$pooled_spec <- plogis(fit$coef[2])
      result$pooled_dor <- exp(fit$coef[1] + fit$coef[2])

      # Confidence intervals
      sens_ci <- plogis(fit$coef[1] + c(-1, 1) * 1.96 * sqrt(fit$vcov[1, 1]))
      spec_ci <- plogis(fit$coef[2] + c(-1, 1) * 1.96 * sqrt(fit$vcov[2, 2]))

      result$pooled_sens_ci_lb <- sens_ci[1]
      result$pooled_sens_ci_ub <- sens_ci[2]
      result$pooled_spec_ci_lb <- spec_ci[1]
      result$pooled_spec_ci_ub <- spec_ci[2]

      # Random effects variances
      result$tau2_sens <- fit$theta[1]
      result$tau2_spec <- fit$theta[2]
    }

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  })

  return(result)
}

# ============================================================================
# Marginal Pooling Method
# ============================================================================

#' Marginal Pooling for DTA Meta-Analysis
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param correction Continuity correction
#' @return List with results
#' @keywords internal
dta_marginal <- function(data, correction = 0.5) {

  result <- list(
    method = "marginal",
    converged = FALSE,
    pooled_sens = NA,
    pooled_spec = NA,
    pooled_dor = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    runtime_seconds = NA,
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
    result$pooled_sens_ci_lb <- max(0, result$pooled_sens - 1.96 * se_sens)
    result$pooled_sens_ci_ub <- min(1, result$pooled_sens + 1.96 * se_sens)

    # Pooled specificity
    result$pooled_spec <- total_TN / (total_TN + total_FP)
    se_spec <- sqrt((result$pooled_spec * (1 - result$pooled_spec)) /
                    (total_TN + total_FP))
    result$pooled_spec_ci_lb <- max(0, result$pooled_spec - 1.96 * se_spec)
    result$pooled_spec_ci_ub <- min(1, result$pooled_spec + 1.96 * se_spec)

    # DOR
    result$pooled_dor <- (total_TP * total_TN) / (total_FP * total_FN)

    result$converged <- TRUE

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  })

  return(result)
}

# ============================================================================
# Regularized Method for Sparse Data
# ============================================================================

#' Regularized DTA Meta-Analysis for Sparse Data
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @return List with results
#' @keywords internal
dta_regularized <- function(data) {

  result <- list(
    method = "regularized",
    converged = FALSE,
    pooled_sens = NA,
    pooled_spec = NA,
    pooled_dor = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    runtime_seconds = NA,
    error_message = NA
  )

  tryCatch({
    # Minimal correction only for zero cells (Firth-style)
    data_corr <- data

    zero_cells <- (data$TP == 0) | (data$FP == 0) | (data$FN == 0) | (data$TN == 0)

    if (any(zero_cells)) {
      # Add 0.5 only to zero cells (targeted correction)
      data_corr$TP[data$TP == 0] <- data$TP[data$TP == 0] + 0.5
      data_corr$FP[data$FP == 0] <- data$FP[data$FP == 0] + 0.5
      data_corr$FN[data$FN == 0] <- data$FN[data$FN == 0] + 0.5
      data_corr$TN[data$TN == 0] <- data$TN[data$TN == 0] + 0.5
    }

    # Use standard bivariate on corrected data
    fit <- mada::reitsma(data_corr)

    if (!is.null(fit)) {
      result$converged <- TRUE
      result$pooled_sens <- plogis(fit$coef[1])
      result$pooled_spec <- plogis(fit$coef[2])
      result$pooled_dor <- exp(fit$coef[1] + fit$coef[2])

      # Bootstrap for better CIs
      if (nrow(data) >= 5) {
        boot_results <- boot::boot(
          data_corr,
          statistic = function(d, idx) {
            d_sub <- d[idx, ]
            fit_sub <- mada::reitsma(d_sub)
            c(plogis(fit_sub$coef[1]), plogis(fit_sub$coef[2]))
          },
          R = 500
        )

        result$pooled_sens_ci_lb <- quantile(boot_results$t[,1], 0.025)
        result$pooled_sens_ci_ub <- quantile(boot_results$t[,1], 0.975)
        result$pooled_spec_ci_lb <- quantile(boot_results$t[,2], 0.025)
        result$pooled_spec_ci_ub <- quantile(boot_results$t[,2], 0.975)
      } else {
        # Use standard CIs for small datasets
        sens_ci <- plogis(fit$coef[1] + c(-1, 1) * 1.96 * sqrt(fit$vcov[1, 1]))
        spec_ci <- plogis(fit$coef[2] + c(-1, 1) * 1.96 * sqrt(fit$vcov[2, 2]))
        result$pooled_sens_ci_lb <- sens_ci[1]
        result$pooled_sens_ci_ub <- sens_ci[2]
        result$pooled_spec_ci_lb <- spec_ci[1]
        result$pooled_spec_ci_ub <- spec_ci[2]
      }
    }

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  })

  return(result)
}

# ============================================================================
# Robust Method with Trimming
# ============================================================================

#' Robust DTA Meta-Analysis with Trimming
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @param trim Proportion to trim from each end
#' @return List with results
#' @keywords internal
dta_robust <- function(data, trim = 0.1) {

  result <- list(
    method = "robust",
    converged = FALSE,
    pooled_sens = NA,
    pooled_spec = NA,
    pooled_dor = NA,
    pooled_sens_ci_lb = NA,
    pooled_sens_ci_ub = NA,
    pooled_spec_ci_lb = NA,
    pooled_spec_ci_ub = NA,
    runtime_seconds = NA,
    error_message = NA
  )

  tryCatch({
    n <- nrow(data)

    if (n < 5) {
      # Too few studies for trimming, use standard method
      result <- dta_bivariate(data)
    } else {
      # Calculate influence measures
      data$sens <- with(data, TP / (TP + FN))
      data$spec <- with(data, TN / (TN + FP))
      data$weight <- with(data, TP + FP + FN + TN)

      # Standardized residuals from marginal pooling
      mean_sens <- weighted.mean(data$sens, data$weight, na.rm = TRUE)
      mean_spec <- weighted.mean(data$spec, data$weight, na.rm = TRUE)

      data$resid_sens <- abs(data$sens - mean_sens)
      data$resid_spec <- abs(data$spec - mean_spec)
      data$influence <- data$resid_sens + data$resid_spec

      # Trim extreme studies
      n_trim <- max(1, floor(n * trim))
      trim_idx <- order(data$influence)[1:(n - 2*n_trim)]
      data_trimmed <- data[trim_idx, ]

      # Fit model to trimmed data
      fit <- mada::reitsma(data_trimmed)

      if (!is.null(fit)) {
        result$converged <- TRUE
        result$pooled_sens <- plogis(fit$coef[1])
        result$pooled_spec <- plogis(fit$coef[2])
        result$pooled_dor <- exp(fit$coef[1] + fit$coef[2])

        sens_ci <- plogis(fit$coef[1] + c(-1, 1) * 1.96 * sqrt(fit$vcov[1, 1]))
        spec_ci <- plogis(fit$coef[2] + c(-1, 1) * 1.96 * sqrt(fit$vcov[2, 2]))

        result$pooled_sens_ci_lb <- sens_ci[1]
        result$pooled_sens_ci_ub <- sens_ci[2]
        result$pooled_spec_ci_lb <- spec_ci[1]
        result$pooled_spec_ci_ub <- spec_ci[2]
      }
    }

  }, error = function(e) {
    result$converged <- FALSE
    result$error_message <- e$message
  })

  return(result)
}
