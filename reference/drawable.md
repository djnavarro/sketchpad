# Parent class for all drawable objects

`drawable` enforces structure on its subclasses: every drawable must
carry a [style](https://sketchpad.djnavarro.net/reference/style.md) and
expose a computed
[points](https://sketchpad.djnavarro.net/reference/points.md) property.
It is not intended to be instantiated directly; use one of its
subclasses ([shape](https://sketchpad.djnavarro.net/reference/shape.md),
[circle](https://sketchpad.djnavarro.net/reference/circle.md),
[blob](https://sketchpad.djnavarro.net/reference/blob.md),
[ribbon](https://sketchpad.djnavarro.net/reference/ribbon.md),
[twist](https://sketchpad.djnavarro.net/reference/twist.md)) instead.

## Usage

``` r
drawable(...)
```

## Arguments

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).
