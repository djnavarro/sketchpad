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

## Usage

``` r
shape_polygon(x = 0, y = 0, radius = 1, n = 6L, ...)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- radius:

  Radius. Must be non-negative. Default `1`.

- n:

  Number of sides (vertices). Must be at least `3`. Default `6L`.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_polygon(radius = 1, n = 3L))

draw(shape_polygon(x = 1, y = 1, radius = 0.5, n = 8L, color = "darkred"))

```
