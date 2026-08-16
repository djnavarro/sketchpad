#' Require that a drawable has particular properties
#'
#' Internal helper shared by [effect_tremor()]/[effect_bristle()]: both
#' take an `object` that must be a [drawable] exposing particular
#' properties (e.g. `x`/`y` control points) for the effect to make sense.
#' Gives a clear, effect-specific error rather than letting a missing
#' property surface later as a raw `@` access or `S7::set_props()`
#' failure.
#'
#' @param object The object to check.
#' @param props A character vector of required property names.
#' @param context A short string identifying the calling function, used
#'   in the error message (e.g. `"effect_tremor()"`).
#' @return `invisible(NULL)`, or aborts.
#' @noRd
require_props <- function(object, props, context) {
  if (!S7::S7_inherits(object, drawable)) {
    rlang::abort(paste0(context, " requires a <drawable> object"))
  }
  missing <- setdiff(props, S7::prop_names(object))
  if (length(missing) > 0) {
    rlang::abort(paste0(
      context, " requires a drawable with ",
      paste(sprintf("`%s`", missing), collapse = ", "),
      " propert", if (length(missing) > 1) "ies" else "y",
      " (e.g. curve_line(), shape_stroke())"
    ))
  }
  invisible(NULL)
}

#' Require that a drawable is pathlike, and has a single sub-path
#'
#' Internal helper shared by [effect_tremor()]/[effect_bristle()]: both
#' need an `object` whose `x`/`y` properties hold a genuine, perturbable,
#' caller-ordered control-point path -- [drawable]'s `pathlike` property
#' (see its docs) -- rather than merely having properties *named* `x`/`y`
#' with a different meaning (e.g. a shape's centroid, or one endpoint of
#' a fixed two-point segment).
#'
#' Also rejects a multi-sub-path `object` (i.e. one with an `id` property
#' -- [shape_raw()]/[curve_raw()]/[points_raw()] -- holding more than one
#' distinct value, e.g. the output of [shape_combine()]). Both effects
#' compute a single arc-length parametrization across the whole of
#' `object@x`/`object@y`, treating it as one continuous path; a
#' multi-sub-path object's sub-paths aren't actually connected, so that
#' arc-length would bridge a fake segment across each sub-path boundary.
#' Supporting a per-sub-path jitter/fan is a possible future enhancement,
#' not yet implemented.
#'
#' @param object The object to check.
#' @param context A short string identifying the calling function, used
#'   in the error message (e.g. `"effect_tremor()"`).
#' @return `invisible(NULL)`, or aborts.
#' @noRd
require_pathlike <- function(object, context) {
  if (!S7::S7_inherits(object, drawable)) {
    rlang::abort(paste0(context, " requires a <drawable> object"))
  }
  if (!isTRUE(object@pathlike)) {
    rlang::abort(paste0(
      context, " requires a pathlike drawable (e.g. curve_line(), ",
      "shape_stroke()) -- an object with a genuine control-point path, ",
      "not merely x/y properties that mean something else (e.g. a ",
      "shape's centroid)"
    ))
  }
  if ("id" %in% S7::prop_names(object) && length(unique(object@id)) > 1) {
    rlang::abort(paste0(
      context, " does not support a multi-sub-path drawable (an object ",
      "with more than one distinct value in its own `id`, e.g. the ",
      "output of shape_combine()) -- its x/y sub-paths aren't actually ",
      "connected, so a single arc-length jitter/fan across all of them ",
      "isn't meaningful"
    ))
  }
  invisible(NULL)
}
