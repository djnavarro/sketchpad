# Unfilled (transparent) fill

`fill_none()` leaves a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
interior entirely unfilled, while still stroking its outline (per
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)'s
`color`/`linewidth`). It's a thin, self-documenting wrapper around
`fill_solid(NA_character_)`: `NA` is already a valid colour to
[`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) (rendered as fully
transparent), but spelling that out as `fill_none()` reads more clearly
at a call site than a bare `NA_character_`, and groups discoverably with
the rest of the `fill_*()` family.

## Usage

``` r
fill_none()
```

## Value

`NA_character_`.

## Details

Since every
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) is
currently rendered as a closed
[`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html) (see
the "Deferred: open/stroked curve support" item in `.agents/PLAN.md`),
`fill_none()` gives an unfilled *closed* outline – the edge connecting
the last point back to the first is still drawn. It does not, by itself,
produce an open/unstroked curve.

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
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)

## Examples

``` r
draw(shape_circle(fill = fill_none(), linewidth = 2))


# still a closed outline: the edge from the last point back to the
# first is drawn even though the interior isn't filled
draw(shape_polygon(n = 5L, fill = fill_none(), color = "steelblue", linewidth = 3))

```
