# An irregular, "blobby" circle

`shape_blob` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
similar to
[shape_circle](https://sketchpad.djnavarro.net/reference/shape_circle.md),
except that its radius varies smoothly around the circumference
according to Perlin/simplex noise generated with ambient.

## Usage

``` r
shape_blob(
  x = 0,
  y = 0,
  radius = 1,
  range = 0.2,
  n = 100L,
  frequency = 1,
  octaves = 2L,
  seed = 1L,
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

- frequency:

  Noise frequency. Must be non-negative. Default `1`.

- octaves:

  Number of noise octaves. Must be a positive integer. Default `2L`.

- seed:

  Integer seed for the noise field. Default `1L`.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)
