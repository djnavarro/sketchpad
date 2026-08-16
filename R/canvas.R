#' Canvas settings for a sketch
#'
#' `canvas` bundles the settings [draw()] applies to a [sketch] as a whole,
#' before drawing any of its shapes: a `background` fill and an optional
#' fixed `xlim`/`ylim` frame. It plays the same role for `sketch` that
#' [style()] plays for a single [drawable] -- a small, reusable settings
#' object, validated independently and stored as a property (`sketch`'s own
#' `canvas`) rather than a flat list of arguments.
#'
#' `xlim`/`ylim` only fix the coordinate *scale* [draw()] maps onto the
#' page -- they do not, by themselves, clip content that falls outside that
#' range; a shape wider than its sketch's `canvas` still renders in full,
#' spilling past the frame, exactly as passing `xlim`/`ylim` to [draw()]
#' directly already behaves. This is a deliberate default: shapes built
#' from a [noise_field]/[noise_bridge] (e.g. [shape_blob()], [shape_twist()])
#' can have somewhat unpredictable extents, and silently cropping part of
#' one away is a worse failure mode than a visibly overflowing shape, which
#' is an obvious cue to adjust the sketch's parameters. Set `clip = TRUE` to
#' opt into hard clipping at `xlim`/`ylim` instead -- most useful once
#' `background` is also set to something other than [fill_none()], since an
#' opaque background otherwise has visible content bleeding past its own
#' edge onto the bare page. `clip` has no visible effect when `xlim`/`ylim`
#' are both left `NULL`, since [draw()] then computes them from the
#' sketch's own shapes, which by construction never exceed that range.
#'
#' @param background Background fill, drawn beneath every shape in the
#'   sketch. Either a plain colour string, or the output of a `fill_*()`
#'   helper -- see [style()]'s `fill` argument for the full family. Default
#'   [fill_none()] (no background drawn; the page's own background shows
#'   through, matching `draw()`'s behavior before `canvas` existed).
#' @param xlim,ylim Fixed axis limits, each a numeric vector of length 2, or
#'   `NULL` (the default) to compute them from the sketch's own shapes at
#'   draw time, as [draw()] already did before `canvas` existed. An explicit
#'   `xlim`/`ylim` passed to [draw()] itself always takes precedence over
#'   these.
#' @param clip Whether to clip content to `xlim`/`ylim`. Must be a single
#'   logical. Default `FALSE` -- see Details.
#'
#' @examples
#' canvas()
#' canvas(background = "grey90")
#'
#' # a background is drawn beneath every shape in the sketch
#' draw(sketch(canvas = canvas(background = "grey90")) + shape_blob(radius = 1))
#'
#' # xlim/ylim alone only fix the coordinate scale -- a shape wider than the
#' # frame still overflows it
#' overflowing <- sketch(canvas = canvas(
#'   background = "white", xlim = c(-1, 1), ylim = c(-1, 1)
#' )) + shape_circle(radius = 1.4)
#' draw(overflowing)
#'
#' # clip = TRUE hard-clips content at xlim/ylim instead
#' overflowing@canvas@clip <- TRUE
#' draw(overflowing)
#'
#' @family core structure
#' @export
canvas <- S7::new_class(
  name = "canvas",
  properties = list(
    background = S7::new_property(fill_class, default = fill_none()),
    # class_any (not class_numeric) so a literal NULL default is stored as
    # NULL, rather than S7 treating `default = NULL` as "no default given"
    # and substituting a zero-length numeric() -- see .agents/HISTORY.md
    xlim       = S7::new_property(S7::class_any, default = NULL),
    ylim       = S7::new_property(S7::class_any, default = NULL),
    clip       = S7::new_property(S7::class_logical, default = FALSE)
  ),
  validator = function(self) {
    if (!is.null(self@xlim) && (!is.numeric(self@xlim) || length(self@xlim) != 2)) {
      return("xlim must be NULL or a numeric vector of length 2")
    }
    if (!is.null(self@ylim) && (!is.numeric(self@ylim) || length(self@ylim) != 2)) {
      return("ylim must be NULL or a numeric vector of length 2")
    }
    if (length(self@clip) != 1) {
      return("clip must be a single logical")
    }
  }
)
