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
#'
#' @export
style <- S7::new_class(
  name = "style",
  properties = list(
    color     = S7::new_property(S7::class_character, default = "black"),
    fill      = S7::new_property(fill_class, default = fill_solid("black")),
    linewidth = S7::new_property(S7::class_numeric, default = 1)
  )
)
