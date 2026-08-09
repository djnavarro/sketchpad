# Graphical style for a drawable object

`style` is a container for the graphical properties passed to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) when a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) object
is drawn.

## Usage

``` r
style(
  color = "black",
  fill = "black",
  linewidth = 1,
  linetype = "solid",
  linejoin = "round",
  lineend = "round",
  linemitre = 10
)
```

## Arguments

- color:

  Stroke colour. Default `"black"`.

- fill:

  Fill colour or pattern. Either a plain colour string, or the output of
  a `fill_*()` helper –
  [`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
  [`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md),
  [`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md),
  [`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md),
  [`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
  [`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md),
  [`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md),
  or
  [`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md).
  Default `fill_solid("black")` (i.e. `"black"`).

- linewidth:

  Line width. Default `1`.

- linetype:

  Line dash pattern, forwarded to
  [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html)'s `lty`. Either a
  named type (`"solid"`, `"dashed"`, `"dotted"`, `"dotdash"`,
  `"longdash"`, `"twodash"`, `"blank"`), an integer code `0:6`, or a
  custom hex dash-pattern string (e.g. `"13"`) – see
  [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) and
  [`graphics::par()`](https://rdrr.io/r/graphics/par.html)'s `lty` for
  the full set of accepted forms, which aren't independently
  re-validated here. Default `"solid"`.

- linejoin:

  Line join style at each vertex, forwarded to
  [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html)'s `linejoin`. One
  of `"round"`, `"mitre"`, or `"bevel"`. Most visible on closed shapes
  with few, sharp vertices, or on any drawable stroked with a thick
  `linewidth`. Default `"round"`.

- lineend:

  Line end style at a path's free endpoints, forwarded to
  [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html)'s `lineend`. One of
  `"round"`, `"butt"`, or `"square"`. Only visible on `"path"`-geometry
  drawables (e.g.
  [`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
  [`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md))
  – a `"polygon"`-geometry drawable has no free endpoint, since its
  outline closes back on itself. Most visible at a thick `linewidth`.
  Default `"round"`.

- linemitre:

  Mitre limit, forwarded to
  [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html)'s `linemitre`. Only
  takes effect when `linejoin = "mitre"`: at a vertex sharper than this
  limit allows, the mitred corner is truncated to a bevel instead, to
  avoid an arbitrarily long spike. Must be at least `1`. Default `10`,
  matching [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html)'s own
  default.

## See also

Other core structure:
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md),
[`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md),
[`point_set()`](https://sketchpad.djnavarro.net/reference/point_set.md),
[`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md)
