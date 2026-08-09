#' Draw a drawable or sketch
#'
#' `draw()` is a generic function that renders a [drawable] or [sketch]
#' object to the current graphics device using \pkg{grid}. Methods accept
#' optional `xlim`/`ylim` arguments giving axis limits; if omitted, limits
#' are computed from the object's points.
#'
#' @param object A [drawable] or [sketch] object.
#' @param ... Passed to methods, e.g. `xlim`/`ylim`.
#'
#' @export
draw <- S7::new_generic("draw", dispatch_args = "object")

#' Build the grob for a drawable's geometry
#'
#' Internal helper shared by both `draw()` methods below: dispatches on a
#' drawable's `geometry` property to build the [grid] grob appropriate to
#' each of the three dimensional cases documented on [drawable]. `fill` is
#' only meaningful for `"polygon"`, so it's omitted from `gpar()` for the
#' other two geometries. `linetype`/`linejoin` are meaningful for both
#' stroked geometries (`"polygon"`, `"path"`) but not `"points"`, which has
#' no line to dash or join.
#'
#' @param points A [point_set].
#' @param sty A [style].
#' @param geometry One of `"polygon"`, `"path"`, or `"points"`.
#' @param vp A [grid::viewport()].
#' @noRd
geometry_grob <- function(points, sty, geometry, vp) {
  switch(
    geometry,
    polygon = grid::polygonGrob(
      x = points@x,
      y = points@y,
      gp = grid::gpar(
        col      = sty@color,
        fill     = sty@fill,
        lwd      = sty@linewidth,
        lty      = sty@linetype,
        linejoin = sty@linejoin
      ),
      vp = vp,
      default.units = "native"
    ),
    path = grid::polylineGrob(
      x = points@x,
      y = points@y,
      gp = grid::gpar(
        col      = sty@color,
        lwd      = sty@linewidth,
        lty      = sty@linetype,
        linejoin = sty@linejoin
      ),
      vp = vp,
      default.units = "native"
    ),
    points = grid::pointsGrob(
      x = points@x,
      y = points@y,
      gp = grid::gpar(col = sty@color),
      vp = vp,
      default.units = "native"
    ),
    rlang::abort('geometry must be one of "polygon", "path", or "points"')
  )
}

#' @export
#' @noRd
S7::method(draw, drawable) <- function(object, xlim = NULL, ylim = NULL, ...) {

  # plotting area is a single viewport with equal-axis scaling
  if (is.null(xlim)) xlim <- range(object@points@x)
  if (is.null(ylim)) ylim <- range(object@points@x)
  x_width <- xlim[2] - xlim[1]
  y_width <- ylim[2] - ylim[1]
  vp <- grid::viewport(
    xscale = xlim,
    yscale = ylim,
    width  = grid::unit(min(1, x_width / y_width), "snpc"),
    height = grid::unit(min(1, y_width / x_width), "snpc"),
  )

  # grob type depends on the drawable's geometry
  grob <- geometry_grob(object@points, object@style, object@geometry, vp)

  # draw the grob
  grid::grid.newpage()
  grid::grid.draw(grob)
}

#' @export
#' @noRd
S7::method(draw, sketch) <- function(object, xlim = NULL, ylim = NULL, ...) {

  # set default axis limits
  if (is.null(xlim)) {
    xlim <- c(
      min(purrr::map_dbl(object@shapes, \(s) min(s@points@x))),
      max(purrr::map_dbl(object@shapes, \(s) max(s@points@x)))
    )
  }
  if (is.null(ylim)) {
    ylim <- c(
      min(purrr::map_dbl(object@shapes, \(s) min(s@points@y))),
      max(purrr::map_dbl(object@shapes, \(s) max(s@points@y)))
    )
  }

  # plotting area is a single viewport with equal-axis scaling
  x_width <- xlim[2] - xlim[1]
  y_width <- ylim[2] - ylim[1]
  vp <- grid::viewport(
    xscale = xlim,
    yscale = ylim,
    width  = grid::unit(min(1, x_width / y_width), "snpc"),
    height = grid::unit(min(1, y_width / x_width), "snpc")
  )

  # draw the grobs
  grid::grid.newpage()
  for (s in object@shapes) {
    grob <- geometry_grob(s@points, s@style, s@geometry, vp)
    grid::grid.draw(grob)
  }
}

#' @export
#' @noRd
S7::method(draw, S7::class_any) <- function(object, ...) {
  rlang::warn("Non-drawable objects ignored by draw()")
  return(invisible(NULL))
}
