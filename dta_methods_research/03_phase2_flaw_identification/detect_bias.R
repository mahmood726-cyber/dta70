# ============================================================================
# detect_bias.R - Identify Flaws and Bias in DTA Meta-Analysis Methods
# ============================================================================
#
# This script analyzes method results to identify specific flaws including:
# - Point estimate bias
# - CI coverage problems
# - Convergence issues
# - Heterogeneity handling problems
# - Threshold effect issues
#
# ============================================================================

setwd("C:/Users/user/OneDrive - NHS/Documents/DTA70")  # sentinel:skip-line P0-hardcoded-local-path

# Load required packages
required_packages <- c("tidyverse", "data.table", "ggplot2", "patchwork",
                       "broom", "boot")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg)
  }
}

# Source utility functions
source("dta_methods_research/functions/evaluation_metrics.R")

# =============================================================================
# Load Results
# ============================================================================

cat("========================================\n")
cat("Phase 2: Flaw Identification\n")
cat("========================================\n\n")

# Load master database
master_results <- readRDS("dta_methods_research/results/raw/master_database.rds")
cat(sprintf("Loaded %d method-dataset combinations\n", nrow(master_results)))

# Load datasets for reference
dataset_list <- readRDS("dta_methods_research/results/raw/all_datasets.rds")

# =============================================================================
# Create Ground Truth (Consensus Estimates)
# ============================================================================

cat("\n========================================\n")
cat("Creating Ground Truth Benchmarks\n")
cat("========================================\n\n")

# Function to create consensus estimate from converging methods
create_consensus <- function(dataset_name, results_data) {
  data_results <- results_data[results_data$dataset_name == dataset_name, ]

  # Only use converged results
  converged_methods <- data_results[data_results$converged == TRUE, ]

  if (nrow(converged_methods) < 2) {
    return(NULL)
  }

  # Use median of converging methods as robust consensus
  # (less sensitive to outliers than mean)

  consensus_sens <- median(converged_methods$pooled_sens, na.rm = TRUE)
  consensus_spec <- median(converged_methods$pooled_spec, na.rm = TRUE)
  consensus_dor <- median(converged_methods$pooled_dor, na.rm = TRUE)

  list(
    dataset_name = dataset_name,
    consensus_sens = consensus_sens,
    consensus_spec = consensus_spec,
    consensus_dor = consensus_dor,
    n_methods = nrow(converged_methods),
    methods_used = paste(converged_methods$method, collapse = ", ")
  )
}

# Create consensus for all datasets
consensus_list <- lapply(unique(master_results$dataset_name), function(ds) {
  create_consensus(ds, master_results)
})

consensus_df <- do.call(rbind, lapply(consensus_list, function(x) {
  if (is.null(x)) return(NULL)
  as.data.frame(x)
}))

# Merge with master results
master_results <- merge(master_results, consensus_df,
                       by = "dataset_name", all.x = TRUE)

cat(sprintf("Created consensus for %d datasets\n", nrow(consensus_df)))

# =============================================================================
# 1. Point Estimate Bias Analysis
# ============================================================================

cat("\n========================================\n")
cat("1. Point Estimate Bias Analysis\n")
cat("========================================\n\n")

# Calculate bias relative to consensus
master_results$bias_sens <- master_results$pooled_sens - master_results$consensus_sens
master_results$bias_spec <- master_results$pooled_spec - master_results$consensus_spec
master_results$bias_dor <- master_results$pooled_dor - master_results$consensus_dor

# Relative bias (%)
master_results$rel_bias_sens <- 100 * master_results$bias_sens / master_results$consensus_sens
master_results$rel_bias_spec <- 100 * master_results$bias_spec / master_results$consensus_spec
master_results$rel_bias_dor <- 100 * master_results$bias_dor / master_results$consensus_dor

# Summary by method
bias_summary <- master_results %>%
  filter(converged == TRUE & !is.na(consensus_sens)) %>%
  group_by(method) %>%
  summarise(
    n = n(),
    mean_bias_sens = mean(bias_sens, na.rm = TRUE),
    sd_bias_sens = sd(bias_sens, na.rm = TRUE),
    mean_rel_bias_sens = mean(rel_bias_sens, na.rm = TRUE),
    mean_bias_spec = mean(bias_spec, na.rm = TRUE),
    sd_bias_spec = sd(bias_spec, na.rm = TRUE),
    mean_rel_bias_spec = mean(rel_bias_spec, na.rm = TRUE),
    mean_bias_dor = mean(bias_dor, na.rm = TRUE),
    .groups = "drop"
  )

cat("Bias summary by method:\n")
print(bias_summary)

# Save bias results
write.csv(bias_summary,
          "dta_methods_research/results/tables/bias_summary.csv",
          row.names = FALSE)
cat("\nSaved: bias_summary.csv\n")

# Test if bias is significantly different from zero
bias_significance <- master_results %>%
  filter(converged == TRUE & !is.na(consensus_sens)) %>%
  group_by(method) %>%
  summarise(
    t_sens = t.test(bias_sens)$statistic,
    p_sens = t.test(bias_sens)$p.value,
    t_spec = t.test(bias_spec)$statistic,
    p_spec = t.test(bias_spec)$p.value,
    .groups = "drop"
  )

cat("\nBias significance tests:\n")
print(bias_significance)

# Methods with significant bias
significant_bias <- bias_significance %>%
  filter(p_sens < 0.05 | p_spec < 0.05)

if (nrow(significant_bias) > 0) {
  cat("\nMethods with significant bias (p < 0.05):\n")
  print(significant_bias)
}

# =============================================================================
# 2. Bias vs Data Characteristics
# ============================================================================

cat("\n========================================\n")
cat("2. Bias vs Data Characteristics\n")
cat("========================================\n\n")

# Regress bias on data characteristics
bias_models <- list()

# Model: Does sparsity predict bias in sensitivity?
model_sens_sparsity <- lm(rel_bias_sens ~ sparsity,
                          data = master_results %>%
                            filter(converged == TRUE & !is.na(consensus_sens)))
bias_models$sens_sparsity <- model_sens_sparsity

cat("Effect of sparsity on sensitivity bias:\n")
print(summary(model_sens_sparsity))

# Model: Does study count predict bias?
model_sens_n <- lm(rel_bias_sens ~ n_studies,
                    data = master_results %>%
                      filter(converged == TRUE & !is.na(consensus_sens)))
bias_models$sens_n <- model_sens_n

cat("\nEffect of study count on sensitivity bias:\n")
print(summary(model_sens_n))

# Model: Does heterogeneity predict bias?
model_sens_i2 <- lm(rel_bias_sens ~ i2_sens,
                     data = master_results %>%
                       filter(converged == TRUE & !is.na(consensus_sens)))
bias_models$sens_i2 <- model_sens_i2

cat("\nEffect of I-squared on sensitivity bias:\n")
print(summary(model_sens_i2))

# =============================================================================
# 3. Subgroup Analysis by Method
# ============================================================================

cat("\n========================================\n")
cat("3. Subgroup Analysis by Method\n")
cat("========================================\n\n")

# Analyze Moses-Littenberg bias specifically (known to underestimate DOR)
mosesl_bias <- master_results %>%
  filter(grepl("MosesL", method) & converged == TRUE & !is.na(consensus_dor))

if (nrow(mosesl_bias) > 0) {
  cat("Moses-Littenberg DOR bias:\n")
  cat(sprintf("  Mean bias: %.4f\n", mean(mosesl_bias$bias_dor, na.rm = TRUE)))
  cat(sprintf("  Mean relative bias: %.2f%%\n",
              mean(mosesl_bias$rel_bias_dor, na.rm = TRUE)))
  cat(sprintf("  Underestimation rate: %.1f%%\n",
              100 * mean(mosesl_bias$bias_dor < 0, na.rm = TRUE)))

  # Test if underestimation is significant
  t_test <- t.test(mosesl_bias$bias_dor)
  cat(sprintf("  t-test: t = %.2f, p = %.4f\n", t_test$statistic, t_test$p.value))
}

# =============================================================================
# 4. CI Coverage Analysis
# ============================================================================

cat("\n========================================\n")
cat("4. CI Coverage Analysis\n")
cat("========================================\n\n")

# For each method, check if consensus falls within CI
master_results$ci_contains_sens <- with(master_results,
                                        (consensus_sens >= pooled_sens_ci_lb) &
                                        (consensus_sens <= pooled_sens_ci_ub))
master_results$ci_contains_spec <- with(master_results,
                                        (consensus_spec >= pooled_spec_ci_lb) &
                                        (consensus_spec <= pooled_spec_ci_ub))

# Coverage rate by method
coverage_summary <- master_results %>%
  filter(converged == TRUE & !is.na(consensus_sens)) %>%
  group_by(method) %>%
  summarise(
    n = n(),
    coverage_sens = mean(ci_contains_sens, na.rm = TRUE),
    coverage_spec = mean(ci_contains_spec, na.rm = TRUE),
    .groups = "drop"
  )

cat("Coverage rates by method:\n")
print(coverage_summary)

# Check for under-coverage (nominal 95% should be >= 0.95)
under_coverage <- coverage_summary %>%
  filter(coverage_sens < 0.90 | coverage_spec < 0.90)

if (nrow(under_coverage) > 0) {
  cat("\nWARNING: Methods with under-coverage (< 90%):\n")
  print(under_coverage)
}

# =============================================================================
# 5. Convergence Failure Analysis
# ============================================================================

cat("\n========================================\n")
cat("5. Convergence Failure Analysis\n")
cat("========================================\n\n")

# Analyze failures by data characteristics
failures <- master_results[!master_results$converged, ]

# Compare characteristics of successful vs failed analyses
success_vs_fail <- master_results %>%
  mutate(outcome = ifelse(converged, "Success", "Failure")) %>%
  group_by(method, outcome) %>%
  summarise(
    mean_sparsity = mean(sparsity, na.rm = TRUE),
    mean_i2 = mean(i2_sens, na.rm = TRUE),
    mean_n_studies = mean(n_studies, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

cat("Data characteristics by convergence outcome:\n")
print(success_vs_fail)

# Logistic regression: What predicts failure?
failure_data <- master_results %>%
  select(method, converged, sparsity, i2_sens, n_studies) %>%
  na.omit()

if (nrow(failure_data) > 0) {
  failure_model <- glm(converged ~ sparsity + i2_sens + n_studies,
                       data = failure_data,
                       family = binomial())

  cat("\nLogistic regression for convergence:\n")
  print(summary(failure_model))
}

# =============================================================================
# 6. Create Visualizations
# ============================================================================

cat("\n========================================\n")
cat("Creating Flaw Visualizations...\n")
cat("========================================\n\n")

theme_publication <- theme_bw() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

# 1. Bias plot by method
bias_long <- master_results %>%
  filter(converged == TRUE) %>%
  select(method, bias_sens, bias_spec) %>%
  pivot_longer(cols = c(bias_sens, bias_spec),
               names_to = "metric",
               values_to = "bias") %>%
  mutate(metric = ifelse(metric == "bias_sens", "Sensitivity", "Specificity"))

p1 <- ggplot(bias_long, aes(x = reorder(method, bias, FUN = median), y = bias)) +
  geom_boxplot() +
  facet_wrap(~ metric, scales = "free") +
  coord_flip() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(x = "Method",
       y = "Bias (difference from consensus)",
       title = "Point Estimate Bias by Method") +
  theme_publication

ggsave("dta_methods_research/results/figures/bias_by_method.png",
       p1, width = 10, height = 8, dpi = 300)

# 2. Bias vs sparsity
p2 <- ggplot(master_results %>%
               filter(converged == TRUE),
             aes(x = sparsity * 100, y = rel_bias_sens, color = method)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed") +
  labs(x = "Sparsity (%)",
       y = "Relative Sensitivity Bias (%)",
       title = "Bias vs Data Sparsity",
       color = "Method") +
  theme_publication

ggsave("dta_methods_research/results/figures/bias_vs_sparsity.png",
       p2, width = 10, height = 6, dpi = 300)

# 3. Coverage plot
coverage_long <- coverage_summary %>%
  pivot_longer(cols = c(coverage_sens, coverage_spec),
               names_to = "metric",
               values_to = "coverage") %>%
  mutate(metric = ifelse(metric == "coverage_sens", "Sensitivity", "Specificity"))

p3 <- ggplot(coverage_long,
             aes(x = reorder(method, coverage), y = coverage * 100, fill = metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  geom_hline(yintercept = 95, linetype = "dashed", color = "red") +
  labs(x = "Method",
       y = "Coverage Rate (%)",
       title = "CI Coverage by Method",
       fill = "Metric") +
  theme_publication

ggsave("dta_methods_research/results/figures/coverage_by_method.png",
       p3, width = 10, height = 6, dpi = 300)

# 4. Convergence by data characteristics
p4 <- ggplot(success_vs_fail,
             aes(x = outcome, y = mean_sparsity * 100, fill = outcome)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~ method) +
  labs(x = "Outcome",
       y = "Mean Sparsity (%)",
       title = "Convergence vs Data Sparsity",
       fill = "Outcome") +
  theme_publication

ggsave("dta_methods_research/results/figures/convergence_vs_sparsity.png",
       p4, width = 12, height = 8, dpi = 300)

cat("All flaw visualizations saved\n")

# =============================================================================
# Save Results
# ============================================================================

cat("\n========================================\n")
cat("Saving Flaw Analysis Results\n")
cat("========================================\n\n")

# Save master results with bias columns
saveRDS(master_results,
        "dta_methods_research/results/raw/master_results_with_bias.rds")
cat("Saved: master_results_with_bias.rds\n")

# Create flaw summary table
flaw_summary <- bias_summary %>%
  left_join(coverage_summary, by = "method") %>%
  mutate(
    significant_bias = ifelse(method %in% significant_bias$method, "Yes", "No"),
    under_coverage = ifelse(coverage_sens < 0.90 | coverage_spec < 0.90, "Yes", "No")
  )

write.csv(flaw_summary,
          "dta_methods_research/results/tables/flaw_summary.csv",
          row.names = FALSE)
cat("Saved: flaw_summary.csv\n")

# =============================================================================
# Complete
# =============================================================================

cat("\n========================================\n")
cat("Phase 2: Flaw Identification Complete!\n")
cat("========================================\n\n")

cat("Key findings:\n")
cat(sprintf("  Methods with significant bias: %d\n", nrow(significant_bias)))
cat(sprintf("  Methods with under-coverage: %d\n", nrow(under_coverage)))

if (nrow(mosesl_bias) > 0) {
  cat(sprintf("  Moses-Littenberg underestimates DOR by %.1f%% (on average)\n",
              mean(mosesl_bias$rel_bias_dor, na.rm = TRUE)))
}

cat("\nOutput files:\n")
cat("  - results/tables/bias_summary.csv\n")
cat("  - results/tables/flaw_summary.csv\n")
cat("  - results/figures/bias_*.png\n")
cat("  - results/figures/coverage_*.png\n")

cat("\nNext steps:\n")
cat("1. Review flaw_summary.csv for detailed issues\n")
cat("2. Proceed to Phase 3: Method Development\n")
cat("3. Run simulation_studies.R for validation\n")
