# DTA70 Dataset Catalog

## Overview

This catalog provides detailed descriptions of all 76 datasets in the DTA70 package, organized by source and medical specialty.

## Dataset Summary Statistics

| Category | Datasets | Studies | Data Points |
|----------|----------|---------|-------------|
| Curated (mada package) | 6 | 159 | 159 |
| Published meta-analyses | 13 | 220 | 500 |
| Cochrane DTA reviews | 57 | 1,587 | 5,848 |
| **Total** | **76** | **1,966** | **6,507** |

---

## Curated Research Datasets (n=6)

### AuditC_data
- **Studies:** 14
- **Topic:** Alcohol Use Disorders Identification Test - Consumption (AUDIT-C)
- **Condition:** Alcohol misuse screening
- **Source:** mada package
- **Mean Sensitivity:** 87.9% | **Mean Specificity:** 68.9%

### Dementia_data
- **Studies:** 33
- **Topic:** Dementia diagnosis using various screening instruments
- **Condition:** Dementia
- **Source:** mada package
- **Mean Sensitivity:** 84.1% | **Mean Specificity:** 86.1%

### IAQ_data
- **Studies:** 20
- **Topic:** Illness Attitude Questionnaire
- **Condition:** Health anxiety screening
- **Source:** mada package
- **Mean Sensitivity:** 94.0% | **Mean Specificity:** 93.8%

### SAQ_data
- **Studies:** 31
- **Topic:** Self-Assessment Questionnaire
- **Condition:** Screening instrument validation
- **Source:** mada package
- **Mean Sensitivity:** 82.9% | **Mean Specificity:** 89.7%

### Smoking_data
- **Studies:** 51
- **Topic:** Biochemical verification of smoking cessation
- **Condition:** Smoking status determination
- **Source:** mada package
- **Mean Sensitivity:** 89.4% | **Mean Specificity:** 92.1%

### SkinTests_data
- **Studies:** 10
- **Topic:** Skin prick testing for allergies
- **Condition:** Allergic sensitization
- **Source:** mada package
- **Mean Sensitivity:** 24.9% | **Mean Specificity:** 95.5%

---

## Published Meta-Analysis Datasets (n=13)

### COVID_AntigenTests_Cochrane2021
- **Studies:** 20
- **Topic:** Rapid antigen tests for SARS-CoV-2
- **Condition:** COVID-19 diagnosis
- **Source:** Cochrane review
- **Mean Sensitivity:** 80.2% | **Mean Specificity:** 97.9%
- **Notes:** Contemporary dataset with pandemic-era diagnostic accuracy

### CT_Colonography_Whiting2011
- **Studies:** 10
- **Topic:** CT colonography (virtual colonoscopy)
- **Condition:** Colorectal polyps and cancer
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 85.0% | **Mean Specificity:** 84.6%

### DDimer_PE_Crawford2020
- **Studies:** 22
- **Topic:** D-dimer testing for pulmonary embolism
- **Condition:** Pulmonary embolism
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 95.3% | **Mean Specificity:** 78.8%
- **Notes:** Emergency medicine application

### Depression_Screening_Gilbody2008
- **Studies:** 13
- **Topic:** Depression screening instruments
- **Condition:** Major depressive disorder
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 85.1% | **Mean Specificity:** 86.5%

### DVT_Ultrasound_Goodacre2005
- **Studies:** 15
- **Topic:** Compression ultrasonography for deep vein thrombosis
- **Condition:** Deep vein thrombosis
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 92.9% | **Mean Specificity:** 97.1%
- **Notes:** High diagnostic accuracy test

### FENO_Asthma_Schneider2017
- **Studies:** 29 (150 data points with multiple cutpoints)
- **Topic:** Fractional exhaled nitric oxide (FeNO) for asthma
- **Condition:** Asthma diagnosis
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 57.8% | **Mean Specificity:** 72.9%
- **Notes:** Multiple thresholds per study - useful for threshold effect research

### HSTroponin_MI_Body2014
- **Studies:** 16
- **Topic:** High-sensitivity cardiac troponin
- **Condition:** Acute myocardial infarction
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 91.2% | **Mean Specificity:** 72.9%

### IQCODE_Dementia_MetaDTA
- **Studies:** 13
- **Topic:** Informant Questionnaire on Cognitive Decline in the Elderly
- **Condition:** Dementia screening
- **Source:** MetaDTA repository (GitHub)
- **Mean Sensitivity:** 88.9% | **Mean Specificity:** 65.0%
- **Notes:** Includes QUADAS-2 quality assessment ratings

### MRI_Prostate_Futterer2015
- **Studies:** 15
- **Topic:** MRI for prostate cancer detection
- **Condition:** Prostate cancer
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 85.0% | **Mean Specificity:** 82.4%

### POCUS_Shock_Yoshida2023
- **Studies:** 12
- **Topic:** Point-of-care ultrasound in shock
- **Condition:** Shock diagnosis in emergency settings
- **Source:** Published meta-analysis (2023)
- **Mean Sensitivity:** 95.1% | **Mean Specificity:** 94.4%
- **Notes:** Recent emergency medicine application

### Procalcitonin_Sepsis_Wacker2013
- **Studies:** 18
- **Topic:** Procalcitonin for sepsis diagnosis
- **Condition:** Sepsis
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 83.5% | **Mean Specificity:** 75.6%

### TB_SmearMicroscopy_Steingart2006
- **Studies:** 20
- **Topic:** Sputum smear microscopy for tuberculosis
- **Condition:** Pulmonary tuberculosis
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 75.7% | **Mean Specificity:** 98.5%

### XpertMTB_RIF_Tuberculosis2014
- **Studies:** 17
- **Topic:** Xpert MTB/RIF assay for tuberculosis
- **Condition:** Tuberculosis
- **Source:** Published meta-analysis
- **Mean Sensitivity:** 85.8% | **Mean Specificity:** 97.8%
- **Notes:** Molecular diagnostic test

---

## Cochrane DTA Review Datasets (n=57)

### Infectious Disease (n=18)

#### Cochrane_CD008892
- **Studies:** 37 | **Rows:** 154
- **Topic:** Rapid diagnostic tests for typhoid and paratyphoid fever
- **Mean Sensitivity:** 70.9% | **Mean Specificity:** 82.2%

#### Cochrane_CD009593
- **Studies:** 36 | **Rows:** 312
- **Topic:** Xpert MTB/RIF for pulmonary tuberculosis and rifampicin resistance
- **Mean Sensitivity:** 83.8% | **Mean Specificity:** 98.5%
- **Notes:** Molecular diagnostic, high specificity

#### Cochrane_CD010502
- **Studies:** 116 | **Rows:** 341
- **Topic:** Rapid antigen detection test for group A streptococcal pharyngitis
- **Mean Sensitivity:** 85.3% | **Mean Specificity:** 96.2%
- **Notes:** Largest dataset by study count

#### Cochrane_CD010705
- **Studies:** 27 | **Rows:** 326
- **Topic:** GenoType MTBDRplus for tuberculosis and rifampicin resistance
- **Mean Sensitivity:** 79.6% | **Mean Specificity:** 97.8%

#### Cochrane_CD011420
- **Studies:** 12 | **Rows:** 147
- **Topic:** Lateral flow urine lipoarabinomannan assay for TB in HIV patients
- **Mean Sensitivity:** 38.6% | **Mean Specificity:** 90.9%

#### Cochrane_CD011431
- **Studies:** 47 | **Rows:** 126
- **Topic:** Rapid diagnostic tests for malaria
- **Mean Sensitivity:** 80.7% | **Mean Specificity:** 98.0%

#### Cochrane_CD009579
- **Studies:** 106 | **Rows:** 180
- **Topic:** Circulating antigen tests and reagent strips for schistosomiasis
- **Mean Sensitivity:** 58.1% | **Mean Specificity:** 80.9%

#### Cochrane_CD009135
- **Studies:** 29 | **Rows:** 55
- **Topic:** Rapid tests for visceral leishmaniasis
- **Mean Sensitivity:** 83.3% | **Mean Specificity:** 91.1%

#### Cochrane_CD009647
- **Studies:** 24 | **Rows:** 322
- **Topic:** Clinical symptoms and signs for identifying malaria
- **Mean Sensitivity:** 41.0% | **Mean Specificity:** 60.1%
- **Notes:** Clinical diagnosis, lower accuracy, high heterogeneity

#### Cochrane_CD007394
- **Studies:** 51 | **Rows:** 57
- **Topic:** Galactomannan detection for invasive aspergillosis
- **Mean Sensitivity:** 59.1% | **Mean Specificity:** 87.3%

#### Cochrane_CD009551
- **Studies:** 18 | **Rows:** 33
- **Topic:** Polymerase chain reaction blood tests for malaria diagnosis
- **Mean Sensitivity:** 71.7% | **Mean Specificity:** 80.1%

#### Cochrane_CD009185
- **Studies:** 24 | **Rows:** 50
- **Topic:** Procalcitonin, C-reactive protein, and erythrocyte sedimentation rate
- **Mean Sensitivity:** 76.1% | **Mean Specificity:** 50.6%

### Oncology (n=12)

#### Cochrane_CD008803
- **Studies:** 105 | **Rows:** 1,018
- **Topic:** Optic nerve head and fiber layer imaging for glaucoma diagnosis
- **Mean Sensitivity:** 61.1% | **Mean Specificity:** 88.8%
- **Notes:** Largest dataset by data points (1,018 rows)

#### Cochrane_CD008054
- **Studies:** 43 | **Rows:** 262
- **Topic:** Human papillomavirus testing for cervical screening
- **Mean Sensitivity:** 84.4% | **Mean Specificity:** 49.8%

#### Cochrane_CD011134
- **Studies:** 52 | **Rows:** 89
- **Topic:** Blood CEA levels for detecting recurrent colorectal cancer
- **Mean Sensitivity:** 70.8% | **Mean Specificity:** 84.3%

#### Cochrane_CD012179
- **Studies:** 70 | **Rows:** 207
- **Topic:** Blood biomarkers for non-invasive diagnosis of endometriosis
- **Mean Sensitivity:** 64.1% | **Mean Specificity:** 75.1%

#### Cochrane_CD012165
- **Studies:** 27 | **Rows:** 48
- **Topic:** Endometrial biomarkers for non-invasive diagnosis of endometriosis
- **Mean Sensitivity:** 76.0% | **Mean Specificity:** 71.8%

#### Cochrane_CD010360
- **Studies:** 38 | **Rows:** 114
- **Topic:** Intraoperative frozen section for ovarian tumor diagnosis
- **Mean Sensitivity:** 92.1% | **Mean Specificity:** 94.2%
- **Notes:** Very high accuracy

#### Cochrane_CD009591
- **Studies:** 49 | **Rows:** 144
- **Topic:** Imaging modalities for non-invasive diagnosis of endometriosis
- **Mean Sensitivity:** 73.0% | **Mean Specificity:** 93.1%

#### Cochrane_CD009944
- **Studies:** 66 | **Rows:** 160
- **Topic:** Endoscopic ultrasonography for pancreatic cancer staging
- **Mean Sensitivity:** 82.2% | **Mean Specificity:** 73.1%

#### Cochrane_CD009519
- **Studies:** 45 | **Rows:** 45
- **Topic:** PET-CT for mediastinal lymph node involvement in lung cancer
- **Mean Sensitivity:** 67.8% | **Mean Specificity:** 86.1%

#### Cochrane_CD010409
- **Studies:** 34 | **Rows:** 125
- **Topic:** Sentinel node assessment for groin lymph node metastases
- **Mean Sensitivity:** 92.3% | **Mean Specificity:** 100.0%
- **Notes:** Perfect specificity

#### Cochrane_CD010276
- **Studies:** 40 | **Rows:** 44
- **Topic:** Diagnostic tests for oral cancer and potentially malignant disorders
- **Mean Sensitivity:** 81.6% | **Mean Specificity:** 71.1%

#### Cochrane_CD008760
- **Studies:** 16 | **Rows:** 53
- **Topic:** Capsule endoscopy for esophageal varices in liver cirrhosis
- **Mean Sensitivity:** 80.3% | **Mean Specificity:** 84.4%

### Neurology and Psychiatry (n=11)

#### Cochrane_CD011145
- **Studies:** 44 | **Rows:** 161
- **Topic:** Mini-Mental State Examination (MMSE) for dementia in community
- **Mean Sensitivity:** 80.2% | **Mean Specificity:** 77.5%

#### Cochrane_CD010772
- **Studies:** 13 | **Rows:** 87
- **Topic:** Informant Questionnaire on Cognitive Decline (IQCODE) - population
- **Mean Sensitivity:** 89.6% | **Mean Specificity:** 65.7%

#### Cochrane_CD010079
- **Studies:** 13 | **Rows:** 53
- **Topic:** Informant Questionnaire on Cognitive Decline (IQCODE) - hospitals
- **Mean Sensitivity:** 77.9% | **Mean Specificity:** 84.6%

#### Cochrane_CD010771
- **Studies:** 1 | **Rows:** 6
- **Topic:** Informant Questionnaire on Cognitive Decline (IQCODE) - clinics
- **Mean Sensitivity:** 90.6% | **Mean Specificity:** 88.6%

#### Cochrane_CD010775
- **Studies:** 7 | **Rows:** 7
- **Topic:** Montreal Cognitive Assessment for dementia diagnosis
- **Mean Sensitivity:** 97.7% | **Mean Specificity:** 53.1%
- **Notes:** Highest sensitivity in package

#### Cochrane_CD010783
- **Studies:** 11 | **Rows:** 13
- **Topic:** Mini-Mental State Examination for dementia in clinics
- **Mean Sensitivity:** 51.0% | **Mean Specificity:** 77.4%

#### Cochrane_CD010860
- **Studies:** 3 | **Rows:** 3
- **Topic:** Mini-Cog for Alzheimer's disease
- **Mean Sensitivity:** 83.4% | **Mean Specificity:** 88.7%

#### Cochrane_CD010632
- **Studies:** 16 | **Rows:** 94
- **Topic:** ¹⁸F-FDG PET for early prediction of Alzheimer's disease
- **Mean Sensitivity:** 72.0% | **Mean Specificity:** 69.1%

#### Cochrane_CD010386
- **Studies:** 9 | **Rows:** 13
- **Topic:** 11C-PIB-PET for early prediction of Alzheimer's disease
- **Mean Sensitivity:** 91.0% | **Mean Specificity:** 59.7%

#### Cochrane_CD010633
- **Studies:** 1 | **Rows:** 4
- **Topic:** Dopamine transporter imaging for Parkinson's dementia
- **Mean Sensitivity:** 92.9% | **Mean Specificity:** 87.6%

#### Cochrane_CD010653
- **Studies:** 21 | **Rows:** 43
- **Topic:** First rank symptoms for schizophrenia
- **Mean Sensitivity:** 55.9% | **Mean Specificity:** 79.8%

### Cardiology and Vascular (n=4)

#### Cochrane_CD009020
- **Studies:** 20 | **Rows:** 61
- **Topic:** MRI, magnetic resonance angiography and ultrasound for stenosis
- **Mean Sensitivity:** 82.3% | **Mean Specificity:** 84.6%

#### Cochrane_CD009372
- **Studies:** 11 | **Rows:** 11
- **Topic:** CT/MRI angiography for lower limb peripheral arterial disease
- **Mean Sensitivity:** 95.8% | **Mean Specificity:** 98.4%
- **Notes:** Highest balanced accuracy (97.1%)

#### Cochrane_CD012281
- **Studies:** 11 | **Rows:** 27
- **Topic:** Combination of non-invasive tests for liver fibrosis
- **Mean Sensitivity:** 77.8% | **Mean Specificity:** 88.4%

### Prenatal Screening (n=2)

#### Cochrane_CD011975
- **Studies:** 56 | **Rows:** 279
- **Topic:** First trimester serum tests for Down's syndrome screening
- **Mean Sensitivity:** 65.5% | **Mean Specificity:** 91.2%

#### Cochrane_CD011984
- **Studies:** 18 | **Rows:** 76
- **Topic:** Urine tests for Down's syndrome screening
- **Mean Sensitivity:** 49.6% | **Mean Specificity:** 94.8%

### Gastroenterology and Hepatology (n=7)

#### Cochrane_CD010542
- **Studies:** 14 | **Rows:** 53
- **Topic:** Transient elastography for liver fibrosis staging
- **Mean Sensitivity:** 89.6% | **Mean Specificity:** 75.9%

#### Cochrane_CD010339
- **Studies:** 10 | **Rows:** 10
- **Topic:** Endoscopic retrograde cholangiopancreatography for biliary stricture
- **Mean Sensitivity:** 91.5% | **Mean Specificity:** 98.4%
- **Notes:** High accuracy

#### Cochrane_CD011548
- **Studies:** 5 | **Rows:** 9
- **Topic:** Ultrasound vs. liver function tests for diagnosis
- **Mean Sensitivity:** 60.1% | **Mean Specificity:** 91.2%

#### Cochrane_CD011549
- **Studies:** 18 | **Rows:** 20
- **Topic:** Endoscopic ultrasound vs. MRI for bile duct stones
- **Mean Sensitivity:** 93.0% | **Mean Specificity:** 95.8%
- **Notes:** Very high accuracy

#### Cochrane_CD010657
- **Studies:** 42 | **Rows:** 75
- **Topic:** DMSA scan or ultrasound for urinary tract infection in children
- **Mean Sensitivity:** 65.5% | **Mean Specificity:** 62.0%

#### Cochrane_CD009786
- **Studies:** 3 | **Rows:** 5
- **Topic:** Laparoscopy for diagnosing resectability of pancreatic cancer
- **Mean Sensitivity:** 64.6% | **Mean Specificity:** 95.1%

#### Cochrane_CD008081
- **Studies:** 10 | **Rows:** 12
- **Topic:** Optical coherence tomography for detecting Barrett's esophagus
- **Mean Sensitivity:** 81.1% | **Mean Specificity:** 79.5%

### Emergency and Critical Care (n=3)

#### Cochrane_CD010173
- **Studies:** 12 | **Rows:** 12
- **Topic:** Clinical assessment for detecting developmental dysplasia of hip
- **Mean Sensitivity:** 49.3% | **Mean Specificity:** 97.4%

#### Cochrane_CD009323
- **Studies:** 16 | **Rows:** 23
- **Topic:** Diagnostic laparoscopy following computed tomography
- **Mean Sensitivity:** 61.7% | **Mean Specificity:** 100.0%

#### Cochrane_CD010438
- **Studies:** 3 | **Rows:** 4
- **Topic:** Thromboelastography for diagnosing coagulopathy
- **Mean Sensitivity:** 82.5% | **Mean Specificity:** 80.3%

### Other Specialties (n=10)

#### Cochrane_CD007427
- **Studies:** 32 | **Rows:** 176
- **Topic:** Physical tests for shoulder impingements
- **Mean Sensitivity:** 61.3% | **Mean Specificity:** 71.9%

#### Cochrane_CD010896
- **Studies:** 12 | **Rows:** 16
- **Topic:** Regional cerebral blood flow SPECT for Alzheimer's disease
- **Mean Sensitivity:** 58.2% | **Mean Specificity:** 88.5%

#### Cochrane_CD010023
- **Studies:** 11 | **Rows:** 15
- **Topic:** CT vs. MRI for chronic rhinosinusitis
- **Mean Sensitivity:** 88.7% | **Mean Specificity:** 90.6%

#### Cochrane_CD008782
- **Studies:** 17 | **Rows:** 25
- **Topic:** Plasma and CSF amyloid beta for Alzheimer's disease
- **Mean Sensitivity:** 77.1% | **Mean Specificity:** 62.1%

#### Cochrane_CD011515
- **Studies:** 2 | **Rows:** 2
- **Topic:** Different imaging modalities for diagnosis
- **Mean Sensitivity:** 87.1% | **Mean Specificity:** 78.6%

#### Cochrane_CD008686
- **Studies:** 8 | **Rows:** 31
- **Topic:** Red flags to screen for malignancy in low back pain
- **Mean Sensitivity:** 29.5% | **Mean Specificity:** 79.6%

#### Cochrane_CD012019
- **Studies:** 5 | **Rows:** 10
- **Topic:** Urinary biomarkers for non-invasive diagnosis of endometriosis
- **Mean Sensitivity:** 69.6% | **Mean Specificity:** 71.7%

---

## Datasets by Diagnostic Accuracy

### Excellent Balanced Accuracy (≥90%)

1. Cochrane_CD009372 (97.1%) - CT/MRI angiography
2. Cochrane_CD010409 (96.2%) - Sentinel node assessment
3. DVT_Ultrasound_Goodacre2005 (95.0%)
4. Cochrane_CD010339 (94.9%) - ERCP
5. POCUS_Shock_Yoshida2023 (94.8%)
6. Cochrane_CD011549 (94.4%) - Endoscopic ultrasound
7. IAQ_data (93.9%)
8. Cochrane_CD010360 (93.2%) - Frozen section analysis
9. XpertMTB_RIF_Tuberculosis2014 (91.8%)
10. Cochrane_CD009593 (91.1%) - Xpert MTB/RIF

### High Heterogeneity (for methods development)

1. Cochrane_CD009647 - Malaria symptoms (SD sens: 0.304, SD spec: 0.294)
2. Cochrane_CD007427 - Shoulder tests (SD sens: 0.279)
3. FENO_Asthma_Schneider2017 - Multiple cutpoints (SD spec: 0.272)
4. Cochrane_CD008686 - Red flags (SD sens: 0.353)

### Large Sample Sizes (>200 data points)

1. Cochrane_CD008803 - 1,018 data points (105 studies)
2. Cochrane_CD010502 - 341 data points (116 studies)
3. Cochrane_CD010705 - 326 data points (27 studies)
4. Cochrane_CD009647 - 322 data points (24 studies)
5. Cochrane_CD009593 - 312 data points (36 studies)
6. Cochrane_CD011975 - 279 data points (56 studies)
7. Cochrane_CD008054 - 262 data points (43 studies)
8. Cochrane_CD012179 - 207 data points (70 studies)

---

## Notes on Usage

- All datasets include TP, FP, FN, TN columns
- Cochrane datasets include `review_id` and `study_id`
- Some datasets have multiple rows per study (different thresholds or subgroups)
- Sensitivity and specificity values shown are simple means (not meta-analytic pooled estimates)
- Consult individual dataset documentation for specific details and references

## Citation Information

When using specific datasets, please cite:
1. The original systematic review or meta-analysis (see dataset documentation)
2. The DTA70 package
3. For Cochrane datasets, also cite the Limsi-Cochrane collection (DOI: 10.5281/zenodo.1303259)
