#' Generate a smoothed Brownian bridge
#'
#' Internal helper used by [noise_bridge]'s [noise_sample()] method.
#' Generates a Brownian bridge on `n` points over `[0, 1]` (a discretized
#' Wiener process pinned to `0` at both ends, matching `e1071::rbridge()`'s
#' construction but implemented directly to avoid the dependency), scales
#' it, and optionally smooths it with repeated local averaging.
#'
#' @param n Number of points in the bridge.
#' @param scale Multiplicative scale applied to the bridge.
#' @param smooth Number of smoothing passes (`0` = no smoothing).
#' @param seed Integer seed.
#'
#' @return Numeric vector of length `n`.
#' @noRd
smooth_bridge <- function(n, scale = .1, smooth = 0, seed = 1L) {
  withr::with_seed(
    seed = seed,
    code = {
      # Discretized Wiener process on n - 1 steps over (0, 1], then
      # subtract the line through the origin and its own endpoint to
      # pin both ends to 0 (the definition of a Brownian bridge).
      z <- cumsum(stats::rnorm(n - 1) / sqrt(n - 1))
      t <- seq_len(n - 1) / (n - 1)
      b <- c(0, z - t * z[n - 1])
    }
  )
  b <- b * scale
  if (smooth > 0) {
    for (i in 1:smooth) {
      b <- (b + c(b[-1], 0) / 2 + c(0, b[-n]) / 2) / 2
    }
  }
  b
}

#' A smoothed Brownian bridge, as a path distortion
#'
#' `noise_bridge` bundles the settings needed to generate a smoothed
#' Brownian bridge (via the internal `smooth_bridge()` helper): how many
#' local-averaging `smooth`-ing passes to apply, and which `seed` to draw
#' from. Unlike [noise_field] (sampled at arbitrary `(x, y)` positions in
#' the plane), a Brownian bridge has no spatial position to sample at --
#' [noise_sample()]'s method for `noise_bridge` instead takes a point
#' count `n` and a `scale`, returning a length-`n` displacement vector.
#' This is the distortion behind [shape_twist()]'s wandering path, split
#' out into its own class for the same reason [noise_field] was: so the
#' distortion is a first-class, swappable object rather than bare
#' constructor arguments, and so a future `curve_twist()` (an open,
#' unfilled wandering path) can reuse it without duplicating
#' `shape_twist()`'s path logic.
#'
#' @param smooth Number of smoothing passes. Must be non-negative.
#'   Default `3L`.
#' @param seed Integer seed. Default `1L`.
#'
#' @examples
#' noise_bridge(smooth = 5L, seed = 4821L)
#'
#' # more smoothing passes give a gentler bridge; embedding it in
#' # shape_twist()'s path_distortion makes the effect easy to see
#' draw(shape_twist(
#'   x = 0, y = 0, xend = 1, yend = 0, width = 0.2,
#'   path_distortion = noise_bridge(smooth = 0L, seed = 7734L)
#' ))
#' draw(shape_twist(
#'   x = 0, y = 0, xend = 1, yend = 0, width = 0.2,
#'   path_distortion = noise_bridge(smooth = 20L, seed = 7734L)
#' ))
#'
#' @family noise helpers
#' @export
noise_bridge <- S7::new_class(
  name = "noise_bridge",
  properties = list(
    smooth = S7::class_numeric,
    seed   = S7::class_integer
  ),
  constructor = function(smooth = 3L, seed = 1L) {
    S7::new_object(
      S7::S7_object(),
      smooth = smooth,
      seed = seed
    )
  },
  validator = function(self) {
    if (length(self@smooth) != 1) return("smooth must be length 1")
    if (length(self@seed) != 1) return("seed must be length 1")
    if (self@smooth < 0) return("smooth must be a non-negative number")
  }
)

#' @param n Number of points in the generated bridge.
#' @param scale Multiplicative scale applied to the bridge. Default `1`.
#' @export
#' @noRd
S7::method(noise_sample, noise_bridge) <- function(field, n, scale = 1) {
  smooth_bridge(n = n, scale = scale, smooth = field@smooth, seed = field@seed)
}
