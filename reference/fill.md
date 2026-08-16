# A resolved or auto-resolving fill value

`fill` is the common representation stored in
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)'s `fill`
property and
[`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md)'s
`background` property: a `value` (a plain colour string, or the
`GridPattern` output of a `fill_*()` pattern/ gradient helper) plus an
optional `resolve` function. `resolve`, when present, is called with the
real target's own bounding-box aspect ratio at
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) time to
rebuild `value` with the correct tile shape – see the internal
`resolvable_fill()`/`resolve_fill()` helpers (`R/fill.R`), and
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)'s
own `aspect` argument docs for the problem this solves. `resolve` is
`NULL` whenever a helper's `aspect` was supplied explicitly (a fixed
aspect, never automatically recomputed) or for a fill with no
aspect-dependence at all
([`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md)).

## Usage

``` r
fill(value = "black", resolve = NULL)
```

## Arguments

- value:

  A plain colour string, or a `GridPattern` object (the output of
  [`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), as returned
  by every `fill_*()` helper besides
  [`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md)/[`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md)).
  Default `"black"`.

- resolve:

  `NULL`, or a function of one argument (`aspect`) rebuilding `value`
  for a newly-known target aspect ratio. Default `NULL`.

## Details

Not usually constructed directly – every `fill_*()` helper already
returns one, and
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)/[`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md)
coerce a bare colour string or `GridPattern` into one automatically (via
the internal `as_fill()` helper) if passed directly.

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
[`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md),
[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md),
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md),
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)
