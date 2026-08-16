#' A polygon defined directly by its vertices
#'
#' `shape_raw` is the simplest [drawable]: the user supplies `x` and `y`
#' coordinates directly, and `points` is computed trivially from them.
#' It is most often produced by [convert()]ing a more complex drawable
#' (e.g. a [shape_blob] or [shape_twist]) down to its raw vertices.
#'
#' @param x,y Numeric vectors of x/y coordinates.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_raw(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1)))
#'
#' # any polygon can be "frozen" to a shape_raw by converting it
#' frozen <- S7::convert(shape_blob(radius = 1, distortion = noise_field(seed = 5150L)), shape_raw)
#' draw(frozen)
#'
#' draw(shape_raw(
#'   x = c(0, 1, 0.5), y = c(0, 0, 1),
#'   fill = "goldenrod", color = "black", linewidth = 2
#' ))
#'
#' @family 2D shapes
#' @export
shape_raw <- S7::new_class(
  name = "shape_raw",
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
      drawable(trans = trans, pathlike = TRUE),
      x = x,
      y = y,
      style = style(...)
    )
  }
)

#' Multiple raw polygons at once
#'
#' `shape_raws()` is a vectorized version of [shape_raw()]. Since `x`/`y`
#' are themselves numeric vectors of vertex coordinates for a single
#' polygon, `shape_raws()` takes them as a `list()` of numeric vectors
#' instead -- one vector of vertices per shape.
#'
#' Every other argument may be a plain vector, recycled against `x`/`y`
#' via `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). The result is a [sketch] containing one
#' `shape_raw()` per list element/recycled row, rather than a single
#' drawable.
#'
#' @rdname shape_raw
#' @param x,y For `shape_raw()`, a numeric vector of x/y coordinates. For
#'   `shape_raws()`, a `list()` of such vectors instead -- one vector of
#'   vertices per shape.
#' @return For `shape_raws()`, a [sketch].
#'
#' @examples
#' draw(shape_raws(
#'   x = list(c(0, 1, 1, 0), c(2, 3, 3, 2)),
#'   y = list(c(0, 0, 1, 1), c(0, 0, 1, 1))
#' ))
#'
#' @family 2D shapes
#' @export
shape_raws <- function(x, y, trans = trans_identity(), ...) {
  vectorize_shapes(shape_raw, c(
    list(x = x, y = y, trans = trans),
    list(...)
  ))
}

