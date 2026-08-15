# An ellipse

`shape_ellipse` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
defined by a centroid and independent x/y radii; its vertices are
computed as evenly spaced points around the circumference, generalizing
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md)
(which is a `shape_ellipse` with equal radii in both directions).

`shape_ellipses()` is a vectorized version of `shape_ellipse()`: each
argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `shape_ellipse()` per recycled row, rather than a single
drawable.

## Usage

``` r
shape_ellipse(
  x = 0,
  y = 0,
  x_radius = 1,
  y_radius = 1,
  n = 100L,
  trans = trans_identity(),
  ...
)

shape_ellipses(
  x = 0,
  y = 0,
  x_radius = 1,
  y_radius = 1,
  n = 100L,
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- x_radius, y_radius:

  Radii along the x and y axes. Must be non-negative. Default `1`.

- n:

  Number of points used to approximate the ellipse. Default `100L`.

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

For `shape_ellipses()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_ellipse(x_radius = 2, y_radius = 1))

draw(shape_ellipse(x = 1, y = 1, x_radius = 0.5, y_radius = 1, n = 6L, color = "darkred"))


draw(shape_ellipses(x = 1:3, x_radius = c(0.5, 1, 1.5), y_radius = 0.5))

```
