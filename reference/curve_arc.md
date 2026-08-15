# An open arc

`curve_arc` is
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)'s
arc alone, with no centroid vertex: an open path of `n` points on the
circle centred at `(x, y)` with the given `radius`, sweeping from angle
`start` to `end` (radians). Shares its point computation and argument
validation with
[`shape_wedge()`](https://sketchpad.djnavarro.net/reference/shape_wedge.md)
via two internal helpers factored into `R/shape_wedge.R`
(`arc_points()`, `validate_arc_args()`), differing only in which
`drawable(geometry = ...)` they construct from and the missing centroid
vertex.

`curve_arcs()` is a vectorized version of `curve_arc()`: each argument
may be a vector, recycled against the others via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `curve_arc()` per recycled row, rather than a single
drawable.

## Usage

``` r
curve_arc(
  x = 0,
  y = 0,
  radius = 1,
  start = 0,
  end = pi/2,
  n = 100L,
  trans = trans_identity(),
  ...
)

curve_arcs(
  x = 0,
  y = 0,
  radius = 1,
  start = 0,
  end = pi/2,
  n = 100L,
  trans = trans_identity(),
  ...
)
```

## Arguments

- x, y:

  Centroid coordinates. Default `0`.

- radius:

  Radius. Must be non-negative. Default `1`.

- start, end:

  Start/end angle of the arc, in radians. Default `0`/ `pi / 2`.

- n:

  Number of points used to approximate the arc. Must be at least `2`.
  Default `100L`.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the shape's computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Value

A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

For `curve_arcs()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## Details

`style@fill` has no effect for `curve_arc()` – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`geometry` documentation for why `"path"` geometries have no interior to
fill. Passing `fill` via `...` is still accepted (it's simply ignored at
draw time), since
[`style()`](https://sketchpad.djnavarro.net/reference/style.md) is
shared across every `geometry`.

## See also

Other 1D curves:
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`curve_raw()`](https://sketchpad.djnavarro.net/reference/curve_raw.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)

## Examples

``` r
draw(curve_arc(start = 0, end = 3 * pi / 2))


draw(curve_arcs(start = 0, end = seq(pi / 2, 2 * pi, length.out = 3)))

```
