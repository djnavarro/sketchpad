#' Generate a smoothed Brownian bridge
#'
#' Internal helper used by [twist] to displace its path away from a
#' straight line. Generates a Brownian bridge on `n` points over `[0, 1]`
#' (a discretized Wiener process pinned to `0` at both ends, matching
#' `e1071::rbridge()`'s construction but implemented directly to avoid
#' the dependency), scales it, and optionally smooths it with repeated
#' local averaging.
#'
#' @param n Number of points in the bridge.
#' @param scale Multiplicative scale applied to the bridge.
#' @param smooth Number of smoothing passes (`0` = no smoothing).
#' @param seed Integer seed.
#'
#' @return Numeric vector of length `n`.
#' @noRd
smooth_bridge <- function(n, scale = .1, smooth = 0, seed = 1L) {
  withr::with_seed(
    seed = seed,
    code = {
      # Discretized Wiener process on n - 1 steps over (0, 1], then
      # subtract the line through the origin and its own endpoint to
      # pin both ends to 0 (the definition of a Brownian bridge).
      z <- cumsum(stats::rnorm(n - 1) / sqrt(n - 1))
      t <- seq_len(n - 1) / (n - 1)
      b <- c(0, z - t * z[n - 1])
    }
  )
  b <- b * scale
  if (smooth > 0) {
    for (i in 1:smooth) {
      b <- (b + c(b[-1], 0) / 2 + c(0, b[-n]) / 2) / 2
    }
  }
  b
}

#' A twisted ribbon following a random path
#'
#' `twist` is like [ribbon], but the underlying path is a Brownian bridge
#' rather than a straight line, giving the polygon a wandering, twisted
#' appearance.
#'
#' @param x,y Start point. Default `0`.
#' @param xend,yend End point. Default `1`.
#' @param width Maximum width. Must be non-negative. Default `0.2`.
#' @param smooth Number of smoothing passes applied to the path. Default `3L`.
#' @param n Number of points used along the path. Default `100L`.
#' @param frequency Noise frequency. Must be non-negative. Default `1`.
#' @param octaves Number of noise octaves. Must be a positive integer.
#'   Default `2L`.
#' @param seed Integer seed for the noise field and path. Default `1L`.
#' @param ... Arguments passed to [style()].
#'
#' @export
twist <- S7::new_class(
  name = "twist",
  parent = drawable,
  properties = list(
    x          = S7::class_numeric,
    y          = S7::class_numeric,
    xend       = S7::class_numeric,
    yend       = S7::class_numeric,
    width      = S7::class_numeric,
    smooth     = S7::class_numeric,
    n          = S7::class_integer,
    frequency  = S7::class_numeric,
    octaves    = S7::class_integer,
    seed       = S7::class_integer,
    path = S7::new_property(
      class = points,
      getter = function(self) {
        x_base <- seq(self@x, self@xend, length.out = self@n)
        y_base <- seq(self@y, self@yend, length.out = self@n)
        x_disp <- smooth_bridge(
          n = self@n,
          smooth = self@smooth,
          scale = 0.1 * self@width,
          seed = self@seed
        )
        y_disp <- smooth_bridge(
          n = self@n,
          smooth = self@smooth,
          scale = 0.1 * self@width,
          seed = self@seed + 1
        )
        points(
          x = x_base + x_disp,
          y = y_base + y_disp
        )
      }
    ),
    points = S7::new_property(
      class = points,
      getter = function(self) {
        x <- self@path@x
        y <- self@path@y
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
        points(
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
                         smooth = 3L,
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
      smooth = smooth,
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

