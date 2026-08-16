# An open polyline

`curve_line` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) whose
path connects an arbitrary number of control points `(x, y)` with
straight segments, in order. With two control points this is a single
line segment; with more, an open polyline.

`curve_lines()` is a vectorized version of `curve_line()`. Since `x`/`y`
are themselves numeric vectors of control points for a single polyline,
`curve_lines()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector of control points per polyline.

## Usage

``` r
curve_line(x, y, trans = trans_identity(), ...)

curve_lines(x, y, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  For `curve_line()`, numeric vectors of control point coordinates, the
  same length, with at least two control points. For `curve_lines()`, a
  [`list()`](https://rdrr.io/r/base/list.html) of such vectors instead –
  one vector of control points per polyline.

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

For `curve_lines()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## Details

Unlike
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md)/[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
the control points are not smoothed or resampled – `points` is exactly
`(x, y)`, so there is no `n` argument.

`style@fill` has no effect for `curve_line()` – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`geometry` documentation for why `"path"` geometries have no interior to
fill. Passing `fill` via `...` is still accepted (it's simply ignored at
draw time), since
[`style()`](https://sketchpad.djnavarro.net/reference/style.md) is
shared across every `geometry`.

Every other argument may be a plain vector, recycled against `x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `curve_line()` per list element/recycled row, rather than
a single drawable.

## See also

Other 1D curves:
[`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md),
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)

## Examples

``` r
draw(curve_line(x = c(0, 1, 1, 2), y = c(0, 1, 0, 1)))


# a thick, square-capped line reads very differently from a thin,
# round-capped one
draw(curve_line(
  x = c(0, 1, 2), y = c(0, 1, 0), linewidth = 12, lineend = "square"
))


# layer several jittered copies for a hand-drawn look
draw(effect_tremor(
  curve_line(x = c(0, 1, 1, 2), y = c(0, 1, 0, 1)),
  layers = 5L
))


draw(curve_lines(
  x = list(c(0, 1, 1, 2), c(2, 3, 3, 4)),
  y = list(c(0, 1, 0, 1), c(0, 1, 0, 1))
))


# a simple hatched grid of crossing lines
draw(curve_lines(
  x = list(c(0, 5), c(0, 5), c(0, 5)),
  y = list(c(0, 5), c(1, 4), c(2, 3))
))

```
