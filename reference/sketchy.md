# Layer jittered copies of a path drawable for a hand-drawn look

No single
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) can
express a hand-drawn ink/pencil look on its own – what reads as
"sketchy" is several independently wobbling copies of the same nominal
path layered on top of each other, not one perfectly smooth line.
`sketchy()` builds a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) of
`layers` such copies: each is constructed by calling `.f` (a drawable
constructor taking `x`/`y` control point vectors, e.g.
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)
or
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md))
with `x`/`y` displaced by smooth, seed-offset simplex noise sampled
along the path's own normalized arc-length – the same ad hoc technique
used, during development, to add a wobbling pencil edge on top of a
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md)'s
tapered outline, or to layer a plain
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)
into a sketchier-looking line by itself.

## Usage

``` r
sketchy(
  .f,
  x,
  y,
  layers = 4L,
  jitter = 0.05,
  jitter_frequency = 0.5,
  seed = 1L,
  ...
)
```

## Arguments

- .f:

  A drawable constructor taking `x`/`y` control point vectors, e.g.
  [`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)
  or
  [`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md).

- x, y:

  Numeric vectors of control point coordinates for the unperturbed path.
  Must be the same length, with at least two points.

- layers:

  Number of independently-jittered copies to layer. Must be a positive
  integer. Default `4L`.

- jitter:

  Maximum displacement amplitude applied to each layer's `x`/`y`. Must
  be non-negative. Default `0.05`.

- jitter_frequency:

  Frequency of the simplex noise driving the jitter, sampled along the
  path's normalized arc-length – lower values give a slower, smoother
  wobble; higher values a jumpier one. Must be non-negative. Default
  `0.5`.

- seed:

  Integer seed for the jitter noise. Default `1L`.

- ...:

  Additional arguments passed unchanged to every call of `.f` (e.g.
  `width`/`distortion` for
  [`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
  or `color`/`color_alpha` for either).

## Value

A [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing `layers` drawables.

## Details

Noise is sampled at each control point's own position along arc-length
(`0` to `1`), not at its raw `x`/`y` coordinates, so the jitter's shape
is independent of the path's own scale or aspect ratio – a long, shallow
path and a short, steep one with the same number of control points get
comparably-shaped wobble. Each layer's noise is seed-offset from the
last (`seed + 2 * (i - 1)` for the `x` displacement, one more for `y`,
following the same seed-offset convention
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)/`twisted_path_points()`
already use for their own independent-axis noise), so layers wobble
independently rather than moving in lockstep.

Every other drawable-specific argument (`width`/`distortion` for
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md);
`color`/`color_alpha`/`linewidth` for either) is forwarded via `...` to
every layer unchanged – `sketchy()` only varies `x`/`y` across layers,
not style. Vary `color_alpha` down and/or `layers` up for a denser, more
overlapping pencil/ink texture.

## See also

Other effects:
[`bristle_stroke()`](https://sketchpad.djnavarro.net/reference/bristle_stroke.md)

## Examples

``` r
draw(sketchy(
  curve_line,
  x = c(0, 1, 2, 3), y = c(0, 1, 0, 1),
  color_alpha = 0.4
))

draw(sketchy(
  shape_stroke,
  x = c(0, 1, 2, 3), y = c(0, 1, 0, 1),
  width = 0.3, fill_alpha = 0.5, color = NA_character_,
  layers = 3L, jitter = 0.03
))

```
