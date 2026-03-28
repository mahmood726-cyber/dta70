#' Create DTA-Stack TruthCert Report
#'
#' @param x dta_stack object
#' @param filename Output filename
#' @export
create_dta_report <- function(x, filename = "DTA_TruthCert_Report.html") {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package 'digest' is required for TruthCert verification")
  }
  
  data_hash <- digest::digest(x$data, algo = "sha256")
  
  report_lines <- c(
    "<html><head><style>",
    "body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; }",
    ".header { background: #2c3e50; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }",
    ".verdict { font-size: 24px; font-weight: bold; padding: 15px; border-left: 5px solid #e74c3c; background: #f9f9f9; margin: 20px 0; }",
    ".stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }",
    ".stat-card { padding: 15px; border: 1px solid #ddd; border-radius: 5px; }",
    ".audit-trail { font-size: 12px; color: #7f8c8d; margin-top: 40px; border-top: 1px solid #eee; padding-top: 10px; }",
    "</style></head><body>",
    
    "<div class='header'>",
    "<h1>DTA-Stack Clinical Oracle Report</h1>",
    "<p>Automated Diagnostic Test Accuracy Evidence Synthesis</p>",
    "</div>",
    
    "<div class='verdict'>",
    sprintf("Verdict: %s (%s GRADE)", x$verdict$label, x$verdict$grade),
    sprintf("<br><span style='font-size: 16px; font-weight: normal;'>Clinical Pathway: %s</span>", x$verdict$pathway),
    "</div>",
    
    "<h3>Key Performance Metrics</h3>",
    "<div class='stats-grid'>",
    "<div class='stat-card'>",
    sprintf("<strong>Sensitivity:</strong> %.1f%% (95%% CI: %.1f%% - %.1f%%)", 
            x$estimates$sens[1]*100, x$estimates$sens[2]*100, x$estimates$sens[3]*100),
    "</div>",
    "<div class='stat-card'>",
    sprintf("<strong>Specificity:</strong> %.1f%% (95%% CI: %.1f%% - %.1f%%)", 
            x$estimates$spec[1]*100, x$estimates$spec[2]*100, x$estimates$spec[3]*100),
    "</div>",
    "</div>",
    
    "<h3>Evidence Integrity</h3>",
    sprintf("<p>Information Accumulation Index (IAI): %.2f</p>", x$integrity$iai),
    sprintf("<p>Bias Detection (Deeks' Test): %s</p>", 
            if(is.na(x$bias$p_val)) "Insufficient data" else sprintf("p = %.3f", x$bias$p_val)),
    
    "<h3>TruthCert(TM) Verification</h3>",
    "<div class='audit-trail'>",
    sprintf("Data SHA-256 Hash: %s", data_hash),
    sprintf("<br>Generated on: %s", Sys.time()),
    sprintf("<br>CBAMM/DTA70 Version: %s", as.character(packageVersion("DTA70"))),
    "</div>",
    
    "</body></html>"
  )
  
  writeLines(report_lines, filename)
  message("TruthCert report saved to: ", filename)
  return(invisible(filename))
}
