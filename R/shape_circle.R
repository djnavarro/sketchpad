#' A circle
#'
#' `shape_circle` is a [drawable] defined by a centroid and a radius; its
#' vertices are computed as evenly spaced points around the circumference.
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param radius Radius. Must be non-negative. Default `1`.
#' @param n Number of points used to approximate the circle. Default `100L`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_circle(radius = 1))
#' draw(shape_circle(x = 1, y = 1, radius = 0.5, n = 6, color = "darkred"))
#' draw(shape_circle(radius = 1, fill = "steelblue", color = NA_character_))
#' draw(shape_circle(radius = 1, fill = fill_hatch(angle = 30)))
#'
#' @family 2D shapes
#' @export
shape_circle <- S7::new_class(
  name = "shape_circle",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    radius = S7::class_numeric,
    n = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        angle <- seq(0, 2 * pi, length.out = self@n)
        apply_trans(self@trans, xy(
          x = self@x + self@radius * cos(angle),
          y = self@y + self@radius * sin(angle)
        ))
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != 1) {
      return("x must be length 1")
    }
    if (length(self@y) != 1) {
      return("y must be length 1")
    }
    if (length(self@radius) != 1) {
      return("radius must be length 1")
    }
    if (length(self@n) != 1) {
      return("n must be length 1")
    }
    if (self@radius < 0) {
      return("radius must be a non-negative number")
    }
    if (self@n < 1L) {
      return("n must be a positive integer")
    }
  },
  constructor = function(x = 0, y = 0, radius = 1, n = 100L, trans = trans_identity(), ...) {
    S7::new_object(
      drawable(trans = trans),
      x = x,
      y = y,
      radius = radius,
      n = as_integerish(n, "n"),
      style = style(...)
    )
  }
)

#' Multiple circles at once
#'
#' `shape_circles()` is a vectorized version of [shape_circle()]: each
#' argument may be a vector, recycled against the others. The result is a
#' [sketch] containing one `shape_circle()` per recycled row, rather than
#' a single drawable.
#'
#' Recycling uses `purrr::pmap()`'s own vctrs-based rules: any length-1
#' element is broadcast to the common length; mismatched lengths greater
#' than 1 raise an error.
#'
#' @rdname shape_circle
#' @return For `shape_circles()`, a [sketch].
#'
#' @examples
#' draw(shape_circles(x = 1:3, radius = c(0.5, 1, 1.5)))
#'
#' # each argument recycles independently, so colour can vary alongside position
#' draw(shape_circles(
#'   x = cos(seq(0, 2 * pi, length.out = 9))[-9],
#'   y = sin(seq(0, 2 * pi, length.out = 9))[-9],
#'   radius = 0.3,
#'   fill = rep(c("tomato", "steelblue"), length.out = 8)
#' ))
#'
#' @family 2D shapes
#' @export
shape_circles <- function(x = 0, y = 0, radius = 1, n = 100L, trans = trans_identity(), ...) {
  vectorize_shapes(shape_circle, c(
    list(x = x, y = y, radius = radius, n = n, trans = trans),
    list(...)
  ))
}
