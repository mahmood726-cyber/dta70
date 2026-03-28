# ============================================================================
# compile_results.R - Compile and Merge All Method Results
# ============================================================================
#
# This script compiles results from all method testing scripts and creates
# a comprehensive master database for analysis and visualization.
#
# ============================================================================

setwd("C:/Users/user/OneDrive - NHS/Documents/DTA70")

# Load required packages
required_packages <- c("tidyverse", "data.table", "ggplot2", "patchwork",
                       "kableExtra", "DT")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg)
  }
}

# =============================================================================
# Load All Results
# ============================================================================

cat("========================================\n")
cat("Compiling All Method Results\n")
cat("========================================\n\n")

# Check which result files exist
result_files <- list(
  mada = "dta_methods_research/results/raw/mada_methods_results.rds",
  meta = "dta_methods_research/results/raw/meta_methods_results.rds",
  bayesian = "dta_methods_research/results/raw/bayesian_methods_results.rds",
  diagmeta = "dta_methods_research/results/raw/diagmeta_methods_results.rds",
  glmm = "dta_methods_research/results/raw/glmm_methods_results.rds"
)

# Load available results
all_results <- list()
for (method_type in names(result_files)) {
  if (file.exists(result_files[[method_type]])) {
    cat(sprintf("Loading %s results...\n", method_type))
    all_results[[method_type]] <- readRDS(result_files[[method_type]])
    cat(sprintf("  Loaded %d rows\n", nrow(all_results[[method_type]])))
  } else {
    cat(sprintf("Warning: %s results not found\n", method_type))
  }
}

# =============================================================================
# Standardize and Merge Results
# ============================================================================

cat("\n========================================\n")
cat("Standardizing and Merging Results\n")
cat("========================================\n\n")

# Function to standardize result format
standardize_results <- function(results, method_type) {
  if (is.null(results)) return(NULL)

  # Ensure required columns exist
  required_cols <- c("dataset_name", "method", "converged",
                     "pooled_sens", "pooled_spec", "pooled_dor",
                     "runtime_seconds")

  # Add missing columns with NA
  for (col in required_cols) {
    if (!col %in% names(results)) {
      results[[col]] <- NA
    }
  }

  # Add method type
  results$method_type <- method_type

  return(results)
}

# Standardize all results
for (method_type in names(all_results)) {
  all_results[[method_type]] <- standardize_results(
    all_results[[method_type]],
    method_type
  )
}

# Combine all results
master_results <- do.call(rbind, all_results[!sapply(all_results, is.null)])
rownames(master_results) <- NULL

cat(sprintf("Combined results: %d rows\n", nrow(master_results)))

# =============================================================================
# Add Data Characteristics
# ============================================================================

cat("\nAdding dataset characteristics...\n")

# Load dataset characteristics
if (file.exists("dta_methods_research/results/raw/characteristics.rds")) {
  characteristics <- readRDS("dta_methods_research/results/raw/characteristics.rds")

  # Merge characteristics
  master_results <- merge(
    master_results,
    characteristics[, c("dataset_name", "n_studies", "sparsity", "i2_sens", "i2_spec")],
    by = "dataset_name",
    all.x = TRUE
  )

  cat("Added dataset characteristics\n")
}

# =============================================================================
# Create Master Database
# ============================================================================

cat("\n========================================\n")
cat("Creating Master Database\n")
cat("========================================\n\n")

# Reorder and select key columns
master_db <- master_results %>%
  select(
    dataset_name,
    method,
    method_type,
    n_studies,
    sparsity,
    i2_sens,
    i2_spec,
    converged,
    pooled_sens,
    pooled_sens_ci_lb,
    pooled_sens_ci_ub,
    pooled_spec,
    pooled_spec_ci_lb,
    pooled_spec_ci_ub,
    pooled_dor,
    pooled_dor_ci_lb,
    pooled_dor_ci_ub,
    runtime_seconds,
    correction
  )

# Save master database
write.csv(master_db,
          "dta_methods_research/results/master_database.csv",
          row.names = FALSE)
cat("Saved: master_database.csv\n")

saveRDS(master_db,
        "dta_methods_research/results/raw/master_database.rds")
cat("Saved: master_database.rds\n")

# =============================================================================
# Summary Statistics
# ============================================================================

cat("\n========================================\n")
cat("Summary Statistics\n")
cat("========================================\n\n")

# Results by method type
cat("Results by method type:\n")
print(table(master_results$method_type))

# Overall convergence
cat("\nOverall convergence rate: %.1f%%\n",
    100 * mean(master_results$converged, na.rm = TRUE))

# Convergence by method type
cat("\nConvergence by method type:\n")
print(aggregate(converged ~ method_type,
                data = master_results,
                FUN = mean))

# =============================================================================
# Method Comparison
# ============================================================================

cat("\n========================================\n")
cat("Method Comparison\n")
cat("========================================\n\n")

# Create comparison summary
comparison_summary <- master_results %>%
  filter(converged == TRUE) %>%
  group_by(method) %>%
  summarise(
    n_tests = n(),
    mean_sens = mean(pooled_sens, na.rm = TRUE),
    sd_sens = sd(pooled_sens, na.rm = TRUE),
    mean_spec = mean(pooled_spec, na.rm = TRUE),
    sd_spec = sd(pooled_spec, na.rm = TRUE),
    mean_dor = mean(pooled_dor, na.rm = TRUE),
    sd_dor = sd(pooled_dor, na.rm = TRUE),
    mean_runtime = mean(runtime_seconds, na.rm = TRUE),
    .groups = "drop"
  )

print(comparison_summary)

# Save comparison
write.csv(comparison_summary,
          "dta_methods_research/results/tables/method_comparison.csv",
          row.names = FALSE)
cat("\nSaved: method_comparison.csv\n")

# =============================================================================
# Create Visualizations
# ============================================================================

cat("\n========================================\n")
cat("Creating Comparison Visualizations...\n")
cat("========================================\n\n")

theme_publication <- theme_bw() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

# 1. Sensitivity comparison across methods (boxplot)
sens_long <- master_results %>%
  filter(converged == TRUE) %>%
  select(method, pooled_sens) %>%
  na.omit()

p1 <- ggplot(sens_long, aes(x = reorder(method, pooled_sens, FUN = median),
                             y = pooled_sens * 100)) +
  geom_boxplot() +
  coord_flip() +
  labs(x = "Method",
       y = "Pooled Sensitivity (%)",
       title = "Sensitivity Comparison Across All Methods") +
  theme_publication

ggsave("dta_methods_research/results/figures/sensitivity_comparison.png",
       p1, width = 10, height = 8, dpi = 300)

# 2. Specificity comparison
spec_long <- master_results %>%
  filter(converged == TRUE) %>%
  select(method, pooled_spec) %>%
  na.omit()

p2 <- ggplot(spec_long, aes(x = reorder(method, pooled_spec, FUN = median),
                             y = pooled_spec * 100)) +
  geom_boxplot() +
  coord_flip() +
  labs(x = "Method",
       y = "Pooled Specificity (%)",
       title = "Specificity Comparison Across All Methods") +
  theme_publication

ggsave("dta_methods_research/results/figures/specificity_comparison.png",
       p2, width = 10, height = 8, dpi = 300)

# 3. DOR comparison
dor_long <- master_results %>%
  filter(converged == TRUE & pooled_dor < Inf) %>%
  select(method, pooled_dor) %>%
  na.omit()

p3 <- ggplot(dor_long, aes(x = reorder(method, pooled_dor, FUN = median),
                            y = pooled_dor)) +
  geom_boxplot() +
  coord_flip() +
  scale_y_log10() +
  labs(x = "Method",
       y = "Diagnostic Odds Ratio (log scale)",
       title = "DOR Comparison Across All Methods") +
  theme_publication

ggsave("dta_methods_research/results/figures/dor_comparison.png",
       p3, width = 10, height = 8, dpi = 300)

# 4. Runtime comparison
runtime_long <- master_results %>%
  filter(converged == TRUE) %>%
  select(method, runtime_seconds) %>%
  na.omit()

p4 <- ggplot(runtime_long, aes(x = reorder(method, runtime_seconds, FUN = median),
                                y = runtime_seconds)) +
  geom_boxplot() +
  coord_flip() +
  labs(x = "Method",
       y = "Runtime (seconds)",
       title = "Runtime Comparison Across All Methods") +
  theme_publication

ggsave("dta_methods_research/results/figures/runtime_comparison.png",
       p4, width = 10, height = 8, dpi = 300)

# 5. Convergence rate by method
convergence_summary <- master_results %>%
  group_by(method) %>%
  summarise(
    n = n(),
    converged_rate = mean(converged, na.rm = TRUE),
    .groups = "drop"
  )

p5 <- ggplot(convergence_summary,
             aes(x = reorder(method, converged_rate), y = converged_rate * 100)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(x = "Method",
       y = "Convergence Rate (%)",
       title = "Convergence Rate by Method") +
  theme_publication

ggsave("dta_methods_research/results/figures/convergence_comparison.png",
       p5, width = 10, height = 8, dpi = 300)

# 6. Method agreement heatmap (sensitivity)
methods_to_compare <- c("reitsma_bivariate", "marginal_pooling",
                        "MosesL_weighted", "meta_PLOGIT")
sens_wide <- master_results %>%
  filter(method %in% methods_to_compare & converged == TRUE) %>%
  select(dataset_name, method, pooled_sens) %>%
  pivot_wider(names_from = method, values_from = pooled_sens)

cor_matrix <- cor(sens_wide[, -1], use = "pairwise.complete.obs")

# Reshape for ggplot
cor_long <- expand.grid(Var1 = colnames(cor_matrix),
                        Var2 = colnames(cor_matrix))
cor_long$value <- as.vector(cor_matrix)

p6 <- ggplot(cor_long, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 2)), color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white",
                       midpoint = 0, limit = c(-1, 1)) +
  labs(x = "", y = "", fill = "Correlation",
       title = "Method Agreement: Sensitivity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("dta_methods_research/results/figures/method_agreement_heatmap.png",
       p6, width = 8, height = 8, dpi = 300)

cat("All visualizations saved\n")

# =============================================================================
# Complete
# =============================================================================

cat("\n========================================\n")
cat("Results Compilation Complete!\n")
cat("========================================\n\n")

cat("Output files:\n")
cat("  - results/master_database.csv\n")
cat("  - results/raw/master_database.rds\n")
cat("  - results/tables/method_comparison.csv\n")
cat("  - results/figures/*_comparison.png\n")

cat("\nNext steps:\n")
cat("1. Review master_database.csv\n")
cat("2. Proceed to Phase 2: Flaw Identification\n")
cat("3. Run generate_visualizations.R for additional plots\n")
