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
#'
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
    linejoin  = S7::new_property(S7::class_character, default = "round")
  ),
  validator = function(self) {
    if (length(self@linetype) != 1) return("linetype must be a single value")
    if (length(self@linejoin) != 1) return("linejoin must be a single string")
    if (!self@linejoin %in% c("round", "mitre", "bevel")) {
      return('linejoin must be one of "round", "mitre", or "bevel"')
    }
  }
)
