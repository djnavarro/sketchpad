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


# overlay the original (faded) with the rotated copy (solid)
original <- shape_rectangle(
  width = 1.5,
  height = 0.6,
  fill_alpha = 0.3,
  color_alpha = 0.3
)
draw(sketch() + original + (original + trans_rotate(pi / 6)))


# rotating about a pivot away from the shape's own centroid sweeps it
# around that point instead -- shown here against a fixed frame, with
# a small marker at the pivot
square <- shape_square(
  x = 2,
  side = 0.5,
  fill_alpha = 0.3,
  color_alpha = 0.3
)
pivot <- shape_circle(radius = 0.05, fill = "tomato", color = NA_character_)
draw(
  sketch() + square +
    (square + trans_rotate(pi / 2, about_x = 0, about_y = 0)) +
    pivot,
  xlim = c(-2.5, 2.5), ylim = c(-2.5, 2.5)
)

```
