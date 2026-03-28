#' Debug DTA-Stack V9
#' @keywords internal
debug_dta_stack_v9 <- function() {
  f <- system.file("data/AuditC_data.rda", package = "DTA70")
  if (f == "") f <- "C:/Users/user/OneDrive - NHS/Documents/DTA70/data/AuditC_data.rda"
  
  if (!file.exists(f)) return(message("Data file not found"))
  
  env <- new.env(); load(f, envir = env); df <- get(ls(env)[1], envir = env)
  df_clean <- normalize_dta_columns(df)

  cat("Testing AuditC_data with method='frequentist'...\n")
  tryCatch({
    fit <- dta_stack(df_clean, method="frequentist")
    print(fit)
  }, error = function(e) {
    cat("ERROR CAUGHT:\n")
    print(e)
  })
}
