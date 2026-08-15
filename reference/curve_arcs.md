# Multiple open arcs at once

`curve_arcs()` is a vectorized version of
[`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md):
each argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one
[`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md)
per recycled row, rather than a single drawable.

## Usage

``` r
curve_arcs(
  x = 0,
  y = 0,
  radius = 1,
  start = 0,
  end = pi/2,
  n = 100L,
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- radius:

  Radius. Must be non-negative. Default `1`.

- start, end:

  Start/end angle of the arc, in radians. Default `0`/ `pi / 2`.

- n:

  Number of points used to approximate the arc. Must be at least `2`.
  Default `100L`.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the shape's computed points. Default
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
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
[`curve_beziers()`](https://sketchpad.djnavarro.net/reference/curve_beziers.md),
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`curve_lines()`](https://sketchpad.djnavarro.net/reference/curve_lines.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_raws()`](https://sketchpad.djnavarro.net/reference/curve_raws.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_scribbles()`](https://sketchpad.djnavarro.net/reference/curve_scribbles.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_spirals()`](https://sketchpad.djnavarro.net/reference/curve_spirals.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md),
[`curve_twists()`](https://sketchpad.djnavarro.net/reference/curve_twists.md)

## Examples

``` r
draw(curve_arcs(start = 0, end = seq(pi / 2, 2 * pi, length.out = 3)))

```
