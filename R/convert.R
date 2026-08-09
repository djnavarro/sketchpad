#' Convert a drawable to a plain shape
#'
#' Extracts the computed [points] of any [drawable] object (e.g. a
#' [shape_blob], [shape_ribbon], or [shape_twist]) and returns them as a
#' plain [shape_raw], preserving the original [style]. Useful for
#' "freezing" a noise-generated outline so it no longer recomputes on
#' access.
#'
#' @param from A [drawable] object.
#' @param to Target class, i.e. [shape_raw].
#' @param ... Currently unused.
#'
#' @export
#' @noRd
method(convert, list(drawable, shape_raw)) <- function(from, to, ...) {
  out <- shape_raw(x = from@points@x, y = from@points@y)
  out@style <- from@style
  out
}

