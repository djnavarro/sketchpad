# Multiple point scatters at once

`points_raws()` is a vectorized version of
[`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md).
Since `x`/`y` are themselves numeric vectors of point coordinates for a
single scatter, `points_raws()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector per scatter – which is most useful for giving several
distinct scatters different `style` arguments (e.g. a different `color`
each). Every other argument may be a plain vector, recycled against
`x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one
[`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md)
per list element/recycled row, rather than a single drawable.

## Usage

``` r
points_raws(x, y, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  A [`list()`](https://rdrr.io/r/base/list.html) of numeric vectors of
  point coordinates, one vector per scatter. Each vector must be the
  same length as its `y`/`x` counterpart.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Value

A [sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## See also

Other 0D points:
[`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md)

## Examples

``` r
draw(points_raws(
  x = list(seq(0, 1, length.out = 10), seq(0, 1, length.out = 10)),
  y = list(rep(0.25, 10), rep(0.75, 10)),
  color = c("steelblue", "darkred")
))

```
