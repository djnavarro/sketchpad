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

## Usage

``` r
curve_raw(x, y, trans = trans_identity(), ...)
```

## Arguments

- x:

  Numeric vector of x coordinates.

- y:

  Numeric vector of y coordinates.

- trans:

  A [trans](https://sketchpad.djnavarro.net/reference/trans.md) object
  applied to the curve's computed points. Default
  [`trans_identity()`](https://sketchpad.djnavarro.net/reference/trans_identity.md)
  (no transform).

- ...:

  Arguments passed to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md).

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
[`curve_arcs()`](https://sketchpad.djnavarro.net/reference/curve_arcs.md),
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md),
[`curve_beziers()`](https://sketchpad.djnavarro.net/reference/curve_beziers.md),
[`curve_line()`](https://sketchpad.djnavarro.net/reference/curve_line.md),
[`curve_lines()`](https://sketchpad.djnavarro.net/reference/curve_lines.md),
[`curve_raws()`](https://sketchpad.djnavarro.net/reference/curve_raws.md),
[`curve_scribble()`](https://sketchpad.djnavarro.net/reference/curve_scribble.md),
[`curve_scribbles()`](https://sketchpad.djnavarro.net/reference/curve_scribbles.md),
[`curve_spiral()`](https://sketchpad.djnavarro.net/reference/curve_spiral.md),
[`curve_spirals()`](https://sketchpad.djnavarro.net/reference/curve_spirals.md),
[`curve_twist()`](https://sketchpad.djnavarro.net/reference/curve_twist.md),
[`curve_twists()`](https://sketchpad.djnavarro.net/reference/curve_twists.md)

## Examples

``` r
draw(curve_raw(x = c(0, 1, 2), y = c(0, 1, 0)))

```
