# testthat auto-runs setup*.R before any test_that() block.
# Use pkgload::load_all() so the DTA70 package's R/ files are visible
# without requiring R CMD INSTALL — keeps the test command portable to
# plain `Rscript -e "testthat::test_dir('tests/testthat')"` (Overmind's
# nightly verifier) and `Rscript tests/testthat.R` alike.
if (!"DTA70" %in% loadedNamespaces()) {
  pkgload::load_all(rprojroot::find_package_root_file(), quiet = TRUE)
}
