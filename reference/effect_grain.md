# A paper-grain/textured-ink rendering of a drawable's own outline

`effect_grain` takes an existing polygon-geometry
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
(`object`, e.g.
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md))
and renders its own outline (`object@points`) not with a
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)`@fill`
via the ordinary
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md)/`geometry_grob()`
path, but by compositing a rasterised paper-grain texture and masking it
to the outline's exact polygon shape via
[`grid::as.mask()`](https://rdrr.io/r/grid/as.mask.html).

## Usage

``` r
effect_grain(
  object,
  grain = noise_field(frequency = 15, octaves = 2L, seed = 2L),
  resolution = 150L,
  color = "gray15",
  alpha = 1,
  background = NA_character_
)
```

## Arguments

- object:

  A polygon-geometry
  [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
  (`@geometry == "polygon"`) whose outline is textured – e.g.
  [`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
  [`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
  [`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md).
  `object@points` is used directly; `object@style` plays no role
  (`effect_grain()` draws its own grain raster instead).

- grain:

  A
  [noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
  controlling the paper-grain texture, sampled directly at each raster
  pixel's own world position (not torus-periodic, unlike
  [`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
  tiled field – see Details). Default
  `noise_field(frequency = 15, octaves = 2L, seed = 2L)` (finer/denser
  than
  [`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md)'s
  own default, for a paper-grain rather than cloudy look).

- resolution:

  Raster resolution (pixels per edge of `object`'s own bounding box).
  Must be a positive integer of at least `2L`. Default `150L`.

- color:

  Grain colour. Default `"gray15"`.

- alpha:

  Maximum grain opacity, at the noise field's peak. Must be a number in
  `(0, 1]`. Default `1`.

- background:

  Colour revealed as grain fades out, or `NA` for true transparency
  (showing whatever is drawn behind). Default `NA`.

## Value

An `effect_grain` object.

## Details

This is the same masking technique
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)
already uses for its own radial fade, but applied to `object`'s own real
(possibly concave, tapering-to-a-point) silhouette rather than a
synthetic circle drawn purely to build the mask.

This is a different effect than filling `object` with
[`fill_charcoal()`](https://sketchpad.djnavarro.net/reference/fill_charcoal.md)/[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)
(already a good option for a shape's interior – see
[`fill_charcoal()`](https://sketchpad.djnavarro.net/reference/fill_charcoal.md)'s
docs): those tile a periodic texture that repeats across the shape via
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), sized
relative to the target's own bounding box. `effect_grain()` instead
samples its grain
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
once, directly, across `object`'s own world coordinates – a single
non-repeating raster the size of the whole shape, with no tiling seam to
manage, at the cost of needing its own
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) method
rather than reusing `geometry_grob()`'s existing
`"polygon"`/`"path"`/`"points"` branches (`effect_grain` is not a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
subclass at all, since its rendering isn't expressible as a single
`points`-based grob).

Grain is rendered as varying opacity of `color`, from fully transparent
at the noise field's minimum to `alpha` at its maximum – exactly
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
own opacity convention – optionally revealing a solid `background`
colour underneath (as
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)'s
own `background` argument does) rather than true transparency, which
reads as a solid, mottled ink stroke instead of a sparse one.

## See also

Other effects:
[`effect_bristle()`](https://sketchpad.djnavarro.net/reference/effect_bristle.md),
[`effect_tremor()`](https://sketchpad.djnavarro.net/reference/effect_tremor.md)

## Examples

``` r
t <- seq(0, 8, length.out = 150)
template <- shape_stroke(x = t, y = sin(t), width = 0.4)

# before: a plain filled stroke
draw(template)


# after: the same outline rendered as textured grain instead of a
# solid style() fill
draw(effect_grain(template, color = "gray10", alpha = 0.9))


# a non-NA background reveals a solid colour underneath the grain,
# instead of true transparency
draw(effect_grain(
  template,
  color = "gray5",
  alpha = 0.85,
  background = "gray30"
))


# a coarser grain field (lower frequency) reads less like paper texture
# and more like a mottled brushstroke
draw(effect_grain(template, grain = noise_field(frequency = 3, seed = 2)))

```
