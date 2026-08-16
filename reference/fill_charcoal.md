# Charcoal/marker-style noise texture fill

`fill_charcoal()` is a
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)
preset – same field, same rendering, just different defaults – tuned to
read as hand-drawn charcoal or marker grain rather than
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
more general-purpose rasterized field: a lighter base tone, finer/denser
tiling, and finer noise detail.

## Usage

``` r
fill_charcoal(
  color = "gray15",
  spacing = 0.25,
  aspect = 1,
  resolution = 32L,
  alpha = 1,
  frequency = 4,
  octaves = 3L,
  seed = 1L,
  extend = "repeat"
)
```

## Arguments

- color:

  Fill colour. Default `"gray15"` (lighter than
  [`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
  own `"black"` default, closer to a charcoal tone).

- spacing:

  Baseline tile size, as a fraction of the target's bounding box. Must
  be a positive number. Default `0.25` (finer than
  [`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
  own `0.5` default, for denser grain).

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
  [`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md).
  Must be non-negative. Default `4` (finer detail than
  [`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
  own default of `1`).

- octaves:

  Number of noise octaves, as in
  [`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md).
  Must be a positive integer. Default `3L` (one more layer of detail
  than
  [`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
  own default of `2L`).

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

Found, while prototyping
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md)'s
interior texture, to be a substantially better fit than
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md)
for a curved stroke's body –
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md)'s
fixed horizontal/vertical direction doesn't track a curved path's own
tangent (see the "Deferred: arbitrary angle for
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md)"
item in `.agents/PLAN.md`), producing hatching that visibly cuts across
the stroke at odd angles wherever the path bends, while
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
directionless mottling has no orientation to clash with the curve.

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
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md),
[`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md),
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)

## Examples

``` r
draw(shape_stroke(
  x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.4,
  fill = fill_charcoal(), color = NA_character_
))


# a lighter tone and a curved backbone -- fill_charcoal()'s directionless
# mottling tracks a bend that fill_scribble()'s fixed direction wouldn't
t <- seq(0, 2 * pi, length.out = 200)
draw(shape_stroke(
  x = t, y = sin(t), width = 0.3,
  fill = fill_charcoal(color = "gray40"), color = NA_character_
))

```
