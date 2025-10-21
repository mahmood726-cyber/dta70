# Additional DTA Datasets from GitHub and Other Sources
# This script demonstrates how to add more DTA datasets to the package

library(usethis)

# ===========================================================================
# EXAMPLE: Adding datasets from GitHub repositories
# ===========================================================================

# Example 1: If there's a CSV file on GitHub with DTA data
# Uncomment and modify the following template:

# library(readr)
# url <- "https://raw.githubusercontent.com/username/repo/main/data/dta_dataset.csv"
# DTA_Example <- read_csv(url)
#
# # Ensure it has the correct format (tp, fp, fn, tn)
# # Add any necessary data cleaning here
#
# usethis::use_data(DTA_Example, overwrite = TRUE)

# ===========================================================================
# EXAMPLE: Creating DTA data from published papers
# ===========================================================================

# If you extract data from a published paper, create it manually:
#
# PaperName_Year <- data.frame(
#   study = c("Study1", "Study2", "Study3"),
#   tp = c(50, 45, 60),
#   fp = c(10, 15, 8),
#   fn = c(5, 8, 3),
#   tn = c(85, 82, 89),
#   author = c("Smith", "Jones", "Brown"),
#   year = c(2015, 2016, 2017)
# )
#
# usethis::use_data(PaperName_Year, overwrite = TRUE)

# ===========================================================================
# EXAMPLE: Datasets from other R packages
# ===========================================================================

# Example: metafor has many DTA datasets
# Explore available datasets:
# data(package = "metafor")

# Additional metafor datasets you could add:
library(metafor)

# 1. Hatzinger et al. (2002) - Depression screening
if (requireNamespace("metafor", quietly = TRUE)) {
  tryCatch({
    data(dat.hine1989, package = "metafor")
    Depression_Hine1989 <- dat.hine1989
    usethis::use_data(Depression_Hine1989, overwrite = TRUE)
    cat("Added Depression_Hine1989 dataset\n")
  }, error = function(e) {
    cat("Dataset dat.hine1989 not available in this version of metafor\n")
  })
}

# ===========================================================================
# EXAMPLE: Web scraping DTA data from Cochrane reviews
# ===========================================================================

# Many Cochrane diagnostic test accuracy reviews publish their data
# You could scrape these with rvest, but ensure you comply with their terms

# library(rvest)
# library(xml2)
#
# # Example template (do not run without proper permissions):
# # url <- "https://www.cochranelibrary.com/cdsr/doi/..."
# # page <- read_html(url)
# #
# # # Extract tables with DTA data
# # dta_table <- page %>%
# #   html_nodes("table") %>%
# #   html_table()
# #
# # # Process and save

# ===========================================================================
# Tips for adding new datasets:
# ===========================================================================

# 1. Always ensure datasets have:
#    - tp, fp, fn, tn (or TP, FP, FN, TN)
#    - Study identifiers (author, year, or study ID)
#    - Clear reference to the source publication

# 2. Document each dataset in R/datasets.R using roxygen2 format

# 3. Include proper citations and references

# 4. Test that datasets load correctly:
#    devtools::load_all()
#    data(YourDataset)
#    str(YourDataset)

cat("\nTo add new datasets:\n")
cat("1. Add data sourcing code to this file or process_datasets.R\n")
cat("2. Document the dataset in R/datasets.R\n")
cat("3. Run devtools::document() to generate .Rd files\n")
cat("4. Run devtools::check() to ensure package passes CRAN checks\n")
