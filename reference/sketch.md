# A collection of drawable objects

`sketch` is a list of
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
objects that can be rendered together with a single call to
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md). Sketches
can be built up incrementally using the `+` operator, e.g.
`sketch() + shape_circle() + shape_circle(x = 2)`.

## Usage

``` r
sketch(shapes = list(), canvas = sketchpad::canvas())
```

## Arguments

- shapes:

  A list of
  [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)-classed
  objects. Default [`list()`](https://rdrr.io/r/base/list.html).

- canvas:

  A [canvas](https://sketchpad.djnavarro.net/reference/canvas.md)
  object, giving the background/framing settings
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) applies
  to the sketch as a whole. Default
  [`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md) (no
  background, axis limits computed from `shapes`).

## Details

A sketch also supports list-like access to its shapes: `length(s)`
counts them, `s[[i]]` returns the single
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) at
position `i`, and `s[i]` returns a new sketch containing only the
selected shapes (its `canvas` is preserved) – mirroring how `[[`/`[`
differ on a plain list.

## See also

Other core structure:
[`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md),
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md),
[`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md),
[`style()`](https://sketchpad.djnavarro.net/reference/style.md),
[`xy()`](https://sketchpad.djnavarro.net/reference/xy.md)

## Examples

``` r
s <- sketch() + shape_circle(radius = 1) + shape_circle(x = 2, radius = 0.5)
draw(s)


s2 <- sketch(canvas = canvas(background = "grey95")) + shape_circle(radius = 1)
draw(s2)


length(s)
#> [1] 2
s[[1]]
#> <sketchpad::shape_circle>
#>  @ style   : <sketchpad::style>
#>  .. @ color      : chr "black"
#>  .. @ fill       : chr "black"
#>  .. @ linewidth  : num 1
#>  .. @ linetype   : chr "solid"
#>  .. @ linejoin   : chr "round"
#>  .. @ lineend    : chr "round"
#>  .. @ linemitre  : num 10
#>  .. @ color_alpha: num 1
#>  .. @ fill_alpha : num 1
#>  @ geometry: chr "polygon"
#>  @ trans   : <sketchpad::trans>
#>  .. @ matrix: num [1:3, 1:3] 1 0 0 0 1 0 0 0 1
#>  @ points  : <sketchpad::xy>
#>  .. @ x: num [1:100] 1 0.998 0.992 0.982 0.968 ...
#>  .. @ y: num [1:100] 0 0.0634 0.1266 0.1893 0.2511 ...
#>  @ x       : num 0
#>  @ y       : num 0
#>  @ radius  : num 1
#>  @ n       : int 100
s[1]
#> <sketchpad::sketch>
#>  @ shapes:List of 1
#>  .. $ : <sketchpad::shape_circle>
#>  ..  ..@ style   : <sketchpad::style>
#>  .. .. .. @ color      : chr "black"
#>  .. .. .. @ fill       : chr "black"
#>  .. .. .. @ linewidth  : num 1
#>  .. .. .. @ linetype   : chr "solid"
#>  .. .. .. @ linejoin   : chr "round"
#>  .. .. .. @ lineend    : chr "round"
#>  .. .. .. @ linemitre  : num 10
#>  .. .. .. @ color_alpha: num 1
#>  .. .. .. @ fill_alpha : num 1
#>  ..  ..@ geometry: chr "polygon"
#>  ..  ..@ trans   : <sketchpad::trans>
#>  .. .. .. @ matrix: num [1:3, 1:3] 1 0 0 0 1 0 0 0 1
#>  ..  ..@ points  : <sketchpad::xy>
#>  .. .. .. @ x: num [1:100] 1 0.998 0.992 0.982 0.968 ...
#>  .. .. .. @ y: num [1:100] 0 0.0634 0.1266 0.1893 0.2511 ...
#>  ..  ..@ x       : num 0
#>  ..  ..@ y       : num 0
#>  ..  ..@ radius  : num 1
#>  ..  ..@ n       : int 100
#>  @ canvas: <sketchpad::canvas>
#>  .. @ background: chr NA
#>  .. @ xlim      : NULL
#>  .. @ ylim      : NULL
#>  .. @ clip      : logi FALSE
```
