# Combine several drawables into one multi-sub-path shape

`shape_combine()` merges the computed `points` of several
polygon-geometry drawables into a single
[shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md), one
sub-path per input (see
[xy](https://sketchpad.djnavarro.net/reference/xy.md)'s own `id`). This
is the ergonomic entry point for the two motivating multi-sub-path use
cases – a shape with a hole (one input nested inside another, under
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)'s
default `rule = "evenodd"`), or several disjoint shapes sharing one
[style](https://sketchpad.djnavarro.net/reference/style.md) – without
computing `id` by hand the way
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md)'s
own `id` argument requires.

## Usage

``` r
shape_combine(..., style = NULL)
```

## Arguments

- ...:

  Two or more polygon-geometry
  [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
  objects (`@geometry == "polygon"`, e.g.
  [`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
  [`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md)).

- style:

  A [style](https://sketchpad.djnavarro.net/reference/style.md) object
  for the combined shape, or `NULL` (the default) to reuse the first
  input's own `style`. Every input's own style besides the one that's
  kept is discarded – a `drawable` has exactly one `style`; several
  independently-styled shapes should use a
  [sketch](https://sketchpad.djnavarro.net/reference/sketch.md) instead.

## Value

A [shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md).

## Details

Each input's own already-computed `points` (i.e. `trans`/noise-based
distortion already applied, the same way
[`convert()`](https://rconsortium.github.io/S7/reference/convert.html)
"bakes in" a drawable's transform) becomes one or more sub-paths in the
combined output – an input that already has multiple sub-paths of its
own (e.g. the output of an earlier `shape_combine()` call) keeps them
all, renumbered to stay distinct from every other input's own sub-paths.
Whether nested sub-paths render as a hole or a second solid region is
purely a function of their geometric nesting and `style@rule` (see
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)'s own
docs) – not of argument order, and not of anything `shape_combine()`
itself decides.

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
[`shape_star()`](https://sketchpad.djnavarro.net/reference/shape_star.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_strokepath()`](https://sketchpad.djnavarro.net/reference/shape_strokepath.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)

## Examples

``` r
# a ring with a hole: a smaller circle nested inside a larger one
draw(shape_combine(
  shape_circle(radius = 2),
  shape_circle(radius = 1),
  style = style(fill = "steelblue")
))


# several disjoint blobs sharing one style
draw(shape_combine(
  shape_blob(x = 0, distortion = noise_field(seed = 1L)),
  shape_blob(x = 3, distortion = noise_field(seed = 2L)),
  shape_blob(x = 6, distortion = noise_field(seed = 3L)),
  style = style(fill = "goldenrod")
))


# combining a hole with a disjoint extra shape in one call
draw(shape_combine(
  shape_circle(x = 0, radius = 2),
  shape_circle(x = 0, radius = 1),
  shape_circle(x = 4, radius = 0.5)
))

```
