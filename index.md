# sketchpad

sketchpad is a lightweight drawing system for generative art, built on
[S7](https://rconsortium.github.io/S7/) classes and `grid` graphics. It
provides a small set of `drawable` shapes
([`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md))
that can be composed into a
[`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md) and
rendered with
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md).

## Installation

You can install the development version of sketchpad from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("djnavarro/sketchpad")
```

## Example

``` r

library(sketchpad)

palette <- c(
  "#e50000", "#ff8d00", "#ffee00",
  "#028121", "#004cff", "#770088"
)
draw(shape_blobs(
  x = cos(seq(0, pi * 5 / 3, length.out = 6)),
  y = sin(seq(0, pi * 5 / 3, length.out = 6)),
  n = 500L,
  fill = palette,
  color = palette
))
```

![](reference/figures/README-ring-of-blobs-1.png)
