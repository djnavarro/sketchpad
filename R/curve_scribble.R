#' A wandering scribble curve
#'
#' `curve_scribble` is a [drawable] whose path is a single random wandering
#' line -- a random finite sum of sine harmonics -- built from the same
#' internal `scribble_lines()` generator that [fill_scribble()] uses to
#' texture a tile's interior, but scaled here into an arbitrary bounding box
#' on the sketch's own coordinate plane rather than tiled inside a fill
#' pattern. Where `fill_scribble()` scatters several such lines across a
#' repeating tile as a texture, `curve_scribble()` draws exactly one as a
#' standalone open curve.
#'
#' The underlying line is generated in `(along, across)` form, `along`
#' running from `0` to `1` and `across` wandering around a random baseline
#' near `0.5` (see `scribble_lines()`'s own details for why this
#' particular construction was chosen -- periodicity, needed for tiling,
#' is irrelevant here). `x`/`y` place the curve's origin, and `width`/
#' `height` scale it: for `direction = "horizontal"` (the default), `along`
#' maps to `x + along * width` and `across` to `y + across * height`, so
#' the curve runs left-to-right; for `direction = "vertical"`, the mapping
#' swaps (`along` maps to `y`, `across` to `x`), so the curve runs
#' bottom-to-top instead.
#'
#' `style@fill` has no effect for `curve_scribble()` -- see [drawable]'s
#' `geometry` documentation for why `"path"` geometries have no interior to
#' fill. Passing `fill` via `...` is still accepted (it's simply ignored at
#' draw time), since `style()` is shared across every `geometry`.
#'
#' @param x,y Coordinates of the curve's origin. Default `0`.
#' @param width,height Extent of the curve's bounding box along/across its
#'   direction of travel. Must be positive. Default `1`.
#' @param direction Either `"horizontal"` (the curve runs left-right) or
#'   `"vertical"` (top-bottom). Default `"horizontal"`.
#' @param n_harmonics Number of sine harmonics summed to build the curve.
#'   Must be a positive integer. Default `3L`.
#' @param amplitude Maximum total wiggle amplitude, as a fraction of
#'   `height` (for `direction = "horizontal"`) or `width` (for
#'   `"vertical"`), split across `n_harmonics`. Must be a non-negative
#'   number. Default `0.35`.
#' @param n Number of points sampled along the curve. Must be a positive
#'   integer of at least `2L`. Default `200L`.
#' @param seed Integer seed for the random harmonics. Default `1L`.
#' @param ... Arguments passed to [style()].
#'
#' @family 1D curves
#' @export
curve_scribble <- S7::new_class(
  name = "curve_scribble",
  parent = drawable,
  properties = list(
    x           = S7::class_numeric,
    y           = S7::class_numeric,
    width       = S7::class_numeric,
    height      = S7::class_numeric,
    direction   = S7::class_character,
    n_harmonics = S7::class_integer,
    amplitude   = S7::class_numeric,
    n           = S7::class_integer,
    seed        = S7::class_integer,
    points = S7::new_property(
      class = point_set,
      getter = function(self) {
        line <- scribble_lines(
          n_lines = 1L,
          n_harmonics = self@n_harmonics,
          amplitude = self@amplitude,
          resolution = self@n,
          seed = self@seed
        )[[1]]
        if (self@direction == "horizontal") {
          point_set(
            x = self@x + line$along * self@width,
            y = self@y + line$across * self@height
          )
        } else {
          point_set(
            x = self@x + line$across * self@width,
            y = self@y + line$along * self@height
          )
        }
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@width) != 1) return("width must be length 1")
    if (length(self@height) != 1) return("height must be length 1")
    if (self@width <= 0) return("width must be a positive number")
    if (self@height <= 0) return("height must be a positive number")
    if (length(self@direction) != 1 ||
          !self@direction %in% c("horizontal", "vertical")) {
      return('direction must be one of "horizontal" or "vertical"')
    }
    if (length(self@n_harmonics) != 1) return("n_harmonics must be length 1")
    if (self@n_harmonics < 1L) return("n_harmonics must be a positive integer")
    if (length(self@amplitude) != 1) return("amplitude must be length 1")
    if (self@amplitude < 0) return("amplitude must be a non-negative number")
    if (length(self@n) != 1) return("n must be length 1")
    if (self@n < 2L) return("n must be an integer of at least 2")
    if (length(self@seed) != 1) return("seed must be length 1")
  },
  constructor = function(x = 0,
                         y = 0,
                         width = 1,
                         height = 1,
                         direction = "horizontal",
                         n_harmonics = 3L,
                         amplitude = 0.35,
                         n = 200L,
                         seed = 1L,
                         ...) {
    S7::new_object(
      drawable(geometry = "path"),
      x = x,
      y = y,
      width = width,
      height = height,
      direction = direction,
      n_harmonics = n_harmonics,
      amplitude = amplitude,
      n = n,
      seed = seed,
      style = style(...)
    )
  }
)
