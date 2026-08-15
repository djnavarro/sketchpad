# An irregular, "blobby" circle

`shape_blob` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
similar to
[shape_circle](https://sketchpad.djnavarro.net/reference/shape_circle.md),
except that its radius varies smoothly around the circumference
according to Perlin/simplex noise generated with ambient.

`shape_blobs()` is a vectorized version of `shape_blob()`: each argument
may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). A shared
`distortion`
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
is automatically recycled across every blob; pass a
[`list()`](https://rdrr.io/r/base/list.html) of several different
`noise_field`s instead to vary it per blob. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one `shape_blob()` per recycled row, rather than a single drawable.

## Usage

``` r
shape_blob(
  x = 0,
  y = 0,
  radius = 1,
  range = 0.2,
  n = 100L,
  distortion = noise_field(),
  trans = trans_identity(),
  ...
)

shape_blobs(
  x = 0,
  y = 0,
  radius = 1,
  range = 0.2,
  n = 100L,
  distortion = noise_field(),
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- radius:

  Mean radius. Must be non-negative. Default `1`.

- range:

  Amplitude of the radius distortion. Must be non-negative. Default
  `0.2`.

- n:

  Number of points used to approximate the outline. Default `100L`.

- distortion:

  A
  [noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
  controlling the radius distortion. Default
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

For `shape_blobs()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_ribbonpath()`](https://sketchpad.djnavarro.net/reference/shape_ribbonpath.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_blob(radius = 1, range = 0.3, distortion = noise_field(seed = 4821L)))


draw(shape_blobs(x = 1:3, radius = c(0.5, 1, 1.5), range = 0.2))

```
