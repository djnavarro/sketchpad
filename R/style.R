#' @noRd
fill_class <- S7::new_union(S7::class_character, S7::new_S3_class("GridPattern"))

#' Graphical style for a drawable object
#'
#' `style` is a container for the graphical properties passed to
#' [grid::gpar()] when a [drawable] object is drawn.
#'
#' @param color Stroke colour. Default `"black"`.
#' @param fill Fill colour or pattern. Either a plain colour string, or the
#'   output of a `fill_*()` helper -- [fill_solid()], [fill_none()],
#'   [fill_hatch()], [fill_crosshatch()], [fill_stipple()], [fill_noise()],
#'   [fill_gradient()], or [fill_vignette()]. Default `fill_solid("black")`
#'   (i.e. `"black"`).
#' @param linewidth Line width. Default `1`.
#' @param linetype Line dash pattern, forwarded to [grid::gpar()]'s `lty`.
#'   Either a named type (`"solid"`, `"dashed"`, `"dotted"`, `"dotdash"`,
#'   `"longdash"`, `"twodash"`, `"blank"`), an integer code `0:6`, or a
#'   custom hex dash-pattern string (e.g. `"13"`) -- see [grid::gpar()] and
#'   `graphics::par()`'s `lty` for the full set of accepted forms, which
#'   aren't independently re-validated here. Default `"solid"`.
#' @param linejoin Line join style at each vertex, forwarded to
#'   [grid::gpar()]'s `linejoin`. One of `"round"`, `"mitre"`, or `"bevel"`.
#'   Most visible on closed shapes with few, sharp vertices, or on any
#'   drawable stroked with a thick `linewidth`. Default `"round"`.
#' @param lineend Line end style at a path's free endpoints, forwarded to
#'   [grid::gpar()]'s `lineend`. One of `"round"`, `"butt"`, or `"square"`.
#'   Only visible on `"path"`-geometry drawables (e.g. [curve_line()],
#'   [curve_bezier()]) -- a `"polygon"`-geometry drawable has no free
#'   endpoint, since its outline closes back on itself. Most visible at a
#'   thick `linewidth`. Default `"round"`.
#' @param linemitre Mitre limit, forwarded to [grid::gpar()]'s `linemitre`.
#'   Only takes effect when `linejoin = "mitre"`: at a vertex sharper than
#'   this limit allows, the mitred corner is truncated to a bevel instead,
#'   to avoid an arbitrarily long spike. Must be at least `1`. Default `10`,
#'   matching [grid::gpar()]'s own default.
#' @param color_alpha Stroke opacity, applied to `color` independently of
#'   `fill_alpha`. Must be a number in `[0, 1]`, where `0` is fully
#'   transparent and `1` (the default) is fully opaque. Applied by baking
#'   the value into `color` via [grDevices::adjustcolor()] at draw time
#'   (see [draw()]'s internal `apply_alpha()` helper), not via
#'   [grid::gpar()]'s own `alpha` argument -- `gpar()`'s `alpha` applies
#'   uniformly to both stroke and fill on the same grob, which would
#'   couple `color_alpha` and `fill_alpha` together. If `color` already
#'   has its own alpha channel (e.g. an `"#RRGGBBAA"` hex string),
#'   `color_alpha` multiplies through it rather than overriding it.
#' @param rule Fill rule used when a drawable's own `points` has more than
#'   one sub-path (see [xy]'s `id`), forwarded to [grid::pathGrob()]'s own
#'   `rule` argument. One of `"evenodd"` (default) or `"winding"`.
#'   `"evenodd"` fills a region if it's enclosed by an odd number of
#'   sub-paths, regardless of each sub-path's own vertex winding direction
#'   -- a sub-path nested inside another becomes a hole purely from
#'   geometric nesting, with no need to get vertex order right by hand,
#'   which is why it's the default. `"winding"` instead fills based on net
#'   signed winding number, which depends on each sub-path's own direction
#'   -- only useful for constructions that specifically need that
#'   direction-sensitive behavior. Has no effect on a drawable with only
#'   one implicit sub-path (every current `shape_*()`/`curve_*()`
#'   constructor), since both rules agree there.
#' @param fill_alpha Fill opacity, applied to `fill` independently of
#'   `color_alpha`, via the same [grDevices::adjustcolor()] mechanism as
#'   `color_alpha`. Must be a number in `[0, 1]`. Default `1`. Only has an
#'   effect when `fill` is a plain colour string (as from [fill_solid()]
#'   or [fill_none()]) -- **silently inert when `fill` is a pattern or
#'   gradient** (the output of any other `fill_*()` helper), since
#'   [grDevices::adjustcolor()] has no defined effect on a `GridPattern`
#'   object. This mirrors `fill` itself already having no effect for
#'   `"path"`/`"points"`-geometry drawables (see [drawable]'s `geometry`
#'   docs), and `lineend`/`linemitre` already being inert for some
#'   geometries -- geometry- or fill-type-conditional inertness, not an
#'   error, is this package's existing convention for style properties
#'   that don't universally apply.
#'
#' @examples
#' style(color = "steelblue", fill = "lightblue", linewidth = 2)
#' style(fill = fill_hatch(angle = 30))
#'
#' # linejoin/linemitre are most visible on a thick-stroked shape with a
#' # sharp vertex
#' star <- shape_polygon(n = 5, radius = 1, fill = "white")
#' draw(shape_stroke(
#'   x = star@points@x, y = star@points@y, width = 0.25,
#'   linejoin = "mitre", linemitre = 1.5
#' ))
#'
#' # color_alpha/fill_alpha control stroke/fill opacity independently
#' draw(shape_circle(
#'   radius = 1, color = "black", fill = "tomato",
#'   color_alpha = 1, fill_alpha = 0.3, linewidth = 3
#' ))
#'
#' # lineend only affects a path's free endpoints, not a closed polygon
#' draw(curve_line(
#'   x = c(0, 1, 2), y = c(0, 1, 0), linewidth = 15, lineend = "square"
#' ))
#'
#' @family core structure
#' @export
style <- S7::new_class(
  name = "style",
  properties = list(
    color = S7::new_property(S7::class_character, default = "black"),
    fill = S7::new_property(fill_class, default = fill_solid("black")),
    linewidth = S7::new_property(S7::class_numeric, default = 1),
    linetype = S7::new_property(
      S7::new_union(S7::class_character, S7::class_numeric),
      default = "solid"
    ),
    linejoin = S7::new_property(S7::class_character, default = "round"),
    lineend = S7::new_property(S7::class_character, default = "round"),
    linemitre = S7::new_property(S7::class_numeric, default = 10),
    rule = S7::new_property(S7::class_character, default = "evenodd"),
    color_alpha = S7::new_property(S7::class_numeric, default = 1),
    fill_alpha = S7::new_property(S7::class_numeric, default = 1)
  ),
  validator = function(self) {
    if (length(self@rule) != 1) {
      return("rule must be a single string")
    }
    if (!self@rule %in% c("evenodd", "winding")) {
      return('rule must be one of "evenodd" or "winding"')
    }
    if (length(self@linetype) != 1) {
      return("linetype must be a single value")
    }
    if (length(self@linejoin) != 1) {
      return("linejoin must be a single string")
    }
    if (!self@linejoin %in% c("round", "mitre", "bevel")) {
      return('linejoin must be one of "round", "mitre", or "bevel"')
    }
    if (length(self@lineend) != 1) {
      return("lineend must be a single string")
    }
    if (!self@lineend %in% c("round", "butt", "square")) {
      return('lineend must be one of "round", "butt", or "square"')
    }
    if (length(self@linemitre) != 1) {
      return("linemitre must be a single number")
    }
    if (self@linemitre < 1) {
      return("linemitre must be at least 1")
    }
    if (length(self@color_alpha) != 1) {
      return("color_alpha must be a single number")
    }
    if (self@color_alpha < 0 || self@color_alpha > 1) {
      return("color_alpha must be between 0 and 1")
    }
    if (length(self@fill_alpha) != 1) {
      return("fill_alpha must be a single number")
    }
    if (self@fill_alpha < 0 || self@fill_alpha > 1) {
      return("fill_alpha must be between 0 and 1")
    }
  }
)
