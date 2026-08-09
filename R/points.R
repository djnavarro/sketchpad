#' Polygon vertices
#'
#' `points` represents the vertices of a polygon as parallel `x` and `y`
#' coordinate vectors. Most [drawable] subclasses expose `points` as a
#' computed property; [shape] is the exception, where the user supplies
#' `x`/`y` directly.
#'
#' @param x Numeric vector of x coordinates.
#' @param y Numeric vector of y coordinates.
#'
#' @export
points <- S7::new_class(
  name = "points",
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

