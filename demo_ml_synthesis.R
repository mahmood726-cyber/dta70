devtools::load_all(".")

cat("=======================================================
")
cat("ADVANCED ML SYNTHESIS DEMO: AuditC Dataset
")
cat("=======================================================

")

env <- new.env()
data(AuditC_data, package = "DTA70", envir = env)
dta_data <- normalize_dta_columns(env$AuditC_data)

# 1. IPD Reconstruction Model
cat("--- Method 1: Patient-Level IPD Reconstruction ---
")
fit_ipd <- dta_stack(dta_data, method="ipd")
cat(sprintf("Reconstructed %d virtual patients across %d primary studies.
", 
            nrow(fit_ipd$diagnostics$pseudo_ipd), nrow(dta_data)))
summary(fit_ipd)

# 2. Machine Learning Bootstrapped Ensemble
cat("
--- Method 2: ML Bootstrapped Ensemble Synthesis ---
")
fit_ens <- dta_stack(dta_data, method="ensemble", boot_n = 2000)
summary(fit_ens)

# Render Plot (Commented out for CLI run, but available)
# plot(fit_ens, type="ensemble")
