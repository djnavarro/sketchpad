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
#' @param trans A [trans] object applied to the curve's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(curve_bezier(x = c(0, 0.5, 1), y = c(0, 1, 0)))
#'
#' @family 1D curves
#' @export
curve_bezier <- S7::new_class(
  name = "curve_bezier",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    n = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        apply_trans(self@trans, bezier_curve_points(self@x, self@y, self@n))
      }
    )
  ),
  validator = function(self) validate_bezier_args(self@x, self@y, self@n),
  constructor = function(x, y, n = 100L, trans = trans_identity(), ...) {
    S7::new_object(
      drawable(geometry = "path", trans = trans),
      x = x,
      y = y,
      n = n,
      style = style(...)
    )
  }
)

#' Multiple open Bezier curves at once
#'
#' `curve_beziers()` is a vectorized version of [curve_bezier()]. Since
#' `x`/`y` are themselves numeric vectors of control points for a single
#' curve, `curve_beziers()` takes them as a `list()` of numeric vectors
#' instead -- one vector of control points per curve. Every other
#' argument may be a plain vector, recycled against `x`/`y` via
#' `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). The result is a [sketch] containing one
#' `curve_bezier()` per list element/recycled row, rather than a single
#' drawable.
#'
#' @inheritParams curve_bezier
#' @param x,y A `list()` of numeric vectors of control point coordinates,
#'   one vector per curve. Each vector must be the same length as its
#'   `y`/`x` counterpart, with at least two control points.
#' @return A [sketch].
#'
#' @examples
#' draw(curve_beziers(
#'   x = list(c(0, 0.5, 1), c(2, 2.5, 3)),
#'   y = list(c(0, 1, 0), c(0, 1, 0))
#' ))
#'
#' @family 1D curves
#' @export
curve_beziers <- function(x, y, n = 100L, trans = trans_identity(), ...) {
  vectorize_shapes(curve_bezier, c(
    list(x = x, y = y, n = n, trans = trans),
    list(...)
  ))
}
