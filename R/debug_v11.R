#' Debug DTA-Stack V11
#' @keywords internal
debug_dta_stack_v11 <- function() {
  cat("DEBUG V11.0: AuditC_data\n")
  f <- system.file("data/AuditC_data.rda", package = "DTA70")
  if (f == "") f <- "C:/Users/user/OneDrive - NHS/Documents/DTA70/data/AuditC_data.rda"
  
  if (!file.exists(f)) return(message("Data file not found"))
  
  env <- new.env(); load(f, envir = env); df <- get(ls(env)[1], envir = env)
  df_clean <- normalize_dta_columns(df)

  if(is.null(df_clean)) stop("Normalization failed")

  tryCatch({
    fit <- dta_stack(df_clean)
    print(fit)
  }, error = function(e) {
    cat("ERROR:\n")
    print(e)
    cat("Running tier1 explicitly...\n")
    print(dta_stack(df_clean, method="tier1_firth"))
  })
}
