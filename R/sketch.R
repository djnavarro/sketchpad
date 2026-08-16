#' A collection of drawable objects
#'
#' `sketch` is a list of [drawable] objects that can be rendered together
#' with a single call to [draw()]. Sketches can be built up incrementally
#' using the `+` operator, e.g.
#' `sketch() + shape_circle() + shape_circle(x = 2)`.
#'
#' A sketch also supports list-like access to its shapes: `length(s)`
#' counts them, `s[[i]]` returns the single [drawable] at position `i`,
#' and `s[i]` returns a new sketch containing only the selected shapes
#' (its `canvas` is preserved) -- mirroring how `[[`/`[` differ on a
#' plain list.
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
#' s2 <- sketch(canvas = canvas(background = "grey95")) +
#'   shape_circle(radius = 1)
#' draw(s2)
#'
#' length(s)
#' s[[1]]
#' s[1]
#'
#' # a trans applied to a sketch composes onto every shape's own @trans
#' draw(s + trans_rotate(pi / 6))
#'
#' # accumulate many shapes in a loop, e.g. a ring of circles
#' ring <- sketch()
#' for (angle in seq(0, 2 * pi, length.out = 9)[-9]) {
#'   ring <- ring + shape_circle(x = cos(angle), y = sin(angle), radius = 0.3)
#' }
#' draw(ring)
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

#' Compose a transform onto a drawable's own `@trans`
#'
#' Internal helper shared by every `method(\`+\`, list(drawable, <trans-like>))`
#' registration below.
#'
#' @param e1 A [drawable].
#' @param e2 A [trans]/[trans_warp]/[trans_fn]/[trans_chain].
#' @return A copy of `e1` with `@trans` composed.
#' @noRd
compose_drawable_trans <- function(e1, e2) {
  e1@trans <- e1@trans + e2
  e1
}

#' Compose a transform onto every shape in a sketch
#'
#' Internal helper shared by every `method(\`+\`, list(sketch, <trans-like>))`
#' registration below.
#'
#' @param e1 A [sketch].
#' @param e2 A [trans]/[trans_warp]/[trans_fn]/[trans_chain].
#' @return A copy of `e1` with the transform composed onto every shape.
#' @noRd
compose_sketch_trans <- function(e1, e2) {
  e1@shapes <- purrr::map(e1@shapes, \(d) d + e2)
  e1
}

#' Apply a transform to a drawable with `+`
#'
#' `drawable + trans` returns a copy of `drawable` with `trans` composed
#' onto its existing `@trans` (`self@trans <- self@trans + trans`), as a
#' fluent alternative to passing `trans = ` at construction time. Also
#' works with a [trans_warp], [trans_fn], or [trans_chain] in place of
#' `trans`.
#'
#' @param e1 A [drawable].
#' @param e2 A [trans].
#' @export
#' @noRd
method(`+`, list(drawable, trans)) <- function(e1, e2) compose_drawable_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(drawable, trans_warp)) <- function(e1, e2) compose_drawable_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(drawable, trans_fn)) <- function(e1, e2) compose_drawable_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(drawable, trans_chain)) <- function(e1, e2) compose_drawable_trans(e1, e2)

#' Apply a transform to every shape in a sketch with `+`
#'
#' `sketch + trans` composes `trans` onto every shape's own `@trans`,
#' transforming the whole composition at once. Also works with a
#' [trans_warp], [trans_fn], or [trans_chain] in place of `trans`.
#'
#' @param e1 A [sketch].
#' @param e2 A [trans].
#' @export
#' @noRd
method(`+`, list(sketch, trans)) <- function(e1, e2) compose_sketch_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(sketch, trans_warp)) <- function(e1, e2) compose_sketch_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(sketch, trans_fn)) <- function(e1, e2) compose_sketch_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(sketch, trans_chain)) <- function(e1, e2) compose_sketch_trans(e1, e2)

#' @export
#' @noRd
method(length, sketch) <- function(x) length(x@shapes)

#' @export
#' @noRd
method(`[[`, sketch) <- function(x, i) x@shapes[[i]]

#' @export
#' @noRd
method(`[`, sketch) <- function(x, i) {
  x@shapes <- x@shapes[i]
  x
}
