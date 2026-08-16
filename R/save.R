#' Validate common `save_*()` arguments
#'
#' Internal helper shared by every `save_*()` wrapper below. `dpi` (only
#' meaningful for `save_png()`) is validated separately by that function
#' itself, since it doesn't apply to the vector formats.
#'
#' @param object A [drawable] or [sketch] object.
#' @param filename A single string.
#' @param width,height A single positive number.
#' @noRd
validate_save_args <- function(object, filename, width, height) {
  if (!(S7::S7_inherits(object, drawable) || S7::S7_inherits(object, sketch))) {
    rlang::abort("`object` must be a <drawable> or <sketch>.")
  }
  if (!is.character(filename) || length(filename) != 1 || is.na(filename)) {
    rlang::abort("`filename` must be a single string.")
  }
  # dirname(filename) is "." for a bare filename with no directory
  # component at all, which dir.exists() always finds -- so this only
  # fires for a genuinely missing directory, not every relative path.
  # Catching this here, before any grDevices::png()/svg()/pdf() call
  # opens a device, gives a clear error naming the actual missing
  # directory instead of grDevices's own generic (and, for some
  # devices, only a warning-turned-partial-failure) "cannot open file"
  # message.
  if (!dir.exists(dirname(filename))) {
    rlang::abort(paste0(
      "Can't write to `", filename, "`: directory `", dirname(filename),
      "` does not exist."
    ))
  }
  if (!is.numeric(width) || length(width) != 1 || width <= 0) {
    rlang::abort("`width` must be a single positive number.")
  }
  if (!is.numeric(height) || length(height) != 1 || height <= 0) {
    rlang::abort("`height` must be a single positive number.")
  }
  invisible(NULL)
}

#' Save a drawable or sketch to an image file
#'
#' `save_png()`, `save_svg()`, and `save_pdf()` render a [drawable] or
#' [sketch] straight to a raster (PNG) or vector (SVG/PDF) file, without
#' the caller needing to manage a [grDevices] device by hand. Each is a
#' thin wrapper: open the appropriate device, call [draw()], and always
#' close the device afterward (via `on.exit()`, so a device is never left
#' open even if `draw()` itself errors).
#'
#' @param object A [drawable] or [sketch] object.
#' @param filename A single string, the path to write to.
#' @param width,height Image dimensions in inches. Default `7`.
#' @param dpi Resolution in dots per inch. Only meaningful for
#'   `save_png()` (a raster format); ignored by `save_svg()`/`save_pdf()`,
#'   which are drawn at vector resolution. Default `300`.
#' @param bg Background colour passed to the underlying device, e.g.
#'   `"white"` (the default) or `"transparent"`. This is the device's own
#'   page colour, independent of any [canvas()] `background` a `sketch`
#'   itself already carries -- the two compose, so a transparent `bg`
#'   here still shows an opaque `canvas()` background underneath, and vice
#'   versa a `sketch` with no `canvas()` background shows `bg` through
#'   any of its own shapes that don't fully cover the page.
#' @param ... Passed on to [draw()], e.g. `xlim`/`ylim`.
#'
#' @return `filename`, invisibly.
#'
#' @examples
#' file <- tempfile(fileext = ".png")
#' save_png(shape_circle(radius = 1), file)
#'
#' file <- tempfile(fileext = ".svg")
#' save_svg(shape_circle(radius = 1), file)
#'
#' file <- tempfile(fileext = ".pdf")
#' save_pdf(shape_circle(radius = 1), file)
#'
#' @family export helpers
#' @export
save_png <- function(object, filename, width = 7, height = 7, dpi = 300, bg = "white", ...) {
  validate_save_args(object, filename, width, height)
  if (!is.numeric(dpi) || length(dpi) != 1 || dpi <= 0) {
    rlang::abort("`dpi` must be a single positive number.")
  }
  grDevices::png(filename, width = width, height = height, units = "in", res = dpi, bg = bg)
  on.exit(grDevices::dev.off())
  draw(object, ...)
  invisible(filename)
}

#' @rdname save_png
#' @export
save_svg <- function(object, filename, width = 7, height = 7, bg = "white", ...) {
  validate_save_args(object, filename, width, height)
  grDevices::svg(filename, width = width, height = height, bg = bg)
  on.exit(grDevices::dev.off())
  draw(object, ...)
  invisible(filename)
}

#' @rdname save_png
#' @export
save_pdf <- function(object, filename, width = 7, height = 7, bg = "white", ...) {
  validate_save_args(object, filename, width, height)
  grDevices::pdf(filename, width = width, height = height, bg = bg)
  on.exit(grDevices::dev.off())
  draw(object, ...)
  invisible(filename)
}
