# Simplex/fractal noise texture fill

`fill_noise()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
from a rasterised simplex/fractal noise field, using the same noise
machinery as
[`blob()`](https://sketchpad.djnavarro.net/reference/blob.md)'s wobbly
outline
([`ambient::fracture()`](https://ambient.data-imaginist.com/reference/fracture.html)
/
[`ambient::gen_simplex()`](https://ambient.data-imaginist.com/reference/noise_simplex.html)
/
[`ambient::fbm()`](https://ambient.data-imaginist.com/reference/fbm.html),
with matching `frequency`, `octaves`, and `seed` arguments), so a
noise-filled shape and a noise-wobbled outline share one visual
vocabulary.

## Usage

``` r
fill_noise(
  color = "black",
  spacing = 0.5,
  aspect = 1,
  resolution = 32L,
  alpha = 1,
  frequency = 1,
  octaves = 2L,
  seed = 1L,
  extend = "repeat"
)
```

## Arguments

- color:

  Fill colour. Default `"black"`.

- spacing:

  Baseline tile size, as a fraction of the target's bounding box. Must
  be a positive number. Default `0.5`.

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- resolution:

  Raster resolution (pixels per tile edge). Must be a positive integer
  of at least `2L`. Default `32L`.

- alpha:

  Maximum opacity, at the noise field's peak. Must be a number in
  `(0, 1]`. Default `1`.

- frequency:

  Noise frequency, as in
  [`blob()`](https://sketchpad.djnavarro.net/reference/blob.md). Must be
  non-negative. Default `1`.

- octaves:

  Number of noise octaves, as in
  [`blob()`](https://sketchpad.djnavarro.net/reference/blob.md). Must be
  a positive integer. Default `2L`.

- seed:

  Integer seed for the noise field, as in
  [`blob()`](https://sketchpad.djnavarro.net/reference/blob.md). Default
  `1L`.

- extend:

  Passed to [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html).
  Default `"repeat"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

Noise is rendered as varying opacity of a single `color`, from fully
transparent at the noise field's minimum to `alpha` at its maximum – a
mottled, cloud-like texture rather than a hard-edged one.

A raster tile has no baked-in direction the way a hatch line does, so
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)'s
tile-edge "dashing" problem doesn't apply directly, but an *ordinary*
noise field still isn't periodic, and
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html)'s
`extend = "repeat"` will visibly seam wherever one tile edge fails to
match the next. `fill_noise()` avoids this by sampling the noise on a
torus: each raster pixel's `(u, v)` tile coordinate is mapped onto a
pair of circles
([`ambient::gen_simplex()`](https://ambient.data-imaginist.com/reference/noise_simplex.html)'s
4 dimensions, `x`/`y` for `u` and `z`/`t` for `v`) rather than sampled
directly, so the field is mathematically periodic in both directions and
tiles with no visible seam, at the cost of the noise "wrapping around"
within each tile rather than varying smoothly across a larger area.

In practice, a very faint seam can still be visible at tile boundaries
on some devices, even though the underlying field is exactly periodic;
this appears to be an artifact of how the graphics device samples a
repeated raster tile (it persists regardless of `interpolate` and
doesn't improve with higher `resolution`), not a flaw in the noise field
itself, and is far subtler than the tile-edge mismatch
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)
has to actively avoid.

## See also

Other fill helpers:
[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md),
[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md),
[`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md),
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md),
[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md),
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md),
[`fill_image()`](https://sketchpad.djnavarro.net/reference/fill_image.md),
[`fill_marble()`](https://sketchpad.djnavarro.net/reference/fill_marble.md),
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)
