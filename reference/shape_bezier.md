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
shape_bezier(x, y, n = 100L, ...)
```

## Arguments

- x, y:

  Numeric vectors of control point coordinates. Must be the same length,
  with at least two control points.

- n:

  Number of points used to sample the curve. Default `100L`.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).
