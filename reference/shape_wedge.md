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

`shape_wedges()` is a vectorized version of `shape_wedge()`: each
argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `shape_wedge()` per recycled row, rather than a single
drawable.

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

shape_wedges(
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

## Value

A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

For `shape_wedges()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

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
[`shape_ribbonpath()`](https://sketchpad.djnavarro.net/reference/shape_ribbonpath.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)

## Examples

``` r
draw(shape_wedge(start = 0, end = pi / 2))

draw(shape_wedge(x = 1, y = 1, radius = 0.5, start = pi, end = 2 * pi, color = "darkred"))


# a nearly-full sweep gives a pac-man-like shape; the arc always closes
# straight back to the centroid
draw(shape_wedge(start = 0, end = 1.9 * pi, fill = "goldenrod"))


draw(shape_wedges(start = 0, end = seq(pi / 2, 2 * pi, length.out = 3)))


# a pie chart: adjacent wedges sharing a centroid, one slice per value
value <- c(30, 20, 50)
cum <- c(0, cumsum(value)) / sum(value) * 2 * pi
draw(shape_wedges(
  start = cum[-length(cum)], end = cum[-1],
  fill = c("steelblue", "tomato", "goldenrod")
))

```
