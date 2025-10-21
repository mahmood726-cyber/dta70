# Dataset Documentation for DTA70 Package

#' Alcohol Screening Test Accuracy (AUDIT-C)
#'
#' Diagnostic test accuracy data for the AUDIT-C (Alcohol Use Disorders
#' Identification Test - Consumption) screening tool for detecting unhealthy
#' alcohol use.
#'
#' @format A data frame with diagnostic accuracy data including:
#' \describe{
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#' }
#'
#' @source Sourced from the \code{mada} package. Original data from systematic
#' reviews of alcohol screening test accuracy.
#'
#' @references
#' Doebler P, Holling H (2015). Meta-analysis of Diagnostic Accuracy with mada.
#' \url{https://CRAN.R-project.org/package=mada}
#'
#' @examples
#' data(AuditC_data)
#' head(AuditC_data)
#' # Calculate sensitivity and specificity
#' AuditC_data$sensitivity <- with(AuditC_data, TP/(TP+FN))
#' AuditC_data$specificity <- with(AuditC_data, TN/(TN+FP))
"AuditC_data"

#' Dementia Diagnosis Test Accuracy
#'
#' Diagnostic test accuracy data from studies evaluating various tests for
#' dementia diagnosis.
#'
#' @format A data frame with diagnostic accuracy data including:
#' \describe{
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#' }
#'
#' @source Sourced from the \code{mada} package.
#'
#' @references
#' Doebler P, Holling H (2015). Meta-analysis of Diagnostic Accuracy with mada.
#' \url{https://CRAN.R-project.org/package=mada}
#'
#' @examples
#' data(Dementia_data)
#' head(Dementia_data)
"Dementia_data"

#' IAQ (Information/Annoyance Questionnaire) Data
#'
#' Diagnostic test accuracy data for the IAQ screening instrument.
#'
#' @format A data frame with diagnostic accuracy data including:
#' \describe{
#'   \item{author}{First author name}
#'   \item{study_id}{Study identifier}
#'   \item{result_id}{Result identifier}
#'   \item{type}{Type of study or test}
#'   \item{TP}{True positives}
#'   \item{FN}{False negatives}
#'   \item{FP}{False positives}
#'   \item{TN}{True negatives}
#'   \item{population}{Population studied}
#' }
#'
#' @source Sourced from the \code{mada} package.
#'
#' @references
#' Doebler P, Holling H (2015). Meta-analysis of Diagnostic Accuracy with mada.
#' \url{https://CRAN.R-project.org/package=mada}
#'
#' @examples
#' data(IAQ_data)
#' head(IAQ_data)
"IAQ_data"

#' SAQ (Self-Administered Questionnaire) Data
#'
#' Diagnostic test accuracy data for the SAQ screening instrument.
#'
#' @format A data frame with diagnostic accuracy data including:
#' \describe{
#'   \item{author}{First author name}
#'   \item{study_id}{Study identifier}
#'   \item{result_id}{Result identifier}
#'   \item{type}{Type of study or test}
#'   \item{TP}{True positives}
#'   \item{FN}{False negatives}
#'   \item{FP}{False positives}
#'   \item{TN}{True negatives}
#'   \item{population}{Population studied}
#' }
#'
#' @source Sourced from the \code{mada} package.
#'
#' @references
#' Doebler P, Holling H (2015). Meta-analysis of Diagnostic Accuracy with mada.
#' \url{https://CRAN.R-project.org/package=mada}
#'
#' @examples
#' data(SAQ_data)
#' head(SAQ_data)
"SAQ_data"

#' Smoking Cessation Diagnosis Data
#'
#' Diagnostic test accuracy data from studies on smoking cessation diagnostic tests.
#'
#' @format A data frame with diagnostic accuracy data including:
#' \describe{
#'   \item{author}{First author name}
#'   \item{study_id}{Study identifier}
#'   \item{result_id}{Result identifier}
#'   \item{type}{Type of study or test}
#'   \item{TP}{True positives}
#'   \item{FN}{False negatives}
#'   \item{FP}{False positives}
#'   \item{TN}{True negatives}
#'   \item{population}{Population studied}
#' }
#'
#' @source Sourced from the \code{mada} package.
#'
#' @references
#' Doebler P, Holling H (2015). Meta-analysis of Diagnostic Accuracy with mada.
#' \url{https://CRAN.R-project.org/package=mada}
#'
#' @examples
#' data(Smoking_data)
#' head(Smoking_data)
"Smoking_data"

#' Skin Tests Diagnostic Accuracy Data
#'
#' Diagnostic test accuracy data from studies evaluating skin tests for various
#' conditions.
#'
#' @format A data frame with diagnostic accuracy data including:
#' \describe{
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#' }
#'
#' @source Sourced from the \code{mada} package.
#'
#' @references
#' Doebler P, Holling H (2015). Meta-analysis of Diagnostic Accuracy with mada.
#' \url{https://CRAN.R-project.org/package=mada}
#'
#' @examples
#' data(SkinTests_data)
#' head(SkinTests_data)
"SkinTests_data"

#' FENO for Asthma Diagnosis - Schneider et al. (2017)
#'
#' Meta-analysis of fractional exhaled nitric oxide (FENO) for diagnosing
#' asthma in adults. This dataset includes multiple cutpoint values per study,
#' making it ideal for meta-analysis methods that account for threshold effects.
#'
#' @format A data frame with 150 observations from 29 studies:
#' \describe{
#'   \item{study_id}{Numeric study identifier}
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{group}{Study group (if applicable)}
#'   \item{cutpoint}{FENO cutpoint value (ppb)}
#'   \item{TP}{True positives}
#'   \item{FN}{False negatives}
#'   \item{FP}{False positives}
#'   \item{TN}{True negatives}
#' }
#'
#' @source Sourced from the \code{diagmeta} package (Schneider2017 dataset).
#'
#' @references
#' Schneider A, Gindner L, Tilemann L, et al. (2013). Diagnostic accuracy of
#' spirometry in asthma: a systematic review and meta-analysis.
#' \emph{Respir Med}, \bold{107}(8), 1178-1185.
#'
#' Schwarzer G, Steinhauser S, Schneider A (2023). diagmeta: Meta-Analysis of
#' Diagnostic Accuracy Studies with Several Cutpoints. R package version 0.5-1.
#'
#' @examples
#' data(FENO_Asthma_Schneider2017)
#' head(FENO_Asthma_Schneider2017)
#' # Number of unique studies
#' length(unique(FENO_Asthma_Schneider2017$study_id))
"FENO_Asthma_Schneider2017"

#' CT Colonography for Colorectal Cancer - Whiting et al. (2011)
#'
#' Diagnostic test accuracy of CT colonography (virtual colonoscopy) for
#' detecting colorectal cancer and polyps. From a systematic review demonstrating
#' the QUADAS-2 quality assessment tool.
#'
#' @format A data frame with 10 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{setting}{Study setting (screening or symptomatic)}
#'   \item{sample_size}{Total sample size}
#' }
#'
#' @source Based on studies cited in Whiting PF, et al. (2011).
#'
#' @references
#' Whiting PF, Rutjes AW, Westwood ME, et al. (2011). QUADAS-2: a revised tool
#' for the quality assessment of diagnostic accuracy studies. \emph{Annals of
#' Internal Medicine}, \bold{155}(8), 529-536.
#'
#' @examples
#' data(CT_Colonography_Whiting2011)
#' head(CT_Colonography_Whiting2011)
#' # Compare sensitivity by setting
#' CT_Colonography_Whiting2011$sensitivity <- with(CT_Colonography_Whiting2011,
#'                                                   TP/(TP+FN))
"CT_Colonography_Whiting2011"

#' Sputum Smear Microscopy for Tuberculosis - Steingart et al. (2006)
#'
#' Diagnostic accuracy of sputum smear microscopy for diagnosing pulmonary
#' tuberculosis. Includes data on different staining methods (Ziehl-Neelsen,
#' Auramine, LED) across multiple countries.
#'
#' @format A data frame with 20 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{smear_method}{Microscopy staining method (ZN, Auramine, LED)}
#'   \item{country}{Country where study was conducted}
#' }
#'
#' @source Based on Steingart KR, et al. (2006).
#'
#' @references
#' Steingart KR, Henry M, Ng V, et al. (2006). Fluorescence versus conventional
#' sputum smear microscopy for tuberculosis: a systematic review.
#' \emph{Lancet Infectious Diseases}, \bold{6}(9), 570-581.
#'
#' @examples
#' data(TB_SmearMicroscopy_Steingart2006)
#' head(TB_SmearMicroscopy_Steingart2006)
#' # Compare methods
#' table(TB_SmearMicroscopy_Steingart2006$smear_method)
"TB_SmearMicroscopy_Steingart2006"

#' COVID-19 Rapid Antigen Tests - Cochrane Review (2021)
#'
#' Diagnostic accuracy of rapid antigen tests for SARS-CoV-2 infection.
#' From a Cochrane systematic review evaluating point-of-care tests across
#' different settings and test brands.
#'
#' @format A data frame with 20 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{test_brand}{Commercial test brand name}
#'   \item{setting}{Testing setting (community or hospital)}
#' }
#'
#' @source Based on Cochrane review by Dinnes J, et al. (2021).
#'
#' @references
#' Dinnes J, Deeks JJ, Berhane S, et al. (2021). Rapid, point-of-care antigen
#' and molecular-based tests for diagnosis of SARS-CoV-2 infection.
#' \emph{Cochrane Database of Systematic Reviews}, \bold{3}, CD013705.
#'
#' @examples
#' data(COVID_AntigenTests_Cochrane2021)
#' head(COVID_AntigenTests_Cochrane2021)
#' # Sensitivity by setting
#' tapply(with(COVID_AntigenTests_Cochrane2021, TP/(TP+FN)),
#'        COVID_AntigenTests_Cochrane2021$setting, mean)
"COVID_AntigenTests_Cochrane2021"

#' Depression Screening - Gilbody et al. (2008)
#'
#' Diagnostic accuracy of depression screening instruments in medical settings.
#' Includes various validated screening tools (PHQ-9, PRIME-MD, HADS, etc.)
#' across different healthcare settings.
#'
#' @format A data frame with 13 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{instrument}{Screening instrument used}
#'   \item{setting}{Healthcare setting}
#' }
#'
#' @source Based on Gilbody S, et al. (2008).
#'
#' @references
#' Gilbody S, Richards D, Brealey S, Hewitt C (2007). Screening for depression
#' in medical settings with the Patient Health Questionnaire (PHQ): a diagnostic
#' meta-analysis. \emph{Journal of General Internal Medicine}, \bold{22}(11),
#' 1596-1602.
#'
#' @examples
#' data(Depression_Screening_Gilbody2008)
#' head(Depression_Screening_Gilbody2008)
#' # Different instruments used
#' table(Depression_Screening_Gilbody2008$instrument)
"Depression_Screening_Gilbody2008"

#' Ultrasound for Deep Vein Thrombosis - Goodacre et al. (2005)
#'
#' Diagnostic accuracy of ultrasound for diagnosing deep vein thrombosis (DVT).
#' Includes both compression ultrasound (CUS) and duplex ultrasound methods.
#'
#' @format A data frame with 15 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{ultrasound_type}{Type of ultrasound (CUS or Duplex)}
#'   \item{population}{Patient population}
#' }
#'
#' @source Based on Goodacre S, et al. (2005).
#'
#' @references
#' Goodacre S, Sampson F, Thomas S, van Beek E, Sutton A (2005). Systematic
#' review and meta-analysis of the diagnostic accuracy of ultrasonography for
#' deep vein thrombosis. \emph{BMC Medical Imaging}, \bold{5}, 6.
#'
#' @examples
#' data(DVT_Ultrasound_Goodacre2005)
#' head(DVT_Ultrasound_Goodacre2005)
#' # Compare ultrasound types
#' table(DVT_Ultrasound_Goodacre2005$ultrasound_type)
"DVT_Ultrasound_Goodacre2005"

#' Point-of-Care Ultrasound for Shock - Yoshida et al. (2023)
#'
#' Diagnostic accuracy of point-of-care ultrasound (POCUS) for identifying
#' the cause of shock in critically ill patients. From a 2023 systematic
#' review published in Critical Care.
#'
#' @format A data frame with 12 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{shock_type}{Type of shock (cardiogenic, distributive, hypovolemic, obstructive, mixed)}
#'   \item{country}{Country where study was conducted}
#' }
#'
#' @source Based on Yoshida T, et al. (2023).
#'
#' @references
#' Yoshida T, Endo A, Oiwa A, et al. (2023). Diagnostic accuracy of point-of-care
#' ultrasound for shock: a systematic review and meta-analysis.
#' \emph{Critical Care}, \bold{27}(1), 200.
#'
#' @examples
#' data(POCUS_Shock_Yoshida2023)
#' head(POCUS_Shock_Yoshida2023)
#' # Sensitivity by shock type
#' POCUS_Shock_Yoshida2023$sensitivity <- with(POCUS_Shock_Yoshida2023, TP/(TP+FN))
#' tapply(POCUS_Shock_Yoshida2023$sensitivity,
#'        POCUS_Shock_Yoshida2023$shock_type, mean)
"POCUS_Shock_Yoshida2023"

#' D-Dimer for Pulmonary Embolism - Crawford et al. (2020)
#'
#' Diagnostic accuracy of D-dimer testing for suspected pulmonary embolism.
#' From a comprehensive systematic review published in Blood Advances in 2020.
#' Includes studies with various D-dimer thresholds.
#'
#' @format A data frame with 22 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{d_dimer_threshold}{D-dimer cutoff threshold (ng/mL)}
#'   \item{setting}{Clinical setting (outpatient, ED, hospital)}
#' }
#'
#' @source Based on Crawford F, et al. (2020).
#'
#' @references
#' Crawford F, Andras A, Welch K, et al. (2020). Systematic review and
#' meta-analysis of test accuracy for the diagnosis of suspected pulmonary
#' embolism. \emph{Blood Advances}, \bold{4}(18), 4296-4311.
#'
#' @examples
#' data(DDimer_PE_Crawford2020)
#' head(DDimer_PE_Crawford2020)
#' # Sensitivity and specificity
#' DDimer_PE_Crawford2020$sensitivity <- with(DDimer_PE_Crawford2020, TP/(TP+FN))
#' DDimer_PE_Crawford2020$specificity <- with(DDimer_PE_Crawford2020, TN/(TN+FP))
#' summary(DDimer_PE_Crawford2020[,c("sensitivity", "specificity")])
"DDimer_PE_Crawford2020"

#' High-Sensitivity Troponin for Myocardial Infarction - Body et al. (2014)
#'
#' Diagnostic accuracy of high-sensitivity cardiac troponin assays for
#' diagnosing acute myocardial infarction. Includes both hs-cTnI and hs-cTnT
#' at various time points.
#'
#' @format A data frame with 16 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{troponin_type}{Type of troponin assay (hs-cTnI or hs-cTnT)}
#'   \item{time_point}{Time of measurement (presentation, 1-hour, 3-hour)}
#'   \item{country}{Country where study was conducted}
#' }
#'
#' @source Based on Body R, et al. (2014).
#'
#' @references
#' Body R, Carley S, McDowell G, et al. (2014). Diagnostic accuracy of sensitive
#' or high-sensitive troponin on presentation for myocardial infarction: a
#' meta-analysis and systematic review. \emph{Vascular Health and Risk Management},
#' \bold{10}, 435-449.
#'
#' @examples
#' data(HSTroponin_MI_Body2014)
#' head(HSTroponin_MI_Body2014)
#' # Compare troponin types
#' table(HSTroponin_MI_Body2014$troponin_type)
"HSTroponin_MI_Body2014"

#' MRI for Prostate Cancer Detection - Futterer et al. (2015)
#'
#' Diagnostic accuracy of multiparametric MRI for detecting prostate cancer.
#' Includes data on different MRI field strengths and PI-RADS scores.
#'
#' @format A data frame with 15 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{mri_strength}{MRI field strength (1.5T or 3.0T)}
#'   \item{pirads_score}{PI-RADS score threshold (3, 4, or 5)}
#' }
#'
#' @source Based on published meta-analyses of mpMRI for prostate cancer.
#'
#' @references
#' Futterer JJ, Briganti A, De Visschere P, et al. (2015). Can clinically
#' significant prostate cancer be detected with multiparametric magnetic
#' resonance imaging? A systematic review of the literature.
#' \emph{European Urology}, \bold{68}(6), 1045-1053.
#'
#' @examples
#' data(MRI_Prostate_Futterer2015)
#' head(MRI_Prostate_Futterer2015)
#' # Compare by MRI strength
#' table(MRI_Prostate_Futterer2015$mri_strength)
"MRI_Prostate_Futterer2015"

#' Procalcitonin for Sepsis Diagnosis - Wacker et al. (2013)
#'
#' Diagnostic accuracy of procalcitonin as a marker for sepsis in critically
#' ill patients. From a Lancet Infectious Diseases meta-analysis with various
#' cutoff values and clinical settings.
#'
#' @format A data frame with 18 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{cutoff_ng_ml}{Procalcitonin cutoff threshold (ng/mL)}
#'   \item{setting}{Clinical setting (ICU, ED, hospital)}
#' }
#'
#' @source Based on Wacker C, et al. (2013).
#'
#' @references
#' Wacker C, Prkno A, Brunkhorst FM, Schlattmann P (2013). Procalcitonin as a
#' diagnostic marker for sepsis: a systematic review and meta-analysis.
#' \emph{Lancet Infectious Diseases}, \bold{13}(5), 426-435.
#'
#' @examples
#' data(Procalcitonin_Sepsis_Wacker2013)
#' head(Procalcitonin_Sepsis_Wacker2013)
#' # Distribution of cutoffs
#' hist(Procalcitonin_Sepsis_Wacker2013$cutoff_ng_ml,
#'      main="Procalcitonin Cutoff Values", xlab="Cutoff (ng/mL)")
"Procalcitonin_Sepsis_Wacker2013"

#' Xpert MTB/RIF for Tuberculosis - Steingart et al. (2014)
#'
#' Diagnostic accuracy of Xpert MTB/RIF for detecting pulmonary tuberculosis
#' and rifampicin resistance. From a Cochrane systematic review including
#' studies from various countries with different HIV prevalence.
#'
#' @format A data frame with 17 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{sample_type}{Type of sample (sputum, various)}
#'   \item{hiv_status}{HIV status of population (positive, negative, mixed)}
#'   \item{country}{Country where study was conducted}
#' }
#'
#' @source Based on Steingart KR, et al. (2014).
#'
#' @references
#' Steingart KR, Schiller I, Horne DJ, et al. (2014). Xpert MTB/RIF assay for
#' pulmonary tuberculosis and rifampicin resistance in adults. \emph{Cochrane
#' Database of Systematic Reviews}, \bold{1}, CD009593.
#'
#' @examples
#' data(XpertMTB_RIF_Tuberculosis2014)
#' head(XpertMTB_RIF_Tuberculosis2014)
#' # Accuracy by HIV status
#' XpertMTB_RIF_Tuberculosis2014$sensitivity <- with(XpertMTB_RIF_Tuberculosis2014,
#'                                                     TP/(TP+FN))
#' tapply(XpertMTB_RIF_Tuberculosis2014$sensitivity,
#'        XpertMTB_RIF_Tuberculosis2014$hiv_status, mean)
"XpertMTB_RIF_Tuberculosis2014"

#' IQCODE for Dementia/Cognitive Impairment - MetaDTA
#'
#' Diagnostic accuracy of the Informant Questionnaire on Cognitive Decline in
#' the Elderly (IQCODE) for detecting dementia and cognitive impairment. This
#' dataset includes quality assessment ratings and study-level covariates.
#'
#' @format A data frame with 13 studies:
#' \describe{
#'   \item{author}{First author name}
#'   \item{year}{Publication year (1991-2011)}
#'   \item{TP}{True positives}
#'   \item{FP}{False positives}
#'   \item{FN}{False negatives}
#'   \item{TN}{True negatives}
#'   \item{threshold}{IQCODE cutoff threshold (range 3.3-4.1)}
#'   \item{country}{Country where study was conducted}
#'   \item{iqcode_version}{Version of IQCODE used (16, 26, or 32 items)}
#'   \item{risk_of_bias_patient_selection}{Risk of bias rating (1-3) for patient selection}
#'   \item{risk_of_bias_index_test}{Risk of bias rating (1-3) for index test}
#'   \item{risk_of_bias_reference_standard}{Risk of bias rating (1-3) for reference standard}
#'   \item{risk_of_bias_flow_timing}{Risk of bias rating (1-3) for flow and timing}
#'   \item{applicability_concerns_patient_selection}{Applicability rating (1-3) for patient selection}
#'   \item{applicability_concerns_index_test}{Applicability rating (1-3) for index test}
#'   \item{applicability_concerns_reference_standard}{Applicability rating (1-3) for reference standard}
#' }
#'
#' @source Sourced from the MetaDTA Shiny application example datasets.
#'   Available at: \url{https://github.com/CRSU-Apps/MetaDTA}
#'
#' @references
#' Freeman SC, Kerby CR, Patel A, et al. (2019). Development of an interactive
#' web-based tool to conduct and interrogate meta-analysis of diagnostic test
#' accuracy studies: MetaDTA. \emph{BMC Medical Research Methodology}, \bold{19}(1), 81.
#'
#' @examples
#' data(IQCODE_Dementia_MetaDTA)
#' head(IQCODE_Dementia_MetaDTA)
#' # Calculate sensitivity and specificity
#' IQCODE_Dementia_MetaDTA$sensitivity <- with(IQCODE_Dementia_MetaDTA, TP/(TP+FN))
#' IQCODE_Dementia_MetaDTA$specificity <- with(IQCODE_Dementia_MetaDTA, TN/(TN+FP))
#' # Examine relationship between threshold and sensitivity
#' plot(IQCODE_Dementia_MetaDTA$threshold, IQCODE_Dementia_MetaDTA$sensitivity,
#'      xlab="IQCODE Threshold", ylab="Sensitivity", main="Threshold Effect")
"IQCODE_Dementia_MetaDTA"
