# A fanned bristle/dry-brush effect along a path

`bristle_stroke()` builds a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) of
`n_bristles` thin
[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md)s,
fanned out perpendicular to a backbone path – like
[`sketchy()`](https://sketchpad.djnavarro.net/reference/sketchy.md), no
single drawable can express this by itself, since a dry-brush look comes
from several independently-frayed, independently wobbling strands laid
side by side, not one stroke. Each bristle:

## Usage

``` r
bristle_stroke(
  x,
  y,
  n_bristles = 9L,
  spread = 0.3,
  width = 0.05,
  width_jitter = 0.3,
  fray = 0.15,
  jitter = 0.015,
  jitter_frequency = 1.2,
  n = 100L,
  distortion = noise_field(),
  seed = 1L,
  ...
)
```

## Arguments

- x, y:

  Numeric vectors of control point coordinates for the backbone path.
  Must be the same length, with at least two points.

- n_bristles:

  Number of bristles to fan out. Must be a positive integer. Default
  `9L`.

- spread:

  Total perpendicular distance the bristles fan across, centred on the
  backbone. Must be non-negative. Default `0.3`.

- width:

  Base bristle width, before per-bristle `width_jitter` scaling. Must be
  non-negative. Default `0.05`.

- width_jitter:

  Fractional random variation applied to each bristle's own `width`
  (e.g. `0.3` scales width by a factor drawn uniformly from
  `[0.7, 1.3]`). Must be in `[0, 1)`. Default `0.3`.

- fray:

  Maximum fraction of the backbone's own length randomly trimmed from
  each bristle's start and end. Must be in `[0, 0.5)`. Default `0.15`.

- jitter, jitter_frequency:

  Passed to
  [`sketchy()`](https://sketchpad.djnavarro.net/reference/sketchy.md)'s
  own arguments of the same name, controlling each bristle's independent
  wobble. Defaults `0.015`/`1.2`.

- n:

  Number of points used along each bristle's resampled path. Must be at
  least `2`. Default `100L`.

- distortion:

  A
  [noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
  controlling each bristle's own width ("pressure") modulation, as in
  [`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md).
  Default
  [`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md).

- seed:

  Integer seed for the per-bristle randomization and wobble. Default
  `1L`.

- ...:

  Additional arguments passed unchanged to every bristle's
  [`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md)
  (e.g. `fill`/`fill_alpha`/`color`).

## Value

A [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing `n_bristles` drawables.

## Details

- is offset from the backbone by a fixed perpendicular distance (via the
  same per-point unit normal
  [`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md)
  itself uses, `stroke_normals()`), evenly spaced across `spread`;

- is trimmed to a random sub-range of the backbone's own length (`fray`
  controls how much), so bristles start/end raggedly rather than in one
  clean line – the same "frayed edge" a real brush's outer bristles show
  as it runs dry;

- has its own randomly-scaled `width` (via `width_jitter`); and

- is independently wobbled via
  [`sketchy()`](https://sketchpad.djnavarro.net/reference/sketchy.md)
  (`layers = 1L`, since the fanning here already does the layering work
  [`sketchy()`](https://sketchpad.djnavarro.net/reference/sketchy.md)
  normally provides – one wobbling copy per bristle position, not
  several wobbling copies of one path).

[`shape_stroke()`](https://sketchpad.djnavarro.net/reference/shape_stroke.md)'s
own taper-to-zero at both ends does double duty as each bristle's tip
fade, needing no extra work here. Randomization (fray range, width
scaling) is scoped per bristle with
[`withr::with_seed()`](https://withr.r-lib.org/reference/with_seed.html),
the same reproducibility convention
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)/[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md)/[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md)
already use, so it never leaks into the caller's global random state.

## See also

Other effects:
[`sketchy()`](https://sketchpad.djnavarro.net/reference/sketchy.md)

## Examples

``` r
t <- seq(0, 8, length.out = 200)
draw(bristle_stroke(
  x = t, y = sin(t) * 1.2,
  n_bristles = 11L, spread = 0.3, width = 0.06,
  fill = "black", fill_alpha = 0.4, color = NA_character_
))

```
