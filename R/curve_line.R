#' An open polyline
#'
#' `curve_line` is a [drawable] whose path connects an arbitrary number of
#' control points `(x, y)` with straight segments, in order. With two control
#' points this is a single line segment; with more, an open polyline.
#'
#' Unlike [curve_bezier()]/[shape_bezier()], the control points are not
#' smoothed or resampled -- `points` is exactly `(x, y)`, so there is no
#' `n` argument.
#'
#' `style@fill` has no effect for `curve_line()` -- see [drawable]'s
#' `geometry` documentation for why `"path"` geometries have no interior to
#' fill. Passing `fill` via `...` is still accepted (it's simply ignored at
#' draw time), since `style()` is shared across every `geometry`.
#'
#' @param x,y Numeric vectors of control point coordinates. Must be the
#'   same length, with at least two control points.
#' @param trans A [trans] object applied to the curve's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(curve_line(x = c(0, 1, 1, 2), y = c(0, 1, 0, 1)))
#'
#' # a thick, square-capped line reads very differently from a thin,
#' # round-capped one
#' draw(curve_line(x = c(0, 1, 2), y = c(0, 1, 0), linewidth = 12, lineend = "square"))
#'
#' # layer several jittered copies for a hand-drawn look
#' draw(effect_tremor(curve_line(x = c(0, 1, 1, 2), y = c(0, 1, 0, 1)), layers = 5L))
#'
#' @family 1D curves
#' @export
curve_line <- S7::new_class(
  name = "curve_line",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    points = S7::new_property(
      class = xy,
      getter = function(self) apply_trans(self@trans, xy(x = self@x, y = self@y))
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      return("x and y must be the same length")
    }
    if (length(self@x) < 2) {
      return("at least two control points are required")
    }
  },
  constructor = function(x, y, trans = trans_identity(), ...) {
    S7::new_object(
      drawable(geometry = "path", trans = trans, pathlike = TRUE),
      x = x,
      y = y,
      style = style(...)
    )
  }
)

#' Multiple open polylines at once
#'
#' `curve_lines()` is a vectorized version of [curve_line()]. Since
#' `x`/`y` are themselves numeric vectors of control points for a single
#' polyline, `curve_lines()` takes them as a `list()` of numeric vectors
#' instead -- one vector of control points per polyline.
#'
#' Every other argument may be a plain vector, recycled against `x`/`y`
#' via `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). The result is a [sketch] containing one
#' `curve_line()` per list element/recycled row, rather than a single
#' drawable.
#'
#' @rdname curve_line
#' @param x,y For `curve_line()`, numeric vectors of control point
#'   coordinates, the same length, with at least two control points. For
#'   `curve_lines()`, a `list()` of such vectors instead -- one vector of
#'   control points per polyline.
#' @return For `curve_lines()`, a [sketch].
#'
#' @examples
#' draw(curve_lines(
#'   x = list(c(0, 1, 1, 2), c(2, 3, 3, 4)),
#'   y = list(c(0, 1, 0, 1), c(0, 1, 0, 1))
#' ))
#'
#' # a simple hatched grid of crossing lines
#' draw(curve_lines(
#'   x = list(c(0, 5), c(0, 5), c(0, 5)),
#'   y = list(c(0, 5), c(1, 4), c(2, 3))
#' ))
#'
#' @family 1D curves
#' @export
curve_lines <- function(x, y, trans = trans_identity(), ...) {
  vectorize_shapes(curve_line, c(
    list(x = x, y = y, trans = trans),
    list(...)
  ))
}
