# Canvas settings for a sketch

`canvas` bundles the settings
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) applies to
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md) as a
whole, before drawing any of its shapes: a `background` fill and an
optional fixed `xlim`/`ylim` frame. It plays the same role for `sketch`
that [`style()`](https://sketchpad.djnavarro.net/reference/style.md)
plays for a single
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) – a
small, reusable settings object, validated independently and stored as a
property (`sketch`'s own `canvas`) rather than a flat list of arguments.

## Usage

``` r
canvas(background = NA_character_, xlim = NULL, ylim = NULL, clip = FALSE)
```

## Arguments

- background:

  Background fill, drawn beneath every shape in the sketch. Either a
  plain colour string, or the output of a `fill_*()` helper – see
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md)'s
  `fill` argument for the full family. Default
  [`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md)
  (no background drawn; the page's own background shows through,
  matching
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md)'s
  behavior before `canvas` existed).

- xlim, ylim:

  Fixed axis limits, each a numeric vector of length 2, or `NULL` (the
  default) to compute them from the sketch's own shapes at draw time, as
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) already
  did before `canvas` existed. An explicit `xlim`/`ylim` passed to
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) itself
  always takes precedence over these.

- clip:

  Whether to clip content to `xlim`/`ylim`. Must be a single logical.
  Default `FALSE` – see Details.

## Details

`xlim`/`ylim` only fix the coordinate *scale*
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) maps onto
the page – they do not, by themselves, clip content that falls outside
that range; a shape wider than its sketch's `canvas` still renders in
full, spilling past the frame, exactly as passing `xlim`/`ylim` to
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) directly
already behaves. This is a deliberate default: shapes built from a
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)/[noise_bridge](https://sketchpad.djnavarro.net/reference/noise_bridge.md)
(e.g.
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md))
can have somewhat unpredictable extents, and silently cropping part of
one away is a worse failure mode than a visibly overflowing shape, which
is an obvious cue to adjust the sketch's parameters. Set `clip = TRUE`
to opt into hard clipping at `xlim`/`ylim` instead – most useful once
`background` is also set to something other than
[`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md),
since an opaque background otherwise has visible content bleeding past
its own edge onto the bare page. `clip` has no visible effect when
`xlim`/`ylim` are both left `NULL`, since
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) then
computes them from the sketch's own shapes, which by construction never
exceed that range.

## See also

Other core structure:
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md),
[`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md),
[`point_set()`](https://sketchpad.djnavarro.net/reference/point_set.md),
[`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md),
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)

## Examples

``` r
canvas()
#> <sketchpad::canvas>
#>  @ background: chr NA
#>  @ xlim      : NULL
#>  @ ylim      : NULL
#>  @ clip      : logi FALSE
canvas(background = "grey90")
#> <sketchpad::canvas>
#>  @ background: chr "grey90"
#>  @ xlim      : NULL
#>  @ ylim      : NULL
#>  @ clip      : logi FALSE
canvas(background = "white", xlim = c(-2, 2), ylim = c(-2, 2), clip = TRUE)
#> <sketchpad::canvas>
#>  @ background: chr "white"
#>  @ xlim      : num [1:2] -2 2
#>  @ ylim      : num [1:2] -2 2
#>  @ clip      : logi TRUE
```
