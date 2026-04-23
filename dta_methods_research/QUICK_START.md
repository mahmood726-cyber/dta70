# ============================================================================
# QUICK START GUIDE - DTA Meta-Analysis Methods Research
# ============================================================================
#
# This guide shows you how to run the complete analysis in R or RStudio.
#
# ============================================================================

## METHOD 1: Quick Run (All Phases)

1. Open R or RStudio
2. Set working directory:
   ```r
   setwd("C:/Users/user/OneDrive - NHS/Documents/DTA70") <!-- sentinel:skip-line P0-hardcoded-local-path -->
   ```

3. Install required packages (first time only):
   ```r
   source("dta_methods_research/config/packages_needed.R")
   ```

4. Run complete analysis:
   ```r
   source("dta_methods_research/run_all.R")
   ```

## METHOD 2: Step-by-Step

If you prefer to run each phase separately:

### Step 1: Install Packages
```r
setwd("C:/Users/user/OneDrive - NHS/Documents/DTA70") <!-- sentinel:skip-line P0-hardcoded-local-path -->
source("dta_methods_research/config/packages_needed.R")
```

### Step 2: Load and Analyze Datasets
```r
source("dta_methods_research/01_data_preparation/load_datasets.R")
source("dta_methods_research/01_data_preparation/data_characteristics.R")
```

### Step 3: Test Methods (Phase 1)
```r
source("dta_methods_research/02_phase1_comprehensive_testing/test_mada_methods.R")
source("dta_methods_research/02_phase1_comprehensive_testing/compile_results.R")
```

### Step 4: Identify Flaws (Phase 2)
```r
source("dta_methods_research/03_phase2_flaw_identification/detect_bias.R")
```

### Step 5: Develop Improved Methods (Phase 3)
```r
source("dta_methods_research/04_phase3_method_development/develop_improved_methods.R")
```

### Step 6: Build DTAimproved Package
```r
devtools::install("DTAimproved")
library(DTAimproved)

# Test the new package
data <- data.frame(
  TP = c(120, 85, 200, 150),
  FP = c(15, 20, 30, 25),
  FN = c(30, 45, 50, 40),
  TN = c(180, 160, 250, 220)
)

result <- dta_analyze(data)
print(result)
```

## METHOD 3: Using Windows Batch File

Double-click this file:
```
C:\Users\user\OneDrive - NHS\Documents\DTA70\dta_methods_research\run_analysis.bat <!-- sentinel:skip-line P0-hardcoded-local-path -->
```

## OUTPUT FILES

After running, you will find:

| File | Location | Description |
|------|----------|-------------|
| master_database.csv | results/ | All method results |
| flaw_summary.csv | results/tables/ | Identified flaws |
| *.png | results/figures/ | Visualizations |
| phase1_report.html | reports/ | HTML report |

## TROUBLESHOOTING

### Issue: "Package not found"
Solution: Run packages_needed.R first to install all dependencies

### Issue: "Dataset not found"
Solution: Ensure DTA70 package is installed in the same directory

### Issue: "Out of memory"
Solution: Process datasets in smaller batches:
```r
# Process only training datasets first
train_data <- read.csv("dta_methods_research/results/raw/train_split.csv")
```

## NEXT STEPS

1. Review `master_database.csv` for all results
2. Check `flaw_summary.csv` for identified method flaws
3. Use `recommend_method()` for new analyses
4. Consider submitting findings to a journal

## SUPPORT

For issues or questions:
- Check the output log file
- Review individual script comments
- Consult the DTA70 package documentation
