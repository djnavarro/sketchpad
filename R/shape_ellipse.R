#' An ellipse
#'
#' `shape_ellipse` is a [drawable] defined by a centroid and independent x/y
#' radii; its vertices are computed as evenly spaced points around the
#' circumference, generalizing [shape_circle()] (which is a `shape_ellipse`
#' with equal radii in both directions).
#'
#' @param x,y Centroid coordinates. Default `0`.
#' @param x_radius,y_radius Radii along the x and y axes. Must be
#'   non-negative. Default `1`.
#' @param n Number of points used to approximate the ellipse. Default `100L`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_ellipse(x_radius = 2, y_radius = 1))
#' draw(shape_ellipse(x = 1, y = 1, x_radius = 0.5, y_radius = 1, n = 6L, color = "darkred"))
#' draw(shape_ellipse(x_radius = 2, y_radius = 1, fill = fill_gradient(angle = 90)))
#'
#' # rotating an ellipse (rather than swapping its radii) tilts its axes
#' draw(shape_ellipse(x_radius = 2, y_radius = 0.7, trans = trans_rotate(pi / 6)))
#'
#' @family 2D shapes
#' @export
shape_ellipse <- S7::new_class(
  name = "shape_ellipse",
  parent = drawable,
  properties = list(
    x        = S7::class_numeric,
    y        = S7::class_numeric,
    x_radius = S7::class_numeric,
    y_radius = S7::class_numeric,
    n        = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        angle <- seq(0, 2 * pi, length.out = self@n)
        apply_trans(self@trans, xy(
          x = self@x + self@x_radius * cos(angle),
          y = self@y + self@y_radius * sin(angle)
        ))
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@x_radius) != 1) return("x_radius must be length 1")
    if (length(self@y_radius) != 1) return("y_radius must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (self@x_radius < 0) return("x_radius must be a non-negative number")
    if (self@y_radius < 0) return("y_radius must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
  },
  constructor = function(x = 0, y = 0, x_radius = 1, y_radius = 1, n = 100L,
                         trans = trans_identity(), ...) {
    S7::new_object(
      drawable(trans = trans),
      x = x,
      y = y,
      x_radius = x_radius,
      y_radius = y_radius,
      n = n,
      style = style(...)
    )
  }
)

#' Multiple ellipses at once
#'
#' `shape_ellipses()` is a vectorized version of [shape_ellipse()]: each
#' argument may be a vector, recycled against the others via
#' `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). The result is a [sketch] containing one
#' `shape_ellipse()` per recycled row, rather than a single drawable.
#'
#' @rdname shape_ellipse
#' @return For `shape_ellipses()`, a [sketch].
#'
#' @examples
#' draw(shape_ellipses(x = 1:3, x_radius = c(0.5, 1, 1.5), y_radius = 0.5))
#' draw(shape_ellipses(
#'   x = 0, y = 0, x_radius = 1, y_radius = 0.3,
#'   trans = purrr::map(seq(0, pi, length.out = 6), trans_rotate)
#' ))
#'
#' @family 2D shapes
#' @export
shape_ellipses <- function(x = 0, y = 0, x_radius = 1, y_radius = 1, n = 100L,
                            trans = trans_identity(), ...) {
  vectorize_shapes(shape_ellipse, c(
    list(x = x, y = y, x_radius = x_radius, y_radius = y_radius, n = n, trans = trans),
    list(...)
  ))
}
