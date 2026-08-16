#' Compute points along a circular arc
#'
#' Shared by [shape_wedge()] and [curve_arc()]: `n` evenly spaced points on
#' the circle centred at `(x, y)` with the given `radius`, sweeping from
#' angle `start` to `end` (radians). `start`/`end` are not restricted to
#' `[0, 2 * pi]` or to `start < end` -- a larger `end` sweeps
#' counterclockwise, a smaller one clockwise, matching `cos()`/`sin()`'s own
#' periodicity.
#'
#' @noRd
arc_points <- function(x, y, radius, start, end, n) {
  angle <- seq(start, end, length.out = n)
  xy(
    x = x + radius * cos(angle),
    y = y + radius * sin(angle)
  )
}

#' Shared argument validation for [shape_wedge()]/[curve_arc()]
#'
#' @noRd
validate_arc_args <- function(x, y, radius, start, end, n) {
  if (length(x) != 1) {
    return("x must be length 1")
  }
  if (length(y) != 1) {
    return("y must be length 1")
  }
  if (length(radius) != 1) {
    return("radius must be length 1")
  }
  if (length(start) != 1) {
    return("start must be length 1")
  }
  if (length(end) != 1) {
    return("end must be length 1")
  }
  if (length(n) != 1) {
    return("n must be length 1")
  }
  if (radius < 0) {
    return("radius must be a non-negative number")
  }
  if (n < 2L) {
    return("n must be an integer of at least 2")
  }
}

#' A pie-slice wedge or annulus segment
#'
#' `shape_wedge` is a [drawable] defined by a centroid, a radius, and a
#' `start`/`end` angle (in radians): its outline is the centroid, followed by
#' `n` points along the circular arc from `start` to `end`.
#'
#' `grid`'s own polygon closing then draws the final straight edge back from
#' the arc's last point to the centroid, giving the familiar pie-slice/wedge
#' shape. [curve_arc()] is the arc alone, with no centroid vertex or fill.
#'
#' `inner_radius` (default `0`) turns the pie slice into a ring slice (an
#' annulus segment): when greater than `0`, the centroid vertex is dropped
#' entirely, and the outline instead traces the outer arc from `start` to
#' `end` followed by a second, inner arc of radius `inner_radius` swept back
#' from `end` to `start` -- `grid`'s own polygon closing then draws the
#' final straight edge back to the outer arc's first point, giving a
#' four-sided (two arcs, two straight radial edges) ring-slice outline
#' rather than a pie slice's three-sided one (two straight edges meeting at
#' the centroid, one arc). `inner_radius = 0` (the default) recovers the
#' original pie-slice outline exactly, since a zero-radius "inner arc"
#' would otherwise degenerate to the centroid repeated `n` times.
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param radius Radius. Must be non-negative. Default `1`.
#' @param inner_radius Inner radius. Must be non-negative and no greater
#'   than `radius`. Default `0` (a pie-slice wedge, i.e. no inner arc; see
#'   Details for the ring-slice/annulus-segment shape a positive value
#'   gives instead).
#' @param start,end Start/end angle of the arc, in radians. Default `0`/
#'   `pi / 2`.
#' @param n Number of points used to approximate the arc. Must be at least
#'   `2`. Default `100L`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_wedge(start = 0, end = pi / 2))
#' draw(shape_wedge(
#'   x = 1,
#'   y = 1,
#'   radius = 0.5,
#'   start = pi,
#'   end = 2 * pi,
#'   color = "darkred"
#' ))
#'
#' # a nearly-full sweep gives a pac-man-like shape; the arc always closes
#' # straight back to the centroid
#' draw(shape_wedge(start = 0, end = 1.9 * pi, fill = "goldenrod"))
#'
#' # inner_radius > 0 gives a ring slice (annulus segment) instead of a
#' # pie slice -- no centroid vertex, a hole in the middle
#' draw(shape_wedge(
#'   radius = 1, inner_radius = 0.6, start = 0, end = 1.5 * pi,
#'   fill = "steelblue"
#' ))
#'
#' # a full sweep (start = 0, end = 2 * pi) with inner_radius > 0 gives a
#' # complete ring/annulus
#' draw(shape_wedge(radius = 1, inner_radius = 0.7, start = 0, end = 2 * pi))
#'
#' @family 2D shapes
#' @export
shape_wedge <- S7::new_class(
  name = "shape_wedge",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    radius = S7::class_numeric,
    inner_radius = S7::class_numeric,
    start = S7::class_numeric,
    end = S7::class_numeric,
    n = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        outer <- arc_points(self@x, self@y, self@radius, self@start, self@end, self@n)
        if (self@inner_radius == 0) {
          return(apply_trans(self@trans, xy(x = c(self@x, outer@x), y = c(self@y, outer@y))))
        }
        inner <- arc_points(self@x, self@y, self@inner_radius, self@end, self@start, self@n)
        apply_trans(self@trans, xy(x = c(outer@x, inner@x), y = c(outer@y, inner@y)))
      }
    )
  ),
  validator = function(self) {
    msg <- validate_arc_args(self@x, self@y, self@radius, self@start, self@end, self@n)
    if (!is.null(msg)) {
      return(msg)
    }
    if (length(self@inner_radius) != 1) {
      return("inner_radius must be length 1")
    }
    if (self@inner_radius < 0) {
      return("inner_radius must be a non-negative number")
    }
    if (self@inner_radius > self@radius) {
      return("inner_radius must be less than or equal to radius")
    }
  },
  constructor = function(x = 0, y = 0, radius = 1, inner_radius = 0, start = 0, end = pi / 2,
                         n = 100L, trans = trans_identity(), ...) {
    S7::new_object(
      drawable(trans = trans),
      x = x,
      y = y,
      radius = radius,
      inner_radius = inner_radius,
      start = start,
      end = end,
      n = as_integerish(n, "n"),
      style = style(...)
    )
  }
)

#' Multiple pie-slice wedges at once
#'
#' `shape_wedges()` is a vectorized version of [shape_wedge()]: each
#' argument may be a vector, recycled against the others. The result is a
#' [sketch] containing one `shape_wedge()` per recycled row, rather than a
#' single drawable.
#'
#' Recycling uses `purrr::pmap()`'s own vctrs-based rules: any length-1
#' element is broadcast to the common length; mismatched lengths greater
#' than 1 raise an error.
#'
#' @rdname shape_wedge
#' @return For `shape_wedges()`, a [sketch].
#'
#' @examples
#' draw(shape_wedges(start = 0, end = seq(pi / 2, 2 * pi, length.out = 3)))
#'
#' # a pie chart: adjacent wedges sharing a centroid, one slice per value
#' value <- c(30, 20, 50)
#' cum <- c(0, cumsum(value)) / sum(value) * 2 * pi
#' draw(shape_wedges(
#'   start = cum[-length(cum)], end = cum[-1],
#'   fill = c("steelblue", "tomato", "goldenrod")
#' ))
#'
#' # a donut chart: the same idea, with inner_radius > 0
#' draw(shape_wedges(
#'   inner_radius = 0.5,
#'   start = cum[-length(cum)], end = cum[-1],
#'   fill = c("steelblue", "tomato", "goldenrod")
#' ))
#'
#' @family 2D shapes
#' @export
shape_wedges <- function(x = 0, y = 0, radius = 1, inner_radius = 0, start = 0, end = pi / 2,
                         n = 100L, trans = trans_identity(), ...) {
  vectorize_shapes(shape_wedge, c(
    list(
      x = x, y = y, radius = radius, inner_radius = inner_radius,
      start = start, end = end, n = n, trans = trans
    ),
    list(...)
  ))
}
