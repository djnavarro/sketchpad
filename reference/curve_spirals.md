# Multiple open spirals at once

`curve_spirals()` is a vectorized version of
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md):
each argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md)
per recycled row, rather than a single drawable.

## Usage

``` r
curve_spirals(
  x = 0,
  y = 0,
  radius_start = 0,
  radius_end = 1,
  turns = 3,
  n = 200L,
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- radius_start, radius_end:

  Radius at the start/end of the path. Must be non-negative. Default
  `0`/`1`.

- turns:

  Number of full revolutions. Must be positive. Default `3`.

- n:

  Number of points used to approximate the spiral. Default `200L`.

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
[`curve_scribbles()`](https://sketchpad.djnavarro.net/reference/curve_scribbles.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md),
[`curve_twists()`](https://sketchpad.djnavarro.net/reference/curve_twists.md)

## Examples

``` r
draw(curve_spirals(x = c(0, 3, 6), turns = c(2, 3, 4)))

```
