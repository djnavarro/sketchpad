# A twisted ribbon following a random path

`twist` is like
[ribbon](https://sketchpad.djnavarro.net/reference/ribbon.md), but the
underlying path is a Brownian bridge rather than a straight line, giving
the polygon a wandering, twisted appearance.

## Usage

``` r
twist(
  x = 0,
  y = 0,
  xend = 1,
  yend = 1,
  width = 0.2,
  smooth = 3L,
  n = 100L,
  frequency = 1,
  octaves = 2L,
  seed = 1L,
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

- smooth:

  Number of smoothing passes applied to the path. Default `3L`.

- n:

  Number of points used along the path. Default `100L`.

- frequency:

  Noise frequency. Must be non-negative. Default `1`.

- octaves:

  Number of noise octaves. Must be a positive integer. Default `2L`.

- seed:

  Integer seed for the noise field and path. Default `1L`.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).
