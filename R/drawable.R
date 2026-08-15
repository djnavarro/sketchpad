#' Parent class for all drawable objects
#'
#' `drawable` enforces structure on its subclasses: every drawable must
#' carry a [style], a `geometry`, and expose a computed `points` property, of
#' class [xy]. It is not intended to be instantiated directly; use one
#' of its subclasses ([shape_raw], [shape_circle], [shape_blob],
#' [shape_ribbon], [shape_twist], [curve_raw], [points_raw], ...) instead.
#'
#' `geometry` tells [draw()] which [grid] grob a drawable's `points` map to,
#' following a dimensional reading: `"points"` (0D, [grid::pointsGrob()],
#' e.g. [points_raw()]), `"path"` (1D, an open [grid::polylineGrob()], e.g.
#' [curve_line()]/[curve_raw()]), or `"polygon"` (2D, a closed
#' [grid::polygonGrob()] -- the default, and the only value any
#' `shape_*()` constructor uses). `style@fill` is ignored for
#' `"points"`/`"path"` geometries, since only a closed polygon has an
#' interior to fill.
#'
#' `trans` is a [trans] (an affine map: [trans_translate()],
#' [trans_rotate()], [trans_scale()], [trans_reflect()], [trans_shear()],
#' [trans_affine()]), a [trans_warp] (a non-rigid, noise-based
#' deformation), or a [trans_chain] combining several via `+`, applied to
#' a drawable's computed `points` as the very last step -- after any
#' shape-specific geometry (and, for [shape_blob()]/[shape_ribbon()]/
#' [shape_twist()], any noise-based distortion) has already been computed.
#' This means a drawable's own defining parameters (e.g. [shape_circle()]'s
#' centroid/radius) are never mutated or flattened by a transform -- only
#' the final rendered coordinates are affected. Default [trans_identity()]
#' (no transform).
#'
#' @param ... Arguments passed to [style()].
#' @param geometry One of `"polygon"` (default), `"path"`, or `"points"`.
#'   Not exposed as a constructor argument by any concrete drawable --
#'   each `shape_*()`/`curve_*()`/`points_raw()` constructor fixes one
#'   value internally instead (see details).
#' @param trans A [trans]/[trans_warp]/[trans_chain] object. See details.
#'
#' @examples
#' circ <- shape_circle(radius = 1)
#' S7::S7_inherits(circ, drawable)
#'
#' @family core structure
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
    trans = S7::new_property(
      class = trans_any,
      default = trans_identity()
    ),
    points = S7::new_property(
      class = xy,
      getter = function(self) xy(x = numeric(0L), y = numeric(0L))
    )
  ),
  validator = function(self) {
    if (length(self@geometry) != 1) return("geometry must be a single string")
    if (!self@geometry %in% c("polygon", "path", "points")) {
      return('geometry must be one of "polygon", "path", or "points"')
    }
  },
  constructor = function(..., geometry = "polygon", trans = trans_identity()) {
    S7::new_object(
      S7::S7_object(),
      style = style(...),
      geometry = geometry,
      trans = trans
    )
  }
)

