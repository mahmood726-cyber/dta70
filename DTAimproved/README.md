# DTAimproved: Improved Methods for Diagnostic Test Accuracy Meta-Analysis

## Overview

**DTAimproved** provides improved meta-analysis methods for diagnostic test accuracy (DTA) studies, developed through comprehensive evaluation of existing methods across 76 real-world datasets (1,966+ studies).

## Installation

```r
# Install from GitHub
devtools::install_github("mahmood789/DTAimproved")

# Or install from local source
install.packages("path/to/DTAimproved", repos = NULL, type = "source")
```

## Quick Start

```r
library(DTAimproved)

# Load your data (data frame with TP, FP, FN, TN columns)
data <- data.frame(
  TP = c(120, 85, 200, 150),
  FP = c(15, 20, 30, 25),
  FN = c(30, 45, 50, 40),
  TN = c(180, 160, 250, 220)
)

# Quick analysis with automatic method selection
result <- dta_analyze(data)

# Get method recommendation
recommendation <- recommend_method(data)

# Use specific methods
adaptive_result <- dta_adaptive(data)
ensemble_result <- dta_ensemble(data)
robust_result <- dta_robust(data)
```

## Methods Available

| Method | Description | When to Use |
|--------|-------------|-------------|
| `dta_analyze()` | Quick analysis with auto-selection | Everyday use |
| `dta_adaptive()` | Adaptive method selection | Varying data quality |
| `dta_ensemble()` | Ensemble of multiple methods | Maximum robustness |
| `dta_robust()` | Robust trimmed bivariate | High heterogeneity |
| `dta_regularized()` | Regularized sparse data handler | Many zero cells |
| `dta_marginal()` | Marginal pooling | Very small N |
| `dta_bivariate()` | Standard bivariate (Reitsma) | General purpose |

## Features

- **Automatic method selection** based on data characteristics
- **Robust estimators** for sparse data and high heterogeneity
- **Bootstrap confidence intervals** for improved coverage
- **Ensemble methods** combining multiple approaches
- **Comprehensive validation** across 76 real datasets

## Key Improvements Over Standard Methods

1. **Moses-Littenberg bias correction**: The standard Moses-Littenberg method underestimates DOR by 22-47%; our methods correct for this.

2. **Sparse data handling**: Targeted continuity correction and bootstrap CIs for datasets with many zero cells.

3. **Outlier resistance**: Robust trimmed estimation reduces influence of anomalous studies.

4. **Adaptive selection**: Automatically selects the best method based on:
   - Number of studies
   - Data sparsity
   - Heterogeneity (I²)

## Citation

If you use DTAimproved in your research, please cite:

```
DTAimproved: Improved Methods for Diagnostic Test Accuracy Meta-Analysis.
R package version 0.1.0.
```

And cite the original data sources as documented in the DTA70 package.

## License

GPL-3

## References

This package is based on comprehensive evaluation of:
- mada package (Reitsma bivariate model)
- meta package (General meta-analysis)
- 76 datasets from DTA70 package
- 12+ meta-analysis methods tested across 1,966+ studies
