# Layer jittered copies of a drawable for a hand-drawn look

`effect_tremor()` builds a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) of
`layers` such copies: each is a copy of `object` (via
[`S7::set_props()`](https://rconsortium.github.io/S7/reference/props.html))
with its `x`/`y` displaced by smooth, seed-offset simplex noise sampled
along the path's own normalized arc-length.

## Usage

``` r
effect_tremor(
  object,
  layers = 4L,
  jitter = 0.05,
  jitter_frequency = 0.5,
  seed = 1L
)
```

## Arguments

- object:

  A pathlike
  [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
  (`@pathlike == TRUE`, see
  [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
  docs), e.g.
  [`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
  [`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
  [`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md).
  Every other property is preserved unchanged across layers.

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

## Value

A [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing `layers` drawables.

## Details

No single
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) can
express a hand-drawn ink/pencil look on its own – what reads as
hand-drawn is several independently wobbling copies of the same nominal
path layered on top of each other, not one perfectly smooth line. This
is the same ad hoc technique used, during development, to add a wobbling
pencil edge on top of a
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md)'s
tapered outline, or to layer a plain
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)
into a shakier-looking line by itself.

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

Because each layer is built with
[`S7::set_props()`](https://rconsortium.github.io/S7/reference/props.html)
from `object` itself, every other property – style, `width`/`distortion`
for a
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md),
`trans`, ... – carries over unchanged; `effect_tremor()` only varies
`x`/`y` across layers. Vary `color_alpha` down and/or `layers` up (on
`object` and via the `layers` argument, respectively) for a denser, more
overlapping pencil/ink texture.

## See also

Other effects:
[`effect_bristle()`](https://sketchpad.djnavarro.net/reference/effect_bristle.md),
[`effect_grain()`](https://sketchpad.djnavarro.net/reference/effect_grain.md)

## Examples

``` r
template <- curve_line(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1))
faded <- curve_line(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), color_alpha = 0.4)

# before: a single crisp line
draw(template)


# after: several jittered, faded copies read as hand-drawn
draw(effect_tremor(faded))


draw(effect_tremor(
  shape_stroke(
    x = c(0, 1, 2, 3), y = c(0, 1, 0, 1),
    width = 0.3, fill_alpha = 0.5, color = NA_character_
  ),
  layers = 3L, jitter = 0.03
))


# more layers and higher jitter give a denser, shakier scribble
draw(effect_tremor(faded, layers = 10L, jitter = 0.15))

```
