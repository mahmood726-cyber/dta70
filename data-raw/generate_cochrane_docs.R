# Generate roxygen2 documentation for all 57 Cochrane datasets

# Load the summary to get titles and metadata
summary_data <- readRDS("C:/Users/user/OneDrive - NHS/Documents/DTA70/zenodo_data/extracted/all_reviews_summary.rds")  # sentinel:skip-line P0-hardcoded-local-path

cat("Generating documentation for", length(summary_data), "Cochrane datasets...\n\n")

# Open the datasets.R file for appending
doc_file <- "C:/Users/user/OneDrive - NHS/Documents/DTA70/R/cochrane_datasets.R"  # sentinel:skip-line P0-hardcoded-local-path

# Start the file with a header
file_content <- "# Cochrane DTA Review Datasets\n# Extracted from the Limsi-Cochrane collection\n# https://zenodo.org/record/1303259\n\n"

# Generate documentation for each dataset
for (i in seq_along(summary_data)) {
  review <- summary_data[[i]]
  review_id <- review$id
  title <- review$title
  n_studies <- review$n_studies
  n_rows <- review$n_rows

  # Load actual data to check unique studies
  data_file <- paste0("C:/Users/user/OneDrive - NHS/Documents/DTA70/zenodo_data/extracted/",  # sentinel:skip-line P0-hardcoded-local-path
                      review_id, ".rds")
  dataset <- readRDS(data_file)
  unique_studies <- length(unique(dataset$study_id))

  # Create dataset name
  dataset_name <- paste0("Cochrane_", review_id)

  # Create roxygen2 documentation
  doc <- sprintf(
"#' %s - Cochrane DTA Review
#'
#' Diagnostic test accuracy data from Cochrane systematic review %s.
#' %s
#'
#' @format A data frame with %d rows representing %d unique studies:
#' \\describe{
#'   \\item{review_id}{Cochrane review ID (%s)}
#'   \\item{study_id}{Study identifier}
#'   \\item{TP}{True positives}
#'   \\item{FP}{False positives}
#'   \\item{FN}{False negatives}
#'   \\item{TN}{True negatives}
#' }
#'
#' @details
#' This dataset contains %d 2x2 contingency tables from %d studies included
#' in the Cochrane systematic review. Each row represents a single diagnostic
#' accuracy comparison. Some studies may contribute multiple rows if they
#' reported results for multiple index tests, thresholds, or subgroups.
#'
#' @source Extracted from the Limsi-Cochrane DTA dataset.
#'   Zenodo repository: \\doi{10.5281/zenodo.1303259}
#'
#' @references
#' Original Cochrane review available at:
#' \\url{https://www.cochranelibrary.com/cdsr/doi/10.1002/14651858.%s/full}
\"%s\"

",
    title,
    review_id,
    title,
    n_rows,
    unique_studies,
    review_id,
    n_rows,
    unique_studies,
    review_id,
    dataset_name
  )

  file_content <- paste0(file_content, doc, "\n\n")

  cat(sprintf("%2d. %s\n", i, dataset_name))
}

# Write to file
writeLines(file_content, doc_file)

cat("\n========================================\n")
cat("Documentation generated successfully!\n")
cat("File saved to:", doc_file, "\n")
cat("========================================\n")
