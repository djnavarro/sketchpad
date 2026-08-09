#' A collection of drawable objects
#'
#' `sketch` is a list of [drawable] objects that can be rendered together
#' with a single call to [draw()]. Sketches can be built up incrementally
#' using the `+` operator, e.g.
#' `sketch() + shape_circle() + shape_circle(x = 2)`.
#'
#' @param shapes A list of [drawable]-classed objects. Default `list()`.
#'
#' @examples
#' \dontrun{
#' s <- sketch() + shape_circle(radius = 1) + shape_circle(x = 2, radius = 0.5)
#' draw(s)
#' }
#'
#' @family core structure
#' @export
sketch <- S7::new_class(
  name = "sketch",
  properties = list(
    shapes = S7::new_property(class = S7::class_list, default = list())
  ),
  validator = function(self) {
    if (!all(purrr::map_lgl(self@shapes, \(d) S7::S7_inherits(d, drawable)))) {
      "shapes must be a list of drawable-classed objects"
    }
  }
)

#' @export
#' @noRd
method(`+`, list(sketch, drawable)) <- function(e1, e2) {
  e1@shapes <- c(e1@shapes, e2)
  e1
}

