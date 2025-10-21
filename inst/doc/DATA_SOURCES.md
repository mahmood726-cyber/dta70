# Data Sources and Collection Process

## Overview

The DTA70 package contains 76 diagnostic test accuracy (DTA) datasets compiled from multiple sources. This document describes the systematic process used to identify, extract, and curate these datasets.

## Data Collection Process

### Phase 1: R Package Survey

We systematically searched CRAN for R packages containing DTA datasets with complete 2x2 contingency table data (TP, FP, FN, TN).

**Packages examined:**
- `mada` - Meta-Analysis of Diagnostic Accuracy (Doebler & Holling, 2015)
- `metafor` - Meta-Analysis Package (Viechtbauer, 2010)
- `diagmeta` - Meta-Analysis of Diagnostic Accuracy Studies (Schwarzer et al., 2023)
- `meta4diag` - Bayesian Bivariate Meta-Analysis (Guo & Riebler, 2018)
- `bamdit` - Bayesian Meta-Analysis of Diagnostic Test Data (Verde, 2018)
- `dmetatools` - Diagnostic Meta-Analysis Tools

**Result:** 6 datasets extracted from the `mada` package with complete documentation and study-level data.

### Phase 2: Published Meta-Analyses

We identified high-quality published DTA meta-analyses from peer-reviewed journals and Cochrane reviews that included extractable 2x2 table data.

**Selection criteria:**
- Published in peer-reviewed journals or Cochrane Database
- Complete 2x2 contingency tables reported
- Multiple studies (≥10 preferred)
- Diverse medical conditions and test types
- High-quality methodology (QUADAS assessment when available)

**Result:** 13 datasets from published meta-analyses covering cardiology, infectious disease, oncology, neurology, and emergency medicine.

### Phase 3: Limsi-Cochrane DTA Collection

We accessed the Limsi-Cochrane Training Set (Zenodo DOI: 10.5281/zenodo.1303259), a structured XML dataset containing 63 Cochrane systematic reviews of diagnostic test accuracy.

**Extraction process:**
1. Downloaded the Limsi-Cochrane XML dataset (19 MB, 63 reviews)
2. Developed XML parsing scripts to extract `<result>` tags containing diagnostic accuracy data
3. Extracted study_id, TP, FP, FN, TN values for each meta-analysis
4. Validated data integrity and completeness
5. Successfully extracted 57 reviews with usable 2x2 table data

**Technical details:**
- XML parsing using `xml2` package
- XPath queries to locate nested result elements
- Data validation to ensure complete 2x2 tables
- Exclusion of 6 reviews due to insufficient extractable data

### Phase 4: GitHub Repositories

We searched GitHub for DTA-related repositories with example datasets.

**Repositories examined:**
- MetaDTA Shiny application (CRSU-Apps/MetaDTA)
- Various diagnostic accuracy research repositories

**Result:** 1 additional dataset (IQCODE for dementia) with complete quality assessment ratings.

## Data Quality Assurance

All datasets underwent quality checks:
1. Verification of complete 2x2 contingency tables (TP, FP, FN, TN)
2. Removal of rows with missing or invalid values
3. Consistency checks for logical relationships (e.g., TP + FN = diseased patients)
4. Documentation of data sources and references

## Dataset Categories

### Category 1: Curated Research Datasets (6 datasets)
**Source:** mada R package
**Characteristics:** Well-documented, frequently used in methodology papers, diverse medical conditions
**Total studies:** 159

### Category 2: Published Meta-Analyses (13 datasets)
**Source:** Peer-reviewed journals and recent Cochrane reviews
**Characteristics:** Contemporary clinical topics, often includes covariates, high methodological quality
**Total studies:** 220

### Category 3: Cochrane DTA Reviews (57 datasets)
**Source:** Limsi-Cochrane collection (Zenodo)
**Characteristics:** Comprehensive systematic reviews, standardized Cochrane methodology, diverse specialties
**Total studies:** 1,587

## Comparison to Other DTA Data Resources

| Resource | Number of Datasets | Total Studies | Data Format | Accessibility |
|----------|-------------------|---------------|-------------|---------------|
| DTA70 | 76 | 1,966+ | R data objects | R package |
| mada package | 6 | 159 | R data objects | R package |
| diagmeta package | 4 | ~100 | R data objects | R package |
| metafor package | 5 DTA datasets | ~50 | R data objects | R package |
| Limsi-Cochrane (raw) | 63 | 1,939 | XML | Zenodo repository |
| DTAmetadata (web) | Variable | Variable | Web interface | Online database |

**Unique features of DTA70:**
- Largest collection of ready-to-use DTA datasets in R
- Standardized format across all datasets
- Comprehensive documentation
- Includes both classic and contemporary clinical topics
- Combines curated research datasets with complete Cochrane reviews

## Data Coverage

### Medical Specialties Represented
- Infectious disease (20+ datasets)
- Oncology (15+ datasets)
- Neurology (10+ datasets)
- Cardiology (5+ datasets)
- Gastroenterology (8+ datasets)
- Ophthalmology (3+ datasets)
- Emergency medicine (3+ datasets)
- Prenatal screening (3+ datasets)
- Mental health (4+ datasets)
- Other specialties (5+ datasets)

### Diagnostic Accuracy Range
- High accuracy tests (balanced accuracy ≥85%): 25 datasets (32.9%)
- Good accuracy tests (balanced accuracy 75-84%): 29 datasets (38.2%)
- Moderate accuracy tests (balanced accuracy <75%): 22 datasets (28.9%)

This range enables testing of meta-analytic methods across different accuracy scenarios.

## References

**Data Sources:**
1. Doebler, P. & Holling, H. (2015). Meta-Analysis of Diagnostic Accuracy with mada. R package.
2. Cohen, K. B., et al. (2019). Limsi-Cochrane Training Set of Systematic Reviews of Diagnostic Test Accuracy. Zenodo. DOI: 10.5281/zenodo.1303259
3. Schwarzer, G., et al. (2023). diagmeta: Meta-Analysis of Diagnostic Accuracy Studies with Several Cutpoints. R package.
4. Freeman, S. C., et al. (2019). Development of an interactive web-based tool to conduct and interrogate meta-analysis of diagnostic test accuracy studies: MetaDTA. BMC Medical Research Methodology, 19(1), 81.

## Data Updates

This package represents a snapshot of available DTA data as of 2025. The Limsi-Cochrane collection may be updated in future releases as new Cochrane reviews become available.

## Acknowledgments

We acknowledge the original authors and data curators:
- mada package authors for well-documented DTA examples
- Cochrane DTA review authors for rigorous systematic reviews
- Limsi-Cochrane team for making structured DTA data publicly available
- MetaDTA developers for sharing example datasets
