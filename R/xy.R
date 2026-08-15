#' A set of locations in 2D space
#'
#' `xy` represents a collection of locations in two-dimensional space as
#' parallel `x` and `y` coordinate vectors. Most [drawable] subclasses expose
#' their geometry as a computed `points` property of class `xy`;
#' [shape_raw] is the exception, where the user supplies `x`/`y` directly.
#' Named `xy` rather than `points` so this exported constructor doesn't mask
#' `graphics::points()`.
#'
#' @param x Numeric vector of x coordinates.
#' @param y Numeric vector of y coordinates.
#'
#' @examples
#' xy(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1))
#'
#' @family core structure
#' @export
xy <- S7::new_class(
  name = "xy",
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
