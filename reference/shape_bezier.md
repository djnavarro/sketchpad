# A closed Bezier curve

`shape_bezier` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) whose
outline follows a Bezier curve defined by an arbitrary number of control
points (`x`, `y`). With two control points this is a straight line; with
four, a cubic Bezier of the kind used to build ribbons and other flowing
shapes. Since
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) renders
every `"polygon"`-geometry `drawable`'s `points` as a closed polygon,
the curve is implicitly closed from its last control point back to its
first – for an open Bezier curve/path instead, see
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md).

`shape_beziers()` is a vectorized version of `shape_bezier()`. Since
`x`/`y` are themselves numeric vectors of control points for a single
curve, `shape_beziers()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector of control points per shape – rather than a bare vector
(which
[`shape_circles()`](https://sketchpad.djnavarro.net/reference/shape_circle.md)-style
constructors use for a plain per-shape scalar). Every other argument may
be a plain vector, recycled against `x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `shape_bezier()` per list element/recycled row, rather
than a single drawable.

## Usage

``` r
shape_bezier(x, y, n = 100L, trans = trans_identity(), ...)

shape_beziers(x, y, n = 100L, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  For `shape_bezier()`, numeric vectors of control point coordinates,
  the same length, with at least two control points. For
  `shape_beziers()`, a [`list()`](https://rdrr.io/r/base/list.html) of
  such vectors instead – one vector of control points per shape.

- n:

  Number of points used to sample the curve. Default `100L`.

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

For `shape_beziers()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## See also

Other 2D shapes:
[`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_bezier(x = c(0, 0.5, 1, 0.5), y = c(0, 1, 0, -1)))


draw(shape_beziers(
  x = list(c(0, 0.5, 1, 0.5), c(2, 2.5, 3, 2.5)),
  y = list(c(0, 1, 0, -1), c(0, 1, 0, -1))
))

```
