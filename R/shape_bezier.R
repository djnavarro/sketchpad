#' Evaluate a Bezier curve via Bernstein polynomials
#'
#' Internal helper used by [shape_bezier] to evaluate one coordinate axis of a
#' Bezier curve at a vector of parameter values, using the Bernstein
#' polynomial basis (rather than De Casteljau's algorithm).
#'
#' @param beta Numeric vector of control point coordinates along one axis.
#' @param t Numeric vector of parameter values in `[0, 1]`.
#'
#' @return Numeric vector the same length as `t`.
#' @noRd
bernstein <- function(beta, t = seq(0, 1, .01)) {
  n <- length(beta) - 1
  w <- choose(n, 0:n)
  b <- rep(0, length(t))
  for (v in 0:n) {
    b <- b + beta[v + 1] * w[v + 1] * t^v * (1 - t)^(n - v)
  }
  b
}

#' Validate the shared arguments of a Bezier-based drawable
#'
#' Internal helper shared by [shape_bezier] and [curve_bezier], whose
#' constructors take identical `x`/`y`/`n` arguments and differ only in
#' `geometry` (closed polygon vs. open path).
#'
#' @param x,y,n The arguments of the same name from the calling
#'   constructor.
#' @return An error message string, or `NULL` if valid.
#' @noRd
validate_bezier_args <- function(x, y, n) {
  if (length(x) != length(y)) return("x and y must be the same length")
  if (length(x) < 2) return("at least two control points are required")
  if (length(n) != 1) return("n must be length 1")
  if (n < 1L) return("n must be a positive integer")
  NULL
}

#' Sample a Bezier curve's points
#'
#' Internal helper shared by [shape_bezier] and [curve_bezier]: evaluates
#' both coordinate axes via `bernstein()` at `n` evenly-spaced parameter
#' values.
#'
#' @param x,y,n The arguments of the same name from the calling
#'   constructor.
#' @return A [xy].
#' @noRd
bezier_curve_points <- function(x, y, n) {
  t <- seq(0, 1, length.out = n)
  xy(x = bernstein(x, t), y = bernstein(y, t))
}

#' A closed Bezier curve
#'
#' `shape_bezier` is a [drawable] whose outline follows a Bezier curve
#' defined by an arbitrary number of control points (`x`, `y`). With two
#' control points this is a straight line; with four, a cubic Bezier of
#' the kind used to build ribbons and other flowing shapes. Since
#' [draw()] renders every `"polygon"`-geometry `drawable`'s `points` as a
#' closed polygon, the curve is implicitly closed from its last control
#' point back to its first -- for an open Bezier curve/path instead, see
#' [curve_bezier()].
#'
#' @param x,y Numeric vectors of control point coordinates. Must be the
#'   same length, with at least two control points.
#' @param n Number of points used to sample the curve. Default `100L`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_bezier(x = c(0, 0.5, 1, 0.5), y = c(0, 1, 0, -1)))
#'
#' # two control points collapse the curve to a straight-edged polygon
#' draw(shape_bezier(x = c(0, 1), y = c(0, 1), fill = "steelblue"))
#'
#' # more control points give the curve more inflections
#' draw(shape_bezier(
#'   x = c(0, 0.3, 0.6, 1, 0.6, 0.3), y = c(0, 1, -1, 0, 1, -1),
#'   fill = fill_hatch(angle = 60, spacing = 0.08)
#' ))
#'
#' @family 2D shapes
#' @export
shape_bezier <- S7::new_class(
  name = "shape_bezier",
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
      drawable(trans = trans, pathlike = TRUE),
      x = x,
      y = y,
      n = n,
      style = style(...)
    )
  }
)

#' Multiple closed Bezier curves at once
#'
#' `shape_beziers()` is a vectorized version of [shape_bezier()]. Since
#' `x`/`y` are themselves numeric vectors of control points for a single
#' curve, `shape_beziers()` takes them as a `list()` of numeric vectors
#' instead -- one vector of control points per shape -- rather than a
#' bare vector (which `shape_circles()`-style constructors use for a
#' plain per-shape scalar). Every other argument may be a plain vector,
#' recycled against `x`/`y` via `purrr::pmap()`'s own vctrs-based rules
#' (any length-1 element is broadcast to the common length; mismatched
#' lengths greater than 1 raise an error). The result is a [sketch]
#' containing one `shape_bezier()` per list element/recycled row, rather
#' than a single drawable.
#'
#' @rdname shape_bezier
#' @param x,y For `shape_bezier()`, numeric vectors of control point
#'   coordinates, the same length, with at least two control points. For
#'   `shape_beziers()`, a `list()` of such vectors instead -- one vector
#'   of control points per shape.
#' @return For `shape_beziers()`, a [sketch].
#'
#' @examples
#' draw(shape_beziers(
#'   x = list(c(0, 0.5, 1, 0.5), c(2, 2.5, 3, 2.5)),
#'   y = list(c(0, 1, 0, -1), c(0, 1, 0, -1))
#' ))
#'
#' @family 2D shapes
#' @export
shape_beziers <- function(x, y, n = 100L, trans = trans_identity(), ...) {
  vectorize_shapes(shape_bezier, c(
    list(x = x, y = y, n = n, trans = trans),
    list(...)
  ))
}

