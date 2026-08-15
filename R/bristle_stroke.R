#' A fanned bristle/dry-brush effect along a path
#'
#' `bristle_stroke()` builds a [sketch] of `n_bristles` thin
#' [shape_stroke()]s, fanned out perpendicular to a backbone path -- like
#' [sketchy()], no single drawable can express this by itself, since a
#' dry-brush look comes from several independently-frayed, independently
#' wobbling strands laid side by side, not one stroke. Each bristle:
#'
#' - is offset from the backbone by a fixed perpendicular distance (via
#'   the same per-point unit normal [shape_stroke()] itself uses,
#'   `stroke_normals()`), evenly spaced across `spread`;
#' - is trimmed to a random sub-range of the backbone's own length
#'   (`fray` controls how much), so bristles start/end raggedly rather
#'   than in one clean line -- the same "frayed edge" a real brush's
#'   outer bristles show as it runs dry;
#' - has its own randomly-scaled `width` (via `width_jitter`); and
#' - is independently wobbled via [sketchy()] (`layers = 1L`, since the
#'   fanning here already does the layering work `sketchy()` normally
#'   provides -- one wobbling copy per bristle position, not several
#'   wobbling copies of one path).
#'
#' [shape_stroke()]'s own taper-to-zero at both ends does double duty as
#' each bristle's tip fade, needing no extra work here. Randomization
#' (fray range, width scaling) is scoped per bristle with
#' [withr::with_seed()], the same reproducibility convention
#' [fill_stipple()]/[fill_scatter()]/[fill_halftone()] already use, so it
#' never leaks into the caller's global random state.
#'
#' @param x,y Numeric vectors of control point coordinates for the
#'   backbone path. Must be the same length, with at least two points.
#' @param n_bristles Number of bristles to fan out. Must be a positive
#'   integer. Default `9L`.
#' @param spread Total perpendicular distance the bristles fan across,
#'   centred on the backbone. Must be non-negative. Default `0.3`.
#' @param width Base bristle width, before per-bristle `width_jitter`
#'   scaling. Must be non-negative. Default `0.05`.
#' @param width_jitter Fractional random variation applied to each
#'   bristle's own `width` (e.g. `0.3` scales width by a factor drawn
#'   uniformly from `[0.7, 1.3]`). Must be in `[0, 1)`. Default `0.3`.
#' @param fray Maximum fraction of the backbone's own length randomly
#'   trimmed from each bristle's start and end. Must be in `[0, 0.5)`.
#'   Default `0.15`.
#' @param jitter,jitter_frequency Passed to [sketchy()]'s own arguments
#'   of the same name, controlling each bristle's independent wobble.
#'   Defaults `0.015`/`1.2`.
#' @param n Number of points used along each bristle's resampled path.
#'   Must be at least `2`. Default `100L`.
#' @param distortion A [noise_field] controlling each bristle's own width
#'   ("pressure") modulation, as in [shape_stroke()]. Default
#'   `noise_field()`.
#' @param seed Integer seed for the per-bristle randomization and wobble.
#'   Default `1L`.
#' @param ... Additional arguments passed unchanged to every bristle's
#'   [shape_stroke()] (e.g. `fill`/`fill_alpha`/`color`).
#' @return A [sketch] containing `n_bristles` drawables.
#'
#' @examples
#' t <- seq(0, 8, length.out = 200)
#' draw(bristle_stroke(
#'   x = t, y = sin(t) * 1.2,
#'   n_bristles = 11L, spread = 0.3, width = 0.06,
#'   fill = "black", fill_alpha = 0.4, color = NA_character_
#' ))
#'
#' @family effects
#' @export
bristle_stroke <- function(x,
                           y,
                           n_bristles = 9L,
                           spread = 0.3,
                           width = 0.05,
                           width_jitter = 0.3,
                           fray = 0.15,
                           jitter = 0.015,
                           jitter_frequency = 1.2,
                           n = 100L,
                           distortion = noise_field(),
                           seed = 1L,
                           ...) {
  if (length(x) != length(y)) rlang::abort("x and y must be the same length")
  if (length(x) < 2) rlang::abort("at least two control points are required")
  if (length(n_bristles) != 1 || n_bristles < 1L || n_bristles != round(n_bristles)) {
    rlang::abort("n_bristles must be a single positive integer")
  }
  if (length(spread) != 1 || spread < 0) {
    rlang::abort("spread must be a single non-negative number")
  }
  if (length(width) != 1 || width < 0) {
    rlang::abort("width must be a single non-negative number")
  }
  if (length(width_jitter) != 1 || width_jitter < 0 || width_jitter >= 1) {
    rlang::abort("width_jitter must be a single number in [0, 1)")
  }
  if (length(fray) != 1 || fray < 0 || fray >= 0.5) {
    rlang::abort("fray must be a single number in [0, 0.5)")
  }
  if (length(n) != 1 || n < 2L) {
    rlang::abort("n must be a single integer of at least 2")
  }

  path <- resample_by_length(x, y, n)
  normal <- stroke_normals(path$x, path$y)
  offsets <- if (n_bristles == 1L) 0 else seq(-spread / 2, spread / 2, length.out = n_bristles)

  shapes <- purrr::map(seq_len(n_bristles), function(i) {
    bristle_seed <- as.integer(seed) + i
    rand <- withr::with_seed(bristle_seed, {
      list(
        start_frac = stats::runif(1, 0, fray),
        end_frac = stats::runif(1, 1 - fray, 1),
        width_mult = stats::runif(1, 1 - width_jitter, 1 + width_jitter)
      )
    })
    idx <- round(rand$start_frac * (n - 1)):round(rand$end_frac * (n - 1)) + 1L

    bx <- path$x[idx] + normal$x[idx] * offsets[i]
    by <- path$y[idx] + normal$y[idx] * offsets[i]

    sketchy(
      shape_stroke,
      x = bx, y = by,
      layers = 1L, jitter = jitter, jitter_frequency = jitter_frequency,
      seed = bristle_seed,
      width = width * rand$width_mult, n = length(idx), distortion = distortion,
      ...
    )[[1]]
  })

  sketch(shapes = shapes)
}
