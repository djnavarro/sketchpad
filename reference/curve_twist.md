# An open, wandering path following a random walk

`curve_twist` is
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)'s
path alone, with no ribbon width: an open
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)-like
polyline between `(x, y)` and `(xend, yend)`, displaced away from a
straight line by a
[noise_bridge](https://sketchpad.djnavarro.net/reference/noise_bridge.md),
giving a wandering, twisted appearance. Where
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)
also modulates a filled ribbon's width along this same kind of path (via
a separate `distortion`
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)),
`curve_twist()` has no width or fill at all – just the displaced
backbone itself, rendered as an open
[`grid::polylineGrob()`](https://rdrr.io/r/grid/grid.lines.html)
(`geometry = "path"`). Shares its path computation with
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)
via the internal `twisted_path_points()` helper (`R/shape_twist.R`)
rather than duplicating it.

`curve_twists()` is a vectorized version of `curve_twist()`: each
argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). A shared
`path_distortion`
[noise_bridge](https://sketchpad.djnavarro.net/reference/noise_bridge.md)
is automatically recycled across every path; pass a
[`list()`](https://rdrr.io/r/base/list.html) of several different
`noise_bridge`s instead to vary it per path. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one `curve_twist()` per recycled row, rather than a single drawable.

## Usage

``` r
curve_twist(
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

A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

For `curve_twists()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## Details

`style@fill` has no effect for `curve_twist()` – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`geometry` documentation for why `"path"` geometries have no interior to
fill. Passing `fill` via `...` is still accepted (it's simply ignored at
draw time), since
[`style()`](https://sketchpad.djnavarro.net/reference/style.md) is
shared across every `geometry`.

## See also

Other 1D curves:
[`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md),
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md)

## Examples

``` r
draw(curve_twist(
  x = 0, y = 0, xend = 1, yend = 0,
  path_distortion = noise_bridge(seed = 7734L)
))


# a larger scale wanders further from the straight line between the
# endpoints
draw(curve_twist(
  x = 0, y = 0, xend = 1, yend = 0, scale = 0.6,
  path_distortion = noise_bridge(seed = 7734L)
))


# curve_twist() is shape_twist()'s backbone alone, with no ribbon width
draw(shape_twist(x = 0, y = 0, xend = 1, yend = 0, path_distortion = noise_bridge(seed = 7734L)))


draw(curve_twists(x = 1:3, y = 0, xend = 2:4, yend = 1))


# a bundle of independently-wandering strands between the same endpoints
draw(curve_twists(
  x = 0, y = 0, xend = 3, yend = 0,
  path_distortion = list(noise_bridge(seed = 1L), noise_bridge(seed = 2L), noise_bridge(seed = 3L))
))

```
