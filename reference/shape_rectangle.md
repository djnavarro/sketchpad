# A rectangle

`shape_rectangle` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
defined by a centroid and a width/height, rendered as an axis-aligned
rectangle. `shape_square()` is a thin convenience wrapper around
`shape_rectangle()` for the common case of `width == height`, taking a
single `side` argument instead – it returns a `shape_rectangle` object
directly rather than being its own class.

## Usage

``` r
shape_rectangle(
  x = 0,
  y = 0,
  width = 1,
  height = 1,
  trans = trans_identity(),
  ...
)

shape_square(x = 0, y = 0, side = 1, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- width, height:

  Rectangle dimensions. Must be non-negative. Default `1`.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the shape's computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

- side:

  Side length, for `shape_square()`. Must be non-negative. Default `1`.

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_rectangle(width = 2, height = 1))

draw(shape_square(x = 1, y = 1, side = 0.5, color = "darkred"))

```
