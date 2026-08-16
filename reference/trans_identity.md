# The identity transform

Returns a [trans](https://sketchpad.djnavarro.net/reference/trans.md)
that leaves points unchanged – the default `trans` for every
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

## Usage

``` r
trans_identity()
```

## See also

Other transform helpers:
[`trans()`](https://sketchpad.djnavarro.net/reference/trans.md),
[`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md),
[`trans_chain()`](https://sketchpad.djnavarro.net/reference/trans_chain.md),
[`trans_reflect()`](https://sketchpad.djnavarro.net/reference/trans_reflect.md),
[`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md),
[`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md),
[`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md),
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md),
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)

## Examples

``` r
trans_identity()
#> <sketchpad::trans>
#>  @ matrix: num [1:3, 1:3] 1 0 0 0 1 0 0 0 1

# the default trans for every drawable -- points are left unchanged
draw(shape_rectangle(width = 1.5, height = 0.6, trans = trans_identity()))

```
