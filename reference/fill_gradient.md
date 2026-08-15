# Gradient fill

`fill_gradient()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
whose tile content is a single rectangle filled with a
[`grid::linearGradient()`](https://rdrr.io/r/grid/patterns.html) or
[`grid::radialGradient()`](https://rdrr.io/r/grid/patterns.html),
depending on `type`.

## Usage

``` r
fill_gradient(
  colors = c("white", "black"),
  type = c("linear", "radial"),
  angle = 45,
  stops = NULL,
  spacing = 1,
  aspect = 1,
  extend = "pad"
)
```

## Arguments

- colors:

  Two or more colours to interpolate between.

- type:

  Either `"linear"` or `"radial"`. Default `"linear"`.

- angle:

  Gradient direction in degrees, for `type = "linear"` only (ignored for
  `"radial"`). Default `45`.

- stops:

  Colour stop positions, as a numeric vector the same length as
  `colors`, or `NULL` to space them evenly (the default used by
  [`grid::linearGradient()`](https://rdrr.io/r/grid/patterns.html)/[`grid::radialGradient()`](https://rdrr.io/r/grid/patterns.html)).
  Default `NULL`.

- spacing:

  Tile size, as a fraction of the target's bounding box. Must be a
  positive number. Default `1` (one tile spans the whole shape).

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- extend:

  Passed to the inner
  [`grid::linearGradient()`](https://rdrr.io/r/grid/patterns.html)/
  [`grid::radialGradient()`](https://rdrr.io/r/grid/patterns.html),
  controlling what happens beyond the colour stops. Default `"pad"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

Like the other `fill_*()` helpers, this needs the target's bounding-box
aspect ratio (`aspect`) to render true rather than stretched – but the
correction is applied differently here. Rather than adjusting the
gradient's own coordinates (the way
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)
adjusts a segment's direction), `fill_gradient()` corrects the *tile*
itself to be physically square, exactly as
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)
does for its dots: once the tile is square, a gradient specified inside
it in plain `"npc"` needs no further correction to render at the
requested `angle`, or as a true circle for `type = "radial"`.

This also means a gradient tile has none of
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)'s
periodicity concerns: adjacent tiles are simply identical copies of the
same square gradient, with nothing analogous to a hatch line's tile-edge
dashing to avoid.

With the default `spacing = 1`, one tile spans (and, for a non-square
bounding box, slightly overshoots) the target's entire bounding box,
giving a single smooth gradient across the whole shape – the overshoot
is invisibly clipped away by the target's own outline. Set `spacing < 1`
for a repeating pattern of small gradient motifs instead.

## See also

Other fill helpers:
[`fill_charcoal()`](https://sketchpad.djnavarro.net/reference/fill_charcoal.md),
[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md),
[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md),
[`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md),
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
draw(shape_circle(fill = fill_gradient(c("white", "steelblue"))))

draw(shape_circle(fill = fill_gradient(c("yellow", "red"), type = "radial")))

```
