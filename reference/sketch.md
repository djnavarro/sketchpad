# A collection of drawable objects

`sketch` is a list of
[drawable](https://sketchpad.djnavarro.net/reference/drawable.md)
objects that can be rendered together with a single call to
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md). Sketches
can be built up incrementally using the `+` operator, e.g.
`sketch() + circle() + circle(x = 2)`.

## Usage

``` r
sketch(shapes = list())
```

## Arguments

- shapes:

  A list of
  [drawable](https://sketchpad.djnavarro.net/reference/drawable.md)-classed
  objects. Default [`list()`](https://rdrr.io/r/base/list.html).

## Examples

``` r
if (FALSE) { # \dontrun{
s <- sketch() + circle(radius = 1) + circle(x = 2, radius = 0.5)
draw(s)
} # }
```
