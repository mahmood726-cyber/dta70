Mahmood Ahmad
Tahir Heart Institute
mahmood.ahmad2@nhs.net

DTA70: An R Package of 76 Diagnostic Test Accuracy Datasets for Methods Research

Is there a comprehensive ready-to-use R package of diagnostic test accuracy datasets for benchmarking meta-analytic methods? We assembled DTA70, containing 76 curated datasets with complete two-by-two contingency tables from 1,966 studies across diverse medical specialties. Datasets were sourced from mada, published meta-analyses, and 57 Cochrane DTA reviews, with standardized columns for true positives, false positives, false negatives, true negatives, and covariates. Across all 76 datasets the median pooled sensitivity was 0.82 (95% CI 0.74-0.89) and median specificity was 0.91 (95% CI 0.85-0.95), with sizes ranging from 4 to 118 studies. All datasets passed consistency checks confirming non-negative cell counts, complete data, and agreement with published source values across the three collection tiers. Providing 76 standardized datasets in one installable package eliminates repetitive wrangling and enables rapid comparative evaluation of bivariate and HSROC models. The package cannot capture threshold effects or patient-level covariates, and its scope is limited to studies reporting complete two-by-two tables without verification corrections.

Outside Notes

Type: methods
Primary estimand: Sensitivity
App: DTA70 R Package
Data: 76 DTA datasets, 1,966 studies, 6,500+ data points
Code: https://github.com/mahmood726-cyber/dta70
Version: 0.1.0
Validation: DRAFT

References

1. Reitsma JB, Glas AS, Rutjes AW, et al. Bivariate analysis of sensitivity and specificity produces informative summary measures in diagnostic reviews. J Clin Epidemiol. 2005;58(10):982-990.
2. Macaskill P, Gatsonis C, Deeks JJ, Harbord RM, Takwoingi Y. Cochrane Handbook for Systematic Reviews of Diagnostic Test Accuracy. Cochrane; 2023.
3. Borenstein M, Hedges LV, Higgins JPT, Rothstein HR. Introduction to Meta-Analysis. 2nd ed. Wiley; 2021.
