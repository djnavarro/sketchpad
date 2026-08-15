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
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(shape_bezier(x = c(0, 0.5, 1, 0.5), y = c(0, 1, 0, -1)))
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
      getter = function(self) bezier_curve_points(self@x, self@y, self@n)
    )
  ),
  validator = function(self) validate_bezier_args(self@x, self@y, self@n),
  constructor = function(x, y, n = 100L, ...) {
    S7::new_object(
      drawable(),
      x = x,
      y = y,
      n = n,
      style = style(...)
    )
  }
)

