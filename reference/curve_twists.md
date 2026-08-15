# Multiple wandering twist paths at once

`curve_twists()` is a vectorized version of
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md):
each argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). A shared
`path_distortion`
[noise_bridge](https://sketchpad.djnavarro.net/reference/noise_bridge.md)
is automatically recycled across every path; pass a
[`list()`](https://rdrr.io/r/base/list.html) of several different
`noise_bridge`s instead to vary it per path. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)
per recycled row, rather than a single drawable.

## Usage

``` r
curve_twists(
  x = 0,
  y = 0,
  xend = 1,
  yend = 1,
  scale = 0.2,
  n = 100L,
  path_distortion = noise_bridge(),
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Start point. Default `0`.

- xend, yend:

  End point. Default `1`.

- scale:

  Amplitude of the Brownian-bridge displacement (internally scaled by
  `0.1`, matching
  [`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)'s
  own scaling of its path). Must be non-negative. Default `0.2`.

- n:

  Number of points used along the path. Default `100L`.

- path_distortion:

  A
  [noise_bridge](https://sketchpad.djnavarro.net/reference/noise_bridge.md)
  controlling the path's Brownian bridge. Default
  [`noise_bridge()`](https://sketchpad.djnavarro.net/reference/noise_bridge.md).

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
[`curve_spirals()`](https://sketchpad.djnavarro.net/reference/curve_spirals.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)

## Examples

``` r
draw(curve_twists(x = 1:3, y = 0, xend = 2:4, yend = 1))

```
