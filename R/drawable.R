#' Parent class for all drawable objects
#'
#' `drawable` enforces structure on its subclasses: every drawable must
#' carry a [style] and expose a computed `points` property, of class
#' [point_set]. It is not intended to be instantiated directly; use one of
#' its subclasses ([shape_raw], [shape_circle], [shape_blob], [shape_ribbon],
#' [shape_twist]) instead.
#'
#' @param ... Arguments passed to [style()].
#'
#' @export
drawable <- S7::new_class(
  name = "drawable",
  properties = list(
    style = S7::new_property(
      class = style,
      default = style()
    ),
    points = S7::new_property(
      class = point_set,
      getter = function(self) point_set(x = numeric(0L), y = numeric(0L))
    )
  ),
  constructor = function(...) S7::new_object(S7::S7_object(), style = style(...))
)

