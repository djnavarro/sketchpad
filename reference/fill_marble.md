# Marbled, veined texture fill

`fill_marble()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
resembling veined marble: a set of `stripes` parallel bands running
around the tile's `u` axis, displaced by a
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)-style
torus-periodic turbulence field (via the shared internal
`torus_grid()`/`torus_noise()` helpers) rather than left straight – the
classic "sine of a coordinate plus turbulence" recipe for procedural
marble.

## Usage

``` r
fill_marble(
  color1 = "white",
  color2 = "black",
  spacing = 0.5,
  aspect = 1,
  resolution = 32L,
  stripes = 3L,
  warp = 4,
  frequency = 1,
  octaves = 3L,
  seed = 1L,
  extend = "repeat"
)
```

## Arguments

- color1, color2:

  The two colours blended across each band. Defaults `"white"` and
  `"black"`.

- spacing:

  Baseline tile size, as a fraction of the target's bounding box. Must
  be a positive number. Default `0.5`.

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- resolution:

  Raster resolution (pixels per tile edge). Must be a positive integer
  of at least `2L`. Default `32L`.

- stripes:

  Number of bands running around the tile's `u` axis before turbulence
  displacement. Must be a positive integer. Default `3L`.

- warp:

  Turbulence amplitude, in radians of displacement along the band
  coordinate. Must be a non-negative number. Default `4`.

- frequency:

  Noise frequency, as in
  [`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md).
  Must be non-negative. Default `1`.

- octaves:

  Number of turbulence octaves, as in
  [`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md).
  Must be a positive integer. Default `3L`.

- seed:

  Integer seed for the noise field, as in
  [`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md).
  Default `1L`.

- extend:

  Passed to [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html).
  Default `"repeat"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

Periodicity needs two things, both already true here: the undisplaced
bands (`sin(theta_u * stripes)`) are periodic in `u` for any *integer*
`stripes`, since `theta_u` itself advances by exactly `2 * pi` over one
tile width; and the turbulence added on top is periodic in both `u` and
`v` because it comes from `torus_noise()`, the same torus-sampling
technique
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)
uses for its own field. Adding one periodic function to another (here,
inside a further [`sin()`](https://rdrr.io/r/base/Trig.html)) stays
periodic, so the combined result still tiles with no seam.

Unlike
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)
(opacity of one colour), the banding is rendered as a blend between
`color1` and `color2`, since a marble texture's visual interest is the
veining pattern itself rather than a fade to transparency.

[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
own faint tile-boundary rasterization seam (see its details) can be more
noticeable here: [`sin()`](https://rdrr.io/r/base/Trig.html) turns a
small mismatch in the turbulence field into a visibly sharper edge in a
band than the same mismatch would produce in a plain opacity fade.

## See also

Other fill helpers:
[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md),
[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md),
[`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md),
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md),
[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md),
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md),
[`fill_image()`](https://sketchpad.djnavarro.net/reference/fill_image.md),
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md),
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)
