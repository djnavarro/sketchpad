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

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

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

```
