#' An open arc
#'
#' `curve_arc` is [shape_wedge()]'s arc alone, with no centroid vertex: an
#' open path of `n` points on the circle centred at `(x, y)` with the given
#' `radius`, sweeping from angle `start` to `end` (radians).
#'
#' Shares its point computation and argument validation with `shape_wedge()`
#' via two internal helpers factored into `R/shape_wedge.R` (`arc_points()`,
#' `validate_arc_args()`), differing only in which `drawable(geometry = ...)`
#' they construct from and the missing centroid vertex.
#'
#' `style@fill` has no effect for `curve_arc()` -- see [drawable]'s
#' `geometry` documentation for why `"path"` geometries have no interior to
#' fill. Passing `fill` via `...` is still accepted (it's simply ignored at
#' draw time), since `style()` is shared across every `geometry`.
#'
#' @inheritParams shape_wedge
#' @return A [drawable].
#'
#' @examples
#' draw(curve_arc(start = 0, end = 3 * pi / 2))
#'
#' # unlike shape_wedge(), there's no centroid vertex or fill -- just the
#' # arc itself
#' draw(curve_arc(start = pi / 4, end = pi, linewidth = 4, lineend = "round"))
#'
#' # a start greater than end sweeps clockwise instead of counterclockwise
#' draw(curve_arc(start = pi, end = 0))
#'
#' @family 1D curves
#' @export
curve_arc <- S7::new_class(
  name = "curve_arc",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    radius = S7::class_numeric,
    start = S7::class_numeric,
    end = S7::class_numeric,
    n = S7::class_integer,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        apply_trans(
          self@trans,
          arc_points(self@x, self@y, self@radius, self@start, self@end, self@n)
        )
      }
    )
  ),
  validator = function(self) {
    validate_arc_args(self@x, self@y, self@radius, self@start, self@end, self@n)
  },
  constructor = function(x = 0, y = 0, radius = 1, start = 0, end = pi / 2, n = 100L,
                         trans = trans_identity(), ...) {
    S7::new_object(
      drawable(geometry = "path", trans = trans),
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

#' Multiple open arcs at once
#'
#' `curve_arcs()` is a vectorized version of [curve_arc()]: each
#' argument may be a vector, recycled against the others. The result is a
#' [sketch] containing one `curve_arc()` per recycled row, rather than a
#' single drawable.
#'
#' Recycling uses `purrr::pmap()`'s own vctrs-based rules: any length-1
#' element is broadcast to the common length; mismatched lengths greater
#' than 1 raise an error.
#'
#' @rdname curve_arc
#' @return For `curve_arcs()`, a [sketch].
#'
#' @examples
#' draw(curve_arcs(start = 0, end = seq(pi / 2, 2 * pi, length.out = 3)))
#'
#' # concentric arcs of growing radius, all sweeping the same angle range
#' draw(curve_arcs(radius = seq(0.2, 1, length.out = 5), start = 0, end = pi))
#'
#' @family 1D curves
#' @export
curve_arcs <- function(x = 0, y = 0, radius = 1, start = 0, end = pi / 2, n = 100L,
                       trans = trans_identity(), ...) {
  vectorize_shapes(curve_arc, c(
    list(x = x, y = y, radius = radius, start = start, end = end, n = n, trans = trans),
    list(...)
  ))
}
