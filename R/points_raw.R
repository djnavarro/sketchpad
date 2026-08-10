#' A scatter of points defined directly by their coordinates
#'
#' `points_raw` is [shape_raw]'s `"points"`-geometry analog, and the first
#' concrete constructor to use `geometry = "points"` (previously reserved
#' on the dimensional reading `"points"`(0D)/`"path"`(1D)/`"polygon"`(2D),
#' but with no constructor exposing it -- see `.agents/PLAN.md`). The user
#' supplies `x`/`y` coordinates directly, rendered as unconnected markers
#' rather than a connected outline or path.
#'
#' `style@fill` and every line-related `style` property (`linewidth`,
#' `linetype`, `linejoin`, `lineend`, `linemitre`) have no effect for
#' `points_raw()` -- see [drawable]'s `geometry` documentation and
#' `geometry_grob()`'s internal dispatch (`R/draw.R`) for why a `"points"`
#' geometry has no line to stroke and no interior to fill. Only `style@color`
#' is used, as the marker colour.
#'
#' @param x Numeric vector of x coordinates.
#' @param y Numeric vector of y coordinates.
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(points_raw(
#'   x = seq(0, 1, length.out = 20),
#'   y = sin(seq(0, 2 * pi, length.out = 20)) / 2 + 0.5,
#'   color = "steelblue"
#' ))
#'
#' @family 0D points
#' @export
points_raw <- S7::new_class(
  name = "points_raw",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    points = S7::new_property(
      class = point_set,
      getter = function(self) {
        point_set(x = self@x, y = self@y)
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      "x and y must be the same length"
    }
  },
  constructor = function(x, y, ...) {
    S7::new_object(
      drawable(geometry = "points"),
      x = x,
      y = y,
      style = style(...)
    )
  }
)
