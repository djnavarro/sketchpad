# Halftone dot pattern fill

`fill_halftone()` is
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)'s
other variant: instead of scattering dots of one fixed size, each dot's
radius is drawn uniformly at random from `radius`, giving a mottled
halftone-print look rather than a uniform stipple. Like
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)
(and unlike
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md)),
it scatters plain
[`grid::circleGrob()`](https://rdrr.io/r/grid/grid.circle.html)s, so
it's immune to the *polygon*-specific rendering problems documented at
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md)
– but it shares
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)'s
own, separate "Known rendering risk with multiple dots" (repeated tiles
containing several `circleGrob`s were, in testing, sometimes visibly
distorted on this package's development R build; see that section for
details). There is no known way to avoid this while still getting a
genuine scattered-dot texture, so **check rendered output visually**
here too.

## Usage

``` r
fill_halftone(
  color = "black",
  radius = c(0.05, 0.2),
  spacing = 0.3,
  aspect = 1,
  n = 4L,
  seed = 1L,
  extend = "repeat"
)
```

## Arguments

- color:

  Dot colour. Default `"black"`.

- radius:

  Dot radius range, as a length-2 numeric vector giving the
  `"npc"`-fraction-of-tile minimum and maximum (a dot's actual radius is
  drawn uniformly from this range). Both values must be positive, and
  the first must be no larger than the second. Default `c(0.05, 0.2)`.

- spacing:

  Baseline tile size, as a fraction of the target's bounding box. Must
  be a positive number. Default `0.3`.

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- n:

  Number of dots scattered per tile. Must be a positive integer. Default
  `4L`.

- seed:

  Integer seed for the dot positions. Default `1L`.

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
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
the target's bounding-box aspect ratio needs to be passed as `aspect` to
keep the dots circular rather than elliptical; the default `aspect = 1`
is only exact for a square bounding box. Dot centres are kept at least
`max(radius)` from each tile edge, so even the largest possible dot
isn't clipped away near a boundary.

## See also

Other fill helpers:
[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md),
[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md),
[`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md),
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md),
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
draw(shape_circle(fill = fill_halftone(radius = c(0.05, 0.15), seed = 3187L)))

```
