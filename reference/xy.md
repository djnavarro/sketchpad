# A set of locations in 2D space

`xy` represents a collection of locations in two-dimensional space as
parallel `x` and `y` coordinate vectors.

## Usage

``` r
xy(x = integer(0), y = integer(0))
```

## Arguments

- x:

  Numeric vector of x coordinates.

- y:

  Numeric vector of y coordinates.

## Details

Most [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
subclasses expose their geometry as a computed `points` property of
class `xy`;
[shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md) is
the exception, where the user supplies `x`/`y` directly. Named `xy`
rather than `points` so this exported constructor doesn't mask
[`graphics::points()`](https://rdrr.io/r/graphics/points.html).

## See also

Other core structure:
[`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md),
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md),
[`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md),
[`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md),
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)

## Examples

``` r
xy(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1))
#> <sketchpad::xy>
#>  @ x: num [1:4] 0 1 1 0
#>  @ y: num [1:4] 0 0 1 1
```
