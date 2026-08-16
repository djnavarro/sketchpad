#' Resample a polyline to evenly-spaced points by arc length
#'
#' Internal helper for [shape_stroke()]. Unlike [curve_line()] (which uses
#' its control points as vertices directly, with no resampling), a stroke
#' needs a dense, evenly-spaced point sequence so its width taper/noise
#' modulation vary smoothly even when the caller supplies only a few
#' control points. Ties in cumulative arc length (from duplicate
#' consecutive control points) are dropped before interpolating, avoiding
#' [stats::approx()]'s "collapsing to unique x values" warning.
#'
#' @param x,y Control point coordinates.
#' @param n Number of evenly arc-length-spaced points to resample to.
#' @return A list with `x`/`y` numeric vectors, each length `n`.
#' @noRd
resample_by_length <- function(x, y, n) {
  arc_length <- c(0, cumsum(sqrt(diff(x)^2 + diff(y)^2)))
  total_length <- arc_length[length(arc_length)]
  if (total_length == 0) {
    return(list(x = rep(x[1], n), y = rep(y[1], n)))
  }
  unique_idx <- !duplicated(arc_length)
  arc_length <- arc_length[unique_idx]
  x <- x[unique_idx]
  y <- y[unique_idx]
  s <- seq(0, total_length, length.out = n)
  list(
    x = stats::approx(arc_length, x, xout = s)$y,
    y = stats::approx(arc_length, y, xout = s)$y
  )
}

#' Per-point unit normals along a polyline
#'
#' Internal helper for [shape_stroke()]. Computed via central differences
#' (forward/backward difference at the two endpoints), then normalized to
#' unit length at every point -- unlike [shape_ribbon()]/[shape_twist()],
#' which offset by a single *unnormalized* direction vector shared by the
#' whole shape (safe only because their own backbone is straight, or
#' displaced from straight by a small amount). A [shape_stroke()] path can
#' bend arbitrarily, so its offset direction must be recomputed, and
#' re-normalized, at every point -- a global direction would visibly skew
#' the outline anywhere the path curves.
#'
#' @param x,y Coordinates of a polyline, already resampled to even
#'   arc-length spacing by `resample_by_length()`.
#' @return A list with `x`/`y` numeric vectors of unit normal components,
#'   the same length as `x`/`y`.
#' @noRd
stroke_normals <- function(x, y) {
  n <- length(x)
  if (n == 2L) {
    dx <- rep(x[2] - x[1], 2)
    dy <- rep(y[2] - y[1], 2)
  } else {
    dx <- c(x[2] - x[1], (x[3:n] - x[1:(n - 2)]) / 2, x[n] - x[n - 1])
    dy <- c(y[2] - y[1], (y[3:n] - y[1:(n - 2)]) / 2, y[n] - y[n - 1])
  }
  seg_length <- sqrt(dx^2 + dy^2)
  # a degenerate (zero-length) tangent has no defined normal; the offset
  # collapses to 0 there regardless, so any nonzero divisor is safe
  seg_length[seg_length == 0] <- 1
  list(x = -dy / seg_length, y = dx / seg_length)
}

#' A tapered, pressure-modulated stroke along an arbitrary path
#'
#' `shape_stroke` is a [drawable] polygon that follows an arbitrary open
#' path through `(x, y)` control points, offset into a ribbon whose width
#' tapers to zero at both ends and varies along its length according to a
#' [noise_field] -- intended as a "pressure" curve, giving the outline an
#' ink/brush-stroke look rather than a constant-width line.
#'
#' The path is resampled to `n` evenly arc-length-spaced points (unlike
#' [curve_line()]'s exact control-point vertices). This generalizes
#' [shape_ribbon()] from a single straight segment to any path, at the
#' cost of computing a true per-point unit normal (via the internal
#' `stroke_normals()` helper) rather than [shape_ribbon()]/[shape_twist()]'s
#' shared single offset direction -- necessary once the path can genuinely
#' curve, not just wander slightly off straight.
#'
#' Unlike [shape_ribbon()]'s own taper (which peaks at `0.5`, an
#' undocumented quirk of its `sqrt(t * (1 - t))` formula), `shape_stroke`'s
#' taper is normalized to peak at `1` at the path's midpoint, so `width`
#' is exactly the maximum rendered width.
#'
#' Resampling only redistributes points evenly along the control
#' polyline's own straight segments -- it does not smooth or curve-fit
#' sharp corners, matching [curve_line()]'s own no-smoothing convention.
#' A `shape_stroke()` built from only a few widely-spaced control points
#' will still have visibly angular corners; supply a denser `x`/`y` (e.g.
#' points already sampled from some smooth function) for a smoothly
#' curving stroke.
#'
#' @param x,y Numeric vectors of control point coordinates. Must be the
#'   same length, with at least two control points.
#' @param width Maximum width. Must be non-negative. Default `0.2`.
#' @param n Number of points used along the resampled path. Must be at
#'   least `2`. Default `100L`.
#' @param distortion A [noise_field] controlling the width ("pressure")
#'   modulation. Default `noise_field()`.
#' @param trans A [trans] object applied to the shape's computed points.
#'   Default [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(shape_stroke(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.3))
#' draw(shape_stroke(
#'   x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.3,
#'   distortion = noise_field(frequency = 3, seed = 7734L)
#' ))
#'
#' # a few widely-spaced control points give angular corners, since
#' # resampling redistributes points but never smooths them
#' draw(shape_stroke(x = c(0, 1, 0), y = c(0, 2, 0), width = 0.2))
#'
#' # denser input points (already sampled from a smooth function) give a
#' # smoothly curving stroke instead
#' t <- seq(0, 2 * pi, length.out = 200)
#' draw(shape_stroke(x = t, y = sin(t), width = 0.15, fill = fill_charcoal()))
#'
#' # layer effect_tremor() on top for a hand-drawn ink look
#' draw(effect_tremor(
#'   shape_stroke(
#'     x = c(0, 1, 2, 3),
#'     y = c(0, 1, 0, 1),
#'     width = 0.2,
#'     fill_alpha = 0.4
#'   ),
#'   layers = 4L
#' ))
#'
#' @family 2D shapes
#' @export
shape_stroke <- S7::new_class(
  name = "shape_stroke",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    width = S7::class_numeric,
    n = S7::class_integer,
    distortion = noise_field,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        path <- resample_by_length(self@x, self@y, self@n)
        normal <- stroke_normals(path$x, path$y)
        pressure <- noise_sample(self@distortion, x = path$x, y = path$y, to = c(0, 1))
        s <- seq(0, 1, length.out = self@n)
        taper <- sqrt(pmin(s, 1 - s) * 2)
        half_width <- (pressure * taper * self@width) / 2
        apply_trans(self@trans, xy(
          x = c(path$x + normal$x * half_width, rev(path$x - normal$x * half_width)),
          y = c(path$y + normal$y * half_width, rev(path$y - normal$y * half_width))
        ))
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      return("x and y must be the same length")
    }
    if (length(self@x) < 2) {
      return("at least two control points are required")
    }
    if (length(self@width) != 1) {
      return("width must be length 1")
    }
    if (length(self@n) != 1) {
      return("n must be length 1")
    }
    if (self@width < 0) {
      return("width must be a non-negative number")
    }
    if (self@n < 2L) {
      return("n must be an integer of at least 2")
    }
  },
  constructor = function(x,
                         y,
                         width = 0.2,
                         n = 100L,
                         distortion = noise_field(),
                         trans = trans_identity(),
                         ...) {
    S7::new_object(
      drawable(trans = trans, pathlike = TRUE),
      x = x,
      y = y,
      width = width,
      n = n,
      distortion = distortion,
      style = style(...)
    )
  }
)

#' Multiple strokes at once
#'
#' `shape_strokes()` is a vectorized version of [shape_stroke()]. Since
#' `x`/`y` are themselves numeric vectors of control points for a single
#' stroke, `shape_strokes()` takes them as a `list()` of numeric vectors
#' instead -- one vector of control points per stroke.
#'
#' Every other argument may be a plain vector, recycled against `x`/`y` via
#' `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). A shared `distortion` [noise_field] is automatically
#' recycled across every stroke; pass a `list()` of several different
#' `noise_field`s instead to vary it per stroke. The result is a [sketch]
#' containing one `shape_stroke()` per list element/recycled row, rather
#' than a single drawable.
#'
#' @rdname shape_stroke
#' @param x,y For `shape_stroke()`, numeric vectors of control point
#'   coordinates, the same length, with at least two control points. For
#'   `shape_strokes()`, a `list()` of such vectors instead -- one vector
#'   of control points per stroke.
#' @return For `shape_strokes()`, a [sketch].
#'
#' @examples
#' draw(shape_strokes(
#'   x = list(c(0, 1, 2, 3), c(0, 1, 2, 3)),
#'   y = list(c(0, 1, 0, 1), c(1, 2, 1, 2)),
#'   width = 0.3
#' ))
#'
#' # a shared distortion recycles across every stroke; width can vary too
#' draw(shape_strokes(
#'   x = list(c(0, 1, 2), c(0, 1, 2)),
#'   y = list(c(0, 1, 0), c(2, 3, 2)),
#'   width = c(0.15, 0.35)
#' ))
#'
#' @family 2D shapes
#' @export
shape_strokes <- function(x,
                          y,
                          width = 0.2,
                          n = 100L,
                          distortion = noise_field(),
                          trans = trans_identity(),
                          ...) {
  vectorize_shapes(shape_stroke, c(
    list(x = x, y = y, width = width, n = n, distortion = distortion, trans = trans),
    list(...)
  ))
}
