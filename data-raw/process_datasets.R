# Script to process and source real DTA datasets
# This script sources DTA datasets from various R packages and GitHub

# Install required packages if needed
required_packages <- c("mada", "meta", "metafor", "usethis")

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(mada)
library(meta)
library(metafor)
library(usethis)

# ============================================================================
# Dataset 1: AuditC - Alcohol screening test accuracy
# ============================================================================
# Source: mada package
# Reference: Screening for Unhealthy Use of Alcohol
data(AuditC, package = "mada")
AuditC_data <- AuditC
usethis::use_data(AuditC_data, overwrite = TRUE)

# ============================================================================
# Dataset 2: Dementia diagnosis tests
# ============================================================================
# Source: mada package
data(Dementia, package = "mada")
Dementia_data <- Dementia
usethis::use_data(Dementia_data, overwrite = TRUE)

# ============================================================================
# Dataset 3: Lymphangiography for detecting metastases
# ============================================================================
# Source: mada package
data(Lymphangiography, package = "mada")
Lymphangiography_data <- Lymphangiography
usethis::use_data(Lymphangiography_data, overwrite = TRUE)

# ============================================================================
# Dataset 4: SAT (Serum Ascites Albumin gradient Test)
# ============================================================================
# Source: mada package
data(SAT, package = "mada")
SAT_data <- SAT
usethis::use_data(SAT_data, overwrite = TRUE)

# ============================================================================
# Dataset 5: Telomerase for bladder cancer diagnosis
# ============================================================================
# Source: mada package
data(Telomerase, package = "mada")
Telomerase_data <- Telomerase
usethis::use_data(Telomerase_data, overwrite = TRUE)

# ============================================================================
# Dataset 6: Colorectal cancer screening - Glas et al. (2003)
# ============================================================================
# Source: metafor package - dat.glas2003
data(dat.glas2003, package = "metafor")
Colorectal_Glas2003 <- dat.glas2003
usethis::use_data(Colorectal_Glas2003, overwrite = TRUE)

# ============================================================================
# Dataset 7: Mammography accuracy - Reitsma (2005)
# ============================================================================
# Source: metafor package - dat.reitsma2005
data(dat.reitsma2005, package = "metafor")
Mammography_Reitsma2005 <- dat.reitsma2005
usethis::use_data(Mammography_Reitsma2005, overwrite = TRUE)

# ============================================================================
# Dataset 8: CT for staging lung cancer - Daniels (2012)
# ============================================================================
# Source: metafor package - dat.daniels2012
data(dat.daniels2012, package = "metafor")
CT_Lung_Daniels2012 <- dat.daniels2012
usethis::use_data(CT_Lung_Daniels2012, overwrite = TRUE)

# ============================================================================
# Dataset 9: MRI for Alzheimer's disease - Deeks (2001)
# ============================================================================
# Source: metafor package - dat.deeks2005
data(dat.deeks2005, package = "metafor")
MRI_Alzheimers_Deeks2005 <- dat.deeks2005
usethis::use_data(MRI_Alzheimers_Deeks2005, overwrite = TRUE)

# ============================================================================
# Dataset 10: Tuberculosis diagnosis - Schiller (2008)
# ============================================================================
# Source: metafor package - dat.scheidler1997
data(dat.scheidler1997, package = "metafor")
MRI_Lymph_Scheidler1997 <- dat.scheidler1997
usethis::use_data(MRI_Lymph_Scheidler1997, overwrite = TRUE)

cat("All datasets processed and saved to data/ directory\n")
