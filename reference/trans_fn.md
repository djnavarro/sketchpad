# An arbitrary-function, non-rigid deformation

`trans_fn` is the general-purpose escape hatch for a non-rigid
deformation not covered by
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)'s
noise-driven domain warping: it wraps a caller-supplied displacement
function directly, the same relationship
[`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md)
has to the rigid `trans_*()` family.

## Usage

``` r
trans_fn(fn = function() NULL)
```

## Arguments

- fn:

  A function taking two numeric vectors (`x`, `y`) and returning a
  `list(x = ..., y = ...)` of the same length.

## Details

`fn` is called as `fn(x, y)`, where `x`/`y` are a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s own
computed points (already flattened to plain numeric vectors, not an
[xy](https://sketchpad.djnavarro.net/reference/xy.md) object), and must
return a `list(x = ..., y = ...)` of the same length – checked at
draw/apply time (not at construction), since `fn`'s own behavior can't
be verified without calling it. This makes `trans_fn` strictly more
general than
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md):
any noise-based warp could be expressed as a `trans_fn` closing over a
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md),
but also deterministic formulas (a swirl, pinch, or bulge) or a warp
driven by something
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
can't express at all, e.g. a second drawable's own geometry captured in
`fn`'s enclosing environment.

Like
[trans_warp](https://sketchpad.djnavarro.net/reference/trans_warp.md),
this can't be represented as a single matrix, so composing it with a
[trans](https://sketchpad.djnavarro.net/reference/trans.md) or another
non-rigid deformation with `+` produces a
[trans_chain](https://sketchpad.djnavarro.net/reference/trans_chain.md)
rather than collapsing.

## See also

Other transform helpers:
[`trans()`](https://sketchpad.djnavarro.net/reference/trans.md),
[`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md),
[`trans_chain()`](https://sketchpad.djnavarro.net/reference/trans_chain.md),
[`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md),
[`trans_reflect()`](https://sketchpad.djnavarro.net/reference/trans_reflect.md),
[`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md),
[`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md),
[`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md),
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md),
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)

## Examples

``` r
# a deterministic swirl: rotate each point by an angle that grows with
# its own distance from the origin. A shape centred at the origin
# (e.g. a plain shape_circle()) is rotationally symmetric about it, so
# every point shares the same distance and the swirl just rotates the
# whole shape rigidly -- offsetting the shape away from the origin
# gives points at varying distances instead, showing the effect
swirl <- function(x, y) {
  r <- sqrt(x^2 + y^2)
  theta <- atan2(y, x) + r * 1.5
  list(x = r * cos(theta), y = r * sin(theta))
}
draw(shape_circle(x = 1, radius = 0.4, n = 200, trans = trans_fn(swirl)))


# a bulge: points near the origin are pushed outward more than points
# far from it. Offsetting the shape away from the origin (for the same
# reason as the swirl example above) means one side sits closer to the
# origin than the other, so the bulge dents that side outward more
bulge <- function(x, y) {
  r <- sqrt(x^2 + y^2)
  scale_factor <- 1 + 0.6 * exp(-4 * r^2)
  list(x = x * scale_factor, y = y * scale_factor)
}
draw(shape_circle(x = 0.8, radius = 0.5, n = 200, trans = trans_fn(bulge)))


# combining a trans_fn with a trans (or a trans_warp) produces a
# trans_chain, applied in the order given by +
draw(shape_circle(
  x = 0.8, radius = 0.5, n = 200,
  trans = trans_fn(bulge) + trans_rotate(pi / 6)
))

```
