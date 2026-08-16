# Colour palette drawn from a curated collection

Selects one palette from a vendored, deduplicated copy of the manually
curated palettes at <https://github.com/djnavarro/palettes>, each
originally a 5-colour hex palette. If `n` differs from the palette's own
native length, colours are linearly interpolated to `n` colours via
[`grDevices::colorRampPalette()`](https://rdrr.io/r/grDevices/colorRamp.html).

## Usage

``` r
palette_manual(n = NULL, index = 1L)
```

## Arguments

- n:

  `NULL` (the default) or a single positive whole number: the number of
  colours to return. `NULL` returns the selected palette's own colours
  unchanged; otherwise the palette is interpolated to `n` colours.

- index:

  A single positive whole number selecting which stored palette to use.
  An out-of-range `index` errors with the valid range for the currently
  vendored data.

## Value

A character vector of `n` hex colour strings (or the selected palette's
own colours, if `n` is `NULL`).

## See also

Other palette helpers:
[`palette_cosine()`](https://sketchpad.djnavarro.net/reference/palette_cosine.md)

## Examples

``` r
palette_manual(index = 1)
#> [1] "#33658a" "#86bbd8" "#2f4858" "#f6ae2d" "#f26419"
palette_manual(n = 12, index = 1)
#>  [1] "#33658A" "#5184A6" "#6FA3C2" "#7EB0CC" "#5E869D" "#3E5C6F" "#535A50"
#>  [8] "#9B7F40" "#E3A430" "#F49927" "#F37E20" "#F26419"
```
