#' Parent class for all drawable objects
#'
#' `drawable` enforces structure on its subclasses: every drawable must
#' carry a [style], a `geometry`, and expose a computed `points` property, of
#' class [point_set]. It is not intended to be instantiated directly; use one
#' of its subclasses ([shape_raw], [shape_circle], [shape_blob],
#' [shape_ribbon], [shape_twist]) instead.
#'
#' `geometry` tells [draw()] which [grid] grob a drawable's `points` map to,
#' following a dimensional reading: `"points"` (0D, [grid::pointsGrob()]),
#' `"path"` (1D, an open [grid::polylineGrob()]), or `"polygon"` (2D, a
#' closed [grid::polygonGrob()] -- the default, and the only value any
#' current `shape_*()` constructor uses). `style@fill` is ignored for
#' `"points"`/`"path"` geometries, since only a closed polygon has an
#' interior to fill.
#'
#' @param ... Arguments passed to [style()].
#' @param geometry One of `"polygon"` (default), `"path"`, or `"points"`.
#'   Not currently exposed by any concrete `shape_*()` constructor -- see
#'   details.
#'
#' @export
drawable <- S7::new_class(
  name = "drawable",
  properties = list(
    style = S7::new_property(
      class = style,
      default = style()
    ),
    geometry = S7::new_property(
      class = S7::class_character,
      default = "polygon"
    ),
    points = S7::new_property(
      class = point_set,
      getter = function(self) point_set(x = numeric(0L), y = numeric(0L))
    )
  ),
  validator = function(self) {
    if (length(self@geometry) != 1) return("geometry must be a single string")
    if (!self@geometry %in% c("polygon", "path", "points")) {
      return('geometry must be one of "polygon", "path", or "points"')
    }
  },
  constructor = function(..., geometry = "polygon") {
    S7::new_object(S7::S7_object(), style = style(...), geometry = geometry)
  }
)

