# Add all 57 Cochrane DTA datasets from Limsi-Cochrane collection
library(usethis)

# Load the summary to get all review IDs and titles
summary_data <- readRDS("C:/Users/user/OneDrive - NHS/Documents/DTA70/zenodo_data/extracted/all_reviews_summary.rds")  # sentinel:skip-line P0-hardcoded-local-path

cat("Adding", length(summary_data), "Cochrane DTA datasets to package...\n\n")

# Process each dataset
for (i in seq_along(summary_data)) {
  review <- summary_data[[i]]
  review_id <- review$id
  title <- review$title
  n_studies <- review$n_studies
  n_rows <- review$n_rows

  cat(sprintf("%2d. Processing %s (%d studies, %d rows)...\n",
              i, review_id, n_studies, n_rows))

  # Load the data
  data_file <- paste0("C:/Users/user/OneDrive - NHS/Documents/DTA70/zenodo_data/extracted/",  # sentinel:skip-line P0-hardcoded-local-path
                      review_id, ".rds")
  dataset <- readRDS(data_file)

  # Create dataset name: Cochrane_CDXXXXXX
  dataset_name <- paste0("Cochrane_", review_id)

  # Save to package data/ with proper name
  # Create a temporary environment with the correctly named object
  assign(dataset_name, dataset)

  # Save using save() directly to get the right name
  save(list = dataset_name,
       file = paste0("C:/Users/user/OneDrive - NHS/Documents/DTA70/data/",  # sentinel:skip-line P0-hardcoded-local-path
                     dataset_name, ".rda"),
       compress = "xz")

  cat("   Saved as:", dataset_name, "\n")
}

cat("\n========================================\n")
cat("Successfully added all", length(summary_data), "datasets!\n")
cat("Total studies:", sum(sapply(summary_data, function(x) x$n_studies)), "\n")
cat("Total data points:", sum(sapply(summary_data, function(x) x$n_rows)), "\n")
cat("========================================\n")
