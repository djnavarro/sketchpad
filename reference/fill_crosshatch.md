# Crosshatch pattern fill

`fill_crosshatch()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
that renders two mirror-symmetric hatch lines, at `angle` and `-angle`,
forming an "X" inside each tile. It shares
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)'s
tile-shape technique: both lines are drawn as the two corner-to-corner
diagonals of a single rectangular tile (rather than at an arbitrary
baked-in slope), so both tile seamlessly under `extend = "repeat"`, and
the tile's `width`/`height` ratio – not the diagonals' own coordinates –
determines the rendered angle. See
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)'s
details for why this matters.

## Usage

``` r
fill_crosshatch(
  color = "black",
  angle = 45,
  spacing = 0.1,
  aspect = 1,
  linewidth = 1,
  extend = "repeat"
)
```

## Arguments

- color:

  Line colour. Default `"black"`.

- angle:

  Hatch angle in degrees, measured counterclockwise from the positive
  x-axis. Default `45`.

- spacing:

  Baseline tile size, as a fraction of the target's bounding box. Must
  be a positive number. Default `0.1`.

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- linewidth:

  Line width. Must be a positive number. Default `1`.

- extend:

  Passed to [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html).
  Default `"repeat"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

Because both lines share one tile shape, they are only *perpendicular*
when `angle = 45` (the classic crosshatch look); for other angles the
two lines are symmetric about the horizontal axis but not at right
angles to each other. Genuinely perpendicular hatching at an arbitrary
angle would need two differently-shaped tiles layered as separate fills,
which this function does not attempt.

At `angle` a multiple of 90 degrees, the two mirrored diagonals would
coincide, so this case is handled separately by drawing a horizontal
line and a vertical line instead (a simple grid).

## See also

Other fill helpers:
[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md),
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
