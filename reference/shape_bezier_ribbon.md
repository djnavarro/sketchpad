# A ribbon following a Bezier curve

`shape_bezier_ribbon` is like
[shape_ribbon](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
but its backbone follows a cubic Bezier curve through `(x, y)`, two
control points, and `(xend, yend)`, rather than a straight line – giving
the ribbon a curved rather than straight path. As with
[shape_ribbon](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
the ribbon's width tapers to zero at both ends and varies along its
length according to simplex noise.

## Usage

``` r
shape_bezier_ribbon(
  x = 0,
  y = 0,
  xend = 1,
  yend = 1,
  x_ctrl1 = 0.5,
  y_ctrl1 = 0.5,
  x_ctrl2 = 0,
  y_ctrl2 = 0,
  width = 0.2,
  n = 100L,
  distortion = noise_field(),
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Start point. Default `0`.

- xend, yend:

  End point. Default `1`.

- x_ctrl1, y_ctrl1:

  First Bezier control point. Default `0.5`.

- x_ctrl2, y_ctrl2:

  Second Bezier control point. Default `0`.

- width:

  Maximum width. Must be non-negative. Default `0.2`.

- n:

  Number of points used along the path. Default `100L`.

- distortion:

  A
  [noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
  controlling the width modulation. Default
  [`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md).

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the shape's computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_bezier_ribbon(x = 0, y = 0, xend = 1, yend = 0, width = 0.2))

```
