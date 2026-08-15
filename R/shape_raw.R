#' A polygon defined directly by its vertices
#'
#' `shape_raw` is the simplest [drawable]: the user supplies `x` and `y`
#' coordinates directly, and `points` is computed trivially from them.
#' It is most often produced by [convert()]ing a more complex drawable
#' (e.g. a [shape_blob] or [shape_twist]) down to its raw vertices.
#'
#' @param x Numeric vector of x coordinates.
#' @param y Numeric vector of y coordinates.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(shape_raw(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1)))
#'
#' @family 2D shapes
#' @export
shape_raw <- S7::new_class(
  name = "shape_raw",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        apply_trans(self@trans, xy(x = self@x, y = self@y))
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      "x and y must be the same length"
    }
  },
  constructor = function(x, y, trans = trans_identity(), ...) {
    S7::new_object(
      drawable(trans = trans),
      x = x,
      y = y,
      style = style(...)
    )
  }
)

