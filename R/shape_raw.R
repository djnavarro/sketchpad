#' A polygon defined directly by its vertices
#'
#' `shape_raw` is the simplest [drawable]: the user supplies `x` and `y`
#' coordinates directly, and `points` is computed trivially from them.
#' It is most often produced by [convert()]ing a more complex drawable
#' (e.g. a [shape_blob] or [shape_twist]) down to its raw vertices.
#'
#' `id` optionally groups `x`/`y` into multiple sub-paths (see [xy]'s own
#' `id`) -- several disjoint polygons sharing one [style], or, combined
#' with [style()]'s `rule`, a shape with a hole. [shape_combine()] is a
#' more convenient way to build this from several already-built
#' drawables' own points, rather than computing `id` by hand.
#'
#' @param x,y Numeric vectors of x/y coordinates.
#' @param id Integer (or integerish numeric) vector the same length as
#'   `x`/`y`, grouping locations into sub-paths -- see [xy]'s own `id`.
#'   Default `NULL` (a single sub-path).
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_raw(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1)))
#'
#' # any polygon can be "frozen" to a shape_raw by converting it
#' frozen <- S7::convert(
#'   shape_blob(radius = 1, distortion = noise_field(seed = 5150)),
#'   shape_raw
#' )
#' draw(frozen)
#'
#' draw(shape_raw(
#'   x = c(0, 1, 0.5), y = c(0, 0, 1),
#'   fill = "goldenrod", color = "black", linewidth = 2
#' ))
#'
#' # id groups x/y into sub-paths -- here, a ring with a hole (a smaller
#' # sub-path nested inside a larger one, under style()'s default
#' # rule = "evenodd")
#' draw(shape_raw(
#'   x = c(0, 0, 4, 4, 1, 1, 3, 3),
#'   y = c(0, 4, 4, 0, 1, 3, 3, 1),
#'   id = c(1, 1, 1, 1, 2, 2, 2, 2),
#'   fill = "steelblue"
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
    id = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        apply_trans(self@trans, xy(x = self@x, y = self@y, id = self@id))
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      return("x and y must be the same length")
    }
    if (length(self@id) != length(self@x)) {
      return("id must be the same length as x and y")
    }
  },
  constructor = function(x, y, id = NULL, trans = trans_identity(), ...) {
    id <- if (is.null(id)) rep(1L, length(x)) else as_integerish(id, "id")
    S7::new_object(
      drawable(trans = trans, pathlike = TRUE),
      x = x,
      y = y,
      id = id,
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
#' @param id For `shape_raw()`, an integer vector the same length as
#'   `x`/`y`, or `NULL` (the default, a single sub-path). For
#'   `shape_raws()`, a `list()` of such vectors (or `NULL`s) instead, one
#'   per shape.
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
shape_raws <- function(x, y, id = NULL, trans = trans_identity(), ...) {
  args <- list(x = x, y = y, trans = trans)
  if (!is.null(id)) {
    args$id <- id
  }
  vectorize_shapes(shape_raw, c(args, list(...)))
}
