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
#'
#' @family core structure
#' @export
style <- S7::new_class(
  name = "style",
  properties = list(
    color     = S7::new_property(S7::class_character, default = "black"),
    fill      = S7::new_property(fill_class, default = fill_solid("black")),
    linewidth = S7::new_property(S7::class_numeric, default = 1),
    linetype  = S7::new_property(
      S7::new_union(S7::class_character, S7::class_numeric),
      default = "solid"
    ),
    linejoin  = S7::new_property(S7::class_character, default = "round"),
    lineend   = S7::new_property(S7::class_character, default = "round"),
    linemitre = S7::new_property(S7::class_numeric, default = 10)
  ),
  validator = function(self) {
    if (length(self@linetype) != 1) return("linetype must be a single value")
    if (length(self@linejoin) != 1) return("linejoin must be a single string")
    if (!self@linejoin %in% c("round", "mitre", "bevel")) {
      return('linejoin must be one of "round", "mitre", or "bevel"')
    }
    if (length(self@lineend) != 1) return("lineend must be a single string")
    if (!self@lineend %in% c("round", "butt", "square")) {
      return('lineend must be one of "round", "butt", or "square"')
    }
    if (length(self@linemitre) != 1) return("linemitre must be a single number")
    if (self@linemitre < 1) return("linemitre must be at least 1")
  }
)
