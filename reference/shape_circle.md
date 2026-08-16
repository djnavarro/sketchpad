# A circle

`shape_circle` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
defined by a centroid and a radius; its vertices are computed as evenly
spaced points around the circumference.

`shape_circles()` is a vectorized version of `shape_circle()`: each
argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `shape_circle()` per recycled row, rather than a single
drawable.

## Usage

``` r
shape_circle(x = 0, y = 0, radius = 1, n = 100L, trans = trans_identity(), ...)

shape_circles(
  x = 0,
  y = 0,
  radius = 1,
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

- n:

  Number of points used to approximate the circle. Default `100L`.

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

For `shape_circles()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## See also

Other 2D shapes:
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md),
[`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md),
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_ribbonpath()`](https://sketchpad.djnavarro.net/reference/shape_ribbonpath.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_circle(radius = 1))

draw(shape_circle(x = 1, y = 1, radius = 0.5, n = 6L, color = "darkred"))

draw(shape_circle(radius = 1, fill = "steelblue", color = NA_character_))

draw(shape_circle(radius = 1, fill = fill_hatch(angle = 30)))


draw(shape_circles(x = 1:3, radius = c(0.5, 1, 1.5)))


# each argument recycles independently, so colour can vary alongside position
draw(shape_circles(
  x = cos(seq(0, 2 * pi, length.out = 9))[-9],
  y = sin(seq(0, 2 * pi, length.out = 9))[-9],
  radius = 0.3,
  fill = rep(c("tomato", "steelblue"), length.out = 8)
))

```
