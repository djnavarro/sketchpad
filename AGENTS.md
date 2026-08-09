# AGENTS.md

## What this package is

sketchpad is a lightweight, p5.js-inspired drawing system for generative
art, built on [S7](https://rconsortium.github.io/S7/) classes and `grid`
graphics. It bypasses ggplot2 entirely: a small set of `drawable` shapes
and curves (`shape_circle`, `shape_blob`, `shape_ribbon`, `shape_twist`,
`shape_bezier`, `curve_bezier`) expose a computed `points` property, are
composed into a `sketch`, and rendered with
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md). It is the
shared foundation extracted from the author’s personal generative-art
sketchbook (`sketches` repo) and is intended to be depended on by the
various `series-*` generative art project repos.

## Architecture reference (current state)

This section documents how the package works *today*. For the design
rationale behind these choices, rejected alternatives, and a record of
how the API got here, see
[.agents/HISTORY.md](https://sketchpad.djnavarro.net/.agents/HISTORY.md).

### Class hierarchy

- **`style`** – container for `color`/`fill`/`linewidth`/`linetype`/
  `linejoin`/`lineend`/`linemitre`, forwarded to
  [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html). `fill` accepts
  either a plain colour string or the output of a `fill_*()` helper (see
  “The `fill_*()` texture family” below); default is
  `fill_solid("black")` (i.e. `"black"`). `linetype` (default `"solid"`,
  forwarded to `lty`) is not independently re-validated – it accepts
  anything [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html)’s `lty`
  does (named types, integer codes, or a custom hex dash string), left
  to `grid` at draw time. `linejoin` (default `"round"`) is validated as
  one of `"round"`/`"mitre"`/ `"bevel"`; `lineend` (default `"round"`)
  as one of `"round"`/`"butt"`/ `"square"`; `linemitre` (default `10`,
  matching [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html)’s own
  default) must be at least `1`. `lineend` only has a visible effect on
  `"path"`-geometry drawables (free endpoints); `linemitre` only takes
  effect when `linejoin = "mitre"`, truncating a corner sharper than the
  limit allows into a bevel instead.
- **`point_set`** – a polygon’s vertices (`x`/`y` numeric vectors, equal
  length). Named `point_set` rather than `points` so the exported
  constructor doesn’t mask
  [`graphics::points()`](https://rdrr.io/r/graphics/points.html); every
  `drawable`’s `points` *property* (see below) is still called `points`,
  since a property isn’t a top-level exported name and can’t mask
  anything.
- **`drawable`** – parent class of every shape. Declares three
  properties: `style` (default
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md)),
  `geometry` (a validated string, one of
  `"polygon"`/`"path"`/`"points"`, default `"polygon"` – tells
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) which
  grob type to build, on a dimensional reading: `"points"` is 0D,
  `"path"` is 1D, `"polygon"` is 2D and the only value any current
  `shape_*()` constructor uses), and a computed `points` property that
  subclasses override. Not meant to be instantiated directly.
  `drawable`’s own `constructor` sets `geometry`’s default explicitly
  (as an argument default, not just a `new_property(default = ...)`
  spec) because it bypasses S7’s auto-generated constructor – see
  “Gotchas”.
- **`shape_raw`** – the trivial drawable: `x`/`y` supplied directly as
  `points`. Usually produced by `convert()`, not constructed by hand.
  `curve_raw`/`points_raw` are its `"path"`/`"points"`-geometry analogs
  (see below) – together the three form a “raw” family covering all
  three `geometry` values with the same trivial constructor shape.
- **`shape_circle`** – centroid + radius + `n` (point count); `points`
  is `n` evenly-spaced points around the circumference.
- **`shape_blob`** – like `shape_circle`, but the radius is perturbed by
  simplex noise
  ([`ambient::fracture()`](https://ambient.data-imaginist.com/reference/fracture.html)/[`ambient::gen_simplex()`](https://ambient.data-imaginist.com/reference/noise_simplex.html)/
  [`ambient::fbm()`](https://ambient.data-imaginist.com/reference/fbm.html)),
  giving an irregular outline. `range` controls noise amplitude,
  `frequency`/`octaves`/`seed` control the noise field.
- **`shape_ribbon`** – a tapered band between `(x, y)` and
  `(xend, yend)`, width modulated by simplex noise and a `sqrt` taper
  that goes to zero at both ends.
- **`shape_twist`** – like `shape_ribbon`, but the underlying path is a
  smoothed Brownian bridge (built directly from
  [`stats::rnorm()`](https://rdrr.io/r/stats/Normal.html) via the
  internal `smooth_bridge()` helper – no longer a dependency on
  [`e1071::rbridge()`](https://rdrr.io/pkg/e1071/man/rbridge.html),
  which it reproduces bit-for-bit for the same seed) rather than a
  straight line.
- **`shape_bezier`** – outline follows a Bezier curve through an
  arbitrary number of control points (`x`/`y`), evaluated via the
  Bernstein polynomial basis (internal `bernstein()` helper, *not* De
  Casteljau’s algorithm). Ported from `series-lissajous`, but
  redesigned: the original was a bare `S7_object` producing a `curve`
  data frame, consumed internally by a separate `bezier_ribbon`
  drawable. Here `shape_bezier` itself has `parent = drawable`, so it’s
  directly usable with
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) – always
  rendering closed (`geometry = "polygon"`, the curve’s last point
  connects straight back to its first) – for the same curve as an open
  path instead, see `curve_bezier`. `bezier_ribbon` itself has not been
  ported; see PLAN.md.
- **`curve_bezier`** – the first `curve_*()`-prefixed drawable: an open
  Bezier path, `geometry = "path"` fixed at construction (not exposed as
  a caller-facing argument). Shares its geometry computation and
  argument validation with `shape_bezier` via two internal helpers
  factored into `R/shape_bezier.R` (`bezier_curve_points()`,
  `validate_bezier_args()`), since the two constructors are otherwise
  identical – `curve_bezier` just passes `drawable(geometry = "path")`
  instead of bare
  [`drawable()`](https://sketchpad.djnavarro.net/reference/drawable.md).
  `style@fill` is accepted (forwarded to
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md) like
  any other drawable) but has no visible effect, per `drawable`’s
  `geometry` docs.
- **`curve_line`** – an open polyline through an arbitrary number (at
  least two) of control points `(x, y)`, connected by straight segments
  in order. Unlike every other drawable, its `points` getter does no
  computation at all (`point_set(x = self@x, y = self@y)` directly), so
  there’s no `n` argument.
- **`curve_spiral`** – centroid (`x`/`y`) + `radius_start`/`radius_end`
  - `turns` + `n`; angle sweeps `2 * pi * turns` radians while radius
    interpolates linearly from `radius_start` to `radius_end`, giving an
    Archimedean-style spiral. Structurally closest to `shape_circle`,
    but needed its own file since the angle range and non-constant
    radius are both new.
- **`curve_scribble`** – a single random wandering line (a finite sum of
  sine harmonics), built from the internal `scribble_lines()` generator
  [`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md)
  already used for its tile texture (`R/fill.R`, shared rather than
  duplicated), but scaled here into an arbitrary `x`/`y` +
  `width`/`height` bounding box on the sketch’s own coordinate plane
  instead of tiled inside a fill pattern. `direction` (`"horizontal"`/
  `"vertical"`) controls which axis `along`/`across` map to, mirroring
  [`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md)’s
  own `direction` argument.
- **`curve_raw`** – `shape_raw`’s `"path"`-geometry analog: `x`/`y`
  supplied directly as `points`, connected by straight segments with no
  smoothing/resampling/closing edge. Unlike `curve_line`, places no
  minimum on `length(x)` (matching `shape_raw`’s own leniency), since
  its primary role is as a `convert()` target for “freezing” any
  `"path"`-geometry drawable (no such `convert()` method exists yet,
  mirroring `shape_raw`’s).
- **`points_raw`** – `shape_raw`’s `"points"`-geometry analog, and the
  first concrete constructor to use `geometry = "points"` (previously
  reserved on the dimensional reading with no constructor exposing it).
  `x`/`y` supplied directly as `points`, rendered as unconnected
  markers; every line-related `style` property
  (`linewidth`/`linetype`/`linejoin`/ `lineend`/`linemitre`) and `fill`
  have no effect, per `drawable`’s `geometry` docs – only `style@color`
  is used, as the marker colour.
- **`sketch`** – a list of `drawable`s (`shapes` property). Built up
  with `sketch() + shape_circle() + shape_blob(...)`; the `+` method
  requires an S7 method registration, not an S3 `` `+.sketch` `` (see
  “Gotchas”).
- **[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md)** – S7
  generic, `dispatch_args = "object"`. Methods for `drawable` (single
  shape) and `sketch` (renders every shape into one shared, equal-aspect
  viewport); a catch-all method on `class_any` warns and returns
  `invisible(NULL)` for anything else. `xlim`/`ylim` default to the
  range of the object’s own points. Both methods build their grob via
  the internal `geometry_grob()` helper (`R/draw.R`), which switches on
  a drawable’s `geometry` property:
  [`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html) for
  `"polygon"`,
  [`grid::polylineGrob()`](https://rdrr.io/r/grid/grid.lines.html) for
  `"path"`,
  [`grid::pointsGrob()`](https://rdrr.io/r/grid/grid.points.html) for
  `"points"` – `style@fill` is omitted from `gpar()` for the latter two,
  since only a closed polygon has an interior to fill.
  `style@linetype`/`style@linejoin`/`style@lineend`/`style@linemitre`
  are forwarded to `gpar()` for both stroked geometries (`"polygon"`,
  `"path"`) but not `"points"`, which has no line to dash, join, cap, or
  mitre – `lineend`/`linemitre` are simply inert for `"polygon"`, which
  has no free endpoint and no mitred corner sharp enough in practice to
  hit the default limit.
- **`convert()`** – S7’s own generic (not defined by this package); a
  `method(convert, list(drawable, shape_raw))` “freezes” any drawable’s
  computed points into a plain `shape_raw`, preserving `style`.

Every closed (`geometry = "polygon"`) drawable’s constructor shares the
`shape_*` prefix
([`shape_circle()`](https://sketchpad.djnavarro.net/reference/shape_circle.md),
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md),
[`shape_ribbon()`](https://sketchpad.djnavarro.net/reference/shape_ribbon.md),
[`shape_twist()`](https://sketchpad.djnavarro.net/reference/shape_twist.md),
[`shape_bezier()`](https://sketchpad.djnavarro.net/reference/shape_bezier.md),
and the trivial
[`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md)),
mirroring the `fill_*()` family below – this groups the “produces a
closed drawable polygon” functions under one discoverable, greppable
prefix distinct from the `fill_*()`,
[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md), and
`convert()` families. Open (`geometry = "path"`) drawables instead share
a `curve_*` prefix – so far just
[`curve_bezier()`](https://sketchpad.djnavarro.net/reference/curve_bezier.md)
– kept visually distinct from `shape_*()` since the two families render
fundamentally differently (closed polygon vs. open stroke), even where
(as with `curve_bezier`/`shape_bezier`) the underlying geometry
computation is shared.

### Rendering model

Every `drawable` is drawn as a single grob (its type chosen by
`geometry` – see `geometry_grob()` above) inside a
[`grid::viewport()`](https://rdrr.io/r/grid/viewport.html) with
equal-axis scaling (`width`/`height` set via `"snpc"` units so a 1:1
aspect ratio is preserved regardless of the device’s own aspect ratio).
`draw(sketch)` computes one shared viewport/axis-range across every
shape’s points, then draws each shape’s grob into it in list order –
later shapes are drawn on top.

[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) itself
needs no special-casing for pattern/gradient fills:
`grid::gpar(fill = ...)` already accepts a colour string or a
`"GridPattern"`-inheriting object interchangeably, so
`object@style@fill` is passed straight through either way.

### The `fill_*()` texture family

`R/fill.R` holds sixteen `fill_*()` constructors for `style@fill`:
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md)
(a validated colour string, no
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) involved),
[`fill_none()`](https://sketchpad.djnavarro.net/reference/fill_none.md)
(a thin `fill_solid(NA_character_)` wrapper – `NA` is already a valid,
transparent [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) colour,
but the wrapper reads more clearly at a call site; note it still renders
as a *closed* unfilled outline, since every `drawable` currently draws a
closed [`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html)
– see “Deferred: open/stroked curve support” in `.agents/PLAN.md`),
[`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)/[`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md)
(diagonal hatching, sharing a tile-shape technique – see below),
[`fill_checker()`](https://sketchpad.djnavarro.net/reference/fill_checker.md)
(a two-colour checkerboard),
[`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md)
(solid alternating bands via a self-repeating hard-stop
[`grid::linearGradient()`](https://rdrr.io/r/grid/patterns.html), not
tile repetition),
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)/[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md)/[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md)
(scattered dots / arbitrary drawables / randomised-radius dots, all
seeded via
[`withr::with_seed()`](https://withr.r-lib.org/reference/with_seed.html)
like
[`shape_blob()`](https://sketchpad.djnavarro.net/reference/shape_blob.md)’s
noise – see “Known rendering risk” in
[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)’s
docs),
[`fill_scribble()`](https://sketchpad.djnavarro.net/reference/fill_scribble.md)
(wandering lines built from random integer-frequency sine harmonics via
the internal `scribble_lines()` helper – periodic by construction, so
tiles with no seam; `direction` is fixed to `"horizontal"` or
`"vertical"` only, not an arbitrary angle – see its “Known limitation”
docs section),
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)
(a rasterised `ambient` simplex/fractal field, sampled on a torus for
seamless tiling),
[`fill_marble()`](https://sketchpad.djnavarro.net/reference/fill_marble.md)/[`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md)
(variants of
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)
sharing its internal `torus_grid()`/`torus_noise()` helpers:
[`fill_marble()`](https://sketchpad.djnavarro.net/reference/fill_marble.md)
displaces sinusoidal bands by torus-periodic turbulence for a veined
look;
[`fill_flow()`](https://sketchpad.djnavarro.net/reference/fill_flow.md)
domain-warps the final field’s own tile angles by a second,
seed-decorrelated torus-periodic field for a swirlier, curl-noise-like
look – both share
[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)’s
occasional faint tile-boundary rasterization seam, more visible here
since [`sin()`](https://rdrr.io/r/base/Trig.html)/warping amplify small
mismatches),
[`fill_image()`](https://sketchpad.djnavarro.net/reference/fill_image.md)
(a caller-supplied raster, letterboxed by default to preserve its own
pixel aspect ratio),
[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md)
(linear/radial via
[`grid::linearGradient()`](https://rdrr.io/r/grid/patterns.html)/`radialGradient()`),
and
[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)
(a colour faded via a
[`grid::as.mask()`](https://rdrr.io/r/grid/as.mask.html) alpha mask –
the only helper using masks). All but
[`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md)
return an object from
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html), sharing the
base S3 class `"GridPattern"`.

The unifying design constraint across all of them:
[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) tiles are
sized as a fraction of the *target polygon’s own bounding box*, not a
fixed physical square, so every helper takes an `aspect` argument (the
target’s bounding-box width/height ratio) to correct for this – computed
via the internal `bbox_aspect()` helper. Two different corrections are
needed depending on what’s drawn:

- Directional content that must tile seamlessly
  ([`fill_hatch()`](https://sketchpad.djnavarro.net/reference/fill_hatch.md)/
  [`fill_crosshatch()`](https://sketchpad.djnavarro.net/reference/fill_crosshatch.md))
  draws a plain corner-to-corner diagonal and controls the *rendered*
  angle via the tile’s own `width`/`height` ratio (the internal
  `hatch_tile_dims()` helper) – never via a raw direction vector baked
  into the segment’s coordinates. `extend = "repeat"` only translates
  tile copies by whole tile-widths/heights, so any slope other than
  exactly 1 (corner-to-corner) leaves a visible mismatch at every tile
  edge.
- Content with no periodicity constraint
  ([`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)’s
  dots,
  [`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md),
  [`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)’s
  mask) instead makes the *tile itself* physically square
  (`height = spacing * aspect`), so content drawn in plain `"npc"`
  inside it needs no further correction.

Shared argument validation lives in the internal `validate_fill_args()`
(spacing/aspect, with an optional angle check via `angle = NULL`).

## Gotchas worth remembering

A handful of non-obvious S7 behaviors that would bite a future edit if
forgotten – all discovered because they only manifest once classes move
from a sourced script into an installed package (see HISTORY.md for the
full debugging narrative):

- **S7 classes get namespace-qualified class names once inside a
  package** (`"sketchpad::sketch"`, not `"sketch"`). Any check written
  as `inherits(x, "drawable")` or an S3 method named `` `+.sketch` ``
  silently stops matching. Use `S7::S7_inherits(x, drawable)` for
  inheritance checks, and register operator methods the S7 way:
  `method(\`+\`, list(sketch, drawable)) \<- function(e1, e2) {…}\`.
- **[`S7::methods_register()`](https://rconsortium.github.io/S7/reference/methods_register.html)
  must be called from `.onLoad()`** (`R/sketchpad-package.R`) whenever
  the package defines a method for an external/base generic (here, `+`).
  Without it, such methods dispatch fine under `devtools::load_all()`
  but silently fail to dispatch once the package is actually installed –
  this only surfaced under `devtools::check()`, not interactive
  development.
- **A custom `constructor` that calls
  `S7::new_object(S7::S7_object(), ...)` does not auto-fill a property’s
  `default` for any property left unnamed in that call.** `drawable`’s
  constructor bypasses S7’s own auto-generated one, so when `geometry`
  was added as a `new_property(default = "polygon")`-only spec, every
  `shape_*()` call failed with
  `@geometry must be <character>, not <NULL>` – confirmed with a minimal
  non-package reprex that this is real S7 behavior, not a
  `drawable`-specific bug. Fixed by giving `drawable`’s own constructor
  an explicit `geometry = "polygon"` argument default and passing it
  through to `new_object()` by name. **Any future property added to
  `drawable` needs the same treatment** as long as its constructor keeps
  bypassing the auto-generated one.
- **A drawable’s `shape_raw(x = ..., y = ..., style = from@style)`
  shortcut doesn’t work.**
  [`shape_raw()`](https://sketchpad.djnavarro.net/reference/shape_raw.md)’s
  constructor only has named `x`/`y` parameters; everything else in
  `...` is forwarded to `style(...)`, so passing
  `style = <a style object>` tries to call `style(style = <...>)` and
  errors. `convert()` instead builds the shape from `x`/`y` alone, then
  reassigns `@style` afterward.
- **R sources `R/*.R` alphabetically by default, which breaks subclass
  definitions.** `shape_blob.R` needs `drawable` (from `drawable.R`) to
  exist first, but “shape_blob.R” \< “drawable.R” alphabetically. Fixed
  with an explicit `Collate` field in `DESCRIPTION` (see “Structure”
  below for the required order) rather than `@include` tags.
- **The first `devtools::document()` pass after adding a new
  cross-referencing class emits “could not resolve link” warnings.**
  This is expected roxygen2 behavior when several classes’ `[link]`
  references point at each other and none of their `.Rd` files exist
  yet; a second `document()` call resolves them all. Don’t chase this
  warning by rewording the docs.
- **`@inheritParams` copies the *literal doc text* of the source
  function, including any “Default `X`” wording – it does not check that
  the borrowing function’s own default actually matches `X`.** A
  pre-merge audit of the `fill_*()` family (all of which lean on
  `@inheritParams fill_hatch()`/[`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)/[`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)
  for `spacing`/`aspect`/`color`/`extend`) found several silently-wrong
  inherited defaults this way –
  e.g. [`fill_noise()`](https://sketchpad.djnavarro.net/reference/fill_noise.md)’s
  real `spacing` default is `0.5`, but its docs said `0.1`
  (fill_hatch()’s own default) until fixed. Whenever a new `fill_*()`
  helper’s own default differs from the function it inherits params
  from, give that parameter its own explicit `@param` overriding the
  inherited text (as
  [`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md)/[`fill_gradient()`](https://sketchpad.djnavarro.net/reference/fill_gradient.md)/[`fill_vignette()`](https://sketchpad.djnavarro.net/reference/fill_vignette.md)/
  [`fill_stripe()`](https://sketchpad.djnavarro.net/reference/fill_stripe.md)
  already do for `spacing`) rather than relying on `@inheritParams` to
  get the number right.
- **`@export` on an individual `method(generic, class) <- function(...)`
  assignment generates its own `.Rd` page with a `\usage` section that
  won’t match hand-written `@param` docs** (e.g. a method’s `xlim`/
  `ylim` formals aren’t part of the generic’s own signature). Add
  `#' @noRd` alongside `#' @export` on every such method block; keep the
  real documentation only on the generic/class definition.
- **`R CMD check` reports a spurious “no visible binding for global
  variable `properties`” NOTE** tied to S7’s `method<-` internals
  misattributing a symbol to this package’s code. Silenced with
  `utils::globalVariables("properties")` in `R/sketchpad-package.R`;
  this is a known S7 artifact, not a real problem in this package’s
  code.
- **`sketch` was not available as the package name.** It’s an existing
  CRAN package (an R-to-JavaScript/p5.js transpiler) – installing both
  would collide. Named this package `sketchpad` instead.
- **`points` was not available as an exported class/constructor name.**
  It would mask
  [`graphics::points()`](https://rdrr.io/r/graphics/points.html) on
  [`library(sketchpad)`](https://sketchpad.djnavarro.net/). The class is
  named `point_set` instead; the `points` *property* every `drawable`
  exposes keeps its original name, since accessing it via `@points`
  never shadows the base function.
- **[`grid::pattern()`](https://rdrr.io/r/grid/patterns.html) tiles
  containing *multiple* shapes can render visibly distorted once the
  tile actually repeats.** Found while building
  [`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)/[`fill_scatter()`](https://sketchpad.djnavarro.net/reference/fill_scatter.md)/[`fill_halftone()`](https://sketchpad.djnavarro.net/reference/fill_halftone.md):
  a single shape (one `circleGrob`, or a single tile spanning the whole
  target via `spacing = 1`, so `extend = "repeat"` never actually
  triggers) always renders correctly, but several separate shapes
  (e.g. `n` scattered dots) inside a tile that’s genuinely repeated
  (`spacing < 1`) can come out clipped into crescents or otherwise
  non-circular – reproduced on this package’s development R build
  (4.6.1) on both an interactive device and
  [`ragg::agg_png()`](https://ragg.r-lib.org/reference/agg_png.html), in
  a fresh R session (so it isn’t session degradation), across multiple
  `n`/`radius` combinations with no clean rule for exactly when it
  triggers. This looks like an upstream `grid`/Cairo bug with
  multi-shape pattern tile content, not something fixable from this
  package’s code – don’t spend more time chasing a root cause or a
  parameter combination that “avoids” it without re-verifying on a
  released (non-development) R version first. Documented on the affected
  functions themselves
  ([`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)’s
  “Known rendering risk” section); no default was found that’s provably
  safe, since
  [`fill_stipple()`](https://sketchpad.djnavarro.net/reference/fill_stipple.md)’s
  whole purpose requires genuine tile repetition.
- **`grDevices::dev.capabilities()$patterns` is not a reliable signal
  for whether a device supports pattern/gradient fills.** It returned
  `NA` for [`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html),
  [`pdf()`](https://rdrr.io/r/grDevices/pdf.html), and
  [`svg()`](https://rdrr.io/r/grDevices/cairo.html) alike when tested –
  not just genuinely unsupported devices – and only reported real values
  (`c("LinearGradient", "RadialGradient", "TilingPattern")`) on
  Positron’s own live plotting device. A
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md)-time
  warning built on this was implemented and then reverted for exactly
  this reason (see HISTORY.md); don’t re-attempt a capability check on
  this API without first finding a more reliable signal.

## Structure

- `R/fill.R` – the `fill_*()` texture family, loaded first: no
  compile-time dependency on any other class, but `style.R` needs
  [`fill_solid()`](https://sketchpad.djnavarro.net/reference/fill_solid.md)
  to exist for its own property default.
- `R/style.R`, `R/point_set.R`, `R/drawable.R` – foundation classes, in
  load order (each depends on the previous).
- `R/shape_bezier.R`, `R/curve_bezier.R`, `R/curve_line.R`,
  `R/curve_spiral.R`, `R/curve_scribble.R`, `R/shape_raw.R`,
  `R/shape_circle.R`, `R/shape_blob.R`, `R/shape_ribbon.R`,
  `R/shape_twist.R` – the concrete `drawable` subclasses, one file each.
  Every closed constructor shares the `shape_*` prefix, every open one
  the `curve_*` prefix (see “Class hierarchy” above), and each file is
  named to match its constructor – except `curve_bezier.R`, kept
  immediately after `shape_bezier.R` since it shares that file’s
  `bernstein()`/`bezier_curve_points()`/`validate_bezier_args()`
  internal helpers rather than duplicating them.
  `curve_line.R`/`curve_spiral.R` need no such sharing (each is
  genuinely new geometry with no `shape_*()` counterpart), so they’re
  ordinary standalone constructor files. `curve_scribble.R` shares
  `R/fill.R`’s internal `scribble_lines()` helper (rather than
  duplicating it) but still needs its own file, since it depends on
  `drawable` (defined after `fill.R` in `Collate`) – `fill.R` itself has
  no dependency on `drawable` and loads first.
- `R/sketch.R` – the `sketch` class and its `+` method.
- `R/draw.R` – the `draw` generic and its three methods.
- `R/convert.R` – the `convert(drawable, shape_raw)` method.
- `R/sketchpad-package.R` – package-level doc, `#' @import S7`, the
  `.onLoad()` calling
  [`S7::methods_register()`](https://rconsortium.github.io/S7/reference/methods_register.html),
  and the `globalVariables("properties")` workaround.
- `DESCRIPTION`’s `Collate` field pins the load order above explicitly
  (fill -\> style -\> point_set -\> drawable -\> shape_bezier -\>
  curve_bezier -\> curve_line -\> curve_spiral -\> curve_scribble -\>
  shape_raw -\> shape_circle -\> shape_blob -\> shape_ribbon -\>
  shape_twist -\> sketch -\> draw -\> convert -\> sketchpad-package).
  **Any new drawable subclass must be added to `Collate` after
  `drawable.R`**, or `devtools::load_all()`/`R CMD check` will fail with
  an “object ‘drawable’ not found” error.

## Conventions

- Fully qualify every call to another package
  ([`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html),
  [`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html),
  [`ambient::fracture()`](https://ambient.data-imaginist.com/reference/fracture.html),
  …) inside `R/*.R`; the only bare (unqualified) symbols are this
  package’s own exports plus whatever `#' @import S7`/`#' @importFrom`
  brings in. No [`library()`](https://rdrr.io/r/base/library.html) calls
  anywhere in `R/`.
- Use the base R pipe (`|>`), not the magrittr pipe.
- Every concrete drawable follows the same constructor shape:
  `constructor = function(<own args>, ...) S7::new_object(drawable(), <own args>, style = style(...))`,
  so arbitrary style arguments (`color`, `fill`, `linewidth`) are always
  accepted via `...` without each subclass needing to declare them.
- A computed geometry property (`points`, and `bezier`/`path` on
  `shape_twist`) is a `new_property()` with only a `getter` – geometry
  is always derived, never stored and mutated in place.
- Every scalar numeric/integer constructor argument gets an explicit
  `length(x) != 1` check in `validator`; every non-negative-only
  argument (`radius`, `width`, `range`, `frequency`) gets a `< 0` check;
  every positive-integer argument (`n`, `octaves`) gets a `< 1L` check.
  Keep new drawables consistent with this.

## Development workflow

- Document with roxygen2 (`devtools::document()` – run it twice if
  you’ve just added a class that cross-references others still missing
  their own `.Rd` file; see “Gotchas”).
- Run tests with `devtools::test()`; full checks with
  `devtools::check()`. The package should check cleanly (0
  errors/warnings/notes) – treat any new NOTE/WARNING as a real problem
  to fix, not something to ignore, with the sole documented exception of
  the `properties` NOTE workaround above.
- Tests live in `tests/testthat/`, one file per drawable/concern
  (`test-drawable.R`, `test-bezier.R`, …).
- `README.Rmd` holds four worked examples (ring of blobs, scattered
  blobs, ribbons, twists), each a direct port of an `example_0N.R`
  script from the `sketches` repo; `devtools::build_readme()`
  regenerates `README.md` and the figures under `man/figures/`. Re-run
  it after any change that would alter one of the four examples’ output.

## Keeping this documentation current

This file (`AGENTS.md`) should stay a lean, current-state reference – if
a change makes something above inaccurate, update it in place rather
than appending a note about the change.

Two companion files in `.agents/` (also excluded from the built package
via `.Rbuildignore`) carry the parts that don’t belong here:

- **[.agents/HISTORY.md](https://sketchpad.djnavarro.net/.agents/HISTORY.md)**
  – a condensed record of completed design decisions and their rationale
  (what was tried, rejected, and why), for context in future sessions.
  When you finish a piece of nontrivial design work, add an entry here
  rather than growing this file with “used to be X, now Y” narrative.
- **[.agents/PLAN.md](https://sketchpad.djnavarro.net/.agents/PLAN.md)**
  – scoped-out future work and deferred/open items. When you finish
  something listed there, move its write-up into `HISTORY.md` and remove
  it from `PLAN.md` rather than marking it “done” in place.
