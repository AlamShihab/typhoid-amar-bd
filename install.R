# One-time setup: install the packages the core analysis needs, then record them with renv.
#   Rscript install.R
# Quarto (https://quarto.org) must also be installed and on the PATH to render the report.

pkgs <- c("DBI", "duckdb", "readxl", "dplyr", "tidyr", "purrr", "readr", "stringr", "tibble",
          "ggplot2", "scales", "here", "mgcv", "MASS", "testthat", "callr", "knitr", "rmarkdown")

if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
if (!file.exists("renv.lock")) {
  renv::init(bare = TRUE, restart = FALSE)   # project library, no packages yet
  renv::install(pkgs)
  renv::snapshot(packages = pkgs, prompt = FALSE)
} else {
  renv::restore(prompt = FALSE)    # a lockfile exists: reproduce exactly those versions
}
