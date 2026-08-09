# A polygon defined directly by its vertices

`shape` is the simplest
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md): the
user supplies `x` and `y` coordinates directly, and `points` is computed
trivially from them. It is most often produced by
[`convert()`](https://rconsortium.github.io/S7/reference/convert.html)ing
a more complex drawable (e.g. a
[blob](https://sketchpad.djnavarro.net/reference/blob.md) or
[twist](https://sketchpad.djnavarro.net/reference/twist.md)) down to its
raw vertices.

## Usage

``` r
shape(x, y, ...)
```

## Arguments

- x:

  Numeric vector of x coordinates.

- y:

  Numeric vector of y coordinates.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).
