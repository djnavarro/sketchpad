# A pie-slice wedge

`shape_wedge` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
defined by a centroid, a radius, and a `start`/`end` angle (in radians):
its outline is the centroid, followed by `n` points along the circular
arc from `start` to `end`. `grid`'s own polygon closing then draws the
final straight edge back from the arc's last point to the centroid,
giving the familiar pie-slice/wedge shape.
[`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md)
is the arc alone, with no centroid vertex or fill.

## Usage

``` r
shape_wedge(
  x = 0,
  y = 0,
  radius = 1,
  start = 0,
  end = pi/2,
  n = 100L,
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- radius:

  Radius. Must be non-negative. Default `1`.

- start, end:

  Start/end angle of the arc, in radians. Default `0`/ `pi / 2`.

- n:

  Number of points used to approximate the arc. Must be at least `2`.
  Default `100L`.

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
[`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md),
[`shape_bezier_ribbons()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbons.md),
[`shape_beziers()`](https://sketchpad.djnavarro.net/reference/shape_beziers.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_blobs()`](https://sketchpad.djnavarro.net/reference/shape_blobs.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_circles()`](https://sketchpad.djnavarro.net/reference/shape_circles.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_ellipses()`](https://sketchpad.djnavarro.net/reference/shape_ellipses.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_polygons()`](https://sketchpad.djnavarro.net/reference/shape_polygons.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_raws()`](https://sketchpad.djnavarro.net/reference/shape_raws.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_rectangles()`](https://sketchpad.djnavarro.net/reference/shape_rectangles.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_ribbons()`](https://sketchpad.djnavarro.net/reference/shape_ribbons.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_twists()`](https://sketchpad.djnavarro.net/reference/shape_twists.md),
[`shape_wedges()`](https://sketchpad.djnavarro.net/reference/shape_wedges.md)

## Examples

``` r
draw(shape_wedge(start = 0, end = pi / 2))

draw(shape_wedge(x = 1, y = 1, radius = 0.5, start = pi, end = 2 * pi, color = "darkred"))

```
