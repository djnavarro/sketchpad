# A non-rigid, noise-based deformation

`trans_warp` displaces each point by simplex/fractal noise sampled at
the point's own `(x, y)` position (domain warping), giving a wobbly,
non-rigid distortion rather than an affine map.

## Usage

``` r
trans_warp(
  amount = 0.1,
  distortion_x = noise_field(),
  distortion_y = noise_field(seed = distortion_x@seed + 1L)
)
```

## Arguments

- amount:

  Displacement amplitude. Must be non-negative. Default `0.1`.

- distortion_x:

  A
  [noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
  controlling the x displacement. Default
  [`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md).

- distortion_y:

  A
  [noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
  controlling the y displacement. Default `distortion_x`, with its seed
  offset by `1`.

## Details

Unlike [trans](https://sketchpad.djnavarro.net/reference/trans.md)
(translate/rotate/scale/reflect/shear), this can't be represented as a
single matrix, since the displacement varies smoothly but irregularly
from point to point.

The x and y displacements are sampled from two independent
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)s
(`distortion_x`/`distortion_y`), each rescaled to `[-1, 1]` and
multiplied by `amount`. By default `distortion_y` reuses
`distortion_x`'s own settings with its seed offset by `1`, so the two
axes wander independently without the caller needing to specify two full
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
objects – the same convention `twisted_path_points()` uses internally
for
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)'s
path.

Like [trans](https://sketchpad.djnavarro.net/reference/trans.md), a
`trans_warp` is attached to a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) via
its `trans` property/argument, and composes with `+` – combining it with
another `trans_warp` or a
[trans](https://sketchpad.djnavarro.net/reference/trans.md) produces a
[trans_chain](https://sketchpad.djnavarro.net/reference/trans_chain.md),
since a non-rigid warp can't collapse into a single matrix.

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
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md)

## Examples

``` r
draw(shape_circle(radius = 1, n = 200, trans = trans_warp(amount = 0.15)))


# a smaller amount gives a subtler wobble; distortion_x's own frequency
# controls how quickly the warp varies across space
draw(shape_circle(radius = 1, n = 200, trans = trans_warp(amount = 0.03)))

draw(shape_circle(
  radius = 1, n = 200,
  trans = trans_warp(amount = 0.1, distortion_x = noise_field(frequency = 4))
))

```
