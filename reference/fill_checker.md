# Checkerboard pattern fill

`fill_checker()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
that renders a two-colour checkerboard. It's the cheapest member of the
hatch family to build: a checkerboard square has no direction the way a
hatch line does (compare
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)'s
corner-to-corner diagonal, needed specifically to tile a *sloped* line
seamlessly), so the tile content here is just four plain quadrant
rectangles – the same two-colour-grid special case
[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md)
already falls back to when `angle` is a multiple of 90 degrees, pulled
out into its own helper.

## Usage

``` r
fill_checker(
  color1 = "black",
  color2 = "white",
  spacing = 0.2,
  aspect = 1,
  extend = "repeat"
)
```

## Arguments

- color1, color2:

  The two checker colours. Defaults `"black"` and `"white"`.

- spacing:

  Baseline tile size, as a fraction of the target's bounding box. Must
  be a positive number. Default `0.2`.

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

As with the other `fill_*()` helpers,
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) tiles are
sized as a fraction of the target polygon's own bounding box rather than
a fixed physical square, so the checker squares would render as
rectangles, not squares, on a non-square bounding box. Pass the target's
width-to-height ratio as `aspect` to correct for this – the same tile-
squaring technique
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)
uses for its dots – so the default `aspect = 1` is only exact for a
square bounding box.

## See also

Other fill helpers:
[`fill_charcoal()`](https://sketchpad.djnavarro.net/reference/fill_charcoal.md),
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
draw(shape_circle(fill = fill_checker(color1 = "black", color2 = "white")))

```
