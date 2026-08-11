# Sample a noise object

`noise_sample()` evaluates a noise object at a set of positions and
returns the (typically rescaled) sampled values. It is an S7 generic
dispatching on `field`; each concrete noise class implements its own
method, since what "a position" means differs by class – a
[noise_field](https://sketchpad.djnavarro.net/reference/noise_field.md)
is sampled at arbitrary `(x, y)` coordinates in the plane, matching
[`ambient::fracture()`](https://ambient.data-imaginist.com/reference/fracture.html)'s
own interface, while a
[noise_bridge](https://sketchpad.djnavarro.net/reference/noise_bridge.md)
instead samples by point count alone, with no `(x, y)` positions
involved.

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

## See also

Other noise helpers:
[`noise_bridge()`](https://sketchpad.djnavarro.net/reference/noise_bridge.md),
[`noise_field()`](https://sketchpad.djnavarro.net/reference/noise_field.md)

## Examples

``` r
noise_sample(noise_field(seed = 4821L), x = 1:5, y = 1:5, to = c(0, 1))
#> [1] 1.0000000 0.7744241 0.7519282 0.4733948 0.0000000
```
