# Graphical style for a drawable object

`style` is a container for the graphical properties passed to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) when a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) object
is drawn.

## Usage

``` r
style(color = "black", fill = "black", linewidth = 1)
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
