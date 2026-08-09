#' Convert a drawable to a plain shape
#'
#' Extracts the computed [points] of any [drawable] object (e.g. a
#' [blob], [ribbon], or [twist]) and returns them as a plain [shape],
#' preserving the original [style]. Useful for "freezing" a
#' noise-generated outline so it no longer recomputes on access.
#'
#' @param from A [drawable] object.
#' @param to Target class, i.e. [shape].
#' @param ... Currently unused.
#'
#' @export
#' @noRd
method(convert, list(drawable, shape)) <- function(from, to, ...) {
  out <- shape(x = from@points@x, y = from@points@y)
  out@style <- from@style
  out
}

