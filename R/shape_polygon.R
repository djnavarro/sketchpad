#' A regular polygon
#'
#' `shape_polygon` is a [drawable] defined by a centroid and a radius; its
#' vertices are `n` evenly spaced points around the circumference, giving a
#' regular n-gon (e.g. `n = 3` a triangle, `n = 6` a hexagon). Unlike
#' [shape_circle()]/[shape_blob()], `points` does not repeat its first vertex
#' at the end -- there are exactly `n` distinct vertices, since
#' `grid::polygonGrob()` closes the path itself and a polygon has no
#' approximation error to hide.
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param radius Radius. Must be non-negative. Default `1`.
#' @param n Number of sides (vertices). Must be at least `3`. Default `6L`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_polygon(radius = 1, n = 3L))
#' draw(shape_polygon(x = 1, y = 1, radius = 0.5, n = 8L, color = "darkred"))
#'
#' @family 2D shapes
#' @export
shape_polygon <- S7::new_class(
  name = "shape_polygon",
  parent = drawable,
  properties = list(
    x      = S7::class_numeric,
    y      = S7::class_numeric,
    radius = S7::class_numeric,
    n      = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        angle <- seq(0, 2 * pi, length.out = self@n + 1)[-(self@n + 1)]
        apply_trans(self@trans, xy(
          x = self@x + self@radius * cos(angle),
          y = self@y + self@radius * sin(angle)
        ))
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@radius) != 1) return("radius must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (self@radius < 0) return("radius must be a non-negative number")
    if (self@n < 3L) return("n must be an integer of at least 3")
  },
  constructor = function(x = 0, y = 0, radius = 1, n = 6L, trans = trans_identity(), ...) {
    S7::new_object(
      drawable(trans = trans),
      x = x,
      y = y,
      radius = radius,
      n = n,
      style = style(...)
    )
  }
)

#' Multiple regular polygons at once
#'
#' `shape_polygons()` is a vectorized version of [shape_polygon()]: each
#' argument may be a vector, recycled against the others via
#' `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). The result is a [sketch] containing one
#' `shape_polygon()` per recycled row, rather than a single drawable.
#'
#' @rdname shape_polygon
#' @return For `shape_polygons()`, a [sketch].
#'
#' @examples
#' draw(shape_polygons(x = 1:3, n = c(3L, 4L, 6L)))
#'
#' @family 2D shapes
#' @export
shape_polygons <- function(x = 0, y = 0, radius = 1, n = 6L, trans = trans_identity(), ...) {
  vectorize_shapes(shape_polygon, c(
    list(x = x, y = y, radius = radius, n = n, trans = trans),
    list(...)
  ))
}
