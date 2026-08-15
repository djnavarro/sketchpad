#' Build the tapered outline points for a `textured_stroke`
#'
#' Internal helper for [textured_stroke()]'s `outline` computed property.
#' Identical arithmetic to [shape_stroke()]'s own `points` getter (shares
#' its `resample_by_length()`/`stroke_normals()` helpers), factored out
#' here only because `textured_stroke` isn't a [drawable] subclass -- it
#' has no `points` property of its own to override.
#'
#' @param self A [textured_stroke] object.
#' @return An [xy] of the closed outline polygon.
#' @noRd
textured_stroke_outline <- function(self) {
  path <- resample_by_length(self@x, self@y, self@n)
  normal <- stroke_normals(path$x, path$y)
  s <- seq(0, 1, length.out = self@n)
  taper <- sqrt(pmin(s, 1 - s) * 2)
  pressure <- noise_sample(self@distortion, x = path$x, y = path$y, to = c(0, 1))
  half_width <- (pressure * taper * self@width) / 2
  xy(
    x = c(path$x + normal$x * half_width, rev(path$x - normal$x * half_width)),
    y = c(path$y + normal$y * half_width, rev(path$y - normal$y * half_width))
  )
}

#' A paper-grain/textured-ink stroke, masked to its own tapered outline
#'
#' `textured_stroke` builds the same tapered, pressure-modulated outline as
#' [shape_stroke()] (sharing its internal `resample_by_length()`/
#' `stroke_normals()` helpers), but instead of filling that outline with a
#' [style()]`@fill` via the ordinary `draw()`/`geometry_grob()` path, it
#' composites a rasterised paper-grain texture and masks it to the exact
#' outline shape using [grid::as.mask()] -- the same masking technique
#' [fill_vignette()] already uses for its own radial fade, but applied to
#' a real (possibly concave, tapering-to-a-point) stroke silhouette rather
#' than a synthetic circle drawn purely to build the mask.
#'
#' This is a different effect than filling a [shape_stroke()] with
#' [fill_charcoal()]/[fill_noise()] (already a good option for a stroke's
#' interior -- see [fill_charcoal()]'s docs): those tile a periodic
#' texture that repeats across the shape via [grid::pattern()], sized
#' relative to the target's own bounding box. `textured_stroke()` instead
#' samples its grain [noise_field] once, directly, across the stroke's own
#' world coordinates -- a single non-repeating raster the size of the
#' whole stroke, with no tiling seam to manage, at the cost of needing its
#' own `draw()` method rather than reusing `geometry_grob()`'s existing
#' `"polygon"`/`"path"`/`"points"` branches (`textured_stroke` is not a
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
#' @param x,y Numeric vectors of control point coordinates for the
#'   backbone path. Must be the same length, with at least two points.
#' @param width Maximum stroke width. Must be non-negative. Default `0.2`.
#' @param n Number of points used along the resampled backbone. Must be
#'   at least `2`. Default `100L`.
#' @param distortion A [noise_field] controlling the width ("pressure")
#'   modulation, as in [shape_stroke()]. Default `noise_field()`.
#' @param grain A [noise_field] controlling the paper-grain texture,
#'   sampled directly at each raster pixel's own world position (not
#'   torus-periodic, unlike [fill_noise()]'s tiled field -- see Details).
#'   Default `noise_field(frequency = 15, octaves = 2L, seed = 2L)`
#'   (finer/denser than `noise_field()`'s own default, for a paper-grain
#'   rather than cloudy look).
#' @param resolution Raster resolution (pixels per edge of the stroke's
#'   own bounding box). Must be a positive integer of at least `2L`.
#'   Default `150L`.
#' @param color Grain colour. Default `"gray15"`.
#' @param alpha Maximum grain opacity, at the noise field's peak. Must be
#'   a number in `(0, 1]`. Default `1`.
#' @param background Colour revealed as grain fades out, or `NA` for true
#'   transparency (showing whatever is drawn behind). Default `NA`.
#'
#' @return A `textured_stroke` object.
#'
#' @examples
#' t <- seq(0, 8, length.out = 150)
#' draw(textured_stroke(
#'   x = t, y = sin(t),
#'   width = 0.4, color = "gray10", alpha = 0.9
#' ))
#' draw(textured_stroke(
#'   x = t, y = sin(t),
#'   width = 0.4, color = "gray5", alpha = 0.85, background = "gray30"
#' ))
#'
#' @family effects
#' @export
textured_stroke <- S7::new_class(
  name = "textured_stroke",
  properties = list(
    x          = S7::class_numeric,
    y          = S7::class_numeric,
    width      = S7::class_numeric,
    n          = S7::class_integer,
    distortion = noise_field,
    grain      = noise_field,
    resolution = S7::class_integer,
    color      = S7::class_character,
    alpha      = S7::class_numeric,
    background = S7::class_character,
    outline = S7::new_property(
      class = xy,
      getter = textured_stroke_outline
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) return("x and y must be the same length")
    if (length(self@x) < 2) return("at least two control points are required")
    if (length(self@width) != 1) return("width must be length 1")
    if (self@width < 0) return("width must be a non-negative number")
    if (length(self@n) != 1 || self@n < 2L) return("n must be an integer of at least 2")
    if (length(self@resolution) != 1 || self@resolution < 2L) {
      return("resolution must be an integer of at least 2")
    }
    if (length(self@color) != 1) return("color must be a single string")
    if (length(self@alpha) != 1 || self@alpha <= 0 || self@alpha > 1) {
      return("alpha must be a single number in (0, 1]")
    }
    if (length(self@background) != 1) return("background must be a single string, or NA")
  },
  constructor = function(x,
                         y,
                         width = 0.2,
                         n = 100L,
                         distortion = noise_field(),
                         grain = noise_field(frequency = 15, octaves = 2L, seed = 2L),
                         resolution = 150L,
                         color = "gray15",
                         alpha = 1,
                         background = NA_character_) {
    S7::new_object(
      S7::S7_object(),
      x = x,
      y = y,
      width = width,
      n = n,
      distortion = distortion,
      grain = grain,
      resolution = as.integer(resolution),
      color = color,
      alpha = alpha,
      background = background
    )
  }
)

#' Build a `textured_stroke`'s masked raster grob
#'
#' Internal helper for `draw(textured_stroke)`. Samples `object@grain`
#' directly at every raster pixel's own world `(x, y)` position across the
#' outline's bounding box (a single non-tiled sample -- see
#' [textured_stroke()] details for why this differs from the `fill_*()`
#' family's torus-periodic tiling), then masks the resulting raster to
#' `outline`'s exact polygon shape via [grid::as.mask()], mirroring
#' [fill_vignette()]'s own mask-building technique.
#'
#' @param object A [textured_stroke] object.
#' @param outline `object@outline`, precomputed by the caller.
#' @param vp The shared [grid::viewport()] `draw()` built for this object.
#' @return A [grid::gTree()].
#' @noRd
textured_stroke_grob <- function(object, outline, vp) {
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
S7::method(draw, textured_stroke) <- function(object, xlim = NULL, ylim = NULL, ...) {
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
  grid::grid.draw(textured_stroke_grob(object, outline, vp))
}
