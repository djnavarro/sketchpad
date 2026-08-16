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
#' `pathlike` marks whether `x`/`y` (where present) hold a genuine,
#' caller-ordered, perturbable control-point path -- as opposed to `x`/`y`
#' meaning something else entirely (e.g. [shape_circle()]'s centroid, or
#' one fixed endpoint of [shape_ribbon()]'s two-point segment). This is
#' the distinction [effect_tremor()]/[effect_bristle()] need to decide whether
#' jittering `x`/`y` produces a meaningful wobble; it's orthogonal to
#' `geometry` -- a `pathlike` drawable can have any `geometry` (a future
#' `points_*()` constructor could reasonably be `pathlike` despite
#' `geometry == "points"`). Currently `TRUE` for [shape_raw()],
#' [curve_raw()], [curve_line()], [shape_stroke()], [shape_bezier()],
#' [curve_bezier()], and [points_raw()]; `FALSE` (the default) for every
#' other concrete drawable, including [shape_ribbon()]/[shape_twist()]/
#' [curve_twist()] -- these do have a conceptual
#' backbone, but it's exposed via `x`/`y`/`xend`/`yend` (or additional
#' named control-point pairs), not a plain `x`/`y` vector. Whether a
#' `pathlike` subclass actually has `x`/`y` properties is not enforced by
#' `drawable`'s own validator -- every subclass constructor first builds
#' a scaffold `drawable()` instance (validated on its own, before any
#' subclass property exists) and only merges in `x`/`y` afterward via
#' `S7::new_object()`, so a cross-property check here would fire on that
#' scaffold and reject every `pathlike` subclass unconditionally (see
#' "Gotchas"). Setting `pathlike = TRUE` on a subclass with no `x`/`y` is
#' therefore an author error caught only when an effect tries to read
#' `object@x`/`object@y`, not at construction time.
#'
#' @param ... Arguments passed to [style()].
#' @param geometry One of `"polygon"` (default), `"path"`, or `"points"`.
#'   Not exposed as a constructor argument by any concrete drawable --
#'   each `shape_*()`/`curve_*()`/`points_raw()` constructor fixes one
#'   value internally instead (see details).
#' @param trans A [trans]/[trans_warp]/[trans_chain] object. See details.
#' @param pathlike A single `TRUE`/`FALSE` (default `FALSE`). Not exposed
#'   as a constructor argument by any concrete drawable -- each fixes its
#'   own value internally, the same convention `geometry` follows. See
#'   details.
#'
#' @examples
#' circ <- shape_circle(radius = 1)
#' S7::S7_inherits(circ, drawable)
#'
#' # geometry controls which grob draw() builds: a closed outline, an open
#' # stroke, or unconnected markers
#' draw(shape_circle(radius = 1, n = 8))
#' draw(curve_line(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), linewidth = 3))
#' draw(points_raw(x = runif(30), y = runif(30)))
#'
#' # trans applies after a shape's own geometry/distortion is computed, so
#' # shape_rectangle()'s centroid/width/height stay fixed -- only the final
#' # rendered corners rotate
#' draw(shape_rectangle(
#'   width = 1.5,
#'   height = 0.5,
#'   trans = trans_rotate(pi / 6)
#' ))
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
    pathlike = S7::new_property(
      class = S7::class_logical,
      default = FALSE
    ),
    points = S7::new_property(
      class = xy,
      getter = function(self) xy(x = numeric(0L), y = numeric(0L))
    )
  ),
  validator = function(self) {
    if (length(self@geometry) != 1) {
      return("geometry must be a single string")
    }
    if (!self@geometry %in% c("polygon", "path", "points")) {
      return('geometry must be one of "polygon", "path", or "points"')
    }
    if (length(self@pathlike) != 1 || !is.logical(self@pathlike) || is.na(self@pathlike)) {
      return("pathlike must be a single TRUE/FALSE value")
    }
  },
  constructor = function(..., geometry = "polygon", trans = trans_identity(), pathlike = FALSE) {
    S7::new_object(
      S7::S7_object(),
      style = style(...),
      geometry = geometry,
      trans = trans,
      pathlike = pathlike
    )
  }
)
