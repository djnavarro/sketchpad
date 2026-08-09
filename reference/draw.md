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
[`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md),
[`point_set()`](https://sketchpad.djnavarro.net/reference/point_set.md),
[`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md),
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)
