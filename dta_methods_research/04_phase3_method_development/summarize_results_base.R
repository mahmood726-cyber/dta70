
results <- readRDS("dta_methods_research/results/raw/mada_methods_results.rds")
# Use base R to summarize
methods <- unique(results$method)
summary_list <- lapply(methods, function(m) {
  subset_data <- results[results$method == m, ]
  data.frame(
    method = m,
    n = nrow(subset_data),
    conv_rate = mean(subset_data$converged, na.rm = TRUE),
    mean_runtime = mean(subset_data$runtime_seconds, na.rm = TRUE),
    mean_sens = mean(as.numeric(subset_data$pooled_sens), na.rm = TRUE),
    mean_spec = mean(as.numeric(subset_data$pooled_spec), na.rm = TRUE)
  )
})
summary_df <- do.call(rbind, summary_list)
print(summary_df)
