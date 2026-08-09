#' A set of polygon vertices
#'
#' `point_set` represents the vertices of a polygon as parallel `x` and `y`
#' coordinate vectors. Most [drawable] subclasses expose their vertices as a
#' computed `points` property of class `point_set`; [shape_raw] is the
#' exception, where the user supplies `x`/`y` directly. Named `point_set`
#' rather than `points` so this exported constructor doesn't mask
#' `graphics::points()`.
#'
#' @param x Numeric vector of x coordinates.
#' @param y Numeric vector of y coordinates.
#'
#' @family core structure
#' @export
point_set <- S7::new_class(
  name = "point_set",
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      "x and y must be the same length"
    }
  }
)
