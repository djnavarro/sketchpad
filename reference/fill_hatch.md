# Diagonal hatch pattern fill

`fill_hatch()` builds a
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) fill value
that renders a repeating diagonal hatch line. It's meant to be used as
the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) (and eventually
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)'s `fill`
property), in place of a plain colour.

## Usage

``` r
fill_hatch(
  color = "black",
  angle = 45,
  spacing = 0.1,
  aspect = 1,
  linewidth = 1,
  extend = "repeat"
)
```

## Arguments

- color:

  Line colour. Default `"black"`.

- angle:

  Hatch angle in degrees, measured counterclockwise from the positive
  x-axis. Default `45`.

- spacing:

  Baseline tile size, as a fraction of the target's bounding box. Must
  be a positive number. Default `0.1`.

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- linewidth:

  Line width. Must be a positive number. Default `1`.

- extend:

  Passed to [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html).
  Default `"repeat"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) tiles are
sized as a *fraction of the target polygon's own bounding box*, not a
fixed physical square, so a tile that looks square in that relative
sense can be a stretched rectangle in absolute terms whenever the
target's bounding box isn't square itself – which distorts any angle
baked directly into the pattern content. Pass the target's bounding-box
aspect ratio (width / height) as `aspect` to correct for this; the
default `aspect = 1` is only exact for a square bounding box.

Internally, the hatch line is always drawn as a plain diagonal from one
tile corner to the opposite corner (or the mirror image, for a
negative-sloped angle) – never at an arbitrary slope baked into the
segment's own coordinates. A corner-to-corner diagonal is the only slope
that tiles seamlessly under
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html)'s
`extend = "repeat"`, which translates tile copies by whole
tile-widths/heights only; any other local slope leaves a visible
mismatch ("dashing") at every tile edge. The desired angle is instead
achieved entirely by choosing the tile's `width`/`height` ratio. Exactly
horizontal/vertical angles are handled as a special case, since a
straight (non-diagonal) line tiles seamlessly at any tile aspect ratio.

## See also

Other fill helpers:
[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md),
[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md),
[`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md),
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md),
[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md),
[`fill_image()`](https://sketchpad.djnavarro.net/reference/fill_image.md),
[`fill_marble()`](https://sketchpad.djnavarro.net/reference/fill_marble.md),
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md),
[`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md),
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)
