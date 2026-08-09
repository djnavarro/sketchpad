# An open Bezier curve

`curve_bezier` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) whose
path follows a Bezier curve defined by an arbitrary number of control
points (`x`, `y`), using the same Bernstein-polynomial machinery as
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md).
Where
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md)
always closes back to its first control point (a consequence of every
`"polygon"`-geometry `drawable` being rendered as a closed
[`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html)),
`curve_bezier()` sets `geometry = "path"` and is rendered as an open
[`grid::polylineGrob()`](https://rdrr.io/r/grid/grid.lines.html)
instead, stopping at its last control point rather than looping back.

## Usage

``` r
curve_bezier(x, y, n = 100L, ...)
```

## Arguments

- x, y:

  Numeric vectors of control point coordinates. Must be the same length,
  with at least two control points.

- n:

  Number of points used to sample the curve. Default `100L`.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Details

`style@fill` has no effect for `curve_bezier()` – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`geometry` documentation for why `"path"` geometries have no interior to
fill. Passing `fill` via `...` is still accepted (it's simply ignored at
draw time), since
[`style()`](https://sketchpad.djnavarro.net/reference/style.md) is
shared across every `geometry`.

## See also

Other 1D curves:
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md)
