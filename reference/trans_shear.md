# Shear points

Applies a shear transform about the pivot `(about_x, about_y)`: `shx`
displaces x-coordinates in proportion to y (distance from `about_y`),
`shy` displaces y-coordinates in proportion to x (distance from
`about_x`).

## Usage

``` r
trans_shear(shx = 0, shy = 0, about_x = 0, about_y = 0)
```

## Arguments

- shx, shy:

  Shear factors along the x/y axes. Default `0` for both.

- about_x, about_y:

  Pivot point coordinates. Default `0`.

## See also

Other transform helpers:
[`trans()`](https://sketchpad.djnavarro.net/reference/trans.md),
[`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md),
[`trans_chain()`](https://sketchpad.djnavarro.net/reference/trans_chain.md),
[`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md),
[`trans_reflect()`](https://sketchpad.djnavarro.net/reference/trans_reflect.md),
[`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md),
[`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md),
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md),
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)

## Examples

``` r
draw(shape_square(side = 1, trans = trans_shear(shx = 0.5)))

```
