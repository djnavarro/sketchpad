# A sampled scalar noise field

`noise_field` bundles the settings needed to sample a scalar-valued
noise field from ambient at arbitrary `(x, y)` positions: which base
noise function and fractal combinator to use
([`ambient::fracture()`](https://ambient.data-imaginist.com/reference/fracture.html)'s
`noise`/`fractal` arguments), how coarse or fine the field is
(`frequency`), how many octaves of detail to layer (`octaves`), and
which `seed` to draw from.

## Usage

``` r
noise_field(
  noise = ambient::gen_simplex,
  fractal = ambient::fbm,
  frequency = 1,
  octaves = 2L,
  seed = 1L
)
```

## Arguments

- noise:

  A noise-generating function, passed to
  [`ambient::fracture()`](https://ambient.data-imaginist.com/reference/fracture.html)'s
  `noise` argument (e.g.
  [`ambient::gen_simplex()`](https://ambient.data-imaginist.com/reference/noise_simplex.html),
  [`ambient::gen_perlin()`](https://ambient.data-imaginist.com/reference/noise_perlin.html),
  [`ambient::gen_worley()`](https://ambient.data-imaginist.com/reference/noise_worley.html)).
  Default
  [`ambient::gen_simplex()`](https://ambient.data-imaginist.com/reference/noise_simplex.html).

- fractal:

  A fractal combinator function, passed to
  [`ambient::fracture()`](https://ambient.data-imaginist.com/reference/fracture.html)'s
  `fractal` argument (e.g.
  [`ambient::fbm()`](https://ambient.data-imaginist.com/reference/fbm.html),
  [`ambient::billow()`](https://ambient.data-imaginist.com/reference/billow.html)).
  Default
  [`ambient::fbm()`](https://ambient.data-imaginist.com/reference/fbm.html).

- frequency:

  Noise frequency. Must be non-negative. Default `1`.

- octaves:

  Number of noise octaves. Must be a positive integer. Default `2L`.

- seed:

  Integer seed for the noise field. Default `1L`.

## Details

[`noise_sample()`](https://sketchpad.djnavarro.net/reference/noise_sample.md)
evaluates a `noise_field` at a set of positions and rescales the result
into a target range – the operation shared by
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md)'s
radius perturbation and
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md)/
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md)'s
width modulation, factored out here so it isn't duplicated across those
three constructors, and so the noise/fractal functions themselves are
configurable rather than hardcoded to
[`ambient::gen_simplex()`](https://ambient.data-imaginist.com/reference/noise_simplex.html)/[`ambient::fbm()`](https://ambient.data-imaginist.com/reference/fbm.html).

## See also

Other noise helpers:
[`noise_bridge()`](https://sketchpad.djnavarro.net/reference/noise_bridge.md),
[`noise_sample()`](https://sketchpad.djnavarro.net/reference/noise_sample.md)

## Examples

``` r
noise_field(frequency = 2, octaves = 3L, seed = 4821L)
#> <sketchpad::noise_field>
#>  @ noise    : function (x, y = NULL, z = NULL, t = NULL, frequency = 1, seed = NULL, 
#>     ...)  
#>  @ fractal  : function (base, new, strength, ...)  
#>  @ frequency: num 2
#>  @ octaves  : int 3
#>  @ seed     : int 4821

# a noise_field's effect is easiest to see through a drawable that
# samples it -- lower frequency gives broad, gentle undulation, higher
# frequency a bumpier, more textured one
draw(shape_blob(
  radius = 1,
  range = 0.4,
  distortion = noise_field(frequency = 0.5, seed = 4821L)
))

draw(shape_blob(
  radius = 1,
  range = 0.4,
  distortion = noise_field(frequency = 6, seed = 4821L)
))


# more octaves layer finer detail on top of the base frequency
draw(shape_blob(
  radius = 1,
  range = 0.4,
  distortion = noise_field(octaves = 6L, seed = 4821L)
))

```
