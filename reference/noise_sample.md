# Sample a noise object

`noise_sample()` evaluates a noise object at a set of positions and
returns the (typically rescaled) sampled values.

## Usage

``` r
noise_sample(field, ...)
```

## Arguments

- field:

  A noise object, e.g. one built by
  [`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md).

- ...:

  Passed to the method for `field`'s class.

## Value

A numeric vector.

## Details

It is an S7 generic dispatching on `field`; each concrete noise class
implements its own method, since what "a position" means differs by
class – a
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
is sampled at arbitrary `(x, y)` coordinates in the plane, matching
[`ambient::fracture()`](https://ambient.data-imaginist.com/reference/fracture.html)'s
own interface, while a
[noise_bridge](https://sketchpad.djnavarro.net/reference/noise_bridge.md)
instead samples by point count alone, with no `(x, y)` positions
involved.

## See also

Other noise helpers:
[`noise_bridge()`](https://sketchpad.djnavarro.net/reference/noise_bridge.md),
[`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md)

## Examples

``` r
noise_sample(noise_field(seed = 4821L), x = 1:5, y = 1:5, to = c(0, 1))
#> [1] 1.0000000 0.7744241 0.7519282 0.4733948 0.0000000

# noise_bridge()'s method samples by point count instead of position
noise_sample(noise_bridge(seed = 4821L), n = 5, scale = 1)
#> [1] -0.08603368 -0.11426980 -0.06669610 -0.00197935  0.01823602

# sampled values can drive a drawable's own geometry, e.g. shape_blob()'s
# radius perturbation (see its `points` getter)
angle <- seq(0, 2 * pi, length.out = 12)
noise_sample(noise_field(seed = 4821L), x = cos(angle), y = sin(angle), to = c(0.8, 1.2))
#>  [1] 1.0063778 1.1991745 0.8000000 1.1827139 0.9059486 0.9042259 0.8505269
#>  [8] 1.2000000 0.8686386 1.1469722 0.9474587 1.0063778
```
