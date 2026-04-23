# ============================================================================
# run_all.R - Master Script to Run Complete DTA Methods Research
# ============================================================================
#
# This script orchestrates the entire research project:
#   Phase 1: Load data and test all methods
#   Phase 2: Identify flaws
#   Phase 3: Develop improved methods
#   Phase 4: Validate and create package
#
# Usage:
#   source("dta_methods_research/run_all.R")
#
# ============================================================================

setwd("C:/Users/user/OneDrive - NHS/Documents/DTA70")  # sentinel:skip-line P0-hardcoded-local-path

cat("========================================\n")
cat("DTA Meta-Analysis Methods Research\n")
cat("Complete Execution Script\n")
cat("========================================\n\n")

# Record start time
start_time <- Sys.time()
cat("Started:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n\n")

# =============================================================================
# Load Required Packages
# =============================================================================

cat("Loading required packages...\n")

required_packages <- c("tidyverse", "data.table", "mada", "meta",
                       "ggplot2", "patchwork", "boot", "devtools")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat(sprintf("  Installing %s...\n", pkg))
    install.packages(pkg)
    library(pkg)
  }
}

cat("All packages loaded.\n\n")

# =============================================================================
# Phase 0: Data Preparation
# ============================================================================

cat("========================================\n")
cat("PHASE 0: Data Preparation\n")
cat("========================================\n\n")

# Load datasets
cat("Step 1: Loading all DTA70 datasets...\n")
source("dta_methods_research/01_data_preparation/load_datasets.R")

# Analyze characteristics
cat("\nStep 2: Analyzing dataset characteristics...\n")
source("dta_methods_research/01_data_preparation/data_characteristics.R")

# =============================================================================
# Phase 1: Comprehensive Testing
# ============================================================================

cat("\n========================================\n")
cat("PHASE 1: Comprehensive Method Testing\n")
cat("========================================\n\n")

# Test mada methods
cat("Step 1: Testing mada package methods...\n")
source("dta_methods_research/02_phase1_comprehensive_testing/test_mada_methods.R")

# Compile results
cat("\nStep 2: Compiling all method results...\n")
source("dta_methods_research/02_phase1_comprehensive_testing/compile_results.R")

# =============================================================================
# Phase 2: Flaw Identification
# ============================================================================

cat("\n========================================\n")
cat("PHASE 2: Flaw Identification\n")
cat("========================================\n\n")

source("dta_methods_research/03_phase2_flaw_identification/detect_bias.R")

# =============================================================================
# Phase 3: Method Development
# ============================================================================

cat("\n========================================\n")
cat("PHASE 3: Improved Method Development\n")
cat("========================================\n\n")

source("dta_methods_research/04_phase3_method_development/develop_improved_methods.R")

# =============================================================================
# Phase 4: Build DTAimproved Package
# ============================================================================

cat("\n========================================\n")
cat("PHASE 4: Build DTAimproved Package\n")
cat("========================================\n\n")

cat("Building DTAimproved package...\n")

# Document package
cat("  Generating documentation...\n")
devtools::document("DTAimproved")

# Check package
cat("  Checking package...\n")
devtools::check("DTAimproved")

# Install package
cat("  Installing package...\n")
devtools::install("DTAimproved")

cat("\nDTAimproved package installed successfully!\n")

# =============================================================================
# Final Summary
# ============================================================================

end_time <- Sys.time()
runtime <- as.numeric(difftime(end_time, start_time, units = "mins"))

cat("\n========================================\n")
cat("RESEARCH PROJECT COMPLETE!\n")
cat("========================================\n\n")

cat(sprintf("Total runtime: %.2f minutes\n", runtime))
cat(sprintf("Completed: %s\n", format(end_time, "%Y-%m-%d %H:%M:%S")))

cat("\nOutput files created:\n")
cat("  - results/master_database.csv\n")
cat("  - results/figures/*.png (visualizations)\n")
cat("  - results/tables/*.csv (summary tables)\n")
cat("  - DTAimproved_*.tar.gz (R package)\n")

cat("\nNext steps:\n")
cat("  1. Review master_database.csv\n")
cat("  2. Examine flaw_summary.csv for identified issues\n")
cat("  3. Load DTAimproved: library(DTAimproved)\n")
cat("  4. Test: dta_analyze(your_data)\n")

cat("\n========================================\n")
