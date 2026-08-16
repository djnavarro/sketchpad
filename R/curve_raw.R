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
#' @param x,y Numeric vectors of x/y coordinates.
#' @param trans A [trans] object applied to the curve's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(curve_raw(x = c(0, 1, 2), y = c(0, 1, 0)))
#'
#' # useful for "freezing" a wandering path's own computed points
#' frozen <- S7::convert(
#'   curve_twist(
#'     x = 0, y = 0, xend = 1, yend = 0,
#'     path_distortion = noise_bridge(seed = 99)
#'   ),
#'   curve_raw
#' )
#' draw(frozen)
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
      class = xy,
      getter = function(self) {
        apply_trans(self@trans, xy(x = self@x, y = self@y))
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      "x and y must be the same length"
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

#' Multiple raw paths at once
#'
#' `curve_raws()` is a vectorized version of [curve_raw()]. Since `x`/`y`
#' are themselves numeric vectors of vertex coordinates for a single
#' path, `curve_raws()` takes them as a `list()` of numeric vectors
#' instead -- one vector of vertices per path.
#'
#' Every other argument may be a plain vector, recycled against `x`/`y`
#' via `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). The result is a [sketch] containing one
#' `curve_raw()` per list element/recycled row, rather than a single
#' drawable.
#'
#' @rdname curve_raw
#' @param x,y For `curve_raw()`, a numeric vector of x/y coordinates. For
#'   `curve_raws()`, a `list()` of such vectors instead -- one vector of
#'   vertices per path.
#' @return For `curve_raws()`, a [sketch].
#'
#' @examples
#' draw(curve_raws(
#'   x = list(c(0, 1, 2), c(2, 3, 4)),
#'   y = list(c(0, 1, 0), c(0, 1, 0))
#' ))
#'
#' @family 1D curves
#' @export
curve_raws <- function(x, y, trans = trans_identity(), ...) {
  vectorize_shapes(curve_raw, c(
    list(x = x, y = y, trans = trans),
    list(...)
  ))
}
