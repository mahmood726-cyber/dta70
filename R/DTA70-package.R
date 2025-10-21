#' @keywords internal
"_PACKAGE"

#' DTA70: Real Diagnostic Test Accuracy Datasets
#'
#' A collection of 76 diagnostic test accuracy (DTA) datasets for methodology
#' research. This package provides authentic DTA data from published
#' meta-analyses and systematic reviews, enabling researchers to develop and
#' validate statistical methods for diagnostic accuracy synthesis. Represents
#' one of the larger collections of ready-to-use DTA datasets in R.
#'
#' @section Dataset Overview:
#' The package includes 76 real DTA datasets covering various medical
#' conditions and diagnostic tests:
#'
#' \strong{From mada package (6 datasets, 159 studies):}
#' \itemize{
#'   \item \code{AuditC_data}: Alcohol screening (14 studies)
#'   \item \code{Dementia_data}: Dementia diagnosis (33 studies)
#'   \item \code{IAQ_data}: IAQ screening instrument (20 studies)
#'   \item \code{SAQ_data}: SAQ screening instrument (31 studies)
#'   \item \code{Smoking_data}: Smoking cessation tests (51 studies)
#'   \item \code{SkinTests_data}: Skin tests (10 studies)
#' }
#'
#' \strong{From published meta-analyses and repositories (13 datasets, 220 studies):}
#' \itemize{
#'   \item \code{FENO_Asthma_Schneider2017}: FENO for asthma (29 studies, 150 rows)
#'   \item \code{CT_Colonography_Whiting2011}: CT colonography (10 studies)
#'   \item \code{TB_SmearMicroscopy_Steingart2006}: TB microscopy (20 studies)
#'   \item \code{COVID_AntigenTests_Cochrane2021}: COVID antigen tests (20 studies)
#'   \item \code{Depression_Screening_Gilbody2008}: Depression screening (13 studies)
#'   \item \code{DVT_Ultrasound_Goodacre2005}: DVT ultrasound (15 studies)
#'   \item \code{POCUS_Shock_Yoshida2023}: Point-of-care ultrasound for shock (12 studies)
#'   \item \code{DDimer_PE_Crawford2020}: D-dimer for PE (22 studies)
#'   \item \code{HSTroponin_MI_Body2014}: High-sensitivity troponin for MI (16 studies)
#'   \item \code{MRI_Prostate_Futterer2015}: MRI for prostate cancer (15 studies)
#'   \item \code{Procalcitonin_Sepsis_Wacker2013}: Procalcitonin for sepsis (18 studies)
#'   \item \code{XpertMTB_RIF_Tuberculosis2014}: Xpert MTB/RIF for TB (17 studies)
#'   \item \code{IQCODE_Dementia_MetaDTA}: IQCODE for dementia (13 studies)
#' }
#'
#' \strong{From Limsi-Cochrane DTA collection (57 Cochrane reviews, 1,587 studies):}
#' Complete Cochrane systematic reviews covering diverse topics including:
#' \itemize{
#'   \item Infectious diseases (TB, malaria, COVID, schistosomiasis, etc.)
#'   \item Oncology (colorectal, prostate, cervical, lung, etc.)
#'   \item Neurology (dementia, Alzheimer's, Parkinson's)
#'   \item Cardiology (MI, PE, DVT)
#'   \item Gastroenterology (pancreatitis, liver disease)
#'   \item Ophthalmology (glaucoma)
#'   \item Prenatal screening (Down's syndrome)
#'   \item And many more medical specialties
#' }
#'
#' See \code{data(package="DTA70")} for the complete list of all 76 datasets.
#'
#' \strong{Total: 76 datasets with 1,966+ individual diagnostic accuracy studies}
#'
#' @section Data Format:
#' All datasets include diagnostic 2x2 table data with:
#' \itemize{
#'   \item TP/tp: True positives
#'   \item FP/fp: False positives
#'   \item FN/fn: False negatives
#'   \item TN/tn: True negatives
#' }
#'
#' Many datasets also include study metadata such as author names, publication
#' years, and other relevant covariates.
#'
#' @section Usage:
#' Load datasets using the standard \code{data()} function:
#'
#' \preformatted{
#' library(DTA70)
#' data(AuditC_data)
#' head(AuditC_data)
#' }
#'
#' For detailed usage examples, see the package vignette:
#' \code{vignette("USAGE_GUIDE", package = "DTA70")}
#'
#' For complete dataset descriptions and comparisons:
#' \code{vignette("DATASET_CATALOG", package = "DTA70")}
#'
#' For information on data sources and collection process:
#' \code{vignette("DATA_SOURCES", package = "DTA70")}
#'
#' @section References:
#' Datasets are sourced from:
#' \itemize{
#'   \item \code{mada} package (Doebler & Holling, 2015)
#'   \item \code{diagmeta} package (Schwarzer et al., 2023)
#'   \item Published Cochrane and systematic reviews (various)
#'   \item Limsi-Cochrane DTA collection: Cohen, K. B., et al. (2019).
#'     Limsi-Cochrane Training Set of Systematic Reviews of Diagnostic Test Accuracy.
#'     Zenodo. \doi{10.5281/zenodo.1303259}
#' }
#'
#' @docType package
#' @name DTA70-package
NULL
