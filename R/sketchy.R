#' Layer jittered copies of a path drawable for a hand-drawn look
#'
#' No single [drawable] can express a hand-drawn ink/pencil look on its
#' own -- what reads as "sketchy" is several independently wobbling
#' copies of the same nominal path layered on top of each other, not one
#' perfectly smooth line. `sketchy()` builds a [sketch] of `layers` such
#' copies: each is constructed by calling `.f` (a drawable constructor
#' taking `x`/`y` control point vectors, e.g. [curve_line()] or
#' [shape_stroke()]) with `x`/`y` displaced by smooth, seed-offset simplex
#' noise sampled along the path's own normalized arc-length -- the same
#' ad hoc technique used, during development, to add a wobbling pencil
#' edge on top of a [shape_stroke()]'s tapered outline, or to layer a
#' plain [curve_line()] into a sketchier-looking line by itself.
#'
#' Noise is sampled at each control point's own position along arc-length
#' (`0` to `1`), not at its raw `x`/`y` coordinates, so the jitter's shape
#' is independent of the path's own scale or aspect ratio -- a long,
#' shallow path and a short, steep one with the same number of control
#' points get comparably-shaped wobble. Each layer's noise is
#' seed-offset from the last (`seed + 2 * (i - 1)` for the `x`
#' displacement, one more for `y`, following the same seed-offset
#' convention `trans_warp()`/`twisted_path_points()` already use for
#' their own independent-axis noise), so layers wobble independently
#' rather than moving in lockstep.
#'
#' Every other drawable-specific argument (`width`/`distortion` for
#' [shape_stroke()]; `color`/`color_alpha`/`linewidth` for either) is
#' forwarded via `...` to every layer unchanged -- `sketchy()` only varies
#' `x`/`y` across layers, not style. Vary `color_alpha` down and/or
#' `layers` up for a denser, more overlapping pencil/ink texture.
#'
#' @param .f A drawable constructor taking `x`/`y` control point vectors,
#'   e.g. [curve_line()] or [shape_stroke()].
#' @param x,y Numeric vectors of control point coordinates for the
#'   unperturbed path. Must be the same length, with at least two points.
#' @param layers Number of independently-jittered copies to layer. Must
#'   be a positive integer. Default `4L`.
#' @param jitter Maximum displacement amplitude applied to each layer's
#'   `x`/`y`. Must be non-negative. Default `0.05`.
#' @param jitter_frequency Frequency of the simplex noise driving the
#'   jitter, sampled along the path's normalized arc-length -- lower
#'   values give a slower, smoother wobble; higher values a jumpier one.
#'   Must be non-negative. Default `0.5`.
#' @param seed Integer seed for the jitter noise. Default `1L`.
#' @param ... Additional arguments passed unchanged to every call of
#'   `.f` (e.g. `width`/`distortion` for [shape_stroke()], or
#'   `color`/`color_alpha` for either).
#' @return A [sketch] containing `layers` drawables.
#'
#' @examples
#' draw(sketchy(
#'   curve_line,
#'   x = c(0, 1, 2, 3), y = c(0, 1, 0, 1),
#'   color_alpha = 0.4
#' ))
#' draw(sketchy(
#'   shape_stroke,
#'   x = c(0, 1, 2, 3), y = c(0, 1, 0, 1),
#'   width = 0.3, fill_alpha = 0.5, color = NA_character_,
#'   layers = 3L, jitter = 0.03
#' ))
#'
#' @family effects
#' @export
sketchy <- function(.f,
                     x,
                     y,
                     layers = 4L,
                     jitter = 0.05,
                     jitter_frequency = 0.5,
                     seed = 1L,
                     ...) {
  if (!is.function(.f)) rlang::abort(".f must be a function")
  if (length(x) != length(y)) rlang::abort("x and y must be the same length")
  if (length(x) < 2) rlang::abort("at least two control points are required")
  if (length(layers) != 1 || layers < 1L || layers != round(layers)) {
    rlang::abort("layers must be a single positive integer")
  }
  if (length(jitter) != 1 || jitter < 0) {
    rlang::abort("jitter must be a single non-negative number")
  }
  if (length(jitter_frequency) != 1 || jitter_frequency < 0) {
    rlang::abort("jitter_frequency must be a single non-negative number")
  }

  arc_length <- c(0, cumsum(sqrt(diff(x)^2 + diff(y)^2)))
  total_length <- arc_length[length(arc_length)]
  s <- if (total_length == 0) rep(0, length(x)) else arc_length / total_length

  shapes <- purrr::map(seq_len(layers), function(i) {
    layer_seed <- seed + 2L * (i - 1L)
    dx <- ambient::gen_simplex(
      x = s, y = 0, frequency = jitter_frequency, seed = layer_seed
    ) * jitter
    dy <- ambient::gen_simplex(
      x = s, y = 100, frequency = jitter_frequency, seed = layer_seed + 1L
    ) * jitter
    .f(x = x + dx, y = y + dy, ...)
  })
  sketch(shapes = shapes)
}
