# Scattered-shape pattern fill

`fill_scatter()` generalizes
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md):
instead of a fixed dot, it scatters copies of an arbitrary small
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) –
rendered with its own `style` (colour, fill, linewidth), which may
itself be another `fill_*()` pattern – at random positions inside each
tile, using
[`withr::with_seed()`](https://withr.r-lib.org/reference/with_seed.html)
for reproducibility exactly as
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)
does.

## Usage

``` r
fill_scatter(
  unit = shape_circle(radius = 1),
  n = 6L,
  size = 0.2,
  spacing = 1,
  aspect = 1,
  seed = 1L,
  extend = "repeat"
)
```

## Arguments

- unit:

  A small
  [drawable](https://sketchpad.djnavarro.net/reference/drawable.md) to
  scatter copies of. Default `shape_circle(radius = 1)`.

- n:

  Number of copies scattered per tile. Must be a positive integer.
  Default `6L`.

- size:

  `unit`'s rescaled size, as a `"npc"` fraction of the tile. Must be a
  number strictly between `0` and `1`. Default `0.2`.

- spacing:

  Tile size, as a fraction of the target's bounding box. Must be a
  positive number. Default `1` (one tile spans the whole shape, since
  `spacing < 1` risks the tiling distortion described above).

- aspect:

  Width-to-height ratio of the target polygon's bounding box. Must be a
  positive number. Default `1` (a square bounding box).

- seed:

  Integer seed for the scatter positions. Default `1L`.

- extend:

  Passed to [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html).
  Default `"repeat"`.

## Value

A pattern object as returned by
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), suitable for
use as the `fill` argument to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).

## Details

`unit`'s own points are rescaled (preserving its own aspect ratio) to a
bounding box of size `size` and re-centred at each scattered position;
its absolute coordinates, position, and radius/width/etc. don't matter,
only its shape.

This needed two corrections neither
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)'s
circles nor
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md)'s/[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md)'s
rectangles did:

- Every other `fill_*()` helper's tile-squaring correction
  (`height = spacing * aspect`, keeping the tile physically square) was,
  by itself, enough to keep circular/rectangular content correctly
  proportioned. Arbitrary polygon content does not get the same
  treatment: empirically, a
  [`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html) (or
  [`grid::pathGrob()`](https://rdrr.io/r/grid/grid.path.html)) used as
  pattern content renders as though it inherits the *target's own,
  uncorrected* bounding-box distortion directly, regardless of the
  tile-squaring correction applied around it – confirmed by testing a
  hand-built circular polygon side by side with an equivalent
  [`grid::circleGrob()`](https://rdrr.io/r/grid/grid.circle.html) in the
  same corrected tile: the circle stayed circular, the polygon became an
  ellipse. So `fill_scatter()` applies a second, explicit correction
  directly to `unit`'s own vertex x-coordinates (dividing by `aspect`)
  on top of the usual tile-squaring.

- Repeated (tiled) polygon content can render with visible clipping
  artifacts on Cairo devices – confirmed interactively: a single stamp,
  comfortably inside its tile's margins, rendered as a clean shape when
  the tile spans the whole target (`spacing = 1`, so `extend = "repeat"`
  is present but never actually exercised within the visible, clipped
  area) but as a "bitten" partial shape once `spacing < 1` made the
  device actually tile multiple copies. This matches
  [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html)'s own
  documented warning that "on Cairo devices, use of clipping in the
  pattern definition should be avoided because it is very likely to
  result in distortion of the pattern tile." Circles/rectangles/rasters
  didn't show this in the rest of the family, but arbitrary polygon
  geometry did. `spacing` therefore defaults to `1` here (one tile spans
  the whole shape, scattering all `n` copies across it at once) rather
  than the smaller, densely-tiled defaults used elsewhere; setting
  `spacing < 1` is still possible for a repeating scattered motif, but
  may show this distortion. (Later testing on
  [`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)
  found the same *actually-repeated tile with multiple shapes*
  combination distorts circleGrob content too, not just polygons – see
  its "Known rendering risk" section. A single tile with multiple
  shapes, as used by this function's default, was never observed to have
  the problem; only real repetition, `spacing < 1`, was.)

## See also

Other fill helpers:
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
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)

## Examples

``` r
draw(shape_circle(
  fill = fill_scatter(unit = shape_circle(radius = 1), n = 8L, size = 0.15)
))

```
