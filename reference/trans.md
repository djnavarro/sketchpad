# A 2D affine transformation

`trans` wraps a 3x3 homogeneous-coordinates affine transformation
matrix. It is not usually constructed directly – use
[`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md),
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md),
[`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md),
[`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md),
[`trans_reflect()`](https://sketchpad.djnavarro.net/reference/trans_reflect.md),
[`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md),
or the general-purpose
[`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md)
instead. Every
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
carries a `trans` property (default
[`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md))
that's applied to its computed `points` as the very last step – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`trans` documentation.

## Usage

``` r
trans(matrix = integer(0))
```

## Arguments

- matrix:

  A 3x3 numeric matrix in homogeneous coordinates (i.e. its third row
  must be `c(0, 0, 1)`).

## Details

Two `trans` objects combine with `+`: `t1 + t2` produces a new `trans`
whose effect is "apply `t1` first, then `t2`" – see
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md)'s
Details for the composition order convention and a worked example.
Composing a `trans` with a
[trans_warp](https://sketchpad.djnavarro.net/reference/trans_warp.md) (a
non-rigid, noise-based deformation that can't be represented as a
matrix) instead produces a
[trans_chain](https://sketchpad.djnavarro.net/reference/trans_chain.md)
– see there.

## See also

Other transform helpers:
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
trans_identity()
#> <sketchpad::trans>
#>  @ matrix: num [1:3, 1:3] 1 0 0 0 1 0 0 0 1
trans_translate(1, 0) + trans_rotate(pi / 4)
#> <sketchpad::trans>
#>  @ matrix: num [1:3, 1:3] 0.707 0.707 0 -0.707 0.707 ...

# overlay a shape's original outline (faded) with a transformed copy
# (solid) to see a trans's effect directly
original <- shape_rectangle(width = 1.5, height = 0.6, fill_alpha = 0.3, color_alpha = 0.3)
draw(sketch() + original + (original + trans_rotate(pi / 6)))

```
