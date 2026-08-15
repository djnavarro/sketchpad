# Rotate points

Rotates points by `angle` radians (counterclockwise for positive angles)
about the pivot `(about_x, about_y)`.

## Usage

``` r
trans_rotate(angle, about_x = 0, about_y = 0)
```

## Arguments

- angle:

  Rotation angle, in radians.

- about_x, about_y:

  Pivot point coordinates. Default `0`.

## See also

Other transform helpers:
[`trans()`](https://sketchpad.djnavarro.net/reference/trans.md),
[`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md),
[`trans_chain()`](https://sketchpad.djnavarro.net/reference/trans_chain.md),
[`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md),
[`trans_reflect()`](https://sketchpad.djnavarro.net/reference/trans_reflect.md),
[`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md),
[`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md),
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md),
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)

## Examples

``` r
draw(shape_square(side = 1, trans = trans_rotate(pi / 4)))

```
