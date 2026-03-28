
library(tidyverse)
results <- readRDS("dta_methods_research/results/raw/mada_methods_results.rds")
summary_results <- results %>%
  group_by(method) %>%
  summarise(
    n = n(),
    conv_rate = mean(converged, na.rm = TRUE),
    mean_runtime = mean(runtime_seconds, na.rm = TRUE),
    mean_sens = mean(pooled_sens, na.rm = TRUE),
    mean_spec = mean(pooled_spec, na.rm = TRUE)
  )
print(summary_results)
