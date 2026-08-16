#' Validate the `path` argument of `shape_ribbonpath()`
#'
#' Internal helper for [shape_ribbonpath()]: `path` must be a [drawable]
#' with `geometry == "path"` (i.e. a `curve_*()` constructor's output),
#' since `shape_ribbonpath()` builds its ribbon from that curve's own
#' computed backbone.
#'
#' @param path The `path` argument from [shape_ribbonpath()].
#' @return `invisible(NULL)`, or aborts.
#' @noRd
validate_ribbonpath_path <- function(path) {
  if (!S7::S7_inherits(path, drawable)) {
    rlang::abort("path must be a <drawable> object, e.g. curve_bezier(), curve_line()")
  }
  if (path@geometry != "path") {
    rlang::abort(paste0(
      'path must have geometry == "path" (e.g. curve_bezier(), curve_line(), ',
      "curve_twist(), curve_spiral(), curve_arc(), curve_scribble(), curve_raw()) -- ",
      'got geometry == "', path@geometry, '"'
    ))
  }
  invisible(NULL)
}

#' A ribbon following an arbitrary curve
#'
#' `shape_ribbonpath()` builds a tapered, noise-modulated ribbon (like
#' [shape_stroke()]) whose backbone follows an arbitrary `curve_*()`
#' drawable's own computed points, rather than raw `x`/`y` control
#' points.
#'
#' It is a thin wrapper: `path@points` is extracted and fed
#' straight into [shape_stroke()], so the object it returns is literally
#' a `shape_stroke` -- `shape_ribbonpath()` exists only to save the
#' caller from writing `shape_stroke(x = path@points@x, y =
#' path@points@y, ...)` by hand, and to make the "ribbon around a curve"
#' use case discoverable under its own name.
#'
#' Because the result is a `shape_stroke`, its width offset uses a true
#' per-point unit normal (`shape_stroke()`'s own `stroke_normals()`
#' helper) rather than a single shared offset direction -- this is what
#' lets `shape_ribbonpath()` work correctly for any backbone shape,
#' including ones that loop or bend sharply (e.g. [curve_twist()],
#' [curve_spiral()]), not just a nearly-straight one. Passing a
#' [curve_bezier()] here covers the same use case the package's earlier
#' `shape_bezier_ribbon()` (since removed) provided, but the two are not
#' numerically identical for a curved backbone: `shape_bezier_ribbon()`
#' offset by one shared direction vector (the straight line from its
#' start to end point) for the whole ribbon, and its taper formula
#' peaked at `0.5`; `shape_ribbonpath()` instead inherits
#' `shape_stroke()`'s true per-point normals and its taper formula
#' (which peaks at `1`, so `width` is exactly the maximum rendered
#' width).
#'
#' @param path A [drawable] with `geometry == "path"` (i.e. any
#'   `curve_*()` constructor's output, e.g. [curve_bezier()],
#'   [curve_line()], [curve_twist()], [curve_spiral()], [curve_arc()],
#'   [curve_scribble()], [curve_raw()]) -- its own computed points become
#'   this ribbon's backbone.
#' @param width Maximum width. Must be non-negative. Default `0.2`.
#' @param n Number of points used along the ribbon, resampled evenly by
#'   arc length from `path`'s own points (independent of however many
#'   points `path` itself was sampled at). Must be at least `2`. Default
#'   `100L`.
#' @param distortion A [noise_field] controlling the width ("pressure")
#'   modulation. Default `noise_field()`.
#' @param trans A [trans] object applied to the ribbon's computed points,
#'   on top of any `trans` already applied to `path` itself. Default
#'   [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable] (a [shape_stroke]).
#'
#' @examples
#' draw(shape_ribbonpath(
#'   curve_bezier(x = c(0, 0.25, 0.75, 1), y = c(0, 1, -1, 0)),
#'   width = 0.2
#' ))
#' draw(shape_ribbonpath(
#'   curve_twist(
#'     x = 0,
#'     y = 0,
#'     xend = 1,
#'     yend = 0,
#'     path_distortion = noise_bridge(seed = 7734L)
#'   ),
#'   width = 0.15
#' ))
#'
#' # a ribbon around a spiral -- a backbone shape_ribbon()/shape_twist()'s
#' # shared single offset direction couldn't render correctly
#' draw(shape_ribbonpath(
#'   curve_spiral(radius_start = 0.1, radius_end = 1, turns = 3),
#'   width = 0.1, fill = fill_charcoal()
#' ))
#'
#' @family 2D shapes
#' @export
shape_ribbonpath <- function(path,
                             width = 0.2,
                             n = 100L,
                             distortion = noise_field(),
                             trans = trans_identity(),
                             ...) {
  validate_ribbonpath_path(path)
  pts <- path@points
  shape_stroke(
    x = pts@x,
    y = pts@y,
    width = width,
    n = n,
    distortion = distortion,
    trans = trans,
    ...
  )
}

#' Multiple ribbon-paths at once
#'
#' `shape_ribbonpaths()` is a vectorized version of
#' [shape_ribbonpath()]: each argument may be a vector, recycled against
#' the others via `purrr::pmap()`'s own vctrs-based rules. The
#' result is a [sketch] containing one `shape_ribbonpath()` per recycled
#' row, rather than a single drawable.
#'
#' Any length-1 element is broadcast to the common length; mismatched
#' lengths greater than 1 raise an error. Unlike the `x`/`y`-list-column
#' constructors (e.g. [shape_beziers()]), `path` is a single [drawable]
#' object per ribbon, not a numeric vector, so a single shared `path`
#' recycles automatically across every ribbon (the same way a shared
#' `distortion` [noise_field] already does); pass a `list()` of several
#' different `curve_*()` objects instead to vary the backbone per ribbon.
#'
#' @rdname shape_ribbonpath
#' @return For `shape_ribbonpaths()`, a [sketch].
#'
#' @examples
#' draw(shape_ribbonpaths(
#'   path = list(
#'     curve_bezier(x = c(0, 0.25, 0.75, 1), y = c(0, 1, -1, 0)),
#'     curve_line(x = c(0, 1, 2), y = c(2, 3, 2))
#'   ),
#'   width = 0.2
#' ))
#'
#' @family 2D shapes
#' @export
shape_ribbonpaths <- function(path,
                              width = 0.2,
                              n = 100L,
                              distortion = noise_field(),
                              trans = trans_identity(),
                              ...) {
  vectorize_shapes(shape_ribbonpath, c(
    list(path = path, width = width, n = n, distortion = distortion, trans = trans),
    list(...)
  ))
}
