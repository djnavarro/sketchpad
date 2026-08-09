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

  # shapes are always polygon grobs
  grob <- grid::polygonGrob(
    x = object@points@x,
    y = object@points@y,
    gp = grid::gpar(
      col = object@style@color,
      fill = object@style@fill,
      lwd = object@style@linewidth
    ),
    vp = vp,
    default.units = "native"
  )

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
    grob <- grid::polygonGrob(
      x = s@points@x,
      y = s@points@y,
      gp = grid::gpar(
        col = s@style@color,
        fill = s@style@fill,
        lwd = s@style@linewidth
      ),
      vp = vp,
      default.units = "native"
    )
    grid::grid.draw(grob)
  }
}

#' @export
#' @noRd
S7::method(draw, S7::class_any) <- function(object, ...) {
  rlang::warn("Non-drawable objects ignored by draw()")
  return(invisible(NULL))
}
