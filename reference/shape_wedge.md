# A pie-slice wedge or annulus segment

`shape_wedge` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
defined by a centroid, a radius, and a `start`/`end` angle (in radians):
its outline is the centroid, followed by `n` points along the circular
arc from `start` to `end`.

`shape_wedges()` is a vectorized version of `shape_wedge()`: each
argument may be a vector, recycled against the others. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one `shape_wedge()` per recycled row, rather than a single drawable.

## Usage

``` r
shape_wedge(
  x = 0,
  y = 0,
  radius = 1,
  inner_radius = 0,
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
  inner_radius = 0,
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

- inner_radius:

  Inner radius. Must be non-negative and no greater than `radius`.
  Default `0` (a pie-slice wedge, i.e. no inner arc; see Details for the
  ring-slice/annulus-segment shape a positive value gives instead).

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

## Details

`grid`'s own polygon closing then draws the final straight edge back
from the arc's last point to the centroid, giving the familiar
pie-slice/wedge shape.
[`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md)
is the arc alone, with no centroid vertex or fill.

`inner_radius` (default `0`) turns the pie slice into a ring slice (an
annulus segment): when greater than `0`, the centroid vertex is dropped
entirely, and the outline instead traces the outer arc from `start` to
`end` followed by a second, inner arc of radius `inner_radius` swept
back from `end` to `start` – `grid`'s own polygon closing then draws the
final straight edge back to the outer arc's first point, giving a
four-sided (two arcs, two straight radial edges) ring-slice outline
rather than a pie slice's three-sided one (two straight edges meeting at
the centroid, one arc). `inner_radius = 0` (the default) recovers the
original pie-slice outline exactly, since a zero-radius "inner arc"
would otherwise degenerate to the centroid repeated `n` times.

Recycling uses
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules: any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error.

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_combine()`](https://sketchpad.djnavarro.net/reference/shape_combine.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_star()`](https://sketchpad.djnavarro.net/reference/shape_star.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_strokepath()`](https://sketchpad.djnavarro.net/reference/shape_strokepath.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)

## Examples

``` r
draw(shape_wedge(start = 0, end = pi / 2))

draw(shape_wedge(
  x = 1,
  y = 1,
  radius = 0.5,
  start = pi,
  end = 2 * pi,
  color = "darkred"
))


# a nearly-full sweep gives a pac-man-like shape; the arc always closes
# straight back to the centroid
draw(shape_wedge(start = 0, end = 1.9 * pi, fill = "goldenrod"))


# inner_radius > 0 gives a ring slice (annulus segment) instead of a
# pie slice -- no centroid vertex, a hole in the middle
draw(shape_wedge(
  radius = 1, inner_radius = 0.6, start = 0, end = 1.5 * pi,
  fill = "steelblue"
))


# a full sweep (start = 0, end = 2 * pi) with inner_radius > 0 gives a
# complete ring/annulus
draw(shape_wedge(radius = 1, inner_radius = 0.7, start = 0, end = 2 * pi))


draw(shape_wedges(start = 0, end = seq(pi / 2, 2 * pi, length.out = 3)))


# a pie chart: adjacent wedges sharing a centroid, one slice per value
value <- c(30, 20, 50)
cum <- c(0, cumsum(value)) / sum(value) * 2 * pi
draw(shape_wedges(
  start = cum[-length(cum)], end = cum[-1],
  fill = c("steelblue", "tomato", "goldenrod")
))


# a donut chart: the same idea, with inner_radius > 0
draw(shape_wedges(
  inner_radius = 0.5,
  start = cum[-length(cum)], end = cum[-1],
  fill = c("steelblue", "tomato", "goldenrod")
))

```
