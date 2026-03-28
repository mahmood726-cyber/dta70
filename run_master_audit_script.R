devtools::load_all(".")

cat("Starting Master Audit...\n")
res <- run_master_audit()
cat("Master Audit Completed.\n")

# Let's print the multi-persona review for a couple of datasets to show it off
env <- new.env()
data(AuditC_data, package = "DTA70", envir = env)

fit1 <- dta_stack(normalize_dta_columns(env$AuditC_data), method="mixture")

cat("\n=======================================================\n")
cat("MULTI-PERSONA REVIEW DEMO: AuditC Dataset (Mixture Method)\n")
cat("=======================================================\n")
summary(fit1)

cat("\n=======================================================\n")
cat("MULTI-PERSONA REVIEW DEMO: AuditC Dataset (Robust Method)\n")
cat("=======================================================\n")
fit2 <- dta_stack(normalize_dta_columns(env$AuditC_data), method="robust")
summary(fit2)
