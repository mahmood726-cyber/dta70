# ============================================================================
# evaluation_metrics.R - Performance Evaluation Metrics for DTA Methods
# ============================================================================
#
# This file contains functions for calculating performance metrics,
# bias, coverage, and other evaluation measures for comparing DTA methods.
#
# ============================================================================

# -----------------------------------------------------------------------------
# Data Characteristics Metrics
# -----------------------------------------------------------------------------

#' Calculate Sparsity Index
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @return Numeric sparsity index (proportion of zero cells)
calculate_sparsity <- function(data) {
  zero_cells <- sum(data$TP == 0 | data$FP == 0 | data$FN == 0 | data$TN == 0)
  total_cells <- 4 * nrow(data)
  return(zero_cells / total_cells)
}

#' Calculate Effective Sample Size
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @return Numeric effective sample size
calculate_eff_n <- function(data) {
  n <- nrow(data)
  mean_cell_n <- mean(data$TP + data$FP + data$FN + data$TN) / 4
  return(n * mean_cell_n)
}

#' Calculate Study Size Range
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @return Named vector with min, max, mean study sizes
calculate_study_size_range <- function(data) {
  study_sizes <- data$TP + data$FP + data$FN + data$TN
  return(c(
    min_size = min(study_sizes),
    max_size = max(study_sizes),
    mean_size = mean(study_sizes),
    median_size = median(study_sizes)
  ))
}

#' Calculate Proportion of Studies with Perfect Classification
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @return Named vector with proportions
calculate_perfect_proportions <- function(data) {
  n <- nrow(data)
  perfect_sens <- sum(data$FN == 0) / n
  perfect_spec <- sum(data$FP == 0) / n
  perfect_both <- sum(data$FN == 0 & data$FP == 0) / n
  return(c(
    perfect_sens = perfect_sens,
    perfect_spec = perfect_spec,
    perfect_both = perfect_both
  ))
}

#' Calculate Overall Dataset Characteristics
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @return Named list of characteristics
calculate_data_characteristics <- function(data) {
  list(
    n_studies = nrow(data),
    sparsity = calculate_sparsity(data),
    eff_n = calculate_eff_n(data),
    zero_cells = sum(data$TP == 0 | data$FP == 0 | data$FN == 0 | data$TN == 0),
    study_size_range = calculate_study_size_range(data),
    perfect_proportions = calculate_perfect_proportions(data),
    mean_sens_raw = mean(data$TP / (data$TP + data$FN), na.rm = TRUE),
    mean_spec_raw = mean(data$TN / (data$TN + data$FP), na.rm = TRUE),
    cv_sens = sd(data$TP / (data$TP + data$FN), na.rm = TRUE) /
             mean(data$TP / (data$TP + data$FN), na.rm = TRUE),
    cv_spec = sd(data$TN / (data$TN + data$FP), na.rm = TRUE) /
             mean(data$TN / (data$TN + data$FP), na.rm = TRUE)
  )
}

# -----------------------------------------------------------------------------
# Method Comparison Metrics
# -----------------------------------------------------------------------------

#' Calculate Bias Compared to Reference
#'
#' @param estimate Estimated value
#' @param reference Reference (true) value
#' @return Numeric bias (estimate - reference)
calculate_bias <- function(estimate, reference) {
  estimate - reference
}

#' Calculate Relative Bias (Percentage)
#'
#' @param estimate Estimated value
#' @param reference Reference (true) value
#' @return Numeric relative bias as percentage
calculate_relative_bias <- function(estimate, reference) {
  100 * (estimate - reference) / reference
}

#' Calculate Mean Squared Error
#'
#' @param estimates Vector of estimates
#' @param reference Reference (true) value
#' @return Numeric MSE
calculate_mse <- function(estimates, reference) {
  mean((estimates - reference)^2, na.rm = TRUE)
}

#' Calculate Root Mean Squared Error
#'
#' @param estimates Vector of estimates
#' @param reference Reference (true) value
#' @return Numeric RMSE
calculate_rmse <- function(estimates, reference) {
  sqrt(calculate_mse(estimates, reference))
}

#' Calculate Absolute Error
#'
#' @param estimate Estimated value
#' @param reference Reference (true) value
#' @return Numeric absolute error
calculate_abs_error <- function(estimate, reference) {
  abs(estimate - reference)
}

#' Calculate Mean Absolute Error
#'
#' @param estimates Vector of estimates
#' @param reference Reference (true) value
#' @return Numeric MAE
calculate_mae <- function(estimates, reference) {
  mean(abs(estimates - reference), na.rm = TRUE)
}

# -----------------------------------------------------------------------------
# Confidence Interval Metrics
# -----------------------------------------------------------------------------

#' Calculate CI Width
#'
#' @param ci_lower Lower confidence bound
#' @param ci_upper Upper confidence bound
#' @return Numeric CI width
calculate_ci_width <- function(ci_lower, ci_upper) {
  ci_upper - ci_lower
}

#' Calculate Empirical Coverage Probability
#'
#' @param lower_bounds Vector of lower CI bounds
#' @param upper_bounds Vector of upper CI bounds
#' @param true_values Vector of true values
#' @return Numeric coverage proportion
calculate_coverage <- function(lower_bounds, upper_bounds, true_values) {
  covered <- (true_values >= lower_bounds) & (true_values <= upper_bounds)
  mean(covered, na.rm = TRUE)
}

#' Calculate Coverage Error
#'
#' @param empirical_coverage Empirical coverage probability
#' @param nominal_level Nominal coverage level (e.g., 0.95)
#' @return Numeric coverage error
calculate_coverage_error <- function(empirical_coverage, nominal_level = 0.95) {
  empirical_coverage - nominal_level
}

#' Check if CI is Valid (bounds within [0,1])
#'
#' @param ci_lower Lower confidence bound
#' @param ci_upper Upper confidence bound
#' @return Logical; TRUE if valid
check_ci_valid <- function(ci_lower, ci_upper) {
  (ci_lower >= 0) & (ci_upper <= 1) & (ci_lower < ci_upper)
}

# -----------------------------------------------------------------------------
# Agreement Metrics
# -----------------------------------------------------------------------------

#' Calculate Pearson Correlation Between Methods
#'
#' @param x Vector of estimates from method 1
#' @param y Vector of estimates from method 2
#' @return Numeric correlation coefficient
calculate_agreement_pearson <- function(x, y) {
  complete_cases <- complete.cases(x, y)
  cor(x[complete_cases], y[complete_cases], method = "pearson")
}

#' Calculate Spearman Rank Correlation Between Methods
#'
#' @param x Vector of estimates from method 1
#' @param y Vector of estimates from method 2
#' @return Numeric correlation coefficient
calculate_agreement_spearman <- function(x, y) {
  complete_cases <- complete.cases(x, y)
  cor(x[complete_cases], y[complete_cases], method = "spearman")
}

#' Calculate Concordance Correlation Coefficient
#'
#' @param x Vector of estimates from method 1
#' @param y Vector of estimates from method 2
#' @return Numeric CCC
calculate_ccc <- function(x, y) {
  complete_cases <- complete.cases(x, y)
  x <- x[complete_cases]
  y <- y[complete_cases]

  mean_x <- mean(x)
  mean_y <- mean(y)
  var_x <- var(x)
  var_y <- var(y)

  # Pearson correlation
  r <- cor(x, y)

  # Concordance correlation
  ccc <- (2 * r * sd(x) * sd(y)) / (var_x + var_y + (mean_x - mean_y)^2)
  return(ccc)
}

#' Calculate Bland-Altman Limits of Agreement
#'
#' @param x Vector of estimates from method 1
#' @param y Vector of estimates from method 2
#' @return Named list with bias, loa_lower, loa_upper
calculate_bland_altman <- function(x, y) {
  complete_cases <- complete.cases(x, y)
  x <- x[complete_cases]
  y <- y[complete_cases]

  differences <- x - y
  bias <- mean(differences)
  sd_diff <- sd(differences)

  list(
    bias = bias,
    loa_lower = bias - 1.96 * sd_diff,
    loa_upper = bias + 1.96 * sd_diff,
    sd_diff = sd_diff,
    mean_diff = bias
  )
}

# -----------------------------------------------------------------------------
# Convergence and Performance Metrics
# -----------------------------------------------------------------------------

#' Calculate Convergence Rate
#'
#' @param results Data frame with converged column
#' @return Numeric convergence rate (proportion)
calculate_convergence_rate <- function(results) {
  mean(results$converged, na.rm = TRUE)
}

#' Calculate Runtime Statistics
#'
#' @param runtimes Vector of runtime values in seconds
#' @return Named vector with statistics
calculate_runtime_stats <- function(runtimes) {
  list(
    mean = mean(runtimes, na.rm = TRUE),
    median = median(runtimes, na.rm = TRUE),
    min = min(runtimes, na.rm = TRUE),
    max = max(runtimes, na.rm = TRUE),
    total = sum(runtimes, na.rm = TRUE)
  )
}

#' Calculate Efficiency (Runtime per Convergence)
#'
#' @param runtime Runtime in seconds
#' @param converged Whether the method converged
#' @return Numeric efficiency score (higher is better)
calculate_efficiency_score <- function(runtime, converged) {
  if (!converged) return(0)
  1 / runtime  # Inverse of runtime
}

# -----------------------------------------------------------------------------
# Composite Performance Score
# -----------------------------------------------------------------------------

#' Calculate Composite Performance Score
#'
#' @param results Data frame with method results
#' @param weights Named list of weights for each metric
#' @return Data frame with composite scores by method
calculate_composite_score <- function(results,
                                      weights = list(
                                        accuracy = 0.4,
                                        coverage = 0.3,
                                        efficiency = 0.2,
                                        convergence = 0.1
                                      )) {

  # Group by method
  methods <- unique(results$method)

  scores <- lapply(methods, function(m) {
    method_data <- results[results$method == m, ]

    # Accuracy score (inverse of MAE vs consensus)
    # This requires a consensus estimate to be calculated first

    # Coverage score (how close to 95% coverage)

    # Efficiency score (inverse of mean runtime)

    # Convergence score (proportion converged)

    # Weighted composite
    score <- NA  # Placeholder

    return(c(method = m, composite_score = score))
  })

  return(do.call(rbind, scores))
}

# -----------------------------------------------------------------------------
# Ranking Methods
# -----------------------------------------------------------------------------

#' Rank Methods by Performance
#'
#' @param results Data frame with method results
#' @param metric Metric to rank by (e.g., "runtime", "pooled_sens")
#' @param descending Should higher values be ranked higher?
#' @return Data frame with method rankings
rank_methods <- function(results, metric = "runtime", descending = FALSE) {
  method_summary <- aggregate(results[[metric]],
                              by = list(method = results$method),
                              FUN = mean,
                              na.rm = TRUE)

  colnames(method_summary)[2] <- "mean_value"

  method_summary <- method_summary[order(method_summary$mean_value,
                                          decreasing = descending), ]

  method_summary$rank <- 1:nrow(method_summary)
  return(method_summary)
}

#' Create Method Ranking Table
#'
#' @param results Data frame with method results
#' @return Data frame with rankings across multiple metrics
create_ranking_table <- function(results) {
  metrics <- c("runtime", "converged", "pooled_sens", "pooled_spec", "pooled_dor")

  rankings <- lapply(metrics, function(m) {
    r <- rank_methods(results, m, descending = (m == "converged"))
    colnames(r)[2] <- paste0("mean_", m)
    return(r)
  })

  # Merge rankings
  ranking_table <- rankings[[1]]
  for (i in 2:length(rankings)) {
    ranking_table <- merge(ranking_table,
                          rankings[i][, c("method", "rank")],
                          by = "method",
                          suffixes = c("", paste0("_", metrics[i])))
  }

  return(ranking_table)
}

# -----------------------------------------------------------------------------
# Heterogeneity Metrics
# -----------------------------------------------------------------------------

#' Calculate I-squared (Heterogeneity Statistic)
#'
#' @param Q Q-statistic
#' @param df Degrees of freedom
#' @return Numeric I-squared value (0-100)
calculate_i2 <- function(Q, df) {
  if (Q < df) return(0)
  100 * (Q - df) / Q
}

#' Calculate Tau-squared (Between-Study Variance)
#'
#' @param Q Q-statistic
#' @param df Degrees of freedom
#' @param C Sum of weights (for DL estimator)
#' @return Numeric tau-squared
calculate_tau2_dl <- function(Q, df, C) {
  if (Q <= df) return(0)
  (Q - df) / C
}

# -----------------------------------------------------------------------------
# Simulation-Based Metrics
# -----------------------------------------------------------------------------

#' Calculate Simulation Performance Metrics
#'
#' @param estimates Matrix of estimates (replications x datasets)
#' @param true_values Vector of true values
#' @return List with bias, MSE, coverage metrics
calculate_simulation_metrics <- function(estimates, true_values) {
  n_sims <- nrow(estimates)

  # Point estimates
  mean_estimate <- colMeans(estimates, na.rm = TRUE)
  bias <- mean_estimate - true_values
  rel_bias <- 100 * bias / true_values
  mse <- colMeans((estimates - matrix(true_values, nrow = n_sims,
                                        ncol = length(true_values),
                                        byrow = TRUE))^2, na.rm = TRUE)
  rmse <- sqrt(mse)

  list(
    mean_estimate = mean_estimate,
    bias = bias,
    relative_bias = rel_bias,
    mse = mse,
    rmse = rmse
  )
}

# -----------------------------------------------------------------------------
# Diagnostic Accuracy Specific Metrics
# -----------------------------------------------------------------------------

#' Calculate Diagnostic Odds Ratio from 2x2 Table
#'
#' @param TP True positives
#' @param FP False positives
#' @param FN False negatives
#' @param TN True negatives
#' @return Numeric DOR
calculate_dor <- function(TP, FP, FN, TN) {
  (TP * TN) / (FP * FN)
}

#' Calculate Positive Likelihood Ratio
#'
#' @param sensitivity Sensitivity value
#' @param specificity Specificity value
#' @return Numeric LR+
calculate_lr_positive <- function(sensitivity, specificity) {
  sensitivity / (1 - specificity)
}

#' Calculate Negative Likelihood Ratio
#'
#' @param sensitivity Sensitivity value
#' @param specificity Specificity value
#' @return Numeric LR-
calculate_lr_negative <- function(sensitivity, specificity) {
  (1 - sensitivity) / specificity
}

#' Calculate Area Under SROC Curve
#'
#' @param sensitivity Vector of sensitivity values
#' @param specificity Vector of specificity values (1 - specificity)
#' @return Numeric AUC (using trapezoidal rule)
calculate_sroc_auc <- function(sensitivity, specificity) {
  # Sort by 1 - specificity (x-axis)
  ord <- order(1 - specificity)
  sens_sorted <- sensitivity[ord]
  fpr_sorted <- 1 - specificity[ord]

  # Add (0,0) and (1,1) points if not present
  if (fpr_sorted[1] != 0) {
    fpr_sorted <- c(0, fpr_sorted)
    sens_sorted <- c(0, sens_sorted)
  }
  if (fpr_sorted[length(fpr_sorted)] != 1) {
    fpr_sorted <- c(fpr_sorted, 1)
    sens_sorted <- c(sens_sorted, 1)
  }

  # Trapezoidal rule
  n <- length(fpr_sorted)
  auc <- 0
  for (i in 2:n) {
    dx <- fpr_sorted[i] - fpr_sorted[i-1]
    avg_y <- (sens_sorted[i] + sens_sorted[i-1]) / 2
    auc <- auc + dx * avg_y
  }

  return(auc)
}

# -----------------------------------------------------------------------------
# Reporting Functions
# -----------------------------------------------------------------------------

#' Create Performance Summary Table
#'
#' @param results Data frame with all results
#' @return Formatted table for reporting
create_performance_summary <- function(results) {
  summary_df <- aggregate(cbind(runtime, converged) ~ method,
                          data = results,
                          FUN = function(x) c(mean = mean(x, na.rm = TRUE),
                                             sd = sd(x, na.rm = TRUE)))

  # Flatten the matrix columns
  summary_df$runtime_mean <- summary_df$runtime[, "mean"]
  summary_df$runtime_sd <- summary_df$runtime[, "sd"]
  summary_df$converged_mean <- summary_df$converged[, "mean"]

  summary_df <- summary_df[, c("method", "runtime_mean", "runtime_sd",
                                "converged_mean")]

  colnames(summary_df) <- c("Method", "Mean Runtime (s)", "SD Runtime (s)",
                            "Convergence Rate")

  return(summary_df)
}

#' Create Method Comparison Matrix
#'
#' @param results Data frame with all results
#' @param metric Metric to compare (e.g., "pooled_sens")
#' @return Correlation matrix of methods
create_comparison_matrix <- function(results, metric = "pooled_sens") {
  # Reshape to wide format
  wide_data <- reshape(results[, c("dataset_name", "method", metric)],
                       idvar = "dataset_name",
                       timevar = "method",
                       direction = "wide")

  # Remove dataset_name column for correlation
  mat <- as.matrix(wide_data[, -1])
  colnames(mat) <- gsub(paste0("^", metric, "\\."), "", colnames(mat))

  # Calculate correlation matrix
  cor_matrix <- cor(mat, use = "pairwise.complete.obs")

  return(cor_matrix)
}

# =============================================================================
# END OF evaluation_metrics.R
# =============================================================================
