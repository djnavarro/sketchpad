#' Build a 2D homogeneous translation matrix
#' @noRd
mat_translate <- function(dx, dy) {
  matrix(c(
    1, 0, dx,
    0, 1, dy,
    0, 0, 1
  ), nrow = 3, byrow = TRUE)
}

#' Build a 2D homogeneous scale matrix
#' @noRd
mat_scale <- function(sx, sy) {
  matrix(c(
    sx, 0,  0,
    0,  sy, 0,
    0,  0,  1
  ), nrow = 3, byrow = TRUE)
}

#' Build a 2D homogeneous rotation matrix
#' @noRd
mat_rotate <- function(angle) {
  matrix(c(
    cos(angle), -sin(angle), 0,
    sin(angle), cos(angle), 0,
    0, 0, 1
  ), nrow = 3, byrow = TRUE)
}

#' Build a 2D homogeneous shear matrix
#' @noRd
mat_shear <- function(shx, shy) {
  matrix(c(
    1,   shx, 0,
    shy, 1,   0,
    0,   0,   1
  ), nrow = 3, byrow = TRUE)
}

#' Wrap a linear matrix so it acts about an arbitrary pivot point
#'
#' `m` is applied as `translate(about) %*% m %*% translate(-about)`, i.e.
#' the pivot is translated to the origin, `m` is applied, then the pivot is
#' translated back.
#'
#' @noRd
mat_about <- function(m, about_x, about_y) {
  mat_translate(about_x, about_y) %*% m %*% mat_translate(-about_x, -about_y)
}

#' A 2D affine transformation
#'
#' `trans` wraps a 3x3 homogeneous-coordinates affine transformation
#' matrix. It is not usually constructed directly -- use [trans_identity()],
#' [trans_translate()], [trans_rotate()], [trans_scale()],
#' [trans_reflect()], [trans_shear()], or the general-purpose
#' [trans_affine()] instead.
#'
#' Every [drawable] carries a `trans` property (default [trans_identity()])
#' that's applied to its computed `points` as the very last step -- see
#' [drawable]'s `trans` documentation.
#'
#' Two `trans` objects combine with `+`: `t1 + t2` produces a new `trans`
#' whose effect is "apply `t1` first, then `t2`" -- see [trans_translate()]'s
#' Details for the composition order convention and a worked example.
#' Composing a `trans` with a [trans_warp] (a non-rigid, noise-based
#' deformation) or a [trans_fn] (a non-rigid deformation from an
#' arbitrary caller-supplied function) -- neither of which can be
#' represented as a matrix -- instead produces a [trans_chain] -- see
#' there.
#'
#' @param matrix A 3x3 numeric matrix in homogeneous coordinates (i.e. its
#'   third row must be `c(0, 0, 1)`).
#'
#' @examples
#' trans_identity()
#' trans_translate(1, 0) + trans_rotate(pi / 4)
#'
#' # overlay a shape's original outline (faded) with a transformed copy
#' # (solid) to see a trans's effect directly
#' original <- shape_rectangle(
#'   width = 1.5,
#'   height = 0.6,
#'   fill_alpha = 0.3,
#'   color_alpha = 0.3
#' )
#' draw(sketch() + original + (original + trans_rotate(pi / 6)))
#'
#' @family transform helpers
#' @export
trans <- S7::new_class(
  name = "trans",
  properties = list(
    matrix = S7::class_numeric
  ),
  validator = function(self) {
    if (!is.matrix(self@matrix)) {
      return("matrix must be a matrix")
    }
    if (!identical(dim(self@matrix), c(3L, 3L))) {
      return("matrix must be a 3x3 matrix")
    }
    if (!isTRUE(all.equal(unname(self@matrix[3, ]), c(0, 0, 1)))) {
      return("matrix's third row must be c(0, 0, 1) (a valid affine transform)")
    }
  }
)

#' A non-rigid, noise-based deformation
#'
#' `trans_warp` displaces each point by simplex/fractal noise sampled at
#' the point's own `(x, y)` position (domain warping), giving a wobbly,
#' non-rigid distortion rather than an affine map.
#'
#' Unlike [trans] (translate/rotate/scale/reflect/shear), this can't be
#' represented as a single matrix, since the displacement varies smoothly
#' but irregularly from point to point.
#'
#' The x and y displacements are sampled from two independent
#' [noise_field]s (`distortion_x`/`distortion_y`), each rescaled to
#' `[-1, 1]` and multiplied by `amount`. By default `distortion_y` reuses
#' `distortion_x`'s own settings with its seed offset by `1`, so the two
#' axes wander independently without the caller needing to specify two
#' full [noise_field] objects -- the same convention
#' `twisted_path_points()` uses internally for [shape_twist()]'s path.
#'
#' Like [trans], a `trans_warp` is attached to a [drawable] via its
#' `trans` property/argument, and composes with `+` -- combining it with
#' another `trans_warp`, a [trans_fn], or a [trans] produces a
#' [trans_chain], since a non-rigid warp can't collapse into a single
#' matrix. See [trans_fn()] for a general-purpose escape hatch taking an
#' arbitrary caller-supplied displacement function, rather than only a
#' [noise_field]-driven one.
#'
#' @param amount Displacement amplitude. Must be non-negative. Default
#'   `0.1`.
#' @param distortion_x A [noise_field] controlling the x displacement.
#'   Default `noise_field()`.
#' @param distortion_y A [noise_field] controlling the y displacement.
#'   Default `distortion_x`, with its seed offset by `1`.
#'
#' @examples
#' draw(shape_circle(radius = 1, n = 200, trans = trans_warp(amount = 0.15)))
#'
#' # a smaller amount gives a subtler wobble; distortion_x's own frequency
#' # controls how quickly the warp varies across space
#' draw(shape_circle(radius = 1, n = 200, trans = trans_warp(amount = 0.03)))
#' draw(shape_circle(
#'   radius = 1, n = 200,
#'   trans = trans_warp(amount = 0.1, distortion_x = noise_field(frequency = 4))
#' ))
#'
#' @family transform helpers
#' @export
trans_warp <- S7::new_class(
  name = "trans_warp",
  properties = list(
    amount       = S7::class_numeric,
    distortion_x = noise_field,
    distortion_y = noise_field
  ),
  validator = function(self) {
    if (length(self@amount) != 1) {
      return("amount must be length 1")
    }
    if (self@amount < 0) {
      return("amount must be a non-negative number")
    }
  },
  constructor = function(amount = 0.1,
                         distortion_x = noise_field(),
                         distortion_y = noise_field(seed = distortion_x@seed + 1L)) {
    S7::new_object(
      S7::S7_object(),
      amount = amount,
      distortion_x = distortion_x,
      distortion_y = distortion_y
    )
  }
)

#' An arbitrary-function, non-rigid deformation
#'
#' `trans_fn` is the general-purpose escape hatch for a non-rigid
#' deformation not covered by [trans_warp()]'s noise-driven domain
#' warping: it wraps a caller-supplied displacement function directly,
#' the same relationship [trans_affine()] has to the rigid `trans_*()`
#' family.
#'
#' `fn` is called as `fn(x, y)`, where `x`/`y` are a [drawable]'s own
#' computed points (already flattened to plain numeric vectors, not an
#' [xy] object), and must return a `list(x = ..., y = ...)` of the same
#' length -- checked at draw/apply time (not at construction), since
#' `fn`'s own behavior can't be verified without calling it. This makes
#' `trans_fn` strictly more general than [trans_warp()]: any noise-based
#' warp could be expressed as a `trans_fn` closing over a [noise_field],
#' but also deterministic formulas (a swirl, pinch, or bulge) or a warp
#' driven by something [noise_field] can't express at all, e.g. a second
#' drawable's own geometry captured in `fn`'s enclosing environment.
#'
#' Like [trans_warp], this can't be represented as a single matrix, so
#' composing it with a [trans] or another non-rigid deformation with `+`
#' produces a [trans_chain] rather than collapsing.
#'
#' @param fn A function taking two numeric vectors (`x`, `y`) and
#'   returning a `list(x = ..., y = ...)` of the same length.
#'
#' @examples
#' # a deterministic swirl: rotate each point by an angle that grows with
#' # its own distance from the origin. A shape centred at the origin
#' # (e.g. a plain shape_circle()) is rotationally symmetric about it, so
#' # every point shares the same distance and the swirl just rotates the
#' # whole shape rigidly -- offsetting the shape away from the origin
#' # gives points at varying distances instead, showing the effect
#' swirl <- function(x, y) {
#'   r <- sqrt(x^2 + y^2)
#'   theta <- atan2(y, x) + r * 1.5
#'   list(x = r * cos(theta), y = r * sin(theta))
#' }
#' draw(shape_circle(x = 1, radius = 0.4, n = 200, trans = trans_fn(swirl)))
#'
#' # a bulge: points near the origin are pushed outward more than points
#' # far from it. Offsetting the shape away from the origin (for the same
#' # reason as the swirl example above) means one side sits closer to the
#' # origin than the other, so the bulge dents that side outward more
#' bulge <- function(x, y) {
#'   r <- sqrt(x^2 + y^2)
#'   scale_factor <- 1 + 0.6 * exp(-4 * r^2)
#'   list(x = x * scale_factor, y = y * scale_factor)
#' }
#' draw(shape_circle(x = 0.8, radius = 0.5, n = 200, trans = trans_fn(bulge)))
#'
#' # combining a trans_fn with a trans (or a trans_warp) produces a
#' # trans_chain, applied in the order given by +
#' draw(shape_circle(
#'   x = 0.8, radius = 0.5, n = 200,
#'   trans = trans_fn(bulge) + trans_rotate(pi / 6)
#' ))
#'
#' @family transform helpers
#' @export
trans_fn <- S7::new_class(
  name = "trans_fn",
  properties = list(
    fn = S7::class_function
  )
)

#' A sequence of composed transforms
#'
#' `trans_chain` is what `+` produces when combining transforms that can't
#' collapse into a single [trans] matrix -- e.g. a [trans_warp] with
#' another [trans_warp], or a [trans_warp] mixed with a [trans]. It is not
#' usually constructed directly; it holds an ordered list of `steps`
#' (each a [trans], [trans_warp], or [trans_fn]), applied in sequence --
#' `steps[[1]]` first, `steps[[length(steps)]]` last -- exactly like
#' chained `+` calls on a [drawable] would suggest.
#'
#' Two consecutive [trans] (affine) steps are *not* automatically
#' collapsed into one matrix when they're already part of a chain (only a
#' bare `trans + trans` collapses); this only costs a little efficiency,
#' not correctness.
#'
#' @param steps A list of [trans]/[trans_warp]/`trans_chain` objects.
#'
#' @examples
#' # combining an affine trans with a trans_warp produces a trans_chain,
#' # applied in the order given by +
#' chained <- trans_rotate(pi / 6) + trans_warp(amount = 0.08)
#' chained
#' draw(shape_rectangle(width = 1.5, height = 0.6, trans = chained))
#'
#' @family transform helpers
#' @export
trans_chain <- S7::new_class(
  name = "trans_chain",
  properties = list(
    steps = S7::class_list
  ),
  validator = function(self) {
    ok <- vapply(
      self@steps,
      \(s) {
        S7::S7_inherits(s, trans) || S7::S7_inherits(s, trans_warp) ||
          S7::S7_inherits(s, trans_fn) || S7::S7_inherits(s, trans_chain)
      },
      logical(1)
    )
    if (!all(ok)) {
      return("steps must be a list of trans/trans_warp/trans_fn/trans_chain objects")
    }
  }
)

#' Flatten a trans-like object into a list of steps
#'
#' Internal helper used when composing two trans-like objects with `+`:
#' a [trans_chain] contributes its own `steps`, anything else contributes
#' itself as a single-element list.
#'
#' @param x A [trans]/[trans_warp]/[trans_chain].
#' @return A list.
#' @noRd
trans_steps <- function(x) {
  if (S7::S7_inherits(x, trans_chain)) x@steps else list(x)
}

#' Combine two trans-like objects
#'
#' Internal helper backing every `+` method between [trans]/[trans_warp]/
#' [trans_fn]/[trans_chain] objects: two plain [trans] (affine) objects
#' collapse into a single [trans] via matrix multiplication (unchanged
#' from `trans`'s original behavior); any combination involving a
#' [trans_warp], [trans_fn], or [trans_chain] instead builds/extends a
#' [trans_chain], since a non-rigid warp has no matrix representation to
#' fold into.
#'
#' @param e1,e2 A [trans]/[trans_warp]/[trans_chain].
#' @return A [trans] or [trans_chain].
#' @noRd
combine_trans <- function(e1, e2) {
  if (S7::S7_inherits(e1, trans) && S7::S7_inherits(e2, trans)) {
    return(trans(matrix = e2@matrix %*% e1@matrix))
  }
  trans_chain(steps = c(trans_steps(e1), trans_steps(e2)))
}

#' @export
#' @noRd
method(`+`, list(trans, trans)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans, trans_warp)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans, trans_chain)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_warp, trans)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_warp, trans_warp)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_warp, trans_chain)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_chain, trans)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_chain, trans_warp)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_chain, trans_chain)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans, trans_fn)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_fn, trans)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_fn, trans_warp)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_warp, trans_fn)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_fn, trans_fn)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_fn, trans_chain)) <- function(e1, e2) combine_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(trans_chain, trans_fn)) <- function(e1, e2) combine_trans(e1, e2)

#' Union of every trans-like class, for property typing only
#' @noRd
trans_any <- S7::new_union(trans, trans_warp, trans_fn, trans_chain)

#' Apply a transform to a set of points
#'
#' S7 generic used by every [drawable] subclass's `points` getter to map
#' an [xy] object's coordinates through its `trans` property. Dispatches
#' on `object`'s class only (like [noise_sample()] dispatches on `field`
#' alone): [trans] multiplies through its homogeneous matrix,
#' [trans_warp] displaces points by noise, [trans_fn] calls its own `fn`
#' directly, and [trans_chain] applies its `steps` in order.
#'
#' @param object A [trans]/[trans_warp]/[trans_fn]/[trans_chain].
#' @param pts A [xy].
#' @return A [xy].
#' @noRd
apply_trans <- S7::new_generic("apply_trans", dispatch_args = "object")

#' @noRd
method(apply_trans, trans) <- function(object, pts) {
  n <- length(pts@x)
  if (n == 0) {
    return(xy(x = numeric(0), y = numeric(0)))
  }
  homogeneous <- rbind(pts@x, pts@y, rep(1, n))
  out <- object@matrix %*% homogeneous
  xy(x = out[1, ], y = out[2, ])
}

#' @noRd
method(apply_trans, trans_warp) <- function(object, pts) {
  n <- length(pts@x)
  if (n == 0) {
    return(xy(x = numeric(0), y = numeric(0)))
  }
  dx <- noise_sample(object@distortion_x, x = pts@x, y = pts@y, to = c(-1, 1)) * object@amount
  dy <- noise_sample(object@distortion_y, x = pts@x, y = pts@y, to = c(-1, 1)) * object@amount
  xy(x = pts@x + dx, y = pts@y + dy)
}

#' @noRd
method(apply_trans, trans_fn) <- function(object, pts) {
  n <- length(pts@x)
  if (n == 0) {
    return(xy(x = numeric(0), y = numeric(0)))
  }
  out <- object@fn(pts@x, pts@y)
  if (!is.list(out) || !all(c("x", "y") %in% names(out))) {
    rlang::abort("trans_fn's fn must return a list with named x/y elements")
  }
  if (length(out$x) != n || length(out$y) != n) {
    rlang::abort("trans_fn's fn must return x/y vectors the same length as its input")
  }
  xy(x = out$x, y = out$y)
}

#' @noRd
method(apply_trans, trans_chain) <- function(object, pts) {
  for (step in object@steps) pts <- apply_trans(step, pts)
  pts
}

#' The identity transform
#'
#' Returns a [trans] that leaves points unchanged -- the default `trans`
#' for every [drawable].
#'
#' @examples
#' trans_identity()
#'
#' # the default trans for every drawable -- points are left unchanged
#' draw(shape_rectangle(width = 1.5, height = 0.6, trans = trans_identity()))
#'
#' @family transform helpers
#' @export
trans_identity <- function() {
  trans(matrix = diag(3))
}

#' Translate points
#'
#' Shifts points by `(dx, dy)`.
#'
#' `trans` objects compose with `+`, applied left to right: `t1 + t2` means
#' "apply `t1`'s effect first, then `t2`'s". For example,
#' `trans_translate(1, 0) + trans_rotate(pi / 2)` translates a point one
#' unit right, then rotates the *result* a quarter turn about the origin --
#' not the same as `trans_rotate(pi / 2) + trans_translate(1, 0)`, which
#' rotates first and translates second. Internally, `(t1 + t2)@matrix` is
#' `t2@matrix %*% t1@matrix`, since points are homogeneous column vectors
#' transformed as `matrix %*% point`.
#'
#' @param dx,dy Distance to shift along the x/y axes. Default `0`.
#'
#' @examples
#' draw(shape_square(side = 1, trans = trans_translate(2, 0)))
#'
#' # overlay the original (faded) with the translated copy (solid)
#' original <- shape_rectangle(
#'   width = 1.5,
#'   height = 0.6,
#'   fill_alpha = 0.3,
#'   color_alpha = 0.3
#' )
#' draw(sketch() + original + (original + trans_translate(1, 0.5)))
#'
#' # composition order matters: translate-then-rotate differs from
#' # rotate-then-translate -- a fixed xlim/ylim makes the difference in
#' # final position visible (a lone shape otherwise always fills its own
#' # auto-scaled frame)
#' square <- shape_square(x = 1, side = 0.4)
#' draw(
#'   square + trans_translate(1, 0) + trans_rotate(pi / 2),
#'   xlim = c(-1, 3),
#'   ylim = c(-1, 3)
#' )
#' draw(
#'   square + trans_rotate(pi / 2) + trans_translate(1, 0),
#'   xlim = c(-1, 3),
#'   ylim = c(-1, 3)
#' )
#'
#' @family transform helpers
#' @export
trans_translate <- function(dx = 0, dy = 0) {
  if (length(dx) != 1) rlang::abort("dx must be length 1")
  if (length(dy) != 1) rlang::abort("dy must be length 1")
  trans(matrix = mat_translate(dx, dy))
}

#' Rotate points
#'
#' Rotates points by `angle` radians (counterclockwise for positive
#' angles) about the pivot `(about_x, about_y)`.
#'
#' @param angle Rotation angle, in radians.
#' @param about_x,about_y Pivot point coordinates. Default `0`.
#'
#' @examples
#' draw(shape_square(side = 1, trans = trans_rotate(pi / 4)))
#'
#' # overlay the original (faded) with the rotated copy (solid)
#' original <- shape_rectangle(
#'   width = 1.5,
#'   height = 0.6,
#'   fill_alpha = 0.3,
#'   color_alpha = 0.3
#' )
#' draw(sketch() + original + (original + trans_rotate(pi / 6)))
#'
#' # rotating about a pivot away from the shape's own centroid sweeps it
#' # around that point instead -- shown here against a fixed frame, with
#' # a small marker at the pivot
#' square <- shape_square(
#'   x = 2,
#'   side = 0.5,
#'   fill_alpha = 0.3,
#'   color_alpha = 0.3
#' )
#' pivot <- shape_circle(radius = 0.05, fill = "tomato", color = NA_character_)
#' draw(
#'   sketch() + square +
#'     (square + trans_rotate(pi / 2, about_x = 0, about_y = 0)) +
#'     pivot,
#'   xlim = c(-2.5, 2.5), ylim = c(-2.5, 2.5)
#' )
#'
#' @family transform helpers
#' @export
trans_rotate <- function(angle, about_x = 0, about_y = 0) {
  if (length(angle) != 1) rlang::abort("angle must be length 1")
  if (length(about_x) != 1) rlang::abort("about_x must be length 1")
  if (length(about_y) != 1) rlang::abort("about_y must be length 1")
  trans(matrix = mat_about(mat_rotate(angle), about_x, about_y))
}

#' Scale points
#'
#' Scales points by `sx`/`sy` along the x/y axes, about the pivot
#' `(about_x, about_y)`.
#'
#' @param sx Scale factor along the x axis. Default `1`.
#' @param sy Scale factor along the y axis. Default `sx` (a uniform scale).
#' @param about_x,about_y Pivot point coordinates. Default `0`.
#'
#' @examples
#' draw(shape_square(side = 1, trans = trans_scale(2)))
#' draw(shape_square(side = 1, trans = trans_scale(2, 0.5)))
#'
#' # overlay the original (faded) with the scaled copy (solid)
#' original <- shape_rectangle(
#'   width = 1.5,
#'   height = 0.6,
#'   fill_alpha = 0.3,
#'   color_alpha = 0.3
#' )
#' draw(sketch() + original + (original + trans_scale(1.5, 0.7)))
#'
#' # scaling about a pivot other than the shape's own centroid also moves
#' # it, since distance from the pivot is what gets scaled -- shown here
#' # against a fixed frame, with a small marker at the pivot
#' square <- shape_square(
#'   x = 1,
#'   side = 0.5,
#'   fill_alpha = 0.3,
#'   color_alpha = 0.3
#' )
#' pivot <- shape_circle(radius = 0.05, fill = "tomato", color = NA_character_)
#' draw(
#'   sketch() + square +
#'     (square + trans_scale(2, about_x = 0, about_y = 0)) +
#'     pivot,
#'   xlim = c(-3, 3), ylim = c(-3, 3)
#' )
#'
#' @family transform helpers
#' @export
trans_scale <- function(sx = 1, sy = sx, about_x = 0, about_y = 0) {
  if (length(sx) != 1) rlang::abort("sx must be length 1")
  if (length(sy) != 1) rlang::abort("sy must be length 1")
  if (length(about_x) != 1) rlang::abort("about_x must be length 1")
  if (length(about_y) != 1) rlang::abort("about_y must be length 1")
  trans(matrix = mat_about(mat_scale(sx, sy), about_x, about_y))
}

#' Reflect points
#'
#' Flips points across a vertical and/or horizontal line through the pivot
#' `(about_x, about_y)`: `x = TRUE` mirrors left-right (flips the
#' x-coordinate), `y = TRUE` mirrors top-bottom (flips the y-coordinate).
#' Setting both reflects through the pivot point itself (equivalent to a
#' half turn, i.e. `trans_rotate(pi, about_x, about_y)`).
#'
#' Reflection across an arbitrary-angle line isn't exposed as a separate
#' argument -- it composes from existing pieces instead: rotate the desired
#' line onto an axis, reflect, then rotate back, e.g.
#' `trans_rotate(-theta) + trans_reflect(y = TRUE) + trans_rotate(theta)`
#' reflects across a line through the origin at angle `theta`.
#'
#' @param x,y Whether to flip the x/y coordinate. Default `FALSE` for both
#'   (i.e. the identity transform).
#' @param about_x,about_y Pivot point coordinates. Default `0`.
#'
#' @examples
#' draw(shape_bezier(
#'   x = c(0, 0.5, 1),
#'   y = c(0, 1, 0.2),
#'   trans = trans_reflect(x = TRUE)
#' ))
#'
#' # overlay the original (faded) with each reflected copy (solid)
#' original <- shape_rectangle(
#'   x = 1,
#'   width = 1,
#'   height = 0.4,
#'   fill_alpha = 0.3,
#'   color_alpha = 0.3
#' )
#' draw(sketch() + original + (original + trans_reflect(x = TRUE)))
#' draw(sketch() + original + (original + trans_reflect(y = TRUE)))
#'
#' # reflecting through both axes is equivalent to a half turn
#' draw(shape_bezier(
#'   x = c(0, 0.5, 1), y = c(0, 1, 0.2),
#'   trans = trans_reflect(x = TRUE, y = TRUE)
#' ))
#'
#' @family transform helpers
#' @export
trans_reflect <- function(x = FALSE, y = FALSE, about_x = 0, about_y = 0) {
  if (length(x) != 1 || !is.logical(x)) rlang::abort("x must be a single logical")
  if (length(y) != 1 || !is.logical(y)) rlang::abort("y must be a single logical")
  if (length(about_x) != 1) rlang::abort("about_x must be length 1")
  if (length(about_y) != 1) rlang::abort("about_y must be length 1")
  sx <- if (isTRUE(x)) -1 else 1
  sy <- if (isTRUE(y)) -1 else 1
  trans(matrix = mat_about(mat_scale(sx, sy), about_x, about_y))
}

#' Shear points
#'
#' Applies a shear transform about the pivot `(about_x, about_y)`: `shx`
#' displaces x-coordinates in proportion to y (distance from `about_y`),
#' `shy` displaces y-coordinates in proportion to x (distance from
#' `about_x`).
#'
#' @param shx,shy Shear factors along the x/y axes. Default `0` for both.
#' @param about_x,about_y Pivot point coordinates. Default `0`.
#'
#' @examples
#' draw(shape_square(side = 1, trans = trans_shear(shx = 0.5)))
#'
#' # overlay the original (faded) with the sheared copy (solid)
#' original <- shape_rectangle(
#'   width = 1,
#'   height = 0.6,
#'   fill_alpha = 0.3,
#'   color_alpha = 0.3
#' )
#' draw(sketch() + original + (original + trans_shear(shx = 0.6)))
#'
#' # shy shears vertically instead of horizontally
#' draw(shape_square(side = 1, trans = trans_shear(shy = 0.5)))
#'
#' @family transform helpers
#' @export
trans_shear <- function(shx = 0, shy = 0, about_x = 0, about_y = 0) {
  if (length(shx) != 1) rlang::abort("shx must be length 1")
  if (length(shy) != 1) rlang::abort("shy must be length 1")
  if (length(about_x) != 1) rlang::abort("about_x must be length 1")
  if (length(about_y) != 1) rlang::abort("about_y must be length 1")
  trans(matrix = mat_about(mat_shear(shx, shy), about_x, about_y))
}

#' Build a custom affine transform
#'
#' General-purpose escape hatch for an affine transform not covered by
#' [trans_translate()]/[trans_rotate()]/[trans_scale()]/[trans_reflect()]/
#' [trans_shear()]: wraps a caller-supplied matrix directly.
#'
#' @param matrix A 3x3 numeric matrix in homogeneous coordinates (its third
#'   row must be `c(0, 0, 1)`), or a 2x3 matrix giving only the first two
#'   rows (the third row is added automatically).
#'
#' @examples
#' # equivalent to trans_scale(2, 3)
#' trans_affine(matrix(c(2, 0, 0, 0, 3, 0, 0, 0, 1), nrow = 3, byrow = TRUE))
#'
#' # the 2x3 form omits the trivial homogeneous third row
#' draw(shape_square(
#'   side = 1,
#'   trans = trans_affine(matrix(c(2, 0, 0, 0, 3, 0), nrow = 2, byrow = TRUE))
#' ))
#'
#' @family transform helpers
#' @export
trans_affine <- function(matrix) {
  if (!is.matrix(matrix) || !is.numeric(matrix)) {
    rlang::abort("matrix must be a numeric matrix")
  }
  if (identical(dim(matrix), c(2L, 3L))) {
    matrix <- rbind(matrix, c(0, 0, 1))
  }
  trans(matrix = matrix)
}
