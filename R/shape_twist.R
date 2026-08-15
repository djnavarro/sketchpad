#' Sample a Brownian-bridge-displaced path
#'
#' Internal helper shared by [shape_twist] and [curve_twist]: builds a
#' straight backbone between `(x, y)` and `(xend, yend)`, then displaces
#' it with two independent [noise_bridge] draws (one per axis, the
#' second seed-offset from `path_distortion`'s own `seed` so the two
#' axes wander independently).
#'
#' @param x,y Start point.
#' @param xend,yend End point.
#' @param n Number of points used along the path.
#' @param width Scale factor for the displacement (`0.1 * width`, matching
#'   [shape_twist()]'s own scaling of its Brownian bridge).
#' @param path_distortion A [noise_bridge].
#' @return A [xy].
#' @noRd
twisted_path_points <- function(x, y, xend, yend, n, width, path_distortion) {
  x_base <- seq(x, xend, length.out = n)
  y_base <- seq(y, yend, length.out = n)
  x_disp <- noise_sample(path_distortion, n = n, scale = 0.1 * width)
  # y displacement reuses the same smooth/seed settings, offset by
  # one seed so the two axes wander independently
  y_disp <- noise_sample(
    noise_bridge(smooth = path_distortion@smooth, seed = path_distortion@seed + 1L),
    n = n,
    scale = 0.1 * width
  )
  xy(
    x = x_base + x_disp,
    y = y_base + y_disp
  )
}

#' A twisted ribbon following a random path
#'
#' `shape_twist` is like [shape_ribbon], but the underlying path is a
#' Brownian bridge rather than a straight line, giving the polygon a
#' wandering, twisted appearance.
#'
#' @param x,y Start point. Default `0`.
#' @param xend,yend End point. Default `1`.
#' @param width Maximum width. Must be non-negative. Default `0.2`.
#' @param n Number of points used along the path. Default `100L`.
#' @param path_distortion A [noise_bridge] controlling the path's
#'   Brownian bridge. Default `noise_bridge()`.
#' @param distortion A [noise_field] controlling the width modulation.
#'   Default `noise_field()`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(shape_twist(
#'   x = 0, y = 0, xend = 1, yend = 0, width = 0.2,
#'   path_distortion = noise_bridge(seed = 7734L)
#' ))
#'
#' @family 2D shapes
#' @export
shape_twist <- S7::new_class(
  name = "shape_twist",
  parent = drawable,
  properties = list(
    x          = S7::class_numeric,
    y          = S7::class_numeric,
    xend       = S7::class_numeric,
    yend       = S7::class_numeric,
    width           = S7::class_numeric,
    n               = S7::class_integer,
    path_distortion = noise_bridge,
    distortion      = noise_field,
    path = S7::new_property(
      class = xy,
      getter = function(self) {
        twisted_path_points(
          x = self@x, y = self@y, xend = self@xend, yend = self@yend,
          n = self@n, width = self@width, path_distortion = self@path_distortion
        )
      }
    ),
    points = S7::new_property(
      class = xy,
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
        apply_trans(self@trans, xy(
          x = c(x - width * dy, x[self@n:1L] + width[self@n:1L] * dy),
          y = c(y + width * dx, y[self@n:1L] - width[self@n:1L] * dx)
        ))
      }
    )
  ),
  constructor = function(x = 0,
                         y = 0,
                         xend = 1,
                         yend = 1,
                         width = 0.2,
                         n = 100L,
                         path_distortion = noise_bridge(),
                         distortion = noise_field(),
                         trans = trans_identity(),
                         ...) {
    S7::new_object(
      drawable(trans = trans),
      x = x,
      y = y,
      xend = xend,
      yend = yend,
      width = width,
      n = n,
      path_distortion = path_distortion,
      distortion = distortion,
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
    if (self@width < 0) return("width must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
  }
)

