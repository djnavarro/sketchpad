# A circle

`circle` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
defined by a centroid and a radius; its vertices are computed as evenly
spaced points around the circumference.

## Usage

``` r
circle(x = 0, y = 0, radius = 1, n = 100L, ...)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- radius:

  Radius. Must be non-negative. Default `1`.

- n:

  Number of points used to approximate the circle. Default `100L`.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).
