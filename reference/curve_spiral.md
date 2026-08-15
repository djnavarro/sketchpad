# An open spiral

`curve_spiral` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) whose
path winds around a centroid `(x, y)`, sweeping through `turns` full
revolutions while its radius interpolates linearly from `radius_start`
to `radius_end`. With `radius_start = radius_end` this traces a circle
repeated `turns` times (visually indistinguishable from a single circle,
since the path retraces itself); the usual case has
`radius_start != radius_end`, giving an Archimedean-style spiral that
grows or shrinks outward.

## Usage

``` r
curve_spiral(
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

## Details

`style@fill` has no effect for `curve_spiral()` – see
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
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)

## Examples

``` r
draw(curve_spiral(radius_start = 0, radius_end = 1, turns = 4))

```
