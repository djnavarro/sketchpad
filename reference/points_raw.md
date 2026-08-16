# A scatter of points defined directly by their coordinates

`points_raw` is
[shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md)'s
`"points"`-geometry analog, and the first concrete constructor to use
`geometry = "points"` (previously reserved on the dimensional reading
`"points"`(0D)/`"path"`(1D)/`"polygon"`(2D), but with no constructor
exposing it – see `.agents/PLAN.md`). The user supplies `x`/`y`
coordinates directly, rendered as unconnected markers rather than a
connected outline or path.

`points_raws()` is a vectorized version of `points_raw()`. Since `x`/`y`
are themselves numeric vectors of point coordinates for a single
scatter, `points_raws()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector per scatter – which is most useful for giving several
distinct scatters different `style` arguments (e.g. a different `color`
each).

## Usage

``` r
points_raw(x, y, id = NULL, trans = trans_identity(), ...)

points_raws(x, y, id = NULL, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  For `points_raw()`, a numeric vector of x/y coordinates. For
  `points_raws()`, a [`list()`](https://rdrr.io/r/base/list.html) of
  such vectors instead – one vector per scatter.

- id:

  For `points_raw()`, an integer vector the same length as `x`/`y`, or
  `NULL` (the default). For `points_raws()`, a
  [`list()`](https://rdrr.io/r/base/list.html) of such vectors (or
  `NULL`s) instead, one per scatter. Inert either way – see Details.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Value

A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

For `points_raws()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## Details

`style@fill` and every line-related `style` property (`linewidth`,
`linetype`, `linejoin`, `lineend`, `linemitre`) have no effect for
`points_raw()` – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`geometry` documentation and `geometry_grob()`'s internal dispatch
(`R/draw.R`) for why a `"points"` geometry has no line to stroke and no
interior to fill. Only `style@color` is used, as the marker colour.

`id` (see [xy](https://sketchpad.djnavarro.net/reference/xy.md)'s own
`id`) is accepted and stored for consistency with
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md)/[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md)
and to round-trip through
[`convert()`](https://rconsortium.github.io/S7/reference/convert.html),
but is otherwise inert here –
[`grid::pointsGrob()`](https://rdrr.io/r/grid/grid.points.html) has no
sub-path concept, consistent with `fill` already being inert for
`"points"` geometry.

Every other argument may be a plain vector, recycled against `x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `points_raw()` per list element/recycled row, rather than
a single drawable.

## Examples

``` r
draw(points_raw(
  x = seq(0, 1, length.out = 20),
  y = sin(seq(0, 2 * pi, length.out = 20)) / 2 + 0.5,
  color = "steelblue"
))


# a random scatter, and the same points converted from a polygon's
# own outline (only style-related properties survive the round trip)
draw(points_raw(x = runif(200), y = runif(200)))

draw(S7::convert(
  shape_blob(radius = 1, distortion = noise_field(seed = 42)),
  points_raw
))


# points_raw() is pathlike, so effect_tremor() can wobble the scatter
draw(effect_tremor(
  points_raw(x = seq(0, 1, length.out = 30), y = rep(0.5, 30)),
  layers = 6L, jitter = 0.08
))


draw(points_raws(
  x = list(seq(0, 1, length.out = 10), seq(0, 1, length.out = 10)),
  y = list(rep(0.25, 10), rep(0.75, 10)),
  color = c("steelblue", "darkred")
))

```
