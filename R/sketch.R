#' A collection of drawable objects
#'
#' `sketch` is a list of [drawable] objects that can be rendered together
#' with a single call to [draw()]. Sketches can be built up incrementally
#' using the `+` operator, e.g.
#' `sketch() + shape_circle() + shape_circle(x = 2)`.
#'
#' @param shapes A list of [drawable]-classed objects. Default `list()`.
#' @param canvas A [canvas] object, giving the background/framing settings
#'   [draw()] applies to the sketch as a whole. Default `canvas()` (no
#'   background, axis limits computed from `shapes`).
#'
#' @examples
#' s <- sketch() + shape_circle(radius = 1) + shape_circle(x = 2, radius = 0.5)
#' draw(s)
#'
#' s2 <- sketch(canvas = canvas(background = "grey95")) + shape_circle(radius = 1)
#' draw(s2)
#'
#' @family core structure
#' @export
sketch <- S7::new_class(
  name = "sketch",
  properties = list(
    shapes = S7::class_list,
    canvas = canvas
  ),
  validator = function(self) {
    if (!all(purrr::map_lgl(self@shapes, \(d) S7::S7_inherits(d, drawable)))) {
      "shapes must be a list of drawable-classed objects"
    }
  },
  # explicit argument defaults (rather than new_property(default = ...))
  # keep the auto-generated constructor's roxygen \usage line valid --
  # embedding a pre-built canvas() object directly as a property default
  # renders as an unparseable "<object>" literal in the Rd \usage section.
  # `sketchpad::canvas()` (rather than bare `canvas()`) is required here,
  # not just stylistic: the `canvas` argument's own name shadows the
  # `canvas` class/constructor within this function's evaluation frame, so
  # an unqualified `canvas()` default recurses onto the argument's own
  # unevaluated promise instead of calling the constructor.
  constructor = function(shapes = list(), canvas = sketchpad::canvas()) {
    S7::new_object(S7::S7_object(), shapes = shapes, canvas = canvas)
  }
)

#' @export
#' @noRd
method(`+`, list(sketch, drawable)) <- function(e1, e2) {
  e1@shapes <- c(e1@shapes, e2)
  e1
}

