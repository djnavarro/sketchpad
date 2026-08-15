# Multiple ribbons at once

`shape_ribbons()` is a vectorized version of
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md):
each argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). A shared
`distortion`
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
is automatically recycled across every ribbon; pass a
[`list()`](https://rdrr.io/r/base/list.html) of several different
`noise_field`s instead to vary it per ribbon. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)
per recycled row, rather than a single drawable.

## Usage

``` r
shape_ribbons(
  x = 0,
  y = 0,
  xend = 1,
  yend = 1,
  width = 0.2,
  n = 100L,
  distortion = noise_field(),
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Start point. Default `0`.

- xend, yend:

  End point. Default `1`.

- width:

  Maximum width. Must be non-negative. Default `0.2`.

- n:

  Number of points used along the path. Default `100L`.

- distortion:

  A
  [noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
  controlling the width modulation. Default
  [`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md).

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
[`shape_beziers()`](https://sketchpad.djnavarro.net/reference/shape_beziers.md),
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
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_twists()`](https://sketchpad.djnavarro.net/reference/shape_twists.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md),
[`shape_wedges()`](https://sketchpad.djnavarro.net/reference/shape_wedges.md)

## Examples

``` r
draw(shape_ribbons(x = 1:3, y = 0, xend = 2:4, yend = 1, width = 0.3))

```
