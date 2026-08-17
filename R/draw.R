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
#' `sty@fill` is a [fill] object; it's resolved against `aspect` (the
#' target's own bounding-box aspect ratio, from the internal `bbox_aspect()`/
#' `bbox_aspect_range()`) via the internal `resolve_fill()` helper before
#' being handed to [grid::gpar()] -- this is what lets every aspect-taking
#' `fill_*()` helper compute its own pattern automatically at draw time,
#' rather than requiring the caller to pass `aspect` by hand.
#'
#' @param points A [xy].
#' @param sty A [style].
#' @param geometry One of `"polygon"`, `"path"`, or `"points"`.
#' @param vp A [grid::viewport()].
#' @param aspect The target's own bounding-box aspect ratio (width /
#'   height), used to resolve `sty@fill` if it has a `resolve` function.
#' @noRd
geometry_grob <- function(points, sty, geometry, vp, aspect) {
  resolved <- resolve_fill(sty@fill, aspect)
  fill <- if (is.character(resolved)) {
    apply_alpha(resolved, sty@fill_alpha)
  } else {
    resolved
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

#' Build an equal-aspect-ratio viewport for a shared xlim/ylim
#'
#' Internal helper shared by `draw(drawable)`/`draw(sketch)` (below) and
#' `draw(group)` (`R/group.R`): builds the single [grid::viewport()]
#' (technically a [grid::vpStack()] of two, see below) each of them draws
#' its shape(s) into, sized so a 1:1 aspect ratio between `xlim`/`ylim`
#' is preserved -- as large as the current device allows, regardless of
#' the device's own aspect ratio. Referencing this from `R/group.R`,
#' which is collated later than this file, is safe since it's an
#' ordinary function looked up at call time, not source time (the same
#' reasoning `R/group.R`'s own docs already give for
#' `format_prop_value()`). Whatever this returns is only ever assigned
#' directly to a grob's own `vp` (in `geometry_grob()`, or as a
#' `grid::rectGrob()`'s `vp` for a sketch's own background) -- never
#' inspected via `vp$xscale`/similar -- so any object grid accepts as a
#' single `vp` value works here.
#'
#' Two earlier versions of this function were tried and rejected before
#' landing on this one:
#'
#' - Sizing `width`/`height` via `"snpc"` units (a fraction of
#'   `min(device_width, device_height)`, applied to both axes) is always
#'   *correct* -- `"snpc"` itself guarantees a 1:1 aspect ratio no matter
#'   the rendering device's own shape -- but caps the render at a square
#'   inscribed in the device even along the one axis that isn't the
#'   limiting dimension, leaving a large, avoidable white border whenever
#'   the device isn't itself square (confirmed directly: even a device
#'   sized to exactly match `xlim`/`ylim`'s own aspect ratio still
#'   rendered with a border under this version).
#' - Replacing `"snpc"` with plain `"npc"` units sized against the
#'   device's own *measured* aspect ratio (`device_aspect`, via
#'   [grid::convertWidth()]/[grid::convertHeight()] against `unit(1,
#'   "npc")`) fixed that border, but measures `device_aspect` once, at
#'   `draw()`-call time, and bakes the resulting numeric fraction
#'   directly into the returned viewport's `width`/`height` -- correct
#'   only as long as the object is later rasterized on that same device.
#'   `pkgdown`'s own reference pages build examples this way (evaluating
#'   the `@examples` code against one device, then materializing each
#'   recorded plot into a separately-sized thumbnail), and confirmed the
#'   failure directly: a regular pentagon, a plain circular arc, and a
#'   wedge all rendered visibly skewed (non-circular) once the baked-in
#'   `device_aspect` no longer matched the device the thumbnail was
#'   actually saved at.
#'
#' This version instead defers the whole aspect-vs-device-shape tradeoff
#' to [grid::grid.layout()]'s own `respect = TRUE` mechanism, which grid
#' itself resolves fresh at *every* render (not baked once as a plain
#' number by this function) -- so it survives a record/replay cycle onto
#' a differently-shaped device exactly the way `"snpc"` does, while still
#' filling the device fully whenever the data's own aspect ratio allows
#' it, matching what the rejected `"npc"` version achieved only for a
#' single, fixed device. A `1 x 1` `grid.layout()` with its one cell's
#' `widths`/`heights` set to `x_width`/`y_width` in `"null"` units and
#' `respect = TRUE` tells grid to size that cell as large as possible
#' inside its parent while preserving the `x_width:y_width` physical
#' ratio between them -- exactly the same layout algorithm behind base
#' graphics' own `asp` argument. A [grid::viewport()] with that layout is
#' pushed as the outer half of a [grid::vpStack()]; the inner half is an
#' ordinary [grid::viewport()] positioned at that layout's one cell
#' (`layout.pos.row = 1, layout.pos.col = 1`) and carrying the actual
#' `xscale`/`yscale`/`clip` content settings -- confirmed directly, via a
#' record-on-one-device/replay-on-another test mirroring `pkgdown`'s own
#' pipeline, that this combination renders undistorted (and replay-safe)
#' on both a device matching `xlim`/`ylim`'s own aspect ratio (filling it
#' completely, no border) and a mismatched one (letterboxed on whichever
#' axis is the constraint, with no skew).
#'
#' @param xlim,ylim Length-2 numeric axis limits.
#' @param clip `"on"` or `"off"`, forwarded to the inner
#'   [grid::viewport()]'s own `clip`. Default `"off"` -- only
#'   `draw(sketch)` has a `canvas@clip` setting of its own to forward
#'   here; `draw(drawable)`/`draw(group)` have no clip concept and always
#'   use the default.
#' @param ... Forwarded to the inner [grid::viewport()] -- e.g.
#'   `effect_grain_grob()` (`R/effect_grain.R`) passes its own `mask`
#'   through this way, rather than duplicating this whole function just
#'   to add one extra `viewport()` argument.
#' @return A [grid::vpStack()] of two [grid::viewport()]s.
#' @noRd
equal_aspect_viewport <- function(xlim, ylim, clip = "off", ...) {
  x_width <- xlim[2] - xlim[1]
  y_width <- ylim[2] - ylim[1]
  outer_vp <- grid::viewport(
    layout = grid::grid.layout(
      nrow = 1, ncol = 1,
      widths  = grid::unit(x_width, "null"),
      heights = grid::unit(y_width, "null"),
      respect = TRUE
    )
  )
  inner_vp <- grid::viewport(
    layout.pos.row = 1,
    layout.pos.col = 1,
    xscale = xlim,
    yscale = ylim,
    clip   = clip,
    ...
  )
  grid::vpStack(outer_vp, inner_vp)
}

#' Error out on an empty shapes list rather than silently drawing `Inf`
#'
#' Internal helper shared by `draw(sketch)` and `draw(group)` (`R/group.R`):
#' an empty `shapes` list has no points to infer a missing `xlim`/`ylim`
#' from, and letting `min()`/`max()` run on an empty numeric vector
#' silently produces an `Inf`/`-Inf` "range" with only a cryptic base R
#' warning (`"no non-missing arguments to min; returning Inf"`) rather
#' than a real error -- this raises a clear one instead. Only fires when
#' the missing limit would actually need to be inferred from `shapes`;
#' an explicit `xlim`/`ylim` argument (or, for a sketch, one already set
#' on its own `canvas`) makes an empty `shapes` list fine to draw, e.g.
#' an otherwise-empty canvas with just a background colour.
#'
#' @param shapes A list of (already-flattened) [drawable] objects.
#' @param xlim,ylim Axis limits already resolved from `draw()`'s own
#'   argument and, for a sketch, its `canvas` -- `NULL` if still unset.
#' @param context A short noun phrase naming the object being drawn (e.g.
#'   `"sketch"`/`"group"`), used in the error message.
#' @noRd
require_shapes_for_limits <- function(shapes, xlim, ylim, context) {
  if (length(shapes) == 0 && (is.null(xlim) || is.null(ylim))) {
    rlang::abort(paste0(
      "Can't draw an empty ", context, " (no shapes to infer xlim/ylim ",
      "from). Add at least one shape, or supply both `xlim` and `ylim` ",
      "explicitly."
    ))
  }
}

#' @export
#' @noRd
S7::method(draw, drawable) <- function(object, xlim = NULL, ylim = NULL, ...) {
  # plotting area is a single viewport with equal-axis scaling
  if (is.null(xlim)) xlim <- range(object@points@x)
  if (is.null(ylim)) ylim <- range(object@points@y)
  vp <- equal_aspect_viewport(xlim, ylim)

  # grob type depends on the drawable's geometry; sty@fill (a fill object)
  # is resolved against this drawable's own bounding-box aspect ratio
  grob <- geometry_grob(object@points, object@style, object@geometry, vp, bbox_aspect(object))

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
  require_shapes_for_limits(shapes, xlim, ylim, "sketch")
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
  vp <- equal_aspect_viewport(
    xlim, ylim,
    clip = if (object@canvas@clip) "on" else "off"
  )

  # draw the page, canvas background, then every shape's grob on top; the
  # background has no single target drawable, so its own aspect comes from
  # the shared viewport's xlim/ylim instead of bbox_aspect()
  grid::grid.newpage()
  bg <- resolve_fill(object@canvas@background, bbox_aspect_range(xlim, ylim))
  if (!(is.character(bg) && length(bg) == 1 && is.na(bg))) {
    grid::grid.draw(grid::rectGrob(gp = grid::gpar(fill = bg, col = NA), vp = vp))
  }
  for (s in shapes) {
    grob <- geometry_grob(s@points, s@style, s@geometry, vp, bbox_aspect(s))
    grid::grid.draw(grob)
  }
}

#' @export
#' @noRd
S7::method(draw, S7::class_any) <- function(object, ...) {
  rlang::warn("Non-drawable objects ignored by draw()")
  return(invisible(NULL))
}
