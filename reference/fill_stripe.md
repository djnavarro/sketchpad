# Striped pattern fill

`fill_stripe()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
that renders repeating solid bands, at a given `angle`, generalized from
two colours to an arbitrary palette.

## Usage

``` r
fill_stripe(
  color = c("black", "white"),
  angle = 45,
  spacing = 0.2,
  aspect = 1,
  extend = "repeat"
)
```

## Arguments

- color:

  Two or more stripe colours, one equal-width band each (see details for
  biasing band widths). Default `c("black", "white")`.

- angle:

  Hatch angle in degrees, measured counterclockwise from the positive
  x-axis. Default `45`.

- spacing:

  One full period through all of `color`, as a fraction of the target's
  bounding box. Must be a positive number. Default `0.2`.

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
repetition altogether: the stripe angle and period come from a
[`grid::linearGradient()`](https://rdrr.io/r/grid/patterns.html) with
hard colour stops (no smooth transition) and `extend = "repeat"`, which
repeats *itself* continuously along its own axis – a fundamentally
different (and for this purpose, simpler) mechanism than tiling a
rasterised copy.
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) is still used
around this gradient, but only once, as a single square
(aspect-corrected) tile spanning the whole target shape, exactly as
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md)
does by default – not to create repetition, which the gradient already
provides.

Each of the `n = length(color)` colours gets an equal-width band by
default (`1/n` of the period); there's no separate argument for unequal
bands – repeat a colour in `color` instead (e.g.
`c("steelblue", "steelblue", "white")` gives a 2:1 ratio between the two
colours), which reuses the same recycling mechanism rather than adding a
second one.

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
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)

## Examples

``` r
draw(shape_circle(fill = fill_stripe(angle = 30)))


# repeating a colour biases the band widths, rather than a separate argument
draw(shape_circle(fill = fill_stripe(color = c("steelblue", "steelblue", "white"))))


# narrower spacing gives more, thinner stripes
draw(shape_circle(fill = fill_stripe(angle = 90, spacing = 0.08)))


# three or more colours repeat through the same period
draw(shape_circle(fill = fill_stripe(color = c("steelblue", "white", "tomato"), angle = 30)))

```
