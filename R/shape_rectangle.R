#' A rectangle
#'
#' `shape_rectangle` is a [drawable] defined by a centroid and a width/height,
#' rendered as an axis-aligned rectangle. `shape_square()` is a thin
#' convenience wrapper around `shape_rectangle()` for the common case of
#' `width == height`, taking a single `side` argument instead -- it returns a
#' `shape_rectangle` object directly rather than being its own class.
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param width,height Rectangle dimensions. Must be non-negative.
#'   Default `1`.
#' @param side Side length, for `shape_square()`. Must be non-negative.
#'   Default `1`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_rectangle(width = 2, height = 1))
#' draw(shape_square(x = 1, y = 1, side = 0.5, color = "darkred"))
#'
#' @family 2D shapes
#' @export
shape_rectangle <- S7::new_class(
  name = "shape_rectangle",
  parent = drawable,
  properties = list(
    x      = S7::class_numeric,
    y      = S7::class_numeric,
    width  = S7::class_numeric,
    height = S7::class_numeric,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        hw <- self@width / 2
        hh <- self@height / 2
        apply_trans(self@trans, xy(
          x = self@x + c(-hw, hw, hw, -hw),
          y = self@y + c(-hh, -hh, hh, hh)
        ))
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@width) != 1) return("width must be length 1")
    if (length(self@height) != 1) return("height must be length 1")
    if (self@width < 0) return("width must be a non-negative number")
    if (self@height < 0) return("height must be a non-negative number")
  },
  constructor = function(x = 0, y = 0, width = 1, height = 1, trans = trans_identity(), ...) {
    S7::new_object(
      drawable(trans = trans),
      x = x,
      y = y,
      width = width,
      height = height,
      style = style(...)
    )
  }
)

#' @rdname shape_rectangle
#' @family 2D shapes
#' @export
shape_square <- function(x = 0, y = 0, side = 1, trans = trans_identity(), ...) {
  shape_rectangle(x = x, y = y, width = side, height = side, trans = trans, ...)
}

#' Multiple rectangles/squares at once
#'
#' `shape_rectangles()`/`shape_squares()` are vectorized versions of
#' [shape_rectangle()]/[shape_square()]: each argument may be a vector,
#' recycled against the others via `purrr::pmap()`'s own vctrs-based
#' rules (any length-1 element is broadcast to the common length;
#' mismatched lengths greater than 1 raise an error). The result is a
#' [sketch] containing one `shape_rectangle()`/`shape_square()` per
#' recycled row, rather than a single drawable.
#'
#' @rdname shape_rectangle
#' @return For `shape_rectangles()`/`shape_squares()`, a [sketch].
#'
#' @examples
#' draw(shape_rectangles(x = 1:3, width = c(0.5, 1, 1.5), height = 0.5))
#' draw(shape_squares(x = 1:3, side = c(0.5, 1, 1.5)))
#'
#' @family 2D shapes
#' @export
shape_rectangles <- function(x = 0, y = 0, width = 1, height = 1, trans = trans_identity(), ...) {
  vectorize_shapes(shape_rectangle, c(
    list(x = x, y = y, width = width, height = height, trans = trans),
    list(...)
  ))
}

#' @rdname shape_rectangle
#' @family 2D shapes
#' @export
shape_squares <- function(x = 0, y = 0, side = 1, trans = trans_identity(), ...) {
  vectorize_shapes(shape_square, c(
    list(x = x, y = y, side = side, trans = trans),
    list(...)
  ))
}
