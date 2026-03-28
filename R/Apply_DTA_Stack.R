#' DTA-Stack: External Model Applicator
#'
#' @description
#' Applies the DTA-Stack v5.1 Adaptive Engine to all datasets in a specified external directory.
#'
#' @param input_dir Directory containing .csv or .rds files with (TP, FN, FP, TN) columns.
#' @param output_dir Directory to save results (defaults to input_dir/results).
#'
#' @export
process_model_directory <- function(input_dir, output_dir = NULL) {
  
  if (!dir.exists(input_dir)) stop("Input directory not found.")
  if (is.null(output_dir)) output_dir <- file.path(input_dir, "results")
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  
  files <- list.files(input_dir, pattern = "\\.(csv|rds)$", full.names = TRUE)
  cat(sprintf("Found %d datasets in %s\n", length(files), input_dir))
  
  results_log <- data.frame()
  
  for (f in files) {
    fname <- basename(f)
    cat(sprintf("\nProcessing: %s ...\n", fname))
    
    # Load Data
    tryCatch({
      if (grepl("\\.csv$", f)) raw <- read.csv(f)
      else raw <- readRDS(f)
      
      # Validate Columns
      req <- c("TP", "FN", "FP", "TN")
      if (!all(req %in% names(raw))) {
        cat("  SKIPPED: Missing TP, FN, FP, TN columns.\n")
        next
      }
      
      # Run DTA-Stack (Auto Mode)
      fit <- dta_stack(raw)
      
      # Save Summary
      est <- fit$estimates
      res_row <- data.frame(
        File = fname,
        Studies = fit$diagnostics$n,
        Sens = est$sens[1], Sens_LB = est$sens[2], Sens_UB = est$sens[3],
        Spec = est$spec[1], Spec_LB = est$spec[2], Spec_UB = est$spec[3],
        DOR = est$dor,
        Runtime = fit$diagnostics$runtime
      )
      results_log <- rbind(results_log, res_row)
      
      # Save Detailed Object
      saveRDS(fit, file.path(output_dir, paste0("fit_", fname, ".rds")))
      
      # Save Plot
      png(file.path(output_dir, paste0("plot_", fname, ".png")), width=600, height=600)
      plot(fit)
      dev.off()
      
      cat(sprintf("  SUCCESS: (Sens: %.1f%%, Spec: %.1f%%)\n", 
                  est$sens[1]*100, est$spec[1]*100))
      
    }, error = function(e) {
      cat(sprintf("  ERROR: %s\n", e$message))
    })
  }
  
  # Save Master Log
  write.csv(results_log, file.path(output_dir, "DTA_Stack_Summary.csv"), row.names = FALSE)
  cat(sprintf("\nDone. Results saved to %s\n", output_dir))
  return(results_log)
}
