#' An open, wandering path following a random walk
#'
#' `curve_twist` is [shape_twist()]'s path alone, with no ribbon width:
#' an open [curve_line()]-like polyline between `(x, y)` and
#' `(xend, yend)`, displaced away from a straight line by a
#' [noise_bridge], giving a wandering, twisted appearance.
#'
#' Where `shape_twist()` also modulates a filled ribbon's width along this
#' same kind of path (via a separate `distortion` [noise_field]),
#' `curve_twist()` has no width or fill at all -- just the displaced
#' backbone itself, rendered as an open `grid::polylineGrob()`
#' (`geometry = "path"`). Shares its path computation with `shape_twist()`
#' via the internal `twisted_path_points()` helper (`R/shape_twist.R`)
#' rather than duplicating it.
#'
#' `style@fill` has no effect for `curve_twist()` -- see [drawable]'s
#' `geometry` documentation for why `"path"` geometries have no interior
#' to fill. Passing `fill` via `...` is still accepted (it's simply
#' ignored at draw time), since `style()` is shared across every
#' `geometry`.
#'
#' @param x,y Start point. Default `0`.
#' @param xend,yend End point. Default `1`.
#' @param scale Amplitude of the Brownian-bridge displacement (internally
#'   scaled by `0.1`, matching [shape_twist()]'s own scaling of its
#'   path). Must be non-negative. Default `0.2`.
#' @param n Number of points used along the path. Default `100L`.
#' @param path_distortion A [noise_bridge] controlling the path's
#'   Brownian bridge. Default `noise_bridge()`.
#' @param trans A [trans] object applied to the curve's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(curve_twist(
#'   x = 0, y = 0, xend = 1, yend = 0,
#'   path_distortion = noise_bridge(seed = 7734L)
#' ))
#'
#' # a larger scale wanders further from the straight line between the
#' # endpoints
#' draw(curve_twist(
#'   x = 0, y = 0, xend = 1, yend = 0, scale = 0.6,
#'   path_distortion = noise_bridge(seed = 7734L)
#' ))
#'
#' # curve_twist() is shape_twist()'s backbone alone, with no ribbon width
#' draw(shape_twist(
#'   x = 0, y = 0, xend = 1, yend = 0,
#'   path_distortion = noise_bridge(seed = 7734L)
#' ))
#'
#' @family 1D curves
#' @export
curve_twist <- S7::new_class(
  name = "curve_twist",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    xend = S7::class_numeric,
    yend = S7::class_numeric,
    scale = S7::class_numeric,
    n = S7::class_integer,
    path_distortion = noise_bridge,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        apply_trans(self@trans, twisted_path_points(
          x = self@x, y = self@y, xend = self@xend, yend = self@yend,
          n = self@n, width = self@scale, path_distortion = self@path_distortion
        ))
      }
    )
  ),
  constructor = function(x = 0,
                         y = 0,
                         xend = 1,
                         yend = 1,
                         scale = 0.2,
                         n = 100L,
                         path_distortion = noise_bridge(),
                         trans = trans_identity(),
                         ...) {
    S7::new_object(
      drawable(geometry = "path", trans = trans),
      x = x,
      y = y,
      xend = xend,
      yend = yend,
      scale = scale,
      n = n,
      path_distortion = path_distortion,
      style = style(...)
    )
  },
  validator = function(self) {
    if (length(self@x) != 1) {
      return("x must be length 1")
    }
    if (length(self@y) != 1) {
      return("y must be length 1")
    }
    if (length(self@xend) != 1) {
      return("xend must be length 1")
    }
    if (length(self@yend) != 1) {
      return("yend must be length 1")
    }
    if (length(self@scale) != 1) {
      return("scale must be length 1")
    }
    if (length(self@n) != 1) {
      return("n must be length 1")
    }
    if (self@scale < 0) {
      return("scale must be a non-negative number")
    }
    if (self@n < 1L) {
      return("n must be a positive integer")
    }
  }
)

#' Multiple wandering twist paths at once
#'
#' `curve_twists()` is a vectorized version of [curve_twist()]: each
#' argument may be a vector, recycled against the others via
#' `purrr::pmap()`'s own vctrs-based rules. The result is
#' a [sketch] containing one `curve_twist()` per recycled row, rather
#' than a single drawable.
#'
#' Any length-1 element is broadcast to the common length; mismatched
#' lengths greater than 1 raise an error. A shared `path_distortion`
#' [noise_bridge] is automatically recycled across every path; pass a
#' `list()` of several different `noise_bridge`s instead to vary it per
#' path.
#'
#' @rdname curve_twist
#' @return For `curve_twists()`, a [sketch].
#'
#' @examples
#' draw(curve_twists(x = 1:3, y = 0, xend = 2:4, yend = 1))
#'
#' # a bundle of independently-wandering strands between the same endpoints
#' draw(curve_twists(
#'   x = 0, y = 0, xend = 3, yend = 0,
#'   path_distortion = list(
#'     noise_bridge(seed = 1L),
#'     noise_bridge(seed = 2L),
#'     noise_bridge(seed = 3L)
#'   )
#' ))
#'
#' @family 1D curves
#' @export
curve_twists <- function(x = 0,
                         y = 0,
                         xend = 1,
                         yend = 1,
                         scale = 0.2,
                         n = 100L,
                         path_distortion = noise_bridge(),
                         trans = trans_identity(),
                         ...) {
  vectorize_shapes(curve_twist, c(
    list(
      x = x, y = y, xend = xend, yend = yend, scale = scale, n = n,
      path_distortion = path_distortion, trans = trans
    ),
    list(...)
  ))
}
