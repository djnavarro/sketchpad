# An open polyline

`curve_line` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) whose
path connects an arbitrary number of control points `(x, y)` with
straight segments, in order. With two control points this is a single
line segment; with more, an open polyline. Unlike
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md)/[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
the control points are not smoothed or resampled – `points` is exactly
`(x, y)`, so there is no `n` argument.

## Usage

``` r
curve_line(x, y, ...)
```

## Arguments

- x, y:

  Numeric vectors of control point coordinates. Must be the same length,
  with at least two control points.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Details

`style@fill` has no effect for `curve_line()` – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`geometry` documentation for why `"path"` geometries have no interior to
fill. Passing `fill` via `...` is still accepted (it's simply ignored at
draw time), since
[`style()`](https://sketchpad.djnavarro.net/reference/style.md) is
shared across every `geometry`.

## See also

Other 1D curves:
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)

## Examples

``` r
draw(curve_line(x = c(0, 1, 1, 2), y = c(0, 1, 0, 1)))

```
