@echo off
REM ==============================================================================
REM run_analysis.bat - Launch R and Run DTA Methods Research Analysis
REM ==============================================================================

echo ========================================
echo DTA Methods Research Analysis
echo ========================================
echo.

REM Check if R is installed
where R >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: R not found in PATH
    echo Please install R from https://cran.r-project.org/
    echo.
    pause
    exit /b 1
)

echo R found at:
where R
echo.

REM Change to project directory
cd /d "C:\Users\user\OneDrive - NHS\Documents\DTA70"

echo Starting R...
echo.

REM Run R with the master script
R CMD BATCH --vanilla --slave dta_methods_research\run_all.R dta_methods_research\output.log

echo.
echo ========================================
echo Analysis Complete!
echo ========================================
echo.
echo Check output.log for results
echo.
pause
