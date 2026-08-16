# Build a custom affine transform

General-purpose escape hatch for an affine transform not covered by
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md)/[`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md)/[`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md)/[`trans_reflect()`](https://sketchpad.djnavarro.net/reference/trans_reflect.md)/
[`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md):
wraps a caller-supplied matrix directly.

## Usage

``` r
trans_affine(matrix)
```

## Arguments

- matrix:

  A 3x3 numeric matrix in homogeneous coordinates (its third row must be
  `c(0, 0, 1)`), or a 2x3 matrix giving only the first two rows (the
  third row is added automatically).

## See also

Other transform helpers:
[`trans()`](https://sketchpad.djnavarro.net/reference/trans.md),
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
# equivalent to trans_scale(2, 3)
trans_affine(matrix(c(2, 0, 0, 0, 3, 0, 0, 0, 1), nrow = 3, byrow = TRUE))
#> <sketchpad::trans>
#>  @ matrix: num [1:3, 1:3] 2 0 0 0 3 0 0 0 1

# the 2x3 form omits the trivial homogeneous third row
draw(shape_square(
  side = 1, trans = trans_affine(matrix(c(2, 0, 0, 0, 3, 0), nrow = 2, byrow = TRUE))
))

```
