#' Evaluate a Bezier curve via Bernstein polynomials
#'
#' Internal helper used by [bezier] to evaluate one coordinate axis of a
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

#' A Bezier curve
#'
#' `bezier` is a [drawable] whose outline follows a Bezier curve defined
#' by an arbitrary number of control points (`x`, `y`). With two control
#' points this is a straight line; with four, a cubic Bezier of the kind
#' used to build ribbons and other flowing shapes. Since [draw()] always
#' renders a `drawable`'s `points` as a closed polygon, the curve is
#' implicitly closed from its last control point back to its first.
#'
#' @param x,y Numeric vectors of control point coordinates. Must be the
#'   same length, with at least two control points.
#' @param n Number of points used to sample the curve. Default `100L`.
#' @param ... Arguments passed to [style()].
#'
#' @export
bezier <- S7::new_class(
  name = "bezier",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    n = S7::class_integer,
    points = S7::new_property(
      class = points,
      getter = function(self) {
        t <- seq(0, 1, length.out = self@n)
        points(
          x = bernstein(self@x, t),
          y = bernstein(self@y, t)
        )
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) return("x and y must be the same length")
    if (length(self@x) < 2) return("at least two control points are required")
    if (length(self@n) != 1) return("n must be length 1")
    if (self@n < 1L) return("n must be a positive integer")
  },
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

