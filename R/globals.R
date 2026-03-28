#' @importFrom stats dbinom lm median plogis qlogis quantile rbinom rnorm runif var
#' @importFrom utils data packageVersion read.csv write.csv
#' @importFrom grDevices dev.off png rgb
#' @importFrom graphics grid legend points polygon segments
NULL

if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("AuditC_data", "TP", "TN", "FP", "FN", "wrapper_reitsma"))
}