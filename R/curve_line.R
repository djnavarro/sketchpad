#' An open polyline
#'
#' `curve_line` is a [drawable] whose path connects an arbitrary number of
#' control points `(x, y)` with straight segments, in order. With two control
#' points this is a single line segment; with more, an open polyline. Unlike
#' [curve_bezier()]/[shape_bezier()], the control points are not smoothed or
#' resampled -- `points` is exactly `(x, y)`, so there is no `n` argument.
#'
#' `style@fill` has no effect for `curve_line()` -- see [drawable]'s
#' `geometry` documentation for why `"path"` geometries have no interior to
#' fill. Passing `fill` via `...` is still accepted (it's simply ignored at
#' draw time), since `style()` is shared across every `geometry`.
#'
#' @param x,y Numeric vectors of control point coordinates. Must be the
#'   same length, with at least two control points.
#' @param trans A [trans] object applied to the curve's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(curve_line(x = c(0, 1, 1, 2), y = c(0, 1, 0, 1)))
#'
#' @family 1D curves
#' @export
curve_line <- S7::new_class(
  name = "curve_line",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    points = S7::new_property(
      class = xy,
      getter = function(self) apply_trans(self@trans, xy(x = self@x, y = self@y))
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) return("x and y must be the same length")
    if (length(self@x) < 2) return("at least two control points are required")
  },
  constructor = function(x, y, trans = trans_identity(), ...) {
    S7::new_object(
      drawable(geometry = "path", trans = trans),
      x = x,
      y = y,
      style = style(...)
    )
  }
)
