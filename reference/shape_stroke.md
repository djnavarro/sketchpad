# A tapered, pressure-modulated stroke along an arbitrary path

`shape_stroke` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
polygon that follows an arbitrary open path through `(x, y)` control
points (resampled to `n` evenly arc-length-spaced points, unlike
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)'s
exact control-point vertices), offset into a ribbon whose width tapers
to zero at both ends and varies along its length according to a
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
– intended as a "pressure" curve, giving the outline an ink/brush-stroke
look rather than a constant-width line. It generalizes
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)
from a single straight segment to any path, at the cost of computing a
true per-point unit normal (via the internal `stroke_normals()` helper)
rather than
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)/[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)'s
shared single offset direction – necessary once the path can genuinely
curve, not just wander slightly off straight.

`shape_strokes()` is a vectorized version of `shape_stroke()`. Since
`x`/`y` are themselves numeric vectors of control points for a single
stroke, `shape_strokes()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector of control points per stroke. Every other argument may be a
plain vector, recycled against `x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). A shared
`distortion`
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
is automatically recycled across every stroke; pass a
[`list()`](https://rdrr.io/r/base/list.html) of several different
`noise_field`s instead to vary it per stroke. The result is a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) containing
one `shape_stroke()` per list element/recycled row, rather than a single
drawable.

## Usage

``` r
shape_stroke(
  x,
  y,
  width = 0.2,
  n = 100L,
  distortion = noise_field(),
  trans = trans_identity(),
  ...
)

shape_strokes(
  x,
  y,
  width = 0.2,
  n = 100L,
  distortion = noise_field(),
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  For `shape_stroke()`, numeric vectors of control point coordinates,
  the same length, with at least two control points. For
  `shape_strokes()`, a [`list()`](https://rdrr.io/r/base/list.html) of
  such vectors instead – one vector of control points per stroke.

- width:

  Maximum width. Must be non-negative. Default `0.2`.

- n:

  Number of points used along the resampled path. Must be at least `2`.
  Default `100L`.

- distortion:

  A
  [noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
  controlling the width ("pressure") modulation. Default
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

For `shape_strokes()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## Details

Unlike
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)'s
own taper (which peaks at `0.5`, an undocumented quirk of its
`sqrt(t * (1 - t))` formula), `shape_stroke`'s taper is normalized to
peak at `1` at the path's midpoint, so `width` is exactly the maximum
rendered width.

Resampling only redistributes points evenly along the control polyline's
own straight segments – it does not smooth or curve-fit sharp corners,
matching
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)'s
own no-smoothing convention. A `shape_stroke()` built from only a few
widely-spaced control points will still have visibly angular corners;
supply a denser `x`/`y` (e.g. points already sampled from some smooth
function) for a smoothly curving stroke.

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
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
draw(shape_stroke(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.3))

draw(shape_stroke(
  x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.3,
  distortion = noise_field(frequency = 3, seed = 7734L)
))


# a few widely-spaced control points give angular corners, since
# resampling redistributes points but never smooths them
draw(shape_stroke(x = c(0, 1, 0), y = c(0, 2, 0), width = 0.2))


# denser input points (already sampled from a smooth function) give a
# smoothly curving stroke instead
t <- seq(0, 2 * pi, length.out = 200)
draw(shape_stroke(x = t, y = sin(t), width = 0.15, fill = fill_charcoal()))


# layer effect_tremor() on top for a hand-drawn ink look
draw(effect_tremor(
  shape_stroke(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.2, fill_alpha = 0.4),
  layers = 4L
))


draw(shape_strokes(
  x = list(c(0, 1, 2, 3), c(0, 1, 2, 3)),
  y = list(c(0, 1, 0, 1), c(1, 2, 1, 2)),
  width = 0.3
))


# a shared distortion recycles across every stroke; width can vary too
draw(shape_strokes(
  x = list(c(0, 1, 2), c(0, 1, 2)),
  y = list(c(0, 1, 0), c(2, 3, 2)),
  width = c(0.15, 0.35)
))

```
