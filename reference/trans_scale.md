# Scale points

Scales points by `sx`/`sy` along the x/y axes, about the pivot
`(about_x, about_y)`.

## Usage

``` r
trans_scale(sx = 1, sy = sx, about_x = 0, about_y = 0)
```

## Arguments

- sx:

  Scale factor along the x axis. Default `1`.

- sy:

  Scale factor along the y axis. Default `sx` (a uniform scale).

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
[`trans_shear()`](https://sketchpad.djnavarro.net/reference/trans_shear.md),
[`trans_translate()`](https://sketchpad.djnavarro.net/reference/trans_translate.md),
[`trans_warp()`](https://sketchpad.djnavarro.net/reference/trans_warp.md)

## Examples

``` r
draw(shape_square(side = 1, trans = trans_scale(2)))

draw(shape_square(side = 1, trans = trans_scale(2, 0.5)))


# overlay the original (faded) with the scaled copy (solid)
original <- shape_rectangle(
  width = 1.5,
  height = 0.6,
  fill_alpha = 0.3,
  color_alpha = 0.3
)
draw(sketch() + original + (original + trans_scale(1.5, 0.7)))


# scaling about a pivot other than the shape's own centroid also moves
# it, since distance from the pivot is what gets scaled -- shown here
# against a fixed frame, with a small marker at the pivot
square <- shape_square(
  x = 1,
  side = 0.5,
  fill_alpha = 0.3,
  color_alpha = 0.3
)
pivot <- shape_circle(radius = 0.05, fill = "tomato", color = NA_character_)
draw(
  sketch() + square +
    (square + trans_scale(2, about_x = 0, about_y = 0)) +
    pivot,
  xlim = c(-3, 3), ylim = c(-3, 3)
)

```
