# A collection of drawable objects

`sketch` is a list of
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
objects that can be rendered together with a single call to
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md). Sketches
can be built up incrementally using the `+` operator, e.g.
`sketch() + shape_circle() + shape_circle(x = 2)`.

## Usage

``` r
sketch(shapes = list(), canvas = sketchpad::canvas())
```

## Arguments

- shapes:

  A list of
  [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)-classed
  objects. Default [`list()`](https://rdrr.io/r/base/list.html).

- canvas:

  A [canvas](https://sketchpad.djnavarro.net/reference/canvas.md)
  object, giving the background/framing settings
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) applies
  to the sketch as a whole. Default
  [`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md) (no
  background, axis limits computed from `shapes`).

## See also

Other core structure:
[`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md),
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md),
[`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md),
[`style()`](https://sketchpad.djnavarro.net/reference/style.md),
[`xy()`](https://sketchpad.djnavarro.net/reference/xy.md)

## Examples

``` r
s <- sketch() + shape_circle(radius = 1) + shape_circle(x = 2, radius = 0.5)
draw(s)


s2 <- sketch(canvas = canvas(background = "grey95")) + shape_circle(radius = 1)
draw(s2)

```
