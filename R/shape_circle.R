#' A circle
#'
#' `shape_circle` is a [drawable] defined by a centroid and a radius; its
#' vertices are computed as evenly spaced points around the circumference.
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param radius Radius. Must be non-negative. Default `1`.
#' @param n Number of points used to approximate the circle. Default `100L`.
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(shape_circle(radius = 1))
#' draw(shape_circle(x = 1, y = 1, radius = 0.5, n = 6L, color = "darkred"))
#'
#' @family 2D shapes
#' @export
shape_circle <- S7::new_class(
  name = "shape_circle",
  parent = drawable,
  properties = list(
    x      = S7::class_numeric,
    y      = S7::class_numeric,
    radius = S7::class_numeric,
    n      = S7::class_integer,
    points = S7::new_property(
      class = point_set,
      getter = function(self) {
        angle <- seq(0, 2 * pi, length.out = self@n)
        point_set(
          x = self@x + self@radius * cos(angle),
          y = self@y + self@radius * sin(angle)
        )
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@radius) != 1) return("radius must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (self@radius < 0) return("radius must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
  },
  constructor = function(x = 0, y = 0, radius = 1, n = 100L, ...) {
    S7::new_object(
      drawable(),
      x = x,
      y = y,
      radius = radius,
      n = n,
      style = style(...)
    )
  }
)

