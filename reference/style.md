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
  linemitre = 10,
  rule = "evenodd",
  color_alpha = 1,
  fill_alpha = 1
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

- rule:

  Fill rule used when a drawable's own `points` has more than one
  sub-path (see [xy](https://sketchpad.djnavarro.net/reference/xy.md)'s
  `id`), forwarded to
  [`grid::pathGrob()`](https://rdrr.io/r/grid/grid.path.html)'s own
  `rule` argument. One of `"evenodd"` (default) or `"winding"`.
  `"evenodd"` fills a region if it's enclosed by an odd number of
  sub-paths, regardless of each sub-path's own vertex winding direction
  – a sub-path nested inside another becomes a hole purely from
  geometric nesting, with no need to get vertex order right by hand,
  which is why it's the default. `"winding"` instead fills based on net
  signed winding number, which depends on each sub-path's own direction
  – only useful for constructions that specifically need that
  direction-sensitive behavior. Has no effect on a drawable with only
  one implicit sub-path (every current `shape_*()`/`curve_*()`
  constructor), since both rules agree there.

- color_alpha:

  Stroke opacity, applied to `color` independently of `fill_alpha`. Must
  be a number in `[0, 1]`, where `0` is fully transparent and `1` (the
  default) is fully opaque. Applied by baking the value into `color` via
  [`grDevices::adjustcolor()`](https://rdrr.io/r/grDevices/adjustcolor.html)
  at draw time (see
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md)'s
  internal `apply_alpha()` helper), not via
  [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html)'s own `alpha`
  argument – `gpar()`'s `alpha` applies uniformly to both stroke and
  fill on the same grob, which would couple `color_alpha` and
  `fill_alpha` together. If `color` already has its own alpha channel
  (e.g. an `"#RRGGBBAA"` hex string), `color_alpha` multiplies through
  it rather than overriding it.

- fill_alpha:

  Fill opacity, applied to `fill` independently of `color_alpha`, via
  the same
  [`grDevices::adjustcolor()`](https://rdrr.io/r/grDevices/adjustcolor.html)
  mechanism as `color_alpha`. Must be a number in `[0, 1]`. Default `1`.
  Only has an effect when `fill` is a plain colour string (as from
  [`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md)
  or
  [`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md))
  – **silently inert when `fill` is a pattern or gradient** (the output
  of any other `fill_*()` helper), since
  [`grDevices::adjustcolor()`](https://rdrr.io/r/grDevices/adjustcolor.html)
  has no defined effect on a `GridPattern` object. This mirrors `fill`
  itself already having no effect for `"path"`/`"points"`-geometry
  drawables (see
  [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
  `geometry` docs), and `lineend`/`linemitre` already being inert for
  some geometries – geometry- or fill-type-conditional inertness, not an
  error, is this package's existing convention for style properties that
  don't universally apply.

## See also

Other core structure:
[`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md),
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md),
[`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md),
[`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md),
[`xy()`](https://sketchpad.djnavarro.net/reference/xy.md)

## Examples

``` r
style(color = "steelblue", fill = "lightblue", linewidth = 2)
#> <sketchpad::style>
#>  @ color      : chr "steelblue"
#>  @ fill       : chr "lightblue"
#>  @ linewidth  : num 2
#>  @ linetype   : chr "solid"
#>  @ linejoin   : chr "round"
#>  @ lineend    : chr "round"
#>  @ linemitre  : num 10
#>  @ rule       : chr "evenodd"
#>  @ color_alpha: num 1
#>  @ fill_alpha : num 1
style(fill = fill_hatch(angle = 30))
#> <sketchpad::style>
#>  @ color      : chr "black"
#>  @ fill       :List of 9
#>  .. $ f     :function ()  
#>  .. $ x     : 'simpleUnit' num 0.5npc
#>  ..  ..- attr(*, "unit")= int 0
#>  .. $ y     : 'simpleUnit' num 0.5npc
#>  ..  ..- attr(*, "unit")= int 0
#>  .. $ width : 'simpleUnit' num 0.0866npc
#>  ..  ..- attr(*, "unit")= int 0
#>  .. $ height: 'simpleUnit' num 0.05npc
#>  ..  ..- attr(*, "unit")= int 0
#>  .. $ hjust : num 0.5
#>  .. $ vjust : num 0.5
#>  .. $ extend: chr "repeat"
#>  .. $ group : logi TRUE
#>  .. - attr(*, "class")= chr [1:2] "GridTilingPattern" "GridPattern"
#>  @ linewidth  : num 1
#>  @ linetype   : chr "solid"
#>  @ linejoin   : chr "round"
#>  @ lineend    : chr "round"
#>  @ linemitre  : num 10
#>  @ rule       : chr "evenodd"
#>  @ color_alpha: num 1
#>  @ fill_alpha : num 1

# linejoin/linemitre are most visible on a thick-stroked shape with a
# sharp vertex
star <- shape_polygon(n = 5, radius = 1, fill = "white")
draw(shape_stroke(
  x = star@points@x, y = star@points@y, width = 0.25,
  linejoin = "mitre", linemitre = 1.5
))


# color_alpha/fill_alpha control stroke/fill opacity independently
draw(shape_circle(
  radius = 1, color = "black", fill = "tomato",
  color_alpha = 1, fill_alpha = 0.3, linewidth = 3
))


# lineend only affects a path's free endpoints, not a closed polygon
draw(curve_line(
  x = c(0, 1, 2), y = c(0, 1, 0), linewidth = 15, lineend = "square"
))

```
