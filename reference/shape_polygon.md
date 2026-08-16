# A regular polygon

`shape_polygon` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
defined by a centroid and a radius; its vertices are `n` evenly spaced
points around the circumference, giving a regular n-gon (e.g. `n = 3` a
triangle, `n = 6` a hexagon). Unlike
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md)/[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
`points` does not repeat its first vertex at the end – there are exactly
`n` distinct vertices, since
[`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html) closes
the path itself and a polygon has no approximation error to hide.

`shape_polygons()` is a vectorized version of `shape_polygon()`: each
argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `shape_polygon()` per recycled row, rather than a single
drawable.

## Usage

``` r
shape_polygon(x = 0, y = 0, radius = 1, n = 6L, trans = trans_identity(), ...)

shape_polygons(x = 0, y = 0, radius = 1, n = 6L, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- radius:

  Radius. Must be non-negative. Default `1`.

- n:

  Number of sides (vertices). Must be at least `3`. Default `6L`.

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

For `shape_polygons()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_ribbonpath()`](https://sketchpad.djnavarro.net/reference/shape_ribbonpath.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_polygon(radius = 1, n = 3L))

draw(shape_polygon(x = 1, y = 1, radius = 0.5, n = 8L, color = "darkred"))

draw(shape_polygon(n = 5L, fill = fill_stripe(color1 = "white", color2 = "grey30")))


# rotating a low-n polygon reorients its vertices
draw(shape_polygon(n = 4L, trans = trans_rotate(pi / 4)))


draw(shape_polygons(x = 1:3, n = c(3L, 4L, 6L)))

draw(shape_polygons(
  x = 0, y = 0, radius = seq(3, 0.5, length.out = 6), n = 6L,
  fill = rep(c("grey20", "grey90"), length.out = 6)
))

```
