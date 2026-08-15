#' Build a sketch by vectorizing a drawable constructor
#'
#' Internal engine shared by every plural `shape_*s()`/`curve_*s()`/
#' `points_raws()` constructor (see e.g. [shape_circles()]). Recycles
#' `args` against each other via `purrr::pmap()`'s own vctrs-based rules
#' (any length-1 element is broadcast to the common length; mismatched
#' lengths greater than 1 raise a clear error) and calls `.f` once per
#' resulting row, collecting the results into a [sketch].
#'
#' A scalar S7 object passed as one of `args` (e.g. a single [trans]/
#' [noise_field]/[noise_bridge] shared by every shape) is not itself a
#' vector -- `purrr::pmap()` errors on non-vector input -- so it's
#' automatically wrapped in a length-1 list first, the same convention
#' already used by hand in `README.Rmd`'s "Twists" example
#' (`path_distortion = list(noise_bridge(...))`). A `list()` of several
#' *different* S7 objects (or of several numeric vectors, for
#' control-point arguments like `shape_beziers()`'s `x`/`y`), one per
#' shape, passes through unchanged, since a plain unclassed list already
#' satisfies `is.vector()`.
#'
#' @param .f A drawable constructor (e.g. [shape_circle()]).
#' @param args A named list of arguments to vectorize over.
#' @return A [sketch] containing one drawable per recycled row.
#' @noRd
vectorize_shapes <- function(.f, args) {
  args <- purrr::map(args, \(a) if (is.vector(a)) a else list(a))
  sketch(shapes = purrr::pmap(args, .f))
}
