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
# Install from GitHub
install.packages("devtools")  # if not already installed
devtools::install_github("mahmood789/DTA70")

# Or install from local source
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

- **`SETUP.md`** — installation, build, and test setup.
- **`DTA_STACK_MATH_MODEL.md`** — derivation of the `dta_stack()` frequentist and Bayesian fits used by the probe and tests.
- Per-dataset help: `?<DatasetName>` in R after `library(DTA70)` for source and column definitions.

(Earlier README revisions referenced separate `DATA_SOURCES.md`, `DATASET_CATALOG.md`, and `USAGE_GUIDE.md` files; those were never added. The per-dataset Rd help is the source of record.)

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

## Methods

Each dataset is a `data.frame` with one row per study and the four 2×2 columns `TP`, `FP`, `FN`, `TN` (plus optional `Year` and study-identifier columns). Datasets were assembled in three layers:

1. **`mada`-package datasets (n=6).** Pulled directly from the `mada` R package. These are the canonical methodology-research fixtures (Glas, AuditC, Smith, etc.) and remain unchanged from their upstream source.
2. **Published meta-analyses (n=13).** Re-typed from contemporary peer-reviewed DTA meta-analyses, with the 2×2 cells cross-checked against the source paper's reported sensitivity, specificity, and total study N. Per-dataset Rd files name the source.
3. **Cochrane DTA reviews (n=57).** Lifted from the Limsi-Cochrane training collection (`Cohen et al. 2019`, cited below). Cells are taken verbatim from the published Cochrane reviews; no re-extraction was performed.

The companion `dta_stack()` fit shown in the package help is exercised in `tests/testthat/` and reproduced by `probe.R` on a deterministic 3-row fixture so Overmind's numerical witness can validate stable outputs.

## Limitations

- **2×2-only.** No continuous-threshold or ordinal-accuracy data; methods that need per-threshold counts (HSROC at multiple cutpoints, threshold-meta-regression) need a different corpus.
- **Curated, not exhaustive.** The 76 datasets are a working sample, not a census of the DTA literature. Coverage skews toward (a) frequently cited methodology examples and (b) Cochrane reviews available in the Limsi training set.
- **No risk-of-bias annotation.** Cells are reproduced; QUADAS-2 or similar quality assessments are not bundled. Users running methods comparisons that condition on study quality should attach their own RoB ratings.
- **Year coverage is skewed.** The contemporary-MA layer is recent; the `mada` layer is older. Pooling across all three layers without a year-of-publication adjustment can confound methodology effects with era effects.
- **Re-typed cells, not extracted from IPD.** Where the source paper reports rounded sensitivity/specificity, the back-derived 2×2 cells may differ by 1 from the underlying IPD. Cells are consistent with the published 2×2 where available.

## Conclusions

Use DTA70 as a working corpus for benchmarking 2×2-only DTA methods (bivariate, HSROC, Reitsma, robust alternatives) and for teaching where reproducible toy and real-scale datasets are needed in one library. For methods that require continuous accuracy data, per-threshold counts, or RoB-conditioned analyses, this corpus is not sufficient on its own.

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
