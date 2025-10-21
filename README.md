# DTA70: Diagnostic Test Accuracy Datasets for R

## Overview

DTA70 is an R package containing 76 diagnostic test accuracy (DTA) datasets with complete 2x2 contingency table data from 1,966+ individual studies. Designed for researchers developing and testing meta-analytic methods for diagnostic accuracy studies.

## Contents

- **76 datasets** with complete TP, FP, FN, TN data
- **1,966+ studies** across all datasets  
- **6,500+ data points**
- **Diverse medical specialties**

## Installation

```r
# Install from local source
install.packages("path/to/DTA70_0.1.0.tar.gz", repos = NULL, type = "source")
```

## Quick Start

```r
library(DTA70)

# View available datasets
data(package = "DTA70")

# Load a dataset
data(COVID_AntigenTests_Cochrane2021)

# Calculate sensitivity and specificity
COVID_AntigenTests_Cochrane2021$sens <- with(COVID_AntigenTests_Cochrane2021, 
                                              TP / (TP + FN))
COVID_AntigenTests_Cochrane2021$spec <- with(COVID_AntigenTests_Cochrane2021, 
                                              TN / (TN + FP))
```

## Documentation

Comprehensive documentation is provided:

- **DATA_SOURCES.md** - Data collection process and sources
- **DATASET_CATALOG.md** - Complete catalog with descriptions
- **USAGE_GUIDE.md** - Detailed usage examples

## Dataset Categories

### Curated Research Datasets (6)
From the `mada` package - frequently used in methodology research

### Published Meta-Analyses (13)
Contemporary clinical topics from peer-reviewed journals

### Cochrane DTA Reviews (57)
Complete systematic reviews from the Limsi-Cochrane collection

## Key Features

- Standardized format (all include TP, FP, FN, TN)
- Ready to use (no additional cleaning required)
- Well-documented with references
- Diverse accuracy range and sample sizes

## Use Cases

- Meta-analytic methods development
- Simulation studies and benchmarking  
- Teaching and courses
- Meta-regression research
- Heterogeneity investigation

## Citation

If you use DTA70 in your research, please cite:

```
DTA70: Real Diagnostic Test Accuracy Datasets for Methodology Research.
R package version 0.1.0.
```

And cite the original data sources as documented in each dataset's help file.

For Cochrane datasets, also cite:
```
Cohen, K. B., et al. (2019). Limsi-Cochrane Training Set of Systematic
Reviews of Diagnostic Test Accuracy. Zenodo. DOI: 10.5281/zenodo.1303259
```

## License

GPL-3
