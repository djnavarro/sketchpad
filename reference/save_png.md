# Save a drawable or sketch to an image file

`save_png()`, `save_svg()`, and `save_pdf()` render a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) or
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) straight
to a raster (PNG) or vector (SVG/PDF) file, without the caller needing
to manage a
[grDevices](https://rdrr.io/r/grDevices/grDevices-package.html) device
by hand. Each is a thin wrapper: open the appropriate device, call
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md), and
always close the device afterward (via
[`on.exit()`](https://rdrr.io/r/base/on.exit.html), so a device is never
left open even if
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) itself
errors).

## Usage

``` r
save_png(object, filename, width = 7, height = 7, dpi = 300, bg = "white", ...)

save_svg(object, filename, width = 7, height = 7, bg = "white", ...)

save_pdf(object, filename, width = 7, height = 7, bg = "white", ...)
```

## Arguments

- object:

  A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md) or
  [sketch](https://sketchpad.djnavarro.net/reference/sketch.md) object.

- filename:

  A single string, the path to write to.

- width, height:

  Image dimensions in inches. Default `7`.

- dpi:

  Resolution in dots per inch. Only meaningful for `save_png()` (a
  raster format); ignored by `save_svg()`/`save_pdf()`, which are drawn
  at vector resolution. Default `300`.

- bg:

  Background colour passed to the underlying device, e.g. `"white"` (the
  default) or `"transparent"`. This is the device's own page colour,
  independent of any
  [`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md)
  `background` a `sketch` itself already carries – the two compose, so a
  transparent `bg` here still shows an opaque
  [`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md)
  background underneath, and vice versa a `sketch` with no
  [`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md)
  background shows `bg` through any of its own shapes that don't fully
  cover the page.

- ...:

  Passed on to
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md), e.g.
  `xlim`/`ylim`.

## Value

`filename`, invisibly.

## Examples

``` r
file <- tempfile(fileext = ".png")
save_png(shape_circle(radius = 1), file)

file <- tempfile(fileext = ".svg")
save_svg(shape_circle(radius = 1), file)

file <- tempfile(fileext = ".pdf")
save_pdf(shape_circle(radius = 1), file)
```
