#' A paper-grain/textured-ink rendering of a drawable's own outline
#'
#' `effect_grain` takes an existing polygon-geometry [drawable] (`object`,
#' e.g. [shape_stroke()], [shape_blob()], [shape_ribbon()]) and renders
#' its own outline (`object@points`) not with a [style()]`@fill` via the
#' ordinary `draw()`/`geometry_grob()` path, but by compositing a
#' rasterised paper-grain texture and masking it to the outline's exact
#' polygon shape via [grid::as.mask()].
#'
#' This is the same masking technique [fill_vignette()] already uses for
#' its own radial fade, but applied to `object`'s own real (possibly
#' concave, tapering-to-a-point) silhouette rather than a synthetic
#' circle drawn purely to build the mask.
#'
#' This is a different effect than filling `object` with
#' [fill_charcoal()]/[fill_noise()] (already a good option for a shape's
#' interior -- see [fill_charcoal()]'s docs): those tile a periodic
#' texture that repeats across the shape via [grid::pattern()], sized
#' relative to the target's own bounding box. `effect_grain()` instead
#' samples its grain [noise_field] once, directly, across `object`'s own
#' world coordinates -- a single non-repeating raster the size of the
#' whole shape, with no tiling seam to manage, at the cost of needing its
#' own `draw()` method rather than reusing `geometry_grob()`'s existing
#' `"polygon"`/`"path"`/`"points"` branches (`effect_grain` is not a
#' [drawable] subclass at all, since its rendering isn't expressible as a
#' single `points`-based grob).
#'
#' Grain is rendered as varying opacity of `color`, from fully transparent
#' at the noise field's minimum to `alpha` at its maximum -- exactly
#' [fill_noise()]'s own opacity convention -- optionally revealing a solid
#' `background` colour underneath (as [fill_vignette()]'s own `background`
#' argument does) rather than true transparency, which reads as a solid,
#' mottled ink stroke instead of a sparse one.
#'
#' @param object A polygon-geometry [drawable] (`@geometry == "polygon"`)
#'   whose outline is textured -- e.g. [shape_stroke()], [shape_blob()],
#'   [shape_ribbon()]. `object@points` is used directly; `object@style`
#'   plays no role (`effect_grain()` draws its own grain raster instead).
#' @param grain A [noise_field] controlling the paper-grain texture,
#'   sampled directly at each raster pixel's own world position (not
#'   torus-periodic, unlike [fill_noise()]'s tiled field -- see Details).
#'   Default `noise_field(frequency = 15, octaves = 2L, seed = 2L)`
#'   (finer/denser than `noise_field()`'s own default, for a paper-grain
#'   rather than cloudy look).
#' @param resolution Raster resolution (pixels per edge of `object`'s own
#'   bounding box). Must be a positive integer of at least `2L`. Default
#'   `150L`.
#' @param color Grain colour. Default `"gray15"`.
#' @param alpha Maximum grain opacity, at the noise field's peak. Must be
#'   a number in `(0, 1]`. Default `1`.
#' @param background Colour revealed as grain fades out, or `NA` for true
#'   transparency (showing whatever is drawn behind). Default `NA`.
#'
#' @return An `effect_grain` object.
#'
#' @examples
#' t <- seq(0, 8, length.out = 150)
#' template <- shape_stroke(x = t, y = sin(t), width = 0.4)
#'
#' # before: a plain filled stroke
#' draw(template)
#'
#' # after: the same outline rendered as textured grain instead of a
#' # solid style() fill
#' draw(effect_grain(template, color = "gray10", alpha = 0.9))
#'
#' # a non-NA background reveals a solid colour underneath the grain,
#' # instead of true transparency
#' draw(effect_grain(template, color = "gray5", alpha = 0.85, background = "gray30"))
#'
#' # a coarser grain field (lower frequency) reads less like paper texture
#' # and more like a mottled brushstroke
#' draw(effect_grain(template, grain = noise_field(frequency = 3, seed = 2L)))
#'
#' @family effects
#' @export
effect_grain <- S7::new_class(
  name = "effect_grain",
  properties = list(
    object     = drawable,
    grain      = noise_field,
    resolution = S7::class_integer,
    color      = S7::class_character,
    alpha      = S7::class_numeric,
    background = S7::class_character,
    outline = S7::new_property(
      class = xy,
      getter = function(self) self@object@points
    )
  ),
  validator = function(self) {
    if (self@object@geometry != "polygon") {
      return('object must have geometry "polygon" (a closed shape) to build a masked outline')
    }
    if (length(self@resolution) != 1 || self@resolution < 2L) {
      return("resolution must be an integer of at least 2")
    }
    if (length(self@color) != 1) return("color must be a single string")
    if (length(self@alpha) != 1 || self@alpha <= 0 || self@alpha > 1) {
      return("alpha must be a single number in (0, 1]")
    }
    if (length(self@background) != 1) return("background must be a single string, or NA")
  },
  constructor = function(object,
                         grain = noise_field(frequency = 15, octaves = 2L, seed = 2L),
                         resolution = 150L,
                         color = "gray15",
                         alpha = 1,
                         background = NA_character_) {
    S7::new_object(
      S7::S7_object(),
      object = object,
      grain = grain,
      resolution = as.integer(resolution),
      color = color,
      alpha = alpha,
      background = background
    )
  }
)

#' Build an `effect_grain`'s masked raster grob
#'
#' Internal helper for `draw(effect_grain)`. Samples `object@grain`
#' directly at every raster pixel's own world `(x, y)` position across the
#' outline's bounding box (a single non-tiled sample -- see
#' [effect_grain()] details for why this differs from the `fill_*()`
#' family's torus-periodic tiling), then masks the resulting raster to
#' `outline`'s exact polygon shape via [grid::as.mask()], mirroring
#' [fill_vignette()]'s own mask-building technique.
#'
#' @param object An [effect_grain] object.
#' @param outline `object@outline`, precomputed by the caller.
#' @param vp The shared [grid::viewport()] `draw()` built for this object.
#' @return A [grid::gTree()].
#' @noRd
effect_grain_grob <- function(object, outline, vp) {
  xlim <- range(outline@x)
  ylim <- range(outline@y)
  x_width <- xlim[2] - xlim[1]
  y_width <- ylim[2] - ylim[1]

  res <- object@resolution
  px <- seq(xlim[1], xlim[2], length.out = res)
  py <- seq(ylim[1], ylim[2], length.out = res)
  grid_xy <- expand.grid(y = py, x = px)
  grain <- noise_sample(object@grain, x = grid_xy$x, y = grid_xy$y, to = c(0, object@alpha))

  rgb <- grDevices::col2rgb(object@color) / 255
  pixels <- matrix(
    grDevices::rgb(rgb["red", ], rgb["green", ], rgb["blue", ], alpha = grain),
    nrow = res, ncol = res
  )
  raster_grob <- grid::rasterGrob(
    pixels,
    x = mean(xlim), y = mean(ylim),
    width = x_width, height = y_width,
    default.units = "native", interpolate = TRUE
  )

  mask_grob <- grid::polygonGrob(
    x = outline@x, y = outline@y,
    default.units = "native",
    gp = grid::gpar(fill = "black", col = NA)
  )
  # a viewport identical to `vp` (same scale/aspect), plus the outline's
  # own mask -- content pushed into it is clipped to the exact stroke
  # silhouette rather than a rectangular/circular tile
  masked_vp <- grid::viewport(
    xscale = vp$xscale, yscale = vp$yscale,
    width  = vp$width, height = vp$height,
    mask   = grid::as.mask(mask_grob, type = "alpha")
  )

  content <- list(raster_grob)
  if (!is.na(object@background)) {
    bg_grob <- grid::rectGrob(
      x = mean(xlim), y = mean(ylim), width = x_width, height = y_width,
      default.units = "native",
      gp = grid::gpar(fill = object@background, col = NA)
    )
    content <- c(list(bg_grob), content)
  }

  grid::gTree(children = do.call(grid::gList, content), vp = masked_vp)
}

#' @export
#' @noRd
S7::method(draw, effect_grain) <- function(object, xlim = NULL, ylim = NULL, ...) {
  outline <- object@outline

  if (is.null(xlim)) xlim <- range(outline@x)
  if (is.null(ylim)) ylim <- range(outline@y)
  x_width <- xlim[2] - xlim[1]
  y_width <- ylim[2] - ylim[1]
  vp <- grid::viewport(
    xscale = xlim,
    yscale = ylim,
    width  = grid::unit(min(1, x_width / y_width), "snpc"),
    height = grid::unit(min(1, y_width / x_width), "snpc")
  )

  grid::grid.newpage()
  grid::grid.draw(effect_grain_grob(object, outline, vp))
}
