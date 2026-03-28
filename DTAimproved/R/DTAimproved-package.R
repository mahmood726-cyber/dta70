# ============================================================================
# DTAimproved: Improved Methods for Diagnostic Test Accuracy Meta-Analysis
# ============================================================================
#
# This package provides improved meta-analysis methods for diagnostic test
# accuracy studies, developed through comprehensive evaluation of existing
# methods and identification of their flaws.
#
# Main functions:
#   - dta_adaptive(): Adaptive method selection based on data characteristics
#   - dta_robust(): Robust bivariate model with trimming
#   - dta_ensemble(): Ensemble of multiple methods
#   - recommend_method(): Recommend best method for given data
#
# ============================================================================

#' @keywords internal
"_PACKAGE"

#' @docType package
#' @name DTAimproved-package
#' @alias DTAimproved
#' @title Improved Methods for Diagnostic Test Accuracy Meta-Analysis
#' @description
#' Improved meta-analysis methods for diagnostic test accuracy studies based on
#' comprehensive evaluation of existing methods.
#'
#' @details
#' The DTAimproved package implements:
#' \itemize{
#'   \item Adaptive method selection (dta_adaptive)
#'   \item Robust estimation for sparse data (dta_robust)
#'   \item Ensemble methods (dta_ensemble)
#'   \item Method recommendation tool (recommend_method)
#' }
#'
#' @references
#' Based on comprehensive evaluation of 12+ DTA meta-analysis methods across
#' 76 real-world datasets (1,966+ studies).
#'
#' @docType package
#' @name DTAimproved-package
NULL

# =============================================================================
# Internal Utility Functions
# ============================================================================

#' Calculate Data Sparsity
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @return Numeric sparsity index (proportion of zero cells)
#' @keywords internal
calculate_sparsity <- function(data) {
  zero_cells <- sum(data$TP == 0 | data$FP == 0 | data$FN == 0 | data$TN == 0)
  total_cells <- 4 * nrow(data)
  return(zero_cells / total_cells)
}

#' Calculate I-squared
#'
#' @param Q Q-statistic
#' @param df Degrees of freedom
#' @return Numeric I-squared value (0-100)
#' @keywords internal
calculate_i2 <- function(Q, df) {
  if (Q < df) return(0)
  100 * (Q - df) / Q
}

#' Validate DTA Input Data
#'
#' @param data Data frame with TP, FP, FN, TN columns
#' @return Logical; TRUE if valid
#' @keywords internal
validate_dta_data <- function(data) {
  required_cols <- c("TP", "FP", "FN", "TN")
  if (!all(required_cols %in% names(data))) {
    stop("Data must contain TP, FP, FN, TN columns")
  }
  if (any(data[, required_cols] < 0, na.rm = TRUE)) {
    stop("Cell counts cannot be negative")
  }
  return(TRUE)
}
