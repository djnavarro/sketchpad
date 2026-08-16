# A tapered ribbon between two points

`shape_ribbon` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
polygon that follows a straight line between `(x, y)` and
`(xend, yend)`, with a width that tapers at both ends and varies along
its length according to simplex noise.

`shape_ribbons()` is a vectorized version of `shape_ribbon()`: each
argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one `shape_ribbon()` per recycled row, rather than a single drawable.

## Usage

``` r
shape_ribbon(
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

A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

For `shape_ribbons()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## Details

Any length-1 element is broadcast to the common length; mismatched
lengths greater than 1 raise an error. A shared `distortion`
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
is automatically recycled across every ribbon; pass a
[`list()`](https://rdrr.io/r/base/list.html) of several different
`noise_field`s instead to vary it per ribbon.

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_strokepath()`](https://sketchpad.djnavarro.net/reference/shape_strokepath.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_ribbon(x = 0, y = 0, xend = 1, yend = 1, width = 0.3))


# a higher-frequency distortion modulates width more rapidly along the
# ribbon's length, giving a more textured/organic edge
draw(shape_ribbon(
  x = 0, y = 0, xend = 1, yend = 1, width = 0.3,
  distortion = noise_field(frequency = 8, seed = 99L)
))


draw(shape_ribbon(
  x = 0, y = 0, xend = 2, yend = 0, width = 0.4,
  fill = fill_gradient(color = c("steelblue", "white"))
))


draw(shape_ribbons(x = 1:3, y = 0, xend = 2:4, yend = 1, width = 0.3))


# a fan of ribbons radiating from the origin
angle <- seq(0, 2 * pi, length.out = 13)[-13]
draw(shape_ribbons(
  x = 0,
  y = 0,
  xend = cos(angle),
  yend = sin(angle),
  width = 0.1
))

```
