# Parent class for all drawable objects

`drawable` enforces structure on its subclasses: every drawable must
carry a [style](https://sketchpad.djnavarro.net/reference/style.md), a
`geometry`, and expose a computed `points` property, of class
[point_set](https://sketchpad.djnavarro.net/reference/point_set.md). It
is not intended to be instantiated directly; use one of its subclasses
([shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md),
[shape_circle](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[shape_blob](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[shape_ribbon](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[shape_twist](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[curve_raw](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[points_raw](https://sketchpad.djnavarro.net/reference/points_raw.md),
...) instead.

## Usage

``` r
drawable(..., geometry = "polygon")
```

## Arguments

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

- geometry:

  One of `"polygon"` (default), `"path"`, or `"points"`. Not exposed as
  a constructor argument by any concrete drawable – each
  `shape_*()`/`curve_*()`/[`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md)
  constructor fixes one value internally instead (see details).

## Details

`geometry` tells
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) which
[grid](https://rdrr.io/r/graphics/grid.html) grob a drawable's `points`
map to, following a dimensional reading: `"points"` (0D,
[`grid::pointsGrob()`](https://rdrr.io/r/grid/grid.points.html), e.g.
[`points_raw()`](https://sketchpad.djnavarro.net/reference/points_raw.md)),
`"path"` (1D, an open
[`grid::polylineGrob()`](https://rdrr.io/r/grid/grid.lines.html), e.g.
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)/[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md)),
or `"polygon"` (2D, a closed
[`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html) – the
default, and the only value any `shape_*()` constructor uses).
`style@fill` is ignored for `"points"`/`"path"` geometries, since only a
closed polygon has an interior to fill.
