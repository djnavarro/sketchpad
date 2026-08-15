#' An open, wandering path following a random walk
#'
#' `curve_twist` is [shape_twist()]'s path alone, with no ribbon width:
#' an open [curve_line()]-like polyline between `(x, y)` and
#' `(xend, yend)`, displaced away from a straight line by a
#' [noise_bridge], giving a wandering, twisted appearance. Where
#' `shape_twist()` also modulates a filled ribbon's width along this same
#' kind of path (via a separate `distortion` [noise_field]), `curve_twist()`
#' has no width or fill at all -- just the displaced backbone itself,
#' rendered as an open `grid::polylineGrob()` (`geometry = "path"`).
#' Shares its path computation with `shape_twist()` via the internal
#' `twisted_path_points()` helper (`R/shape_twist.R`) rather than
#' duplicating it.
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
#' @param ... Arguments passed to [style()].
#'
#' @examples
#' draw(curve_twist(
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
    x               = S7::class_numeric,
    y               = S7::class_numeric,
    xend            = S7::class_numeric,
    yend            = S7::class_numeric,
    scale           = S7::class_numeric,
    n               = S7::class_integer,
    path_distortion = noise_bridge,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        twisted_path_points(
          x = self@x, y = self@y, xend = self@xend, yend = self@yend,
          n = self@n, width = self@scale, path_distortion = self@path_distortion
        )
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
                         ...) {
    S7::new_object(
      drawable(geometry = "path"),
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
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@xend) != 1) return("xend must be length 1")
    if (length(self@yend) != 1) return("yend must be length 1")
    if (length(self@scale) != 1) return("scale must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (self@scale < 0) return("scale must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
  }
)
