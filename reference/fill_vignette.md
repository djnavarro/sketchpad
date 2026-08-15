# Vignette fill

`fill_vignette()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
that fades a colour out towards the edges of each tile, using
[`grid::as.mask()`](https://rdrr.io/r/grid/as.mask.html) – the one
`grid` capability the rest of the `fill_*()` family doesn't touch. A
solid `color` layer is masked by a radial alpha mask (opaque at the tile
centre, fully transparent at its edge), optionally revealing a solid
`background` layer underneath rather than true transparency.

## Usage

``` r
fill_vignette(
  color = "black",
  background = NA,
  spacing = 1,
  aspect = 1,
  extend = "repeat"
)
```

## Arguments

- color:

  Fill colour at the tile's centre. Default `"black"`.

- background:

  Fill colour revealed as `color` fades out, or `NA` for true
  transparency (showing whatever is drawn behind the target shape).
  Default `NA`.

- spacing:

  Tile size, as a fraction of the target's bounding box. Must be a
  positive number. Default `1` (one tile spans the whole shape).

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- extend:

  Passed to [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html).
  Default `"repeat"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

As with
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md),
the fade shape is kept circular by correcting the *tile* to be
physically square via `aspect` (the target's bounding-box
width-to-height ratio), the same technique
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)
uses for its dots – once the tile is square, a mask specified inside it
in plain `"npc"` needs no further correction.

A mask must always be built with
[`grid::as.mask()`](https://rdrr.io/r/grid/as.mask.html) and an explicit
`type = "alpha"` here, rather than passed as a bare grob (which defaults
to an alpha mask anyway) – during prototyping, a bare mask grob whose
own fill was a
[`grid::radialGradient()`](https://rdrr.io/r/grid/patterns.html)
intermittently triggered an "Ignored luminance mask (not supported on
this device)" warning on this session's device, even though the rendered
result was visually correct either way. Being explicit with
`as.mask(..., type = "alpha")` avoided the warning entirely with an
identical render, so that's what's used here; true
[`grid::as.mask()`](https://rdrr.io/r/grid/as.mask.html) luminance masks
were found not to work at all in this nested tile context (silently
ignored, regardless of explicitness), so `fill_vignette()` only offers
the alpha variant.

## See also

Other fill helpers:
[`fill_charcoal()`](https://sketchpad.djnavarro.net/reference/fill_charcoal.md),
[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md),
[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md),
[`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md),
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md),
[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md),
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md),
[`fill_image()`](https://sketchpad.djnavarro.net/reference/fill_image.md),
[`fill_marble()`](https://sketchpad.djnavarro.net/reference/fill_marble.md),
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md),
[`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md),
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md)

## Examples

``` r
draw(shape_circle(fill = fill_vignette(color = "black")))

```
