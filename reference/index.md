# Package index

## Core structure

The classes and generics that define how a sketch is built and rendered,
independent of any specific drawable.

- [`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md) : A
  collection of drawable objects
- [`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md) :
  Canvas settings for a sketch
- [`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md)
  : Parent class for all drawable objects
- [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) : Draw a
  drawable or sketch
- [`xy()`](https://sketchpad.djnavarro.net/reference/xy.md) : A set of
  locations in 2D space
- [`style()`](https://sketchpad.djnavarro.net/reference/style.md) :
  Graphical style for a drawable object

## Two-dimensional shapes

Closed, fillable `drawable`s (`geometry = "polygon"`).

- [`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md)
  [`shape_beziers()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md)
  : A closed Bezier curve
- [`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md)
  [`shape_blobs()`](https://sketchpad.djnavarro.net/reference/shape_blob.md)
  : An irregular, "blobby" circle
- [`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md)
  [`shape_circles()`](https://sketchpad.djnavarro.net/reference/shape_circle.md)
  : A circle
- [`shape_ellipse()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md)
  [`shape_ellipses()`](https://sketchpad.djnavarro.net/reference/shape_ellipse.md)
  : An ellipse
- [`shape_polygon()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md)
  [`shape_polygons()`](https://sketchpad.djnavarro.net/reference/shape_polygon.md)
  : A regular polygon
- [`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md)
  [`shape_raws()`](https://sketchpad.djnavarro.net/reference/shape_raw.md)
  : A polygon defined directly by its vertices
- [`shape_rectangle()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md)
  [`shape_square()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md)
  [`shape_rectangles()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md)
  [`shape_squares()`](https://sketchpad.djnavarro.net/reference/shape_rectangle.md)
  : A rectangle
- [`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)
  [`shape_ribbons()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)
  : A tapered ribbon between two points
- [`shape_ribbonpath()`](https://sketchpad.djnavarro.net/reference/shape_ribbonpath.md)
  [`shape_ribbonpaths()`](https://sketchpad.djnavarro.net/reference/shape_ribbonpath.md)
  : A ribbon following an arbitrary curve
- [`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md)
  [`shape_strokes()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md)
  : A tapered, pressure-modulated stroke along an arbitrary path
- [`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)
  [`shape_twists()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)
  : A twisted ribbon following a random path
- [`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)
  [`shape_wedges()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)
  : A pie-slice wedge

## One-dimensional curves

Open, stroked `drawable`s (`geometry = "path"`).

- [`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md)
  [`curve_arcs()`](https://sketchpad.djnavarro.net/reference/curve_arc.md)
  : An open arc
- [`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md)
  [`curve_beziers()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md)
  : An open Bezier curve
- [`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)
  [`curve_lines()`](https://sketchpad.djnavarro.net/reference/curve_line.md)
  : An open polyline
- [`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md)
  [`curve_raws()`](https://sketchpad.djnavarro.net/reference/curve_raw.md)
  : An open path defined directly by its vertices
- [`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md)
  [`curve_scribbles()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md)
  : A wandering scribble curve
- [`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md)
  [`curve_spirals()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md)
  : An open spiral
- [`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)
  [`curve_twists()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)
  : An open, wandering path following a random walk

## Zero-dimensional points

Unconnected marker `drawable`s (`geometry = "points"`).

- [`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md)
  [`points_raws()`](https://sketchpad.djnavarro.net/reference/points_raw.md)
  : A scatter of points defined directly by their coordinates

## Noise tools

Scalar noise fields used to distort a shape’s points, used by
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md)/[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)/[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md).

- [`noise_bridge()`](https://sketchpad.djnavarro.net/reference/noise_bridge.md)
  : A smoothed Brownian bridge, as a path distortion
- [`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md)
  : A sampled scalar noise field
- [`noise_sample()`](https://sketchpad.djnavarro.net/reference/noise_sample.md)
  : Sample a noise object

## Fill tools

Textures and patterns for
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)’s `fill`
argument, used by 2D shapes.

- [`fill_charcoal()`](https://sketchpad.djnavarro.net/reference/fill_charcoal.md)
  : Charcoal/marker-style noise texture fill
- [`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md)
  : Checkerboard pattern fill
- [`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md)
  : Crosshatch pattern fill
- [`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md)
  : Domain-warped noise texture fill
- [`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md)
  : Gradient fill
- [`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md)
  : Halftone dot pattern fill
- [`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)
  : Diagonal hatch pattern fill
- [`fill_image()`](https://sketchpad.djnavarro.net/reference/fill_image.md)
  : User-supplied raster image fill
- [`fill_marble()`](https://sketchpad.djnavarro.net/reference/fill_marble.md)
  : Marbled, veined texture fill
- [`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)
  : Simplex/fractal noise texture fill
- [`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md)
  : Unfilled (transparent) fill
- [`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md)
  : Scattered-shape pattern fill
- [`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md)
  : Wandering-line scribble texture fill
- [`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md)
  : Solid colour fill
- [`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)
  : Stippled dot pattern fill
- [`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md)
  : Striped pattern fill
- [`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)
  : Vignette fill

## Transformation tools

Transformations applied to a `drawable`’s computed `points`, used by
every `drawable`’s `trans` property.

- [`trans()`](https://sketchpad.djnavarro.net/reference/trans.md) : A 2D
  affine transformation
- [`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md)
  : Build a custom affine transform
- [`trans_chain()`](https://sketchpad.djnavarro.net/reference/trans_chain.md)
  : A sequence of composed transforms
- [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  : The identity transform
- [`trans_reflect()`](https://sketchpad.djnavarro.net/reference/trans_reflect.md)
  : Reflect points
- [`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md)
  : Rotate points
- [`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md)
  : Scale points
- [`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md)
  : Shear points
- [`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md)
  : Translate points
- [`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)
  : A non-rigid, noise-based deformation

## Effects tools

Helpers that compose several drawables together for a particular visual
effect, rather than constructing a single drawable.

- [`effect_bristle()`](https://sketchpad.djnavarro.net/reference/effect_bristle.md)
  : A fanned bristle/dry-brush effect along a path
- [`effect_grain()`](https://sketchpad.djnavarro.net/reference/effect_grain.md)
  : A paper-grain/textured-ink rendering of a drawable's own outline
- [`effect_tremor()`](https://sketchpad.djnavarro.net/reference/effect_tremor.md)
  : Layer jittered copies of a drawable for a hand-drawn look

## Palette tools

Functions returning a plain character vector of colours, for use in
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)’s
`color`/`fill` arguments or any `fill_*()` helper’s own colour vector.

- [`palette_cosine()`](https://sketchpad.djnavarro.net/reference/palette_cosine.md)
  : Colour palette from a linear cosine formula
- [`palette_manual()`](https://sketchpad.djnavarro.net/reference/palette_manual.md)
  : Colour palette drawn from a curated collection
