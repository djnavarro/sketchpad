#' An irregular, "blobby" circle
#'
#' `shape_blob` is a [drawable] similar to [shape_circle], except that its
#' radius varies smoothly around the circumference according to
#' Perlin/simplex noise generated with \pkg{ambient}.
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param radius Mean radius. Must be non-negative. Default `1`.
#' @param range Amplitude of the radius distortion. Must be non-negative.
#'   Default `0.2`.
#' @param n Number of points used to approximate the outline. Default `100L`.
#' @param distortion A [noise_field] controlling the radius distortion.
#'   Default `noise_field()`.
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(shape_blob(radius = 1, range = 0.3, distortion = noise_field(seed = 4821L)))
#'
#' @family 2D shapes
#' @export
shape_blob <- S7::new_class(
  name = "shape_blob",
  parent = drawable,
  properties = list(
    x          = S7::class_numeric,
    y          = S7::class_numeric,
    radius     = S7::class_numeric,
    range      = S7::class_numeric,
    n          = S7::class_integer,
    distortion = noise_field,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        angle <- seq(0, 2 * pi, length.out = self@n)
        pointwise_radius <- noise_sample(
          self@distortion,
          x = self@x + cos(angle) * self@radius,
          y = self@y + sin(angle) * self@radius,
          to = self@radius + c(-1, 1) * self@range
        )
        xy(
          x = self@x + pointwise_radius * cos(angle),
          y = self@y + pointwise_radius * sin(angle)
        )
      }
    )
  ),
  constructor = function(x = 0,
                         y = 0,
                         radius = 1,
                         range = 0.2,
                         n = 100L,
                         distortion = noise_field(),
                         ...) {
    S7::new_object(
      drawable(),
      x = x,
      y = y,
      radius = radius,
      range = range,
      n = n,
      distortion = distortion,
      style = style(...)
    )
  },
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@radius) != 1) return("radius must be length 1")
    if (length(self@range) != 1) return("range must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (self@radius < 0) return("radius must be a non-negative number")
    if (self@range < 0) return("range must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
  }
)

