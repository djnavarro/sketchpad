# A twisted ribbon following a random path

`shape_twist` is like
[shape_ribbon](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
but the underlying path is a Brownian bridge rather than a straight
line, giving the polygon a wandering, twisted appearance.

`shape_twists()` is a vectorized version of `shape_twist()`: each
argument may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one `shape_twist()` per recycled row, rather than a single drawable.

## Usage

``` r
shape_twist(
  x = 0,
  y = 0,
  xend = 1,
  yend = 1,
  width = 0.2,
  n = 100L,
  path_distortion = noise_bridge(),
  distortion = noise_field(),
  trans = trans_identity(),
  ...
)

shape_twists(
  x = 0,
  y = 0,
  xend = 1,
  yend = 1,
  width = 0.2,
  n = 100L,
  path_distortion = noise_bridge(),
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

- width:

  Maximum width. Must be non-negative. Default `0.2`.

- n:

  Number of points used along the path. Default `100L`.

- path_distortion:

  A
  [noise_bridge](https://sketchpad.djnavarro.net/reference/noise_bridge.md)
  controlling the path's Brownian bridge. Default
  [`noise_bridge()`](https://sketchpad.djnavarro.net/reference/noise_bridge.md).

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

## Value

A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

For `shape_twists()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## Details

Any length-1 element is broadcast to the common length; mismatched
lengths greater than 1 raise an error. A shared
`path_distortion`/`distortion` is automatically recycled across every
twist; pass a [`list()`](https://rdrr.io/r/base/list.html) of several
different
[noise_bridge](https://sketchpad.djnavarro.net/reference/noise_bridge.md)/[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
objects instead to vary either per twist – as in `README.Rmd`'s "Twists"
example, which gives every twist the same `path_distortion` this way.

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
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_twist(
  x = 0, y = 0, xend = 1, yend = 0, width = 0.2,
  path_distortion = noise_bridge(seed = 7734L)
))


# more smoothing passes make the Brownian bridge wander more gently;
# fewer passes leave it jumpier
draw(shape_twist(
  x = 0, y = 0, xend = 1, yend = 0, width = 0.2,
  path_distortion = noise_bridge(smooth = 20L, seed = 7734L)
))

draw(shape_twist(
  x = 0, y = 0, xend = 1, yend = 0, width = 0.2,
  path_distortion = noise_bridge(smooth = 0L, seed = 7734L)
))


draw(shape_twists(x = 1:3, y = 0, xend = 2:4, yend = 1, width = 0.2))


# every twist sharing one path_distortion gives them a family
# resemblance, as in README.Rmd's "Twists" example
draw(shape_twists(
  x = 0, y = 1:5, xend = 3, yend = 1:5, width = 0.15,
  path_distortion = noise_bridge(seed = 2020L)
))

```
