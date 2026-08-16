# Stippled dot pattern fill

`fill_stipple()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
that scatters a handful of dots at random positions inside each tile,
using
[`withr::with_seed()`](https://withr.r-lib.org/reference/with_seed.html)
so the same `seed` always reproduces the same scatter (the same
convention used by
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
and
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)'s
noise fields).

## Usage

``` r
fill_stipple(
  color = "black",
  radius = 0.15,
  spacing = 0.3,
  aspect = 1,
  n = 4L,
  seed = 1L,
  extend = "repeat"
)
```

## Arguments

- color:

  Dot colour. Default `"black"`.

- radius:

  Dot radius, as a `"npc"` fraction of the tile. Must be a positive
  number. Default `0.15`.

- spacing:

  Baseline tile size, as a fraction of the target's bounding box. Must
  be a positive number. Default `0.3`.

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- n:

  Number of dots scattered per tile. Must be a positive integer. Default
  `4L`.

- seed:

  Integer seed for the dot positions. Default `1L`.

- extend:

  Passed to [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html).
  Default `"repeat"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

Unlike
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)/[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md),
a dot has no direction, so there's no analogue of their tile-edge
"dashing" problem here. There's still a circularity problem to correct
for, though: [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html)
tiles are sized as a fraction of the target polygon's own bounding box,
so a dot drawn with an `npc`-relative radius renders as an ellipse
whenever that bounding box isn't square. Pass the bounding box's
width-to-height ratio as `aspect` to keep dots circular; the default
`aspect = 1` is only exact for a square bounding box.

## Known rendering risk with multiple dots

On this package's development R build (4.6.1, a very recent/development
version), [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html)
tiles whose content is a *group* of several
[`grid::circleGrob()`](https://rdrr.io/r/grid/grid.circle.html)s (i.e.
`n > 1`) were found, in some cases, to render individual dots visibly
distorted – clipped into crescents or otherwise not circular – even
though each dot's own coordinates are correct and a single dot (`n = 1`)
always renders correctly. This reproduced in a fresh R session (so it
isn't specific to a long interactive session), across multiple `n` and
`radius` values, with no clean rule found for exactly when it triggers;
it appeared on both an interactive device and
[`ragg::agg_png()`](https://ragg.r-lib.org/reference/agg_png.html). No
fix or reliable workaround was found – this looks like an upstream
`grid`/Cairo issue with multi-shape pattern tile content, not something
specific to how this function builds its content. **Visually check
rendered output** before relying on `fill_stipple()` (or
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md)/
[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md),
which share this risk) for anything beyond casual use, especially on
unfamiliar R/`grid`/graphics-device versions.

## See also

Other fill helpers:
[`fill_charcoal()`](https://sketchpad.djnavarro.net/reference/fill_charcoal.md),
[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md),
[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md),
[`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md),
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md),
[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md),
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md),
[`fill_image()`](https://sketchpad.djnavarro.net/reference/fill_image.md),
[`fill_marble()`](https://sketchpad.djnavarro.net/reference/fill_marble.md),
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md),
[`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md),
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)

## Examples

``` r
draw(shape_circle(fill = fill_stipple(n = 6L, seed = 2091L)))


# more, smaller dots per tile give a denser stipple
draw(shape_circle(fill = fill_stipple(n = 15L, radius = 0.06, spacing = 0.5, seed = 2091L)))

```
