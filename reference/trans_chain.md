# A sequence of composed transforms

`trans_chain` is what `+` produces when combining transforms that can't
collapse into a single
[trans](https://sketchpad.djnavarro.net/reference/trans.md) matrix –
e.g. a
[trans_warp](https://sketchpad.djnavarro.net/reference/trans_warp.md)
with another
[trans_warp](https://sketchpad.djnavarro.net/reference/trans_warp.md),
or a
[trans_warp](https://sketchpad.djnavarro.net/reference/trans_warp.md)
mixed with a
[trans](https://sketchpad.djnavarro.net/reference/trans.md). It is not
usually constructed directly; it holds an ordered list of `steps` (each
a [trans](https://sketchpad.djnavarro.net/reference/trans.md) or
[trans_warp](https://sketchpad.djnavarro.net/reference/trans_warp.md)),
applied in sequence – `steps[[1]]` first, `steps[[length(steps)]]` last
– exactly like chained `+` calls on a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) would
suggest.

## Usage

``` r
trans_chain(steps = list())
```

## Arguments

- steps:

  A list of
  [trans](https://sketchpad.djnavarro.net/reference/trans.md)/[trans_warp](https://sketchpad.djnavarro.net/reference/trans_warp.md)/`trans_chain`
  objects.

## Details

Two consecutive
[trans](https://sketchpad.djnavarro.net/reference/trans.md) (affine)
steps are *not* automatically collapsed into one matrix when they're
already part of a chain (only a bare `trans + trans` collapses); this
only costs a little efficiency, not correctness.

## See also

Other transform helpers:
[`trans()`](https://sketchpad.djnavarro.net/reference/trans.md),
[`trans_affine()`](https://sketchpad.djnavarro.net/reference/trans_affine.md),
[`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md),
[`trans_reflect()`](https://sketchpad.djnavarro.net/reference/trans_reflect.md),
[`trans_rotate()`](https://sketchpad.djnavarro.net/reference/trans_rotate.md),
[`trans_scale()`](https://sketchpad.djnavarro.net/reference/trans_scale.md),
[`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md),
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md),
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)

## Examples

``` r
# combining an affine trans with a trans_warp produces a trans_chain,
# applied in the order given by +
chained <- trans_rotate(pi / 6) + trans_warp(amount = 0.08)
chained
#> <sketchpad::trans_chain>
#>  @ steps:List of 2
#>  .. $ : <sketchpad::trans>
#>  ..  ..@ matrix: num [1:3, 1:3] 0.866 0.5 0 -0.5 0.866 ...
#>  .. $ : <sketchpad::trans_warp>
#>  ..  ..@ amount      : num 0.08
#>  ..  ..@ distortion_x: <sketchpad::noise_field>
#>  .. .. .. @ noise    : function (x, y = NULL, z = NULL, t = NULL, frequency = 1, seed = NULL, 
#>     ...)  
#>  .. .. .. @ fractal  : function (base, new, strength, ...)  
#>  .. .. .. @ frequency: num 1
#>  .. .. .. @ octaves  : int 2
#>  .. .. .. @ seed     : int 1
#>  ..  ..@ distortion_y: <sketchpad::noise_field>
#>  .. .. .. @ noise    : function (x, y = NULL, z = NULL, t = NULL, frequency = 1, seed = NULL, 
#>     ...)  
#>  .. .. .. @ fractal  : function (base, new, strength, ...)  
#>  .. .. .. @ frequency: num 1
#>  .. .. .. @ octaves  : int 2
#>  .. .. .. @ seed     : int 2
draw(shape_rectangle(width = 1.5, height = 0.6, trans = chained))

```
