# A tapered ribbon between two points

`ribbon` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
polygon that follows a straight line between `(x, y)` and
`(xend, yend)`, with a width that tapers at both ends and varies along
its length according to simplex noise.

## Usage

``` r
ribbon(
  x = 0,
  y = 0,
  xend = 1,
  yend = 1,
  width = 0.2,
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

- n:

  Number of points used along the path. Default `100L`.

- frequency:

  Noise frequency. Must be non-negative. Default `1`.

- octaves:

  Number of noise octaves. Must be a positive integer. Default `2L`.

- seed:

  Integer seed for the noise field. Default `1L`.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).
