# A tapered ribbon between two points

`shape_ribbon` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
polygon that follows a straight line between `(x, y)` and
`(xend, yend)`, with a width that tapers at both ends and varies along
its length according to simplex noise.

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

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)

## Examples

``` r
draw(shape_ribbon(x = 0, y = 0, xend = 1, yend = 1, width = 0.3))

```
