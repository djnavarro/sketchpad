#' Graphical style for a drawable object
#'
#' `style` is a container for the graphical properties passed to
#' [grid::gpar()] when a [drawable] object is drawn.
#'
#' @param color Stroke colour. Default `"black"`.
#' @param fill Fill colour. Default `"black"`.
#' @param linewidth Line width. Default `1`.
#'
#' @export
style <- S7::new_class(
  name = "style",
  properties = list(
    color     = S7::new_property(S7::class_character, default = "black"),
    fill      = S7::new_property(S7::class_character, default = "black"),
    linewidth = S7::new_property(S7::class_numeric, default = 1)
  )
)

