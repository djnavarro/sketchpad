# Reflect points

Flips points across a vertical and/or horizontal line through the pivot
`(about_x, about_y)`: `x = TRUE` mirrors left-right (flips the
x-coordinate), `y = TRUE` mirrors top-bottom (flips the y-coordinate).
Setting both reflects through the pivot point itself (equivalent to a
half turn, i.e. `trans_rotate(pi, about_x, about_y)`).

## Usage

``` r
trans_reflect(x = FALSE, y = FALSE, about_x = 0, about_y = 0)
```

## Arguments

- x, y:

  Whether to flip the x/y coordinate. Default `FALSE` for both (i.e. the
  identity transform).

- about_x, about_y:

  Pivot point coordinates. Default `0`.

## Details

Reflection across an arbitrary-angle line isn't exposed as a separate
argument – it composes from existing pieces instead: rotate the desired
line onto an axis, reflect, then rotate back, e.g.
`trans_rotate(-theta) + trans_reflect(y = TRUE) + trans_rotate(theta)`
reflects across a line through the origin at angle `theta`.

## See also

Other transform helpers:
[`trans()`](https://sketchpad.djnavarro.net/reference/trans.md),
[`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md),
[`trans_chain()`](https://sketchpad.djnavarro.net/reference/trans_chain.md),
[`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md),
[`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md),
[`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md),
[`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md),
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md),
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)

## Examples

``` r
draw(shape_bezier(x = c(0, 0.5, 1), y = c(0, 1, 0.2), trans = trans_reflect(x = TRUE)))

```
