#' An open Bezier curve
#'
#' `curve_bezier` is a [drawable] whose path follows a Bezier curve defined
#' by an arbitrary number of control points (`x`, `y`), using the same
#' Bernstein-polynomial machinery as [shape_bezier()]. Where `shape_bezier()`
#' always closes back to its first control point (a consequence of every
#' `"polygon"`-geometry `drawable` being rendered as a closed
#' `grid::polygonGrob()`), `curve_bezier()` sets `geometry = "path"` and is
#' rendered as an open `grid::polylineGrob()` instead, stopping at its last
#' control point rather than looping back.
#'
#' `style@fill` has no effect for `curve_bezier()` -- see [drawable]'s
#' `geometry` documentation for why `"path"` geometries have no interior to
#' fill. Passing `fill` via `...` is still accepted (it's simply ignored at
#' draw time), since `style()` is shared across every `geometry`.
#'
#' @param x,y Numeric vectors of control point coordinates. Must be the
#'   same length, with at least two control points.
#' @param n Number of points used to sample the curve. Default `100L`.
#' @param ... Arguments passed to [style()].
#'
#' @export
curve_bezier <- S7::new_class(
  name = "curve_bezier",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    n = S7::class_integer,
    points = S7::new_property(
      class = point_set,
      getter = function(self) bezier_curve_points(self@x, self@y, self@n)
    )
  ),
  validator = function(self) validate_bezier_args(self@x, self@y, self@n),
  constructor = function(x, y, n = 100L, ...) {
    S7::new_object(
      drawable(geometry = "path"),
      x = x,
      y = y,
      n = n,
      style = style(...)
    )
  }
)
