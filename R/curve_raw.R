#' An open path defined directly by its vertices
#'
#' `curve_raw` is [shape_raw]'s `"path"`-geometry analog: the user supplies
#' `x`/`y` coordinates directly, connected by straight segments in the
#' order given, with no smoothing, resampling, or implicit closing edge.
#' Unlike [curve_line()] (which requires at least two control points, since
#' a single-point "line" isn't meaningful), `curve_raw` places no minimum
#' on `length(x)`, matching [shape_raw]'s own leniency -- it exists
#' primarily as a `convert()` target for "freezing" any `"path"`-geometry
#' drawable's computed points, the same role [shape_raw] plays for
#' `"polygon"`-geometry drawables.
#'
#' `style@fill` has no effect for `curve_raw()` -- see [drawable]'s
#' `geometry` documentation for why `"path"` geometries have no interior to
#' fill. Passing `fill` via `...` is still accepted (it's simply ignored at
#' draw time), since `style()` is shared across every `geometry`.
#'
#' @param x Numeric vector of x coordinates.
#' @param y Numeric vector of y coordinates.
#' @param ... Arguments passed to [style()].
#'
#' @family 1D curves
#' @export
curve_raw <- S7::new_class(
  name = "curve_raw",
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
      drawable(geometry = "path"),
      x = x,
      y = y,
      style = style(...)
    )
  }
)
