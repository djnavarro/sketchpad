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

`curve_beziers()` is a vectorized version of `curve_bezier()`. Since
`x`/`y` are themselves numeric vectors of control points for a single
curve, `curve_beziers()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector of control points per curve. Every other argument may be a
plain vector, recycled against `x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `curve_bezier()` per list element/recycled row, rather
than a single drawable.

## Usage

``` r
curve_bezier(x, y, n = 100L, trans = trans_identity(), ...)

curve_beziers(x, y, n = 100L, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  For `curve_bezier()`, numeric vectors of control point coordinates,
  the same length, with at least two control points. For
  `curve_beziers()`, a [`list()`](https://rdrr.io/r/base/list.html) of
  such vectors instead – one vector of control points per curve.

- n:

  Number of points used to sample the curve. Default `100L`.

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

For `curve_beziers()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

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
[`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md),
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)

## Examples

``` r
draw(curve_bezier(x = c(0, 0.5, 1), y = c(0, 1, 0)))


draw(curve_beziers(
  x = list(c(0, 0.5, 1), c(2, 2.5, 3)),
  y = list(c(0, 1, 0), c(0, 1, 0))
))

```
