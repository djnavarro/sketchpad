# A scatter of points defined directly by their coordinates

`points_raw` is
[shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md)'s
`"points"`-geometry analog, and the first concrete constructor to use
`geometry = "points"` (previously reserved on the dimensional reading
`"points"`(0D)/`"path"`(1D)/`"polygon"`(2D), but with no constructor
exposing it – see `.agents/PLAN.md`). The user supplies `x`/`y`
coordinates directly, rendered as unconnected markers rather than a
connected outline or path.

## Usage

``` r
points_raw(x, y, trans = trans_identity(), ...)
```

## Arguments

- x:

  Numeric vector of x coordinates.

- y:

  Numeric vector of y coordinates.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Details

`style@fill` and every line-related `style` property (`linewidth`,
`linetype`, `linejoin`, `lineend`, `linemitre`) have no effect for
`points_raw()` – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`geometry` documentation and `geometry_grob()`'s internal dispatch
(`R/draw.R`) for why a `"points"` geometry has no line to stroke and no
interior to fill. Only `style@color` is used, as the marker colour.

## Examples

``` r
draw(points_raw(
  x = seq(0, 1, length.out = 20),
  y = sin(seq(0, 2 * pi, length.out = 20)) / 2 + 0.5,
  color = "steelblue"
))

```
