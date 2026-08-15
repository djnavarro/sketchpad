#' An open arc
#'
#' `curve_arc` is [shape_wedge()]'s arc alone, with no centroid vertex: an
#' open path of `n` points on the circle centred at `(x, y)` with the given
#' `radius`, sweeping from angle `start` to `end` (radians). Shares its point
#' computation and argument validation with `shape_wedge()` via two internal
#' helpers factored into `R/shape_wedge.R` (`arc_points()`,
#' `validate_arc_args()`), differing only in which `drawable(geometry = ...)`
#' they construct from and the missing centroid vertex.
#'
#' `style@fill` has no effect for `curve_arc()` -- see [drawable]'s
#' `geometry` documentation for why `"path"` geometries have no interior to
#' fill. Passing `fill` via `...` is still accepted (it's simply ignored at
#' draw time), since `style()` is shared across every `geometry`.
#'
#' @inheritParams shape_wedge
#'
#' @examples
#' draw(curve_arc(start = 0, end = 3 * pi / 2))
#'
#' @family 1D curves
#' @export
curve_arc <- S7::new_class(
  name = "curve_arc",
  parent = drawable,
  properties = list(
    x      = S7::class_numeric,
    y      = S7::class_numeric,
    radius = S7::class_numeric,
    start  = S7::class_numeric,
    end    = S7::class_numeric,
    n      = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) arc_points(self@x, self@y, self@radius, self@start, self@end, self@n)
    )
  ),
  validator = function(self) {
    validate_arc_args(self@x, self@y, self@radius, self@start, self@end, self@n)
  },
  constructor = function(x = 0, y = 0, radius = 1, start = 0, end = pi / 2, n = 100L, ...) {
    S7::new_object(
      drawable(geometry = "path"),
      x = x,
      y = y,
      radius = radius,
      start = start,
      end = end,
      n = n,
      style = style(...)
    )
  }
)
