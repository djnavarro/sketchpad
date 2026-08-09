# Striped pattern fill

`fill_stripe()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
that renders repeating solid bands of two colours, at a given `angle`.

## Usage

``` r
fill_stripe(
  color1 = "black",
  color2 = "white",
  angle = 45,
  width = 0.5,
  spacing = 0.2,
  aspect = 1,
  extend = "repeat"
)
```

## Arguments

- color1, color2:

  The two stripe colours. Defaults `"black"` and `"white"`.

- angle:

  Hatch angle in degrees, measured counterclockwise from the positive
  x-axis. Default `45`.

- width:

  Fraction of each stripe period that is `color1` (the rest is
  `color2`). Must be a number strictly between `0` and `1`. Default
  `0.5` (equal bands).

- spacing:

  One stripe period (`color1` band plus `color2` band), as a fraction of
  the target's bounding box. Must be a positive number. Default `0.2`.

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- extend:

  Passed to the inner
  [`grid::linearGradient()`](https://rdrr.io/r/grid/patterns.html),
  controlling what happens beyond the colour stops – *not* to the outer
  [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) call, which
  always uses `extend = "repeat"` (see details). Default `"repeat"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

Unlike
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md),
this doesn't use the corner-to-corner-diagonal tile-shape technique at
all – because a *filled* band, unlike a thin hatch *line*, needs every
point along a tile's edge to match its neighbour, not just the points
where a thin line happens to cross, a single diagonal split of a tile
turns out not to tile seamlessly at an arbitrary angle the way a thin
hatch line does. Instead, `fill_stripe()` sidesteps
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html)'s tile-copy
repetition altogether: the stripe angle and period come from a short
two-colour
[`grid::linearGradient()`](https://rdrr.io/r/grid/patterns.html) with
hard colour stops (no smooth transition) and `extend = "repeat"`, which
repeats *itself* continuously along its own axis – a fundamentally
different (and for this purpose, simpler) mechanism than tiling a
rasterised copy.
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) is still used
around this gradient, but only once, as a single square (aspect-
corrected) tile spanning the whole target shape, exactly as
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md)
does by default – not to create repetition, which the gradient already
provides.

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
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)
