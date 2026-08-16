# Parent class for all drawable objects

`drawable` enforces structure on its subclasses: every drawable must
carry a [style](https://sketchpad.djnavarro.net/reference/style.md), a
`geometry`, and expose a computed `points` property, of class
[xy](https://sketchpad.djnavarro.net/reference/xy.md). It is not
intended to be instantiated directly; use one of its subclasses
([shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[shape_circle](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[shape_blob](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[shape_ribbon](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[shape_twist](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[curve_raw](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[points_raw](https://sketchpad.djnavarro.net/reference/points_raw.md),
...) instead.

## Usage

``` r
drawable(..., geometry = "polygon", trans = trans_identity(), pathlike = FALSE)
```

## Arguments

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

- geometry:

  One of `"polygon"` (default), `"path"`, or `"points"`. Not exposed as
  a constructor argument by any concrete drawable – each
  `shape_*()`/`curve_*()`/[`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md)
  constructor fixes one value internally instead (see details).

- trans:

  A
  [trans](https://sketchpad.djnavarro.net/reference/trans.md)/[trans_warp](https://sketchpad.djnavarro.net/reference/trans_warp.md)/[trans_chain](https://sketchpad.djnavarro.net/reference/trans_chain.md)
  object. See details.

- pathlike:

  A single `TRUE`/`FALSE` (default `FALSE`). Not exposed as a
  constructor argument by any concrete drawable – each fixes its own
  value internally, the same convention `geometry` follows. See details.

## Details

`geometry` tells
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) which
[grid](https://rdrr.io/r/graphics/grid.html) grob a drawable's `points`
map to, following a dimensional reading: `"points"` (0D,
[`grid::pointsGrob()`](https://rdrr.io/r/grid/grid.points.html), e.g.
[`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md)),
`"path"` (1D, an open
[`grid::polylineGrob()`](https://rdrr.io/r/grid/grid.lines.html), e.g.
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)/[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md)),
or `"polygon"` (2D, a closed
[`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html) – the
default, and the only value any `shape_*()` constructor uses).
`style@fill` is ignored for `"points"`/`"path"` geometries, since only a
closed polygon has an interior to fill.

`trans` is a [trans](https://sketchpad.djnavarro.net/reference/trans.md)
(an affine map:
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md),
[`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md),
[`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md),
[`trans_reflect()`](https://sketchpad.djnavarro.net/reference/trans_reflect.md),
[`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md),
[`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md)),
a [trans_warp](https://sketchpad.djnavarro.net/reference/trans_warp.md)
(a non-rigid, noise-based deformation), or a
[trans_chain](https://sketchpad.djnavarro.net/reference/trans_chain.md)
combining several via `+`, applied to a drawable's computed `points` as
the very last step – after any shape-specific geometry (and, for
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md)/[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)/
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
any noise-based distortion) has already been computed. This means a
drawable's own defining parameters (e.g.
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md)'s
centroid/radius) are never mutated or flattened by a transform – only
the final rendered coordinates are affected. Default
[`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
(no transform).

`pathlike` marks whether `x`/`y` (where present) hold a genuine,
caller-ordered, perturbable control-point path – as opposed to `x`/`y`
meaning something else entirely (e.g.
[`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md)'s
centroid, or one fixed endpoint of
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)'s
two-point segment). This is the distinction
[`effect_tremor()`](https://sketchpad.djnavarro.net/reference/effect_tremor.md)/[`effect_bristle()`](https://sketchpad.djnavarro.net/reference/effect_bristle.md)
need to decide whether jittering `x`/`y` produces a meaningful wobble;
it's orthogonal to `geometry` – a `pathlike` drawable can have any
`geometry` (a future `points_*()` constructor could reasonably be
`pathlike` despite `geometry == "points"`). Currently `TRUE` for
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
and
[`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md);
`FALSE` (the default) for every other concrete drawable, including
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)/[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)/
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)
– these do have a conceptual backbone, but it's exposed via
`x`/`y`/`xend`/`yend` (or additional named control-point pairs), not a
plain `x`/`y` vector. Whether a `pathlike` subclass actually has `x`/`y`
properties is not enforced by `drawable`'s own validator – every
subclass constructor first builds a scaffold `drawable()` instance
(validated on its own, before any subclass property exists) and only
merges in `x`/`y` afterward via
[`S7::new_object()`](https://rconsortium.github.io/S7/reference/new_class.html),
so a cross-property check here would fire on that scaffold and reject
every `pathlike` subclass unconditionally (see "Gotchas"). Setting
`pathlike = TRUE` on a subclass with no `x`/`y` is therefore an author
error caught only when an effect tries to read `object@x`/`object@y`,
not at construction time.

## See also

Other core structure:
[`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md),
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md),
[`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md),
[`style()`](https://sketchpad.djnavarro.net/reference/style.md),
[`xy()`](https://sketchpad.djnavarro.net/reference/xy.md)

## Examples

``` r
circ <- shape_circle(radius = 1)
S7::S7_inherits(circ, drawable)
#> [1] TRUE

# geometry controls which grob draw() builds: a closed outline, an open
# stroke, or unconnected markers
draw(shape_circle(radius = 1, n = 8L))

draw(curve_line(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), linewidth = 3))

draw(points_raw(x = runif(30), y = runif(30)))


# trans applies after a shape's own geometry/distortion is computed, so
# shape_rectangle()'s centroid/width/height stay fixed -- only the final
# rendered corners rotate
draw(shape_rectangle(
  width = 1.5,
  height = 0.5,
  trans = trans_rotate(pi / 6)
))

```
