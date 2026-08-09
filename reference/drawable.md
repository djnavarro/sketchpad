# Parent class for all drawable objects

`drawable` enforces structure on its subclasses: every drawable must
carry a [style](https://sketchpad.djnavarro.net/reference/style.md) and
expose a computed `points` property, of class
[point_set](https://sketchpad.djnavarro.net/reference/point_set.md). It
is not intended to be instantiated directly; use one of its subclasses
([shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[shape_circle](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[shape_blob](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[shape_ribbon](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[shape_twist](https://sketchpad.djnavarro.net/reference/shape_twist.md))
instead.

## Usage

``` r
drawable(...)
```

## Arguments

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).
