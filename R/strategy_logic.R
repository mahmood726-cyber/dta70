#' Select DTA Strategy
#' @keywords internal
select_dta_strategy <- function(data, mods, method) {
  if (method != "auto") {
    if (method == "frequentist") return("tier2_bivariate")
    if (method == "bayesian") return("tier5_bayesian")
    if (method == "averaging") return("tier7_averaging")
    if (method == "robust") return("tier8_robust")
    if (method == "mixture") return("tier6_mixture")
    if (method == "ensemble") return("tier10_ensemble")
    if (method == "ipd") return("tier9_ipd")
    if (method == "regression" && !is.null(mods)) return("tier4_regression")
    return(method)
  }
  if (!is.null(mods)) return("tier4_regression")
  n <- nrow(data)
  if (n < 5) return("tier1_firth")
  if (n >= 10) return("tier7_averaging") # Default to Oracle Averaging
  return("tier2_bivariate")
}

#' Execute DTA Strategy
#' @keywords internal
execute_dta_strategy <- function(strat, data, mods, args) {
  if (strat == "tier1_firth") return(run_firth_penalized(data))
  if (strat == "tier2_bivariate") return(run_bivariate_glmm(data))
  if (strat == "tier4_regression") return(run_regression_glmm(data, mods))
  if (strat == "tier5_bayesian") return(run_bayesian_mcmc(data, args$mcmc_iter))
  if (strat == "tier6_mixture") return(run_latent_mixture(data))
  if (strat == "tier7_averaging") return(run_model_averaging(data, args$mcmc_iter))
  if (strat == "tier8_robust") return(run_robust_bivariate(data))
  if (strat == "tier9_ipd") return(run_pseudo_ipd(data))
  if (strat == "tier10_ensemble") return(run_bagged_ensemble(data, args$boot_n))
  return(run_firth_penalized(data))
}

#' Run Regression GLMM (Bivariate Logit with Covariates)
#' @keywords internal
run_regression_glmm <- function(data, mods) {
  # Fallback if mods invalid
  if (is.null(mods) || nrow(as.matrix(mods)) != nrow(data)) {
    return(run_bivariate_glmm(data))
  }
  
  y1 <- qlogis((data$TP + 0.5) / (data$TP + data$FN + 1))
  y2 <- qlogis((data$TN + 0.5) / (data$TN + data$FP + 1))
  v1 <- 1 / (data$TP + 0.5) + 1 / (data$FN + 0.5)
  v2 <- 1 / (data$TN + 0.5) + 1 / (data$FP + 0.5)
  
  X <- cbind(1, as.matrix(mods))
  
  fit_reg <- function(y, v, X) {
    if (det(t(X) %*% X) < 1e-10) return(list(beta=rep(0, ncol(X)), se=rep(1, ncol(X)), tau2=0)) # Singular
    w <- 1 / v
    W <- diag(w, nrow=length(w))
    beta <- solve(t(X) %*% W %*% X) %*% t(X) %*% W %*% y
    res <- y - X %*% beta
    k <- length(y)
    p <- ncol(X)
    df <- k - p
    tau2 <- 0
    if (df > 0) {
      Q <- sum(w * res^2)
      W_sum <- sum(w)
      tr_P <- sum(diag(solve(t(X) %*% W %*% X) %*% t(X) %*% (W %*% W) %*% X))
      if (W_sum > tr_P) tau2 <- max(0, (Q - df) / (W_sum - tr_P))
    }
    wr <- 1 / (v + tau2)
    Wr <- diag(wr, nrow=length(wr))
    beta_re <- solve(t(X) %*% Wr %*% X) %*% t(X) %*% Wr %*% y
    vcov_re <- solve(t(X) %*% Wr %*% X)
    list(beta = beta_re, se = sqrt(diag(vcov_re)), tau2 = tau2)
  }
  
  r1 <- fit_reg(y1, v1, X)
  r2 <- fit_reg(y2, v2, X)
  
  int_sens <- r1$beta[1]; se_sens <- r1$se[1]
  int_spec <- r2$beta[1]; se_spec <- r2$se[1]
  
  list(estimates = list(
    sens = c(plogis(int_sens), plogis(int_sens - 1.96 * se_sens), plogis(int_sens + 1.96 * se_sens)),
    spec = c(plogis(int_spec), plogis(int_spec - 1.96 * se_spec), plogis(int_spec + 1.96 * se_spec)),
    lr_p = plogis(int_sens) / (1 - plogis(int_spec)),
    lr_n = (1 - plogis(int_sens)) / plogis(int_spec),
    dor = exp(int_sens + int_spec),
    beta_sens = r1$beta,
    beta_spec = r2$beta,
    tau2_sens = r1$tau2,
    tau2_spec = r2$tau2
  ), averaged = FALSE, mcmc_diag = NULL)
}
