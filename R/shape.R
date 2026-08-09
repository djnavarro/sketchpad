#' A polygon defined directly by its vertices
#'
#' `shape` is the simplest [drawable]: the user supplies `x` and `y`
#' coordinates directly, and `points` is computed trivially from them.
#' It is most often produced by [convert()]ing a more complex drawable
#' (e.g. a [blob] or [twist]) down to its raw vertices.
#'
#' @param x Numeric vector of x coordinates.
#' @param y Numeric vector of y coordinates.
#' @param ... Arguments passed to [style()].
#'
#' @export
shape <- S7::new_class(
  name = "shape",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    points = S7::new_property(
      class = points,
      getter = function(self) {
        points(x = self@x, y = self@y)
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      "x and y must be the same length"
    }
  },
  constructor = function(x, y, ...) {
    S7::new_object(
      drawable(),
      x = x,
      y = y,
      style = style(...)
    )
  }
)

