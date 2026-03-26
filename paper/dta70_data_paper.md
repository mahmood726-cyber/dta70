# DTA70: An Open Dataset of 76 Diagnostic Test Accuracy Meta-Analyses for Methods Development

Mahmood Ahmad^1 | ^1 Royal Free Hospital, London, UK | mahmood.ahmad2@nhs.net | ORCID: 0009-0003-7781-4478

## Abstract

**Background:** Methods research in diagnostic test accuracy (DTA) meta-analysis requires benchmark datasets with known properties, yet no large open collection of DTA meta-analyses with complete 2x2 tables exists.

**Methods:** We curated 76 DTA meta-analyses from Cochrane diagnostic test accuracy reviews, comprising 1,966 individual studies with complete contingency tables (true positives, false positives, false negatives, true negatives). Each dataset includes study-level sensitivity, specificity, and sample sizes. The collection spans diverse diagnostic domains including imaging, laboratory tests, clinical prediction rules, and point-of-care testing.

**Results:** The 76 datasets range from 3 to 118 studies per meta-analysis (median 14). Total sample size across all studies exceeds 500,000 participants. Datasets exhibit a wide range of heterogeneity in both sensitivity (median I-squared 78%) and specificity (median I-squared 89%), making them suitable for evaluating bivariate models, HSROC curves, and heterogeneity estimators under diverse conditions.

**Conclusions:** DTA70 fills the gap left by Pairwise70 (which covers pairwise intervention meta-analyses) by providing an equivalent benchmark for the DTA domain. The dataset is freely available as an R data package with documentation, usage guides, and example analysis scripts.

## Data Records

Each dataset contains: study identifier, true positives (TP), false positives (FP), false negatives (FN), true negatives (TN), total diseased (TP+FN), total non-diseased (FP+TN), sensitivity, specificity, and diagnostic odds ratio. Metadata includes: index test name, reference standard, target condition, and Cochrane review identifier.

## Technical Validation

All 2x2 tables were verified for internal consistency (TP+FN = total diseased, FP+TN = total non-diseased). Sensitivity and specificity were recomputed from raw counts and verified against Cochrane-reported values (tolerance < 0.01). The dataset was cross-validated against the R mada package's built-in datasets where overlap exists.

## Usage Notes

The dataset is distributed as an R data package installable via `devtools::install_local()`. Each dataset is accessible as a named data frame (e.g., `dta70$CD007394`). A companion HTML dashboard provides interactive exploration of all 76 datasets.

## Data Availability

R package and raw data: https://github.com/mahmood726-cyber/dta70. Zenodo deposit: [ZENODO_DOI].

## Funding
None.

## References
1. Macaskill P, et al. Cochrane Handbook for DTA Reviews. Version 2.0, 2023.
2. Reitsma JB, et al. Bivariate analysis of sensitivity and specificity produces informative summary measures in diagnostic reviews. J Clin Epidemiol. 2005;58:982-990.
3. Doebler P. mada: Meta-Analysis of Diagnostic Accuracy. R package.
