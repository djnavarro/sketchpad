# A set of locations in 2D space

`xy` represents a collection of locations in two-dimensional space as
parallel `x`/`y` coordinate vectors, plus a parallel `id` vector
grouping those locations into sub-paths.

## Usage

``` r
xy(x, y, id = NULL)
```

## Arguments

- x:

  Numeric vector of x coordinates.

- y:

  Numeric vector of y coordinates.

- id:

  Integer (or integerish numeric) vector the same length as `x`/`y`,
  grouping locations into sub-paths. Default `NULL`, filled in as
  `rep(1L, length(x))` (a single sub-path).

## Details

Most [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
subclasses expose their geometry as a computed `points` property of
class `xy`;
[shape_raw](https://sketchpad.djnavarro.net/reference/shape_raw.md) is
the exception, where the user supplies `x`/`y` directly. Named `xy`
rather than `points` so this exported constructor doesn't mask
[`graphics::points()`](https://rdrr.io/r/graphics/points.html).

`id` marks which sub-path/contour each `x`/`y` location belongs to –
locations sharing the same `id` are connected into one contour; a
different `id` starts a new one. Every existing single-contour drawable
has exactly one implicit sub-path, so `id` defaults to
`rep(1L, length(x))` whenever left `NULL` (the default), meaning no
drawable's own `points` getter needs to pass `id` explicitly to keep its
current, single-contour behavior. Multiple sub-paths let a single
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md) render
as several disjoint shapes sharing one
[style](https://sketchpad.djnavarro.net/reference/style.md) (e.g. two
separate blobs), or – combined with
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)'s `rule`
– as a shape with a hole (a sub-path nested inside another). No
constructor currently exposes a way to *set* a non-trivial `id` when
building geometry by hand; this is the underlying data-shape change
alone, not yet paired with an author-facing API (see `.agents/PLAN.md`).

## See also

Other core structure:
[`canvas()`](https://sketchpad.djnavarro.net/reference/canvas.md),
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md),
[`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md),
[`sketch()`](https://sketchpad.djnavarro.net/reference/sketch.md),
[`style()`](https://sketchpad.djnavarro.net/reference/style.md)

## Examples

``` r
xy(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1))
#> <sketchpad::xy>
#>  @ x : num [1:4] 0 1 1 0
#>  @ y : num [1:4] 0 0 1 1
#>  @ id: int [1:4] 1 1 1 1

# two sub-paths: a pair of disjoint 4-point contours sharing one xy object
xy(x = c(0, 1, 1, 0, 2, 3, 3, 2), y = c(0, 0, 1, 1, 0, 0, 1, 1), id = rep(1:2, each = 4))
#> <sketchpad::xy>
#>  @ x : num [1:8] 0 1 1 0 2 3 3 2
#>  @ y : num [1:8] 0 0 1 1 0 0 1 1
#>  @ id: int [1:8] 1 1 1 1 2 2 2 2
```
