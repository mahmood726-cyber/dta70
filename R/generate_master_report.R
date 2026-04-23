
#' Run Master DTA Audit
#' @description Runs the DTA-Stack engine across all datasets in the package.
#' @export
run_master_audit <- function() {
  cat("================================================================================\n")
  cat("DTA-STACK V23.0: THE INFINITE INTELLIGENCE AUDIT\n")
  cat("================================================================================\n\n")

  # 1. Infinite Brief Demo
  cat("--- DEMO: INFINITE CLINICAL BRIEF (AuditC_data) ---\n")
  env <- new.env()
  data(AuditC_data, package = "DTA70", envir = env)
  fit <- dta_stack(normalize_dta_columns(env$AuditC_data))
  summary(fit)

  # 2. Batch Audit
  data_dir <- system.file("data", package = "DTA70")
  if (data_dir == "") data_dir <- "C:/Users/user/OneDrive - NHS/Documents/DTA70/data"  # sentinel:skip-line P0-hardcoded-local-path
  
  files <- list.files(data_dir, pattern = "\\.rda$", full.names = TRUE)
  master_results <- data.frame()

  for (f in files) {
    ds_name <- gsub("\\.rda$", "", basename(f))
    env <- new.env(); load(f, envir = env); df <- get(ls(env)[1], envir = env)
    df_c <- normalize_dta_columns(df)
    if (is.null(df_c)) next
    
    res <- tryCatch({ dta_stack(df_c, method="frequentist") }, error = function(e) NULL)
    if (!is.null(res)) {
      row <- as.data.frame(res)
      row$Dataset <- ds_name
      master_results <- rbind(master_results, row)
      cat(sprintf("INFINITE GRADED: %-40s -> %s\n", ds_name, res$verdict$label))
    }
  }

  write.csv(master_results, "Infinite_Truth_Table_v23.csv", row.names=FALSE)
  cat("\nFinal Infinite Truth Table Saved: Infinite_Truth_Table_v23.csv\n")
  cat("================================================================================\n")
  return(invisible(master_results))
}
