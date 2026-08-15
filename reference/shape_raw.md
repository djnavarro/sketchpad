# A polygon defined directly by its vertices

`shape_raw` is the simplest
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md): the
user supplies `x` and `y` coordinates directly, and `points` is computed
trivially from them. It is most often produced by
[`convert()`](https://rconsortium.github.io/S7/reference/convert.html)ing
a more complex drawable (e.g. a
[shape_blob](https://sketchpad.djnavarro.net/reference/shape_blob.md) or
[shape_twist](https://sketchpad.djnavarro.net/reference/shape_twist.md))
down to its raw vertices.

`shape_raws()` is a vectorized version of `shape_raw()`. Since `x`/`y`
are themselves numeric vectors of vertex coordinates for a single
polygon, `shape_raws()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector of vertices per shape. Every other argument may be a plain
vector, recycled against `x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `shape_raw()` per list element/recycled row, rather than
a single drawable.

## Usage

``` r
shape_raw(x, y, trans = trans_identity(), ...)

shape_raws(x, y, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  For `shape_raw()`, a numeric vector of x/y coordinates. For
  `shape_raws()`, a [`list()`](https://rdrr.io/r/base/list.html) of such
  vectors instead – one vector of vertices per shape.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the shape's computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Value

A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

For `shape_raws()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_ribbonpath()`](https://sketchpad.djnavarro.net/reference/shape_ribbonpath.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_raw(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1)))


draw(shape_raws(
  x = list(c(0, 1, 1, 0), c(2, 3, 3, 2)),
  y = list(c(0, 0, 1, 1), c(0, 0, 1, 1))
))

```
