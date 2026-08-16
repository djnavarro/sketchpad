# A star

`shape_star` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
defined by a centroid and two radii: its outline alternates `n` outer
vertices (at `outer_radius`) with `n` inner vertices (at
`inner_radius`), evenly spaced by angle, giving the familiar `n`-pointed
star shape (e.g. `n = 5` a five-pointed star, `n = 6` a
Star-of-David-like hexagram outline).

`shape_stars()` is a vectorized version of `shape_star()`: each argument
may be a vector, recycled against the others. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one `shape_star()` per recycled row, rather than a single drawable.

## Usage

``` r
shape_star(
  x = 0,
  y = 0,
  outer_radius = 1,
  inner_radius = 0.5,
  n = 5L,
  trans = trans_identity(),
  ...
)

shape_stars(
  x = 0,
  y = 0,
  outer_radius = 1,
  inner_radius = 0.5,
  n = 5L,
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- outer_radius:

  Outer radius (star tips). Must be non-negative. Default `1`.

- inner_radius:

  Inner radius (between tips). Must be non-negative and no greater than
  `outer_radius`. Default `0.5`.

- n:

  Number of star points. Must be at least `2`. Default `5L`.

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

For `shape_stars()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## Details

Like
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
`points` does not repeat its first vertex at the end – there are exactly
`2 * n` distinct vertices, since
[`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html) closes
the path itself. The first vertex is an outer one at angle `0`; use
[`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md)
to reorient the star, the same way
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md)'s
own low-`n` vertices are reoriented.

`inner_radius = outer_radius` degenerates the star into a regular
`2 * n`-gon (no points), and `inner_radius = 0` collapses every inner
vertex onto the centroid, giving a sharp `n`-pointed "asterisk" outline.

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
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_strokepath()`](https://sketchpad.djnavarro.net/reference/shape_strokepath.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_star())

draw(shape_star(x = 1, y = 1, outer_radius = 0.5, n = 8, color = "darkred"))

draw(shape_star(n = 6, fill = "goldenrod"))


# a sharper star: inner_radius closer to 0
draw(shape_star(inner_radius = 0.2, fill = "steelblue"))


# rotating a star reorients its tips
draw(shape_star(n = 5, trans = trans_rotate(pi / 2)))


draw(shape_stars(x = 1:3, n = c(4L, 5L, 6L)))

draw(shape_stars(
  x = 0, y = 0, outer_radius = seq(3, 0.5, length.out = 6), n = 5,
  fill = rep(c("grey20", "grey90"), length.out = 6)
))

```
