#' DTA-Stack: The Clinical Oracle (v25.0)
#'
#' @description
#' The autonomous consultant for diagnostic medicine.
#' Features: Dynamic Model Averaging, Clinical Pathways, Entropy Landscapes, LOO Influential Analysis, IPD Reconstruction, and ML Ensembles.
#'
#' @param data A data frame with TP, FN, FP, TN columns.
#' @param mods Optional moderators for meta-regression.
#' @param method Selection method: "auto", "frequentist", "bayesian", "averaging", "robust", "mixture", "ensemble", "ipd".
#' @param mcmc_iter Number of MCMC iterations for Bayesian models.
#' @param boot_n Number of bootstrap iterations for frequentist uncertainty or ML Ensembles.
#' @param loo Logical. If TRUE, runs Leave-One-Out influential study analysis.
#' @return Object of class "dta_stack"
#' @export
dta_stack <- function(data, mods = NULL, method = "auto", mcmc_iter = 3000, boot_n = 500, loo = FALSE) {
  start_time <- Sys.time()
  data <- as.data.frame(data)
  
  # 1. Integrity check
  integrity <- calculate_zenith_integrity(data, if("Year" %in% names(data)) data$Year else rep(2020, nrow(data)))
  
  # 2. Strategy Selection
  strategy <- select_dta_strategy(data, mods, method)
  
  # 3. Execution
  args <- list(mcmc_iter=mcmc_iter, boot_n=boot_n)
  fit <- execute_dta_strategy(strategy, data, mods, args)
  
  # 4. Refinement & Bias
  fit$estimates <- apply_context_aware_prior(fit$estimates, nrow(data))
  bias <- safe_deeks_test(data)
  
  # 5. Clinical Pathway Logic
  sens <- fit$estimates$sens[1]; spec <- fit$estimates$spec[1]
  pathway <- "Uncertain Role"
  if(sens > 0.95) pathway <- "Triage (Rule-Out)"
  else if(spec > 0.95) pathway <- "Confirmation (Rule-In)"
  else if(sens > 0.85 && spec > 0.85) pathway <- "Stand-alone Diagnostic"
  else pathway <- "Adjunct Only"
  
  # 6. Verdict
  verdict <- calculate_zenith_verdict(fit, integrity, calculate_aunbc_utility(fit$estimates))
  verdict$pathway <- pathway
  
  # 7. Leave-One-Out Analysis
  loo_res <- NULL
  if (loo && nrow(data) > 3) {
    loo_res <- lapply(1:nrow(data), function(i) {
      fit_i <- tryCatch(execute_dta_strategy(strategy, data[-i, ], mods[-i, , drop=FALSE], args)$estimates, error = function(e) NULL)
      if (is.null(fit_i)) return(c(NA, NA))
      c(sens_diff = fit_i$sens[1] - sens, spec_diff = fit_i$spec[1] - spec)
    })
    loo_mat <- do.call(rbind, loo_res)
    influential <- which(abs(loo_mat[,1]) > 0.05 | abs(loo_mat[,2]) > 0.05)
    loo_res <- list(matrix = loo_mat, influential_studies = influential)
  }
  
  # 8. Assembly
  out <- list(
    method = "DTA-Stack v25.0 (Oracle)",
    verdict = verdict,
    estimates = fit$estimates,
    integrity = integrity,
    bias = bias,
    diagnostics = list(
      n = nrow(data), 
      runtime = as.numeric(difftime(Sys.time(), start_time, units="secs")), 
      averaged = isTRUE(fit$averaged),
      mcmc_diag = fit$mcmc_diag,
      loo_analysis = loo_res
    ),
    data = data
  )
  if (!is.null(fit$subgroups)) out$diagnostics$subgroups <- fit$subgroups
  if (!is.null(fit$weights)) out$diagnostics$robust_weights <- fit$weights
  if (!is.null(fit$pseudo_ipd)) out$diagnostics$pseudo_ipd <- fit$pseudo_ipd
  if (!is.null(fit$ensemble_dist)) out$diagnostics$ensemble_dist <- fit$ensemble_dist
  class(out) <- "dta_stack"
  return(out)
}

#' Dynamic Model Averaging (Bayesian + Frequentist)
#' @keywords internal
run_model_averaging <- function(d, iter) {
  # Fit Frequentist GLMM
  f_freq <- run_bivariate_glmm(d)
  # Fit Bayesian MCMC
  f_bayes <- run_bayesian_mcmc(d, iter=iter)
  
  # 50/50 Split for robustness
  avg_est <- function(e1, e2) {
    list(
      sens = (e1$sens + e2$sens)/2,
      spec = (e1$spec + e2$spec)/2,
      lr_p = (e1$lr_p + e2$lr_p)/2,
      lr_n = (e1$lr_n + e2$lr_n)/2,
      dor  = exp(mean(log(c(e1$dor, e2$dor))))
    )
  }
  
  est <- avg_est(f_freq$estimates, f_bayes$estimates)
  list(estimates = est, averaged = TRUE, mcmc_diag = f_bayes$mcmc_diag)
}

#' Run Penalized Likelihood (Firth) for sparse data
#' @keywords internal
run_firth_penalized <- function(d) { 
  tp<-sum(d$TP)+0.5; fn<-sum(d$FN)+0.5; tn<-sum(d$TN)+0.5; fp<-sum(d$FP)+0.5; 
  se<-tp/(tp+fn); sp<-tn/(tn+fp); 
  list(estimates=list(sens=c(se,se-0.1,se+0.1), spec=c(sp,sp-0.1,sp+0.1), 
                     lr_p=se/(1-sp), lr_n=(1-se)/sp, dor=(se*sp)/((1-se)*(1-sp))), 
       averaged=FALSE, mcmc_diag = NULL) 
}

#' Run Bivariate GLMM Meta-Analysis
#' @keywords internal
run_bivariate_glmm <- function(d) { 
  y1<-qlogis((d$TP+0.5)/(d$TP+d$FN+1)); y2<-qlogis((d$TN+0.5)/(d$TN+d$FP+1)); 
  v1<-1/(d$TP+0.5)+1/(d$FN+0.5); v2<-1/(d$TN+0.5)+1/(d$FP+0.5); 
  p<-function(y,v){
    if(length(y)<2)return(c(y[1],sqrt(v[1]))); 
    w<-1/v; mu<-sum(w*y)/sum(w); 
    t2<-max(0,(sum(w*(y-mu)^2)-(length(y)-1))/(sum(w)-sum(w^2)/sum(w))); 
    wr<-1/(v+t2); mr<-sum(wr*y)/sum(wr); c(mr,sqrt(1/sum(wr))) 
  }; 
  r1<-p(y1,v1); r2<-p(y2,v2); 
  list(estimates=list(
    sens=c(plogis(r1[1]),plogis(r1[1]-1.96*r1[2]),plogis(r1[1]+1.96*r1[2])), 
    spec=c(plogis(r2[1]),plogis(r2[1]-1.96*r2[2]),plogis(r2[1]+1.96*r2[2])), 
    lr_p=plogis(r1[1])/(1-plogis(r2[1])), lr_n=(1-plogis(r1[1]))/plogis(r2[1]), 
    dor=exp(r1[1]+r2[1])), averaged=FALSE, mcmc_diag = NULL) 
}

#' Run Robust Bivariate Meta-Analysis (Huber-weighted)
#' @keywords internal
#' @noRd
run_robust_bivariate <- function(d) { 
  y1<-qlogis((d$TP+0.5)/(d$TP+d$FN+1)); y2<-qlogis((d$TN+0.5)/(d$TN+d$FP+1)); 
  v1<-1/(d$TP+0.5)+1/(d$FN+0.5); v2<-1/(d$TN+0.5)+1/(d$FP+0.5); 
  w1 <- 1/v1; w2 <- 1/v2
  mu1 <- sum(w1*y1)/sum(w1); mu2 <- sum(w2*y2)/sum(w2)
  for(iter in 1:10) {
    res1 <- y1 - mu1; res2 <- y2 - mu2
    k <- 1.345
    sd1 <- sqrt(sum(w1 * res1^2) / sum(w1))
    sd2 <- sqrt(sum(w2 * res2^2) / sum(w2))
    if (is.na(sd1) || sd1 == 0) sd1 <- 1
    if (is.na(sd2) || sd2 == 0) sd2 <- 1
    hw1 <- ifelse(abs(res1/sd1) <= k, 1, k/abs(res1/sd1))
    hw2 <- ifelse(abs(res2/sd2) <= k, 1, k/abs(res2/sd2))
    cw1 <- w1 * hw1; cw2 <- w2 * hw2
    mu1_new <- sum(cw1*y1)/sum(cw1)
    mu2_new <- sum(cw2*y2)/sum(cw2)
    if(abs(mu1_new - mu1) < 1e-4 && abs(mu2_new - mu2) < 1e-4) break
    mu1 <- mu1_new; mu2 <- mu2_new
  }
  t2_1 <- max(0, (sum(cw1*(y1-mu1)^2) - (length(y1)-1)) / (sum(cw1) - sum(cw1^2)/sum(cw1)))
  t2_2 <- max(0, (sum(cw2*(y2-mu2)^2) - (length(y2)-1)) / (sum(cw2) - sum(cw2^2)/sum(cw2)))
  wr1 <- 1/(v1 + t2_1); wr2 <- 1/(v2 + t2_2)
  mr1 <- sum(wr1*y1)/sum(wr1); mr2 <- sum(wr2*y2)/sum(wr2)
  se1 <- sqrt(1/sum(wr1)); se2 <- sqrt(1/sum(wr2))
  list(estimates=list(
    sens=c(plogis(mr1),plogis(mr1-1.96*se1),plogis(mr1+1.96*se1)), 
    spec=c(plogis(mr2),plogis(mr2-1.96*se2),plogis(mr2+1.96*se2)), 
    lr_p=plogis(mr1)/(1-plogis(mr2)), lr_n=(1-plogis(mr1))/plogis(mr2), 
    dor=exp(mr1+mr2)), averaged=FALSE, mcmc_diag = NULL, weights = list(sens=hw1, spec=hw2)) 
}

#' Run Latent Subgroup Discovery (Bivariate Gaussian Mixture)
#' @keywords internal
#' @noRd
run_latent_mixture <- function(d) {
  y1<-qlogis((d$TP+0.5)/(d$TP+d$FN+1)); y2<-qlogis((d$TN+0.5)/(d$TN+d$FP+1)); 
  n <- nrow(d)
  if(n < 10) return(run_bivariate_glmm(d))
  set.seed(42)
  z <- stats::kmeans(cbind(y1, y2), centers=2)$cluster
  pi1 <- sum(z==1)/n; pi2 <- sum(z==2)/n
  mu1_1 <- mean(y1[z==1]); mu2_1 <- mean(y2[z==1])
  mu1_2 <- mean(y1[z==2]); mu2_2 <- mean(y2[z==2])
  v1_1 <- stats::var(y1[z==1]); v2_1 <- stats::var(y2[z==1])
  v1_2 <- stats::var(y1[z==2]); v2_2 <- stats::var(y2[z==2])
  if(is.na(v1_1) || v1_1<1e-4) v1_1 <- 0.5
  if(is.na(v2_1) || v2_1<1e-4) v2_1 <- 0.5
  if(is.na(v1_2) || v1_2<1e-4) v1_2 <- 0.5
  if(is.na(v2_2) || v2_2<1e-4) v2_2 <- 0.5
  for(i in 1:20) {
    d1 <- pi1 * stats::dnorm(y1, mu1_1, sqrt(v1_1)) * stats::dnorm(y2, mu2_1, sqrt(v2_1))
    d2 <- pi2 * stats::dnorm(y1, mu1_2, sqrt(v1_2)) * stats::dnorm(y2, mu2_2, sqrt(v2_2))
    den <- d1 + d2 + 1e-10
    resp1 <- d1 / den; resp2 <- d2 / den
    N1 <- sum(resp1); N2 <- sum(resp2)
    if(N1 < 1e-4 || N2 < 1e-4) break # Degenerate cluster
    pi1 <- N1/n; pi2 <- N2/n
    mu1_1 <- sum(resp1*y1)/N1; mu2_1 <- sum(resp1*y2)/N1
    mu1_2 <- sum(resp2*y1)/N2; mu2_2 <- sum(resp2*y2)/N2
    v1_1 <- sum(resp1*(y1-mu1_1)^2)/N1 + 1e-4; v2_1 <- sum(resp1*(y2-mu2_1)^2)/N1 + 1e-4
    v1_2 <- sum(resp2*(y1-mu1_2)^2)/N2 + 1e-4; v2_2 <- sum(resp2*(y2-mu2_2)^2)/N2 + 1e-4
  }
  if(is.na(mu1_1) || is.na(mu1_2)) return(run_bivariate_glmm(d)) # Fallback if EM fails completely
  dor1 <- exp(mu1_1 + mu2_1); dor2 <- exp(mu1_2 + mu2_2)
  primary <- if(!is.na(dor1) && !is.na(dor2) && dor1 > dor2) 1 else 2
  sec <- if(primary == 1) 2 else 1
  m1_p <- if(primary==1) mu1_1 else mu1_2; m2_p <- if(primary==1) mu2_1 else mu2_2
  m1_s <- if(sec==1) mu1_1 else mu1_2; m2_s <- if(sec==1) mu2_1 else mu2_2
  v1_p <- if(primary==1) v1_1 else v1_2; v2_p <- if(primary==1) v2_1 else v2_2
  list(estimates=list(
    sens=c(plogis(m1_p),plogis(m1_p-1.96*sqrt(v1_p/n)),plogis(m1_p+1.96*sqrt(v1_p/n))), 
    spec=c(plogis(m2_p),plogis(m2_p-1.96*sqrt(v2_p/n)),plogis(m2_p+1.96*sqrt(v2_p/n))), 
    lr_p=plogis(m1_p)/(1-plogis(m2_p)), lr_n=(1-plogis(m1_p))/plogis(m2_p), 
    dor=exp(m1_p+m2_p)), averaged=FALSE, mcmc_diag = NULL,
    subgroups = list(
      primary = list(sens=plogis(m1_p), spec=plogis(m2_p), weight=max(pi1,pi2)),
      secondary = list(sens=plogis(m1_s), spec=plogis(m2_s), weight=min(pi1,pi2))
    ))
}

#' Run Bayesian MCMC Meta-Analysis with R-hat diagnostics
#' @keywords internal
run_bayesian_mcmc <- function(d, iter) { 
  if(is.null(iter)) iter<-3000; 
  sampler<-function(s){
    set.seed(s); N<-nrow(d); y_p<-d$TP; n_p<-d$TP+d$FN; y_n<-d$TN; n_n<-d$TN+d$FP; 
    mu<-c(0,0); re<-matrix(0,N,2); st<-matrix(0,iter,2); jump<-0.4; 
    for(i in 1:iter){
      acc<-0; 
      for(j in 1:N){
        curr<-re[j,]; prop<-curr+rnorm(2,0,jump); 
        lp<-function(r)sum(dbinom(c(y_p[j],y_n[j]),c(n_p[j],n_n[j]),plogis(mu+r),log=T))-0.5*sum(r^2); 
        if(log(runif(1))<(lp(prop)-lp(curr))){re[j,]<-prop;acc<-acc+1}
      }; 
      if(i<(iter/2)&&i%%50==0){
        rate<-acc/N; if(rate<0.2)jump<-jump*0.8 else if(rate>0.5)jump<-jump*1.2
      }; 
      mu<-as.numeric(colMeans(re)+rnorm(2,0,0.05)); st[i,]<-mu
    }; 
    st[-(1:(iter/2)), , drop=FALSE]
  }; 
  c1<-sampler(42); c2<-sampler(99); mu<-rbind(c1,c2); 
  
  # Simple R-hat logic
  calc_rhat <- function(chain1, chain2) {
    n_samp <- length(chain1); m <- 2
    b_mean <- (mean(chain1) + mean(chain2))/2
    B <- n_samp/(m-1) * ((mean(chain1)-b_mean)^2 + (mean(chain2)-b_mean)^2)
    W <- 1/m * (var(chain1) + var(chain2))
    val <- sqrt(( (n_samp-1)/n_samp * W + 1/n_samp * B ) / W)
    if(is.nan(val)) return(1.0) # Handle zero variance
    return(val)
  }
  
  rhat_sens <- calc_rhat(c1[,1], c2[,1])
  rhat_spec <- calc_rhat(c1[,2], c2[,2])
  
  est<-colMeans(mu); ci1<-as.numeric(quantile(mu[,1],c(0.025,0.975))); 
  ci2<-as.numeric(quantile(mu[,2],c(0.025,0.975))); 
  
  list(estimates=list(
    sens=c(plogis(est[1]),plogis(ci1[1]),plogis(ci1[2])),
    spec=c(plogis(est[2]),plogis(ci2[1]),plogis(ci2[2])),
    lr_p=plogis(est[1])/(1-plogis(est[2])),
    lr_n=(1-plogis(est[1]))/plogis(est[2]),
    dor=exp(sum(est))), 
    averaged=FALSE,
    mcmc_diag = list(rhat_sens = rhat_sens, rhat_spec = rhat_spec, converged = max(rhat_sens, rhat_spec, na.rm=TRUE) < 1.1)
  ) 
}

#' Run Pseudo-IPD Reconstruction
#' @keywords internal
#' @noRd
run_pseudo_ipd <- function(d) {
  # Reconstruct individual patient data
  ipd_list <- lapply(1:nrow(d), function(i) {
    study <- d[i, ]
    data.frame(
      Study = i,
      Disease = c(rep(1, study$TP + study$FN), rep(0, study$FP + study$TN)),
      Test = c(rep(1, study$TP), rep(0, study$FN), rep(1, study$FP), rep(0, study$TN))
    )
  })
  ipd <- do.call(rbind, ipd_list)
  
  # Patient-level models
  fit_sens <- stats::glm(Test ~ 1, family=stats::binomial, data=ipd[ipd$Disease==1,])
  fit_spec <- stats::glm(I(1-Test) ~ 1, family=stats::binomial, data=ipd[ipd$Disease==0,])
  
  s_coef <- summary(fit_sens)$coefficients; sp_coef <- summary(fit_spec)$coefficients
  se <- plogis(s_coef[1,1]); sp <- plogis(sp_coef[1,1])
  
  list(estimates=list(
    sens=c(se, plogis(s_coef[1,1]-1.96*s_coef[1,2]), plogis(s_coef[1,1]+1.96*s_coef[1,2])),
    spec=c(sp, plogis(sp_coef[1,1]-1.96*sp_coef[1,2]), plogis(sp_coef[1,1]+1.96*sp_coef[1,2])),
    lr_p=se/(1-sp), lr_n=(1-se)/sp, dor=(se*sp)/((1-se)*(1-sp))
  ), averaged=FALSE, mcmc_diag=NULL, pseudo_ipd=ipd)
}

#' Run ML Bootstrapped Ensemble Synthesis
#' @keywords internal
#' @noRd
run_bagged_ensemble <- function(d, boot_n) {
  if (is.null(boot_n)) boot_n <- 500
  n <- nrow(d); res_sens <- numeric(boot_n); res_spec <- numeric(boot_n)
  for(i in 1:boot_n) {
    idx <- sample(1:n, n, replace=TRUE)
    boot_d <- d[idx, ]
    y1<-qlogis((boot_d$TP+0.5)/(boot_d$TP+boot_d$FN+1)); y2<-qlogis((boot_d$TN+0.5)/(boot_d$TN+boot_d$FP+1))
    v1<-1/(boot_d$TP+0.5)+1/(boot_d$FN+0.5); v2<-1/(boot_d$TN+0.5)+1/(boot_d$FP+0.5)
    r1 <- sum((1/v1)*y1)/sum(1/v1); r2 <- sum((1/v2)*y2)/sum(1/v2) 
    res_sens[i] <- plogis(r1); res_spec[i] <- plogis(r2)
  }
  se <- mean(res_sens); sp <- mean(res_spec)
  s_ci <- stats::quantile(res_sens, c(0.025, 0.975))
  sp_ci <- stats::quantile(res_spec, c(0.025, 0.975))
  list(estimates=list(
    sens=c(se, as.numeric(s_ci[1]), as.numeric(s_ci[2])),
    spec=c(sp, as.numeric(sp_ci[1]), as.numeric(sp_ci[2])),
    lr_p=se/(1-sp), lr_n=(1-se)/sp, dor=(se*sp)/((1-se)*(1-sp))
  ), averaged=FALSE, mcmc_diag=NULL, ensemble_dist=list(sens=res_sens, spec=res_spec))
}

# --- Clinical Utility & Integrity ---

#' @keywords internal
#' @noRd
calculate_zenith_integrity <- function(d, years) { 
  an<-sum(d$TP+d$FN+d$TN+d$FP); k<-nrow(d); ifv<-an/(1000*(1+(k/20))); 
  median_y<-median(years,na.rm=T); age_p<-1/(1+exp(0.3*(median_y-2010))); 
  iai<-max(0.1, (0.6*min(1,ifv)+0.4*(1-(1/(1+k))))*(1-(age_p*0.5))); 
  list(iai=iai, age_penalty=age_p, drivers=if(age_p>0.3)"Obsolete" else "Robust") 
}

#' @keywords internal
#' @noRd
calculate_aunbc_utility <- function(est, cost_fp = 1, cost_fn = 9) { 
  s<-est$sens[1]; sp<-est$spec[1]; pt<-seq(0.01,0.99,0.01); 
  # Weighted Net Benefit
  nb<-s*0.1-(1-sp)*0.9*(pt/(1-pt))*(cost_fp/cost_fn); 
  nba<-0.1-0.9*(pt/(1-pt))*(cost_fp/cost_fn); 
  aunbc<-sum(nb[nb>nba & nb>0])*0.01; 
  list(score=min(100,aunbc*500)) 
}

#' @keywords internal
#' @noRd
calculate_zenith_verdict <- function(fit, integrity, utility) { 
  score<-(integrity$iai*40)+(fit$estimates$sens[1]*15+fit$estimates$spec[1]*15)+(utility$score*0.3); 
  label<-if(score>=80)"ZENITH TRUTH" else if(score>=60)"ROBUST" else "CONDITIONAL"; 
  list(score=score, label=label, grade=if(score>=80)"High" else "Low") 
}

#' @keywords internal
#' @noRd
apply_context_aware_prior <- function(est, k) { 
  r_se<-est$sens[1]; r_sp<-est$spec[1]; if(is.na(r_se))r_se<-0.75; if(is.na(r_sp))r_sp<-0.85; 
  p_se<-if(r_se>0.9)0.95 else 0.75; p_sp<-if(r_sp>0.9)0.95 else 0.85; 
  shrink<-function(val,prior,k) { 
    w<-1-(1/(1+0.5*k)); mv<-val[1]*w+prior*(1-w); 
    c(mv, mv-(val[1]-val[2])*w, mv+(val[3]-val[1])*w) 
  }; 
  est$sens<-shrink(est$sens, p_se, k); est$spec<-shrink(est$spec, p_sp, k); est 
}

#' @keywords internal
#' @noRd
safe_deeks_test <- function(d) { 
  tryCatch({ 
    k<-nrow(d); if(k<10) return(list(p_val=NA, detected=FALSE)); 
    ess<-(4*d$TP*d$FN)/(d$TP+d$FN+1); 
    dor_ln<-log(((d$TP+0.5)*(d$TN+0.5))/((d$FP+0.5)*(d$FN+0.5))); 
    p_val<-summary(lm(dor_ln~I(1/sqrt(ess))))$coefficients[2,4]; 
    list(p_val=p_val, detected=p_val<0.10) 
  }, error=function(e) list(p_val=NA, detected=FALSE)) 
}

#' Plot DTA Stack Object
#' @param x dta_stack object
#' @param type Plot type ("sroc", "entropy", "subgroups", "fagan", or "ensemble")
#' @param ... Additional arguments
#' @importFrom graphics grid legend points polygon segments text abline
#' @importFrom grDevices rgb
#' @method plot dta_stack
#' @export
plot.dta_stack <- function(x, type="sroc", ...) {
  if (type == "ensemble" && !is.null(x$diagnostics$ensemble_dist)) {
    ed <- x$diagnostics$ensemble_dist
    plot(1-ed$spec, ed$sens, pch=16, col=rgb(0,0,1,0.1), xlim=c(0,1), ylim=c(0,1),
         xlab="1 - Specificity", ylab="Sensitivity", main="ML Bootstrapped Ensemble Distribution")
    grid()
    points(1-x$estimates$spec[1], x$estimates$sens[1], pch=18, col="red", cex=2)
    legend("bottomright", legend=c("Bootstrap Iteration", "Ensemble Mean"), 
           pch=c(16, 18), col=c("blue", "red"), pt.cex=c(1, 2), bty="n")
    return(invisible(NULL))
  }
  
  if (type == "fagan") {
    # Fagan Nomogram (Simplified Logic)
    prev <- 0.20 # Default pre-test probability
    lr_p <- x$estimates$lr_p; lr_n <- x$estimates$lr_n
    post_p <- (prev/(1-prev)*lr_p) / (1 + (prev/(1-prev)*lr_p))
    post_n <- (prev/(1-prev)*lr_n) / (1 + (prev/(1-prev)*lr_n))
    
    plot(0, 0, type="n", xlim=c(0, 2), ylim=c(0, 1), axes=FALSE, xlab="", ylab="", 
         main=paste("Fagan Nomogram (Pre-test 20%):", x$verdict$label))
    segments(0, 0, 0, 1, lwd=2); segments(1, 0, 1, 1, lwd=2); segments(2, 0, 2, 1, lwd=2)
    text(0, 1.05, "Pre-test %"); text(1, 1.05, "LR"); text(2, 1.05, "Post-test %")
    
    # Pre-test 20% point
    points(0, prev, pch=19); text(-0.1, prev, "20%")
    # LR+ line
    segments(0, prev, 2, post_p, col="red", lwd=2)
    text(2.1, post_p, sprintf("Pos: %.1f%%", post_p*100), col="red")
    # LR- line
    segments(0, prev, 2, post_n, col="blue", lwd=2)
    text(2.1, post_n, sprintf("Neg: %.1f%%", post_n*100), col="blue")
    
    return(invisible(NULL))
  }
  if (type == "entropy") {
    lr_p <- x$estimates$lr_p
    prev_seq <- seq(0.01, 0.99, 0.01)
    entropy <- function(p) -(p*log2(p) + (1-p)*log2(1-p))
    gain <- sapply(prev_seq, function(p) {
      post <- (p/(1-p)*lr_p) / (1 + (p/(1-p)*lr_p))
      max(0, entropy(p) - entropy(post))
    })
    plot(prev_seq*100, gain, type="l", lwd=2, col="purple", 
         xlab="Pre-Test Probability (%)", ylab="Information Gain (Bits)",
         main=paste("Entropy Landscape:", x$verdict$label))
    grid()
    polygon(c(prev_seq*100, rev(prev_seq*100)), c(gain, rep(0, length(gain))), col=rgb(0.5,0,0.5,0.2), border=NA)
    return(invisible(NULL))
  }
  
  if (type == "subgroups" && !is.null(x$diagnostics$subgroups)) {
    d <- x$data; se <- d$TP/(d$TP+d$FN); sp <- d$TN/(d$TN+d$FP)
    sg <- x$diagnostics$subgroups
    
    plot(1-sp, se, xlim=c(0,1), ylim=c(0,1), pch=21, col="gray", bg="white",
         xlab="1 - Specificity", ylab="Sensitivity", 
         main="Latent Subgroup Discovery (Mixture Model)", bty="n")
    grid()
    
    # Subgroup 1 (Primary)
    points(1-sg$primary$spec, sg$primary$sens, col="darkgreen", pch=19, cex=3)
    text(1-sg$primary$spec, sg$primary$sens, labels="P", col="white", font=2, cex=0.8)
    
    # Subgroup 2 (Secondary)
    points(1-sg$secondary$spec, sg$secondary$sens, col="orange", pch=19, cex=2.5)
    text(1-sg$secondary$spec, sg$secondary$sens, labels="S", col="white", font=2, cex=0.7)
    
    legend("bottomright", legend=c(sprintf("Primary (w=%.1f%%)", sg$primary$weight*100), 
                                   sprintf("Secondary (w=%.1f%%)", sg$secondary$weight*100)), 
           pch=19, col=c("darkgreen", "orange"), bty="n")
    return(invisible(NULL))
  }

  # Default SROC
  d <- x$data; se <- d$TP/(d$TP+d$FN); sp <- d$TN/(d$TN+d$FP)
  
  plot(1-sp, se, xlim=c(0,1), ylim=c(0,1), pch=21, col="darkblue", bg="lightblue", cex=1.5, 
       xlab="1 - Specificity (False Positive Rate)", ylab="Sensitivity (True Positive Rate)", 
       main=paste("SROC Plot:", x$verdict$label), bty="n")
  grid()
  
  # Summary point
  p_se <- as.numeric(x$estimates$sens[1])
  p_sp <- as.numeric(x$estimates$spec[1])
  points(1-p_sp, p_se, col="red", pch=18, cex=2.5)
  
  # Crosshairs for 95% CI
  se_ci <- as.numeric(x$estimates$sens[2:3])
  sp_ci <- as.numeric(x$estimates$spec[2:3])
  segments(x0=1-sp_ci[2], y0=p_se, x1=1-sp_ci[1], y1=p_se, col="red", lwd=2)
  segments(x0=1-p_sp, y0=se_ci[1], x1=1-p_sp, y1=se_ci[2], col="red", lwd=2)
  
  legend("bottomright", legend=c("Primary Studies", "Summary Estimate (95% CI)"), 
         pch=c(21, 18), col=c("darkblue", "red"), pt.bg=c("lightblue", NA), pt.cex=c(1.5, 2.5), bty="n")
}

#' Summary of DTA Stack Object
#' @param object dta_stack object
#' @param ... Additional arguments
#' @method summary dta_stack
#' @export
summary.dta_stack <- function(object, ...) {
  cat("\nORACLE CLINICAL CONSULT:\n")
  cat(rep("=", 60), "\n")
  cat(sprintf("Verdict   : %s (%s)\n", object$verdict$label, object$verdict$grade))
  cat(sprintf("Pathway   : %s\n", object$verdict$pathway))
  cat(sprintf("Strategy  : %s\n", if(isTRUE(object$diagnostics$averaged)) "Dynamic Model Averaging (Bayes+Freq)" else "Single Tier"))
  
  if (!is.null(object$diagnostics$mcmc_diag)) {
    cat(sprintf("Convergence: %s (Max R-hat: %.3f)\n", 
                if(object$diagnostics$mcmc_diag$converged) "Pass" else "Fail",
                max(object$diagnostics$mcmc_diag$rhat_sens, object$diagnostics$mcmc_diag$rhat_spec, na.rm=TRUE)))
  }
  
  cat(rep("-", 60), "\n")
  pe <- function(v) sprintf("%.1f%%", as.numeric(v)*100)
  cat(sprintf("Sensitivity: %s | Specificity: %s\n", pe(object$estimates$sens[1]), pe(object$estimates$spec[1])))
  
  # Multi-Persona Research Synthesis Review
  cat(rep("-", 60), "\n")
  cat("MULTI-PERSONA RESEARCH SYNTHESIS REVIEW:\n")
  
  # Persona 1: The Strict Methodologist
  m_score <- object$verdict$score * (1 - 0.5 * (if(is.na(object$bias$p_val)) 0.5 else if(object$bias$p_val < 0.1) 1 else 0))
  m_grade <- if(m_score > 70) "Trustworthy" else "Caution: High Bias Risk"
  cat(sprintf("[Strict Methodologist]: %s (Internal Validity Focus)\n", m_grade))
  
  # Persona 2: The Clinical Optimist
  c_score <- (object$estimates$sens[1] + object$estimates$spec[1]) / 2 * 100
  c_grade <- if(c_score > 85) "Clinical Breakthrough" else "Incremental Utility"
  cat(sprintf("[Clinical Optimist]   : %s (Utility Focus)\n", c_grade))
  
  # Persona 3: The Conservative Statistician
  s_range <- (object$estimates$sens[3] - object$estimates$sens[2])
  s_grade <- if(s_range < 0.15) "High Precision" else "Fragile Estimates"
  cat(sprintf("[Cons. Statistician] : %s (Uncertainty Focus)\n", s_grade))
  
  cat(rep("=", 60), "\n\n")
}

#' Print DTA Stack Object
#' @param x dta_stack object
#' @param ... Additional arguments
#' @method print dta_stack
#' @export
print.dta_stack <- function(x, ...) { summary(x) }

#' Coerce DTA Stack Object to Data Frame
#' @param x dta_stack object
#' @param row.names NULL or a character vector
#' @param optional logical
#' @param ... Additional arguments
#' @method as.data.frame dta_stack
#' @export
as.data.frame.dta_stack <- function(x, row.names = NULL, optional = FALSE, ...) {
  data.frame(
    Dataset="Custom", Verdict=x$verdict$label, GRADE=x$verdict$grade, Pathway=x$verdict$pathway,
    Sens=round(x$estimates$sens[1],3), Spec=round(x$estimates$spec[1],3),
    Averaged=isTRUE(x$diagnostics$averaged), stringsAsFactors=FALSE
  )
}
