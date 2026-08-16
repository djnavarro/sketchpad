#' @noRd
fill_class <- S7::new_union(S7::class_character, S7::new_S3_class("GridPattern"))

#' A resolved or auto-resolving fill value
#'
#' `fill` is the common representation stored in [style()]'s `fill`
#' property and [canvas()]'s `background` property: a `value` (a plain
#' colour string, or the `GridPattern` output of a `fill_*()` pattern/
#' gradient helper) plus an optional `resolve` function. `resolve`, when
#' present, is called with the real target's own bounding-box aspect ratio
#' at [draw()] time to rebuild `value` with the correct tile shape -- see
#' the internal `resolvable_fill()`/`resolve_fill()` helpers (`R/fill.R`),
#' and [fill_hatch()]'s own `aspect` argument docs for the problem this
#' solves. `resolve` is `NULL` whenever a helper's `aspect` was supplied
#' explicitly (a fixed aspect, never automatically recomputed) or for a
#' fill with no aspect-dependence at all ([fill_solid()], [fill_none()]).
#'
#' Not usually constructed directly -- every `fill_*()` helper already
#' returns one, and [style()]/[canvas()] coerce a bare colour string or
#' `GridPattern` into one automatically (via the internal `as_fill()`
#' helper) if passed directly.
#'
#' @param value A plain colour string, or a `GridPattern` object (the
#'   output of [grid::pattern()], as returned by every `fill_*()` helper
#'   besides [fill_solid()]/[fill_none()]). Default `"black"`.
#' @param resolve `NULL`, or a function of one argument (`aspect`)
#'   rebuilding `value` for a newly-known target aspect ratio. Default
#'   `NULL`.
#'
#' @family fill helpers
#' @export
fill <- S7::new_class(
  name = "fill",
  properties = list(
    value = S7::new_property(fill_class, default = "black"),
    resolve = S7::new_property(S7::class_any, default = NULL)
  ),
  validator = function(self) {
    if (!is.null(self@resolve) && !is.function(self@resolve)) {
      "resolve must be NULL or a function"
    }
  }
)

#' Coerce a bare fill value into a `fill` object
#'
#' Internal helper shared by `style()`'s and `canvas()`'s own constructors:
#' a [fill] object passes through unchanged, while a plain colour string or
#' `GridPattern` (e.g. typed directly rather than built via a `fill_*()`
#' helper) is wrapped with no `resolve`.
#'
#' @param x A [fill] object, or a plain colour string/`GridPattern`.
#' @return A [fill] object.
#' @noRd
as_fill <- function(x) {
  if (S7::S7_inherits(x, fill)) {
    return(x)
  }
  fill(value = x)
}

#' Check whether a string is a valid colour for `grid`/`graphics`
#'
#' Internal helper backing `style`'s own validator: `NA` (a valid, fully
#' transparent [grid::gpar()] colour -- the same convention [fill_none()]
#' relies on for its own `NA_character_` value) is treated as valid
#' without calling [grDevices::col2rgb()] at all, since `col2rgb(NA)`
#' does not error but silently returns opaque white, which would be the
#' wrong answer here. Any other string is checked by actually calling
#' `col2rgb()` and catching the error it raises for an unrecognised name
#' or malformed hex string, rather than re-implementing colour-string
#' parsing here. `R/fill.R`'s own `validate_colors()` (shared by every
#' `fill_*()` helper's colour-vector argument) checks real colour validity
#' the same way, but inline against a whole vector at once rather than via
#' this scalar helper, since `NA` is never a valid entry there -- see its
#' own docs.
#'
#' @param x A single string.
#' @return `TRUE`/`FALSE`.
#' @noRd
is_valid_color <- function(x) {
  if (is.na(x)) {
    return(TRUE)
  }
  !inherits(tryCatch(grDevices::col2rgb(x), error = function(e) e), "error")
}

#' Graphical style for a drawable object
#'
#' `style` is a container for the graphical properties passed to
#' [grid::gpar()] when a [drawable] object is drawn.
#'
#' @param color Stroke colour: a single colour string recognised by
#'   [grDevices::col2rgb()] (a name, `"#RRGGBB"`/`"#RRGGBBAA"` hex string,
#'   ...), or `NA` for a fully transparent stroke. Validated at
#'   construction time, rather than only surfacing as a [grid] error once
#'   [draw()] is called. Default `"black"`.
#' @param fill Fill colour or pattern. Either a plain colour string, or the
#'   output of a `fill_*()` helper -- [fill_solid()], [fill_none()],
#'   [fill_hatch()], [fill_crosshatch()], [fill_stipple()], [fill_noise()],
#'   [fill_gradient()], or [fill_vignette()]. A bare colour string/
#'   `GridPattern` is coerced into a [fill] object automatically. Default
#'   `fill_solid("black")` (i.e. `"black"`).
#' @param linewidth Line width. Default `1`.
#' @param linetype Line dash pattern, forwarded to [grid::gpar()]'s `lty`.
#'   Either a named type (`"solid"`, `"dashed"`, `"dotted"`, `"dotdash"`,
#'   `"longdash"`, `"twodash"`, `"blank"`), an integer code `0:6`, or a
#'   custom hex dash-pattern string (e.g. `"13"`) -- see [grid::gpar()] and
#'   `graphics::par()`'s `lty` for the full set of accepted forms, which
#'   aren't independently re-validated here. Default `"solid"`.
#' @param linejoin Line join style at each vertex, forwarded to
#'   [grid::gpar()]'s `linejoin`. One of `"round"`, `"mitre"`, or `"bevel"`.
#'   Most visible on closed shapes with few, sharp vertices, or on any
#'   drawable stroked with a thick `linewidth`. Default `"round"`.
#' @param lineend Line end style at a path's free endpoints, forwarded to
#'   [grid::gpar()]'s `lineend`. One of `"round"`, `"butt"`, or `"square"`.
#'   Only visible on `"path"`-geometry drawables (e.g. [curve_line()],
#'   [curve_bezier()]) -- a `"polygon"`-geometry drawable has no free
#'   endpoint, since its outline closes back on itself. Most visible at a
#'   thick `linewidth`. Default `"round"`.
#' @param linemitre Mitre limit, forwarded to [grid::gpar()]'s `linemitre`.
#'   Only takes effect when `linejoin = "mitre"`: at a vertex sharper than
#'   this limit allows, the mitred corner is truncated to a bevel instead,
#'   to avoid an arbitrarily long spike. Must be at least `1`. Default `10`,
#'   matching [grid::gpar()]'s own default.
#' @param color_alpha Stroke opacity, applied to `color` independently of
#'   `fill_alpha`. Must be a number in `[0, 1]`, where `0` is fully
#'   transparent and `1` (the default) is fully opaque. Applied by baking
#'   the value into `color` via [grDevices::adjustcolor()] at draw time
#'   (see [draw()]'s internal `apply_alpha()` helper), not via
#'   [grid::gpar()]'s own `alpha` argument -- `gpar()`'s `alpha` applies
#'   uniformly to both stroke and fill on the same grob, which would
#'   couple `color_alpha` and `fill_alpha` together. If `color` already
#'   has its own alpha channel (e.g. an `"#RRGGBBAA"` hex string),
#'   `color_alpha` multiplies through it rather than overriding it.
#' @param rule Fill rule used when a drawable's own `points` has more than
#'   one sub-path (see [xy]'s `id`), forwarded to [grid::pathGrob()]'s own
#'   `rule` argument. One of `"evenodd"` (default) or `"winding"`.
#'   `"evenodd"` fills a region if it's enclosed by an odd number of
#'   sub-paths, regardless of each sub-path's own vertex winding direction
#'   -- a sub-path nested inside another becomes a hole purely from
#'   geometric nesting, with no need to get vertex order right by hand,
#'   which is why it's the default. `"winding"` instead fills based on net
#'   signed winding number, which depends on each sub-path's own direction
#'   -- only useful for constructions that specifically need that
#'   direction-sensitive behavior. Has no effect on a drawable with only
#'   one implicit sub-path (every current `shape_*()`/`curve_*()`
#'   constructor), since both rules agree there.
#' @param fill_alpha Fill opacity, applied to `fill` independently of
#'   `color_alpha`, via the same [grDevices::adjustcolor()] mechanism as
#'   `color_alpha`. Must be a number in `[0, 1]`. Default `1`. Only has an
#'   effect when `fill` is a plain colour string (as from [fill_solid()]
#'   or [fill_none()]) -- **silently inert when `fill` is a pattern or
#'   gradient** (the output of any other `fill_*()` helper), since
#'   [grDevices::adjustcolor()] has no defined effect on a `GridPattern`
#'   object. This mirrors `fill` itself already having no effect for
#'   `"path"`/`"points"`-geometry drawables (see [drawable]'s `geometry`
#'   docs), and `lineend`/`linemitre` already being inert for some
#'   geometries -- geometry- or fill-type-conditional inertness, not an
#'   error, is this package's existing convention for style properties
#'   that don't universally apply.
#'
#' @examples
#' style(color = "steelblue", fill = "lightblue", linewidth = 2)
#' style(fill = fill_hatch(angle = 30))
#'
#' # linejoin/linemitre are most visible on a thick-stroked shape with a
#' # sharp vertex
#' star <- shape_polygon(n = 5, radius = 1, fill = "white")
#' draw(shape_stroke(
#'   x = star@points@x, y = star@points@y, width = 0.25,
#'   linejoin = "mitre", linemitre = 1.5
#' ))
#'
#' # color_alpha/fill_alpha control stroke/fill opacity independently
#' draw(shape_circle(
#'   radius = 1, color = "black", fill = "tomato",
#'   color_alpha = 1, fill_alpha = 0.3, linewidth = 3
#' ))
#'
#' # lineend only affects a path's free endpoints, not a closed polygon
#' draw(curve_line(
#'   x = c(0, 1, 2), y = c(0, 1, 0), linewidth = 15, lineend = "square"
#' ))
#'
#' @family core structure
#' @export
style <- S7::new_class(
  name = "style",
  properties = list(
    color = S7::new_property(S7::class_character, default = "black"),
    fill = fill,
    linewidth = S7::new_property(S7::class_numeric, default = 1),
    linetype = S7::new_property(
      S7::new_union(S7::class_character, S7::class_numeric),
      default = "solid"
    ),
    linejoin = S7::new_property(S7::class_character, default = "round"),
    lineend = S7::new_property(S7::class_character, default = "round"),
    linemitre = S7::new_property(S7::class_numeric, default = 10),
    rule = S7::new_property(S7::class_character, default = "evenodd"),
    color_alpha = S7::new_property(S7::class_numeric, default = 1),
    fill_alpha = S7::new_property(S7::class_numeric, default = 1)
  ),
  # explicit argument defaults (rather than new_property(default = ...))
  # keep the auto-generated constructor's roxygen \usage line valid --
  # embedding a pre-built fill() object directly as a property default
  # renders as an unparseable "<object>" literal in the Rd \usage section
  # (the same reason sketch()'s own canvas argument needs one -- see
  # .agents/HISTORY.md). `fill`'s own default expression calls
  # `fill_solid()`, not `fill()` itself, so there's no name-shadowing
  # concern the way `canvas = canvas()` has.
  constructor = function(color = "black",
                         fill = fill_solid("black"),
                         linewidth = 1,
                         linetype = "solid",
                         linejoin = "round",
                         lineend = "round",
                         linemitre = 10,
                         rule = "evenodd",
                         color_alpha = 1,
                         fill_alpha = 1) {
    S7::new_object(
      S7::S7_object(),
      color = color,
      fill = as_fill(fill),
      linewidth = linewidth,
      linetype = linetype,
      linejoin = linejoin,
      lineend = lineend,
      linemitre = linemitre,
      rule = rule,
      color_alpha = color_alpha,
      fill_alpha = fill_alpha
    )
  },
  validator = function(self) {
    if (length(self@color) != 1) {
      return("color must be a single string")
    }
    if (!is_valid_color(self@color)) {
      return(paste0(
        'color must be a valid colour string or NA, not "', self@color, '"'
      ))
    }
    if (length(self@rule) != 1) {
      return("rule must be a single string")
    }
    if (!self@rule %in% c("evenodd", "winding")) {
      return('rule must be one of "evenodd" or "winding"')
    }
    if (length(self@linetype) != 1) {
      return("linetype must be a single value")
    }
    if (length(self@linejoin) != 1) {
      return("linejoin must be a single string")
    }
    if (!self@linejoin %in% c("round", "mitre", "bevel")) {
      return('linejoin must be one of "round", "mitre", or "bevel"')
    }
    if (length(self@lineend) != 1) {
      return("lineend must be a single string")
    }
    if (!self@lineend %in% c("round", "butt", "square")) {
      return('lineend must be one of "round", "butt", or "square"')
    }
    if (length(self@linewidth) != 1) {
      return("linewidth must be a single number")
    }
    if (self@linewidth < 0) {
      return("linewidth must be a non-negative number")
    }
    if (length(self@linemitre) != 1) {
      return("linemitre must be a single number")
    }
    if (self@linemitre < 1) {
      return("linemitre must be at least 1")
    }
    if (length(self@color_alpha) != 1) {
      return("color_alpha must be a single number")
    }
    if (self@color_alpha < 0 || self@color_alpha > 1) {
      return("color_alpha must be between 0 and 1")
    }
    if (length(self@fill_alpha) != 1) {
      return("fill_alpha must be a single number")
    }
    if (self@fill_alpha < 0 || self@fill_alpha > 1) {
      return("fill_alpha must be between 0 and 1")
    }
  }
)
