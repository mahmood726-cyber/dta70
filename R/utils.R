#' Universal DTA Column Normalizer
#' @description Maps diverse column naming conventions to standard TP, FN, FP, TN.
#' @param df A data frame with columns representing diagnostic accuracy counts.
#' @export
normalize_dta_columns <- function(df) {
  cols <- names(df)
  
  # 1. Standard Mapping
  if (all(c("TP", "FN", "FP", "TN") %in% cols)) return(df)
  
  # 2. Case-Insensitive Check
  if (all(c("tp", "fn", "fp", "tn") %in% tolower(cols))) {
    df_new <- df
    names(df_new) <- toupper(names(df_new))
    return(df_new)
  }
  
  # 3. Deep Probe: Cochrane/Pairwise Export Mapping
  # Many DTA datasets in Cochrane are exported with these names:
  # TP = Experimental.cases
  # FN = Experimental.N - Experimental.cases
  # FP = Control.cases
  # TN = Control.N - Control.cases
  
  if (all(c("Experimental.cases", "Experimental.N", "Control.cases", "Control.N") %in% cols)) {
    df_norm <- data.frame(
      TP = df$Experimental.cases,
      FN = df$Experimental.N - df$Experimental.cases,
      FP = df$Control.cases,
      TN = df$Control.N - df$Control.cases
    )
    # Check for consistency
    if (any(df_norm < 0, na.rm=TRUE)) return(NULL)
    return(df_norm)
  }
  
  # 4. Alternative: events1, n1 style
  if (all(c("events1", "n1", "events2", "n2") %in% cols)) {
    return(data.frame(TP=df$events1, FN=df$n1-df$events1, FP=df$events2, TN=df$n2-df$events2))
  }

  return(NULL)
}
