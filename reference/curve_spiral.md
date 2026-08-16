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

`curve_spirals()` is a vectorized version of `curve_spiral()`: each
argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `curve_spiral()` per recycled row, rather than a single
drawable.

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

A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

For `curve_spirals()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

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


# radius_start > radius_end spirals inward instead of outward
draw(curve_spiral(
  radius_start = 1, radius_end = 0.1, turns = 5, linewidth = 2
))


# equal start/end radii retrace a circle -- rarely useful on its own,
# but shows turns has no effect on shape when radius doesn't change
draw(curve_spiral(radius_start = 1, radius_end = 1, turns = 3))


draw(curve_spirals(x = c(0, 3, 6), turns = c(2, 3, 4)))


# nested spirals sharing a centroid, growing radius each time
draw(curve_spirals(
  radius_start = seq(0.1, 0.5, length.out = 4),
  radius_end = seq(0.6, 1, length.out = 4)
))

```
