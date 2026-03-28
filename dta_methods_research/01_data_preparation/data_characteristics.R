# ============================================================================
# data_characteristics.R - Calculate and Visualize Dataset Characteristics
# ============================================================================
#
# This script analyzes the characteristics of all loaded DTA datasets,
# creating summary statistics and visualizations.
#
# ============================================================================

setwd("C:/Users/user/OneDrive - NHS/Documents/DTA70")

# Load required packages
required_packages <- c("tidyverse", "data.table", "ggplot2", "patchwork",
                       "gridExtra", "kableExtra")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg)
  }
}

# Source utility functions
source("dta_methods_research/functions/evaluation_metrics.R")

# =============================================================================
# Load Data
# =============================================================================

cat("========================================\n")
cat("DTA70 Dataset Characteristics Analysis\n")
cat("========================================\n\n")

# Load dataset list
dataset_list <- readRDS("dta_methods_research/results/raw/all_datasets.rds")
dataset_info <- read.csv("dta_methods_research/results/raw/dataset_info.csv")

cat(sprintf("Loaded %d datasets\n\n", length(dataset_list)))

# =============================================================================
# Calculate Detailed Characteristics
# =============================================================================

cat("Calculating detailed characteristics...\n\n")

# Initialize results data frame
characteristics_list <- lapply(names(dataset_list), function(ds_name) {
  data <- dataset_list[[ds_name]]

  char <- calculate_data_characteristics(data)

  # Add to data frame
  out <- data.frame(
    dataset_name = ds_name,
    n_studies = char$n_studies,
    sparsity = char$sparsity,
    eff_n = char$eff_n,
    zero_cells = char$zero_cells,
    min_size = char$study_size_range["min_size"],
    max_size = char$study_size_range["max_size"],
    mean_size = char$study_size_range["mean_size"],
    median_size = char$study_size_range["median_size"],
    perfect_sens = char$perfect_proportions["perfect_sens"],
    perfect_spec = char$perfect_proportions["perfect_spec"],
    perfect_both = char$perfect_proportions["perfect_both"],
    mean_sens_raw = char$mean_sens_raw,
    mean_spec_raw = char$mean_spec_raw,
    cv_sens = char$cv_sens,
    cv_spec = char$cv_spec,
    stringsAsFactors = FALSE
  )

  return(out)
})

characteristics_df <- do.call(rbind, characteristics_list)

# Add split info
characteristics_df$split <- dataset_info$split[match(characteristics_df$dataset_name,
                                                     dataset_info$dataset_name)]

# Calculate I-squared for each dataset (using DL method)
characteristics_df$i2_sens <- NA
characteristics_df$i2_spec <- NA

for (i in 1:nrow(characteristics_df)) {
  ds_name <- characteristics_df$dataset_name[i]
  data <- dataset_list[[ds_name]]

  tryCatch({
    # Calculate I-squared for sensitivity using DerSimonian-Laird
    w_sens <- data$TP + data$FN
    sens_i <- data$TP / w_sens
    sens_pooled <- sum(w_sens * sens_i) / sum(w_sens)
    Q_sens <- sum(w_sens * (sens_i - sens_pooled)^2) / (sens_pooled * (1 - sens_pooled))
    characteristics_df$i2_sens[i] <- calculate_i2(Q_sens, nrow(data) - 1)

    # I-squared for specificity
    w_spec <- data$TN + data$FP
    spec_i <- data$TN / w_spec
    spec_pooled <- sum(w_spec * spec_i) / sum(w_spec)
    Q_spec <- sum(w_spec * (spec_i - spec_pooled)^2) / (spec_pooled * (1 - spec_pooled))
    characteristics_df$i2_spec[i] <- calculate_i2(Q_spec, nrow(data) - 1)
  }, error = function(e) {
    # Keep NA if calculation fails
  })
}

# =============================================================================
# Summary Statistics
# =============================================================================

cat("========================================\n")
cat("Summary Statistics\n")
cat("========================================\n\n")

cat("Dataset size (number of studies):\n")
print(summary(characteristics_df$n_studies))

cat("\nSparsity (proportion of zero cells):\n")
print(summary(characteristics_df$sparsity))

cat("\nEffective sample size:\n")
print(summary(characteristics_df$eff_n))

cat("\nI-squared (sensitivity):\n")
print(summary(characteristics_df$i2_sens, na.rm = TRUE))

cat("\nI-squared (specificity):\n")
print(summary(characteristics_df$i2_spec, na.rm = TRUE))

# =============================================================================
# Create Visualizations
# =============================================================================

cat("\n========================================\n")
cat("Creating Visualizations...\n")
cat("========================================\n\n")

# Theme for publication-quality plots
theme_publication <- theme_bw() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

# 1. Study count distribution
p1 <- ggplot(characteristics_df, aes(x = n_studies)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "black", alpha = 0.7) +
  labs(x = "Number of Studies",
       y = "Frequency",
       title = "Distribution of Study Counts Across Datasets") +
  theme_publication

ggsave("dta_methods_research/results/figures/study_count_distribution.png",
       p1, width = 8, height = 6, dpi = 300)
cat("Saved: study_count_distribution.png\n")

# 2. Sparsity distribution
p2 <- ggplot(characteristics_df, aes(x = sparsity * 100)) +
  geom_histogram(bins = 30, fill = "coral", color = "black", alpha = 0.7) +
  labs(x = "Sparsity (%)",
       y = "Frequency",
       title = "Distribution of Data Sparsity") +
  theme_publication

ggsave("dta_methods_research/results/figures/sparsity_distribution.png",
       p2, width = 8, height = 6, dpi = 300)
cat("Saved: sparsity_distribution.png\n")

# 3. I-squared distribution
i2_long <- characteristics_df %>%
  select(dataset_name, i2_sens, i2_spec) %>%
  pivot_longer(cols = c(i2_sens, i2_spec),
               names_to = "metric",
               values_to = "i2") %>%
  mutate(metric = ifelse(metric == "i2_sens", "Sensitivity", "Specificity"))

p3 <- ggplot(i2_long, aes(x = i2, fill = metric)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
  facet_wrap(~ metric, ncol = 1) +
  labs(x = "I-squared (%)",
       y = "Frequency",
       title = "Distribution of Heterogeneity (I-squared)",
       fill = "Metric") +
  theme_publication

ggsave("dta_methods_research/results/figures/i2_distribution.png",
       p3, width = 8, height = 8, dpi = 300)
cat("Saved: i2_distribution.png\n")

# 4. Mean sensitivity vs specificity
p4 <- ggplot(characteristics_df,
             aes(x = mean_sens_raw * 100, y = mean_spec_raw * 100)) +
  geom_point(aes(color = split, size = n_studies), alpha = 0.7) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50") +
  labs(x = "Mean Sensitivity (%)",
       y = "Mean Specificity (%)",
       title = "Mean Sensitivity vs Specificity Across Datasets",
       color = "Split",
       size = "N Studies") +
  theme_publication

ggsave("dta_methods_research/results/figures/sens_vs_spec.png",
       p4, width = 8, height = 6, dpi = 300)
cat("Saved: sens_vs_spec.png\n")

# 5. Sparsity vs I-squared
p5 <- ggplot(characteristics_df,
             aes(x = sparsity * 100, y = i2_sens)) +
  geom_point(aes(color = split, size = n_studies), alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +
  labs(x = "Sparsity (%)",
       y = "I-squared (Sensitivity) (%)",
       title = "Relationship Between Sparsity and Heterogeneity",
       color = "Split",
       size = "N Studies") +
  theme_publication

ggsave("dta_methods_research/results/figures/sparsity_vs_i2.png",
       p5, width = 8, height = 6, dpi = 300)
cat("Saved: sparsity_vs_i2.png\n")

# 6. Study size vs heterogeneity
p6 <- ggplot(characteristics_df,
             aes(x = n_studies, y = i2_sens)) +
  geom_point(aes(color = split), alpha = 0.7, size = 3) +
  geom_smooth(method = "loess", se = TRUE, color = "red", linetype = "dashed") +
  labs(x = "Number of Studies",
       y = "I-squared (Sensitivity) (%)",
       title = "Relationship Between Study Count and Heterogeneity",
       color = "Split") +
  theme_publication

ggsave("dta_methods_research/results/figures/n_studies_vs_i2.png",
       p6, width = 8, height = 6, dpi = 300)
cat("Saved: n_studies_vs_i2.png\n")

# 7. Coefficient of variation (sensitivity vs specificity)
p7 <- ggplot(characteristics_df,
             aes(x = cv_sens * 100, y = cv_spec * 100)) +
  geom_point(aes(color = split, size = n_studies), alpha = 0.7) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50") +
  labs(x = "CV of Sensitivity (%)",
       y = "CV of Specificity (%)",
       title = "Variability Across Studies",
       color = "Split",
       size = "N Studies") +
  theme_publication

ggsave("dta_methods_research/results/figures/cv_sens_vs_cv_spec.png",
       p7, width = 8, height = 6, dpi = 300)
cat("Saved: cv_sens_vs_cv_spec.png\n")

# 8. Multi-panel summary
p_summary <- (p1 + p2) / (p4 + p5)
ggsave("dta_methods_research/results/figures/characteristics_summary.png",
       p_summary, width = 12, height = 10, dpi = 300)
cat("Saved: characteristics_summary.png\n")

# =============================================================================
# Create Summary Table
# =============================================================================

cat("\n========================================\n")
cat("Creating Summary Table...\n")
cat("========================================\n\n")

# Create publication-ready table
summary_table <- characteristics_df %>%
  mutate(
    Sensitivity = sprintf("%.2f%% (±%.2f%%)", mean_sens_raw * 100,
                          cv_sens * mean_sens_raw * 100),
    Specificity = sprintf("%.2f%% (±%.2f%%)", mean_spec_raw * 100,
                          cv_spec * mean_spec_raw * 100),
    I2_Sens = sprintf("%.1f%%", i2_sens),
    I2_Spec = sprintf("%.1f%%", i2_spec),
    Sparsity = sprintf("%.1f%%", sparsity * 100),
    N_Studies = n_studies
  ) %>%
  select(dataset_name, N_Studies, Sparsity, Sensitivity, Specificity, I2_Sens, I2_Spec) %>%
  arrange(desc(N_Studies))

# Save as CSV
write.csv(summary_table,
          "dta_methods_research/results/tables/dataset_characteristics.csv",
          row.names = FALSE)
cat("Saved: dataset_characteristics.csv\n")

# =============================================================================
# Identify Problematic Datasets
# =============================================================================

cat("\n========================================\n")
cat("Dataset Quality Assessment\n")
cat("========================================\n\n")

# Define problematic criteria
high_sparsity <- characteristics_df$sparsity > 0.2
high_heterogeneity <- characteristics_df$i2_sens > 80 | characteristics_df$i2_spec > 80
very_small <- characteristics_df$n_studies < 5
many_perfect <- characteristics_df$perfect_both > 0.5

problematic <- characteristics_df[high_sparsity | high_heterogeneity |
                                  very_small | many_perfect, ]

cat("Potentially problematic datasets:\n\n")
for (i in 1:nrow(problematic)) {
  issues <- c()
  if (high_sparsity[match(problematic$dataset_name[i], characteristics_df$dataset_name)]) {
    issues <- c(issues, "high sparsity")
  }
  if (high_heterogeneity[match(problematic$dataset_name[i], characteristics_df$dataset_name)]) {
    issues <- c(issues, "high heterogeneity")
  }
  if (very_small[match(problematic$dataset_name[i], characteristics_df$dataset_name)]) {
    issues <- c(issues, "very small")
  }
  if (many_perfect[match(problematic$dataset_name[i], characteristics_df$dataset_name)]) {
    issues <- c(issues, "many perfect results")
  }

  cat(sprintf("  %s: %s\n", problematic$dataset_name[i], paste(issues, collapse = ", ")))
}

# =============================================================================
# Save Results
# =============================================================================

cat("\n========================================\n")
cat("Saving Results...\n")
cat("========================================\n\n")

# Save full characteristics
write.csv(characteristics_df,
          "dta_methods_research/results/tables/full_characteristics.csv",
          row.names = FALSE)
cat("Saved: full_characteristics.csv\n")

# Save as RDS for quick loading
saveRDS(characteristics_df,
        "dta_methods_research/results/raw/characteristics.rds")
cat("Saved: characteristics.rds\n")

# =============================================================================
# Complete
# ============================================================================

cat("\n========================================\n")
cat("Characteristics Analysis Complete!\n")
cat("========================================\n\n")

cat("Summary:\n")
cat(sprintf("  Total datasets analyzed: %d\n", nrow(characteristics_df)))
cat(sprintf("  Mean studies per dataset: %.1f\n", mean(characteristics_df$n_studies)))
cat(sprintf("  Mean sparsity: %.1f%%\n", 100 * mean(characteristics_df$sparsity)))
cat(sprintf("  Mean I-squared (sens): %.1f%%\n",
            mean(characteristics_df$i2_sens, na.rm = TRUE)))
cat(sprintf("  Mean I-squared (spec): %.1f%%\n",
            mean(characteristics_df$i2_spec, na.rm = TRUE)))
cat(sprintf("  Potentially problematic: %d\n", nrow(problematic)))

cat("\nOutput files:\n")
cat("  - results/figures/*.png (visualizations)\n")
cat("  - results/tables/dataset_characteristics.csv\n")
cat("  - results/tables/full_characteristics.csv\n")
cat("  - results/raw/characteristics.rds\n")
