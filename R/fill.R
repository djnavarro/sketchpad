#' Validate the shared arguments of a `fill_*()` helper
#'
#' Internal helper shared by every `fill_*()` pattern-fill constructor.
#'
#' @param angle,spacing,aspect The arguments of the same name from the
#'   calling `fill_*()` function.
#' @noRd
validate_fill_args <- function(angle, spacing, aspect) {
  if (!is.numeric(spacing) || length(spacing) != 1 || spacing <= 0) {
    rlang::abort("spacing must be a single positive number")
  }
  if (!is.numeric(aspect) || length(aspect) != 1 || aspect <= 0) {
    rlang::abort("aspect must be a single positive number")
  }
  if (!is.numeric(angle) || length(angle) != 1) {
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
