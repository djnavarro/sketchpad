#' A nested collection of drawables sharing one transform/style
#'
#' `group` bundles several [drawable]/`group` objects (`shapes`) together
#' with one shared `trans` and, optionally, one shared `style` override --
#' the whole group can be rotated/scaled/moved as a unit, or restyled as a
#' unit, without touching any member's own `trans`/`style`. This is
#' different from [sketch], which represents the whole canvas of
#' independently-styled/-positioned shapes; a `group` is meant to be one
#' element *inside* a [sketch] (or inside another `group`), not a
#' replacement for it.
#'
#' Groups are built up incrementally with `+`, the same way a [sketch] is:
#' `group() + shape_circle() + shape_circle(x = 2)`. `group + <trans-like>`
#' composes the transform onto the group's own `@trans`, applied to every
#' member as a unit -- it does not touch any member's own `@trans`. A
#' `group` can itself be added to a [sketch] (or nested inside another
#' `group`), and mixed freely with plain [drawable]s in either container.
#'
#' `style`, when set (default `NULL`, meaning no override), is meant to
#' replace every descendant [drawable]'s own `@style` when the group is
#' drawn -- a nested `group` with no `style` of its own would inherit its
#' ancestor's override; a nested `group` that sets its own `style` would
#' keep that instead (the nearest override wins, it does not stack). This
#' cascade is implemented by `draw()`'s own `group` method, not by `group`
#' itself.
#'
#' @param shapes A list of [drawable]/`group` objects. Default `list()`.
#' @param trans A [trans]/[trans_warp]/[trans_fn]/[trans_chain], applied to
#'   every member as a unit. Default [trans_identity()].
#' @param style A [style] object overriding every descendant drawable's own
#'   style, or `NULL` (default) for no override.
#'
#' @examples
#' # shape_square() (rather than shape_circle()) makes a rotation visually
#' # detectable -- a circle's outline is rotationally symmetric about its
#' # own centroid, so rotating one in place looks identical to the original
#' g <- group() + shape_square(side = 1) + shape_square(x = 2, side = 0.6)
#' draw(g)
#'
#' # a trans applied to a group composes onto every member as a unit,
#' # without changing any member's own @trans -- both squares rotate about
#' # the group's own origin, sweeping the smaller one around the larger one
#' draw(g + trans_rotate(pi / 6))
#'
#' # a style override, applied to every member when the group is drawn
#' draw(g + style(color = "tomato", fill = "grey90"))
#'
#' # groups mix freely with plain drawables inside a sketch, and can nest;
#' # a nested group's own style override wins over an outer one, and an
#' # outer group's trans applies on top of everything inside it
#' inner <- group() + shape_square(x = 0.4, side = 0.3) + style(fill = "steelblue")
#' outer <- (group() + g + inner + style(color = "tomato")) + trans_translate(1, 0)
#' draw(sketch() + shape_square(x = -2) + outer)
#'
#' @family core structure
#' @export
group <- S7::new_class(
  name = "group",
  properties = list(
    shapes = S7::class_list,
    trans = S7::new_property(class = trans_any, default = trans_identity()),
    # class_any (not the style class) so a literal NULL default is stored
    # as NULL, rather than S7 substituting something else for "no default
    # given" -- see canvas's xlim/ylim, .agents/HISTORY.md
    style = S7::new_property(class = S7::class_any, default = NULL)
  ),
  validator = function(self) {
    ok <- purrr::map_lgl(
      self@shapes,
      \(d) S7::S7_inherits(d, drawable) || S7::S7_inherits(d, group)
    )
    if (!all(ok)) {
      return("shapes must be a list of drawable/group objects")
    }
    if (!is.null(self@style) && !S7::S7_inherits(self@style, style)) {
      return("style must be NULL or a style object")
    }
  },
  constructor = function(shapes = list(), trans = trans_identity(), style = NULL) {
    S7::new_object(S7::S7_object(), shapes = shapes, trans = trans, style = style)
  }
)

#' @export
#' @noRd
method(`+`, list(group, drawable)) <- function(e1, e2) {
  e1@shapes <- c(e1@shapes, e2)
  e1
}

#' @export
#' @noRd
method(`+`, list(group, group)) <- function(e1, e2) {
  e1@shapes <- c(e1@shapes, e2)
  e1
}

#' Compose a transform onto every member of a group, as a unit
#'
#' Internal helper shared by every `method(\`+\`, list(group, <trans-like>))`
#' registration below -- mirrors `compose_drawable_trans()`/
#' `compose_sketch_trans()` (`R/sketch.R`), but composes onto the group's
#' own `@trans` rather than mapping over its members, since a group's
#' `@trans` is applied to every member as a unit rather than baked into
#' each member's own `@trans`.
#'
#' @param e1 A [group].
#' @param e2 A [trans]/[trans_warp]/[trans_fn]/[trans_chain].
#' @return A copy of `e1` with `@trans` composed.
#' @noRd
compose_group_trans <- function(e1, e2) {
  e1@trans <- e1@trans + e2
  e1
}

#' Apply a transform to every member of a group with `+`
#'
#' `group + trans` returns a copy of `group` with `trans` composed onto its
#' existing `@trans` (`self@trans <- self@trans + trans`), applied to every
#' member as a unit at draw time -- it does not touch any member's own
#' `@trans`. Also works with a [trans_warp], [trans_fn], or [trans_chain]
#' in place of `trans`.
#'
#' @param e1 A [group].
#' @param e2 A [trans].
#' @export
#' @noRd
method(`+`, list(group, trans)) <- function(e1, e2) compose_group_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(group, trans_warp)) <- function(e1, e2) compose_group_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(group, trans_fn)) <- function(e1, e2) compose_group_trans(e1, e2)

#' @export
#' @noRd
method(`+`, list(group, trans_chain)) <- function(e1, e2) compose_group_trans(e1, e2)

#' Set a style override on a group with `+`
#'
#' `group + style(...)` returns a copy of `group` with `@style` replaced by
#' the given [style] object, overriding every descendant drawable's own
#' style at draw time.
#'
#' @param e1 A [group].
#' @param e2 A [style].
#' @export
#' @noRd
method(`+`, list(group, style)) <- function(e1, e2) {
  e1@style <- e2
  e1
}

#' Add a group to a sketch with `+`
#'
#' `sketch + group` appends `group` as a single element of the sketch's own
#' `@shapes`, alongside any plain [drawable]s already there -- mirrors
#' `sketch + drawable` (`R/sketch.R`).
#'
#' @param e1 A [sketch].
#' @param e2 A [group].
#' @export
#' @noRd
method(`+`, list(sketch, group)) <- function(e1, e2) {
  e1@shapes <- c(e1@shapes, e2)
  e1
}

#' @export
#' @noRd
method(length, group) <- function(x) length(x@shapes)

#' @export
#' @noRd
method(`[[`, group) <- function(x, i) x@shapes[[i]]

#' @export
#' @noRd
method(`[`, group) <- function(x, i) {
  x@shapes <- x@shapes[i]
  x
}

#' Resolve one member of a group/sketch into a flat list of drawables
#'
#' Internal helper backing `flatten_shapes()`/`resolve_group()` below. A
#' plain [drawable] member becomes a single-element list: a copy with its
#' own `@trans` composed with `ancestor_trans` (`member@trans +
#' ancestor_trans`, i.e. the member's own transform applies first, then
#' every enclosing group's, outermost last -- see [trans_translate()]'s
#' docs for why composition order matters) and its `@style` replaced by
#' `ancestor_style` whenever that's non-`NULL` (the nearest enclosing
#' group's own override, already resolved by the caller), otherwise left
#' as the member's own style. A `group` member instead recurses via
#' `resolve_group()`, so nesting flattens all the way down to plain
#' drawables.
#'
#' @param member A [drawable] or [group].
#' @param ancestor_trans A [trans]/[trans_warp]/[trans_fn]/[trans_chain]
#'   already accumulated from every enclosing group, to compose onto
#'   `member`'s own `@trans`.
#' @param ancestor_style A [style] object (the nearest enclosing group's
#'   own override) or `NULL` (no override in effect).
#' @return A list of [drawable] objects.
#' @noRd
resolve_group_member <- function(member, ancestor_trans, ancestor_style) {
  if (S7::S7_inherits(member, group)) {
    return(resolve_group(member, ancestor_trans, ancestor_style))
  }
  effective_style <- if (is.null(ancestor_style)) member@style else ancestor_style
  list(S7::set_props(
    member,
    trans = member@trans + ancestor_trans,
    style = effective_style
  ))
}

#' Flatten a group's own members into a list of plain drawables
#'
#' Internal helper backing `draw(group)` and `flatten_shapes()` below:
#' resolves `g`'s own `@trans`/`@style` against whatever's already been
#' accumulated from its enclosing groups (`ancestor_trans`/
#' `ancestor_style`), then maps `resolve_group_member()` over `g@shapes`
#' and flattens the result -- since a nested `group` member contributes
#' several drawables of its own, not one.
#'
#' @param g A [group].
#' @param ancestor_trans A [trans]/[trans_warp]/[trans_fn]/[trans_chain]
#'   already accumulated from every group enclosing `g` itself. Default
#'   [trans_identity()] (`g` has no enclosing group).
#' @param ancestor_style A [style] object (the nearest enclosing group's
#'   own override) or `NULL`. Default `NULL` (`g` has no enclosing group).
#' @return A list of [drawable] objects.
#' @noRd
resolve_group <- function(g, ancestor_trans = trans_identity(), ancestor_style = NULL) {
  own_trans <- g@trans + ancestor_trans
  own_style <- if (is.null(g@style)) ancestor_style else g@style
  purrr::flatten(purrr::map(
    g@shapes,
    resolve_group_member,
    ancestor_trans = own_trans,
    ancestor_style = own_style
  ))
}

#' Flatten a mixed drawable/group list into plain drawables
#'
#' Internal helper shared by `draw(sketch)` (`R/draw.R`) and `draw(group)`
#' below: expands every [group] element of `shapes` into its own
#' resolved-and-flattened drawables (via `resolve_group()`), leaving every
#' plain [drawable] element untouched apart from composing in the (empty,
#' at this top level) `ancestor_trans`/`ancestor_style` -- so callers that
#' only ever handle plain drawables (e.g. `geometry_grob()`) never need to
#' know a `sketch`/`group` can also hold nested groups.
#'
#' @param shapes A list of [drawable]/[group] objects.
#' @return A list of [drawable] objects.
#' @noRd
flatten_shapes <- function(shapes) {
  purrr::flatten(purrr::map(
    shapes,
    resolve_group_member,
    ancestor_trans = trans_identity(),
    ancestor_style = NULL
  ))
}

#' Format a `group` for printing
#'
#' Mirrors `format(sketch)` (`R/format.R`): reports the number of members
#' (`shapes`), each member's own class name in order (a nested `group`
#' member prints as `"group"`, the same way any other member prints its
#' own class), a `trans` summary (`format_trans_summary()`, shared with
#' `format(drawable)`/`format(sketch)`), and a `style` summary -- `"none"`
#' when no override is set (the default), or the same `color`/`fill`/
#' `linewidth` summary `format(drawable)` uses for its own `style`
#' otherwise. `format_prop_value()`/`format_trans_summary()` are defined
#' in `R/format.R`, collated earlier than this file -- referencing them
#' here is safe since both are ordinary functions, looked up at call time
#' rather than at source time.
#'
#' @param x A [group].
#' @param ... Currently unused.
#' @return A character vector, one element per printed line.
#' @export
#' @noRd
method(format, group) <- function(x, ...) {
  n <- length(x@shapes)
  header <- paste0("<group: ", n, " shape", if (n != 1) "s" else "", ">")
  shape_lines <- if (n > 0) {
    paste0("  ", seq_len(n), ": ", purrr::map_chr(x@shapes, \(d) S7::S7_class(d)@name))
  }
  style_summary <- if (is.null(x@style)) {
    "none"
  } else {
    paste0(
      "color = ", format_prop_value(x@style@color),
      ", fill = ", format_fill_summary(x@style@fill),
      ", linewidth = ", format_prop_value(x@style@linewidth)
    )
  }
  detail_line <- paste0(
    "  trans: ", format_trans_summary(x@trans), ", style: ", style_summary
  )
  c(header, shape_lines, detail_line)
}

#' Print a `group`
#'
#' @param x A [group].
#' @param ... Currently unused.
#' @export
#' @noRd
method(print, group) <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' @export
#' @noRd
S7::method(draw, group) <- function(object, xlim = NULL, ylim = NULL, ...) {
  # resolve_group() (not flatten_shapes()) -- object's own @trans/@style
  # must be folded into its descendants too, not just object@shapes's own
  # nested groups; flatten_shapes() starts from an identity trans/no
  # override, which is right for a sketch's own top-level @shapes (a
  # sketch has no @trans/@style of its own to apply) but would silently
  # drop object's own @trans/@style here
  shapes <- resolve_group(object)

  require_shapes_for_limits(shapes, xlim, ylim, "group")
  if (is.null(xlim)) {
    xlim <- c(
      min(purrr::map_dbl(shapes, \(s) min(s@points@x))),
      max(purrr::map_dbl(shapes, \(s) max(s@points@x)))
    )
  }
  if (is.null(ylim)) {
    ylim <- c(
      min(purrr::map_dbl(shapes, \(s) min(s@points@y))),
      max(purrr::map_dbl(shapes, \(s) max(s@points@y)))
    )
  }

  x_width <- xlim[2] - xlim[1]
  y_width <- ylim[2] - ylim[1]
  vp <- grid::viewport(
    xscale = xlim,
    yscale = ylim,
    width  = grid::unit(min(1, x_width / y_width), "snpc"),
    height = grid::unit(min(1, y_width / x_width), "snpc")
  )

  grid::grid.newpage()
  for (s in shapes) {
    grid::grid.draw(geometry_grob(s@points, s@style, s@geometry, vp, bbox_aspect(s)))
  }
}
