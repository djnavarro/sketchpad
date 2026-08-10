# Solid colour fill

`fill_solid()` is the trivial member of the `fill_*()` family: a plain
colour needs no
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) machinery,
since [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html)'s `fill`
argument already accepts a colour string directly. It exists so that a
plain colour can be requested with the same `fill_*()` naming as the
pattern-based helpers (grouping them together in autocomplete), and so
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)'s `fill`
property has one uniform family of constructors to accept – including
for its own default – once it's extended to take `fill_*()` outputs
alongside a bare colour string.

## Usage

``` r
fill_solid(color = "black")
```

## Arguments

- color:

  Fill colour. Default `"black"`.

## Value

`color`, unchanged (a single string), after validating it.

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
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)

## Examples

``` r
fill_solid("steelblue")
#> [1] "steelblue"
draw(shape_circle(fill = fill_solid("tomato")))

```
