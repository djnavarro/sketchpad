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
#' @return `color`, unchanged (a single string), after validating it.
#'
#' @family fill helpers
#' @export
fill_solid <- function(color = "black") {
  if (!is.character(color) || length(color) != 1) {
    rlang::abort("color must be a single string")
  }
  color
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
#' distorts any angle baked directly into the pattern content. Pass the
#' target's bounding-box aspect ratio (width / height) as `aspect` to
#' correct for this; the default `aspect = 1` is only exact for a square
#' bounding box.
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
#' @param angle Hatch angle in degrees, measured counterclockwise from the
#'   positive x-axis. Default `45`.
#' @param spacing Baseline tile size, as a fraction of the target's bounding
#'   box. Must be a positive number. Default `0.1`.
#' @param aspect Width-to-height ratio of the target polygon's bounding box.
#'   Must be a positive number. Default `1` (a square bounding box).
#' @param color Line colour. Default `"black"`.
#' @param linewidth Line width. Default `1`.
#' @param extend Passed to [grid::pattern()]. Default `"repeat"`.
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @family fill helpers
#' @export
fill_hatch <- function(angle = 45,
                        spacing = 0.1,
                        aspect = 1,
                        color = "black",
                        linewidth = 1,
                        extend = "repeat") {
  validate_fill_args(angle, spacing, aspect)

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

#' Crosshatch pattern fill
#'
#' `fill_crosshatch()` builds a [grid::pattern()] fill value that renders two
#' mirror-symmetric hatch lines, at `angle` and `-angle`, forming an "X"
#' inside each tile. It shares [fill_hatch()]'s tile-shape technique: both
#' lines are drawn as the two corner-to-corner diagonals of a single
#' rectangular tile (rather than at an arbitrary baked-in slope), so both
#' tile seamlessly under `extend = "repeat"`, and the tile's `width`/`height`
#' ratio -- not the diagonals' own coordinates -- determines the rendered
#' angle. See [fill_hatch()]'s details for why this matters.
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
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @family fill helpers
#' @export
fill_crosshatch <- function(angle = 45,
                             spacing = 0.1,
                             aspect = 1,
                             color = "black",
                             linewidth = 1,
                             extend = "repeat") {
  validate_fill_args(angle, spacing, aspect)

  # a multiple of 90 degrees: the mirrored diagonals would coincide, so draw
  # a horizontal + vertical grid instead
  if (isTRUE(all.equal(angle %% 90, 0))) {
    content <- grid::grobTree(
      grid::gList(
        grid::segmentsGrob(
          x0 = 0, y0 = 0.5, x1 = 1, y1 = 0.5,
          default.units = "npc",
          gp = grid::gpar(col = color, lwd = linewidth)
        ),
        grid::segmentsGrob(
          x0 = 0.5, y0 = 0, x1 = 0.5, y1 = 1,
          default.units = "npc",
          gp = grid::gpar(col = color, lwd = linewidth)
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
        gp = grid::gpar(col = color, lwd = linewidth)
      ),
      grid::segmentsGrob(
        x0 = 0, y0 = 1, x1 = 1, y1 = 0,
        default.units = "npc",
        gp = grid::gpar(col = color, lwd = linewidth)
      )
    )
  )

  grid::pattern(content, width = dims["width"], height = dims["height"], extend = extend)
}

#' Checkerboard pattern fill
#'
#' `fill_checker()` builds a [grid::pattern()] fill value that renders a
#' two-colour checkerboard. It's the cheapest member of the hatch family to
#' build: a checkerboard square has no direction the way a hatch line does
#' (compare [fill_hatch()]'s corner-to-corner diagonal, needed specifically
#' to tile a *sloped* line seamlessly), so the tile content here is just
#' four plain quadrant rectangles -- the same two-colour-grid special case
#' [fill_crosshatch()] already falls back to when `angle` is a multiple of
#' 90 degrees, pulled out into its own helper.
#'
#' As with the other `fill_*()` helpers, [grid::pattern()] tiles are sized
#' as a fraction of the target polygon's own bounding box rather than a
#' fixed physical square, so the checker squares would render as
#' rectangles, not squares, on a non-square bounding box. Pass the target's
#' width-to-height ratio as `aspect` to correct for this -- the same tile-
#' squaring technique [fill_stipple()] uses for its dots -- so the default
#' `aspect = 1` is only exact for a square bounding box.
#'
#' @param color1,color2 The two checker colours. Defaults `"black"` and
#'   `"white"`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @family fill helpers
#' @export
fill_checker <- function(color1 = "black",
                          color2 = "white",
                          spacing = 0.2,
                          aspect = 1,
                          extend = "repeat") {
  validate_fill_args(NULL, spacing, aspect)
  if (!is.character(color1) || length(color1) != 1) {
    rlang::abort("color1 must be a single string")
  }
  if (!is.character(color2) || length(color2) != 1) {
    rlang::abort("color2 must be a single string")
  }

  quadrant <- function(x, y, color) {
    grid::rectGrob(
      x = x, y = y, width = 0.5, height = 0.5,
      default.units = "npc",
      gp = grid::gpar(fill = color, col = NA)
    )
  }
  content <- grid::grobTree(
    grid::gList(
      quadrant(0.25, 0.75, color1), quadrant(0.75, 0.75, color2),
      quadrant(0.25, 0.25, color2), quadrant(0.75, 0.25, color1)
    )
  )

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = extend)
}

#' Stippled dot pattern fill
#'
#' `fill_stipple()` builds a [grid::pattern()] fill value that scatters a
#' handful of dots at random positions inside each tile, using
#' [withr::with_seed()] so the same `seed` always reproduces the same
#' scatter (the same convention used by [blob()], [ribbon()], and
#' [twist()]'s noise fields).
#'
#' Unlike [fill_hatch()]/[fill_crosshatch()], a dot has no direction, so
#' there's no analogue of their tile-edge "dashing" problem here. There's
#' still a circularity problem to correct for, though: [grid::pattern()]
#' tiles are sized as a fraction of the target polygon's own bounding box,
#' so a dot drawn with an `npc`-relative radius renders as an ellipse
#' whenever that bounding box isn't square. Pass the bounding box's
#' width-to-height ratio as `aspect` to keep dots circular; the default
#' `aspect = 1` is only exact for a square bounding box.
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
#' @param radius Dot radius, as a `"npc"` fraction of the tile. Must be a
#'   positive number. Default `0.15`.
#' @param n Number of dots scattered per tile. Must be a positive integer.
#'   Default `4L`.
#' @param seed Integer seed for the dot positions. Default `1L`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @family fill helpers
#' @export
fill_stipple <- function(radius = 0.15,
                          spacing = 0.3,
                          aspect = 1,
                          n = 4L,
                          seed = 1L,
                          color = "black",
                          extend = "repeat") {
  validate_fill_args(NULL, spacing, aspect)
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

  dots <- purrr::map2(x, y, function(cx, cy) {
    grid::circleGrob(
      x = cx, y = cy, r = radius,
      default.units = "npc",
      gp = grid::gpar(col = NA, fill = color)
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
#'   `circle(radius = 1)`.
#' @param n Number of copies scattered per tile. Must be a positive
#'   integer. Default `6L`.
#' @param size `unit`'s rescaled size, as a `"npc"` fraction of the tile.
#'   Must be a number strictly between `0` and `1`. Default `0.2`.
#' @param seed Integer seed for the scatter positions. Default `1L`.
#' @param spacing Tile size, as a fraction of the target's bounding box.
#'   Must be a positive number. Default `1` (one tile spans the whole
#'   shape, since `spacing < 1` risks the tiling distortion described
#'   above).
#' @param aspect Width-to-height ratio of the target polygon's bounding
#'   box. Must be a positive number. Default `1` (a square bounding box).
#' @param extend Passed to [grid::pattern()]. Default `"repeat"`.
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @family fill helpers
#' @export
fill_scatter <- function(unit = circle(radius = 1),
                          n = 6L,
                          size = 0.2,
                          spacing = 1,
                          aspect = 1,
                          seed = 1L,
                          extend = "repeat") {
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

  stamps <- purrr::map2(cx, cy, function(ccx, ccy) {
    grid::polygonGrob(
      x = norm_x + ccx, y = norm_y + ccy,
      default.units = "npc",
      gp = grid::gpar(
        col = unit@style@color,
        fill = unit@style@fill,
        lwd = unit@style@linewidth
      )
    )
  })
  content <- grid::grobTree(do.call(grid::gList, stamps))

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = extend)
}

#' Halftone dot pattern fill
#'
#' `fill_halftone()` is [fill_stipple()]'s other variant: instead of
#' scattering dots of one fixed size, each dot's radius is drawn
#' uniformly at random from `radius`, giving a mottled halftone-print
#' look rather than a uniform stipple. Like [fill_stipple()] (and unlike
#' [fill_scatter()]), it scatters plain [grid::circleGrob()]s, so it's
#' immune to the *polygon*-specific rendering problems documented at
#' [fill_scatter()] -- but it shares [fill_stipple()]'s own, separate
#' "Known rendering risk with multiple dots" (repeated tiles containing
#' several `circleGrob`s were, in testing, sometimes visibly distorted on
#' this package's development R build; see that section for details).
#' There is no known way to avoid this while still getting a genuine
#' scattered-dot texture, so **check rendered output visually** here too.
#'
#' As with [fill_stipple()], the target's bounding-box aspect ratio needs
#' to be passed as `aspect` to keep the dots circular rather than
#' elliptical; the default `aspect = 1` is only exact for a square
#' bounding box. Dot centres are kept at least `max(radius)` from each
#' tile edge, so even the largest possible dot isn't clipped away near a
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
#' @family fill helpers
#' @export
fill_halftone <- function(radius = c(0.05, 0.2),
                           spacing = 0.3,
                           aspect = 1,
                           n = 4L,
                           seed = 1L,
                           color = "black",
                           extend = "repeat") {
  validate_fill_args(NULL, spacing, aspect)
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

  dots <- purrr::pmap(list(x, y, r), function(cx, cy, cr) {
    grid::circleGrob(
      x = cx, y = cy, r = cr,
      default.units = "npc",
      gp = grid::gpar(col = NA, fill = color)
    )
  })
  content <- grid::grobTree(do.call(grid::gList, dots))

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = extend)
}

#' Simplex/fractal noise texture fill
#'
#' `fill_noise()` builds a [grid::pattern()] fill value from a rasterised
#' simplex/fractal noise field, using the same noise machinery as
#' [blob()]'s wobbly outline (`ambient::fracture()` /
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
#' @param color Fill colour. Default `"black"`.
#' @param resolution Raster resolution (pixels per tile edge). Must be a
#'   positive integer of at least `2L`. Default `32L`.
#' @param alpha Maximum opacity, at the noise field's peak. Must be a number
#'   in `(0, 1]`. Default `1`.
#' @param frequency Noise frequency, as in [blob()]. Must be non-negative.
#'   Default `1`.
#' @param octaves Number of noise octaves, as in [blob()]. Must be a
#'   positive integer. Default `2L`.
#' @param seed Integer seed for the noise field, as in [blob()]. Default
#'   `1L`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @family fill helpers
#' @export
fill_noise <- function(color = "black",
                        spacing = 0.5,
                        aspect = 1,
                        resolution = 32L,
                        alpha = 1,
                        frequency = 1,
                        octaves = 2L,
                        seed = 1L,
                        extend = "repeat") {
  validate_fill_args(NULL, spacing, aspect)
  if (!is.character(color) || length(color) != 1) {
    rlang::abort("color must be a single string")
  }
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
  u <- (seq_len(resolution) - 0.5) / resolution
  v <- (seq_len(resolution) - 0.5) / resolution
  uv <- expand.grid(v = v, u = u)

  # sample on a torus (two circles, one per tile axis) rather than directly
  # in (u, v), so the field is exactly periodic and tiles with no seam
  theta_u <- 2 * pi * uv$u
  theta_v <- 2 * pi * uv$v

  noise <- ambient::fracture(
    noise = ambient::gen_simplex,
    fractal = ambient::fbm,
    x = cos(theta_u) * frequency,
    y = sin(theta_u) * frequency,
    z = cos(theta_v) * frequency,
    t = sin(theta_v) * frequency,
    seed = as.integer(seed),
    octaves = as.integer(octaves)
  ) |>
    ambient::normalize(to = c(0, alpha))

  rgb <- grDevices::col2rgb(color) / 255
  pixels <- matrix(
    grDevices::rgb(rgb["red", ], rgb["green", ], rgb["blue", ], alpha = noise),
    nrow = resolution, ncol = resolution
  )
  raster <- grid::rasterGrob(
    pixels, width = 1, height = 1,
    default.units = "npc", interpolate = TRUE
  )

  grid::pattern(raster, width = spacing, height = spacing * aspect, extend = extend)
}

#' Gradient fill
#'
#' `fill_gradient()` builds a [grid::pattern()] fill value whose tile content
#' is a single rectangle filled with a [grid::linearGradient()] or
#' [grid::radialGradient()], depending on `type`.
#'
#' Like the other `fill_*()` helpers, this needs the target's bounding-box
#' aspect ratio (`aspect`) to render true rather than stretched -- but the
#' correction is applied differently here. Rather than adjusting the
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
#' @param colors Two or more colours to interpolate between.
#' @param type Either `"linear"` or `"radial"`. Default `"linear"`.
#' @param angle Gradient direction in degrees, for `type = "linear"` only
#'   (ignored for `"radial"`). Default `45`.
#' @param stops Colour stop positions, as a numeric vector the same length
#'   as `colors`, or `NULL` to space them evenly (the default used by
#'   [grid::linearGradient()]/[grid::radialGradient()]). Default `NULL`.
#' @param spacing Tile size, as a fraction of the target's bounding box.
#'   Must be a positive number. Default `1` (one tile spans the whole
#'   shape).
#' @param aspect Width-to-height ratio of the target polygon's bounding box.
#'   Must be a positive number. Default `1` (a square bounding box).
#' @param extend Passed to the inner [grid::linearGradient()]/
#'   [grid::radialGradient()], controlling what happens beyond the colour
#'   stops. Default `"pad"`.
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @family fill helpers
#' @export
fill_gradient <- function(colors = c("white", "black"),
                           type = c("linear", "radial"),
                           angle = 45,
                           stops = NULL,
                           spacing = 1,
                           aspect = 1,
                           extend = "pad") {
  type <- match.arg(type)
  validate_fill_args(NULL, spacing, aspect)
  if (!is.character(colors) || length(colors) < 2) {
    rlang::abort("colors must be a character vector of at least length 2")
  }
  if (!is.null(stops) && (!is.numeric(stops) || length(stops) != length(colors))) {
    rlang::abort("stops must be NULL, or a numeric vector the same length as colors")
  }
  if (!is.numeric(angle) || length(angle) != 1) {
    rlang::abort("angle must be a single number")
  }

  gradient_args <- list(colours = colors, extend = extend)
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

#' Vignette fill
#'
#' `fill_vignette()` builds a [grid::pattern()] fill value that fades a
#' colour out towards the edges of each tile, using [grid::as.mask()] --
#' the one `grid` capability the rest of the `fill_*()` family doesn't
#' touch. A solid `color` layer is masked by a radial alpha mask (opaque at
#' the tile centre, fully transparent at its edge), optionally revealing a
#' solid `background` layer underneath rather than true transparency.
#'
#' As with [fill_gradient()], the fade shape is kept circular by correcting
#' the *tile* to be physically square via `aspect` (the target's
#' bounding-box width-to-height ratio), the same technique [fill_stipple()]
#' uses for its dots -- once the tile is square, a mask specified inside it
#' in plain `"npc"` needs no further correction.
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
#' @param color Fill colour at the tile's centre. Default `"black"`.
#' @param background Fill colour revealed as `color` fades out, or `NA` for
#'   true transparency (showing whatever is drawn behind the target shape).
#'   Default `NA`.
#' @param spacing Tile size, as a fraction of the target's bounding box.
#'   Must be a positive number. Default `1` (one tile spans the whole
#'   shape).
#' @param aspect Width-to-height ratio of the target polygon's bounding box.
#'   Must be a positive number. Default `1` (a square bounding box).
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @family fill helpers
#' @export
fill_vignette <- function(color = "black",
                           background = NA,
                           spacing = 1,
                           aspect = 1) {
  validate_fill_args(NULL, spacing, aspect)
  if (!is.character(color) || length(color) != 1) {
    rlang::abort("color must be a single string")
  }
  if (length(background) != 1 || !(is.na(background) || is.character(background))) {
    rlang::abort("background must be a single string, or NA")
  }

  mask_grob <- grid::circleGrob(
    x = 0.5, y = 0.5, r = 0.5,
    gp = grid::gpar(fill = grid::radialGradient(colours = c(color, "transparent")), col = NA)
  )
  fg <- grid::gTree(
    children = grid::gList(
      grid::rectGrob(
        x = 0.5, y = 0.5, width = 1, height = 1,
        default.units = "npc",
        gp = grid::gpar(fill = color, col = NA)
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

  grid::pattern(content, width = spacing, height = spacing * aspect, extend = "repeat")
}

#' Striped pattern fill
#'
#' `fill_stripe()` builds a [grid::pattern()] fill value that renders
#' repeating solid bands of two colours, at a given `angle`.
#'
#' Unlike [fill_hatch()], this doesn't use the corner-to-corner-diagonal
#' tile-shape technique at all -- because a *filled* band, unlike a thin
#' hatch *line*, needs every point along a tile's edge to match its
#' neighbour, not just the points where a thin line happens to cross, a
#' single diagonal split of a tile turns out not to tile seamlessly at an
#' arbitrary angle the way a thin hatch line does. Instead, `fill_stripe()`
#' sidesteps [grid::pattern()]'s tile-copy repetition altogether: the
#' stripe angle and period come from a short two-colour
#' [grid::linearGradient()] with hard colour stops (no smooth transition)
#' and `extend = "repeat"`, which repeats *itself* continuously along its
#' own axis -- a fundamentally different (and for this purpose, simpler)
#' mechanism than tiling a rasterised copy. [grid::pattern()] is still used
#' around this gradient, but only once, as a single square (aspect-
#' corrected) tile spanning the whole target shape, exactly as
#' [fill_gradient()] does by default -- not to create repetition, which the
#' gradient already provides.
#'
#' @param color1,color2 The two stripe colours. Defaults `"black"` and
#'   `"white"`.
#' @param width Fraction of each stripe period that is `color1` (the rest
#'   is `color2`). Must be a number strictly between `0` and `1`. Default
#'   `0.5` (equal bands).
#' @param spacing One stripe period (`color1` band plus `color2` band), as
#'   a fraction of the target's bounding box. Must be a positive number.
#'   Default `0.2`.
#' @inheritParams fill_hatch
#'
#' @return A pattern object as returned by [grid::pattern()], suitable for
#'   use as the `fill` argument to [grid::gpar()].
#'
#' @family fill helpers
#' @export
fill_stripe <- function(color1 = "black",
                         color2 = "white",
                         angle = 45,
                         width = 0.5,
                         spacing = 0.2,
                         aspect = 1,
                         extend = "repeat") {
  validate_fill_args(angle, spacing, aspect)
  if (!is.character(color1) || length(color1) != 1) {
    rlang::abort("color1 must be a single string")
  }
  if (!is.character(color2) || length(color2) != 1) {
    rlang::abort("color2 must be a single string")
  }
  if (!is.numeric(width) || length(width) != 1 || width <= 0 || width >= 1) {
    rlang::abort("width must be a single number strictly between 0 and 1")
  }

  theta <- angle * pi / 180
  half <- spacing / 2
  gradient <- grid::linearGradient(
    colours = c(color1, color1, color2, color2),
    stops = c(0, width, width, 1),
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

#' Bounding-box aspect ratio of a drawable
#'
#' Internal helper. Computes the width-to-height ratio of a [drawable]
#' object's own points, for use as the `aspect` argument to fill helpers
#' like [fill_hatch()] and [fill_crosshatch()].
#'
#' @param object A [drawable] object.
#'
#' @return A single positive number.
#' @noRd
bbox_aspect <- function(object) {
  diff(range(object@points@x)) / diff(range(object@points@y))
}
