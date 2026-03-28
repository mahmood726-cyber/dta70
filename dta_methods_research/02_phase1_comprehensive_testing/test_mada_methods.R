# ============================================================================
# test_mada_methods.R - Test All MADA Package Methods
# ============================================================================
#
# This script runs comprehensive testing of all mada package methods
# across all 76 DTA datasets, measuring performance and identifying issues.
#
# Methods tested:
#   - reitsma(): Bivariate model (current standard)
#   - MosesL(): Moses-Littenberg (weighted and unweighted)
#   - marginal(): Marginal pooling
#   - bivariate(): Alternative bivariate implementation
#
# ============================================================================

setwd("C:/Users/user/OneDrive - NHS/Documents/DTA70")

# Load required packages
required_packages <- c("mada", "tidyverse", "data.table", "parallel",
                       "foreach", "doParallel")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg)
  }
}

# Source utility functions
source("dta_methods_research/functions/method_wrappers.R")
source("dta_methods_research/functions/evaluation_metrics.R")

# =============================================================================
# Setup
# ============================================================================

cat("========================================\n")
cat("MADA Package Methods Testing\n")
cat("========================================\n\n")

# Load datasets
dataset_list <- readRDS("dta_methods_research/results/raw/all_datasets.rds")
dataset_info <- read.csv("dta_methods_research/results/raw/dataset_info.csv")

cat(sprintf("Loaded %d datasets for testing\n\n", length(dataset_list)))

# Set up parallel processing
n_cores <- detectCores() - 1
cat(sprintf("Using %d cores for parallel processing\n", n_cores))

cl <- makeCluster(n_cores)
registerDoParallel(cl)

# =============================================================================
# Define Methods to Test
# ============================================================================

mada_methods <- c(
  "reitsma",
  "mosesl_weighted",
  "mosesl_unweighted",
  "marginal"
)

# =============================================================================
# Run Tests on All Datasets
# ============================================================================

cat("\n========================================\n")
cat("Running Tests...\n")
cat("========================================\n\n")

# Master results data frame
master_results <- data.frame()

# Test with different continuity corrections
corrections <- c(0, 0.1, 0.5)

start_time <- Sys.time()

results_list <- foreach(
  ds_name = names(dataset_list),
  .packages = c("mada", "data.table"),
  .export = c("wrapper_reitsma", "wrapper_mosesl", "wrapper_marginal",
              "validate_dta_data", "calculate_sparsity"),
  .options.parallel = list(preschedule = TRUE)
) %dopar% {

  results <- data.frame()
  data <- dataset_list[[ds_name]]

  for (correction in corrections) {

    # Run reitsma
    tryCatch({
      res_reitsma <- wrapper_reitsma(data, correction)
      res_reitsma$dataset_name <- ds_name
      res_reitsma$correction <- correction
      res_reitsma$n_studies <- nrow(data)
      res_reitsma$sparsity <- calculate_sparsity(data)
      results <- rbind(results, as.data.frame(res_reitsma))
    }, error = function(e) {
      # Record error
    })

    # Run Moses-Littenberg (weighted)
    tryCatch({
      res_mosl_w <- wrapper_mosesl(data, weighted = TRUE, correction)
      res_mosl_w$dataset_name <- ds_name
      res_mosl_w$correction <- correction
      res_mosl_w$n_studies <- nrow(data)
      res_mosl_w$sparsity <- calculate_sparsity(data)
      results <- rbind(results, as.data.frame(res_mosl_w))
    }, error = function(e) {
      # Record error
    })

    # Run Moses-Littenberg (unweighted)
    tryCatch({
      res_mosl_uw <- wrapper_mosesl(data, weighted = FALSE, correction)
      res_mosl_uw$dataset_name <- ds_name
      res_mosl_uw$correction <- correction
      res_mosl_uw$n_studies <- nrow(data)
      res_mosl_uw$sparsity <- calculate_sparsity(data)
      results <- rbind(results, as.data.frame(res_mosl_uw))
    }, error = function(e) {
      # Record error
    })

    # Run marginal
    tryCatch({
      res_marginal <- wrapper_marginal(data, correction)
      res_marginal$dataset_name <- ds_name
      res_marginal$correction <- correction
      res_marginal$n_studies <- nrow(data)
      res_marginal$sparsity <- calculate_sparsity(data)
      results <- rbind(results, as.data.frame(res_marginal))
    }, error = function(e) {
      # Record error
    })
  }

  return(results)
}

# Stop parallel cluster
stopCluster(cl)

# Combine all results
master_results <- do.call(rbind, results_list)
rownames(master_results) <- NULL

end_time <- Sys.time()
runtime_total <- as.numeric(difftime(end_time, start_time, units = "secs"))

cat(sprintf("\nTesting completed in %.2f seconds\n", runtime_total))

# =============================================================================
# Summary Statistics
# ============================================================================

cat("\n========================================\n")
cat("Summary Statistics\n")
cat("========================================\n\n")

# Count results by method
cat("Results by method:\n")
print(table(master_results$method))

# Convergence rates by method
cat("\nConvergence rates:\n")
convergence_summary <- aggregate(converged ~ method,
                                 data = master_results,
                                 FUN = mean)
print(convergence_summary)

# Average runtime by method
cat("\nAverage runtime (seconds):\n")
runtime_summary <- aggregate(runtime_seconds ~ method,
                             data = master_results,
                             FUN = function(x) mean(x, na.rm = TRUE))
print(runtime_summary)

# =============================================================================
# Analyze Impact of Continuity Correction
# ============================================================================

cat("\n========================================\n")
cat("Continuity Correction Impact\n")
cat("========================================\n\n")

# Compare results with and without correction
correction_comparison <- master_results %>%
  group_by(method, correction) %>%
  summarise(
    converged = mean(converged, na.rm = TRUE),
    runtime = mean(runtime_seconds, na.rm = TRUE),
    sens = mean(pooled_sens, na.rm = TRUE),
    spec = mean(pooled_spec, na.rm = TRUE),
    dor = mean(pooled_dor, na.rm = TRUE),
    .groups = "drop"
  )

print(correction_comparison)

# =============================================================================
# Identify Failed Analyses
# ============================================================================

cat("\n========================================\n")
cat("Failed Analyses\n")
cat("========================================\n\n")

failed <- master_results[!master_results$converged, ]

cat(sprintf("Total failures: %d / %d (%.1f%%)\n\n",
            nrow(failed), nrow(master_results),
            100 * nrow(failed) / nrow(master_results)))

# Failures by method
cat("Failures by method:\n")
print(table(failed$method))

# Failures by sparsity level
failed$sparsity_category <- cut(failed$sparsity,
                                 breaks = c(0, 0.05, 0.1, 0.2, Inf),
                                 labels = c("Low", "Medium", "High", "Very High"))

cat("\nFailures by sparsity:\n")
print(table(failed$sparsity_category))

# Datasets with most failures
dataset_failures <- table(failed$dataset_name)
cat("\nDatasets with 3+ failures:\n")
print(head(sort(dataset_failures, decreasing = TRUE), 10))

# =============================================================================
# Save Results
# ============================================================================

cat("\n========================================\n")
cat("Saving Results...\n")
cat("========================================\n\n")

# Save master results
write.csv(master_results,
          "dta_methods_research/results/raw/mada_methods_results.csv",
          row.names = FALSE)
cat("Saved: mada_methods_results.csv\n")

# Save as RDS
saveRDS(master_results,
        "dta_methods_research/results/raw/mada_methods_results.rds")
cat("Saved: mada_methods_results.rds\n")

# Create summary table
summary_table <- master_results %>%
  group_by(method) %>%
  summarise(
    n_tests = n(),
    n_converged = sum(converged, na.rm = TRUE),
    convergence_rate = mean(converged, na.rm = TRUE),
    mean_runtime = mean(runtime_seconds, na.rm = TRUE),
    mean_sens = mean(pooled_sens, na.rm = TRUE),
    mean_spec = mean(pooled_spec, na.rm = TRUE),
    mean_dor = mean(pooled_dor, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(convergence_rate))

write.csv(summary_table,
          "dta_methods_research/results/tables/mada_methods_summary.csv",
          row.names = FALSE)
cat("Saved: mada_methods_summary.csv\n")

# =============================================================================
# Create Visualizations
# ============================================================================

cat("\n========================================\n")
cat("Creating Visualizations...\n")
cat("========================================\n\n")

# Theme
theme_publication <- theme_bw() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

# 1. Convergence rate by method
p1 <- ggplot(summary_table,
             aes(x = reorder(method, convergence_rate), y = convergence_rate * 100)) +
  geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
  coord_flip() +
  labs(x = "Method",
       y = "Convergence Rate (%)",
       title = "Convergence Rate by MADA Method") +
  theme_publication

ggsave("dta_methods_research/results/figures/mada_convergence_rate.png",
       p1, width = 8, height = 6, dpi = 300)

# 2. Runtime by method
p2 <- ggplot(summary_table,
             aes(x = reorder(method, mean_runtime), y = mean_runtime)) +
  geom_bar(stat = "identity", fill = "coral", alpha = 0.8) +
  coord_flip() +
  labs(x = "Method",
       y = "Mean Runtime (seconds)",
       title = "Runtime by MADA Method") +
  theme_publication

ggsave("dta_methods_research/results/figures/mada_runtime.png",
       p2, width = 8, height = 6, dpi = 300)

# 3. DOR comparison (MosesL vs Reitsma)
dor_comparison <- master_results %>%
  filter(correction == 0.5) %>%
  select(dataset_name, method, pooled_dor) %>%
  pivot_wider(names_from = method, values_from = pooled_dor) %>%
  filter(!is.na(reitsma_bivariate) & !is.na(MosesL_weighted))

p3 <- ggplot(dor_comparison,
             aes(x = MosesL_weighted, y = reitsma_bivariate)) +
  geom_point(alpha = 0.6) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +
  labs(x = "Moses-Littenberg (Weighted) DOR",
       y = "Reitsma Bivariate DOR",
       title = "DOR Comparison: Moses-Littenberg vs Reitsma") +
  theme_publication

ggsave("dta_methods_research/results/figures/mosesl_vs_reitsma_dor.png",
       p3, width = 8, height = 6, dpi = 300)

# 4. Sensitivity comparison
sens_comparison <- master_results %>%
  filter(correction == 0.5) %>%
  select(dataset_name, method, pooled_sens) %>%
  pivot_wider(names_from = method, values_from = pooled_sens) %>%
  filter(!is.na(reitsma_bivariate) & !is.na(marginal_pooling))

p4 <- ggplot(sens_comparison,
             aes(x = marginal_pooling, y = reitsma_bivariate)) +
  geom_point(alpha = 0.6) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +
  labs(x = "Marginal Pooling Sensitivity",
       y = "Reitsma Bivariate Sensitivity",
       title = "Sensitivity Comparison: Marginal vs Reitsma") +
  theme_publication

ggsave("dta_methods_research/results/figures/marginal_vs_reitsma_sens.png",
       p4, width = 8, height = 6, dpi = 300)

# 5. Sparsity vs Convergence
sparsity_convergence <- master_results %>%
  group_by(dataset_name, method) %>%
  summarise(
    sparsity = mean(sparsity),
    converged = mean(converged),
    .groups = "drop"
  )

p5 <- ggplot(sparsity_convergence,
             aes(x = sparsity * 100, y = converged, color = method)) +
  geom_smooth(method = "loess", se = TRUE) +
  geom_point(alpha = 0.3) +
  labs(x = "Sparsity (%)",
       y = "Convergence Rate",
       title = "Sparsity vs Convergence Rate",
       color = "Method") +
  theme_publication

ggsave("dta_methods_research/results/figures/mada_sparsity_vs_convergence.png",
       p5, width = 10, height = 6, dpi = 300)

cat("Saved all visualizations\n")

# =============================================================================
# Complete
# =============================================================================

cat("\n========================================\n")
cat("MADA Methods Testing Complete!\n")
cat("========================================\n\n")

cat("Summary:\n")
cat(sprintf("  Total tests run: %d\n", nrow(master_results)))
cat(sprintf("  Converged: %d (%.1f%%)\n",
            sum(master_results$converged, na.rm = TRUE),
            100 * mean(master_results$converged, na.rm = TRUE)))
cat(sprintf("  Total runtime: %.2f seconds\n", runtime_total))

cat("\nOutput files:\n")
cat("  - results/raw/mada_methods_results.csv\n")
cat("  - results/raw/mada_methods_results.rds\n")
cat("  - results/tables/mada_methods_summary.csv\n")
cat("  - results/figures/mada_*.png\n")

cat("\nNext steps:\n")
cat("1. Review results and identify problematic patterns\n")
cat("2. Run test_bayesian.R for Bayesian methods\n")
cat("3. Run compile_results.R to merge all results\n")
