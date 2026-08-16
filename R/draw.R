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
#' @examples
#' draw(shape_circle(radius = 1))
#'
#' s <- sketch() + shape_circle(radius = 1) + shape_blob(x = 2, radius = 0.5)
#' draw(s)
#'
#' # an explicit xlim/ylim overrides both the sketch's own canvas and the
#' # range of its shapes' own points, useful for zooming in/out or padding
#' draw(shape_circle(radius = 1), xlim = c(-2, 2), ylim = c(-2, 2))
#'
#' # a non-drawable object is ignored, with a warning, rather than erroring
#' draw("not a drawable")
#'
#' @family core structure
#' @export
draw <- S7::new_generic("draw", dispatch_args = "object")

#' Bake a style alpha into a plain colour string
#'
#' Internal helper shared by every branch of `geometry_grob()`. Applies
#' `alpha` to `color` via [grDevices::adjustcolor()], rather than via
#' [grid::gpar()]'s own `alpha` argument -- `gpar()`'s `alpha` would apply
#' uniformly to both `col` and `fill` on the same grob, coupling
#' `style@color_alpha` and `style@fill_alpha` together, which is exactly
#' what baking each into its own colour string avoids. A no-op (returns
#' `color` unchanged) when `alpha == 1`, so the common case skips
#' `adjustcolor()` entirely. `adjustcolor()` multiplies through any alpha
#' channel already present in `color` (e.g. an `"#RRGGBBAA"` hex string)
#' rather than overriding it, and returns a fully-transparent colour for
#' `NA` input without erroring.
#'
#' @param color A single colour string (may be `NA`).
#' @param alpha A single number in `[0, 1]`.
#' @return A single colour string.
#' @noRd
apply_alpha <- function(color, alpha) {
  if (alpha == 1) {
    return(color)
  }
  grDevices::adjustcolor(color, alpha.f = alpha)
}

#' Build the grob for a drawable's geometry
#'
#' Internal helper shared by both `draw()` methods below: dispatches on a
#' drawable's `geometry` property to build the [grid] grob appropriate to
#' each of the three dimensional cases documented on [drawable]. `fill`
#' (and thus `fill_alpha`) is only meaningful for `"polygon"`, so both are
#' omitted from `gpar()` for the other two geometries.
#' `linetype`/`linejoin`/`lineend`/`linemitre` are forwarded for both
#' stroked geometries (`"polygon"`, `"path"`) but not `"points"`, which
#' has no line to dash, join, cap, or mitre -- `lineend`/`linemitre` are
#' simply inert for `"polygon"`, which has no free endpoint and only a
#' mitred (rather than bevelled) join to truncate. `color_alpha` is
#' forwarded for every geometry, via `apply_alpha()`; `fill_alpha` is
#' forwarded the same way but only when `fill` is a plain colour string --
#' it's silently inert when `fill` is a `GridPattern`, since
#' `apply_alpha()`/`adjustcolor()` has no defined effect on one (see
#' [style()]'s `fill_alpha` docs).
#'
#' `"polygon"` is built via [grid::pathGrob()] rather than
#' [grid::polygonGrob()], passing `points@id` as `pathGrob()`'s own `id`
#' (grouping `points` into sub-paths) and `sty@rule` as its `rule`. With a
#' single sub-path (`points@id` all one value, true of every current
#' `shape_*()` constructor), `pathGrob()` reproduces `polygonGrob()`'s
#' rendering exactly -- this is a rendering-mechanism change only, not a
#' visible behavior change for any existing drawable. `pathId` is left at
#' its default (`NULL`), so every sub-path of one drawable is always
#' combined into a single rendered path/fill region -- a drawable that
#' wants several independently-styled shapes already uses a [sketch]
#' instead. `"path"` similarly passes `points@id` to
#' [grid::polylineGrob()]'s own `id`, letting a `"path"`-geometry drawable
#' render as several disjoint strokes sharing one style; `"points"` has no
#' sub-path concept (no `id` support in [grid::pointsGrob()]), consistent
#' with `fill` already being inert for both non-`"polygon"` geometries.
#'
#' @param points A [xy].
#' @param sty A [style].
#' @param geometry One of `"polygon"`, `"path"`, or `"points"`.
#' @param vp A [grid::viewport()].
#' @noRd
geometry_grob <- function(points, sty, geometry, vp) {
  fill <- if (is.character(sty@fill)) {
    apply_alpha(sty@fill, sty@fill_alpha)
  } else {
    sty@fill
  }
  switch(geometry,
    polygon = grid::pathGrob(
      x = points@x,
      y = points@y,
      id = points@id,
      rule = sty@rule,
      gp = grid::gpar(
        col       = apply_alpha(sty@color, sty@color_alpha),
        fill      = fill,
        lwd       = sty@linewidth,
        lty       = sty@linetype,
        linejoin  = sty@linejoin,
        lineend   = sty@lineend,
        linemitre = sty@linemitre
      ),
      vp = vp,
      default.units = "native"
    ),
    path = grid::polylineGrob(
      x = points@x,
      y = points@y,
      id = points@id,
      gp = grid::gpar(
        col       = apply_alpha(sty@color, sty@color_alpha),
        lwd       = sty@linewidth,
        lty       = sty@linetype,
        linejoin  = sty@linejoin,
        lineend   = sty@lineend,
        linemitre = sty@linemitre
      ),
      vp = vp,
      default.units = "native"
    ),
    points = grid::pointsGrob(
      x = points@x,
      y = points@y,
      gp = grid::gpar(col = apply_alpha(sty@color, sty@color_alpha)),
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
  if (is.null(ylim)) ylim <- range(object@points@y)
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
  # a sketch's own @shapes can mix plain drawables with groups (each
  # possibly nesting further groups); flatten_shapes() (R/group.R)
  # resolves every group's own trans/style cascade and returns a plain
  # list of drawables, so the rest of this method never needs to know
  # about group at all
  shapes <- flatten_shapes(object@shapes)

  # axis limits: an explicit draw() argument wins, then the sketch's own
  # canvas, then the shapes' own point ranges (canvas's xlim/ylim default to
  # NULL, so this falls through to the pre-canvas() default behavior)
  if (is.null(xlim)) xlim <- object@canvas@xlim
  if (is.null(ylim)) ylim <- object@canvas@ylim
  if (is.null(xlim)) {
    xlim <- c(
      min(purrr::map_dbl(shapes, \(s) min(s@points@x))),
      max(purrr::map_dbl(shapes, \(s) max(s@points@x)))
    )
  }
  if (is.null(ylim)) {
    ylim <- c(
      min(purrr::map_dbl(shapes, \(s) min(s@points@y))),
      max(purrr::map_dbl(shapes, \(s) max(s@points@y)))
    )
  }

  # plotting area is a single viewport with equal-axis scaling; clip only
  # takes effect when canvas@clip is TRUE (see canvas()'s docs)
  x_width <- xlim[2] - xlim[1]
  y_width <- ylim[2] - ylim[1]
  vp <- grid::viewport(
    xscale = xlim,
    yscale = ylim,
    width  = grid::unit(min(1, x_width / y_width), "snpc"),
    height = grid::unit(min(1, y_width / x_width), "snpc"),
    clip   = if (object@canvas@clip) "on" else "off"
  )

  # draw the page, canvas background, then every shape's grob on top
  grid::grid.newpage()
  bg <- object@canvas@background
  if (!(is.character(bg) && length(bg) == 1 && is.na(bg))) {
    grid::grid.draw(grid::rectGrob(gp = grid::gpar(fill = bg, col = NA), vp = vp))
  }
  for (s in shapes) {
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
