# Add IQCODE dataset from MetaDTA repository
library(usethis)

# Read the IQCODE CSV dataset
iqcode_raw <- read.csv("C:/Users/user/OneDrive - NHS/Documents/DTA70/data-raw/IQCODE.csv",
                       stringsAsFactors = FALSE)

# Create clean dataset
IQCODE_Dementia_MetaDTA <- data.frame(
  author = iqcode_raw$author,
  year = iqcode_raw$year,
  TP = iqcode_raw$TP,
  FP = iqcode_raw$FP,
  FN = iqcode_raw$FN,
  TN = iqcode_raw$TN,
  threshold = iqcode_raw$Threshold,
  country = iqcode_raw$Country,
  iqcode_version = iqcode_raw$IQCODE,
  risk_of_bias_patient_selection = iqcode_raw$rob_PS,
  risk_of_bias_index_test = iqcode_raw$rob_IT,
  risk_of_bias_reference_standard = iqcode_raw$rob_RS,
  risk_of_bias_flow_timing = iqcode_raw$rob_FT,
  applicability_concerns_patient_selection = iqcode_raw$ac_PS,
  applicability_concerns_index_test = iqcode_raw$ac_IT,
  applicability_concerns_reference_standard = iqcode_raw$ac_RS,
  stringsAsFactors = FALSE
)

# Display summary
cat("\n=== IQCODE Dataset for Dementia Screening ===\n\n")
cat("Number of studies:", nrow(IQCODE_Dementia_MetaDTA), "\n")
cat("Years:", min(IQCODE_Dementia_MetaDTA$year), "-", max(IQCODE_Dementia_MetaDTA$year), "\n")
cat("Countries:", paste(unique(IQCODE_Dementia_MetaDTA$country), collapse=", "), "\n")
cat("IQCODE versions:", paste(unique(IQCODE_Dementia_MetaDTA$iqcode_version), collapse=", "), "\n")
cat("Threshold range:", min(IQCODE_Dementia_MetaDTA$threshold), "-",
    max(IQCODE_Dementia_MetaDTA$threshold), "\n\n")

cat("First few studies:\n")
print(head(IQCODE_Dementia_MetaDTA[, c("author", "year", "TP", "FP", "FN", "TN", "threshold")], 5))

# Save to package data
usethis::use_data(IQCODE_Dementia_MetaDTA, overwrite = TRUE)

cat("\n\nDataset saved successfully!\n")
