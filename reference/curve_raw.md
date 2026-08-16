# An open path defined directly by its vertices

`curve_raw` is
[shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md)'s
`"path"`-geometry analog: the user supplies `x`/`y` coordinates
directly, connected by straight segments in the order given, with no
smoothing, resampling, or implicit closing edge. Unlike
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md)
(which requires at least two control points, since a single-point "line"
isn't meaningful), `curve_raw` places no minimum on `length(x)`,
matching
[shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md)'s
own leniency – it exists primarily as a `convert()` target for
"freezing" any `"path"`-geometry drawable's computed points, the same
role [shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md)
plays for `"polygon"`-geometry drawables.

`curve_raws()` is a vectorized version of `curve_raw()`. Since `x`/`y`
are themselves numeric vectors of vertex coordinates for a single path,
`curve_raws()` takes them as a
[`list()`](https://rdrr.io/r/base/list.html) of numeric vectors instead
– one vector of vertices per path. Every other argument may be a plain
vector, recycled against `x`/`y` via
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html)'s own
vctrs-based rules (any length-1 element is broadcast to the common
length; mismatched lengths greater than 1 raise an error). The result is
a [sketch](https://sketchpad.djnavarro.net/reference/sketch.md)
containing one `curve_raw()` per list element/recycled row, rather than
a single drawable.

## Usage

``` r
curve_raw(x, y, trans = trans_identity(), ...)

curve_raws(x, y, trans = trans_identity(), ...)
```

## Arguments

- x, y:

  For `curve_raw()`, a numeric vector of x/y coordinates. For
  `curve_raws()`, a [`list()`](https://rdrr.io/r/base/list.html) of such
  vectors instead – one vector of vertices per path.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the curve's computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

## Value

A [drawable](https://sketchpad.djnavarro.net/reference/drawable.md).

For `curve_raws()`, a
[sketch](https://sketchpad.djnavarro.net/reference/sketch.md).

## Details

`style@fill` has no effect for `curve_raw()` – see
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)'s
`geometry` documentation for why `"path"` geometries have no interior to
fill. Passing `fill` via `...` is still accepted (it's simply ignored at
draw time), since
[`style()`](https://sketchpad.djnavarro.net/reference/style.md) is
shared across every `geometry`.

## See also

Other 1D curves:
[`curve_arc()`](https://sketchpad.djnavarro.net/reference/curve_arc.md),
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md)

## Examples

``` r
draw(curve_raw(x = c(0, 1, 2), y = c(0, 1, 0)))


# useful for "freezing" a wandering path's own computed points
frozen <- S7::convert(
  curve_twist(x = 0, y = 0, xend = 1, yend = 0, path_distortion = noise_bridge(seed = 99L)),
  curve_raw
)
draw(frozen)


draw(curve_raws(
  x = list(c(0, 1, 2), c(2, 3, 4)),
  y = list(c(0, 1, 0), c(0, 1, 0))
))

```
