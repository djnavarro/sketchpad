#' An open spiral
#'
#' `curve_spiral` is a [drawable] whose path winds around a centroid
#' `(x, y)`, sweeping through `turns` full revolutions while its radius
#' interpolates linearly from `radius_start` to `radius_end`. With
#' `radius_start = radius_end` this traces a circle repeated `turns` times
#' (visually indistinguishable from a single circle, since the path
#' retraces itself); the usual case has `radius_start != radius_end`, giving
#' an Archimedean-style spiral that grows or shrinks outward.
#'
#' `style@fill` has no effect for `curve_spiral()` -- see [drawable]'s
#' `geometry` documentation for why `"path"` geometries have no interior to
#' fill. Passing `fill` via `...` is still accepted (it's simply ignored at
#' draw time), since `style()` is shared across every `geometry`.
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param radius_start,radius_end Radius at the start/end of the path. Must
#'   be non-negative. Default `0`/`1`.
#' @param turns Number of full revolutions. Must be positive. Default `3`.
#' @param n Number of points used to approximate the spiral. Default `200L`.
#' @param trans A [trans] object applied to the curve's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(curve_spiral(radius_start = 0, radius_end = 1, turns = 4))
#'
#' # radius_start > radius_end spirals inward instead of outward
#' draw(curve_spiral(
#'   radius_start = 1, radius_end = 0.1, turns = 5, linewidth = 2
#' ))
#'
#' # equal start/end radii retrace a circle -- rarely useful on its own,
#' # but shows turns has no effect on shape when radius doesn't change
#' draw(curve_spiral(radius_start = 1, radius_end = 1, turns = 3))
#'
#' @family 1D curves
#' @export
curve_spiral <- S7::new_class(
  name = "curve_spiral",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    radius_start = S7::class_numeric,
    radius_end = S7::class_numeric,
    turns = S7::class_numeric,
    n = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        angle <- seq(0, 2 * pi * self@turns, length.out = self@n)
        radius <- seq(self@radius_start, self@radius_end, length.out = self@n)
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
    if (length(self@radius_start) != 1) {
      return("radius_start must be length 1")
    }
    if (length(self@radius_end) != 1) {
      return("radius_end must be length 1")
    }
    if (length(self@turns) != 1) {
      return("turns must be length 1")
    }
    if (length(self@n) != 1) {
      return("n must be length 1")
    }
    if (self@radius_start < 0) {
      return("radius_start must be a non-negative number")
    }
    if (self@radius_end < 0) {
      return("radius_end must be a non-negative number")
    }
    if (self@turns <= 0) {
      return("turns must be a positive number")
    }
    if (self@n < 1L) {
      return("n must be a positive integer")
    }
  },
  constructor = function(x = 0,
                         y = 0,
                         radius_start = 0,
                         radius_end = 1,
                         turns = 3,
                         n = 200L,
                         trans = trans_identity(),
                         ...) {
    S7::new_object(
      drawable(geometry = "path", trans = trans),
      x = x,
      y = y,
      radius_start = radius_start,
      radius_end = radius_end,
      turns = turns,
      n = n,
      style = style(...)
    )
  }
)

#' Multiple open spirals at once
#'
#' `curve_spirals()` is a vectorized version of [curve_spiral()]: each
#' argument may be a vector, recycled against the others via
#' `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). The result is a [sketch] containing one
#' `curve_spiral()` per recycled row, rather than a single drawable.
#'
#' @rdname curve_spiral
#' @return For `curve_spirals()`, a [sketch].
#'
#' @examples
#' draw(curve_spirals(x = c(0, 3, 6), turns = c(2, 3, 4)))
#'
#' # nested spirals sharing a centroid, growing radius each time
#' draw(curve_spirals(
#'   radius_start = seq(0.1, 0.5, length.out = 4),
#'   radius_end = seq(0.6, 1, length.out = 4)
#' ))
#'
#' @family 1D curves
#' @export
curve_spirals <- function(x = 0,
                          y = 0,
                          radius_start = 0,
                          radius_end = 1,
                          turns = 3,
                          n = 200L,
                          trans = trans_identity(),
                          ...) {
  vectorize_shapes(curve_spiral, c(
    list(
      x = x, y = y, radius_start = radius_start, radius_end = radius_end,
      turns = turns, n = n, trans = trans
    ),
    list(...)
  ))
}
