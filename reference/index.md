# Package index

## Core structure

The classes and generics that define how a sketch is built and rendered,
independent of any specific drawable.

- [`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md) : A
  collection of drawable objects
- [`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md)
  : Parent class for all drawable objects
- [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) : Draw a
  drawable or sketch
- [`point_set()`](https://sketchpad.djnavarro.net/reference/point_set.md)
  : A set of polygon vertices
- [`style()`](https://sketchpad.djnavarro.net/reference/style.md) :
  Graphical style for a drawable object

## 2D shapes

Closed, fillable `drawable`s (`geometry = "polygon"`).

- [`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md)
  : A closed Bezier curve
- [`shape_bezier_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_bezier_ribbon.md)
  : A ribbon following a Bezier curve
- [`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md)
  : An irregular, "blobby" circle
- [`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md)
  : A circle
- [`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md)
  : A polygon defined directly by its vertices
- [`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)
  : A tapered ribbon between two points
- [`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)
  : A twisted ribbon following a random path

## 1D curves

Open, stroked `drawable`s (`geometry = "path"`).

- [`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md)
  : An open Bezier curve
- [`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)
  : An open polyline
- [`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md)
  : An open path defined directly by its vertices
- [`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md)
  : A wandering scribble curve
- [`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md)
  : An open spiral
- [`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)
  : An open, wandering path following a random walk

## 0D points

Unconnected marker `drawable`s (`geometry = "points"`).

- [`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md)
  : A scatter of points defined directly by their coordinates

## Noise helpers

Scalar noise fields used to distort a shape’s points, used by
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md)/[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)/[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md).

- [`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md)
  : A sampled scalar noise field
- [`noise_bridge()`](https://sketchpad.djnavarro.net/reference/noise_bridge.md)
  : A smoothed Brownian bridge, as a path distortion
- [`noise_sample()`](https://sketchpad.djnavarro.net/reference/noise_sample.md)
  : Sample a noise object

## Fills

Textures and patterns for
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)’s `fill`
argument, used by 2D shapes.

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
