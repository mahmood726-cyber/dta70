# DTA70 Usage Guide

## Installation

```r
# Install from local source
install.packages("path/to/DTA70_0.1.0.tar.gz", repos = NULL, type = "source")

# Or using devtools
devtools::install_local("path/to/DTA70")
```

## Basic Usage

### Loading the Package

```r
library(DTA70)
```

### Viewing Available Datasets

```r
# List all datasets
data(package = "DTA70")

# Load a specific dataset
data(Dementia_data)
head(Dementia_data)
```

### Accessing Dataset Documentation

```r
# View documentation for a dataset
?Dementia_data
?Cochrane_CD008803
```

## Example Analyses

### Example 1: Basic Diagnostic Accuracy Meta-Analysis

```r
library(DTA70)
library(mada)

# Load dataset
data(Dementia_data)

# Fit bivariate meta-analysis
fit <- reitsma(Dementia_data)
summary(fit)

# Create forest plot
forest(fit)

# Create SROC curve
plot(fit, sroc.type = "roc")
```

### Example 2: Meta-Analysis with Covariates

```r
library(DTA70)
library(metafor)

# Load dataset with covariates
data(FENO_Asthma_Schneider2017)

# Calculate log diagnostic odds ratio
FENO_Asthma_Schneider2017$logDOR <- with(FENO_Asthma_Schneider2017,
                                          log((TP * TN) / (FP * FN)))

# Calculate variance
FENO_Asthma_Schneider2017$var_logDOR <- with(FENO_Asthma_Schneider2017,
                                              1/TP + 1/FP + 1/FN + 1/TN)

# Meta-analysis
res <- rma(yi = logDOR, vi = var_logDOR, data = FENO_Asthma_Schneider2017,
           method = "REML")
summary(res)
```

### Example 3: Sensitivity and Specificity Calculation

```r
library(DTA70)

# Load any dataset
data(COVID_AntigenTests_Cochrane2021)

# Calculate sensitivity and specificity
COVID_AntigenTests_Cochrane2021$sensitivity <-
  with(COVID_AntigenTests_Cochrane2021, TP / (TP + FN))

COVID_AntigenTests_Cochrane2021$specificity <-
  with(COVID_AntigenTests_Cochrane2021, TN / (TN + FP))

# Summary statistics
summary(COVID_AntigenTests_Cochrane2021[, c("sensitivity", "specificity")])
```

### Example 4: Using Cochrane Review Datasets

```r
library(DTA70)
library(mada)

# Load a large Cochrane dataset
data(Cochrane_CD008803)  # Glaucoma - 105 studies

# Basic summary
cat("Dataset:", "Cochrane_CD008803\n")
cat("Studies:", length(unique(Cochrane_CD008803$study_id)), "\n")
cat("Data points:", nrow(Cochrane_CD008803), "\n")

# Calculate pooled sensitivity and specificity
Cochrane_CD008803$sens <- with(Cochrane_CD008803, TP / (TP + FN))
Cochrane_CD008803$spec <- with(Cochrane_CD008803, TN / (TN + FP))

cat("\nPooled estimates (simple mean):\n")
cat("Sensitivity:", round(mean(Cochrane_CD008803$sens), 3), "\n")
cat("Specificity:", round(mean(Cochrane_CD008803$spec), 3), "\n")
```

### Example 5: Comparing Multiple Datasets

```r
library(DTA70)

# Function to get summary statistics
get_summary <- function(dataset_name) {
  data(list = dataset_name, envir = environment())
  ds <- get(dataset_name)

  ds$sens <- ds$TP / (ds$TP + ds$FN)
  ds$spec <- ds$TN / (ds$TN + ds$FP)

  data.frame(
    dataset = dataset_name,
    n = nrow(ds),
    mean_sens = mean(ds$sens, na.rm = TRUE),
    mean_spec = mean(ds$spec, na.rm = TRUE),
    median_sens = median(ds$sens, na.rm = TRUE),
    median_spec = median(ds$spec, na.rm = TRUE)
  )
}

# Compare several infectious disease datasets
datasets <- c("TB_SmearMicroscopy_Steingart2006",
              "XpertMTB_RIF_Tuberculosis2014",
              "COVID_AntigenTests_Cochrane2021",
              "Cochrane_CD009593")  # Xpert TB

results <- do.call(rbind, lapply(datasets, get_summary))
print(results)
```

### Example 6: Threshold Effect Analysis

```r
library(DTA70)

# Load dataset with multiple cutpoints
data(FENO_Asthma_Schneider2017)

# This dataset has 150 rows from 29 studies
# Multiple cutpoints per study indicate threshold effects

# Check for threshold effects by examining correlation
FENO_Asthma_Schneider2017$logit_sens <- with(FENO_Asthma_Schneider2017,
                                              log(TP / FN))
FENO_Asthma_Schneider2017$logit_spec <- with(FENO_Asthma_Schneider2017,
                                              log(TN / FP))

cor.test(FENO_Asthma_Schneider2017$logit_sens,
         FENO_Asthma_Schneider2017$logit_spec)

# Negative correlation suggests threshold effect
```

### Example 7: Publication Bias Assessment

```r
library(DTA70)
library(metafor)

# Load dataset
data(Depression_Screening_Gilbody2008)

# Calculate log odds ratio
Depression_Screening_Gilbody2008$logOR <- with(Depression_Screening_Gilbody2008,
                                                log((TP * TN) / (FP * FN)))

Depression_Screening_Gilbody2008$SE <- with(Depression_Screening_Gilbody2008,
                                             sqrt(1/TP + 1/FP + 1/FN + 1/TN))

# Funnel plot
with(Depression_Screening_Gilbody2008,
     funnel(logOR, SE))

# Egger's test
res <- rma(yi = logOR, sei = SE, data = Depression_Screening_Gilbody2008)
regtest(res)
```

## Working with Different Dataset Types

### Original Curated Datasets
These datasets (from `mada` package) typically include author names and years:
- `AuditC_data`
- `Dementia_data`
- `IAQ_data`
- `SAQ_data`
- `Smoking_data`
- `SkinTests_data`

### Contemporary Meta-Analysis Datasets
These include recent clinical topics with additional covariates:
- `COVID_AntigenTests_Cochrane2021`
- `POCUS_Shock_Yoshida2023`
- `DDimer_PE_Crawford2020`

### Cochrane Review Datasets
All datasets starting with `Cochrane_CD` contain:
- `review_id`: Cochrane review identifier
- `study_id`: Individual study identifier
- `TP`, `FP`, `FN`, `TN`: Contingency table counts

Example:
```r
data(Cochrane_CD010502)  # Strep throat rapid tests - 116 studies
str(Cochrane_CD010502)
```

## Tips for Analysis

### Handling Zero Cells

Some studies may have zero cells (0 TP, FP, FN, or TN), which can cause issues in meta-analysis:

```r
# Add continuity correction
add_correction <- function(df, correction = 0.5) {
  df$TP <- df$TP + correction
  df$FP <- df$FP + correction
  df$FN <- df$FN + correction
  df$TN <- df$TN + correction
  return(df)
}

# Use only when necessary
data(your_dataset)
if (any(c(your_dataset$TP, your_dataset$FP,
          your_dataset$FN, your_dataset$TN) == 0)) {
  your_dataset <- add_correction(your_dataset)
}
```

### Selecting Appropriate Models

- **Bivariate model** (Reitsma): Accounts for correlation between sensitivity and specificity
- **HSROC model**: Allows for threshold effects
- **Univariate models**: Separate analyses of sensitivity and specificity (less recommended)

### Handling Multiple Rows per Study

Some studies contribute multiple rows (different thresholds, subgroups, or tests):

```r
# Count observations per study
data(FENO_Asthma_Schneider2017)
table(table(FENO_Asthma_Schneider2017$author))

# Option 1: Analyze all data points (accounts for within-study correlation if model allows)
# Option 2: Select one cutpoint per study
# Option 3: Use multilevel meta-analysis models
```

## Common Issues and Solutions

### Issue 1: Dataset Not Found
```r
# Ensure package is loaded
library(DTA70)

# Check dataset name (case-sensitive)
data(package = "DTA70")
```

### Issue 2: Missing Values
```r
# Check for missing values
data(your_dataset)
summary(your_dataset)

# Remove rows with missing values
your_dataset_complete <- your_dataset[complete.cases(your_dataset), ]
```

### Issue 3: Convergence Problems in Meta-Analysis
```r
# Try different starting values or estimation methods
# Use simpler models if bivariate doesn't converge
# Check for extremely small or large cell counts
```

## Further Resources

- `mada` package documentation: https://cran.r-project.org/package=mada
- `metafor` package documentation: https://www.metafor-project.org/
- Cochrane Handbook for DTA reviews: https://training.cochrane.org/handbook-diagnostic-test-accuracy

## Citation

If you use the DTA70 package in your research, please cite:

```
DTA70: Real Diagnostic Test Accuracy Datasets for Methodology Research.
R package version 0.1.0.
```

And cite the original data sources as documented in each dataset's help file.
