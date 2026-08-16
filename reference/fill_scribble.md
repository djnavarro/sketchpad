# Wandering-line scribble texture fill

`fill_scribble()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
from several randomly wandering lines, each a random finite sum of sine
harmonics (see the internal `scribble_lines()` helper) rather than a
smooth noise field or a scattered discrete motif – giving a loose,
hand-drawn scribble texture built from genuinely continuous strokes.

## Usage

``` r
fill_scribble(
  color = "black",
  direction = c("horizontal", "vertical"),
  n_lines = 5L,
  n_harmonics = 3L,
  amplitude = 0.35,
  resolution = 200L,
  linewidth = 1,
  spacing = 0.25,
  aspect = NULL,
  seed = 1L,
  extend = "repeat"
)
```

## Arguments

- color:

  One or more line colours. A vector shorter than `n_lines` is recycled
  (in order, not randomly) across the wandering lines – a single colour
  (the default) colours every line the same, matching the original
  behaviour. Default `"black"`.

- direction:

  Either `"horizontal"` (lines run left-right) or `"vertical"` (lines
  run top-bottom). Default `"horizontal"`.

- n_lines:

  Number of wandering lines per tile. Must be a positive integer.
  Default `5L`.

- n_harmonics:

  Number of sine harmonics summed per line. Must be a positive integer.
  Default `3L`.

- amplitude:

  Maximum total wiggle amplitude, as a `"npc"` fraction of the tile,
  split across `n_harmonics` (so more harmonics each contribute
  proportionally less). Must be a non-negative number. Default `0.35`.

- resolution:

  Number of points sampled along each line. Must be a positive integer
  of at least `2L`. Default `200L`.

- linewidth:

  Line width. Must be a positive number. Default `1`.

- spacing:

  Baseline tile size, as a fraction of the target's bounding box. Must
  be a positive number. Default `0.25`.

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number, or `NULL` (the default) to resolve it automatically
  from the real target's own bounding-box aspect ratio at
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) time –
  see the [fill](https://sketchpad.djnavarro.net/reference/fill.md)
  class. Passing a fixed number instead computes the pattern once,
  immediately, against that value only.

- seed:

  Integer seed for the random harmonics. Default `1L`.

- extend:

  Passed to [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html).
  Default `"repeat"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

A wandering *open* line poses a tiling problem none of the other
`fill_*()` helpers have:
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)'s
diagonal and
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)'s
raster both tile by construction (a straight corner-to-corner line, or
an already-periodic field), and
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)/[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md)/
[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md)
sidestep the problem entirely by keeping their scattered content
margined well clear of the tile edge. A wandering line that's meant to
look continuous *can't* stay clear of the edge – it has to run all the
way to it, and pick up again at exactly the right place, in both
position and slope, on the opposite edge, or the seam shows as a visible
kink. `fill_scribble()` gets this for free by building each line as a
random sum of sine harmonics at *integer* frequencies only: over one
full period, such a sum always returns exactly to its starting value and
slope (to floating-point precision), so consecutive tile copies join
with no visible seam – confirmed visually with `extend = "repeat"` at
small `spacing`, including repeated copies (unlike the
polygon-in-a-genuinely-repeated-tile issue documented at
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
open-line content showed no clipping or distortion in testing).

## Known limitation – direction is fixed, not an arbitrary angle

Every other angled helper
([`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)/[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md)/
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md))
achieves an arbitrary angle by reshaping the *tile* itself (via
`hatch_tile_dims()`) around content that's a plain corner-to-corner
diagonal. That trick was tried here first and found not to generalize:
reshaping the tile around a *wandering* line just anisotropically
stretches its wiggle rather than rotating it, since the line's content
isn't a bare diagonal the tile shape can reinterpret. A genuinely
rotated wandering line would need the tile built as a rotated/sheared
parallelogram with edge-matching worked out for a curve rather than a
segment – no such technique exists in this package yet. `direction` is
therefore restricted to `"horizontal"` (lines run left-right, periodic
tiling along that axis) or `"vertical"` (lines run top-bottom instead,
i.e. `along`/`across` from `scribble_lines()` mapped to `y`/`x` rather
than `x`/`y`) – there is no `angle` argument. Revisit if a real sketch
needs an arbitrary angle.

## See also

Other fill helpers:
[`fill()`](https://sketchpad.djnavarro.net/reference/fill.md),
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
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)

## Examples

``` r
draw(shape_circle(fill = fill_scribble(n_lines = 4L, seed = 6602L)))


# direction = "vertical" runs the wandering lines top-to-bottom instead
draw(shape_circle(
  fill = fill_scribble(n_lines = 4L, direction = "vertical", seed = 6602L)
))


# more harmonics and higher amplitude give a more agitated scribble
draw(shape_circle(
  fill = fill_scribble(
    n_lines = 6L,
    n_harmonics = 6L,
    amplitude = 0.6,
    seed = 6602L
  )
))


# a colour vector is recycled across the wandering lines
draw(shape_circle(
  fill = fill_scribble(
    color = c("steelblue", "tomato"),
    n_lines = 4L,
    seed = 6602L
  )
))

```
