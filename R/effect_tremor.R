#' Layer jittered copies of a drawable for a hand-drawn look
#'
#' No single [drawable] can express a hand-drawn ink/pencil look on its
#' own -- what reads as hand-drawn is several independently wobbling
#' copies of the same nominal path layered on top of each other, not one
#' perfectly smooth line. `effect_tremor()` builds a [sketch] of `layers`
#' such copies: each is a copy of `object` (via [S7::set_props()]) with
#' its `x`/`y` displaced by smooth, seed-offset simplex noise sampled
#' along the path's own normalized arc-length -- the same ad hoc
#' technique used, during development, to add a wobbling pencil edge on
#' top of a [shape_stroke()]'s tapered outline, or to layer a plain
#' [curve_line()] into a shakier-looking line by itself.
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
#' Because each layer is built with [S7::set_props()] from `object`
#' itself, every other property -- style, `width`/`distortion` for a
#' [shape_stroke()], `trans`, ... -- carries over unchanged;
#' `effect_tremor()` only varies `x`/`y` across layers. Vary `color_alpha`
#' down and/or `layers` up (on `object` and via the `layers` argument,
#' respectively) for a denser, more overlapping pencil/ink texture.
#'
#' @param object A pathlike [drawable] (`@pathlike == TRUE`, see
#'   [drawable]'s docs), e.g. [curve_line()], [shape_stroke()],
#'   [shape_bezier()]. Every other property is preserved unchanged
#'   across layers.
#' @param layers Number of independently-jittered copies to layer. Must
#'   be a positive integer. Default `4L`.
#' @param jitter Maximum displacement amplitude applied to each layer's
#'   `x`/`y`. Must be non-negative. Default `0.05`.
#' @param jitter_frequency Frequency of the simplex noise driving the
#'   jitter, sampled along the path's normalized arc-length -- lower
#'   values give a slower, smoother wobble; higher values a jumpier one.
#'   Must be non-negative. Default `0.5`.
#' @param seed Integer seed for the jitter noise. Default `1L`.
#' @return A [sketch] containing `layers` drawables.
#'
#' @examples
#' template <- curve_line(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1))
#' faded <- curve_line(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), color_alpha = 0.4)
#'
#' # before: a single crisp line
#' draw(template)
#'
#' # after: several jittered, faded copies read as hand-drawn
#' draw(effect_tremor(faded))
#'
#' draw(effect_tremor(
#'   shape_stroke(
#'     x = c(0, 1, 2, 3), y = c(0, 1, 0, 1),
#'     width = 0.3, fill_alpha = 0.5, color = NA_character_
#'   ),
#'   layers = 3L, jitter = 0.03
#' ))
#'
#' # more layers and higher jitter give a denser, shakier scribble
#' draw(effect_tremor(faded, layers = 10L, jitter = 0.15))
#'
#' @family effects
#' @export
effect_tremor <- function(object,
                          layers = 4L,
                          jitter = 0.05,
                          jitter_frequency = 0.5,
                          seed = 1L) {
  require_pathlike(object, "effect_tremor()")
  x <- object@x
  y <- object@y
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
    S7::set_props(object, x = x + dx, y = y + dy)
  })
  sketch(shapes = shapes)
}
