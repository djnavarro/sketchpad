# A closed Bezier curve

`shape_bezier` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) whose
outline follows a Bezier curve defined by an arbitrary number of control
points (`x`, `y`). With two control points this is a straight line; with
four, a cubic Bezier of the kind used to build ribbons and other flowing
shapes. Since
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) renders
every `"polygon"`-geometry `drawable`'s `points` as a closed polygon,
the curve is implicitly closed from its last control point back to its
first – for an open Bezier curve/path instead, see
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md).

## Usage

``` r
shape_bezier(x, y, n = 100L, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  Numeric vectors of control point coordinates. Must be the same length,
  with at least two control points.

- n:

  Number of points used to sample the curve. Default `100L`.

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
[`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md),
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
draw(shape_bezier(x = c(0, 0.5, 1, 0.5), y = c(0, 1, 0, -1)))

```
