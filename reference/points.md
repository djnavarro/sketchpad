# Polygon vertices

`points` represents the vertices of a polygon as parallel `x` and `y`
coordinate vectors. Most
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
subclasses expose `points` as a computed property;
[shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md) is
the exception, where the user supplies `x`/`y` directly.

## Usage

``` r
points(x = integer(0), y = integer(0))
```

## Arguments

- x:

  Numeric vector of x coordinates.

- y:

  Numeric vector of y coordinates.
