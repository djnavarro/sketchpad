#' Build a `fill` object from a `build(aspect)` closure
#'
#' Internal helper shared by every aspect-taking `fill_*()` helper below.
#' `build` computes the actual `GridPattern` (or colour string) for a
#' given aspect ratio; `aspect = NULL` (the default on every such helper)
#' defers that computation to [draw()] time, against the real target's own
#' bounding-box aspect, by keeping `build` itself as the returned [fill]'s
#' `resolve`. Passing a fixed `aspect` instead computes `value` once,
#' immediately, with no `resolve` -- matching every such helper's behavior
#' before automatic resolution existed.
#'
#' @param build A function of one argument (`aspect`).
#' @param aspect `NULL`, or a single positive number.
#' @return A [fill] object.
#' @noRd
resolvable_fill <- function(build, aspect) {
  fill(
    value = build(if (is.null(aspect)) 1 else aspect),
    resolve = if (is.null(aspect)) build else NULL
  )
}

#' Resolve a `fill` object against a real target aspect ratio
#'
#' Internal helper used by [draw()]'s own `geometry_grob()`: a [fill]
#' object with a `resolve` is rebuilt against `aspect`; one without simply
#' returns its own stored `value`. A bare (non-`fill`) value is returned
#' unchanged, so this is also safe to call defensively on anything that
#' might not have been coerced yet.
#'
#' @param f A [fill] object (or a bare colour string/`GridPattern`).
#' @param aspect A single positive number.
#' @return A plain colour string or `GridPattern`.
#' @noRd
resolve_fill <- function(f, aspect) {
  if (!S7::S7_inherits(f, fill)) {
    return(f)
  }
  if (is.null(f@resolve)) {
    return(f@value)
  }
  f@resolve(aspect)
}

#' Solid colour fill
#'
#' `fill_solid()` is the trivial member of the `fill_*()` family: a plain
#' colour needs no [grid::pattern()] machinery, since [grid::gpar()]'s `fill`
#' argument already accepts a colour string directly. It exists so that a
#' plain colour can be requested with the same `fill_*()` naming as the
#' pattern-based helpers (grouping them together in autocomplete), and so
#' `style()`'s `fill` property has one uniform family of constructors to
#' accept -- including for its own default -- once it's extended to take
#' `fill_*()` outputs alongside a bare colour string.
#'
#' @param color Fill colour. Default `"black"`.
#'
#' @return A [fill] object wrapping `color`.
#'
#' @examples
#' fill_solid("steelblue")
#' draw(shape_circle(fill = fill_solid("tomato")))
#'
#' # equivalent to passing the colour string directly, since style()'s own
#' # `fill` default is fill_solid("black")
#' draw(shape_circle(fill = "tomato"))
#'
#' @family fill helpers
#' @export
fill_solid <- function(color = "black") {
  if (!is.character(color) || length(color) != 1) {
    rlang::abort("color must be a single string")
  }
  fill(value = color)
}

#' Unfilled (transparent) fill
#'
#' `fill_none()` leaves a [drawable]'s interior entirely unfilled, while
#' still stroking its outline (per `style()`'s `color`/`linewidth`). It's a
#' thin, self-documenting wrapper around `fill_solid(NA_character_)`: `NA` is
#' already a valid colour to [grid::gpar()] (rendered as fully transparent),
#' but spelling that out as `fill_none()` reads more clearly at a call site
#' than a bare `NA_character_`, and groups discoverably with the rest of the
#' `fill_*()` family.
#'
#' Since every [drawable] is currently rendered as a closed
#' [grid::polygonGrob()] (see the "Deferred: open/stroked curve support"
#' item in `.agents/PLAN.md`), `fill_none()` gives an unfilled *closed*
#' outline -- the edge connecting the last point back to the first is still
#' drawn. It does not, by itself, produce an open/unstroked curve.
#'
#' @return A [fill] object wrapping `NA_character_`.
#'
#' @examples
#' draw(shape_circle(fill = fill_none(), linewidth = 2))
#'
#' # still a closed outline: the edge from the last point back to the
#' # first is drawn even though the interior isn't filled
#' draw(shape_polygon(
#'   n = 5L,
#'   fill = fill_none(),
#'   color = "steelblue",
#'   linewidth = 3
#' ))
#'
#' @family fill helpers
#' @export
fill_none <- function() {
  fill(value = NA_character_)
}

#' Validate the shared arguments of a `fill_*()` helper
#'
#' Internal helper shared by every `fill_*()` pattern-fill constructor.
#' `spacing`/`aspect` are common to all of them; `angle` is specific to the
#' hatch-family helpers, so pass `NULL` to skip that check.
#'
#' @param angle,spacing,aspect The arguments of the same name from the
#'   calling `fill_*()` function. `angle = NULL` skips the angle check.
#' @noRd
validate_fill_args <- function(angle, spacing, aspect) {
  if (!is.numeric(spacing) || length(spacing) != 1 || spacing <= 0) {
    rlang::abort("spacing must be a single positive number")
  }
  if (!is.numeric(aspect) || length(aspect) != 1 || aspect <= 0) {
    rlang::abort("aspect must be a single positive number")
  }
  if (!is.null(angle) && (!is.numeric(angle) || length(angle) != 1)) {
    rlang::abort("angle must be a single number")
  }
}

#' Validate a `fill_*()` helper's colour vector argument
#'
#' Internal helper shared by every `fill_*()` constructor accepting a colour
#' vector (as opposed to always requiring a single colour) -- checks that
#' `colors` is a character vector of at least `min_length` with no `NA`
#' entries.
#'
#' @param colors The argument to validate.
#' @param arg_name The argument's name, used in the error message.
#' @param min_length Minimum allowed length. Default `1`.
#' @noRd
validate_colors <- function(colors, arg_name, min_length = 1) {
  if (!is.character(colors) || length(colors) < min_length || anyNA(colors)) {
    if (min_length <= 1) {
      rlang::abort(paste0(arg_name, " must be a character vector with at least one colour"))
    } else {
      rlang::abort(paste0(arg_name, " must be a character vector of at least length ", min_length))
    }
  }
}

#' Tile dimensions that render a corner-to-corner diagonal at a given angle
#'
#' Internal helper. See [fill_hatch()] details for why the rendered angle of
#' a [grid::pattern()] tile is controlled via its `width`/`height` ratio
#' rather than the slope of the content drawn inside it.
#'
#' @param theta Angle in radians, already reduced to `[0, pi)`.
#' @param spacing,aspect As in [fill_hatch()].
#' @noRd
hatch_tile_dims <- function(theta, spacing, aspect) {
  c(
    width  = spacing * abs(cos(theta)),
    height = spacing * abs(sin(theta)) * aspect
  )
}

#' Diagonal hatch pattern fill
#'
#' `fill_hatch()` builds a [grid::pattern()] fill value that renders a
#' repeating diagonal hatch line. It's meant to be used as the `fill`
#' argument to [grid::gpar()] (and eventually `style()`'s `fill` property),
#' in place of a plain colour.
#'
#' [grid::pattern()] tiles are sized as a *fraction of the target polygon's
#' own bounding box*, not a fixed physical square, so a tile that looks
#' square in that relative sense can be a stretched rectangle in absolute
#' terms whenever the target's bounding box isn't square itself -- which
#' distorts any angle baked directly into the pattern content. This is
#' corrected automatically: `aspect` defaults to `NULL`, resolved against
#' the real target's own bounding-box aspect ratio (width / height) at
#' [draw()] time (see the [fill] class); pass a fixed number instead to
#' compute the pattern once, immediately, against that value only.
#'
#' Internally, the hatch line is always drawn as a plain diagonal from one
#' tile corner to the opposite corner (or the mirror image, for a
#' negative-sloped angle) -- never at an arbitrary slope baked into the
#' segment's own coordinates. A corner-to-corner diagonal is the only slope
#' that tiles seamlessly under [grid::pattern()]'s `extend = "repeat"`,
#' which translates tile copies by whole tile-widths/heights only; any other
#' local slope leaves a visible mismatch ("dashing") at every tile edge. The
#' desired angle is instead achieved entirely by choosing the tile's
#' `width`/`height` ratio. Exactly horizontal/vertical angles are handled as
#' a special case, since a straight (non-diagonal) line tiles seamlessly at
#' any tile aspect ratio.
#'
#' @param color Line colour. Default `"black"`.
#' @param angle Hatch angle in degrees, measured counterclockwise from the
#'   positive x-axis. Default `45`.
#' @param spacing Baseline tile size, as a fraction of the target's bounding
#'   box. Must be a positive number. Default `0.1`.
#' @param aspect Width-to-height ratio of the target polygon's bounding box.
#'   Must be a positive number, or `NULL` (the default) to resolve it
#'   automatically from the real target's own bounding-box aspect ratio at
#'   [draw()] time -- see the [fill] class. Passing a fixed number instead
#'   computes the pattern once, immediately, against that value only.
#' @param linewidth Line width. Must be a positive number. Default `1`.
#' @param extend Passed to [grid::pattern()]. Default `"repeat"`.
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_hatch(angle = 30, spacing = 0.15)))
#'
#' # a steeper angle and finer spacing
#' draw(shape_circle(fill = fill_hatch(angle = 75, spacing = 0.06)))
#'
#' # exactly horizontal/vertical are handled as a special case (no
#' # diagonal-tile trick needed)
#' draw(shape_circle(fill = fill_hatch(angle = 0, spacing = 0.1)))
#'
#' # aspect corrects the rendered angle for a non-square bounding box --
#' # without it, a 45 degree hatch looks skewed on a wide rectangle
#' draw(shape_rectangle(width = 3, height = 1, fill = fill_hatch(angle = 45)))
#' draw(shape_rectangle(
#'   width = 3,
#'   height = 1,
#'   fill = fill_hatch(angle = 45, aspect = 3)
#' ))
#'
#' @family fill helpers
#' @export
fill_hatch <- function(color = "black",
                       angle = 45,
                       spacing = 0.1,
                       aspect = NULL,
                       linewidth = 1,
                       extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(angle, spacing, aspect)
  if (!is.numeric(linewidth) || length(linewidth) != 1 || linewidth <= 0) {
    rlang::abort("linewidth must be a single positive number")
  }

  # exactly horizontal/vertical: a straight line tiles seamlessly regardless
  # of tile aspect, so skip the diagonal construction entirely
  if (isTRUE(all.equal(angle %% 180, 0))) {
    seg <- grid::segmentsGrob(
      x0 = 0, y0 = 0.5, x1 = 1, y1 = 0.5,
      default.units = "npc",
      gp = grid::gpar(col = color, lwd = linewidth)
    )
    return(grid::pattern(seg, width = spacing, height = spacing, extend = extend))
  }
  if (isTRUE(all.equal(angle %% 180, 90))) {
    seg <- grid::segmentsGrob(
      x0 = 0.5, y0 = 0, x1 = 0.5, y1 = 1,
      default.units = "npc",
      gp = grid::gpar(col = color, lwd = linewidth)
    )
    return(grid::pattern(seg, width = spacing, height = spacing, extend = extend))
  }

  theta <- (angle %% 180) * pi / 180
  dims <- hatch_tile_dims(theta, spacing, aspect)

  if (sin(theta) * cos(theta) >= 0) {
    seg <- grid::segmentsGrob(
      x0 = 0, y0 = 0, x1 = 1, y1 = 1,
      default.units = "npc",
      gp = grid::gpar(col = color, lwd = linewidth)
    )
  } else {
    seg <- grid::segmentsGrob(
      x0 = 0, y0 = 1, x1 = 1, y1 = 0,
      default.units = "npc",
      gp = grid::gpar(col = color, lwd = linewidth)
    )
  }

  grid::pattern(seg, width = dims["width"], height = dims["height"], extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Crosshatch pattern fill
#'
#' `fill_crosshatch()` builds a [grid::pattern()] fill value that renders two
#' mirror-symmetric hatch lines, at `angle` and `-angle`, forming an "X"
#' inside each tile.
#'
#' It shares [fill_hatch()]'s tile-shape technique: both lines are drawn as
#' the two corner-to-corner diagonals of a single rectangular tile (rather
#' than at an arbitrary baked-in slope), so both tile seamlessly under
#' `extend = "repeat"`, and the tile's `width`/`height` ratio -- not the
#' diagonals' own coordinates -- determines the rendered angle. See
#' [fill_hatch()]'s details for why this matters.
#'
#' Because both lines share one tile shape, they are only *perpendicular*
#' when `angle = 45` (the classic crosshatch look); for other angles the two
#' lines are symmetric about the horizontal axis but not at right angles to
#' each other. Genuinely perpendicular hatching at an arbitrary angle would
#' need two differently-shaped tiles layered as separate fills, which this
#' function does not attempt.
#'
#' At `angle` a multiple of 90 degrees, the two mirrored diagonals would
#' coincide, so this case is handled separately by drawing a horizontal line
#' and a vertical line instead (a simple grid).
#'
#' @param color One or more line colours. A vector of length 2 colours the
#'   two lines independently; a single colour (the default) colours both the
#'   same, matching the original behaviour. Longer vectors are recycled to
#'   length 2. Default `"black"`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_crosshatch(angle = 30)))
#'
#' # at a multiple of 90 degrees, the mirrored diagonals would coincide,
#' # so a plain horizontal/vertical grid is drawn instead
#' draw(shape_circle(fill = fill_crosshatch(angle = 0, spacing = 0.15)))
#'
#' # only angle = 45 gives genuinely perpendicular lines; other angles are
#' # symmetric about the horizontal axis but not at right angles
#' draw(shape_circle(fill = fill_crosshatch(angle = 20, spacing = 0.12)))
#'
#' # a two-colour vector colours the two lines independently
#' draw(shape_circle(
#'   fill = fill_crosshatch(color = c("steelblue", "tomato"), angle = 45)
#' ))
#'
#' @family fill helpers
#' @export
fill_crosshatch <- function(color = "black",
                            angle = 45,
                            spacing = 0.1,
                            aspect = NULL,
                            linewidth = 1,
                            extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(angle, spacing, aspect)
  validate_colors(color, "color")
  if (!is.numeric(linewidth) || length(linewidth) != 1 || linewidth <= 0) {
    rlang::abort("linewidth must be a single positive number")
  }
  line_colors <- rep_len(color, 2)

  # a multiple of 90 degrees: the mirrored diagonals would coincide, so draw
  # a horizontal + vertical grid instead
  if (isTRUE(all.equal(angle %% 90, 0))) {
    content <- grid::grobTree(
      grid::gList(
        grid::segmentsGrob(
          x0 = 0, y0 = 0.5, x1 = 1, y1 = 0.5,
          default.units = "npc",
          gp = grid::gpar(col = line_colors[1], lwd = linewidth)
        ),
        grid::segmentsGrob(
          x0 = 0.5, y0 = 0, x1 = 0.5, y1 = 1,
          default.units = "npc",
          gp = grid::gpar(col = line_colors[2], lwd = linewidth)
        )
      )
    )
    return(grid::pattern(content, width = spacing, height = spacing, extend = extend))
  }

  theta <- (angle %% 180) * pi / 180
  dims <- hatch_tile_dims(theta, spacing, aspect)

  content <- grid::grobTree(
    grid::gList(
      grid::segmentsGrob(
        x0 = 0, y0 = 0, x1 = 1, y1 = 1,
        default.units = "npc",
        gp = grid::gpar(col = line_colors[1], lwd = linewidth)
      ),
      grid::segmentsGrob(
        x0 = 0, y0 = 1, x1 = 1, y1 = 0,
        default.units = "npc",
        gp = grid::gpar(col = line_colors[2], lwd = linewidth)
      )
    )
  )

  grid::pattern(content, width = dims["width"], height = dims["height"], extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Checkerboard pattern fill
#'
#' `fill_checker()` builds a [grid::pattern()] fill value that renders a
#' checkerboard, generalized from two colours to an arbitrary palette.
#'
#' It's the cheapest member of the hatch family to build: a checkerboard
#' square has no direction the way a hatch line does (compare
#' [fill_hatch()]'s corner-to-corner diagonal, needed specifically to tile
#' a *sloped* line seamlessly), so the tile content here is just a grid of
#' plain quadrant rectangles -- the same two-colour-grid special case
#' [fill_crosshatch()] already falls back to when `angle` is a multiple of
#' 90 degrees, pulled out into its own helper.
#'
#' The tile is subdivided into an `n x n` grid, where `n = length(color)`.
#' The colour at grid cell `(row, col)` (0-indexed) is `color[((row + col)
#' %% n) + 1]` -- for the default two colours this reproduces the classic
#' 2x2 checkerboard exactly; a longer `color` vector grows the grid rather
#' than adding a separate density argument, since a checkerboard's cell size
#' and colour count aren't independent concepts here.
#'
#' @section Known rendering risk with three or more colours: The default
#'   two-colour, four-rectangle tile has always rendered correctly, but
#'   `color` vectors of length 3 or more (a 3x3 or larger grid of
#'   rectangles) were found, at the default `spacing`, to trigger the same
#'   upstream `grid`/Cairo issue documented at [fill_stipple()]'s "Known
#'   rendering risk" section -- several shapes inside a genuinely *repeated*
#'   [grid::pattern()] tile can render distorted (here, collapsing to a
#'   single solid colour instead of a grid), even though the same tile
#'   content renders correctly as a single, non-repeated tile (`spacing =
#'   1`). **Visually check rendered output** before relying on more than
#'   two `color`s for anything beyond casual use.
#'
#' As with the other `fill_*()` helpers, [grid::pattern()] tiles are sized
#' as a fraction of the target polygon's own bounding box rather than a
#' fixed physical square, so the checker squares would render as
#' rectangles, not squares, on a non-square bounding box -- the same
#' tile-squaring technique [fill_stipple()] uses for its dots. `aspect`
#' resolves this automatically by default (see [fill_hatch()]'s own
#' `aspect` docs).
#'
#' @param color Two or more checker colours. Default `c("black", "white")`.
#' @param spacing Baseline tile size, as a fraction of the target's bounding
#'   box. Must be a positive number. Default `0.2`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_checker(color = c("black", "white"))))
#'
#' # a coarser, differently-coloured checkerboard
#' draw(shape_circle(
#'   fill = fill_checker(color = c("steelblue", "white"), spacing = 0.4)
#' ))
#'
#' # three or more colours grow the grid rather than alternating just two;
#' # spacing = 1 avoids the tile-repetition rendering risk noted above
#' draw(shape_circle(
#'   fill = fill_checker(color = c("steelblue", "white", "tomato"), spacing = 1)
#' ))
#'
#' @family fill helpers
#' @export
fill_checker <- function(color = c("black", "white"),
                         spacing = 0.2,
                         aspect = NULL,
                         extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  validate_colors(color, "color", min_length = 2)

  n <- length(color)
  cell <- 1 / n
  cells <- expand.grid(row = seq(0, n - 1), col = seq(0, n - 1))
  quadrant <- function(x, y, color) {
    grid::rectGrob(
      x = x, y = y, width = cell, height = cell,
      default.units = "npc",
      gp = grid::gpar(fill = color, col = NA)
    )
  }
  rects <- purrr::pmap(cells, function(row, col) {
    color_index <- ((row + col) %% n) + 1
    quadrant(
      x = (col + 0.5) * cell,
      y = 1 - (row + 0.5) * cell,
      color = color[color_index]
    )
  })
  content <- grid::grobTree(do.call(grid::gList, rects))

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Stippled dot pattern fill
#'
#' `fill_stipple()` builds a [grid::pattern()] fill value that scatters a
#' handful of dots at random positions inside each tile, using
#' [withr::with_seed()] so the same `seed` always reproduces the same
#' scatter (the same convention used by [shape_blob()], [shape_ribbon()],
#' and [shape_twist()]'s noise fields).
#'
#' Unlike [fill_hatch()]/[fill_crosshatch()], a dot has no direction, so
#' there's no analogue of their tile-edge "dashing" problem here. There's
#' still a circularity problem to correct for, though: [grid::pattern()]
#' tiles are sized as a fraction of the target polygon's own bounding box,
#' so a dot drawn with an `npc`-relative radius renders as an ellipse
#' whenever that bounding box isn't square. `aspect` corrects for this
#' automatically by default, keeping dots circular (see [fill_hatch()]'s
#' own `aspect` docs).
#'
#' @section Known rendering risk with multiple dots: On this package's
#'   development R build (4.6.1, a very recent/development version),
#'   [grid::pattern()] tiles whose content is a *group* of several
#'   [grid::circleGrob()]s (i.e. `n > 1`) were found, in some cases, to
#'   render individual dots visibly distorted -- clipped into crescents or
#'   otherwise not circular -- even though each dot's own coordinates are
#'   correct and a single dot (`n = 1`) always renders correctly. This
#'   reproduced in a fresh R session (so it isn't specific to a long
#'   interactive session), across multiple `n` and `radius` values, with
#'   no clean rule found for exactly when it triggers; it appeared on both
#'   an interactive device and `ragg::agg_png()`. No fix or reliable
#'   workaround was found -- this looks like an upstream `grid`/Cairo
#'   issue with multi-shape pattern tile content, not something specific
#'   to how this function builds its content. **Visually check rendered
#'   output** before relying on `fill_stipple()` (or [fill_scatter()]/
#'   [fill_halftone()], which share this risk) for anything beyond casual
#'   use, especially on unfamiliar R/`grid`/graphics-device versions.
#'
#' @param color One or more dot colours. A vector shorter than `n` is
#'   recycled (in order, not randomly) across the scattered dots -- a single
#'   colour (the default) colours every dot the same, matching the original
#'   behaviour. Default `"black"`.
#' @param radius Dot radius, as a `"npc"` fraction of the tile. Must be a
#'   positive number. Default `0.15`.
#' @param spacing Baseline tile size, as a fraction of the target's bounding
#'   box. Must be a positive number. Default `0.3`.
#' @param n Number of dots scattered per tile. Must be a positive integer.
#'   Default `4L`.
#' @param seed Integer seed for the dot positions. Default `1L`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_stipple(n = 6L, seed = 2091L)))
#'
#' # more, smaller dots per tile give a denser stipple
#' draw(shape_circle(
#'   fill = fill_stipple(n = 15L, radius = 0.06, spacing = 0.5, seed = 2091L)
#' ))
#'
#' # a colour vector is recycled across the dots
#' draw(shape_circle(
#'   fill = fill_stipple(color = c("steelblue", "tomato"), n = 8L, seed = 2091L)
#' ))
#'
#' @family fill helpers
#' @export
fill_stipple <- function(color = "black",
                         radius = 0.15,
                         spacing = 0.3,
                         aspect = NULL,
                         n = 4L,
                         seed = 1L,
                         extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  validate_colors(color, "color")
  if (!is.numeric(radius) || length(radius) != 1 || radius <= 0) {
    rlang::abort("radius must be a single positive number")
  }
  if (!is.numeric(n) || length(n) != 1 || n < 1 || n != round(n)) {
    rlang::abort("n must be a single positive integer")
  }
  if (!is.numeric(seed) || length(seed) != 1 || seed != round(seed)) {
    rlang::abort("seed must be a single integer")
  }

  # dot centres kept at least `radius` from the tile edge, so dots aren't
  # clipped away when they fall near a boundary
  withr::with_seed(
    seed = as.integer(seed),
    code = {
      x <- stats::runif(n, radius, 1 - radius)
      y <- stats::runif(n, radius, 1 - radius)
    }
  )
  dot_colors <- rep_len(color, n)

  dots <- purrr::pmap(list(x, y, dot_colors), function(cx, cy, cc) {
    grid::circleGrob(
      x = cx, y = cy, r = radius,
      default.units = "npc",
      gp = grid::gpar(col = NA, fill = cc)
    )
  })
  content <- grid::grobTree(do.call(grid::gList, dots))

  # the aspect correction here mirrors fill_hatch()'s: it keeps the tile
  # physically square (in bbox-relative terms) so a circular dot doesn't
  # render as an ellipse
  grid::pattern(
    content,
    width = spacing, height = spacing * aspect,
    extend = extend
  )
  }
  resolvable_fill(build, aspect)
}

#' Scattered-shape pattern fill
#'
#' `fill_scatter()` generalizes [fill_stipple()]: instead of a fixed dot,
#' it scatters copies of an arbitrary small [drawable] -- rendered with its
#' own `style` (colour, fill, linewidth), which may itself be another
#' `fill_*()` pattern -- at random positions inside each tile, using
#' [withr::with_seed()] for reproducibility exactly as [fill_stipple()]
#' does.
#'
#' `unit`'s own points are rescaled (preserving its own aspect ratio) to a
#' bounding box of size `size` and re-centred at each scattered position;
#' its absolute coordinates, position, and radius/width/etc. don't matter,
#' only its shape.
#'
#' This needed two corrections neither [fill_stipple()]'s circles nor
#' [fill_gradient()]'s/[fill_checker()]'s rectangles did:
#'
#' - Every other `fill_*()` helper's tile-squaring correction (`height =
#'   spacing * aspect`, keeping the tile physically square) was, by
#'   itself, enough to keep circular/rectangular content correctly
#'   proportioned. Arbitrary polygon content does not get the same
#'   treatment: empirically, a [grid::polygonGrob()] (or
#'   [grid::pathGrob()]) used as pattern content renders as though it
#'   inherits the *target's own, uncorrected* bounding-box distortion
#'   directly, regardless of the tile-squaring correction applied around
#'   it -- confirmed by testing a hand-built circular polygon side by side
#'   with an equivalent [grid::circleGrob()] in the same corrected tile:
#'   the circle stayed circular, the polygon became an ellipse. So
#'   `fill_scatter()` applies a second, explicit correction directly to
#'   `unit`'s own vertex x-coordinates (dividing by `aspect`) on top of
#'   the usual tile-squaring.
#' - Repeated (tiled) polygon content can render with visible clipping
#'   artifacts on Cairo devices -- confirmed interactively: a single
#'   stamp, comfortably inside its tile's margins, rendered as a clean
#'   shape when the tile spans the whole target (`spacing = 1`, so
#'   `extend = "repeat"` is present but never actually exercised within
#'   the visible, clipped area) but as a "bitten" partial shape once
#'   `spacing < 1` made the device actually tile multiple copies. This
#'   matches [grid::pattern()]'s own documented warning that "on Cairo
#'   devices, use of clipping in the pattern definition should be avoided
#'   because it is very likely to result in distortion of the pattern
#'   tile." Circles/rectangles/rasters didn't show this in the rest of
#'   the family, but arbitrary polygon geometry did. `spacing` therefore
#'   defaults to `1` here (one tile spans the whole shape, scattering all
#'   `n` copies across it at once) rather than the smaller, densely-tiled
#'   defaults used elsewhere; setting `spacing < 1` is still possible for
#'   a repeating scattered motif, but may show this distortion. (Later
#'   testing on [fill_stipple()] found the same *actually-repeated tile
#'   with multiple shapes* combination distorts circleGrob content too,
#'   not just polygons -- see its "Known rendering risk" section. A
#'   single tile with multiple shapes, as used by this function's
#'   default, was never observed to have the problem; only real
#'   repetition, `spacing < 1`, was.)
#'
#' @param unit A small [drawable] to scatter copies of. Default
#'   `shape_circle(radius = 1)`.
#' @param n Number of copies scattered per tile. Must be a positive
#'   integer. Default `6L`.
#' @param size `unit`'s rescaled size, as a `"npc"` fraction of the tile.
#'   Must be a number strictly between `0` and `1`. Default `0.2`.
#' @param color `NULL`, or one or more colours overriding `unit@style@color`
#'   for each stamp, recycled (in order, not randomly) across the `n`
#'   copies. `NULL` (the default) colours every stamp from `unit`'s own
#'   style, as before this argument existed.
#' @param seed Integer seed for the scatter positions. Default `1L`.
#' @param spacing Tile size, as a fraction of the target's bounding box.
#'   Must be a positive number. Default `1` (one tile spans the whole
#'   shape, since `spacing < 1` risks the tiling distortion described
#'   above).
#' @param aspect Width-to-height ratio of the target polygon's bounding
#'   box. Must be a positive number, or `NULL` (the default) to resolve it
#'   automatically at [draw()] time -- see [fill_hatch()]'s own `aspect`
#'   docs.
#' @param extend Passed to [grid::pattern()]. Default `"repeat"`.
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(
#'   fill = fill_scatter(unit = shape_circle(radius = 1), n = 8L, size = 0.15)
#' ))
#'
#' # any small drawable works as the scattered unit, e.g. a triangle
#' draw(shape_circle(
#'   fill = fill_scatter(
#'     unit = shape_polygon(n = 3, fill = "steelblue"),
#'     n = 10L,
#'     size = 0.2
#'   )
#' ))
#'
#' # a color vector overrides unit's own style colour, recycled per stamp
#' draw(shape_circle(
#'   fill = fill_scatter(
#'     color = c("steelblue", "tomato", "goldenrod"),
#'     n = 9L,
#'     size = 0.15
#'   )
#' ))
#'
#' @family fill helpers
#' @export
fill_scatter <- function(unit = shape_circle(radius = 1),
                         n = 6L,
                         size = 0.2,
                         color = NULL,
                         spacing = 1,
                         aspect = NULL,
                         seed = 1L,
                         extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  if (!S7::S7_inherits(unit, drawable)) {
    rlang::abort("unit must be a drawable")
  }
  if (!is.numeric(size) || length(size) != 1 || size <= 0 || size >= 1) {
    rlang::abort("size must be a single number strictly between 0 and 1")
  }
  if (!is.numeric(n) || length(n) != 1 || n < 1 || n != round(n)) {
    rlang::abort("n must be a single positive integer")
  }
  if (!is.null(color)) {
    validate_colors(color, "color")
  }
  if (!is.numeric(seed) || length(seed) != 1 || seed != round(seed)) {
    rlang::abort("seed must be a single integer")
  }

  px <- unit@points@x
  py <- unit@points@y
  half_extent <- max(diff(range(px)), diff(range(py))) / 2
  if (!is.finite(half_extent) || half_extent == 0) {
    rlang::abort("unit must have nonzero, finite extent")
  }
  scale_factor <- (size / 2) / half_extent

  # rescale unit's own points to fit a `size`-npc bounding box, preserving
  # its own aspect ratio -- then apply the polygon-specific aspect
  # correction described above, on top of (not instead of) the tile's own
  # squaring below
  norm_x <- (px - mean(range(px))) * scale_factor / aspect
  norm_y <- (py - mean(range(py))) * scale_factor

  # scattered centres kept at least `size/2` from the tile edge, so copies
  # aren't clipped away when they fall near a boundary
  margin <- size / 2
  withr::with_seed(
    seed = as.integer(seed),
    code = {
      cx <- stats::runif(n, margin, 1 - margin)
      cy <- stats::runif(n, margin, 1 - margin)
    }
  )

  stamp_colors <- if (is.null(color)) rep(unit@style@color, n) else rep_len(color, n)
  # unit@style@fill is a fill object (possibly still unresolved, e.g. a
  # nested fill_*() pattern with its own auto-resolving aspect); resolve it
  # against unit's own bounding-box aspect before embedding it in a nested
  # gpar(), the same way draw() resolves a top-level drawable's own fill
  unit_fill <- resolve_fill(unit@style@fill, bbox_aspect(unit))

  stamps <- purrr::pmap(list(cx, cy, stamp_colors), function(ccx, ccy, ccol) {
    grid::polygonGrob(
      x = norm_x + ccx, y = norm_y + ccy,
      default.units = "npc",
      gp = grid::gpar(
        col = ccol,
        fill = unit_fill,
        lwd = unit@style@linewidth
      )
    )
  })
  content <- grid::grobTree(do.call(grid::gList, stamps))

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Halftone dot pattern fill
#'
#' `fill_halftone()` is [fill_stipple()]'s other variant: instead of
#' scattering dots of one fixed size, each dot's radius is drawn
#' uniformly at random from `radius`, giving a mottled halftone-print
#' look rather than a uniform stipple.
#'
#' Like [fill_stipple()] (and unlike [fill_scatter()]), it scatters plain
#' [grid::circleGrob()]s, so it's immune to the *polygon*-specific
#' rendering problems documented at [fill_scatter()] -- but it shares
#' [fill_stipple()]'s own, separate "Known rendering risk with multiple
#' dots" (repeated tiles containing several `circleGrob`s were, in
#' testing, sometimes visibly distorted on this package's development R
#' build; see that section for details). There is no known way to avoid
#' this while still getting a genuine scattered-dot texture, so **check
#' rendered output visually** here too.
#'
#' As with [fill_stipple()], `aspect` corrects for the target's own
#' bounding-box aspect ratio automatically by default, keeping the dots
#' circular rather than elliptical (see [fill_hatch()]'s own `aspect`
#' docs). Dot centres are kept at least `max(radius)` from each tile
#' edge, so even the largest possible dot isn't clipped away near a
#' boundary.
#'
#' @param radius Dot radius range, as a length-2 numeric vector giving the
#'   `"npc"`-fraction-of-tile minimum and maximum (a dot's actual radius is
#'   drawn uniformly from this range). Both values must be positive, and
#'   the first must be no larger than the second. Default `c(0.05, 0.2)`.
#' @inheritParams fill_stipple
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(
#'   fill = fill_halftone(radius = c(0.05, 0.15), seed = 3187L)
#' ))
#'
#' # a wider radius range gives more size contrast between dots
#' draw(shape_circle(
#'   fill = fill_halftone(radius = c(0.02, 0.22), n = 6L, seed = 3187L)
#' ))
#'
#' # a colour vector is recycled across the dots, as in fill_stipple()
#' draw(shape_circle(
#'   fill = fill_halftone(
#'     color = c("steelblue", "tomato"),
#'     n = 8L,
#'     seed = 3187L
#'   )
#' ))
#'
#' @family fill helpers
#' @export
fill_halftone <- function(color = "black",
                          radius = c(0.05, 0.2),
                          spacing = 0.3,
                          aspect = NULL,
                          n = 4L,
                          seed = 1L,
                          extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  validate_colors(color, "color")
  if (!is.numeric(radius) || length(radius) != 2 || any(radius <= 0)) {
    rlang::abort("radius must be a length-2 vector of positive numbers")
  }
  if (radius[1] > radius[2]) {
    rlang::abort("radius[1] must be no larger than radius[2]")
  }
  if (radius[2] >= 0.5) {
    rlang::abort("radius[2] must be less than 0.5, so dots fit within a tile")
  }
  if (!is.numeric(n) || length(n) != 1 || n < 1 || n != round(n)) {
    rlang::abort("n must be a single positive integer")
  }
  if (!is.numeric(seed) || length(seed) != 1 || seed != round(seed)) {
    rlang::abort("seed must be a single integer")
  }

  margin <- radius[2]
  withr::with_seed(
    seed = as.integer(seed),
    code = {
      x <- stats::runif(n, margin, 1 - margin)
      y <- stats::runif(n, margin, 1 - margin)
      r <- stats::runif(n, radius[1], radius[2])
    }
  )
  dot_colors <- rep_len(color, n)

  dots <- purrr::pmap(list(x, y, r, dot_colors), function(cx, cy, cr, cc) {
    grid::circleGrob(
      x = cx, y = cy, r = cr,
      default.units = "npc",
      gp = grid::gpar(col = NA, fill = cc)
    )
  })
  content <- grid::grobTree(do.call(grid::gList, dots))

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Build the (along, across) coordinates of a random-harmonic wander line
#'
#' Internal helper shared by [fill_scribble()] and [curve_scribble()]. Each
#' line is a random finite sum of sine harmonics, all at *integer*
#' frequencies, in `across = f(along)` form: `along` runs from `0` to `1`,
#' and by construction `f(0) == f(1)` to full floating-point precision (an
#' integer number of full periods always closes exactly), and likewise for
#' the function's derivative -- so the line always meets itself, in both
#' position and tangent direction, at the two ends of `along`. That's what
#' makes it tile seamlessly under [grid::pattern()]'s `extend = "repeat"`:
#' each tile's copy of the line picks up exactly where the previous tile's
#' left off (periodicity irrelevant to [curve_scribble()], which draws a
#' single standalone line rather than a repeating tile, but harmless there
#' too). See [fill_scribble()] details for the rest of the periodicity
#' argument.
#'
#' @param n_lines,n_harmonics,amplitude,resolution,seed As in
#'   [fill_scribble()]. [curve_scribble()] always calls this with
#'   `n_lines = 1`.
#' @return A list of `n_lines` elements, each a list with numeric vectors
#'   `along` and `across`, both length `resolution`.
#' @noRd
scribble_lines <- function(n_lines, n_harmonics, amplitude, resolution, seed) {
  along <- seq(0, 1, length.out = resolution)
  withr::with_seed(
    seed = as.integer(seed),
    code = {
      lines <- vector("list", n_lines)
      for (i in seq_len(n_lines)) {
        baseline <- stats::runif(1, 0.15, 0.85)
        # integer frequencies only -- required for across(0) == across(1)
        freq <- sample.int(4, n_harmonics, replace = TRUE)
        amp <- stats::runif(n_harmonics, 0, amplitude) / n_harmonics
        phase <- stats::runif(n_harmonics, 0, 2 * pi)
        across <- baseline
        for (j in seq_len(n_harmonics)) {
          across <- across + amp[j] * sin(2 * pi * freq[j] * along + phase[j])
        }
        lines[[i]] <- list(along = along, across = across)
      }
    }
  )
  lines
}

#' Wandering-line scribble texture fill
#'
#' `fill_scribble()` builds a [grid::pattern()] fill value from several
#' randomly wandering lines, each a random finite sum of sine harmonics
#' (see the internal `scribble_lines()` helper) rather than a smooth noise
#' field or a scattered discrete motif -- giving a loose, hand-drawn
#' scribble texture built from genuinely continuous strokes.
#'
#' A wandering *open* line poses a tiling problem none of the other
#' `fill_*()` helpers have: [fill_hatch()]'s diagonal and [fill_noise()]'s
#' raster both tile by construction (a straight corner-to-corner line, or
#' an already-periodic field), and [fill_stipple()]/[fill_scatter()]/
#' [fill_halftone()] sidestep the problem entirely by keeping their
#' scattered content margined well clear of the tile edge. A wandering
#' line that's meant to look continuous *can't* stay clear of the edge --
#' it has to run all the way to it, and pick up again at exactly the right
#' place, in both position and slope, on the opposite edge, or the seam
#' shows as a visible kink. `fill_scribble()` gets this for free by
#' building each line as a random sum of sine harmonics at *integer*
#' frequencies only: over one full period, such a sum always returns
#' exactly to its starting value and slope (to floating-point precision),
#' so consecutive tile copies join with no visible seam -- confirmed
#' visually with `extend = "repeat"` at small `spacing`, including
#' repeated copies (unlike the polygon-in-a-genuinely-repeated-tile issue
#' documented at [fill_scatter()], open-line content showed no clipping or
#' distortion in testing).
#'
#' @section Known limitation -- direction is fixed, not an arbitrary angle:
#'   Every other angled helper ([fill_hatch()]/[fill_crosshatch()]/
#'   [fill_stripe()]) achieves an arbitrary angle by reshaping the *tile*
#'   itself (via `hatch_tile_dims()`) around content that's a plain
#'   corner-to-corner diagonal. That trick was tried here first and found
#'   not to generalize: reshaping the tile around a *wandering* line just
#'   anisotropically stretches its wiggle rather than rotating it, since
#'   the line's content isn't a bare diagonal the tile shape can
#'   reinterpret. A genuinely rotated wandering line would need the tile
#'   built as a rotated/sheared parallelogram with edge-matching worked
#'   out for a curve rather than a segment -- no such technique exists in
#'   this package yet. `direction` is therefore restricted to `"horizontal"`
#'   (lines run left-right, periodic tiling along that axis) or
#'   `"vertical"` (lines run top-bottom instead, i.e. `along`/`across` from
#'   `scribble_lines()` mapped to `y`/`x` rather than `x`/`y`) -- there is
#'   no `angle` argument. Revisit if a real sketch needs an arbitrary
#'   angle.
#'
#' @param color One or more line colours. A vector shorter than `n_lines` is
#'   recycled (in order, not randomly) across the wandering lines -- a
#'   single colour (the default) colours every line the same, matching the
#'   original behaviour. Default `"black"`.
#' @param direction Either `"horizontal"` (lines run left-right) or
#'   `"vertical"` (lines run top-bottom). Default `"horizontal"`.
#' @param n_lines Number of wandering lines per tile. Must be a positive
#'   integer. Default `5L`.
#' @param n_harmonics Number of sine harmonics summed per line. Must be a
#'   positive integer. Default `3L`.
#' @param amplitude Maximum total wiggle amplitude, as a `"npc"` fraction
#'   of the tile, split across `n_harmonics` (so more harmonics each
#'   contribute proportionally less). Must be a non-negative number.
#'   Default `0.35`.
#' @param resolution Number of points sampled along each line. Must be a
#'   positive integer of at least `2L`. Default `200L`.
#' @param linewidth Line width. Must be a positive number. Default `1`.
#' @param spacing Baseline tile size, as a fraction of the target's bounding
#'   box. Must be a positive number. Default `0.25`.
#' @param seed Integer seed for the random harmonics. Default `1L`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_scribble(n_lines = 4L, seed = 6602L)))
#'
#' # direction = "vertical" runs the wandering lines top-to-bottom instead
#' draw(shape_circle(
#'   fill = fill_scribble(n_lines = 4L, direction = "vertical", seed = 6602L)
#' ))
#'
#' # more harmonics and higher amplitude give a more agitated scribble
#' draw(shape_circle(
#'   fill = fill_scribble(
#'     n_lines = 6L,
#'     n_harmonics = 6L,
#'     amplitude = 0.6,
#'     seed = 6602L
#'   )
#' ))
#'
#' # a colour vector is recycled across the wandering lines
#' draw(shape_circle(
#'   fill = fill_scribble(
#'     color = c("steelblue", "tomato"),
#'     n_lines = 4L,
#'     seed = 6602L
#'   )
#' ))
#'
#' @family fill helpers
#' @export
fill_scribble <- function(color = "black",
                          direction = c("horizontal", "vertical"),
                          n_lines = 5L,
                          n_harmonics = 3L,
                          amplitude = 0.35,
                          resolution = 200L,
                          linewidth = 1,
                          spacing = 0.25,
                          aspect = NULL,
                          seed = 1L,
                          extend = "repeat") {
  direction <- match.arg(direction)
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  if (!is.numeric(n_lines) || length(n_lines) != 1 ||
    n_lines < 1 || n_lines != round(n_lines)) {
    rlang::abort("n_lines must be a single positive integer")
  }
  if (!is.numeric(n_harmonics) || length(n_harmonics) != 1 ||
    n_harmonics < 1 || n_harmonics != round(n_harmonics)) {
    rlang::abort("n_harmonics must be a single positive integer")
  }
  if (!is.numeric(amplitude) || length(amplitude) != 1 || amplitude < 0) {
    rlang::abort("amplitude must be a single non-negative number")
  }
  if (!is.numeric(resolution) || length(resolution) != 1 ||
    resolution < 2 || resolution != round(resolution)) {
    rlang::abort("resolution must be a single integer of at least 2")
  }
  validate_colors(color, "color")
  if (!is.numeric(linewidth) || length(linewidth) != 1 || linewidth <= 0) {
    rlang::abort("linewidth must be a single positive number")
  }
  if (!is.numeric(seed) || length(seed) != 1 || seed != round(seed)) {
    rlang::abort("seed must be a single integer")
  }

  lines <- scribble_lines(
    n_lines = round(n_lines),
    n_harmonics = round(n_harmonics),
    amplitude = amplitude,
    resolution = round(resolution),
    seed = seed
  )
  line_colors <- rep_len(color, round(n_lines))

  strokes <- purrr::map2(lines, line_colors, function(ln, cc) {
    if (direction == "horizontal") {
      x <- ln$along
      y <- ln$across
    } else {
      x <- ln$across
      y <- ln$along
    }
    grid::linesGrob(
      x = x, y = y, default.units = "npc",
      gp = grid::gpar(col = cc, lwd = linewidth)
    )
  })
  content <- grid::grobTree(do.call(grid::gList, strokes))

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Torus-mapped tile coordinates for a periodic raster fill
#'
#' Internal helper shared by [fill_noise()], [fill_marble()], and
#' [fill_flow()]. Builds a `resolution`-by-`resolution` grid of tile pixel
#' centres, in both plain `(u, v) \eqn{\in} [0, 1]` form and mapped onto a
#' pair of circles (`theta_u`/`theta_v`, in radians) -- the latter is what
#' `torus_noise()` samples from, so a noise field built on it is exactly
#' periodic in both tile directions. See [fill_noise()] details for why
#' this matters.
#'
#' @param resolution As in [fill_noise()].
#' @return A list with elements `u`, `v`, `theta_u`, `theta_v`, each a
#'   numeric vector of length `resolution^2`.
#' @noRd
torus_grid <- function(resolution) {
  u <- (seq_len(resolution) - 0.5) / resolution
  v <- (seq_len(resolution) - 0.5) / resolution
  uv <- expand.grid(v = v, u = u)
  list(
    u = uv$u, v = uv$v,
    theta_u = 2 * pi * uv$u, theta_v = 2 * pi * uv$v
  )
}

#' Sample a torus-periodic simplex/fractal noise field
#'
#' Internal helper shared by [fill_noise()], [fill_marble()], and
#' [fill_flow()]. Thin wrapper around `ambient::fracture()`/
#' `ambient::gen_simplex()`/`ambient::fbm()` that maps a pair of tile
#' angles (`theta_u`/`theta_v`, as produced by `torus_grid()`, optionally
#' already warped -- see [fill_flow()]) onto `ambient::gen_simplex()`'s 4
#' input dimensions (`x`/`y` for `theta_u`'s circle, `z`/`t` for
#' `theta_v`'s), so the result is exactly periodic in both tile directions
#' regardless of what `theta_u`/`theta_v` were derived from. Returns the
#' raw (unnormalized) field -- callers apply their own
#' `ambient::normalize()`.
#'
#' @param theta_u,theta_v Tile angles in radians, as produced by
#'   `torus_grid()` (or a warped variant of them).
#' @param frequency,octaves,seed As in [fill_noise()].
#' @return A numeric vector the same length as `theta_u`/`theta_v`.
#' @noRd
torus_noise <- function(theta_u, theta_v, frequency, octaves, seed) {
  ambient::fracture(
    noise = ambient::gen_simplex,
    fractal = ambient::fbm,
    x = cos(theta_u) * frequency,
    y = sin(theta_u) * frequency,
    z = cos(theta_v) * frequency,
    t = sin(theta_v) * frequency,
    seed = as.integer(seed),
    octaves = as.integer(octaves)
  )
}

#' Map a normalized noise field to pixel colour strings
#'
#' Internal helper shared by [fill_noise()] and [fill_flow()]. A single
#' `color` fades in opacity from fully transparent to `alpha` across the
#' field's own range -- the exact original behavior of both functions,
#' before they accepted a colour vector. Two or more `color`s instead blend
#' across a `grDevices::colorRamp()` built from them, driven by the same
#' normalized field value, with `alpha` applied as a flat opacity -- a
#' fading multi-hue blend can't also fade to fully transparent without one
#' colour vanishing arbitrarily before the others.
#'
#' @param value01 The noise field, already normalized to `[0, 1]`.
#' @param color A character vector of one or more colours.
#' @param alpha As in [fill_noise()].
#' @return A character vector of colour strings the same length as `value01`.
#' @noRd
noise_to_pixels <- function(value01, color, alpha) {
  if (length(color) == 1) {
    rgb <- grDevices::col2rgb(color) / 255
    grDevices::rgb(rgb["red", ], rgb["green", ], rgb["blue", ], alpha = value01 * alpha)
  } else {
    ramp <- grDevices::colorRamp(color)
    rgb <- ramp(value01) / 255
    grDevices::rgb(rgb[, 1], rgb[, 2], rgb[, 3], alpha = alpha)
  }
}

#' Simplex/fractal noise texture fill
#'
#' `fill_noise()` builds a [grid::pattern()] fill value from a rasterised
#' simplex/fractal noise field, using the same noise machinery as
#' [shape_blob()]'s wobbly outline (`ambient::fracture()` /
#' `ambient::gen_simplex()` / `ambient::fbm()`, with matching `frequency`,
#' `octaves`, and `seed` arguments), so a noise-filled shape and a
#' noise-wobbled outline share one visual vocabulary.
#'
#' Noise is rendered as varying opacity of a single `color`, from fully
#' transparent at the noise field's minimum to `alpha` at its maximum --
#' a mottled, cloud-like texture rather than a hard-edged one.
#'
#' A raster tile has no baked-in direction the way a hatch line does, so
#' [fill_hatch()]'s tile-edge "dashing" problem doesn't apply directly, but
#' an *ordinary* noise field still isn't periodic, and [grid::pattern()]'s
#' `extend = "repeat"` will visibly seam wherever one tile edge fails to
#' match the next. `fill_noise()` avoids this by sampling the noise on a
#' torus: each raster pixel's `(u, v)` tile coordinate is mapped onto a pair
#' of circles (`ambient::gen_simplex()`'s 4 dimensions, `x`/`y` for `u` and
#' `z`/`t` for `v`) rather than sampled directly, so the field is
#' mathematically periodic in both directions and tiles with no visible
#' seam, at the cost of the noise "wrapping around" within each tile rather
#' than varying smoothly across a larger area.
#'
#' In practice, a very faint seam can still be visible at tile boundaries on
#' some devices, even though the underlying field is exactly periodic; this
#' appears to be an artifact of how the graphics device samples a repeated
#' raster tile (it persists regardless of `interpolate` and doesn't improve
#' with higher `resolution`), not a flaw in the noise field itself, and is
#' far subtler than the tile-edge mismatch [fill_hatch()] has to actively
#' avoid.
#'
#' @param color One or more fill colours. A single colour (the default)
#'   fades in opacity from fully transparent to `alpha`, exactly as before
#'   this argument accepted a vector. Two or more colours instead blend
#'   across a `grDevices::colorRamp()` built from them, driven by the noise
#'   value, with `alpha` applied as a flat opacity across the whole fill
#'   (see the internal `noise_to_pixels()` helper). Default `"black"`.
#' @param spacing Baseline tile size, as a fraction of the target's bounding
#'   box. Must be a positive number. Default `0.5`.
#' @param resolution Raster resolution (pixels per tile edge). Must be a
#'   positive integer of at least `2L`. Default `32L`.
#' @param alpha Opacity. For a single `color`, the maximum opacity at the
#'   noise field's peak; for two or more, a flat opacity applied uniformly.
#'   Must be a number in `(0, 1]`. Default `1`.
#' @param frequency Noise frequency, as in [shape_blob()]. Must be non-negative.
#'   Default `1`.
#' @param octaves Number of noise octaves, as in [shape_blob()]. Must be a
#'   positive integer. Default `2L`.
#' @param seed Integer seed for the noise field, as in [shape_blob()]. Default
#'   `1L`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_noise(seed = 8843L)))
#'
#' # higher frequency/octaves give finer-grained texture
#' draw(shape_circle(
#'   fill = fill_noise(frequency = 4, octaves = 4L, seed = 8843L)
#' ))
#'
#' # a lower alpha lets the shape's own outline/background show through more
#' draw(shape_circle(
#'   fill = fill_noise(color = "steelblue", alpha = 0.5, seed = 8843L)
#' ))
#'
#' # two or more colours blend across the field instead of fading to transparent
#' draw(shape_circle(
#'   fill = fill_noise(color = c("steelblue", "white", "tomato"), seed = 8843L)
#' ))
#'
#' @family fill helpers
#' @export
fill_noise <- function(color = "black",
                       spacing = 0.5,
                       aspect = NULL,
                       resolution = 32L,
                       alpha = 1,
                       frequency = 1,
                       octaves = 2L,
                       seed = 1L,
                       extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  validate_colors(color, "color")
  if (!is.numeric(resolution) || length(resolution) != 1 ||
    resolution < 2 || resolution != round(resolution)) {
    rlang::abort("resolution must be a single integer of at least 2")
  }
  if (!is.numeric(alpha) || length(alpha) != 1 || alpha <= 0 || alpha > 1) {
    rlang::abort("alpha must be a single number in (0, 1]")
  }
  if (!is.numeric(frequency) || length(frequency) != 1 || frequency < 0) {
    rlang::abort("frequency must be a single non-negative number")
  }
  if (!is.numeric(octaves) || length(octaves) != 1 ||
    octaves < 1 || octaves != round(octaves)) {
    rlang::abort("octaves must be a single positive integer")
  }
  if (!is.numeric(seed) || length(seed) != 1 || seed != round(seed)) {
    rlang::abort("seed must be a single integer")
  }

  resolution <- as.integer(resolution)
  # sample on a torus (two circles, one per tile axis) rather than directly
  # in (u, v), so the field is exactly periodic and tiles with no seam
  grid_uv <- torus_grid(resolution)

  value01 <- torus_noise(grid_uv$theta_u, grid_uv$theta_v, frequency, octaves, seed) |>
    ambient::normalize(to = c(0, 1))

  pixels <- matrix(
    noise_to_pixels(value01, color, alpha),
    nrow = resolution, ncol = resolution
  )
  raster <- grid::rasterGrob(
    pixels,
    width = 1, height = 1,
    default.units = "npc", interpolate = TRUE
  )

  grid::pattern(raster, width = spacing, height = spacing * aspect, extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Marbled, veined texture fill
#'
#' `fill_marble()` builds a [grid::pattern()] fill value resembling veined
#' marble: a set of `stripes` parallel bands running around the tile's `u`
#' axis, displaced by a [fill_noise()]-style torus-periodic turbulence
#' field (via the shared internal `torus_grid()`/`torus_noise()` helpers)
#' rather than left straight -- the classic "sine of a coordinate plus
#' turbulence" recipe for procedural marble.
#'
#' Periodicity needs two things, both already true here: the undisplaced
#' bands (`sin(theta_u * stripes)`) are periodic in `u` for any *integer*
#' `stripes`, since `theta_u` itself advances by exactly `2 * pi` over one
#' tile width; and the turbulence added on top is periodic in both `u` and
#' `v` because it comes from `torus_noise()`, the same torus-sampling
#' technique [fill_noise()] uses for its own field. Adding one periodic
#' function to another (here, inside a further `sin()`) stays periodic, so
#' the combined result still tiles with no seam.
#'
#' Unlike [fill_noise()] (opacity of one colour), the banding is rendered
#' as a blend across `color` via `grDevices::colorRamp()`, since a marble
#' texture's visual interest is the veining pattern itself rather than a
#' fade to transparency.
#'
#' [fill_noise()]'s own faint tile-boundary rasterization seam (see its
#' details) can be more noticeable here: `sin()` turns a small mismatch in
#' the turbulence field into a visibly sharper edge in a band than the
#' same mismatch would produce in a plain opacity fade.
#'
#' @param color Two or more colours blended across each band, in order,
#'   via `grDevices::colorRamp()`. Default `c("white", "black")`.
#' @param stripes Number of bands running around the tile's `u` axis before
#'   turbulence displacement. Must be a positive integer. Default `3L`.
#' @param warp Turbulence amplitude, in radians of displacement along the
#'   band coordinate. Must be a non-negative number. Default `4`.
#' @param octaves Number of turbulence octaves, as in [shape_blob()]. Must be a
#'   positive integer. Default `3L`.
#' @inheritParams fill_noise
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_marble(stripes = 4L, seed = 1274L)))
#'
#' # more stripes and stronger warp give busier, more tangled veining
#' draw(shape_circle(fill = fill_marble(stripes = 8L, warp = 8, seed = 1274L)))
#'
#' # a different colour pair changes the veining's contrast entirely
#' draw(shape_circle(
#'   fill = fill_marble(
#'     color = c("black", "goldenrod"),
#'     stripes = 4L,
#'     seed = 1274L
#'   )
#' ))
#'
#' # three or more colours blend across the band in sequence
#' draw(shape_circle(
#'   fill = fill_marble(
#'     color = c("black", "goldenrod", "white"),
#'     stripes = 4L,
#'     seed = 1274L
#'   )
#' ))
#'
#' @family fill helpers
#' @export
fill_marble <- function(color = c("white", "black"),
                        spacing = 0.5,
                        aspect = NULL,
                        resolution = 32L,
                        stripes = 3L,
                        warp = 4,
                        frequency = 1,
                        octaves = 3L,
                        seed = 1L,
                        extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  validate_colors(color, "color", min_length = 2)
  if (!is.numeric(resolution) || length(resolution) != 1 ||
    resolution < 2 || resolution != round(resolution)) {
    rlang::abort("resolution must be a single integer of at least 2")
  }
  if (!is.numeric(stripes) || length(stripes) != 1 ||
    stripes < 1 || stripes != round(stripes)) {
    rlang::abort("stripes must be a single positive integer")
  }
  if (!is.numeric(warp) || length(warp) != 1 || warp < 0) {
    rlang::abort("warp must be a single non-negative number")
  }
  if (!is.numeric(frequency) || length(frequency) != 1 || frequency < 0) {
    rlang::abort("frequency must be a single non-negative number")
  }
  if (!is.numeric(octaves) || length(octaves) != 1 ||
    octaves < 1 || octaves != round(octaves)) {
    rlang::abort("octaves must be a single positive integer")
  }
  if (!is.numeric(seed) || length(seed) != 1 || seed != round(seed)) {
    rlang::abort("seed must be a single integer")
  }

  resolution <- as.integer(resolution)
  grid_uv <- torus_grid(resolution)

  turbulence <- torus_noise(grid_uv$theta_u, grid_uv$theta_v, frequency, octaves, seed) |>
    ambient::normalize(to = c(-1, 1))

  # bands run around theta_u; adding periodic turbulence before sin() keeps
  # the whole expression periodic in both tile directions -- see details
  value <- (sin(grid_uv$theta_u * round(stripes) + warp * turbulence) + 1) / 2

  ramp <- grDevices::colorRamp(color)
  rgb <- ramp(value) / 255
  pixels <- matrix(
    grDevices::rgb(rgb[, 1], rgb[, 2], rgb[, 3]),
    nrow = resolution, ncol = resolution
  )
  raster <- grid::rasterGrob(
    pixels,
    width = 1, height = 1,
    default.units = "npc", interpolate = TRUE
  )

  grid::pattern(raster, width = spacing, height = spacing * aspect, extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Domain-warped noise texture fill
#'
#' `fill_flow()` is a swirlier variant of [fill_noise()]: before sampling
#' the final noise field, the tile's own `(theta_u, theta_v)` angles (see
#' [fill_noise()] details for why angles, not raw `(u, v)`) are displaced
#' by a second, independent torus-periodic noise field -- the "fBm of fBm"
#' domain-warping recipe popularized for flowing, curl-noise-like
#' textures, adapted here so the warp field is itself torus-periodic
#' rather than sampled directly, keeping the whole result seamless.
#'
#' The warp field needs to be decorrelated from the final field and from
#' itself along each axis, but `ambient::gen_simplex()`'s 4 input
#' dimensions are already fully spent on the `(theta_u, theta_v)` torus
#' trick, leaving no spare dimension to offset. `fill_flow()` decorrelates
#' by seed instead: the `u`- and `v`-displacement fields are sampled at
#' `seed + 104729L` and `seed + 200003L` respectively (arbitrary large
#' primes, chosen only to make collisions with a user's own nearby seed
#' choices unlikely), before the final field is sampled at `seed` itself.
#'
#' Displacing a periodic field's own periodic coordinates by another
#' periodic field preserves periodicity: shifting `u` from `0` to `1`
#' still advances `theta_u` by exactly `2 * pi` (a full turn), and the
#' warp added at each end is identical since it's sampled from a field
#' that's periodic in `u` itself -- so the warped angle wraps around
#' exactly as the unwarped one did, with no seam.
#'
#' As with [fill_noise()], a faint tile-boundary rasterization seam can
#' still be visible on some devices despite the field being exactly
#' periodic (see its details); larger `warp` values tend to make this
#' more noticeable, for the same reason described at [fill_marble()].
#'
#' @param warp Warp amplitude, in radians of angular displacement. Must be
#'   a non-negative number. Default `2`.
#' @param warp_frequency Frequency of the two warp-displacement noise
#'   fields. Must be non-negative. Default `1`.
#' @param warp_octaves Number of octaves for the warp-displacement noise
#'   fields. Must be a positive integer. Default `1L`.
#' @inheritParams fill_noise
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_flow(warp = 3, seed = 9350L)))
#'
#' # a larger warp gives a swirlier, more curl-noise-like look; warp = 0
#' # reduces to plain fill_noise()
#' draw(shape_circle(fill = fill_flow(warp = 0, seed = 9350L)))
#' draw(shape_circle(fill = fill_flow(warp = 6, seed = 9350L)))
#'
#' # two or more colours blend across the field, as in fill_noise()
#' draw(shape_circle(
#'   fill = fill_flow(color = c("steelblue", "white", "tomato"), seed = 9350L)
#' ))
#'
#' @family fill helpers
#' @export
fill_flow <- function(color = "black",
                      spacing = 0.5,
                      aspect = NULL,
                      resolution = 32L,
                      alpha = 1,
                      warp = 2,
                      warp_frequency = 1,
                      warp_octaves = 1L,
                      frequency = 1,
                      octaves = 2L,
                      seed = 1L,
                      extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  validate_colors(color, "color")
  if (!is.numeric(resolution) || length(resolution) != 1 ||
    resolution < 2 || resolution != round(resolution)) {
    rlang::abort("resolution must be a single integer of at least 2")
  }
  if (!is.numeric(alpha) || length(alpha) != 1 || alpha <= 0 || alpha > 1) {
    rlang::abort("alpha must be a single number in (0, 1]")
  }
  if (!is.numeric(warp) || length(warp) != 1 || warp < 0) {
    rlang::abort("warp must be a single non-negative number")
  }
  if (!is.numeric(warp_frequency) || length(warp_frequency) != 1 || warp_frequency < 0) {
    rlang::abort("warp_frequency must be a single non-negative number")
  }
  if (!is.numeric(warp_octaves) || length(warp_octaves) != 1 ||
    warp_octaves < 1 || warp_octaves != round(warp_octaves)) {
    rlang::abort("warp_octaves must be a single positive integer")
  }
  if (!is.numeric(frequency) || length(frequency) != 1 || frequency < 0) {
    rlang::abort("frequency must be a single non-negative number")
  }
  if (!is.numeric(octaves) || length(octaves) != 1 ||
    octaves < 1 || octaves != round(octaves)) {
    rlang::abort("octaves must be a single positive integer")
  }
  if (!is.numeric(seed) || length(seed) != 1 || seed != round(seed)) {
    rlang::abort("seed must be a single integer")
  }

  resolution <- as.integer(resolution)
  grid_uv <- torus_grid(resolution)
  seed <- as.integer(seed)

  # decorrelate the two displacement fields (and the final field) by seed,
  # since gen_simplex()'s 4 dimensions are already fully spent on the
  # (theta_u, theta_v) torus trick -- see details
  warp_u <- torus_noise(grid_uv$theta_u, grid_uv$theta_v, warp_frequency, warp_octaves, seed + 104729L) |>
    ambient::normalize(to = c(-1, 1)) * warp
  warp_v <- torus_noise(grid_uv$theta_u, grid_uv$theta_v, warp_frequency, warp_octaves, seed + 200003L) |>
    ambient::normalize(to = c(-1, 1)) * warp

  value01 <- torus_noise(grid_uv$theta_u + warp_u, grid_uv$theta_v + warp_v, frequency, octaves, seed) |>
    ambient::normalize(to = c(0, 1))

  pixels <- matrix(
    noise_to_pixels(value01, color, alpha),
    nrow = resolution, ncol = resolution
  )
  raster <- grid::rasterGrob(
    pixels,
    width = 1, height = 1,
    default.units = "npc", interpolate = TRUE
  )

  grid::pattern(raster, width = spacing, height = spacing * aspect, extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Charcoal/marker-style noise texture fill
#'
#' `fill_charcoal()` is a [fill_noise()] preset -- same field, same
#' rendering, just different defaults -- tuned to read as hand-drawn
#' charcoal or marker grain rather than [fill_noise()]'s more
#' general-purpose rasterized field: a lighter base tone, finer/denser
#' tiling, and finer noise detail.
#'
#' Found, while prototyping [shape_stroke()]'s interior texture, to be a
#' substantially better fit than [fill_scribble()] for a curved stroke's
#' body -- `fill_scribble()`'s fixed horizontal/vertical direction doesn't
#' track a curved path's own tangent (see the "Deferred: arbitrary angle
#' for `fill_scribble()`" item in `.agents/PLAN.md`), producing hatching
#' that visibly cuts across the stroke at odd angles wherever the path
#' bends, while [fill_noise()]'s directionless mottling has no orientation
#' to clash with the curve.
#'
#' @inheritParams fill_noise
#' @param color One or more fill colours, as in [fill_noise()]. Default
#'   `"gray15"` (lighter than [fill_noise()]'s own `"black"` default, closer
#'   to a charcoal tone).
#' @param spacing Baseline tile size, as a fraction of the target's
#'   bounding box. Must be a positive number. Default `0.25` (finer than
#'   [fill_noise()]'s own `0.5` default, for denser grain).
#' @param frequency Noise frequency, as in [shape_blob()]. Must be
#'   non-negative. Default `4` (finer detail than [fill_noise()]'s own
#'   default of `1`).
#' @param octaves Number of noise octaves, as in [shape_blob()]. Must be a
#'   positive integer. Default `3L` (one more layer of detail than
#'   [fill_noise()]'s own default of `2L`).
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_stroke(
#'   x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.4,
#'   fill = fill_charcoal(), color = NA_character_
#' ))
#'
#' # a lighter tone and a curved backbone -- fill_charcoal()'s directionless
#' # mottling tracks a bend that fill_scribble()'s fixed direction wouldn't
#' t <- seq(0, 2 * pi, length.out = 200)
#' draw(shape_stroke(
#'   x = t, y = sin(t), width = 0.3,
#'   fill = fill_charcoal(color = "gray40"), color = NA_character_
#' ))
#'
#' @family fill helpers
#' @export
fill_charcoal <- function(color = "gray15",
                          spacing = 0.25,
                          aspect = NULL,
                          resolution = 32L,
                          alpha = 1,
                          frequency = 4,
                          octaves = 3L,
                          seed = 1L,
                          extend = "repeat") {
  fill_noise(
    color = color, spacing = spacing, aspect = aspect, resolution = resolution,
    alpha = alpha, frequency = frequency, octaves = octaves, seed = seed,
    extend = extend
  )
}

#' User-supplied raster image fill
#'
#' `fill_image()` builds a [grid::pattern()] fill value whose tile content is
#' an arbitrary bitmap, rather than a texture generated by this package. It
#' plugs any raster the caller already has in memory into the same
#' `grid::pattern()` machinery [fill_noise()] uses for its own generated
#' raster -- but with the raster supplied, not computed.
#'
#' `fill_image()` doesn't read image files itself, to avoid adding an image
#' I/O dependency (`png`/`jpeg`/`magick`, ...) to a package that otherwise
#' has none. Load the file first with whichever of those packages is
#' already on hand, then pass the result (or [grDevices::as.raster()] of
#' it) as `image` -- e.g. `fill_image(png::readPNG("logo.png"))` or
#' `fill_image(magick::image_read("logo.png"))`. Anything
#' [grDevices::as.raster()] accepts works: a `"raster"` object, a character
#' matrix of colour strings, or a numeric array of `0`-`1` RGB/RGBA
#' intensities.
#'
#' Unlike the other `fill_*()` helpers, `fill_image()`'s content has its
#' *own* pixel aspect ratio to account for, on top of the usual
#' target-bounding-box correction every helper needs (`aspect`, defaulting
#' to automatic resolution exactly as every other helper -- see
#' [fill_hatch()]'s own `aspect` docs -- and corrected for exactly as
#' [fill_noise()] does -- keeping the tile physically square). With
#' `preserve_aspect = TRUE` (the default), the image is
#' letterboxed to fit that square tile without distorting it: whichever of
#' width/height is smaller in the image's own pixel dimensions is shrunk
#' to fit, leaving the tile's remaining margin transparent. Set
#' `preserve_aspect = FALSE` to stretch the image to fill the tile exactly
#' instead, matching [fill_noise()]'s own (always-stretched) behaviour.
#'
#' @param image A raster image: a `"raster"` object, or a matrix/array
#'   accepted by [grDevices::as.raster()]. Not a file path -- read the file
#'   first with e.g. `png::readPNG()`, `jpeg::readJPEG()`, or
#'   `magick::image_read()`.
#' @param preserve_aspect Whether to letterbox the image to preserve its own
#'   pixel aspect ratio (`TRUE`), or stretch it to exactly fill each tile
#'   (`FALSE`). Default `TRUE`.
#' @param interpolate Passed to [grid::rasterGrob()]. Default `TRUE`.
#' @param spacing Tile size, as a fraction of the target's bounding box.
#'   Must be a positive number. Default `1` (one tile spans the whole
#'   shape).
#' @inheritParams fill_noise
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' img <- matrix(c("red", "white", "white", "blue"), nrow = 2)
#' draw(shape_circle(fill = fill_image(img, preserve_aspect = FALSE)))
#'
#' # a non-square image, letterboxed (default) vs. stretched to fill the tile
#' wide_img <- matrix(c("red", "white", "blue"), nrow = 1)
#' draw(shape_rectangle(width = 2, height = 1, fill = fill_image(wide_img)))
#' draw(shape_rectangle(
#'   width = 2,
#'   height = 1,
#'   fill = fill_image(wide_img, preserve_aspect = FALSE)
#' ))
#'
#' @family fill helpers
#' @export
fill_image <- function(image,
                       preserve_aspect = TRUE,
                       spacing = 1,
                       aspect = NULL,
                       interpolate = TRUE,
                       extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  if (!is.matrix(image) && !is.array(image) && !inherits(image, "raster")) {
    rlang::abort(
      "image must be a raster object, or a matrix/array accepted by grDevices::as.raster()"
    )
  }
  if (!is.logical(preserve_aspect) || length(preserve_aspect) != 1 || is.na(preserve_aspect)) {
    rlang::abort("preserve_aspect must be a single TRUE/FALSE value")
  }
  if (!is.logical(interpolate) || length(interpolate) != 1 || is.na(interpolate)) {
    rlang::abort("interpolate must be a single TRUE/FALSE value")
  }

  img_raster <- tryCatch(
    grDevices::as.raster(image),
    error = function(e) {
      rlang::abort(paste0(
        "image could not be converted with grDevices::as.raster(): ",
        conditionMessage(e)
      ))
    }
  )
  img_dim <- dim(img_raster)
  if (is.null(img_dim) || length(img_dim) != 2 || any(img_dim < 1)) {
    rlang::abort("image must have at least one row and one column")
  }

  if (preserve_aspect) {
    # img_dim is (nrow, ncol) = (height, width) in pixels; letterbox the
    # narrower dimension within the tile's unit square, rather than
    # stretching to fill it, exactly as fill_noise() does
    img_aspect <- img_dim[2] / img_dim[1]
    if (img_aspect >= 1) {
      w <- 1
      h <- 1 / img_aspect
    } else {
      w <- img_aspect
      h <- 1
    }
  } else {
    w <- 1
    h <- 1
  }

  content <- grid::rasterGrob(
    img_raster,
    x = 0.5, y = 0.5, width = w, height = h,
    default.units = "npc", interpolate = interpolate
  )

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Gradient fill
#'
#' `fill_gradient()` builds a [grid::pattern()] fill value whose tile content
#' is a single rectangle filled with a [grid::linearGradient()] or
#' [grid::radialGradient()], depending on `type`.
#'
#' Like the other `fill_*()` helpers, this needs the target's bounding-box
#' aspect ratio (`aspect`, resolved automatically by default -- see
#' [fill_hatch()]'s own `aspect` docs) to render true rather than
#' stretched -- but the correction is applied differently here. Rather
#' than adjusting the
#' gradient's own coordinates (the way [fill_hatch()] adjusts a segment's
#' direction), `fill_gradient()` corrects the *tile* itself to be physically
#' square, exactly as [fill_stipple()] does for its dots: once the tile is
#' square, a gradient specified inside it in plain `"npc"` needs no further
#' correction to render at the requested `angle`, or as a true circle for
#' `type = "radial"`.
#'
#' This also means a gradient tile has none of [fill_hatch()]'s periodicity
#' concerns: adjacent tiles are simply identical copies of the same square
#' gradient, with nothing analogous to a hatch line's tile-edge dashing to
#' avoid.
#'
#' With the default `spacing = 1`, one tile spans (and, for a non-square
#' bounding box, slightly overshoots) the target's entire bounding box,
#' giving a single smooth gradient across the whole shape -- the overshoot
#' is invisibly clipped away by the target's own outline. Set `spacing < 1`
#' for a repeating pattern of small gradient motifs instead.
#'
#' @param color Two or more colours to interpolate between.
#' @param type Either `"linear"` or `"radial"`. Default `"linear"`.
#' @param angle Gradient direction in degrees, for `type = "linear"` only
#'   (ignored for `"radial"`). Default `45`.
#' @param stops Colour stop positions, as a numeric vector the same length
#'   as `color`, or `NULL` to space them evenly (the default used by
#'   [grid::linearGradient()]/[grid::radialGradient()]). Default `NULL`.
#' @param spacing Tile size, as a fraction of the target's bounding box.
#'   Must be a positive number. Default `1` (one tile spans the whole
#'   shape).
#' @param aspect Width-to-height ratio of the target polygon's bounding box.
#'   Must be a positive number, or `NULL` (the default) to resolve it
#'   automatically at [draw()] time -- see [fill_hatch()]'s own `aspect`
#'   docs.
#' @param extend Passed to the inner [grid::linearGradient()]/
#'   [grid::radialGradient()], controlling what happens beyond the colour
#'   stops. Default `"pad"`.
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_gradient(c("white", "steelblue"))))
#' draw(shape_circle(fill = fill_gradient(c("yellow", "red"), type = "radial")))
#'
#' # three or more colours interpolate in sequence; angle rotates a linear
#' # gradient's direction
#' draw(shape_circle(
#'   fill = fill_gradient(c("yellow", "orange", "red"), angle = 90)
#' ))
#'
#' # spacing < 1 repeats the gradient as a small tiled motif instead of one
#' # smooth sweep across the whole shape
#' draw(shape_circle(
#'   fill = fill_gradient(c("white", "steelblue"), spacing = 0.3)
#' ))
#'
#' @family fill helpers
#' @export
fill_gradient <- function(color = c("white", "black"),
                          type = c("linear", "radial"),
                          angle = 45,
                          stops = NULL,
                          spacing = 1,
                          aspect = NULL,
                          extend = "pad") {
  type <- match.arg(type)
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  if (!is.character(color) || length(color) < 2) {
    rlang::abort("color must be a character vector of at least length 2")
  }
  if (!is.null(stops) && (!is.numeric(stops) || length(stops) != length(color))) {
    rlang::abort("stops must be NULL, or a numeric vector the same length as color")
  }
  if (!is.numeric(angle) || length(angle) != 1) {
    rlang::abort("angle must be a single number")
  }

  gradient_args <- list(colours = color, extend = extend)
  if (!is.null(stops)) {
    gradient_args$stops <- stops
  }

  if (type == "linear") {
    theta <- angle * pi / 180
    gradient <- do.call(grid::linearGradient, c(
      gradient_args,
      list(
        x1 = 0.5 - 0.5 * cos(theta), y1 = 0.5 - 0.5 * sin(theta),
        x2 = 0.5 + 0.5 * cos(theta), y2 = 0.5 + 0.5 * sin(theta)
      )
    ))
  } else {
    gradient <- do.call(grid::radialGradient, c(
      gradient_args,
      list(cx1 = 0.5, cy1 = 0.5, r1 = 0, cx2 = 0.5, cy2 = 0.5, r2 = 0.5)
    ))
  }

  content <- grid::rectGrob(
    x = 0.5, y = 0.5, width = 1, height = 1,
    default.units = "npc",
    gp = grid::gpar(fill = gradient, col = NA)
  )

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = "repeat")
  }
  resolvable_fill(build, aspect)
}

#' Vignette fill
#'
#' `fill_vignette()` builds a [grid::pattern()] fill value that fades
#' colour out towards the edges of each tile, using [grid::as.mask()] --
#' the one `grid` capability the rest of the `fill_*()` family doesn't
#' touch. A `color` layer (solid for a single colour, or a
#' `grid::radialGradient()` blend for two or more) is masked by a radial
#' alpha mask (opaque at the tile centre, fully transparent at its edge),
#' optionally revealing a solid `background` layer underneath rather than
#' true transparency.
#'
#' As with [fill_gradient()], the fade shape is kept circular by correcting
#' the *tile* to be physically square via `aspect` (the target's
#' bounding-box width-to-height ratio, resolved automatically by default
#' -- see [fill_hatch()]'s own `aspect` docs), the same technique
#' [fill_stipple()] uses for its dots -- once the tile is square, a mask
#' specified inside it in plain `"npc"` needs no further correction.
#'
#' A mask must always be built with [grid::as.mask()] and an explicit
#' `type = "alpha"` here, rather than passed as a bare grob (which defaults
#' to an alpha mask anyway) -- during prototyping, a bare mask grob whose
#' own fill was a [grid::radialGradient()] intermittently triggered an
#' "Ignored luminance mask (not supported on this device)" warning on this
#' session's device, even though the rendered result was visually correct
#' either way. Being explicit with `as.mask(..., type = "alpha")` avoided
#' the warning entirely with an identical render, so that's what's used
#' here; true [grid::as.mask()] luminance masks were found not to work at
#' all in this nested tile context (silently ignored, regardless of
#' explicitness), so `fill_vignette()` only offers the alpha variant.
#'
#' @param color One or more fill colours, blended from the tile's centre
#'   outward. A single colour (the default) is a solid fade, exactly as
#'   before this argument accepted a vector; two or more blend via a
#'   `grid::radialGradient()` before the same alpha mask is applied. Default
#'   `"black"`.
#' @param background Fill colour revealed as `color` fades out, or `NA` for
#'   true transparency (showing whatever is drawn behind the target shape).
#'   Default `NA`.
#' @param spacing Tile size, as a fraction of the target's bounding box.
#'   Must be a positive number. Default `1` (one tile spans the whole
#'   shape).
#' @param aspect Width-to-height ratio of the target polygon's bounding box.
#'   Must be a positive number, or `NULL` (the default) to resolve it
#'   automatically at [draw()] time -- see [fill_hatch()]'s own `aspect`
#'   docs.
#' @param extend Passed to [grid::pattern()]. Default `"repeat"`.
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_vignette(color = "black")))
#'
#' # a non-NA background reveals a solid colour underneath the fade,
#' # instead of true transparency
#' draw(shape_circle(
#'   fill = fill_vignette(color = "steelblue", background = "white")
#' ))
#'
#' # two or more colours blend radially before fading via the alpha mask
#' draw(shape_circle(fill = fill_vignette(color = c("goldenrod", "steelblue"))))
#'
#' @family fill helpers
#' @export
fill_vignette <- function(color = "black",
                          background = NA,
                          spacing = 1,
                          aspect = NULL,
                          extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(NULL, spacing, aspect)
  validate_colors(color, "color")
  if (length(background) != 1 || !(is.na(background) || is.character(background))) {
    rlang::abort("background must be a single string, or NA")
  }

  # the mask only ever extracts alpha, not hue, so color[1] alone is enough
  # to build it regardless of how many colours color itself holds
  mask_grob <- grid::circleGrob(
    x = 0.5, y = 0.5, r = 0.5,
    gp = grid::gpar(fill = grid::radialGradient(colours = c(color[1], "transparent")), col = NA)
  )
  fg_fill <- if (length(color) == 1) {
    color
  } else {
    grid::radialGradient(
      colours = color,
      cx1 = 0.5, cy1 = 0.5, r1 = 0, cx2 = 0.5, cy2 = 0.5, r2 = 0.5
    )
  }
  fg <- grid::gTree(
    children = grid::gList(
      grid::rectGrob(
        x = 0.5, y = 0.5, width = 1, height = 1,
        default.units = "npc",
        gp = grid::gpar(fill = fg_fill, col = NA)
      )
    ),
    vp = grid::viewport(mask = grid::as.mask(mask_grob, type = "alpha"))
  )

  content <- if (is.na(background)) {
    fg
  } else {
    bg <- grid::rectGrob(
      x = 0.5, y = 0.5, width = 1, height = 1,
      default.units = "npc",
      gp = grid::gpar(fill = background, col = NA)
    )
    grid::gTree(children = grid::gList(bg, fg))
  }

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = extend)
  }
  resolvable_fill(build, aspect)
}

#' Striped pattern fill
#'
#' `fill_stripe()` builds a [grid::pattern()] fill value that renders
#' repeating solid bands, at a given `angle`, generalized from two colours
#' to an arbitrary palette.
#'
#' Unlike [fill_hatch()], this doesn't use the corner-to-corner-diagonal
#' tile-shape technique at all -- because a *filled* band, unlike a thin
#' hatch *line*, needs every point along a tile's edge to match its
#' neighbour, not just the points where a thin line happens to cross, a
#' single diagonal split of a tile turns out not to tile seamlessly at an
#' arbitrary angle the way a thin hatch line does. Instead, `fill_stripe()`
#' sidesteps [grid::pattern()]'s tile-copy repetition altogether: the
#' stripe angle and period come from a [grid::linearGradient()] with hard
#' colour stops (no smooth transition) and `extend = "repeat"`, which
#' repeats *itself* continuously along its own axis -- a fundamentally
#' different (and for this purpose, simpler) mechanism than tiling a
#' rasterised copy. [grid::pattern()] is still used around this gradient,
#' but only once, as a single square (automatically aspect-corrected --
#' see [fill_hatch()]'s own `aspect` docs) tile spanning the whole target
#' shape, exactly as [fill_gradient()] does by default -- not to create
#' repetition, which the gradient already provides.
#'
#' Each of the `n = length(color)` colours gets an equal-width band by
#' default (`1/n` of the period); there's no separate argument for unequal
#' bands -- repeat a colour in `color` instead (e.g. `c("steelblue",
#' "steelblue", "white")` gives a 2:1 ratio between the two colours), which
#' reuses the same recycling mechanism rather than adding a second one.
#'
#' @param color Two or more stripe colours, one equal-width band each (see
#'   details for biasing band widths). Default `c("black", "white")`.
#' @param spacing One full period through all of `color`, as a fraction of
#'   the target's bounding box. Must be a positive number. Default `0.2`.
#' @param extend Passed to the inner [grid::linearGradient()], controlling
#'   what happens beyond the colour stops -- *not* to the outer
#'   [grid::pattern()] call, which always uses `extend = "repeat"` (see
#'   details). Default `"repeat"`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @examples
#' draw(shape_circle(fill = fill_stripe(angle = 30)))
#'
#' # repeating a colour biases the band widths, rather than a separate argument
#' draw(shape_circle(
#'   fill = fill_stripe(color = c("steelblue", "steelblue", "white"))
#' ))
#'
#' # narrower spacing gives more, thinner stripes
#' draw(shape_circle(fill = fill_stripe(angle = 90, spacing = 0.08)))
#'
#' # three or more colours repeat through the same period
#' draw(shape_circle(
#'   fill = fill_stripe(color = c("steelblue", "white", "tomato"), angle = 30)
#' ))
#'
#' @family fill helpers
#' @export
fill_stripe <- function(color = c("black", "white"),
                        angle = 45,
                        spacing = 0.2,
                        aspect = NULL,
                        extend = "repeat") {
  build <- function(aspect) {
  validate_fill_args(angle, spacing, aspect)
  validate_colors(color, "color", min_length = 2)

  n <- length(color)
  bounds <- seq(0, 1, length.out = n + 1)
  band_colors <- rep(color, each = 2)
  stops <- as.vector(rbind(bounds[-(n + 1)], bounds[-1]))

  theta <- angle * pi / 180
  half <- spacing / 2
  gradient <- grid::linearGradient(
    colours = band_colors,
    stops = stops,
    x1 = 0.5 - half * cos(theta), y1 = 0.5 - half * sin(theta),
    x2 = 0.5 + half * cos(theta), y2 = 0.5 + half * sin(theta),
    extend = extend
  )

  content <- grid::rectGrob(
    x = 0.5, y = 0.5, width = 1, height = 1,
    default.units = "npc",
    gp = grid::gpar(fill = gradient, col = NA)
  )

  grid::pattern(content, width = 1, height = aspect, extend = "repeat")
  }
  resolvable_fill(build, aspect)
}

#' Bounding-box aspect ratio of a drawable
#'
#' Internal helper. Computes the width-to-height ratio of a [drawable]
#' object's own points, for use as the `aspect` argument to fill helpers
#' like [fill_hatch()] and [fill_crosshatch()] -- and, since every such
#' helper now resolves its own `aspect` automatically at [draw()] time
#' (see the [fill] class), the value [draw()] itself passes to
#' `resolve_fill()`.
#'
#' @param object A [drawable] object.
#'
#' @return A single positive number.
#' @noRd
bbox_aspect <- function(object) {
  diff(range(object@points@x)) / diff(range(object@points@y))
}

#' Bounding-box aspect ratio of an explicit coordinate range
#'
#' Internal helper, `bbox_aspect()`'s counterpart for [draw()]'s `sketch`
#' method: a sketch's own `canvas@background` has no single target
#' drawable to measure, so its aspect is computed from the shared
#' viewport's own `xlim`/`ylim` instead.
#'
#' @param xlim,ylim Each a numeric vector of length 2.
#'
#' @return A single positive number.
#' @noRd
bbox_aspect_range <- function(xlim, ylim) {
  diff(xlim) / diff(ylim)
}
