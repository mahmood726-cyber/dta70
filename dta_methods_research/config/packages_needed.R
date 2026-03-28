# ============================================================================
# packages_needed.R - Install All Required R Packages
# ============================================================================
#
# Run this script to install all packages needed for the DTA methods research.
#
# ============================================================================

cat("========================================\n")
cat("Installing Required R Packages\n")
cat("========================================\n\n")

# List of all required packages
packages <- list(
  # Core DTA packages
  core = c("mada", "meta", "metafor", "diagmeta", "metadta", "NMADTA"),

  # Bayesian packages
  bayesian = c("meta4diag", "rstan", "rjags", "bamdit"),

  # Utility packages
  utility = c("tidyverse", "data.table", "boot", "MVN", "copula", "lme4", "glmmTMB"),

  # Visualization packages
  visualization = c("ggplot2", "forestplot", "patchwork", "gridExtra", "cowplot"),

  # Development packages
  development = c("devtools", "roxygen2", "usethis", "testthat"),

  # Reporting packages
  reporting = c("knitr", "rmarkdown", "tinytex", "DT", "kableExtra"),

  # Additional analysis packages
  analysis = c("glmnet", "robustbase", "broom")
)

# Function to install packages from CRAN
install_from_cran <- function(pkg_list) {
  for (pkg in pkg_list) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(sprintf("Installing %s...\n", pkg))
      tryCatch({
        install.packages(pkg, dependencies = TRUE)
        library(pkg, character.only = TRUE)
        cat(sprintf("  ✓ %s installed\n", pkg))
      }, error = function(e) {
        cat(sprintf("  ✗ %s failed: %s\n", pkg, e$message))
      })
    } else {
      cat(sprintf("  ✓ %s already installed\n", pkg))
    }
  }
}

# Function to install from GitHub
install_from_github <- function(pkg, repo) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("Installing %s from GitHub (%s)...\n", pkg, repo))
    tryCatch({
      devtools::install_github(repo)
      library(pkg, character.only = TRUE)
      cat(sprintf("  ✓ %s installed\n", pkg))
    }, error = function(e) {
      cat(sprintf("  ✗ %s failed: %s\n", pkg, e$message))
    })
  } else {
    cat(sprintf("  ✓ %s already installed\n", pkg))
  }
}

# Install by category
cat("Installing core DTA packages...\n")
install_from_cran(packages$core)

cat("\nInstalling utility packages...\n")
install_from_cran(packages$utility)

cat("\nInstalling visualization packages...\n")
install_from_cran(packages$visualization)

cat("\nInstalling development packages...\n")
install_from_cran(packages$development)

cat("\nInstalling reporting packages...\n")
install_from_cran(packages$reporting)

cat("\nInstalling analysis packages...\n")
install_from_cran(packages$analysis)

# Bayesian packages (may require additional setup)
cat("\nInstalling Bayesian packages...\n")
install_from_cran(packages$bayesian)

# GitHub packages
cat("\nInstalling packages from GitHub...\n")
# Add any GitHub packages here if needed

# Check for DTa70
cat("\nChecking for DTA70 package...\n")
if (!require("DTA70", quietly = TRUE)) {
  cat("  DTA70 not found. Make sure to install from source.\n")
  cat("  Command: install.packages('path/to/DTA70', repos = NULL)\n")
} else {
  cat("  ✓ DTA70 installed\n")
}

# =============================================================================
# Summary
# =============================================================================

cat("\n========================================\n")
cat("Package Installation Complete!\n")
cat("========================================\n\n")

# Check which packages are available
all_packages <- unlist(packages)
installed <- sapply(all_packages, function(p) {
  require(p, character.only = TRUE, quietly = TRUE)
})

cat("Package Status:\n")
for (pkg in names(installed)) {
  status <- ifelse(installed[pkg], "✓", "✗")
  cat(sprintf("  %s %s\n", status, pkg))
}

cat(sprintf("\n%d of %d packages installed\n",
            sum(installed), length(installed)))
