#' Convert a drawable to a plain shape
#'
#' Extracts the computed `points` of any [drawable] object (e.g. a
#' [shape_blob], [shape_ribbon], or [shape_twist]) and returns them as a
#' plain [shape_raw], preserving the original [style]. Useful for
#' "freezing" a noise-generated outline so it no longer recomputes on
#' access.
#'
#' This always targets `"polygon"`-geometry ([shape_raw]), regardless of
#' `from`'s own `geometry` -- converting an open/`"path"`-geometry
#' drawable (e.g. [curve_bezier()] or [curve_scribble()]) or a
#' `"points"`-geometry one (e.g. [points_raw()]) this way silently turns
#' it into a closed, filled outline. To freeze a drawable's points while
#' preserving its own `"path"`/`"points"` geometry instead, target
#' [curve_raw]/[points_raw] directly -- see `method(convert, list(drawable,
#' curve_raw))`/`method(convert, list(drawable, points_raw))` below.
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

#' Convert a drawable to a plain open path
#'
#' `from`'s `"path"`-geometry analog of `method(convert, list(drawable,
#' shape_raw))`: extracts the computed `points` of any [drawable] object
#' and returns them as a plain [curve_raw], preserving the original
#' [style] and rendering as an open stroke rather than a closed polygon.
#' Unlike the `shape_raw` target above, this doesn't change `from`'s own
#' geometry -- it's meant for freezing a `"path"`-geometry drawable (e.g.
#' [curve_bezier()] or [curve_scribble()]) without silently closing/filling
#' it, though nothing stops calling it on a `"polygon"`-geometry drawable
#' too (its computed points are used as-is, connected as an open path
#' instead of a closed outline).
#'
#' @param from A [drawable] object.
#' @param to Target class, i.e. [curve_raw].
#' @param ... Currently unused.
#'
#' @export
#' @noRd
method(convert, list(drawable, curve_raw)) <- function(from, to, ...) {
  out <- curve_raw(x = from@points@x, y = from@points@y)
  out@style <- from@style
  out
}

#' Convert a drawable to a plain scatter of points
#'
#' `from`'s `"points"`-geometry analog of `method(convert, list(drawable,
#' shape_raw))`: extracts the computed `points` of any [drawable] object
#' and returns them as a plain [points_raw], preserving the original
#' [style] and rendering as unconnected markers rather than a closed
#' polygon or open path. As with the `curve_raw` target above, this
#' doesn't change `from`'s own geometry -- it freezes any drawable's
#' points as a `"points"`-geometry scatter regardless of what geometry
#' `from` itself had.
#'
#' @param from A [drawable] object.
#' @param to Target class, i.e. [points_raw].
#' @param ... Currently unused.
#'
#' @export
#' @noRd
method(convert, list(drawable, points_raw)) <- function(from, to, ...) {
  out <- points_raw(x = from@points@x, y = from@points@y)
  out@style <- from@style
  out
}

