# A wandering scribble curve

`curve_scribble` is a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) whose
path is a single random wandering line – a random finite sum of sine
harmonics – built from the same internal `scribble_lines()` generator
that
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md)
uses to texture a tile's interior, but scaled here into an arbitrary
bounding box on the sketch's own coordinate plane rather than tiled
inside a fill pattern. Where
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md)
scatters several such lines across a repeating tile as a texture,
`curve_scribble()` draws exactly one as a standalone open curve.

## Usage

``` r
curve_scribble(
  x = 0,
  y = 0,
  width = 1,
  height = 1,
  direction = "horizontal",
  n_harmonics = 3L,
  amplitude = 0.35,
  n = 200L,
  seed = 1L,
  ...
)
```

## Arguments

- x, y:

  Coordinates of the curve's origin. Default `0`.

- width, height:

  Extent of the curve's bounding box along/across its direction of
  travel. Must be positive. Default `1`.

- direction:

  Either `"horizontal"` (the curve runs left-right) or `"vertical"`
  (top-bottom). Default `"horizontal"`.

- n_harmonics:

  Number of sine harmonics summed to build the curve. Must be a positive
  integer. Default `3L`.

- amplitude:

  Maximum total wiggle amplitude, as a fraction of `height` (for
  `direction = "horizontal"`) or `width` (for `"vertical"`), split
  across `n_harmonics`. Must be a non-negative number. Default `0.35`.

- n:

  Number of points sampled along the curve. Must be a positive integer
  of at least `2L`. Default `200L`.

- seed:

  Integer seed for the random harmonics. Default `1L`.

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Details

The underlying line is generated in `(along, across)` form, `along`
running from `0` to `1` and `across` wandering around a random baseline
near `0.5` (see `scribble_lines()`'s own details for why this particular
construction was chosen – periodicity, needed for tiling, is irrelevant
here). `x`/`y` place the curve's origin, and `width`/ `height` scale it:
for `direction = "horizontal"` (the default), `along` maps to
`x + along * width` and `across` to `y + across * height`, so the curve
runs left-to-right; for `direction = "vertical"`, the mapping swaps
(`along` maps to `y`, `across` to `x`), so the curve runs bottom-to-top
instead.

`style@fill` has no effect for `curve_scribble()` – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`geometry` documentation for why `"path"` geometries have no interior to
fill. Passing `fill` via `...` is still accepted (it's simply ignored at
draw time), since
[`style()`](https://sketchpad.djnavarro.net/reference/style.md) is
shared across every `geometry`.

## See also

Other 1D curves:
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md)

## Examples

``` r
draw(curve_scribble(width = 2, height = 0.5, seed = 5591L))

```
