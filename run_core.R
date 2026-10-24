# run_core.R: rebuilds the core analysis from the raw workbook, in order.
# Usage, from the project folder:  Rscript run_core.R
RUN_DEFERRED <- FALSE   # genomics, MIC and projection modules are not part of this release

root <- normalizePath(".")
stopifnot(file.exists(file.path(root, ".here")))

log_line <- function(...) {
  line <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "  ", ...)
  message(line)
  cat(line, "\n", file = file.path(root, "audit", "build_log.txt"), append = TRUE, sep = "")
}
dir.create(file.path(root, "audit"), showWarnings = FALSE)

# Stop early on any syntax error
scripts <- c(list.files("R", pattern = "\\.R$", full.names = TRUE), "run_core.R",
             list.files("tests/testthat", pattern = "\\.R$", full.names = TRUE))
for (f in scripts) parse(f)
log_line("parse check passed for ", length(scripts), " scripts")

# Tests on synthetic tables; stop on any failure
res <- testthat::test_dir("tests/testthat", stop_on_failure = TRUE, reporter = "summary")
log_line("tests passed")

# Each stage in its own R process, so no DuckDB connection or lock outlives its stage
stages <- c("R/01_load.R", "R/02_validate.R", "R/03_descriptive.R",
            "R/04_standardise.R", "R/05_robustness.R")
for (s in stages) {
  log_line("running ", s)
  callr::rscript(s, wd = root, show = TRUE, fail_on_status = TRUE)
  log_line("finished ", s)
}

# The report reads data/processed/, audit/ and figures/ only, never the database
log_line("rendering report")
status <- system2("quarto", c("render", "report/report.qmd"))
if (status != 0) stop("Quarto render failed")
dir.create("docs", showWarnings = FALSE)
file.copy("report/report.html", "docs/index.html", overwrite = TRUE)
log_line("report written to docs/index.html")

writeLines(capture.output(sessionInfo()), file.path(root, "audit", "session_info.txt"))
log_line("build complete")
