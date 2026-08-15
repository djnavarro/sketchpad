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
  if (length(x) != 1) return("x must be length 1")
  if (length(y) != 1) return("y must be length 1")
  if (length(radius) != 1) return("radius must be length 1")
  if (length(start) != 1) return("start must be length 1")
  if (length(end) != 1) return("end must be length 1")
  if (length(n) != 1) return("n must be length 1")
  if (radius < 0) return("radius must be a non-negative number")
  if (n < 2L) return("n must be an integer of at least 2")
}

#' A pie-slice wedge
#'
#' `shape_wedge` is a [drawable] defined by a centroid, a radius, and a
#' `start`/`end` angle (in radians): its outline is the centroid, followed by
#' `n` points along the circular arc from `start` to `end`. `grid`'s own
#' polygon closing then draws the final straight edge back from the arc's
#' last point to the centroid, giving the familiar pie-slice/wedge shape.
#' [curve_arc()] is the arc alone, with no centroid vertex or fill.
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param radius Radius. Must be non-negative. Default `1`.
#' @param start,end Start/end angle of the arc, in radians. Default `0`/
#'   `pi / 2`.
#' @param n Number of points used to approximate the arc. Must be at least
#'   `2`. Default `100L`.
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(shape_wedge(start = 0, end = pi / 2))
#' draw(shape_wedge(x = 1, y = 1, radius = 0.5, start = pi, end = 2 * pi, color = "darkred"))
#'
#' @family 2D shapes
#' @export
shape_wedge <- S7::new_class(
  name = "shape_wedge",
  parent = drawable,
  properties = list(
    x      = S7::class_numeric,
    y      = S7::class_numeric,
    radius = S7::class_numeric,
    start  = S7::class_numeric,
    end    = S7::class_numeric,
    n      = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        arc <- arc_points(self@x, self@y, self@radius, self@start, self@end, self@n)
        xy(x = c(self@x, arc@x), y = c(self@y, arc@y))
      }
    )
  ),
  validator = function(self) {
    validate_arc_args(self@x, self@y, self@radius, self@start, self@end, self@n)
  },
  constructor = function(x = 0, y = 0, radius = 1, start = 0, end = pi / 2, n = 100L, ...) {
    S7::new_object(
      drawable(),
      x = x,
      y = y,
      radius = radius,
      start = start,
      end = end,
      n = n,
      style = style(...)
    )
  }
)
