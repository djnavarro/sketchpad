#' A scatter of points defined directly by their coordinates
#'
#' `points_raw` is [shape_raw]'s `"points"`-geometry analog, and the first
#' concrete constructor to use `geometry = "points"` (previously reserved
#' on the dimensional reading `"points"`(0D)/`"path"`(1D)/`"polygon"`(2D),
#' but with no constructor exposing it -- see `.agents/PLAN.md`). The user
#' supplies `x`/`y` coordinates directly, rendered as unconnected markers
#' rather than a connected outline or path.
#'
#' `style@fill` and every line-related `style` property (`linewidth`,
#' `linetype`, `linejoin`, `lineend`, `linemitre`) have no effect for
#' `points_raw()` -- see [drawable]'s `geometry` documentation and
#' `geometry_grob()`'s internal dispatch (`R/draw.R`) for why a `"points"`
#' geometry has no line to stroke and no interior to fill. Only `style@color`
#' is used, as the marker colour.
#'
#' @param x,y Numeric vectors of x/y coordinates.
#' @param trans A [trans] object applied to the computed points. Default
#'   [trans_identity()] (no transform).
#' @param ... Arguments passed to [style()].
#' @return A [drawable].
#'
#' @examples
#' draw(points_raw(
#'   x = seq(0, 1, length.out = 20),
#'   y = sin(seq(0, 2 * pi, length.out = 20)) / 2 + 0.5,
#'   color = "steelblue"
#' ))
#'
#' # a random scatter, and the same points converted from a polygon's
#' # own outline (only style-related properties survive the round trip)
#' draw(points_raw(x = runif(200), y = runif(200)))
#' draw(S7::convert(
#'   shape_blob(radius = 1, distortion = noise_field(seed = 42L)),
#'   points_raw
#' ))
#'
#' # points_raw() is pathlike, so effect_tremor() can wobble the scatter
#' draw(effect_tremor(
#'   points_raw(x = seq(0, 1, length.out = 30), y = rep(0.5, 30)),
#'   layers = 6L, jitter = 0.08
#' ))
#'
#' @family 0D points
#' @export
points_raw <- S7::new_class(
  name = "points_raw",
  parent = drawable,
  properties = list(
    x = S7::class_numeric,
    y = S7::class_numeric,
    points = S7::new_property(
      class = xy,
      getter = function(self) {
        apply_trans(self@trans, xy(x = self@x, y = self@y))
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      "x and y must be the same length"
    }
  },
  constructor = function(x, y, trans = trans_identity(), ...) {
    S7::new_object(
      drawable(geometry = "points", trans = trans, pathlike = TRUE),
      x = x,
      y = y,
      style = style(...)
    )
  }
)

#' Multiple point scatters at once
#'
#' `points_raws()` is a vectorized version of [points_raw()]. Since
#' `x`/`y` are themselves numeric vectors of point coordinates for a
#' single scatter, `points_raws()` takes them as a `list()` of numeric
#' vectors instead -- one vector per scatter -- which is most useful for
#' giving several distinct scatters different `style` arguments (e.g. a
#' different `color` each).
#'
#' Every other argument may be a plain vector, recycled against `x`/`y`
#' via `purrr::pmap()`'s own vctrs-based rules (any length-1 element is
#' broadcast to the common length; mismatched lengths greater than 1
#' raise an error). The result is a [sketch] containing one
#' `points_raw()` per list element/recycled row, rather than a single
#' drawable.
#'
#' @rdname points_raw
#' @param x,y For `points_raw()`, a numeric vector of x/y coordinates. For
#'   `points_raws()`, a `list()` of such vectors instead -- one vector
#'   per scatter.
#' @return For `points_raws()`, a [sketch].
#'
#' @examples
#' draw(points_raws(
#'   x = list(seq(0, 1, length.out = 10), seq(0, 1, length.out = 10)),
#'   y = list(rep(0.25, 10), rep(0.75, 10)),
#'   color = c("steelblue", "darkred")
#' ))
#'
#' @family 0D points
#' @export
points_raws <- function(x, y, trans = trans_identity(), ...) {
  vectorize_shapes(points_raw, c(
    list(x = x, y = y, trans = trans),
    list(...)
  ))
}
