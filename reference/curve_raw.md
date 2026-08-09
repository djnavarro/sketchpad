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
curve_raw(x, y, ...)
```

## Arguments

- x:

  Numeric vector of x coordinates.

- y:

  Numeric vector of y coordinates.

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
