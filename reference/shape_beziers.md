# Multiple closed Bezier curves at once

`shape_beziers()` is a vectorized version of
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md).
Since `x`/`y` are themselves numeric vectors of control points for a
single curve, `shape_beziers()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector of control points per shape – rather than a bare vector
(which
[`shape_circles()`](https://sketchpad.djnavarro.net/reference/shape_circles.md)-style
constructors use for a plain per-shape scalar). Every other argument may
be a plain vector, recycled against `x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md)
per list element/recycled row, rather than a single drawable.

## Usage

``` r
shape_beziers(x, y, n = 100L, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  A [`list()`](https://rdrr.io/r/base/list.html) of numeric vectors of
  control point coordinates, one vector per shape. Each vector must be
  the same length as its `y`/`x` counterpart, with at least two control
  points.

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

A [sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md),
[`shape_bezier_ribbons()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbons.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_blobs()`](https://sketchpad.djnavarro.net/reference/shape_blobs.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_circles()`](https://sketchpad.djnavarro.net/reference/shape_circles.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_ellipses()`](https://sketchpad.djnavarro.net/reference/shape_ellipses.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_polygons()`](https://sketchpad.djnavarro.net/reference/shape_polygons.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_raws()`](https://sketchpad.djnavarro.net/reference/shape_raws.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_rectangles()`](https://sketchpad.djnavarro.net/reference/shape_rectangles.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_ribbons()`](https://sketchpad.djnavarro.net/reference/shape_ribbons.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_twists()`](https://sketchpad.djnavarro.net/reference/shape_twists.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md),
[`shape_wedges()`](https://sketchpad.djnavarro.net/reference/shape_wedges.md)

## Examples

``` r
draw(shape_beziers(
  x = list(c(0, 0.5, 1, 0.5), c(2, 2.5, 3, 2.5)),
  y = list(c(0, 1, 0, -1), c(0, 1, 0, -1))
))

```
