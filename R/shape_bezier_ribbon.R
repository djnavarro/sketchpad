#' A ribbon following a Bezier curve
#'
#' `shape_bezier_ribbon` is like [shape_ribbon], but its backbone follows a
#' cubic Bezier curve through `(x, y)`, two control points, and
#' `(xend, yend)`, rather than a straight line -- giving the ribbon a
#' curved rather than straight path. As with [shape_ribbon], the ribbon's
#' width tapers to zero at both ends and varies along its length
#' according to simplex noise.
#'
#' @param x,y Start point. Default `0`.
#' @param xend,yend End point. Default `1`.
#' @param x_ctrl1,y_ctrl1 First Bezier control point. Default `0.5`.
#' @param x_ctrl2,y_ctrl2 Second Bezier control point. Default `0`.
#' @param width Maximum width. Must be non-negative. Default `0.2`.
#' @param n Number of points used along the path. Default `100L`.
#' @param distortion A [noise_field] controlling the width modulation.
#'   Default `noise_field()`.
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(shape_bezier_ribbon(x = 0, y = 0, xend = 1, yend = 0, width = 0.2))
#'
#' @family 2D shapes
#' @export
shape_bezier_ribbon <- S7::new_class(
  name = "shape_bezier_ribbon",
  parent = drawable,
  properties = list(
    x         = S7::class_numeric,
    y         = S7::class_numeric,
    xend      = S7::class_numeric,
    yend      = S7::class_numeric,
    x_ctrl1   = S7::class_numeric,
    y_ctrl1   = S7::class_numeric,
    x_ctrl2   = S7::class_numeric,
    y_ctrl2   = S7::class_numeric,
    width     = S7::class_numeric,
    n         = S7::class_integer,
    distortion = noise_field,
    path = S7::new_property(
      class = point_set,
      getter = function(self) {
        bezier_curve_points(
          x = c(self@x, self@x_ctrl1, self@x_ctrl2, self@xend),
          y = c(self@y, self@y_ctrl1, self@y_ctrl2, self@yend),
          n = self@n
        )
      }
    ),
    points = S7::new_property(
      class = point_set,
      getter = function(self) {
        x <- self@path@x
        y <- self@path@y
        displacement <- noise_sample(self@distortion, x = x, y = y, to = c(0, 1))
        taper <- sqrt(
          seq(0, 1, length.out = self@n) * seq(1, 0, length.out = self@n)
        )
        width <- displacement * taper * self@width
        dx <- self@xend - self@x
        dy <- self@yend - self@y
        point_set(
          x = c(x - width * dy, x[self@n:1L] + width[self@n:1L] * dy),
          y = c(y + width * dx, y[self@n:1L] - width[self@n:1L] * dx)
        )
      }
    )
  ),
  constructor = function(x = 0,
                         y = 0,
                         xend = 1,
                         yend = 1,
                         x_ctrl1 = 0.5,
                         y_ctrl1 = 0.5,
                         x_ctrl2 = 0,
                         y_ctrl2 = 0,
                         width = 0.2,
                         n = 100L,
                         distortion = noise_field(),
                         ...) {
    S7::new_object(
      drawable(),
      x = x,
      y = y,
      xend = xend,
      yend = yend,
      x_ctrl1 = x_ctrl1,
      y_ctrl1 = y_ctrl1,
      x_ctrl2 = x_ctrl2,
      y_ctrl2 = y_ctrl2,
      width = width,
      n = n,
      distortion = distortion,
      style = style(...)
    )
  },
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@xend) != 1) return("xend must be length 1")
    if (length(self@yend) != 1) return("yend must be length 1")
    if (length(self@x_ctrl1) != 1) return("x_ctrl1 must be length 1")
    if (length(self@y_ctrl1) != 1) return("y_ctrl1 must be length 1")
    if (length(self@x_ctrl2) != 1) return("x_ctrl2 must be length 1")
    if (length(self@y_ctrl2) != 1) return("y_ctrl2 must be length 1")
    if (length(self@width) != 1) return("width must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (self@width < 0) return("width must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
  }
)
