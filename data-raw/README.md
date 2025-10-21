# Data Processing Scripts

This directory contains scripts for sourcing and processing DTA datasets included in the package.

## Files

- `process_datasets.R`: Main script that sources all datasets from R packages (mada, metafor)
- `additional_datasets_github.R`: Examples and templates for adding datasets from GitHub and other sources

## How to Use

### Initial Setup

To populate the `data/` directory with all datasets:

1. Open R in the package root directory
2. Run the processing script:

```r
source("data-raw/process_datasets.R")
```

This will:
- Install required packages (mada, meta, metafor) if needed
- Load all DTA datasets from source packages
- Save them as .rda files in the `data/` directory

### Adding New Datasets

To add additional datasets:

1. Edit `additional_datasets_github.R` or create a new script
2. Source your dataset (from GitHub, CSV, manual entry, etc.)
3. Use `usethis::use_data(dataset_name)` to save it
4. Document the dataset in `R/datasets.R` using roxygen2 format
5. Run `devtools::document()` to generate documentation
6. Run `devtools::check()` to verify everything works

### Data Sources

Current datasets are sourced from:

- **mada package**: AuditC, Dementia, Lymphangiography, SAT, Telomerase
- **metafor package**: Glas2003, Reitsma2005, Daniels2012, Deeks2005, Scheidler1997

### Best Practices

1. **Always document sources**: Include references to original publications
2. **Maintain data integrity**: Don't modify the original data unless necessary for formatting
3. **Use consistent naming**: Use descriptive names that indicate the test and/or first author
4. **Include metadata**: Add study identifiers, publication years, etc.
5. **Test thoroughly**: Ensure datasets load correctly and are properly documented

### Data Format Standards

All DTA datasets should include:

- **Required**: tp/TP, fp/FP, fn/FN, tn/TN (diagnostic 2x2 table counts)
- **Recommended**: study identifier (author, year, or ID)
- **Optional**: study-level covariates (sample size, setting, etc.)

### Adding Data from Publications

If you extract DTA data from a published systematic review:

1. Create the data frame manually or import from CSV
2. Include full citation in the documentation
3. Note any data processing or cleaning steps
4. Consider reaching out to original authors for permission/verification

## Questions?

See the main README.md for package usage or open an issue on GitHub.
