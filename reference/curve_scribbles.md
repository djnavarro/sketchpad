# Multiple wandering scribble curves at once

`curve_scribbles()` is a vectorized version of
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md):
each argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). Varying
`seed` per curve is usually what makes several scribbles look distinct
from each other. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md)
per recycled row, rather than a single drawable.

## Usage

``` r
curve_scribbles(
  x = 0,
  y = 0,
  width = 1,
  height = 1,
  direction = "horizontal",
  n_harmonics = 3L,
  amplitude = 0.35,
  n = 200L,
  seed = 1L,
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Coordinates of the curve's origin. Default `0`.

- width, height:

  Extent of the curve's bounding box along/across its direction of
  travel. Must be positive. Default `1`.

- direction:

  Either `"horizontal"` (the curve runs left-right) or `"vertical"`
  (top-bottom). Default `"horizontal"`.

- n_harmonics:

  Number of sine harmonics summed to build the curve. Must be a positive
  integer. Default `3L`.

- amplitude:

  Maximum total wiggle amplitude, as a fraction of `height` (for
  `direction = "horizontal"`) or `width` (for `"vertical"`), split
  across `n_harmonics`. Must be a non-negative number. Default `0.35`.

- n:

  Number of points sampled along the curve. Must be a positive integer
  of at least `2L`. Default `200L`.

- seed:

  Integer seed for the random harmonics. Default `1L`.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the curve's computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Value

A [sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## See also

Other 1D curves:
[`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md),
[`curve_arcs()`](https://sketchpad.djnavarro.net/reference/curve_arcs.md),
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
[`curve_beziers()`](https://sketchpad.djnavarro.net/reference/curve_beziers.md),
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`curve_lines()`](https://sketchpad.djnavarro.net/reference/curve_lines.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_raws()`](https://sketchpad.djnavarro.net/reference/curve_raws.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_spirals()`](https://sketchpad.djnavarro.net/reference/curve_spirals.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md),
[`curve_twists()`](https://sketchpad.djnavarro.net/reference/curve_twists.md)

## Examples

``` r
draw(curve_scribbles(x = 1:3, width = 0.8, height = 0.5, seed = 1:3))

```
