#' A tapered ribbon between two points
#'
#' `shape_ribbon` is a [drawable] polygon that follows a straight line
#' between `(x, y)` and `(xend, yend)`, with a width that tapers at both
#' ends and varies along its length according to simplex noise.
#'
#' @param x,y Start point. Default `0`.
#' @param xend,yend End point. Default `1`.
#' @param width Maximum width. Must be non-negative. Default `0.2`.
#' @param n Number of points used along the path. Default `100L`.
#' @param frequency Noise frequency. Must be non-negative. Default `1`.
#' @param octaves Number of noise octaves. Must be a positive integer.
#'   Default `2L`.
#' @param seed Integer seed for the noise field. Default `1L`.
#' @param ... Arguments passed to [style()].
#'
#' @family 2D shapes
#' @export
shape_ribbon <- S7::new_class(
  name = "shape_ribbon",
  parent = drawable,
  properties = list(
    x          = S7::class_numeric,
    y          = S7::class_numeric,
    xend       = S7::class_numeric,
    yend       = S7::class_numeric,
    width      = S7::class_numeric,
    n          = S7::class_integer,
    frequency  = S7::class_numeric,
    octaves    = S7::class_integer,
    seed       = S7::class_integer,
    points = S7::new_property(
      class = point_set,
      getter = function(self) {
        x <- seq(self@x, self@xend, length.out = self@n)
        y <- seq(self@y, self@yend, length.out = self@n)
        displacement <- ambient::fracture(
          noise = ambient::gen_simplex,
          fractal = ambient::fbm,
          x = x,
          y = y,
          frequency = self@frequency,
          seed = self@seed,
          octaves = self@octaves
        ) |>
          ambient::normalize(to = c(0, 1))
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
                         width = 0.2,
                         n = 100L,
                         frequency = 1,
                         octaves = 2L,
                         seed = 1L,
                         ...) {
    S7::new_object(
      drawable(),
      x = x,
      y = y,
      xend = xend,
      yend = yend,
      width = width,
      n = n,
      frequency = frequency,
      octaves = octaves,
      seed = seed,
      style = style(...)
    )
  },
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@xend) != 1) return("xend must be length 1")
    if (length(self@yend) != 1) return("yend must be length 1")
    if (length(self@width) != 1) return("width must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (length(self@frequency) != 1) return("frequency must be length 1")
    if (length(self@octaves) != 1) return("octaves must be length 1")
    if (length(self@seed) != 1) return("seed must be length 1")
    if (self@width < 0) return("width must be a non-negative number")
    if (self@frequency < 0) return("frequency must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
    if (self@octaves < 1L) return("octaves must be a positive integer")
  }
)

