# Multiple raw paths at once

`curve_raws()` is a vectorized version of
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md).
Since `x`/`y` are themselves numeric vectors of vertex coordinates for a
single path, `curve_raws()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector of vertices per path. Every other argument may be a plain
vector, recycled against `x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md)
per list element/recycled row, rather than a single drawable.

## Usage

``` r
curve_raws(x, y, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  A [`list()`](https://rdrr.io/r/base/list.html) of numeric vectors of
  vertex coordinates, one vector per path. Each vector must be the same
  length as its `y`/`x` counterpart.

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
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_scribbles()`](https://sketchpad.djnavarro.net/reference/curve_scribbles.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_spirals()`](https://sketchpad.djnavarro.net/reference/curve_spirals.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md),
[`curve_twists()`](https://sketchpad.djnavarro.net/reference/curve_twists.md)

## Examples

``` r
draw(curve_raws(
  x = list(c(0, 1, 2), c(2, 3, 4)),
  y = list(c(0, 1, 0), c(0, 1, 0))
))

```
