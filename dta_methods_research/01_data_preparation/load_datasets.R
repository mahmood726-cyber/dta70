# ============================================================================
# load_datasets.R - Load All DTA70 Datasets
# ============================================================================
#
# This script loads all 76 DTA datasets from the DTA70 package and prepares
# them for analysis. Each dataset is validated and standardised.
#
# ============================================================================

# Set working directory to DTA70 package root
setwd("C:/Users/user/OneDrive - NHS/Documents/DTA70")

# Load required packages
required_packages <- c("DTA70", "tidyverse", "data.table")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg)
  }
}

# Source utility functions
source("dta_methods_research/functions/evaluation_metrics.R")

# =============================================================================
# PART 1: List All Available Datasets
# =============================================================================

cat("========================================\n")
cat("DTA70 Dataset Loader\n")
cat("========================================\n\n")

# Get list of all datasets in DTA70 package
all_datasets <- data(package = "DTA70")$results[, "Item"]
cat("Found", length(all_datasets), "datasets in DTA70 package:\n\n")

# Print dataset names
for (i in seq_along(all_datasets)) {
  cat(sprintf("%2d. %s\n", i, all_datasets[i]))
}

# =============================================================================
# PART 2: Load and Validate Each Dataset
# =============================================================================

cat("\n========================================\n")
cat("Loading Datasets...\n")
cat("========================================\n\n")

# Function to validate dataset structure
validate_dta_dataset <- function(data) {
  required_cols <- c("TP", "FP", "FN", "TN")

  # Check columns exist
  if (!all(required_cols %in% names(data))) {
    warning(paste("Missing required columns:",
                  paste(setdiff(required_cols, names(data)), collapse = ", ")))
    return(FALSE)
  }

  # Check for negative values
  for (col in required_cols) {
    if (any(data[[col]] < 0, na.rm = TRUE)) {
      warning(paste("Negative values found in", col))
      return(FALSE)
    }
  }

  return(TRUE)
}

# Function to standardise dataset format
standardise_dataset <- function(data, dataset_name) {
  # Ensure required columns are numeric
  for (col in c("TP", "FP", "FN", "TN")) {
    data[[col]] <- as.numeric(data[[col]])
  }

  # Remove rows with all NA
  data <- data[rowSums(is.na(data[, c("TP", "FP", "FN", "TN")])) < 4, ]

  # Add dataset name
  data$dataset_name <- dataset_name

  # Add study ID if not present
  if (!"study_id" %in% names(data)) {
    data$study_id <- seq_len(nrow(data))
  }

  # Calculate raw sensitivity and specificity
  data$raw_sens <- with(data, TP / (TP + FN))
  data$raw_spec <- with(data, TN / (TN + FP))
  data$raw_dor <- with(data, (TP * TN) / (FP * FN))

  # Handle Inf/NaN from DOR calculation
  data$raw_dor[is.infinite(data$raw_dor) & data$raw_dor > 0] <- NA
  data$raw_dor[is.nan(data$raw_dor)] <- NA

  return(data)
}

# Load all datasets into a list
dataset_list <- list()
validation_results <- data.frame(
  dataset_name = character(),
  n_studies = integer(),
  zero_cells = integer(),
  sparsity = numeric(),
  valid = logical(),
  stringsAsFactors = FALSE
)

for (dataset_name in all_datasets) {
  cat(sprintf("Loading %s... ", dataset_name))

  tryCatch({
    # Load dataset
    data <- get(dataset_name)

    # Validate
    is_valid <- validate_dta_dataset(data)

    # Standardise
    if (is_valid) {
      data_std <- standardise_dataset(data, dataset_name)
      dataset_list[[dataset_name]] <- data_std
      n_studies <- nrow(data_std)
      zero_cells <- sum(data_std$TP == 0 | data_std$FP == 0 |
                        data_std$FN == 0 | data_std$TN == 0)
      sparsity <- calculate_sparsity(data_std)

      validation_results <- rbind(validation_results, data.frame(
        dataset_name = dataset_name,
        n_studies = n_studies,
        zero_cells = zero_cells,
        sparsity = sparsity,
        valid = is_valid
      ))

      cat(sprintf("OK (%d studies, %.1f%% sparse)\n",
                  n_studies, 100 * sparsity))
    } else {
      cat("FAILED (validation)\n")
    }

  }, error = function(e) {
    cat(sprintf("FAILED: %s\n", e$message))
    validation_results <<- rbind(validation_results, data.frame(
      dataset_name = dataset_name,
      n_studies = NA,
      zero_cells = NA,
      sparsity = NA,
      valid = FALSE
    ))
  })
}

# =============================================================================
# PART 3: Summary Statistics
# =============================================================================

cat("\n========================================\n")
cat("Dataset Summary\n")
cat("========================================\n\n")

valid_datasets <- validation_results[validation_results$valid, ]
cat(sprintf("Successfully loaded: %d/%d datasets\n\n",
            nrow(valid_datasets), length(all_datasets)))

# Overall statistics
cat("Overall statistics:\n")
cat(sprintf("  Total studies: %d\n", sum(valid_datasets$n_studies)))
cat(sprintf("  Mean studies per dataset: %.1f\n", mean(valid_datasets$n_studies)))
cat(sprintf("  Mean sparsity: %.2f%%\n", 100 * mean(valid_datasets$sparsity)))
cat(sprintf("  Datasets with zero cells: %d\n",
            sum(valid_datasets$zero_cells > 0)))

# Study count distribution
cat("\nStudy count distribution:\n")
print(table(cut(valid_datasets$n_studies,
                breaks = c(0, 10, 20, 50, Inf),
                labels = c("1-10", "11-20", "21-50", "50+"))))

# Sparsity distribution
cat("\nSparsity distribution:\n")
print(table(cut(valid_datasets$sparsity,
                breaks = c(0, 0.05, 0.1, 0.2, Inf),
                labels = c("0-5%", "5-10%", "10-20%", "20%+"))))

# =============================================================================
# PART 4: Create Train/Validation Splits
# =============================================================================

cat("\n========================================\n")
cat("Creating Train/Validation Splits...\n")
cat("========================================\n\n")

# Set seed for reproducibility
set.seed(42)

# Create stratified split based on study count
# 80% training, 20% validation
valid_dataset_names <- valid_datasets$dataset_name

# Stratify by study count category
valid_datasets$category <- cut(valid_datasets$n_studies,
                               breaks = c(0, 10, 20, 50, Inf),
                               labels = c("small", "medium", "large", "xlarge"))

train_indices <- c()
validation_indices <- c()

for (cat in unique(valid_datasets$category)) {
  cat_indices <- which(valid_datasets$category == cat)
  n_cat <- length(cat_indices)
  n_train <- floor(0.8 * n_cat)

  # Random sample within category
  cat_sample <- sample(cat_indices)
  train_indices <- c(train_indices, cat_sample[1:n_train])
  validation_indices <- c(validation_indices, cat_sample[(n_train+1):n_cat])
}

train_datasets <- valid_dataset_names[train_indices]
validation_datasets <- valid_dataset_names[validation_indices]

cat(sprintf("Training set: %d datasets\n", length(train_datasets)))
cat(sprintf("Validation set: %d datasets\n", length(validation_datasets)))

# List datasets in each split
cat("\nTraining datasets:\n")
for (name in train_datasets) {
  ds_info <- valid_datasets[valid_datasets$dataset_name == name, ]
  cat(sprintf("  - %s (%d studies, %.1f%% sparse)\n",
              name, ds_info$n_studies, 100 * ds_info$sparsity))
}

cat("\nValidation datasets:\n")
for (name in validation_datasets) {
  ds_info <- valid_datasets[valid_datasets$dataset_name == name, ]
  cat(sprintf("  - %s (%d studies, %.1f%% sparse)\n",
              name, ds_info$n_studies, 100 * ds_info$sparsity))
}

# =============================================================================
# PART 5: Save Prepared Data
# =============================================================================

cat("\n========================================\n")
cat("Saving Prepared Data...\n")
cat("========================================\n\n")

# Save dataset list
saveRDS(dataset_list, "dta_methods_research/results/raw/all_datasets.rds")
cat("Saved: dta_methods_research/results/raw/all_datasets.rds\n")

# Save validation results
write.csv(validation_results,
          "dta_methods_research/results/raw/dataset_validation.csv",
          row.names = FALSE)
cat("Saved: dta_methods_research/results/raw/dataset_validation.csv\n")

# Save train/validation splits
write.csv(data.frame(dataset_name = train_datasets, split = "train"),
          "dta_methods_research/results/raw/train_split.csv",
          row.names = FALSE)
write.csv(data.frame(dataset_name = validation_datasets, split = "validation"),
          "dta_methods_research/results/raw/validation_split.csv",
          row.names = FALSE)
cat("Saved: train_split.csv and validation_split.csv\n")

# Create combined dataset info
dataset_info <- validation_results
dataset_info$split <- ifelse(dataset_info$dataset_name %in% train_datasets,
                             "train", "validation")
dataset_info$category <- valid_datasets$category[match(dataset_info$dataset_name,
                                                       valid_dataset_names)]

write.csv(dataset_info,
          "dta_methods_research/results/raw/dataset_info.csv",
          row.names = FALSE)
cat("Saved: dta_methods_research/results/raw/dataset_info.csv\n")

# =============================================================================
# PART 6: Create Quick Reference List
# =============================================================================

cat("\n========================================\n")
cat("Quick Reference\n")
cat("========================================\n\n")

cat("To access a specific dataset:\n\n")
cat("  # Load all datasets\n")
cat("  dataset_list <- readRDS('dta_methods_research/results/raw/all_datasets.rds')\n\n")
cat("  # Access specific dataset\n")
cat("  data <- dataset_list[[\"COVID_AntigenTests_Cochrane2021\"]]\n\n")
cat("  # Get list of all dataset names\n")
cat("  names(dataset_list)\n\n")

cat("Dataset categories:\n")
cat(sprintf("  - mada package: %d datasets\n",
            sum(grepl("^mada_", all_datasets))))
cat(sprintf("  - Published meta-analyses: %d datasets\n",
            sum(grepl("^[A-Z]", all_datasets))))
cat(sprintf("  - Cochrane reviews: %d datasets\n",
            sum(grepl("^Cochrane_", all_datasets))))

# =============================================================================
# Complete
# =============================================================================

cat("\n========================================\n")
cat("Data Loading Complete!\n")
cat("========================================\n")

cat("\nNext steps:\n")
cat("1. Review dataset_info.csv for dataset characteristics\n")
cat("2. Run data_characteristics.R for detailed analysis\n")
cat("3. Proceed to Phase 1: Comprehensive Testing\n")
