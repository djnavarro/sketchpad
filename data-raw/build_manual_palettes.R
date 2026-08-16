# Vendors the hardcoded palettes from https://github.com/djnavarro/palettes
# into this package's internal data (R/sysdata.rda), for use by
# `palette_manual()`. This script is not run as part of the package build
# or `R CMD check` -- it's a one-time (or occasional, if the source repo
# gains new palettes) vendoring step, run by hand from the package root:
#
#   source("data-raw/build_manual_palettes.R")
#
# Source data vendored 2026-08-16: 5 CSVs (`palette_01.csv`...
# `palette_05.csv`), each row a 5-colour hex palette originally scraped
# from https://coolors.co palette URLs (see that repo's `utils.R`). No
# licence file was found in the source repo; both it and this package
# share the same author, and the palettes themselves (bare hex codes) are
# not creative works subject to copyright, so vendoring them here is
# treated as reuse of the author's own prior work.

palette_urls <- sprintf(
  "https://raw.githubusercontent.com/djnavarro/palettes/main/palette_%02d.csv",
  1:5
)

palette_rows <- palette_urls |>
  lapply(utils::read.csv, stringsAsFactors = FALSE) |>
  do.call(what = rbind)

# Each row -> a length-5 character vector of lowercase hex colours
raw_palettes <- palette_rows |>
  apply(MARGIN = 1, FUN = function(row) unname(tolower(row)), simplify = FALSE)

# Whole-row exact duplicates (case-insensitive) show up across the 5
# source files; drop them, keeping the first occurrence in file/row order
palette_keys <- vapply(raw_palettes, paste, character(1), collapse = ",")
manual_palettes <- raw_palettes[!duplicated(palette_keys)]

usethis::use_data(manual_palettes, internal = TRUE, overwrite = TRUE)
