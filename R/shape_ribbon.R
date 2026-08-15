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
#' @param distortion A [noise_field] controlling the width modulation.
#'   Default `noise_field()`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_ribbon(x = 0, y = 0, xend = 1, yend = 1, width = 0.3))
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
    distortion = noise_field,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        x <- seq(self@x, self@xend, length.out = self@n)
        y <- seq(self@y, self@yend, length.out = self@n)
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

#' Multiple ribbons at once
#'
#' `shape_ribbons()` is a vectorized version of [shape_ribbon()]: each
#' argument may be a vector, recycled against the others via
#' `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). A shared `distortion` [noise_field] is automatically
#' recycled across every ribbon; pass a `list()` of several different
#' `noise_field`s instead to vary it per ribbon. The result is a
#' [sketch] containing one `shape_ribbon()` per recycled row, rather
#' than a single drawable.
#'
#' @rdname shape_ribbon
#' @return For `shape_ribbons()`, a [sketch].
#'
#' @examples
#' draw(shape_ribbons(x = 1:3, y = 0, xend = 2:4, yend = 1, width = 0.3))
#'
#' @family 2D shapes
#' @export
shape_ribbons <- function(x = 0,
                           y = 0,
                           xend = 1,
                           yend = 1,
                           width = 0.2,
                           n = 100L,
                           distortion = noise_field(),
                           trans = trans_identity(),
                           ...) {
  vectorize_shapes(shape_ribbon, c(
    list(x = x, y = y, xend = xend, yend = yend, width = width, n = n,
         distortion = distortion, trans = trans),
    list(...)
  ))
}

