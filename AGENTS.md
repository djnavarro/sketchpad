# AGENTS.md

## What this package is

sketchpad is a lightweight, p5.js-inspired drawing system for generative
art, built on [S7](https://rconsortium.github.io/S7/) classes and `grid`
graphics. It bypasses ggplot2 entirely: a small set of `drawable` shapes
(`circle`, `blob`, `ribbon`, `twist`, `bezier`) expose a computed `points`
property, are composed into a `sketch`, and rendered with `draw()`. It is
the shared foundation extracted from the author's personal generative-art
sketchbook (`sketches` repo) and is intended to be depended on by the
various `series-*` generative art project repos.

## Architecture reference (current state)

This section documents how the package works *today*. For the design
rationale behind these choices, rejected alternatives, and a record of
how the API got here, see [.agents/HISTORY.md](.agents/HISTORY.md).

### Class hierarchy

- **`style`** -- container for `color`/`fill`/`linewidth`, forwarded to
  `grid::gpar()`. `fill` accepts either a plain colour string or the
  output of a `fill_*()` helper (see "The `fill_*()` texture family"
  below); default is `fill_solid("black")` (i.e. `"black"`).
- **`points`** -- a polygon's vertices (`x`/`y` numeric vectors, equal
  length).
- **`drawable`** -- parent class of every shape. Declares two properties:
  `style` (default `style()`) and a computed `points` property that
  subclasses override. Not meant to be instantiated directly.
- **`shape`** -- the trivial drawable: `x`/`y` supplied directly as
  `points`. Usually produced by `convert()`, not constructed by hand.
- **`circle`** -- centroid + radius + `n` (point count); `points` is
  `n` evenly-spaced points around the circumference.
- **`blob`** -- like `circle`, but the radius is perturbed by simplex
  noise (`ambient::fracture()`/`ambient::gen_simplex()`/`ambient::fbm()`),
  giving an irregular outline. `range` controls noise amplitude,
  `frequency`/`octaves`/`seed` control the noise field.
- **`ribbon`** -- a tapered band between `(x, y)` and `(xend, yend)`,
  width modulated by simplex noise and a `sqrt` taper that goes to zero
  at both ends.
- **`twist`** -- like `ribbon`, but the underlying path is a smoothed
  Brownian bridge (`e1071::rbridge()` via the internal `smooth_bridge()`
  helper) rather than a straight line.
- **`bezier`** -- outline follows a Bezier curve through an arbitrary
  number of control points (`x`/`y`), evaluated via the Bernstein
  polynomial basis (internal `bernstein()` helper, *not* De Casteljau's
  algorithm). Ported from `series-lissajous`, but redesigned: the
  original was a bare `S7_object` producing a `curve` data frame,
  consumed internally by a separate `bezier_ribbon` drawable. Here
  `bezier` itself has `parent = drawable`, so it's directly usable with
  `draw()` -- at the cost of always rendering as a closed polygon (the
  curve's last point connects straight back to its first), since every
  `drawable`'s `points` are drawn with `grid::polygonGrob()`. There is no
  open/stroked-curve option. `bezier_ribbon` itself has not been ported;
  see PLAN.md.
- **`sketch`** -- a list of `drawable`s (`shapes` property). Built up
  with `sketch() + circle() + blob(...)`; the `+` method requires an S7
  method registration, not an S3 `` `+.sketch` `` (see "Gotchas").
- **`draw()`** -- S7 generic, `dispatch_args = "object"`. Methods for
  `drawable` (single shape) and `sketch` (renders every shape into one
  shared, equal-aspect viewport); a catch-all method on `class_any` warns
  and returns `invisible(NULL)` for anything else. `xlim`/`ylim` default
  to the range of the object's own points.
- **`convert()`** -- S7's own generic (not defined by this package); a
  `method(convert, list(drawable, shape))` "freezes" any drawable's
  computed points into a plain `shape`, preserving `style`.

### Rendering model

Every `drawable` is drawn as a single `grid::polygonGrob()` inside a
`grid::viewport()` with equal-axis scaling (`width`/`height` set via
`"snpc"` units so a 1:1 aspect ratio is preserved regardless of the
device's own aspect ratio). `draw(sketch)` computes one shared
viewport/axis-range across every shape's points, then draws each shape's
polygon into it in list order -- later shapes are drawn on top.

`draw()` itself needs no special-casing for pattern/gradient fills:
`grid::gpar(fill = ...)` already accepts a colour string or a
`"GridPattern"`-inheriting object interchangeably, so `object@style@fill`
is passed straight through either way.

### The `fill_*()` texture family

`R/fill.R` holds fourteen `fill_*()` constructors for `style@fill`:
`fill_solid()` (a validated colour string, no `grid::pattern()` involved),
`fill_hatch()`/`fill_crosshatch()` (diagonal hatching, sharing a
tile-shape technique -- see below), `fill_checker()` (a two-colour
checkerboard), `fill_stripe()` (solid alternating bands via a
self-repeating hard-stop `grid::linearGradient()`, not tile repetition),
`fill_stipple()`/`fill_scatter()`/`fill_halftone()` (scattered dots /
arbitrary drawables / randomised-radius dots, all seeded via
`withr::with_seed()` like `blob()`'s noise -- see "Known rendering risk"
in `fill_stipple()`'s docs), `fill_noise()` (a rasterised `ambient`
simplex/fractal field, sampled on a torus for seamless tiling),
`fill_marble()`/`fill_flow()` (variants of `fill_noise()` sharing its
internal `torus_grid()`/`torus_noise()` helpers: `fill_marble()` displaces
sinusoidal bands by torus-periodic turbulence for a veined look;
`fill_flow()` domain-warps the final field's own tile angles by a second,
seed-decorrelated torus-periodic field for a swirlier, curl-noise-like
look -- both share `fill_noise()`'s occasional faint tile-boundary
rasterization seam, more visible here since `sin()`/warping amplify small
mismatches), `fill_image()` (a caller-supplied raster, letterboxed by
default to preserve its own pixel aspect ratio), `fill_gradient()`
(linear/radial via `grid::linearGradient()`/`radialGradient()`), and
`fill_vignette()` (a colour faded via a `grid::as.mask()` alpha mask --
the only helper using masks). All but `fill_solid()` return an object
from `grid::pattern()`, sharing the base S3 class `"GridPattern"`.

The unifying design constraint across all of them: `grid::pattern()`
tiles are sized as a fraction of the *target polygon's own bounding box*,
not a fixed physical square, so every helper takes an `aspect` argument
(the target's bounding-box width/height ratio) to correct for this --
computed via the internal `bbox_aspect()` helper. Two different
corrections are needed depending on what's drawn:

- Directional content that must tile seamlessly (`fill_hatch()`/
  `fill_crosshatch()`) draws a plain corner-to-corner diagonal and
  controls the *rendered* angle via the tile's own `width`/`height`
  ratio (the internal `hatch_tile_dims()` helper) -- never via a raw
  direction vector baked into the segment's coordinates. `extend =
  "repeat"` only translates tile copies by whole tile-widths/heights, so
  any slope other than exactly 1 (corner-to-corner) leaves a visible
  mismatch at every tile edge.
- Content with no periodicity constraint (`fill_stipple()`'s dots,
  `fill_gradient()`, `fill_vignette()`'s mask) instead makes the *tile
  itself* physically square (`height = spacing * aspect`), so content
  drawn in plain `"npc"` inside it needs no further correction.

Shared argument validation lives in the internal `validate_fill_args()`
(spacing/aspect, with an optional angle check via `angle = NULL`).

## Gotchas worth remembering

A handful of non-obvious S7 behaviors that would bite a future edit if
forgotten -- all discovered because they only manifest once classes move
from a sourced script into an installed package (see HISTORY.md for the
full debugging narrative):

- **S7 classes get namespace-qualified class names once inside a
  package** (`"sketchpad::sketch"`, not `"sketch"`). Any check written
  as `inherits(x, "drawable")` or an S3 method named `` `+.sketch` ``
  silently stops matching. Use `S7::S7_inherits(x, drawable)` for
  inheritance checks, and register operator methods the S7 way:
  `method(\`+\`, list(sketch, drawable)) <- function(e1, e2) {...}`.
- **`S7::methods_register()` must be called from `.onLoad()`**
  (`R/sketchpad-package.R`) whenever the package defines a method for an
  external/base generic (here, `+`). Without it, such methods dispatch
  fine under `devtools::load_all()` but silently fail to dispatch once
  the package is actually installed -- this only surfaced under
  `devtools::check()`, not interactive development.
- **A drawable's `shape(x = ..., y = ..., style = from@style)`
  shortcut doesn't work.** `shape()`'s constructor only has named
  `x`/`y` parameters; everything else in `...` is forwarded to
  `style(...)`, so passing `style = <a style object>` tries to call
  `style(style = <...>)` and errors. `convert()` instead builds the
  shape from `x`/`y` alone, then reassigns `@style` afterward.
- **R sources `R/*.R` alphabetically by default, which breaks subclass
  definitions.** `blob.R` needs `drawable` (from `drawable.R`) to exist
  first, but "blob.R" < "drawable.R" alphabetically. Fixed with an
  explicit `Collate` field in `DESCRIPTION` (see "Structure" below for
  the required order) rather than `@include` tags.
- **The first `devtools::document()` pass after adding a new
  cross-referencing class emits "could not resolve link" warnings.**
  This is expected roxygen2 behavior when several classes' `[link]`
  references point at each other and none of their `.Rd` files exist
  yet; a second `document()` call resolves them all. Don't chase this
  warning by rewording the docs.
- **`@export` on an individual `method(generic, class) <- function(...)`
  assignment generates its own `.Rd` page with a `\usage` section that
  won't match hand-written `@param` docs** (e.g. a method's `xlim`/
  `ylim` formals aren't part of the generic's own signature). Add
  `#' @noRd` alongside `#' @export` on every such method block; keep the
  real documentation only on the generic/class definition.
- **`R CMD check` reports a spurious "no visible binding for global
  variable `properties`" NOTE** tied to S7's `method<-` internals
  misattributing a symbol to this package's code. Silenced with
  `utils::globalVariables("properties")` in `R/sketchpad-package.R`;
  this is a known S7 artifact, not a real problem in this package's code.
- **`sketch` was not available as the package name.** It's an existing
  CRAN package (an R-to-JavaScript/p5.js transpiler) -- installing both
  would collide. Named this package `sketchpad` instead.
- **`grid::pattern()` tiles containing *multiple* shapes can render
  visibly distorted once the tile actually repeats.** Found while
  building `fill_stipple()`/`fill_scatter()`/`fill_halftone()`: a single
  shape (one `circleGrob`, or a single tile spanning the whole target via
  `spacing = 1`, so `extend = "repeat"` never actually triggers) always
  renders correctly, but several separate shapes (e.g. `n` scattered
  dots) inside a tile that's genuinely repeated (`spacing < 1`) can come
  out clipped into crescents or otherwise non-circular -- reproduced on
  this package's development R build (4.6.1) on both an interactive
  device and `ragg::agg_png()`, in a fresh R session (so it isn't session
  degradation), across multiple `n`/`radius` combinations with no clean
  rule for exactly when it triggers. This looks like an upstream
  `grid`/Cairo bug with multi-shape pattern tile content, not something
  fixable from this package's code -- don't spend more time chasing a
  root cause or a parameter combination that "avoids" it without
  re-verifying on a released (non-development) R version first. Documented
  on the affected functions themselves (`fill_stipple()`'s "Known
  rendering risk" section); no default was found that's provably safe,
  since `fill_stipple()`'s whole purpose requires genuine tile repetition.
- **`grDevices::dev.capabilities()$patterns` is not a reliable signal
  for whether a device supports pattern/gradient fills.** It returned
  `NA` for `cairo_pdf()`, `pdf()`, and `svg()` alike when tested -- not
  just genuinely unsupported devices -- and only reported real values
  (`c("LinearGradient", "RadialGradient", "TilingPattern")`) on
  Positron's own live plotting device. A `draw()`-time warning built on
  this was implemented and then reverted for exactly this reason (see
  HISTORY.md); don't re-attempt a capability check on this API without
  first finding a more reliable signal.

## Structure

- `R/fill.R` -- the `fill_*()` texture family, loaded first: no
  compile-time dependency on any other class, but `style.R` needs
  `fill_solid()` to exist for its own property default.
- `R/style.R`, `R/points.R`, `R/drawable.R` -- foundation classes, in
  load order (each depends on the previous).
- `R/bezier.R`, `R/shape.R`, `R/circle.R`, `R/blob.R`, `R/ribbon.R`,
  `R/twist.R` -- the concrete `drawable` subclasses, one file each.
- `R/sketch.R` -- the `sketch` class and its `+` method.
- `R/draw.R` -- the `draw` generic and its three methods.
- `R/convert.R` -- the `convert(drawable, shape)` method.
- `R/sketchpad-package.R` -- package-level doc, `#' @import S7`, the
  `.onLoad()` calling `S7::methods_register()`, and the
  `globalVariables("properties")` workaround.
- `DESCRIPTION`'s `Collate` field pins the load order above explicitly
  (fill -> style -> points -> drawable -> bezier -> shape -> circle ->
  blob -> ribbon -> twist -> sketch -> draw -> convert ->
  sketchpad-package). **Any new drawable subclass must be added to
  `Collate` after `drawable.R`**, or `devtools::load_all()`/
  `R CMD check` will fail with an "object 'drawable' not found" error.

## Conventions

- Fully qualify every call to another package (`S7::new_class()`,
  `grid::polygonGrob()`, `ambient::fracture()`, ...) inside `R/*.R`; the
  only bare (unqualified) symbols are this package's own exports plus
  whatever `#' @import S7`/`#' @importFrom` brings in. No `library()`
  calls anywhere in `R/`.
- Use the base R pipe (`|>`), not the magrittr pipe.
- Every concrete drawable follows the same constructor shape:
  `constructor = function(<own args>, ...) S7::new_object(drawable(),
  <own args>, style = style(...))`, so arbitrary style arguments
  (`color`, `fill`, `linewidth`) are always accepted via `...` without
  each subclass needing to declare them.
- A computed geometry property (`points`, and `bezier`/`path` on
  `twist`) is a `new_property()` with only a `getter` -- geometry is
  always derived, never stored and mutated in place.
- Every scalar numeric/integer constructor argument gets an explicit
  `length(x) != 1` check in `validator`; every non-negative-only
  argument (`radius`, `width`, `range`, `frequency`) gets a `< 0` check;
  every positive-integer argument (`n`, `octaves`) gets a `< 1L` check.
  Keep new drawables consistent with this.

## Development workflow

- Document with roxygen2 (`devtools::document()` -- run it twice if
  you've just added a class that cross-references others still missing
  their own `.Rd` file; see "Gotchas").
- Run tests with `devtools::test()`; full checks with `devtools::check()`.
  The package should check cleanly (0 errors/warnings/notes) -- treat any
  new NOTE/WARNING as a real problem to fix, not something to ignore,
  with the sole documented exception of the `properties` NOTE workaround
  above.
- Tests live in `tests/testthat/`, one file per drawable/concern
  (`test-drawable.R`, `test-bezier.R`, ...).
- `README.Rmd` holds four worked examples (ring of blobs, scattered
  blobs, ribbons, twists), each a direct port of an `example_0N.R` script
  from the `sketches` repo; `devtools::build_readme()` regenerates
  `README.md` and the figures under `man/figures/`. Re-run it after any
  change that would alter one of the four examples' output.

## Keeping this documentation current

This file (`AGENTS.md`) should stay a lean, current-state reference --
if a change makes something above inaccurate, update it in place rather
than appending a note about the change.

Two companion files in `.agents/` (also excluded from the built package
via `.Rbuildignore`) carry the parts that don't belong here:

- **[.agents/HISTORY.md](.agents/HISTORY.md)** -- a condensed record of
  completed design decisions and their rationale (what was tried,
  rejected, and why), for context in future sessions. When you finish a
  piece of nontrivial design work, add an entry here rather than growing
  this file with "used to be X, now Y" narrative.
- **[.agents/PLAN.md](.agents/PLAN.md)** -- scoped-out future work and
  deferred/open items. When you finish something listed there, move its
  write-up into `HISTORY.md` and remove it from `PLAN.md` rather than
  marking it "done" in place.
