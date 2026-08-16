#' A sampled scalar noise field
#'
#' `noise_field` bundles the settings needed to sample a scalar-valued
#' noise field from \pkg{ambient} at arbitrary `(x, y)` positions: which
#' base noise function and fractal combinator to use
#' ([ambient::fracture()]'s `noise`/`fractal` arguments), how coarse or
#' fine the field is (`frequency`), how many octaves of detail to layer
#' (`octaves`), and which `seed` to draw from.
#'
#' [noise_sample()] evaluates a `noise_field` at a set of positions and
#' rescales the result into a target range -- the operation shared by
#' [shape_blob()]'s radius perturbation and [shape_ribbon()]/
#' [shape_twist()]'s width modulation, factored out here so it isn't
#' duplicated across those three constructors, and so the noise/fractal
#' functions themselves are configurable rather than hardcoded to
#' [ambient::gen_simplex()]/[ambient::fbm()].
#'
#' @param noise A noise-generating function, passed to
#'   [ambient::fracture()]'s `noise` argument (e.g. [ambient::gen_simplex()],
#'   [ambient::gen_perlin()], [ambient::gen_worley()]). Default
#'   [ambient::gen_simplex()].
#' @param fractal A fractal combinator function, passed to
#'   [ambient::fracture()]'s `fractal` argument (e.g. [ambient::fbm()],
#'   [ambient::billow()]). Default [ambient::fbm()].
#' @param frequency Noise frequency. Must be non-negative. Default `1`.
#' @param octaves Number of noise octaves. Must be a positive integer.
#'   Default `2L`.
#' @param seed Integer seed for the noise field. Default `1L`.
#'
#' @examples
#' noise_field(frequency = 2, octaves = 3, seed = 4821)
#'
#' # a noise_field's effect is easiest to see through a drawable that
#' # samples it -- lower frequency gives broad, gentle undulation, higher
#' # frequency a bumpier, more textured one
#' draw(shape_blob(
#'   radius = 1,
#'   range = 0.4,
#'   distortion = noise_field(frequency = 0.5, seed = 4821)
#' ))
#' draw(shape_blob(
#'   radius = 1,
#'   range = 0.4,
#'   distortion = noise_field(frequency = 6, seed = 4821)
#' ))
#'
#' # more octaves layer finer detail on top of the base frequency
#' draw(shape_blob(
#'   radius = 1,
#'   range = 0.4,
#'   distortion = noise_field(octaves = 6, seed = 4821)
#' ))
#'
#' @family noise helpers
#' @export
noise_field <- S7::new_class(
  name = "noise_field",
  properties = list(
    noise     = S7::class_function,
    fractal   = S7::class_function,
    frequency = S7::class_numeric,
    octaves   = S7::class_integer,
    seed      = S7::class_integer
  ),
  constructor = function(noise = ambient::gen_simplex,
                         fractal = ambient::fbm,
                         frequency = 1,
                         octaves = 2L,
                         seed = 1L) {
    S7::new_object(
      S7::S7_object(),
      noise = noise,
      fractal = fractal,
      frequency = frequency,
      octaves = as_integerish(octaves, "octaves"),
      seed = as_integerish(seed, "seed")
    )
  },
  validator = function(self) {
    if (length(self@frequency) != 1) {
      return("frequency must be length 1")
    }
    if (length(self@octaves) != 1) {
      return("octaves must be length 1")
    }
    if (length(self@seed) != 1) {
      return("seed must be length 1")
    }
    if (self@frequency < 0) {
      return("frequency must be a non-negative number")
    }
    if (self@octaves < 1L) {
      return("octaves must be a positive integer")
    }
  }
)

#' Sample a noise object
#'
#' `noise_sample()` evaluates a noise object at a set of positions and
#' returns the (typically rescaled) sampled values.
#'
#' It is an S7 generic dispatching on `field`; each concrete noise class
#' implements its own method, since what "a position" means differs by
#' class -- a [noise_field] is sampled at arbitrary `(x, y)` coordinates
#' in the plane, matching [ambient::fracture()]'s own interface, while a
#' [noise_bridge] instead samples by point count alone, with no
#' `(x, y)` positions involved.
#'
#' @param field A noise object, e.g. one built by [noise_field()].
#' @param ... Passed to the method for `field`'s class.
#'
#' @return A numeric vector.
#'
#' @examples
#' noise_sample(noise_field(seed = 4821), x = 1:5, y = 1:5, to = c(0, 1))
#'
#' # noise_bridge()'s method samples by point count instead of position
#' noise_sample(noise_bridge(seed = 4821), n = 5, scale = 1)
#'
#' # sampled values can drive a drawable's own geometry, e.g. shape_blob()'s
#' # radius perturbation (see its `points` getter)
#' angle <- seq(0, 2 * pi, length.out = 12)
#' noise_sample(
#'   noise_field(seed = 4821),
#'   x = cos(angle),
#'   y = sin(angle),
#'   to = c(0.8, 1.2)
#' )
#'
#' @family noise helpers
#' @export
noise_sample <- S7::new_generic("noise_sample", dispatch_args = "field")

#' @param x,y Numeric vectors of positions to sample the field at.
#' @param to Numeric vector of length 2, the range to rescale the sampled
#'   values into. Default `c(0, 1)`.
#' @export
#' @noRd
S7::method(noise_sample, noise_field) <- function(field, x, y, to = c(0, 1)) {
  ambient::fracture(
    noise = field@noise,
    fractal = field@fractal,
    x = x,
    y = y,
    frequency = field@frequency,
    seed = field@seed,
    octaves = field@octaves
  ) |>
    ambient::normalize(to = to)
}
