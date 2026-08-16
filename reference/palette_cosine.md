# Colour palette from a linear cosine formula

Generates a smoothly varying colour palette using the linear cosine
formula described by Iñigo Quilez for procedural palettes (see
<https://blog.djnavarro.net/posts/2025-09-14_cosine-palettes/>):
\$\$f(t) = a + b \cos(2 \pi (c t + d))\$\$ where \\a = (0.5, 0.5, 0.5)\\
is fixed and \\b\\, \\c\\, \\d\\ are each an RGB triple sampled (with
replacement) from `base`.

## Usage

``` r
palette_cosine(n, base = NULL, seed = 1L)
```

## Arguments

- n:

  A single positive whole number: the number of colours to generate.

- base:

  `NULL` (the default) or a character vector of candidate colours to
  sample `b`, `c`, and `d` from. `NULL` uses
  `grDevices::colors(distinct = TRUE)`.

- seed:

  A single whole number seeding the random sampling of `b`, `c`, and
  `d`, so the same `seed` always produces the same palette.

## Value

A character vector of `n` hex colour strings.

## Details

As in the source algorithm, resulting values are clamped only on the
high end (values above 1 are capped at 1); values below 0 are folded
back with [`abs()`](https://rdrr.io/r/base/MathFun.html) rather than
clamped to 0. This is an intentional quirk inherited from the source
algorithm, not a bug – it occasionally produces a colour "reflected"
around black rather than a flat black.

## See also

Other palette helpers:
[`palette_manual()`](https://sketchpad.djnavarro.net/reference/palette_manual.md)

## Examples

``` r
palette_cosine(n = 16, seed = 11)
#>  [1] "#7F1616" "#6F1A17" "#362A20" "#22442F" "#8A6642" "#F18A5A" "#FFAD74"
#>  [8] "#FFCB8F" "#FFE0A9" "#FFE9C0" "#FFE6D3" "#AAD6E1" "#40BDE8" "#1F9CE9"
#> [15] "#6377E3" "#7F54D6"
```
