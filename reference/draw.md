# Draw a drawable or sketch

`draw()` is a generic function that renders a
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) or
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md) object to
the current graphics device using grid. Methods accept optional
`xlim`/`ylim` arguments giving axis limits; if omitted, limits are
computed from the object's points.

## Usage

``` r
draw(object, ...)
```

## Arguments

- object:

  A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md) or
  [sketch](https://sketchpad.djnavarro.net/reference/sketch.md) object.

- ...:

  Passed to methods, e.g. `xlim`/`ylim`.

## See also

Other core structure:
[`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md),
[`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md),
[`group()`](https://sketchpad.djnavarro.net/reference/group.md),
[`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md),
[`style()`](https://sketchpad.djnavarro.net/reference/style.md),
[`xy()`](https://sketchpad.djnavarro.net/reference/xy.md)

## Examples

``` r
draw(shape_circle(radius = 1))


s <- sketch() + shape_circle(radius = 1) + shape_blob(x = 2, radius = 0.5)
draw(s)


# an explicit xlim/ylim overrides both the sketch's own canvas and the
# range of its shapes' own points, useful for zooming in/out or padding
draw(shape_circle(radius = 1), xlim = c(-2, 2), ylim = c(-2, 2))


# a non-drawable object is ignored, with a warning, rather than erroring
draw("not a drawable")
#> Warning: Non-drawable objects ignored by draw()
```
