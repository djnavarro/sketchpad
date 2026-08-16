# Translate points

Shifts points by `(dx, dy)`.

## Usage

``` r
trans_translate(dx = 0, dy = 0)
```

## Arguments

- dx, dy:

  Distance to shift along the x/y axes. Default `0`.

## Details

`trans` objects compose with `+`, applied left to right: `t1 + t2` means
"apply `t1`'s effect first, then `t2`'s". For example,
`trans_translate(1, 0) + trans_rotate(pi / 2)` translates a point one
unit right, then rotates the *result* a quarter turn about the origin –
not the same as `trans_rotate(pi / 2) + trans_translate(1, 0)`, which
rotates first and translates second. Internally, `(t1 + t2)@matrix` is
`t2@matrix %*% t1@matrix`, since points are homogeneous column vectors
transformed as `matrix %*% point`.

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
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)

## Examples

``` r
draw(shape_square(side = 1, trans = trans_translate(2, 0)))


# overlay the original (faded) with the translated copy (solid)
original <- shape_rectangle(width = 1.5, height = 0.6, fill_alpha = 0.3, color_alpha = 0.3)
draw(sketch() + original + (original + trans_translate(1, 0.5)))


# composition order matters: translate-then-rotate differs from
# rotate-then-translate -- a fixed xlim/ylim makes the difference in
# final position visible (a lone shape otherwise always fills its own
# auto-scaled frame)
square <- shape_square(x = 1, side = 0.4)
draw(square + trans_translate(1, 0) + trans_rotate(pi / 2), xlim = c(-1, 3), ylim = c(-1, 3))

draw(square + trans_rotate(pi / 2) + trans_translate(1, 0), xlim = c(-1, 3), ylim = c(-1, 3))

```
