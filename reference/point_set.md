# A set of polygon vertices

`point_set` represents the vertices of a polygon as parallel `x` and `y`
coordinate vectors. Most
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
subclasses expose their vertices as a computed `points` property of
class `point_set`;
[shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md) is
the exception, where the user supplies `x`/`y` directly. Named
`point_set` rather than `points` so this exported constructor doesn't
mask [`graphics::points()`](https://rdrr.io/r/graphics/points.html).

## Usage

``` r
point_set(x = integer(0), y = integer(0))
```

## Arguments

- x:

  Numeric vector of x coordinates.

- y:

  Numeric vector of y coordinates.
