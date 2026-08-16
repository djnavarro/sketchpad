#' Colour palette drawn from a curated collection
#'
#' Selects one palette from a vendored, deduplicated copy of the manually
#' curated palettes at <https://github.com/djnavarro/palettes>, each
#' originally a 5-colour hex palette. If `n` differs from the palette's own
#' native length, colours are linearly interpolated to `n` colours via
#' [grDevices::colorRampPalette()].
#'
#' @param n `NULL` (the default) or a single positive whole number: the
#'   number of colours to return. `NULL` returns the selected palette's own
#'   colours unchanged; otherwise the palette is interpolated to `n`
#'   colours.
#' @param index A single positive whole number selecting which stored
#'   palette to use. An out-of-range `index` errors with the valid range
#'   for the currently vendored data.
#'
#' @return A character vector of `n` hex colour strings (or the selected
#'   palette's own colours, if `n` is `NULL`).
#'
#' @examples
#' palette_manual(index = 1)
#' palette_manual(n = 12, index = 1)
#'
#' @family palette helpers
#' @export
palette_manual <- function(n = NULL, index = 1L) {
  n_available <- length(manual_palettes)
  if (!is.numeric(index) || length(index) != 1 || index != round(index)) {
    rlang::abort("index must be a single whole number")
  }
  if (index < 1 || index > n_available) {
    rlang::abort(paste0("index must be between 1 and ", n_available))
  }
  if (!is.null(n) && (!is.numeric(n) || length(n) != 1 || n < 1 || n != round(n))) {
    rlang::abort("n must be NULL or a single positive whole number")
  }

  pal <- manual_palettes[[index]]
  if (is.null(n)) {
    return(pal)
  }
  grDevices::colorRampPalette(pal)(n)
}

#' Colour palette from a linear cosine formula
#'
#' Generates a smoothly varying colour palette using the linear cosine
#' formula described by Iñigo Quilez for procedural palettes (see
#' <https://blog.djnavarro.net/posts/2025-09-14_cosine-palettes/>):
#' \deqn{f(t) = a + b \cos(2 \pi (c t + d))}
#' where \eqn{a = (0.5, 0.5, 0.5)} is fixed and \eqn{b}, \eqn{c}, \eqn{d}
#' are each an RGB triple sampled (with replacement) from `base`.
#'
#' As in the source algorithm, resulting values are clamped only on the
#' high end (values above 1 are capped at 1); values below 0 are folded
#' back with [abs()] rather than clamped to 0. This is an intentional
#' quirk inherited from the source algorithm, not a bug -- it occasionally
#' produces a colour "reflected" around black rather than a flat black.
#'
#' @param n A single positive whole number: the number of colours to
#'   generate.
#' @param base `NULL` (the default) or a character vector of candidate
#'   colours to sample `b`, `c`, and `d` from. `NULL` uses
#'   `grDevices::colors(distinct = TRUE)`.
#' @param seed A single whole number seeding the random sampling of `b`,
#'   `c`, and `d`, so the same `seed` always produces the same palette.
#'
#' @return A character vector of `n` hex colour strings.
#'
#' @examples
#' palette_cosine(n = 16, seed = 11)
#'
#' @family palette helpers
#' @export
palette_cosine <- function(n, base = NULL, seed = 1L) {
  if (!is.numeric(n) || length(n) != 1 || n < 1 || n != round(n)) {
    rlang::abort("n must be a single positive whole number")
  }
  if (is.null(base)) {
    base <- grDevices::colors(distinct = TRUE)
  }
  validate_colors(base, "base")
  if (!is.numeric(seed) || length(seed) != 1 || seed != round(seed)) {
    rlang::abort("seed must be a single whole number")
  }

  withr::with_seed(
    seed = as.integer(seed),
    code = {
      sampled <- sample(base, 3, replace = TRUE)
    }
  )
  to_unit_rgb <- function(color) as.vector(grDevices::col2rgb(color)) / 255
  a <- c(0.5, 0.5, 0.5)
  b <- to_unit_rgb(sampled[1])
  c <- to_unit_rgb(sampled[2])
  d <- to_unit_rgb(sampled[3])

  t <- seq(0, 1, length.out = n)
  pal <- vapply(t, function(tt) a + b * cos(2 * pi * (c * tt + d)), double(3))
  pal[pal > 1] <- 1
  grDevices::rgb(t(abs(pal)))
}
