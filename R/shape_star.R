#' A star
#'
#' `shape_star` is a [drawable] defined by a centroid and two radii: its
#' outline alternates `n` outer vertices (at `outer_radius`) with `n` inner
#' vertices (at `inner_radius`), evenly spaced by angle, giving the familiar
#' `n`-pointed star shape (e.g. `n = 5` a five-pointed star, `n = 6` a
#' Star-of-David-like hexagram outline).
#'
#' Like [shape_polygon()], `points` does not repeat its first vertex at the
#' end -- there are exactly `2 * n` distinct vertices, since
#' `grid::polygonGrob()` closes the path itself. The first vertex is an outer
#' one at angle `0`; use `trans_rotate()` to reorient the star, the same way
#' [shape_polygon()]'s own low-`n` vertices are reoriented.
#'
#' `inner_radius = outer_radius` degenerates the star into a regular
#' `2 * n`-gon (no points), and `inner_radius = 0` collapses every inner
#' vertex onto the centroid, giving a sharp `n`-pointed "asterisk" outline.
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param outer_radius Outer radius (star tips). Must be non-negative.
#'   Default `1`.
#' @param inner_radius Inner radius (between tips). Must be non-negative and
#'   no greater than `outer_radius`. Default `0.5`.
#' @param n Number of star points. Must be at least `2`. Default `5L`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_star())
#' draw(shape_star(x = 1, y = 1, outer_radius = 0.5, n = 8, color = "darkred"))
#' draw(shape_star(n = 6, fill = "goldenrod"))
#'
#' # a sharper star: inner_radius closer to 0
#' draw(shape_star(inner_radius = 0.2, fill = "steelblue"))
#'
#' # rotating a star reorients its tips
#' draw(shape_star(n = 5, trans = trans_rotate(pi / 2)))
#'
#' @family 2D shapes
#' @export
shape_star <- S7::new_class(
  name = "shape_star",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    outer_radius = S7::class_numeric,
    inner_radius = S7::class_numeric,
    n = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        angle <- seq(0, 2 * pi, length.out = 2 * self@n + 1)[-(2 * self@n + 1)]
        radius <- rep(c(self@outer_radius, self@inner_radius), self@n)
        apply_trans(self@trans, xy(
          x = self@x + radius * cos(angle),
          y = self@y + radius * sin(angle)
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
    if (length(self@outer_radius) != 1) {
      return("outer_radius must be length 1")
    }
    if (length(self@inner_radius) != 1) {
      return("inner_radius must be length 1")
    }
    if (length(self@n) != 1) {
      return("n must be length 1")
    }
    if (self@outer_radius < 0) {
      return("outer_radius must be a non-negative number")
    }
    if (self@inner_radius < 0) {
      return("inner_radius must be a non-negative number")
    }
    if (self@inner_radius > self@outer_radius) {
      return("inner_radius must be less than or equal to outer_radius")
    }
    if (self@n < 2L) {
      return("n must be an integer of at least 2")
    }
  },
  constructor = function(x = 0, y = 0, outer_radius = 1, inner_radius = 0.5, n = 5L,
                          trans = trans_identity(), ...) {
    S7::new_object(
      drawable(trans = trans),
      x = x,
      y = y,
      outer_radius = outer_radius,
      inner_radius = inner_radius,
      n = as_integerish(n, "n"),
      style = style(...)
    )
  }
)

#' Multiple stars at once
#'
#' `shape_stars()` is a vectorized version of [shape_star()]: each argument
#' may be a vector, recycled against the others. The result is a [sketch]
#' containing one `shape_star()` per recycled row, rather than a single
#' drawable.
#'
#' Recycling uses `purrr::pmap()`'s own vctrs-based rules: any length-1
#' element is broadcast to the common length; mismatched lengths greater
#' than 1 raise an error.
#'
#' @rdname shape_star
#' @return For `shape_stars()`, a [sketch].
#'
#' @examples
#' draw(shape_stars(x = 1:3, n = c(4L, 5L, 6L)))
#' draw(shape_stars(
#'   x = 0, y = 0, outer_radius = seq(3, 0.5, length.out = 6), n = 5,
#'   fill = rep(c("grey20", "grey90"), length.out = 6)
#' ))
#'
#' @family 2D shapes
#' @export
shape_stars <- function(x = 0, y = 0, outer_radius = 1, inner_radius = 0.5, n = 5L,
                         trans = trans_identity(), ...) {
  vectorize_shapes(shape_star, c(
    list(x = x, y = y, outer_radius = outer_radius, inner_radius = inner_radius, n = n, trans = trans),
    list(...)
  ))
}
