# A polygon defined directly by its vertices

`shape_raw` is the simplest
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md): the
user supplies `x` and `y` coordinates directly, and `points` is computed
trivially from them. It is most often produced by
[`convert()`](https://rconsortium.github.io/S7/reference/convert.html)ing
a more complex drawable (e.g. a
[shape_blob](https://sketchpad.djnavarro.net/reference/shape_blob.md) or
[shape_twist](https://sketchpad.djnavarro.net/reference/shape_twist.md))
down to its raw vertices.

## Usage

``` r
shape_raw(x, y, ...)
```

## Arguments

- x:

  Numeric vector of x coordinates.

- y:

  Numeric vector of y coordinates.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)

## Examples

``` r
draw(shape_raw(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1)))

```
