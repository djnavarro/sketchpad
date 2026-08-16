#' A set of locations in 2D space
#'
#' `xy` represents a collection of locations in two-dimensional space as
#' parallel `x`/`y` coordinate vectors, plus a parallel `id` vector grouping
#' those locations into sub-paths.
#'
#' Most [drawable] subclasses expose their geometry as a computed `points`
#' property of class `xy`; [shape_raw] is the exception, where the user
#' supplies `x`/`y` directly. Named `xy` rather than `points` so this
#' exported constructor doesn't mask `graphics::points()`.
#'
#' `id` marks which sub-path/contour each `x`/`y` location belongs to --
#' locations sharing the same `id` are connected into one contour; a
#' different `id` starts a new one. Every existing single-contour drawable
#' has exactly one implicit sub-path, so `id` defaults to `rep(1L,
#' length(x))` whenever left `NULL` (the default), meaning no drawable's own
#' `points` getter needs to pass `id` explicitly to keep its current,
#' single-contour behavior. Multiple sub-paths let a single [drawable]
#' render as several disjoint shapes sharing one [style] (e.g. two separate
#' blobs), or -- combined with [style()]'s `rule` -- as a shape with a hole
#' (a sub-path nested inside another). No constructor currently exposes a
#' way to *set* a non-trivial `id` when building geometry by hand; this is
#' the underlying data-shape change alone, not yet paired with an
#' author-facing API (see `.agents/PLAN.md`).
#'
#' @param x Numeric vector of x coordinates.
#' @param y Numeric vector of y coordinates.
#' @param id Integer (or integerish numeric) vector the same length as
#'   `x`/`y`, grouping locations into sub-paths. Default `NULL`, filled in
#'   as `rep(1L, length(x))` (a single sub-path).
#'
#' @examples
#' xy(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1))
#'
#' # two sub-paths: a pair of disjoint 4-point contours sharing one xy object
#' xy(x = c(0, 1, 1, 0, 2, 3, 3, 2), y = c(0, 0, 1, 1, 0, 0, 1, 1), id = rep(1:2, each = 4))
#'
#' @family core structure
#' @export
xy <- S7::new_class(
  name = "xy",
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    id = S7::class_integer
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      return("x and y must be the same length")
    }
    if (length(self@id) != length(self@x)) {
      return("id must be the same length as x and y")
    }
  },
  constructor = function(x, y, id = NULL) {
    if (is.null(id)) {
      id <- rep(1L, length(x))
    } else {
      id <- as_integerish(id, "id")
    }
    S7::new_object(S7::S7_object(), x = x, y = y, id = id)
  }
)
