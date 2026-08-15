# sketchpad design history

This file is a condensed historical record of completed design
decisions: what was tried, what was rejected, and why. It exists for
context in future sessions, not as a changelog or PR log -- step-by-step
implementation narrative (file-by-file diffs, exact test-pass counts,
staged commit sequencing) has generally been trimmed in favor of the
decisions themselves; see git history for that level of detail if it's
ever needed. Entries are in roughly chronological order. Current-state
facts that came out of this history (what the API looks like today) live
in `AGENTS.md`, not here.

## Extracting a package from the `sketches` sketchbook repo

The drawing system (S7 classes atop `grid`: `style`/`points`/`drawable`
and the `circle`/`blob`/`ribbon`/`twist` shapes, plus `sketch`/`draw()`)
started as a single `sketches.R` file, `source()`-d by `example_*.R`
scripts in a personal generative-art sketchbook repo. It had no
`DESCRIPTION`/`NAMESPACE`/`R/` -- a project-based script, not a package --
but was already S7-idiomatic enough (clean class hierarchy, computed
properties, validators) to package with only mechanical changes.

**Naming.** `sketch` was the first choice (simpler, matches the existing
`sketch()` class), but it's already an existing CRAN package -- an
R-to-JavaScript/p5.js transpiler, coincidentally also p5.js-flavored.
Reusing the name would risk a real installation collision, not just a
CRAN-submission-time conflict, so the package was named `sketchpad`
instead.

**Location.** Scaffolded as a new sibling repo
(`djnavarro/sketchpad`), not a subdirectory of `sketches` and not a
conversion of that repo's root -- keeping the sketchbook and the shared
framework as independently-versioned things.

## Splitting `sketches.R` into per-class files

Each class got its own file under `R/` (`style.R`, `points.R`,
`drawable.R`, `shape.R`, `circle.R`, `blob.R`, `ribbon.R`, `twist.R`,
`sketch.R`, `draw.R`, `convert.R`). This immediately broke
`devtools::document()`/`load_all()`: R sources `R/*.R` alphabetically by
default, so `blob.R` (needs `drawable`) loaded before `drawable.R`
defined it, erroring with "object 'drawable' not found". Fixed with an
explicit `Collate` field in `DESCRIPTION` (via the `desc` package) rather
than roxygen `@include` tags, since the dependency chain is a strict
total order here (style -> points -> drawable -> subclasses -> sketch ->
draw -> convert) and a single hand-maintained list is simpler than
tagging every file.

## Three S7-specific bugs that only appeared once packaged

None of these were bugs in the original `sketches.R` script -- they're
specifically about how S7 classes/methods behave once namespaced inside
an installed package, and were only caught by running `devtools::check()`
rather than `load_all()`.

**`+.sketch` stopped dispatching.** The original script defined a plain
S3 method, `` `+.sketch` <- function(e1, e2) {...} ``, and it worked --
because in a bare script, an S7 object's class attribute is just
`c("sketch", "S7_object")`. Once `sketch` is defined inside a package,
S7 namespace-qualifies the class name to `"sketchpad::sketch"`, so R's
S3 dispatch for `+` (which looks for `` `+.sketch` ``, not
`` `+.sketchpad::sketch` ``) never finds it, and falls through to S7's
own `Ops.S7_object` handler, which errors with "Can't find method for
generic `+(e1, e2)`". Fixed by registering `+` as a proper S7 method
instead: `method(\`+\`, list(sketch, drawable)) <- function(e1, e2)
{...}`. The same namespacing broke the `sketch` validator's
`inherits(d, "drawable")` check (`class(d)` no longer contains the bare
string `"drawable"`); fixed with `S7::S7_inherits(d, drawable)`, which
compares against the class object rather than a string.

**Even after registering it as an S7 method, `+` still failed --
under `R CMD check`, not under `load_all()`.** `S7::methods_register()`
must be called from `.onLoad()` whenever a package defines a method for
an external/base generic (here, `+`, a primitive). Without it, method
registration only takes effect within the current session's dev-loaded
state, not for a package loaded normally via `library()`. Added a
minimal `.onLoad(libname, pkgname) { S7::methods_register() }` to
`R/sketchpad-package.R`. This is now the first thing to check if any
future S7-method-on-an-external-generic mysteriously stops working only
in `R CMD check`/a fresh session.

**`convert(drawable, shape)` had a latent constructor bug,** inherited
unnoticed from the original script (never exercised by any of the
`example_*.R` scripts, so it went undetected there too). It called
`shape(style = from@style, x = from@points@x, y = from@points@y)`, but
`shape()`'s constructor signature is `function(x, y, ...)` -- everything
not named `x`/`y` goes into `...`, which is forwarded to `style(...)`.
So `style = from@style` became an attempt to call `style(style =
<object>)`, which errors ("unused argument"). Fixed by constructing the
shape from `x`/`y` alone, then reassigning `@style` afterward:
`out <- shape(x = ..., y = ...); out@style <- from@style; out`.

## `R CMD check` cleanup

Getting to a clean check (0 errors/warnings/notes) surfaced a few more
S7-and-roxygen-specific issues, none of them bugs in the runtime
behavior:

- **Rd `\usage` mismatches.** `@export` on each individual
  `method(draw, drawable) <- function(object, xlim = NULL, ylim = NULL,
  ...) {...}` assignment made roxygen generate a separate `.Rd` page per
  method, and that page's auto-derived `\usage` didn't match the
  hand-written `@param xlim`/`@param ylim` docs (those params belong to
  the method, not the generic's own `dispatch_args = "object"`
  signature). Fixed by adding `#' @noRd` alongside `#' @export` on every
  method-assignment block, keeping full prose documentation only on the
  generic (`draw <- S7::new_generic(...)`) or class definition. Applied
  the same fix to the `+` method and the `convert()` method.
- **First-pass "could not resolve link" warnings** when several new
  classes' roxygen `[link]`s point at each other and none of their `.Rd`
  files exist yet on the first `devtools::document()` call. Resolved
  itself on a second `document()` call; not a real problem, just an
  ordering artifact.
- **Spurious "no visible binding for global variable `properties`"
  NOTE,** traced to S7's `method<-` replacement-function internals,
  misattributed by `R CMD check`'s static analysis to this package's own
  code (it doesn't actually reference a variable called `properties`
  anywhere). Silenced with `utils::globalVariables("properties")`,
  documented in `R/sketchpad-package.R` as a known S7 artifact rather
  than removed by chasing the phantom reference.
- **"Namespaces in Imports field not imported from" NOTE** for
  `ambient`/`grid`/`purrr`/`rlang`, despite genuine `pkg::fun()` usage
  throughout `R/*.R`. Traced to those specific calls only appearing
  inside `S7::method(...) <- function(...) {...}` bodies, which aren't
  visible to `R CMD check`'s static usage scan the way an ordinary named
  top-level function's body is (calls inside `e1071::rbridge()`/
  `withr::with_seed()` in the plain top-level `smooth_bridge()` function
  *were* detected fine). Fixed by adding one explicit
  `#' @importFrom pkg fun` per affected namespace in
  `R/sketchpad-package.R`, which is sufficient for the check regardless
  of whether the corresponding call site is itself visible to the
  scanner.

## Porting four sketchbook examples into `README.Rmd`

The `sketches` repo's `example_01.R`-`example_04.R` scripts (ring of
blobs, scattered blobs, ribbons, and a batch PNG-export loop over 50
seeds of noise-driven twists) were adapted into `README.Rmd` sections,
swapping `source(here::here("sketches.R"))` for `library(sketchpad)`.
Two changes from the originals:

- Example 4's 50-seed `for` loop writing PNGs to `image_04/` was reduced
  to a single representative seed, rendered inline like the other three
  -- appropriate for a README example, not a batch-export script.
- Example 4's palette came from an external `palette_02.csv` (read via
  `readr::read_csv()`); one row of that CSV's hex colors was inlined
  directly in the README instead, so the example doesn't depend on
  `readr` or an external data file.

Verified the ring-of-blobs example against the original `example_01.R`
output (same default `seed = 1L`, same inputs) -- structurally identical
(same six colors, positions, and blob outlines).

## Adding the `bezier` drawable class

Ported from `series-lissajous`'s `source/bezier.R`, but reshaped to fit
sketchpad's "everything is a `drawable`" pattern rather than copied
as-is. The original `bezier` there was a bare `S7_object` (not a
`drawable`) whose only job was evaluating control points into a `curve`
data frame via Bernstein polynomials; the actual renderable shape was a
separate, more complex class, `bezier_ribbon` (parent `drawable`), which
used an internal `bezier` object's curve as the centerline for a
noise-perturbed perpendicular ribbon offset -- the same offset logic
`ribbon`/`twist` already implement.

Since the request was specifically for "a bezier drawable class," and
`bezier_ribbon` is really a distinct, more complex drawable (bezier path
+ ribbon-style noise offset, conceptually parallel to how `twist` is
"`ribbon` + Brownian-bridge path"), `bezier` was made a `drawable`
directly instead of porting the original two-class split: `parent =
drawable`, control points as `x`/`y` (arbitrary length, not fixed to
four), computed `points` via the same `bernstein()` evaluation. This
makes a plain `bezier` curve immediately usable with `draw()`/`sketch()`
like every other shape, at the cost of always closing into a polygon
(verified: a 2-control-point `bezier` degenerates to a zero-area line,
as expected; a 4-control-point cubic renders as a filled arc closed back
to its baseline). `bezier_ribbon` itself was deliberately left for a
separate future addition (see PLAN.md) rather than folded into this one,
since it's a materially different, more complex shape.

## Building the `fill_*()` texture family and wiring it into `style@fill`

Explored `grid`'s native gradient/pattern/mask support (`grid::pattern()`,
`linearGradient()`/`radialGradient()`, `as.mask()`) as an alternative to
reimplementing pattern geometry by hand the way `ggpattern` does. Built
seven helpers in `R/fill.R` -- `fill_solid()`, `fill_hatch()`,
`fill_crosshatch()`, `fill_stipple()`, `fill_noise()`, `fill_gradient()`,
`fill_vignette()` -- then widened `style@fill` to accept either a plain
colour string or any of their outputs.

**`grid::pattern()`'s tile coordinates are npc-relative to the *target's*
bounding box, not a fixed physical square.** This one fact drove most of
the family's design and is worth remembering in full:

- A tile that's square in that relative sense is a stretched rectangle in
  absolute terms whenever the target's bounding box isn't square, which
  distorts any angle/circularity baked directly into the pattern content.
  Every helper takes an `aspect` argument (the target's bounding-box
  width/height ratio) to correct for this -- but the correction is applied
  two different ways depending on what's being drawn:
  - For directional content that must *tile* correctly (`fill_hatch()`,
    `fill_crosshatch()`), the correction has to go on the **tile's own
    `width`/`height`**, not the content's coordinates -- see the next
    point for why.
  - For content with no periodicity constraint (`fill_stipple()`'s dots,
    `fill_noise()`'s raster, `fill_gradient()`, `fill_vignette()`'s mask),
    the fix is simpler: make the tile physically square via
    `height = spacing * aspect`, then draw the content in plain `npc`
    inside it with no further correction needed.
- **`extend = "repeat"` only tiles seamlessly when a line's local slope is
  exactly 1** (corner-to-corner across the tile). It just translates tile
  copies by whole tile-widths/heights with no blending, so any other slope
  baked into a segment's own coordinates leaves a real mismatch at every
  tile edge ("dashing") -- confirmed by testing that neither longer
  segments nor more copies fixed it, only changing the slope did. Fixed by
  always drawing a plain corner-to-corner diagonal and controlling the
  *rendered* angle entirely via the tile's `width`/`height` ratio instead.
  This is why `fill_hatch()`/`fill_crosshatch()` don't take a raw direction
  vector.
- A raster content grob has the same seamlessness problem in a different
  guise: `fill_noise()` solves it by sampling `ambient::gen_simplex()`'s
  noise on a torus (mapping each tile pixel's `(u, v)` onto a pair of
  circles across the noise function's 4 dimensions) rather than sampling
  directly, making the field exactly periodic. Even so, a faint seam is
  still visible at tile boundaries in practice, independent of
  `resolution` or `interpolate` -- documented as an open, not-fully-solved
  rendering-level caveat rather than silently claimed fixed.

**`grid::mask()` doesn't exist** -- masking is a viewport property
(`as.mask()` + `viewport(mask = ...)`), not a `fill` value the other
helpers could plug in directly. `fill_vignette()` works around this by
nesting a masked viewport inside the pattern tile's own content `gTree`.
Two mask-specific surprises: a bare mask grob whose own fill was a
`radialGradient()` intermittently emitted an "Ignored luminance mask (not
supported on this device)" warning even though the render was visually
correct regardless; being explicit with `as.mask(mask_grob, type =
"alpha")` avoided the warning with an identical result (isolated via a
solid-colour mask grob, which never triggered it, to confirm the cause was
the gradient specifically, not masking in general). True `type =
"luminance"` masks were separately found not to render at all in this
nested-tile context, so only the alpha variant is offered.

**Wiring into `style@fill`:** since `grid::gpar(fill = ...)` already
accepts a colour string or a `"GridPattern"`-inheriting object
interchangeably (every `fill_*()` helper except `fill_solid()` returns an
object sharing that one base S3 class, confirmed across `pattern()`/
`linearGradient()`/`radialGradient()`), `draw()`'s rendering code needed no
changes at all. The only change was widening `style`'s `fill` property to
`S7::new_union(S7::class_character, S7::new_S3_class("GridPattern"))`, with
default `fill_solid("black")` (requiring `fill.R` to move before `style.R`
in `Collate`, which was safe since `fill.R` has no compile-time dependency
on `style`/`drawable`/`points`). Every drawable constructor already
forwards `...` straight to `style(...)`, so `blob(fill = fill_hatch())`
etc. needed no per-drawable changes either.

**Rejected: warning when the active device might not support pattern
fills.** `grid::pattern()`'s own docs note unsupported devices silently
render a transparent fill instead of erroring, which seemed worth
surfacing via `grDevices::dev.capabilities()$patterns`. Implemented, then
reverted after testing revealed the check is unreliable in practice: in
this environment, `dev.capabilities()$patterns` returned `NA` on
`cairo_pdf()`, `pdf()`, *and* `svg()` alike -- not just genuinely
unsupported devices -- with the single exception of Positron's own live
plotting device, which correctly reported
`c("LinearGradient", "RadialGradient", "TilingPattern")`. A warning built
on this signal would false-positive on exactly the standard file devices
users need for real output, which is worse than not warning at all. If
revisited, would need a more reliable signal than `dev.capabilities()`.

## Adding `fill_checker()`, `fill_stripe()`, `fill_scatter()`, `fill_halftone()`

Four more `fill_*()` helpers, each testing the limits of the family's
established tile-shape/aspect-correction technique:

`fill_checker()` was the cheapest addition -- a checkerboard square has no
direction, so there's no analogue of `fill_hatch()`'s corner-to-corner
diagonal requirement; it's just four quadrant rectangles, plus the usual
tile-squaring correction.

`fill_stripe()` (solid alternating bands) turned out *not* to be a simple
reskin of `fill_hatch()`, despite looking like one. A filled band, unlike
a thin hatch line, needs every point along a tile edge to match its
neighbour, not just the points a thin line crosses, so a single diagonal
tile split doesn't tile seamlessly at an arbitrary angle. Solved
differently: a short two-colour `grid::linearGradient()` with hard colour
stops and its own `extend = "repeat"`, which repeats *itself* along its
axis rather than relying on `grid::pattern()`'s tile-copy repetition at
all.

`fill_scatter()` (generalizing `fill_stipple()` to an arbitrary
`drawable`) surfaced two new problems neither circles nor rectangles had:
(1) the usual tile-squaring correction isn't enough for polygon vertex
content -- a `polygonGrob`/`pathGrob` renders as though it inherits the
target's *uncorrected* bounding-box distortion directly, confirmed by
comparing a hand-built circular polygon against an equivalent
`circleGrob` in the same corrected tile (circle stayed circular, polygon
became an ellipse) -- fixed with a second explicit correction on the
unit's own vertex x-coordinates; and (2) repeated (`spacing < 1`) polygon
content can render with visible clipping once the tile actually repeats,
matching `grid::pattern()`'s own documented Cairo clipping-distortion
warning. Fixed by defaulting `spacing = 1` (all copies scattered across
one tile spanning the whole shape) rather than the smaller tiled
defaults used elsewhere.

`fill_halftone()` (`fill_stipple()` with randomized dot radius) is where
problem (2) above turned out to be broader than first thought. Testing
in a completely fresh R session (ruling out session-specific
degradation) found that repeated tiles containing *multiple circleGrobs*
-- not just polygons -- can render individual dots visibly distorted,
across a range of `n`/`radius` combinations with no clean rule for
exactly when it triggers. Unlike `fill_scatter()`, there's no `spacing =
1` escape hatch available: `fill_stipple()`'s whole purpose is a texture
that repeats many small dots across a large shape, which requires
genuine tile repetition. After discussing the scope of the problem,
documented as a known, unresolved rendering risk directly on
`fill_stipple()` (cross-referenced from `fill_scatter()`/
`fill_halftone()`) rather than attempting a fix -- no parameter change
was found to reliably avoid it, and it looks like an upstream `grid`/
Cairo bug rather than something wrong in this package's own code. See
the matching Gotchas entry in `AGENTS.md`.

## `fill_marble()`/`fill_flow()`: sharing `fill_noise()`'s torus machinery

Both are domain-warped variants of `fill_noise()`'s own torus-periodic
field, so its `(theta_u, theta_v)`-mapping and `ambient::fracture()`
sampling code were pulled out into two internal helpers
(`torus_grid()`/`torus_noise()`), reused by all three rather than
duplicated. `fill_marble()` adds a `sin(theta_u * stripes + warp *
turbulence)` band pattern (turbulence itself sampled via `torus_noise()`,
so it stays periodic); `fill_flow()` instead displaces the *final*
field's own `theta_u`/`theta_v` inputs by a second, independent
torus-periodic field before sampling (the classic "fBm of fBm"
domain-warp recipe) -- periodicity survives because displacing a
periodic coordinate by another periodic-in-the-same-variable field still
returns to the same value after one full period. The two displacement
fields needed to be decorrelated from the final field and from each
other, but `ambient::gen_simplex()`'s 4 input dimensions were already
fully spent on the `(theta_u, theta_v)` torus trick, leaving no spare
dimension to offset -- solved by sampling them at `seed + 104729L`/`seed
+ 200003L` instead (arbitrary large primes, not a principled choice,
just unlikely to collide with a user's own nearby seed).

## `fill_scribble()`: a wandering line that has to close the loop on itself

Flagged early on as the hardest candidate `fill_*()` helper to build,
because an open wandering line -- unlike every other helper's content --
can't just stay clear of the tile edge; it has to run to it and pick up
again at exactly the right point on the opposite edge, or the seam shows
as a visible kink. Investigated before committing to an API (see the
conversation that led to this entry for the full exploration): the
working technique turned out to be building each line as a random finite
sum of sine harmonics at *integer* frequencies only, so that over one
full period the sum always returns exactly to its starting value and
slope (to floating-point precision) -- pulled out as the internal
`scribble_lines()` helper. Tested empirically for the Cairo multi-shape
clipping distortion that affects `fill_stipple()`/`fill_scatter()`/
`fill_halftone()`'s closed-shape content under genuine tile repetition;
open polyline content showed no such distortion.

Tried and rejected: reusing `fill_hatch()`'s angle trick
(`hatch_tile_dims()`, rendering an arbitrary angle by reshaping the tile
around content that's a plain corner-to-corner diagonal) to give
`fill_scribble()` an `angle` parameter for free. Reshaping the tile
around a *wandering* line just anisotropically stretched its wiggle
rather than rotating it -- confirmed visually, the line stayed
horizontal under a 30-degree tile shape, just squashed. That trick is
specific to genuinely straight diagonal content; a rotated wandering
line would need the tile built as a rotated/sheared parallelogram with
edge-matching worked out for a curve rather than a segment, which no
technique in this package currently does. Shipped instead with
`direction` restricted to `"horizontal"` or `"vertical"` (a fixed
transpose of the same construction), documented as a known limitation on
`fill_scribble()` itself rather than attempting the harder general case.

## Pre-merge review of the whole `fill_*()` family

Before merging the full fifteen-helper `fill_*()` family, did a naming/
docs consistency pass across all of `R/fill.R` rather than treating each
helper's own review (above) as sufficient in isolation. Found and fixed:

- **Several inherited `@param spacing` docs stated the wrong default.**
  `@inheritParams` copies doc *text* verbatim, including literal
  "Default `X`" wording, with no check that the borrowing function's own
  default actually matches -- see the matching `AGENTS.md` Gotchas entry
  for the general lesson. Concretely, `fill_checker()` (real default
  `0.2`), `fill_stipple()` (`0.3`), `fill_scribble()` (`0.25`),
  `fill_noise()` (`0.5`), and `fill_image()` (`1`) all inherited
  `fill_hatch()`'s (or, for `fill_image()`, `fill_noise()`'s) `spacing`
  doc unchanged, including its `0.1` default text. Fixed by giving each
  its own explicit `@param spacing`; `fill_halftone()` and
  `fill_marble()`/`fill_flow()` needed no separate edit since they
  inherit from `fill_stipple()`/`fill_noise()` respectively and picked up
  the corrected text automatically once those were fixed.
- **`fill_marble()`'s `octaves` doc said "Default `2L`"** (inherited from
  `fill_noise()`) **but its own actual default is `3L`.** Fixed with its
  own explicit `@param octaves`.
- **`fill_stipple()`'s (and, by inheritance, `fill_halftone()`'s)
  `color` doc said "Line colour"**, inherited unchanged from
  `fill_hatch()` -- inaccurate, since both actually fill dots
  (`gpar(col = NA, fill = color)`), not stroke a line. Fixed with an
  explicit `@param color` reading "Dot colour" instead.
- **`fill_stripe()`'s inherited `extend` doc said "Passed to
  `grid::pattern()`"**, but its implementation actually threads `extend`
  through to the *inner* `grid::linearGradient()`; the outer
  `grid::pattern()` call always hardcodes `extend = "repeat"`. Fixed
  with its own explicit `@param extend` describing the real behaviour
  (mirroring how `fill_gradient()` already documented the same pattern
  correctly).
- **`fill_vignette()` had no `extend` parameter at all**, unlike every
  other `fill_*()` helper -- its outer `grid::pattern()` call always
  hardcoded `"repeat"`. Added `extend = "repeat"` to its signature and
  threaded it through, for parity with the rest of the family.
- **`linewidth` was never validated** in `fill_hatch()`,
  `fill_crosshatch()`, or `fill_scribble()`, unlike every other
  parameter in the family. Added a positive-number check to all three.

Considered but deliberately left alone at the time: the family had no
single fixed rule for where a `color`/`color1`/`color2` parameter sits
relative to `spacing`/`aspect` in the argument list (sometimes first,
sometimes after `n`/`seed`). Flagged rather than fixed immediately,
since reordering existing parameters is a real, if low-risk, breaking
change across every signature -- worth confirming was wanted before
touching all of them.

## Standardizing color parameter position across `fill_*()`

Followed up on the item above: adopted **"color parameter(s) always
first"** as the convention, since it was already the majority pattern
(`fill_checker()`, `fill_noise()`, `fill_marble()`, `fill_flow()`,
`fill_gradient()`, `fill_vignette()`, `fill_stripe()` all had `color`/
`color1`/`color2`/`colors` as their very first argument already) and
gives one predictable place to look for the most commonly-tweaked
cosmetic knob across all twelve `fill_*()` helpers that have a colour
parameter. Before making the change, grepped every call site in the
package (`tests/`, `R/`) to confirm nothing calls these functions
positionally -- confirmed, everything already uses named arguments --
so reordering formals was judged safe pre-merge (the package has never
been released).

Applied to the five holdouts: `fill_hatch()`, `fill_crosshatch()`,
`fill_stipple()`, `fill_halftone()`, `fill_scribble()`. All other
parameter order was left untouched (e.g. `linewidth` still stays where
it was, immediately before `spacing`/`aspect` or wherever it already
sat) -- only the color parameter's position moved, since that's the
specific inconsistency being resolved, not a full signature reshuffle.
`fill_halftone()` needed no doc changes (its `color` doc is inherited
from `fill_stipple()` via `@inheritParams`, and roxyger2 orders
`\arguments` by the function's own formal order regardless of the
`@inheritParams`/`@param` declaration order in the source, so moving
just the formal was enough); `fill_hatch()`/`fill_stipple()`/
`fill_scribble()`'s own `@param color` lines were moved to match, for
source readability, though this has no effect on the generated Rd.

## Renaming drawable constructors to a shared `shape_*` prefix

The five concrete drawable constructors (`circle`, `blob`, `ribbon`,
`twist`, `bezier`) plus the trivial `shape` constructor were, before this
change, a set of bare top-level names with no shared prefix -- unlike
the `fill_*()` texture family, nothing in their names signalled "these
all construct a drawable polygon." Renamed to `shape_circle`,
`shape_blob`, `shape_ribbon`, `shape_twist`, `shape_bezier`, and
`shape_raw` (the last replacing bare `shape`, since leaving one function
in the family unprefixed would have undercut the point of the scheme).
Considered `draw_*` (rejected: collides conceptually with the existing
`draw()` rendering generic), `poly_*` (rejected: introduces a new term
not otherwise used in the package's vocabulary), and `drawable_*`
(rejected: accurate but more verbose than `fill_*()`'s own prefix
length). `shape_*` was preferred because "shape" was already the
package's own word for this concept (see `drawable`'s own roxygen docs
pre-rename, and `fill_scatter()`'s docs).

Renaming the S7 class generator variable (e.g. `circle <- S7::new_class(name
= "circle", ...)`) automatically renames both the constructor function and
the class itself, since S7 class generators serve both roles -- so class
names changed too (`"sketchpad::shape_circle"`, not
`"sketchpad::circle"`), including the dispatch class used by
`convert()`'s `method(convert, list(drawable, shape_raw))`. The six
per-drawable source files were renamed to match (`R/circle.R` ->
`R/shape_circle.R`, etc.), with `DESCRIPTION`'s `Collate` field updated
to the new filenames in the same relative order. Every call site across
`R/` (`fill.R`'s `fill_scatter()` default unit, cross-referencing
roxygen `[links]`), `tests/testthat/`, and `README.Rmd` was updated;
`devtools::document()` needed two passes (per the existing "could not
resolve link" gotcha) before all cross-references between the renamed
topics resolved cleanly, and `R CMD check` was re-run to confirm 0
errors/warnings/notes. No deprecation shim was added for the old names,
since the package has never been released.

## Renaming the `points` class to `point_set`

`points <- S7::new_class(name = "points", ...)` (`R/points.R`) was
exported and masked `graphics::points()` on `library(sketchpad)` --
a real problem worth fixing (any script calling `points()` after
`library(sketchpad)` would hit this package's class constructor
instead of the base function), not just a cosmetic naming choice.
Renamed the class/constructor to `point_set` (`R/point_set.R`), after
considering `vertices`, `coords`, and `xy` -- `point_set` was chosen as
the most unambiguous option, prioritizing avoiding any further
collision risk over brevity.

Only the class generator itself needed renaming. Every `drawable`
subclass's computed `points` *property* (`@points`) keeps its original
name unchanged -- a property is accessed via `@`, not a top-level
exported function, so it was never actually responsible for the
masking, and renaming it too would have been a much larger, purely
cosmetic breaking change for no benefit. Updated: every property's
`class = points` -> `class = point_set` and every `points(x = ..., y =
...)` constructor call -> `point_set(x = ..., y = ...)` across
`drawable.R`/`shape_circle.R`/`shape_blob.R`/`shape_ribbon.R`/
`shape_twist.R`/`shape_raw.R`/`shape_bezier.R`; `DESCRIPTION`'s
`Collate` field (`'points.R'` -> `'point_set.R'`); roxygen `[points]`
links that pointed at the class topic (in `drawable.R`/`convert.R`)
reworded to reference the `points` property in prose (backticked, not
linked) plus an explicit `[point_set]` link where the class itself is
introduced. No test changes were needed -- `tests/testthat/` only ever
accessed `@points` as a property, never called the `points()`
constructor directly. `devtools::document()` needed **three** passes
(not the usual two) before the cross-reference `drawable.R` ->
`[point_set]` resolved cleanly; not fully explained, but re-running
`document()` an extra time is a harmless fix if a "could not resolve
link" warning persists past the usual second pass. `R CMD check`
confirmed 0 errors/warnings/notes after the rename, and all 277
existing tests passed unchanged.

## Renaming `point_set` to `xy`, and dropping the polygon-vertex framing

Revisited the earlier `point_set` name once more of the package existed
and it became clear the class carries no inherent polygon/vertex
meaning of its own -- it's just parallel `x`/`y` coordinate vectors, and
several concrete drawables use it for a `"path"` or `"points"` geometry
where "vertices of a polygon" doesn't even apply (`curve_line`,
`curve_raw`, `points_raw`, ...). `point_set` was chosen the first time
specifically to avoid collision risk over brevity (see above), but on
reflection `xy` -- rejected back then only for being *too* terse --
reads fine once the docs stop trying to justify a name via a
now-inaccurate polygon description. Renamed `R/point_set.R` ->
`R/xy.R`; every property/getter's `class = point_set` -> `class = xy`
and every `point_set(x = ..., y = ...)` constructor call -> `xy(x =
..., y = ...)` across all affected files (`drawable.R`, every
`shape_*.R`/`curve_*.R`/`points_raw.R`); `DESCRIPTION`'s `Collate`
field and `_pkgdown.yml`'s reference index updated to match. Reworded
the class's own roxygen title/description (previously "A set of
polygon vertices") to describe it as a generic collection of 2D
locations, with no polygon-specific language; `drawable.R`'s own
description already read generically ("expose a computed `points`
property, of class `xy`") and needed no change. No test changes were
needed, matching the earlier rename -- `tests/testthat/` never called
the constructor directly. `devtools::document()` needed the usual two
passes (not three, this time) for cross-reference links to `[xy]` to
resolve; `devtools::test()` confirmed all 547 existing tests passed
unchanged after the rename.

## Adding a `geometry` property to `drawable`, in preparation for open curves

The first concrete step of the open-curve design (see the "Decided"
entry that lived in `PLAN.md`): `drawable` gained a `geometry` property
(`S7::new_property(S7::class_character, default = "polygon")`),
validated by a new `drawable` `validator` clause requiring `geometry` be
a length-1 string in `c("polygon", "path", "points")`. The three values
follow a dimensional reading -- `"points"` (0D), `"path"` (1D),
`"polygon"` (2D) -- deliberately settled on over an initial `closed`
logical, since a boolean caps the design at two grob kinds and a third
(multi-subpath/hole support) is already a known future candidate; see
`PLAN.md`'s "Multiple sub-paths and holes per drawable" entry, kept
explicitly separate since it needs a `points`-property data-shape change
rather than a new `geometry` value.

`draw()`'s `drawable` and `sketch` methods previously built a
`grid::polygonGrob()` unconditionally; both now call a new internal
`geometry_grob()` helper (`R/draw.R`) that switches on `geometry` to
build `grid::polygonGrob()` (`"polygon"`), `grid::polylineGrob()`
(`"path"`), or `grid::pointsGrob()` (`"points"`) -- `style@fill` is
simply omitted from `gpar()` for the latter two, since only a closed
polygon has an interior to fill. No existing `shape_*()` constructor
exposes `geometry` yet -- reserved for the still-undesigned `curve_*()`
family (see `PLAN.md`).

**Gotcha hit while implementing:** `drawable`'s custom `constructor`
(`function(...) S7::new_object(S7::S7_object(), style = style(...))`)
does not automatically fill in a new property's `default` the way S7's
own auto-generated constructor would -- passing `S7::S7_object()` (a
bare object, not a `drawable` instance) as `new_object()`'s first
argument means *only* explicitly-named properties get set, so `geometry`
came back `NULL` and failed its class check on every single `shape_*()`
call, not just new ones. Confirmed with a minimal reprex outside this
package before concluding it's real S7 behavior, not a mistake specific
to `drawable`. Fixed by adding `geometry = "polygon"` as an explicit
default argument to `drawable`'s own constructor signature and passing
it through to `new_object()` explicitly -- every concrete `shape_*()`
subclass still calls bare `drawable()` internally, so this is invisible
to them; a future `curve_*()` constructor would call `drawable(geometry
= "path")` instead. **Any future property added to `drawable` needs the
same treatment** (an explicit constructor argument/default, not just a
`new_property(default = ...)` spec) as long as `drawable`'s constructor
keeps bypassing the auto-generated one.

Tests exercise `geometry` via `S7::prop<-` (which does trigger
`validate()`, unlike calling `S7::new_object()` directly outside a
constructor, which errors) since no public constructor exposes
`geometry` to pass an invalid value through normal construction yet.
`R CMD check` confirmed 0 errors/warnings/notes, and all 289 tests
passed (10 new: default-geometry coverage across every `shape_*()`,
validator rejection, and `draw()` exercising the `"path"`/`"points"`
branches).

## Adding `curve_bezier()`, the first `curve_*()`/`geometry = "path"` constructor

The first concrete `curve_*()` constructor, proving out the `geometry`
property end to end (see the "Adding a `geometry` property to
`drawable`" entry above). `curve_bezier()` is an open Bezier path: same
Bernstein-polynomial curve as `shape_bezier()`, but constructed from
`drawable(geometry = "path")` instead of bare `drawable()`, so it's
rendered as an open `grid::polylineGrob()` rather than a closed
`grid::polygonGrob()` -- confirmed visually with a dashed, coloured,
thick-stroked curve that stops at its last control point rather than
looping back to its first.

Since `curve_bezier()` and `shape_bezier()` differ *only* in which
`drawable(...)` they build from -- identical `x`/`y`/`n` arguments,
identical points computation, identical validation -- their shared logic
was factored out of `shape_bezier.R` into two internal helpers,
`bezier_curve_points()` (the Bernstein-based points getter) and
`validate_bezier_args()` (the length/positivity checks), rather than
duplicating either across two files. `curve_bezier` itself lives in its
own file, `R/curve_bezier.R`, collated immediately after
`shape_bezier.R` (which still owns `bernstein()` and the two new shared
helpers) in `DESCRIPTION`'s `Collate` field -- this is the established
pattern for genuinely shared internal machinery (see `fill.R`'s
`validate_fill_args()`), balanced against the package's usual "one file
per constructor" convention: the constructors get separate files (since
they're conceptually distinct, differently-named, differently-documented
public APIs), but their identical internals don't.

This also settled a naming question left open in `PLAN.md`: closed
(`geometry = "polygon"`) drawable constructors keep the `shape_*` prefix,
while open (`geometry = "path"`) ones get a new `curve_*` prefix --
visually distinct even where, as here, the underlying geometry is
shared. `AGENTS.md`'s "Rendering model" section (which had gone stale
since the `geometry` property landed, still describing every `drawable`
as unconditionally rendering via `grid::polygonGrob()`) was corrected
alongside this.

`curve_bezier()` doesn't expose `geometry` as a constructor argument --
it's fixed to `"path"` at construction, the same way `shape_bezier()`
doesn't expose it either (fixed to the inherited `"polygon"` default).
`style@fill` is still accepted via `curve_bezier()`'s `...` (forwarded to
`style()` like any other argument) but has no visible effect, consistent
with `drawable`'s existing "`style` is a superset of features not every
`geometry` consumes" design.

`R CMD check` confirmed 0 errors/warnings/notes, and all 313 tests
passed (11 new, in a new `tests/testthat/test-curve.R`), including one
asserting `curve_bezier()` and `shape_bezier()` compute byte-identical
`points` for the same inputs.

## Adding `curve_line()` and `curve_spiral()`

The next two entries in the `curve_*()` family (see `.agents/PLAN.md`),
each needing genuinely new geometry rather than sharing a `shape_*()`
counterpart's computation the way `curve_bezier()` shares
`shape_bezier()`'s.

`curve_line()` is a straight open polyline through an arbitrary number
of control points `(x, y)` (at least two), connected in order. Unlike
every other drawable so far, its `points` getter does no
computation/resampling at all -- it's just `point_set(x = self@x, y =
self@y)` -- so there's no `n` argument, and the constructor is the
shortest in the package. This is the "bare `line`" primitive named in
`PLAN.md`'s "Additional primitive shapes" brainstorm list, generalized
from a single segment (two points) to an arbitrary polyline, since
supporting more than two points cost nothing extra and is strictly more
useful (e.g. a zig-zag or path through several waypoints).

`curve_spiral()` is a new parametric curve: angle sweeps `2 * pi *
turns` radians (`turns` full revolutions) while radius interpolates
linearly from `radius_start` to `radius_end` across the same `n`
evenly-spaced parameter values, giving an Archimedean-style spiral that
grows or shrinks outward. Structurally closest to `shape_circle()`
(centroid + radius + `n`, `cos`/`sin` points), but needed its own file
rather than sharing helpers with it, since the angle range and
non-constant radius are both genuinely new. `radius_start`/`radius_end`
independently non-negative (not just their difference), `turns` strictly
positive (a zero-turn spiral would degenerate to a single point at
`radius_start`), `n` a positive integer -- validated the same way every
other numeric-argument drawable is.

Both fix `geometry = "path"` at construction, matching `curve_bezier()`;
neither exposes `geometry` as a constructor argument. `style@fill` is
accepted via `...` for both (forwarded to `style()`) but has no visible
effect, per `drawable`'s existing `geometry` documentation.

Visual check: a `curve_line()` zig-zag through four points and a
`curve_spiral()` with `radius_start` near zero and `turns = 4` both
rendered as open, unfilled strokes as expected, confirming neither
accidentally closes back to its start the way a `"polygon"`-geometry
drawable would.

`R CMD check` confirmed 0 errors/warnings/notes, and all 339 tests
passed (26 new, appended to `tests/testthat/test-curve.R`) -- geometry
defaults, points computation (including an exact zero-radius start and
angle-sweep check for `curve_spiral()`), argument validation, `draw()`
rendering without error, and stroke-styling acceptance for both.

## Adding `lineend`/`linemitre` to `style()`

Revisited the `lineend`/`linemitre` deferral noted when `linetype`/
`linejoin` were first added (see that entry above) and again when
`curve_bezier()` landed, this time with `curve_line()` in hand:
`curve_line()` is a straight polyline, so unlike `curve_bezier()`'s
smoothed curve it can produce genuinely sharp interior vertices, and
(like every `"path"`-geometry drawable) it has real free endpoints. A
quick `grid` experiment confirmed both properties have a real, visible
effect at these features: `lineend` (`"round"`/`"butt"`/`"square"`)
visibly changes the cap shape at a path's free ends, and `linemitre`
(paired with `linejoin = "mitre"`) determines whether a sharp interior
vertex renders as a full mitred spike or gets truncated to a bevel once
the corner is sharper than the limit allows -- both only visible at a
sufficiently thick `linewidth`, the same threshold that already applied
to `linejoin`. That crossed the bar the package used to justify
`linetype`/`linejoin` in the first place (a demonstrated, concrete visual
effect rather than API completeness for its own sake), so both were
added.

Implementation exactly mirrors `linejoin`: `lineend` is a validated
string enum (`"round"`/`"butt"`/`"square"`, default `"round"`);
`linemitre` is numeric, validated only for `>= 1` (matching
`grid::gpar()`'s own requirement), default `10` (matching `grid::gpar()`'s
own default) rather than independently re-validated beyond that, the
same leniency already given to `linetype`. Both are forwarded in
`geometry_grob()`'s `"polygon"` and `"path"` branches alongside
`linejoin`/`linetype`, omitted from `"points"` (no line to cap or mitre)
-- including them in the `"polygon"` branch is harmless even though a
closed polygon has no exposed free endpoint and, in practice, no mitred
corner sharp enough to hit the default limit; this matches `linejoin`'s
own existing precedent of applying uniformly across both stroked
geometries rather than special-casing which geometry each sub-property
"really" affects.

`R CMD check` confirmed 0 errors/warnings/notes, and all 354 tests
passed (15 new) -- default values, valid/invalid `lineend`, valid/invalid
`linemitre`, non-scalar rejection for both, and `curve_line()` accepting
and rendering both without error at a thick `linewidth` with
`linejoin = "mitre"`.

## Adding `curve_scribble()`, promoting `scribble_lines()` to a public path generator

The last item left in `.agents/PLAN.md`'s `curve_*()` family write-up:
`curve_scribble()` draws a single random wandering line -- a finite sum
of sine harmonics -- as a standalone open curve, reusing
`fill_scribble()`'s internal `scribble_lines()` generator (`R/fill.R`)
rather than duplicating its harmonic-construction logic. "Promoting" this
helper meant giving it a second, public-facing consumer, not exporting
`scribble_lines()` itself -- it stays `@noRd`, the same treatment already
given to `shape_bezier.R`'s shared `bernstein()`/`bezier_curve_points()`/
`validate_bezier_args()` helpers.

`scribble_lines()` returns `(along, across)` coordinates in `[0, 1]`-ish
form (`along` runs `0` to `1`; `across` wobbles around a random baseline
near `0.5`), designed for `fill_scribble()`'s tile-repetition use case --
periodicity at the two `along` ends is what lets tiles join seamlessly.
That periodicity is irrelevant to a single standalone curve, but harmless
to keep, so `curve_scribble()`'s `points` getter calls
`scribble_lines(n_lines = 1, ...)` and rescales the one resulting line
into an arbitrary `x`/`y` + `width`/`height` bounding box on the sketch's
own coordinate plane, rather than tiling it inside a fill pattern.
`direction` (`"horizontal"`/`"vertical"`) controls the `along`/`across`
to `x`/`y` mapping, mirroring `fill_scribble()`'s own `direction`
argument and its same rationale (see that function's "Known limitation"
docs section -- unaffected by this change, since `curve_scribble()`
doesn't attempt an arbitrary-angle version either).

Naming diverged slightly from `fill_scribble()`'s own argument names:
`resolution` (points sampled along the line) is called `n` here instead,
matching every other `curve_*()`/`shape_*()` constructor's convention
rather than `fill_scribble()`'s -- the constructor forwards it to
`scribble_lines()`'s `resolution` parameter internally, so this is a
public-API-only rename, not a change to the shared helper's own
signature.

Lives in its own file, `R/curve_scribble.R`, collated after
`curve_spiral.R` (grouped with the rest of the `curve_*()` family) even
though its logic is shared with `fill.R` -- it still depends on
`drawable`, which loads after `fill.R` in `Collate`, so it can't live in
`fill.R` itself the way `scribble_lines()` does.

Visual check: a horizontal and a vertical `curve_scribble()`, in
different bounding boxes side by side, both rendered as genuine
wandering open curves (not tiled/repeating), confirming the rescaling
and `direction` mapping both work as intended.

`R CMD check` confirmed 0 errors/warnings/notes, and all 370 tests
passed (13 new, appended to `tests/testthat/test-curve.R`) -- geometry
default, agreement with a direct `scribble_lines()` call for both
directions, seed-reproducibility, argument validation, `draw()`
rendering without error, and stroke-styling acceptance.

## Adding `curve_raw()` and `points_raw()`

Rounded out `shape_raw()` into a three-member "raw" family, one per
`geometry` value: `curve_raw()` is the `"path"`-geometry analog,
`points_raw()` the `"points"`-geometry one. Both are close to a literal
copy of `shape_raw()`'s own constructor/validator/points-getter (`x`/`y`
supplied directly, no computation), differing only in which
`drawable(geometry = ...)` they build from -- following the same
"differ only in `geometry`" pattern already used for
`shape_bezier()`/`curve_bezier()`, except here there's no shared
computation worth factoring into a common helper (the getter is a
one-liner), so each constructor just repeats it inline rather than
introducing a shared internal for three near-identical one-line
getters.

**`curve_raw()` vs. `curve_line()`.** Deliberately kept distinct from
`curve_line()` rather than merged into it: `curve_line()` requires at
least two control points (a single-point "line" isn't meaningful) and is
meant as a hand-written primitive; `curve_raw()` places no minimum on
`length(x)` at all, matching `shape_raw()`'s own leniency, since its
primary role -- like `shape_raw()`'s -- is as a `convert()` target for
"freezing" an arbitrary drawable's computed points (any `"path"`-geometry
drawable, in this case), where a 0- or 1-point result should still be
constructible even if rarely useful in practice. No `convert()` method
actually targets `curve_raw()`/`points_raw()` yet -- see the new
`.agents/PLAN.md` entry, "`convert()` targets for
`"path"`/`"points"`-geometry drawables".

**`points_raw()` is the first concrete `geometry = "points"`
constructor.** `geometry = "points"` had been reserved since the
`geometry` property was first added (see that entry above), on the
dimensional reading `"points"`(0D)/`"path"`(1D)/`"polygon"`(2D), but
nothing had exposed it until now. Its docs are explicit that every
line-related `style` property (`linewidth`/`linetype`/`linejoin`/
`lineend`/`linemitre`) and `fill` are inert for this geometry, per
`geometry_grob()`'s existing `"points"` branch (`R/draw.R`, unchanged by
this work) -- only `style@color` has any visible effect, as the marker
colour.

Both fix their `geometry` at construction (not exposed as a caller-facing
argument), matching every other concrete drawable. Neither needed new
validator logic beyond `shape_raw()`'s own single check (`x`/`y` equal
length) -- confirmed both accept zero-length and single-point `x`/`y`
without error, unlike `curve_line()`'s stricter minimum.

Placed in `DESCRIPTION`'s `Collate` immediately after `shape_raw.R`
(mirroring `shape_bezier.R`/`curve_bezier.R`'s adjacency, since these
three are directly-parallel "raw" constructors) rather than grouped with
the rest of the `curve_*()` family earlier in the file.

Visual check: a `curve_raw()` zig-zag and a `points_raw()` scatter of
unconnected markers, side by side, both rendered as expected -- the path
open and unfilled, the points as separate circles with no connecting
line.

`R CMD check` confirmed 0 errors/warnings/notes, and all 388 tests
passed (18 new, in a new `tests/testthat/test-raw.R`) -- geometry
defaults, points computed directly from input, zero-/single-point
construction, `x`/`y` length validation, `draw()` rendering without
error, and stroke/marker-colour styling acceptance for both.

## Porting `bezier_ribbon` from series-lissajous as `shape_bezier_ribbon()`

Ported `series-lissajous`'s `bezier_ribbon` -- a ribbon whose backbone is
a cubic Bezier curve rather than a straight line ([shape_ribbon]) or
Brownian bridge ([shape_twist]) -- as `shape_bezier_ribbon()`, per the
naming note left in `.agents/PLAN.md` (matching the `shape_*` prefix
convention rather than the source repo's bare `bezier_ribbon`).

**Structure mirrors `shape_twist`, not `shape_ribbon`.** Like
`shape_twist`, it exposes a computed `path` property (the raw backbone,
here `bezier_curve_points()` through `(x, y)`, two control points, and
`(xend, yend)`, reusing the helper factored out for
`shape_bezier()`/`curve_bezier()` rather than duplicating Bernstein-basis
evaluation) separately from `points` (the noise-perturbed, tapered
outline built from that backbone) -- `shape_ribbon` has no equivalent
split since its backbone is a trivial `seq()`, not worth its own
property.

**Control point naming.** The source repo used `xctr_1`/`yctr_1`/
`xctr_2`/`yctr_2`; renamed to `x_ctrl1`/`y_ctrl1`/`x_ctrl2`/`y_ctrl2` to
read more clearly at a call site and avoid the ambiguous abbreviation
`ctr` (centre vs. control).

**Dropped the source's unused `smooth` argument.** The original
`bezier_ribbon` declared a `smooth` property/constructor argument
(copied from `shape_twist`, where it drives `smooth_bridge()`'s
averaging passes) but never referenced it anywhere in its own `bezier`
or `points` getters -- a Bezier curve is deterministic, so there's no
random path to smooth. Confirmed by inspection this was dead weight
carried over from copy-pasting `shape_twist`'s scaffolding rather than
intentional, so it was not ported.

**Perpendicular-offset direction still uses the endpoint chord, not the
local tangent.** Like `shape_ribbon`/`shape_twist` before it, the width
offset at each point is perpendicular to the straight line from `(x, y)`
to `(xend, yend)` (`dx`/`dy` computed once, not re-derived along the
curve) rather than the Bezier curve's own local tangent direction. This
matches the source repo's behavior exactly and keeps the outline
self-consistent with its sibling shapes, but means a strongly-curved
backbone's ribbon can look slightly asymmetric near sharp bends -- not
treated as a bug to fix here, since it reproduces the ported behavior
faithfully; revisit only if a real sketch's visual output demands a
tangent-following offset.

Placed in `DESCRIPTION`'s `Collate` immediately after `shape_bezier.R`
(per the `.agents/PLAN.md` note), since it depends only on `drawable`
and `shape_bezier.R`'s internal `bezier_curve_points()` helper, not on
`curve_bezier.R`.

Visual check: a curved, noise-tapered ribbon with visibly distinct
endpoints and a smooth S-shaped backbone rendered as expected.

`R CMD check` confirmed 0 errors/warnings/notes, and all 398 tests
passed (10 new, in a new `tests/testthat/test-bezier-ribbon.R`) --
backbone endpoints matching the supplied control points, a zero-width
ribbon collapsing exactly onto its backbone (forward path then reversed
path), and scalar-argument validation.

## Adding `color_alpha`/`fill_alpha` opacity control to `style()`

Added independent stroke/fill opacity to `style()`, closing the
"Alpha/opacity in `style`" candidate-features item.

**The key constraint driving the design: `grid::gpar()` can't decouple
stroke opacity from fill opacity.** `gpar()` has a single `alpha`
argument that applies uniformly to everything a grob draws -- passing it
would couple `color_alpha` and `fill_alpha` together on the same
`polygonGrob()`, defeating the point of having two independently-settable
properties (mirroring the existing `color`/`fill` split). Instead, each
alpha is baked directly into its own colour string via
`grDevices::adjustcolor(color, alpha.f = ...)` before either reaches
`gpar()`, via a new internal `apply_alpha()` helper in `R/draw.R`
(a no-op at `alpha == 1`, so the common/default case skips
`adjustcolor()` entirely). `gpar()`'s own `alpha` argument is never
passed, staying at its implicit default of `1`, at every call site.

**`adjustcolor()`'s behavior confirmed empirically before committing to
this approach** (session console): it *multiplies* through any alpha
channel already present in the input string (`adjustcolor("#FF000080",
alpha.f = 0.5)` gives `"#FF000040"`, i.e. 0.5 x the existing ~0.502
alpha, not a flat override) -- so a caller who already passed a
translucent hex colour to `color`/`fill` composes correctly rather than
being clobbered. It also returns a fully-transparent colour for `NA`
input without erroring, so `fill = fill_none()` stays invisible
regardless of `fill_alpha`. But it **errors** outright when given a
`GridPattern` object (confirmed via `adjustcolor(fill_hatch(), alpha.f =
0.5)`) -- there is no way to apply a scalar opacity to an arbitrary,
already-built pattern/gradient grob this way.

**`fill_alpha` is therefore silently inert whenever `style@fill` is a
`GridPattern`** (i.e. built by any `fill_*()` helper except
`fill_solid()`/`fill_none()`), guarded in `geometry_grob()` by
`is.character(sty@fill)` before calling `apply_alpha()` on it at all.
This was a deliberate choice to follow this package's existing
precedent for style properties that don't universally apply (`fill`
itself already has no effect for `"path"`/`"points"`-geometry
drawables; `lineend`/`linemitre` are already inert for some geometries)
-- documented in `fill_alpha`'s own `@param` text, with no warning or
error, rather than rejecting the combination at `style()` construction
time or warning at draw time. Both alternatives were considered and
rejected: erecting a cross-property validation rule would be a new kind
of coupling this package's `style` validator has never needed before
(every existing check is local to one property), and a draw-time
warning has no precedent among the package's several other
geometry-conditional properties either.

**Range chosen as `[0, 1]` closed**, not `fill_noise()`'s existing
`(0, 1]` -- `0` is a legitimate "fully invisible" value at the `style`
level (e.g. a fully transparent stroke while keeping a visible fill, or
vice versa), unlike `fill_noise()`'s own `alpha` where `0` would be a
pointless no-op fill.

`color_alpha` is forwarded in all three `geometry_grob()` branches
(`"polygon"`, `"path"`, `"points"`), matching `color` itself already
applying everywhere; `fill_alpha` only matters for `"polygon"`, where
`fill` itself is used.

Visual check: two overlapping circles with independent `color_alpha`
(one solid black outline, one faint outline) and matching `fill_alpha`
blended visibly darker in the overlap region, as expected; a
`fill_hatch()`-filled circle with `fill_alpha = 0.2` rendered with fully
opaque hatch lines and no error, confirming the silent-inertness path.

`R CMD check` confirmed 0 errors/warnings/notes, and all 419 tests
passed (23 new, across `tests/testthat/test-style.R` and
`tests/testthat/test-draw.R`) -- defaults, full-range acceptance,
out-of-range/non-scalar rejection, `apply_alpha()`'s no-op/alpha-baking/
multiply-through behavior, and `draw()` not erroring on either a solid
or pattern fill combined with the new properties.

## Adding dedicated tests for `shape_circle`/`shape_blob`/`shape_ribbon`/`shape_twist`

These four `drawable` subclasses previously had no tests of their own
(test coverage was concentrated on `shape_bezier` plus `sketch`-level
concerns) -- added one file each
(`tests/testthat/test-circle.R`/`test-blob.R`/`test-ribbon.R`/
`test-twist.R`), following the pattern already established by
`test-bezier.R`/`test-bezier-ribbon.R`: geometry correctness via a
degenerate-parameter collapse (radius/width set to a value that makes
the computed `points` reduce to something exactly checkable), seed
reproducibility, and scalar-argument validation.

**Degenerate cases used to pin down geometry, one per shape:**

- `shape_circle`: `radius = 0` collapses every point onto the centroid;
  separately, every point at a positive radius is confirmed to lie at
  exactly that Euclidean distance from the centroid (not merely "looks
  circular"), and the outline is confirmed to close exactly (first point
  equals last, since `seq(0, 2 * pi, length.out = n)` includes both
  endpoints).
- `shape_blob`: `range = 0` collapses every point onto a circle at the
  mean `radius` -- confirmed via the same Euclidean-distance check as
  `shape_circle`, verifying `ambient::normalize()`'s degenerate
  zero-width target range behaves as expected (maps every input to the
  single target value, not `NaN`) rather than just asserting on
  appearance.
- `shape_ribbon`/`shape_twist`: `width = 0` collapses the outline onto
  the forward-then-reversed backbone (mirroring the check already used
  for `shape_bezier_ribbon`). For `shape_twist` specifically, `width`
  also scales the Brownian-bridge *displacement itself*
  (`smooth_bridge(..., scale = 0.1 * self@width, ...)`), so `width = 0`
  collapses `path` to the exact straight line regardless of `smooth`
  or `seed` -- confirmed directly, then used as the base case for the
  outline-collapse check exactly as with `shape_ribbon`.

**Noticed while writing these tests, fixed separately (see next
entry):** `shape_twist`'s validator didn't check `smooth` at all.

`R CMD check` confirmed 0 errors/warnings/notes, and all 486 tests
passed (67 new: 13 for `shape_circle`, 18 for `shape_blob`, 17 for
`shape_ribbon`, 19 for `shape_twist`).

## Fixing `shape_twist`'s missing `smooth` validation

`shape_twist`'s validator checked
`x`/`y`/`xend`/`yend`/`width`/`n`/`frequency`/`octaves`/`seed`, but never
validated `smooth` at all -- no length-1 check, no non-negativity check,
despite `smooth` counting down in a `for (i in 1:smooth)` loop
(`smooth_bridge()`, `R/shape_twist.R`) that would behave oddly for a
negative or non-integer value (`1:smooth` counts *down* from `1` for a
negative `smooth`, running the smoothing loop body with descending,
partly-negative indices rather than erroring or no-op'ing). Added the
same two checks every other non-negative numeric argument in this
package gets (`length(self@smooth) != 1`, `self@smooth < 0`), plus a
`smooth = 0` acceptance test (confirming `0` -- i.e. no smoothing passes
-- is explicitly valid, not just the boundary of a `< 0` rejection) and a
non-scalar-`smooth` rejection test, both in `tests/testthat/test-twist.R`
alongside the shape's other tests added just prior. `@param smooth`'s
docs updated to state the non-negativity requirement, matching every
other such parameter's docs in the package.

`R CMD check` confirmed 0 errors/warnings/notes, and all 489 tests
passed (3 new).

## Adding `convert()` targets for `curve_raw`/`points_raw`

`method(convert, list(drawable, shape_raw))` always freezes a drawable's
points into a `"polygon"`-geometry `shape_raw`, regardless of the source
drawable's own `geometry` -- silently closing/filling an open
`"path"`-geometry drawable (e.g. `curve_bezier()`/`curve_scribble()`) or
flattening a `"points"`-geometry one into a filled outline. Added two
more `convert()` methods, `method(convert, list(drawable, curve_raw))`
and `method(convert, list(drawable, points_raw))`, so a drawable can be
frozen into its `"path"`/`"points"`-geometry analog directly instead,
closing out the `.agents/PLAN.md` item left open when `curve_raw()`/
`points_raw()` were first added.

Both are near-identical to the existing `shape_raw` method (extract
`from@points`, build the target constructor from it, then copy over
`from@style`) -- differing only in which raw constructor they call.
Deliberately **not** merged into one shared internal helper: three
near-identical five-line method bodies were judged clearer than a
helper parameterized by which of three constructors to call, especially
since S7's `method<-` assignment (not a plain function call) is the
outer shape each one needs regardless.

**Dispatch is on `from`'s class only, `to`'s value is unconstrained.**
Like the existing `shape_raw` method, these don't require `from` to
already have the target geometry -- converting a `"polygon"`-geometry
`shape_circle()` to `curve_raw`/`points_raw()` works exactly the same
way as converting an already-`"path"`-geometry `curve_bezier()`, since
all three methods only ever read `from@points` (the *computed* outline,
already flattened to plain coordinates regardless of source geometry)
and never inspect `from@geometry` itself. This is intentional -- it's
what lets any drawable be frozen into any of the three geometries on
request, not just its own.

Visual check: converting a `shape_blob()` to `curve_raw` and drawing it
rendered the same wobbly outline as an open, unfilled stroke -- visibly
missing the closing edge between its last and first points, confirming
the geometry actually changed rather than just relabeling the same
closed shape.

`R CMD check` confirmed 0 errors/warnings/notes, and all 502 tests
passed (13 new, in `tests/testthat/test-drawable.R` alongside the
existing `shape_raw` convert test) -- correct target class/geometry for
each, points/style preserved exactly, and conversion working regardless
of `from`'s own starting geometry.

## Adding runnable `@examples` across the `drawable`/`fill_*()` family

Closed the `.agents/PLAN.md` "Runnable `@examples`" item: every exported
function that gets its own `.Rd` page (every `drawable` subclass, the
core structure classes/generics, and all sixteen `fill_*()` helpers --
34 exports in total) previously had either no `@examples` block at all
or, in `sketch()`'s single existing case, one wrapped in `\dontrun{}`.
Added one runnable example per export instead.

**Chose genuinely runnable examples over `\dontrun{}`, including for
the pre-existing `sketch()` example.** `\dontrun{}` was the only
established precedent in the package, presumably out of caution around
`draw()` opening a graphics device, but that caution turned out to be
unfounded: `R CMD check`'s example-running already provides a device
(a recording one, not an interactive window), so calls to
`grid::grid.newpage()`/`grid::grid.draw()` inside `draw()` run cleanly
with no window ever appearing. Verified every new example actually
executes with `devtools::run_examples(run_dontrun = TRUE, run_donttest
= TRUE)` against the freshly `devtools::document()`-ed package, not
just visual inspection of the roxygen source.

**Every example that needs a seed uses an explicit `L`-suffixed
integer** (e.g. `seed = 4821L`), not a bare double -- every `seed`
property across the package is typed `S7::class_integer`, so
`shape_blob(seed = 4821)` (no `L`) fails construction with `@seed must
be <integer>, not <double>`, caught by actually running the drafted
examples before committing them rather than assuming the bare-number
form would coerce.

**Kept each example minimal and self-contained** -- one or two calls
per function, usually `draw(shape_*(...))`/`draw(shape_circle(fill =
fill_*(...)))`, rather than a full multi-shape sketch for every single
helper (that broader composition is already what `sketch()`'s own
example and `README.Rmd` demonstrate). `fill_image()`'s example builds
a trivial 2x2 in-memory colour matrix rather than reading a real image
file, since the function itself deliberately has no image-file I/O
dependency (see its own docs) and an example shouldn't introduce one
either. `fill_stipple()`'s and `fill_halftone()`'s examples exercise
the documented "Known rendering risk with multiple dots" code path
(multi-circle pattern tiles) on purpose, since avoiding it would leave
exactly the functions with a known caveat undocumented by example; both
ran without erroring in this session, consistent with the existing
docs framing the risk as a rendering-fidelity concern, not a hard
failure.

`devtools::document()` (run twice, per the established "could not
resolve link" gotcha -- unneeded here since no new cross-references
were introduced, but run anyway for safety) regenerated all 34 affected
`.Rd` files with no warnings, and `devtools::run_examples()` confirmed
every one of the resulting 35 example blocks (34 new plus `sketch()`'s
updated one) executes end to end with no errors.

## Factoring noise sampling into a `noise_field` class

`shape_blob()`'s radius perturbation, `shape_ribbon()`/`shape_twist()`'s
width modulation, and `shape_bezier_ribbon()`'s width modulation all
independently called `ambient::fracture(noise = ambient::gen_simplex,
fractal = ambient::fbm, ...) |> ambient::normalize(to = ...)` against
their own `frequency`/`octaves`/`seed` properties -- the same ~10-line
block copied four times, with the noise/fractal functions hardcoded
rather than configurable. Prompted by a question about whether these
four constructors could be reframed as "a simpler base shape with a
distortion applied," which they structurally are for this one part of
each of them.

**What was built.** A standalone `noise_field` S7 class (`R/noise_field.R`,
no `drawable` parent) bundling `noise`/`fractal` (functions, default
`ambient::gen_simplex`/`ambient::fbm`) and `frequency`/`octaves`/`seed`,
plus a `noise_sample(field, x, y, to)` S7 generic wrapping the
fracture-then-normalize call. Each of the four constructors above now
takes a `distortion = noise_field()` property instead of bare
`frequency`/`octaves`/`seed` arguments, and calls `noise_sample()` in
its `points` getter. `shape_twist()` is the one wrinkle: it keeps its
own `seed` property, since that seed drives its Brownian-bridge *path*
(`smooth_bridge()`, unrelated to `ambient`/`noise_field`) -- only its
*width* modulation moved to `distortion`. Defaults were chosen so
`noise_field()`'s own defaults exactly reproduce each constructor's old
`frequency = 1`/`octaves = 2L`/`seed = 1L` defaults, so no shape's
default appearance changed.

**What was rejected: one `distortion` class covering everything.** The
original framing considered a single "distortion" abstraction applied
uniformly across `shape_*()`/`curve_*()`/`points_*()`. This doesn't hold
up structurally: `noise_field` is a *scalar field sampled at arbitrary
`(x, y)` positions*, but `shape_twist()`'s path perturbation is a
*point-count-indexed vector generator* with no spatial position
involved at all (a Brownian bridge, built from `stats::rnorm()`, not
`ambient`). Forcing both into one class's interface would mean either an
awkward union of unrelated argument shapes or a class that's really just
"pick which noise implementation to use," so the two were kept separate:
`noise_field` now exists; a parallel `noise_bridge` for the path case is
deferred (see `.agents/PLAN.md`) until `shape_twist()`'s path generator
gets a second real consumer (a future `curve_twist()`) to validate the
interface against, rather than being designed from one call site.

**Breaking change, deliberately not mitigated.** Every caller of
`shape_blob(frequency = ..., octaves = ..., seed = ...)` (etc.) needed
updating to `shape_blob(distortion = noise_field(seed = ...))` --
including every test in `tests/testthat/` that constructed one of these
four shapes with a non-default noise argument. This package has no
external consumers yet (see its own intro in `AGENTS.md`); the explicit
decision was to take the breaking change now, while the cost is limited
to this repo's own tests, rather than design around backward
compatibility for hypothetical future callers.

## Adding `noise_bridge` for `shape_twist()`'s path

Once `noise_field` had two real width-noise consumers beyond
`shape_blob()` (`shape_ribbon()`/`shape_twist()`, plus
`shape_bezier_ribbon()` shortly after), its interface was considered
validated enough to build the second, previously-deferred noise class:
`noise_bridge`, covering `shape_twist()`'s *path* -- the
`smooth_bridge()`-generated Brownian bridge (`stats::rnorm()`-based, no
`ambient` involvement) that displaces its backbone away from a straight
line, as distinct from the `distortion` `noise_field` that already
modulated its *width*.

**What was built.** `R/noise_bridge.R`: a `noise_bridge` class
(properties `smooth`/`seed`, no `ambient` dependency) plus a
`noise_sample(field, n, scale)` method -- deliberately a different
signature from `noise_field`'s `noise_sample(field, x, y, to)` method,
since a Brownian bridge has no spatial position to sample at, just a
point count. `smooth_bridge()` itself (previously a bare internal helper
living in `R/shape_twist.R`) moved into `R/noise_bridge.R` alongside its
new class wrapper, since it's now exclusively that class's
implementation detail. `shape_twist()` gained a `path_distortion =
noise_bridge()` property (replacing its old bare `smooth`/`seed`
arguments) alongside its existing `distortion = noise_field()` property
-- two independent distortion properties on one shape, one per noise
class, which is exactly the outcome the original "one unified
`distortion` class" idea was rejected in favor of.

**The two-axis wrinkle.** `shape_twist()`'s path needs two independent
displacement vectors (x and y), generated from the same `smooth`
setting but different seeds (the original code called `smooth_bridge()`
twice, with `seed` and `seed + 1`). Rather than growing `noise_bridge`'s
own interface to return both axes at once (which would make it a
two-purpose class, path-shaped rather than a generic "sample a
distortion" one), `shape_twist()`'s `path` getter calls `noise_sample()`
twice: once against `self@path_distortion` directly, once against a
second `noise_bridge` built inline with the same `smooth` and
`seed + 1L`. This keeps `noise_bridge`/`noise_sample()`'s contract
identical to `noise_field`'s (one object, one sampled vector) at the
cost of one inline object construction in the caller -- judged the
better tradeoff than a bespoke two-output method only `shape_twist()`
would ever use.

**Verified visually and via tests**: `shape_twist()`'s rendered output
is unchanged at the same seed/smooth defaults (`noise_bridge()`'s
defaults reproduce the old `smooth = 3L`/`seed = 1L` exactly), new
`tests/testthat/test-noise-bridge.R` covers `noise_bridge`/`noise_sample()`
directly, and `devtools::check()` stayed clean (0 errors/warnings/notes)
throughout.

## Adding `curve_twist()`, `noise_bridge`'s second consumer

With `noise_bridge` built for `shape_twist()`'s path, the natural next
step (flagged when the class was first designed) was giving it a second
consumer to validate the interface: `curve_twist()`, an open, unfilled
wandering path with no ribbon width at all -- `shape_twist()`'s path
alone, `geometry = "path"` instead of a closed ribbon polygon.

**Sharing rather than duplicating.** `shape_twist()`'s `path` property
getter (backbone + two independent seed-offset `noise_bridge` draws, one
per axis) was factored out into an internal `twisted_path_points()`
helper in `R/shape_twist.R`, used by both `shape_twist()`'s own `path`
getter and `curve_twist()`'s `points` getter -- the same
"factor a helper into the file it originated in, collate the new
constructor immediately after it" pattern already established by
`shape_bezier.R`/`curve_bezier.R`'s `bezier_curve_points()`. No changes
were needed to `noise_bridge`/`noise_sample()` themselves to support
the new consumer -- the interface (a point count `n` and a `scale` in,
a displacement vector out) was already general enough.

**Naming: `scale` instead of `width`.** `shape_twist()`'s `width`
argument does double duty (scales the Brownian-bridge path displacement
*and* the ribbon's taper), but `curve_twist()` has no ribbon, so
carrying the name `width` over would be misleading. `curve_twist()`
instead exposes the same underlying displacement-amplitude parameter as
`scale`, passed straight through to `twisted_path_points()`'s own
`width` formal (which keeps that name internally, since it's shared
with `shape_twist()`'s actual width-scaled call site).

Verified `curve_twist()`'s points are identical to `shape_twist()`'s own
`path` property for matching arguments (a direct test of the shared
helper), and `devtools::check()` stayed clean throughout.

## Adding a `canvas` class for sketch-level background/framing

Picked up the "Canvas/background concept" item from `.agents/PLAN.md`:
`draw()` had no way to paint a background behind a sketch's shapes, or to
give a sketch its own remembered `xlim`/`ylim` frame -- every `draw()`
call recomputed axis limits from whatever shapes were present unless the
caller passed `xlim`/`ylim` by hand each time.

**A `canvas` value class, not `sketch()`-constructor arguments.** Settled
the open design question (should `sketch()` itself do canvas/background
setup, or should a separate concept own it?) in favor of a small `canvas`
class -- `background` (any `style@fill`-style value: plain colour or
`fill_*()` output), `xlim`/`ylim` (each `NULL` or length-2 numeric), and
`clip` (logical) -- stored as `sketch`'s own `canvas` property, default
`canvas()`. This mirrors `style`'s relationship to `drawable` rather than
folding flat properties onto `sketch`: `sketch()` stays pure data with no
device-level side effects at construction time (still composable via `+`
across multiple lines/calls, still re-drawable to multiple devices), and
all rendering — including painting the background — happens only inside
`draw()`, exactly as it already did for every other style property.
`draw(drawable)` (the single-shape method) is unaffected; canvas is a
sketch-level concept only.

**Clipping is opt-in, not automatic.** `xlim`/`ylim` alone only fix the
viewport's coordinate scale, matching `draw()`'s pre-existing `xlim`/
`ylim` argument behavior exactly -- content outside that range still
renders in full by default. Deliberately did not make `canvas`'s
`xlim`/`ylim` clip by default: shapes built from a `noise_field`/
`noise_bridge` (`shape_blob()`, `shape_twist()`, ...) can have somewhat
unpredictable extents, and silently cropping part of one away is a worse
failure mode than a visibly overflowing shape, which is an obvious cue to
fix the sketch's own parameters. A separate `clip` logical (`FALSE` by
default, mapped onto `grid::viewport()`'s own `clip = "on"`/`"off"`, never
`"inherit"`) opts into hard clipping -- most useful once `background` is
also set to something other than `fill_none()`, since otherwise an
overflowing shape visibly bleeds past an opaque background's own edge
onto the bare page, undermining the point of having a background at all.
`clip` has no visible effect whenever `xlim`/`ylim` are both left `NULL`,
since `draw()` then computes them from the sketch's own shapes, which by
construction never exceed that range.

**`draw(sketch)`'s xlim/ylim precedence.** An explicit `xlim`/`ylim`
passed directly to `draw()` still takes precedence over `canvas`'s own
stored values, which in turn take precedence over the auto-computed
range from the sketch's shapes -- preserving every pre-`canvas()` call
site unchanged while letting a sketch remember its own frame as the new
middle tier.

**Two S7 property-default gotchas hit while building this, both now
worth remembering generally:**

- **`new_property(class = class_numeric, default = NULL)` does not store
  a literal `NULL`.** S7 treats a property spec's bare `default = NULL`
  as "no default was given," not as the value `NULL` -- for `xlim`/
  `ylim`, this silently substituted a zero-length `numeric()`/`integer()`
  instead, which then failed `canvas`'s own "must be `NULL` or length 2"
  validator every time (a `numeric(0)` is neither). Fixed by declaring
  `xlim`/`ylim` as `S7::class_any` instead of `S7::class_numeric` --
  `class_any` has no zero-length substitution behavior, so `default =
  NULL` is stored as a genuine `NULL` -- and moving the type check
  (`is.numeric(...)`) into the validator itself alongside the existing
  length check, since the property class no longer enforces it.
- **A constructor argument cannot share a name with the S7 class/
  constructor function used in its own default expression.** `sketch`'s
  new `canvas` argument, defaulting to bare `canvas()`, failed at call
  time with `"promise already under evaluation: recursive default
  argument reference"` -- the argument's own name shadows the `canvas`
  class within the constructor's evaluation frame, so the unqualified
  call resolves to the argument's own unforced promise instead of the
  class constructor. Confirmed with a minimal non-package reprex that
  this is ordinary R lazy-evaluation behavior, not S7-specific. Fixed by
  self-namespace-qualifying the default as `sketchpad::canvas()`, which
  resolves via the namespace export table rather than local frame lookup
  and so isn't shadowed -- an intentional, commented exception to this
  package's usual "don't `::`-qualify your own package's exports"
  practice, needed only because the argument and class happen to share a
  name. This also surfaced a smaller, separate lesson: giving `sketch` a
  custom `constructor` (rather than relying on S7's auto-generated one,
  as it had before) was itself required once `canvas`'s default was a
  pre-built object -- embedding an already-evaluated S7 object directly
  as a property's `default` renders as an unparseable `<object>` literal
  in the auto-generated constructor's roxygen `\usage` line (`R CMD
  check`'s "Bad \usage lines" warning), the same reason every other
  constructor with a non-trivial object default (`drawable`'s `style`,
  `shape_blob`'s `distortion`) already used a custom `constructor` with
  an explicit argument default instead of `new_property(default = ...)`.

Added `tests/testthat/test-canvas.R` covering `canvas()`'s own defaults/
validation, `sketch()`'s new `canvas` property, and `draw()`'s background
painting, `xlim`/`ylim` precedence, and `clip` behavior (both on and off,
against a shape sized to overflow a small canvas). `devtools::check()`
stayed clean (0 errors/warnings/notes) throughout.

## Fixing a stale `shape_twist()` call in README.Rmd's "Twists" example

`devtools::build_readme()` failed on the "Twists" chunk with `unused
argument (smooth = 6)`: that chunk still called `shape_twist(..., smooth
= 6L, ...)` via `purrr::pmap()`, left over from before `shape_twist()`
was refactored to take a `path_distortion = noise_bridge(smooth = ...,
seed = ...)` property instead of a bare `smooth` argument (see
`noise_bridge`'s own introduction, above) -- that refactor updated every
`R/*.R` call site but missed this README chunk. Fixed by replacing the
`smooth = 6L` column with `path_distortion = list(noise_bridge(smooth =
6L))`: a length-1 list column, which `tibble::tibble()` recycles to
`n_twists` rows like any other length-1 column, giving every twist the
same `noise_bridge` object (matching the original chunk's behavior,
which also never varied a seed across rows -- only `smooth` was set, and
every twist implicitly shared the same default seed). Verified the fixed
chunk runs standalone before re-running `build_readme()`; the
regenerated `man/figures/README-twists-1.png` came out byte-identical
to the version already committed, confirming the fix reproduces the
example's originally-intended output rather than just silencing the
error.

## List-like access on `sketch`

Added `length()`, `` `[[` ``, and `` `[` `` methods for `sketch`, so its
shapes can be counted/accessed without reaching into `@shapes` directly
(`length(s)`, `s[[i]]`, `s[i]`). Confirmed via a small non-package reprex
first that S7's `method()`/`methods_register()` machinery -- already
relied on for `+` -- also covers these: `S7:::internal_generics()`
explicitly lists `"["`/`"[["` alongside `.S3PrimitiveGenerics` (which
includes `length`), so no new registration mechanism was needed beyond
the existing `.onLoad()` call to `S7::methods_register()`.

`x[[i]]` forwards straight to `x@shapes[[i]]`, returning the bare
`drawable` at that position. `x[i]` forwards to `x@shapes[i]` but wraps
the result back into a `sketch` (preserving `@canvas`) rather than
returning a bare list, mirroring how `[[`/`[` already differ on a plain
list -- `s[i]` stays something `draw()` can be called on directly, no
different from `s[[i]]` being a single drawable ready for `draw()`
itself. Documented on `sketch`'s own class docs (not on the individual
`method()` assignments, which just carry `@export`/`@noRd`, per this
package's usual convention for method-only `.Rd` pages). Added
`tests/testthat/test-sketch.R` covering `length()`, `[[`, `[` with
numeric and logical indices, and canvas preservation.

## Vectorized (plural) constructors

Added a plural `shape_*s()`/`curve_*s()`/`points_raws()` counterpart for
every existing `shape_*()`/`curve_*()`/`points_raw()` constructor (e.g.
`shape_circles()`, `shape_blobs()`, `curve_twists()`), replacing the
`purrr::pmap(values, shape_circle) |> sketch()` idiom every `README.Rmd`
example previously had to spell out by hand with a single call that
returns a `sketch` directly.

**Engine.** All twenty share one internal helper,
`vectorize_shapes(.f, args)` (`R/vectorize.R`, collated right after
`sketch.R`): it wraps any non-vector element of `args` (an S7 object,
e.g. a single shared `trans`/`noise_field`/`noise_bridge`) in a
length-1 `list()` -- `purrr::pmap()` errors on genuinely non-vector
input, confirmed with a small reprex before writing this -- and then
calls `purrr::pmap(args, .f)`, collecting the results into
`sketch(shapes = ...)`. Every plural wrapper is otherwise a thin
one-liner: same argument names/defaults as its singular counterpart,
forwarding `list(<own args>)` plus `list(...)` (for style arguments
like `color`/`fill`) into `vectorize_shapes()`.

**Recycling comes for free from `purrr::pmap()`'s own vctrs rules** --
no custom recycling logic was needed: a length-1 argument broadcasts
against longer ones, and mismatched lengths greater than 1 raise a
clear "Can't recycle" error. This also means a `list()` of several
*different* S7 objects (rather than one shared scalar) passes straight
through unchanged and varies correctly per shape, since an unclassed
list already satisfies `is.vector()` -- confirmed both directions with
tests (`shape_blobs(distortion = <single noise_field>)` sharing one
object vs. `shape_blobs(distortion = list(<nf1>, <nf2>))` varying it).

**Control-point arguments need a list-column, not a bare vector.** Six
constructors (`shape_bezier`/`curve_bezier`, `curve_line`, `shape_raw`/
`curve_raw`, `points_raw`) take `x`/`y` as numeric vectors of control
points/vertices *for a single shape*, not one scalar per shape -- so
their plural versions (`shape_beziers()`, etc.) require `x`/`y` as a
`list()` of numeric vectors, one vector per shape, documented explicitly
on each (overriding the inherited `@param x,y` text from the singular
constructor, per this package's existing `@inheritParams`-override
convention for anywhere the meaning/shape of an argument actually
differs). This falls out of the same `vectorize_shapes()` engine with no
special-casing, since a list of numeric vectors is exactly what
`purrr::pmap()` expects to iterate one whole vector per row.

Documented each plural constructor on its own `.Rd` page (own title,
`@inheritParams` the singular constructor, `@family` matching the
singular's own category) rather than merging into the singular's page,
and added `tests/testthat/test-vectorize.R` covering recycling,
mismatched-length errors, style-argument vectorization via `...`,
shared-vs-varying S7-object arguments, list-column control points, the
zero-length-input edge case, and that `draw()` renders the result.
`devtools::check()` stayed clean (0 errors/warnings/notes) throughout.

## Merging singular/plural constructor docs into shared Rd topics

Reorganized the pkgdown reference so every plural `shape_*s()`/
`curve_*s()`/`points_raws()` constructor documents on the same `.Rd`
topic as its singular counterpart, rather than getting a separate page
-- `?shape_circle` now covers both `shape_circle()` and
`shape_circles()`, matching the pattern `shape_square()` already used to
share `shape_rectangle`'s topic. `shape_rectangle`'s topic now merges
all four of `shape_rectangle()`/`shape_square()`/`shape_rectangles()`/
`shape_squares()`.

**Mechanism**: roxygen2's own `@rdname` merging (confirmed with a small
standalone reprex before touching the package) concatenates
`@description`/`@return`/`@examples` text across every block sharing an
`@rdname`, using only the *first* block's `@title`. This meant each
plural block needed: `@inheritParams <singular>` removed (once merged,
its parameters are already documented in the same topic, so
`@inheritParams` finds "no parameters left to inherit" and errors at
`document()` time -- confirmed with the reprex first); its own title
line left in place structurally (roxygen still needs *some* first
paragraph to parse a block) but understood to be discarded, not
rendered; and an `@rdname <singular>` tag added.

**Disambiguating return types.** Singular constructors previously had no
`@return` tag at all (undocumented by convention). Merging required
adding one (`@return A [drawable].`) so the plural block's own
`@return` (reworded as an override, e.g. `For \`shape_circles()\`, a
[sketch].`) attributes the right return type to the right function
in the merged Value section, rather than the section reading as if
`shape_circle()` itself also returns a sketch.

**A key-matching gotcha for the six list-column constructors**
(`shape_bezier()`/`curve_bezier()`, `curve_line()`, `shape_raw()`/
`curve_raw()`, `points_raw()`): roxygen's "later block overrides
earlier" merge behavior is keyed on the exact `@param` tag string. Three
of these (`shape_raw`, `curve_raw`, `points_raw`) originally declared
`@param x` and `@param y` as two *separate* single-name tags; the plural
block's override used the combined key `@param x,y`, which doesn't match
either separate key -- the rendered `\arguments{}` section ended up with
three entries (`x`, `y`, and `x, y`) instead of one. No warning surfaced
at `document()` time; caught only by reading the generated `.Rd` file's
`\arguments{}` section directly. Fixed by rephrasing the three affected
singular constructors' own tag to the same combined `@param x,y` key,
so the plural override replaces it cleanly.

Verified with `pkgdown::build_reference()` (no warnings) and a full
`devtools::check()` (0 errors/warnings/notes); roxygen2 automatically
deleted the now-orphaned plural-only `.Rd` files (`shape_circles.Rd`,
etc.) on the next `devtools::document()` run, with no manual cleanup
needed.

## `shape_stroke()`: a tapered stroke along an arbitrary path

Explored, ahead of building any package code, several ways to give
`curve_*()` drawables a hand-drawn (ink/pencil/brush) look that plain
`grid::gpar()` line styling can't express. Prototyped in conversation
(not committed) before settling on a design: a variable-width ribbon
offset from an arbitrary path, generalizing `shape_ribbon()`'s
offset-normal + `sqrt`-taper technique from a single straight segment to
any point sequence, with a `noise_field` modulating width as a
"pressure" curve. Confirmed by prototype that layering several
independently-jittered copies of the resulting shape (or of a plain
`curve_line()`) on top adds a convincing pencil/ink edge texture, and
that texturing the ribbon's own interior with `fill_noise()` reads as
charcoal/marker grain -- both left as compositional techniques for the
caller rather than built into the class itself (see
`.agents/PLAN.md`'s "Stylized stroke rendering" item for what's still
open).

**Why per-point normals, not a shared offset direction.** `shape_ribbon()`/
`shape_twist()` both offset by a single, *unnormalized* direction vector
(the straight backbone's own `(dy, dx)`) shared across every point --
correct only because their own backbone is exactly straight, or
displaced from straight by an amount small relative to its length. A
`shape_stroke()` path can bend arbitrarily (that's the point of taking
arbitrary control points), so reusing that same shortcut would visibly
skew the outline anywhere the path curves -- confirmed by an early
prototype attempt using the shared-direction shortcut on a sine-wave
path, which came out visibly slanted at each bend. Fixed by computing a
genuine unit normal at every point via central differences
(`stroke_normals()`, `R/shape_stroke.R`), re-normalized per point rather
than shared.

**Why resampling, and why it doesn't smooth corners.** A stroke built
from only a few widely-spaced control points needs denser points for its
width taper/noise modulation to vary smoothly, so `shape_stroke()`
resamples its control polyline to `n` evenly arc-length-spaced points
(`resample_by_length()`, via `stats::approx()` after dropping duplicate
arc-length ties to avoid its "collapsing to unique x values" warning)
before computing normals/width. This only redistributes points along the
existing straight segments -- it does not curve-fit or smooth sharp
corners, matching `curve_line()`'s own no-smoothing convention (no
spline fit, unlike `shape_bezier()`/`curve_bezier()`'s Bernstein-basis
smoothing). A `shape_stroke()` given only a handful of control points
therefore still renders with visibly angular corners; a smoothly curving
stroke needs a denser input path (e.g. points already sampled from some
smooth function), documented explicitly on the constructor after an
initial test render with only 8-12 control points came out visibly
zig-zagged rather than smooth.

**Why the taper is renormalized to peak at `1`.** `shape_ribbon()`'s own
`sqrt(t * (1 - t))` taper formula peaks at `0.5` (an existing,
undocumented quirk -- its `width` argument is therefore not literally the
maximum rendered width). `shape_stroke()` uses `sqrt(pmin(t, 1 - t) * 2)`
instead, which peaks at exactly `1` at the path's midpoint, so its own
`width` argument is exactly the maximum rendered width -- a deliberate,
documented improvement over the existing siblings' behavior rather than
copying their formula verbatim, without changing either existing class
(no shared taper helper was factored out, since the two formulas are now
genuinely different, not duplicated).

Implemented as a full `shape_*` family member: `shape_stroke()` (singular)
and `shape_strokes()` (plural, list-column `x`/`y` like `curve_line()`'s
own plural), collated in `DESCRIPTION` right after `curve_twist.R`,
documented together on one merged `.Rd` topic, `tests/testthat/test-stroke.R`
covering point count, zero-width collapse-to-backbone, taper-to-zero at
both ends, per-point (not global-chord) normal behavior on a bent path,
seed reproducibility, argument validation, and `shape_strokes()`
vectorization. Verified with a full `devtools::check()` (0 errors/
warnings/notes).

## `sketchy()` and `fill_charcoal()`: formalizing the layered-jitter and texture-preset prototypes

Two ad hoc techniques used while designing `shape_stroke()` (layering
independently-jittered path copies for a pencil/ink look, and texturing
a stroke's interior with `fill_noise()` for a charcoal/marker look) were
promoted from one-off console prototypes into real, tested, documented
package functions.

**`sketchy()`** (`R/sketchy.R`) generalizes the layered-jitter prototype:
rather than a new drawable class or a `shape_stroke()`-specific helper,
it's a plain function taking a drawable constructor `.f` (e.g.
`curve_line()` or `shape_stroke()`) plus `x`/`y`, building `layers`
independently-perturbed calls to `.f` and collecting them into a
`sketch`. Two design decisions worth recording:

- **Noise sampled along normalized arc-length, not raw `(x, y)`.** The
  original ad hoc prototype sampled `ambient::gen_simplex()` at the
  curve's own domain parameter (e.g. `t` in `sin(t)`), which only exists
  because that example happened to be a function plot. A general-purpose
  version has no such parameter available, so `sketchy()` computes one:
  cumulative arc-length, normalized to `[0, 1]`. This keeps the jitter's
  qualitative shape independent of the input path's own scale -- a path
  spanning `[0, 100]` and one spanning `[0, 1]` with the same point count
  get comparably-shaped wobble, rather than the frequency parameter
  needing rescaling by hand for each new path.
- **No new drawable class, no new prefix family.** Considered naming
  this something in the `shape_*`/`curve_*` vein, but rejected: it
  doesn't produce a single `drawable` (a `sketch` of several isn't
  representable as one polygon/path/points geometry), and confusion with
  the already-existing `shape_strokes()` (unrelated: vectorizes over
  several *independent* strokes' own arguments, not jittered copies of
  *one* logical stroke) seemed likely with any name sharing that prefix.
  Landed on a new, minimal top-level family instead: `sketchy()` is the
  first member of a new pkgdown reference section, "Effects"
  (`@family effects`), for functions that compose whole drawables rather
  than constructing one.

**`fill_charcoal()`** (`R/fill.R`, collated as an ordinary function
addition, no `Collate` change needed) is a thin `fill_noise()` preset --
same field, same rendering, just different defaults (lighter `"gray15"`
base colour, finer `spacing = 0.25`, finer `frequency = 4`, one more
`octaves = 3L`) -- capturing the parameter combination found, while
testing `shape_stroke()`'s own texture options, to read convincingly as
charcoal/marker grain. Implemented and documented following
`fill_none()`'s "thin wrapper over a sibling constructor, self-documenting
name" pattern rather than duplicating `fill_noise()`'s own validation.

**A repeated gotcha, caught by `R CMD check` rather than avoided in
advance**: `fill_charcoal()`'s own roxygen example used `color = NA`
(a logical `NA`) instead of `NA_character_`, the same
`style()`-validator mismatch documented elsewhere in this file for
interactive `draw()` calls -- but this time inside a runnable example,
which `R CMD check`'s `--run-examples` step actually executes, so it
surfaced as a real check ERROR rather than a console error the developer
could just retype. Fixed by using `NA_character_` in the example, same
as everywhere else `color = NA` is wanted. Worth remembering: this
mistake is easy to make even after hitting it before, precisely because
it *looks* correct and only fails at the `style()` validator boundary.

Verified with a full test suite run (`tests/testthat/test-sketchy.R`
covering layer count, per-layer class, jitter-vs-unperturbed and
zero-jitter-collapses-to-backbone behavior, independent per-layer
wobble, seed reproducibility, `...` forwarding, `shape_stroke()`
compatibility, argument validation, and a `draw()` smoke test; three new
tests appended to `tests/testthat/test-fill.R` for `fill_charcoal()`)
and a full `devtools::check()` (0 errors/warnings/notes, after fixing
the example bug above).

## `bristle_stroke()`: fanning shape_stroke()/sketchy() into a dry-brush effect

Prototyped in conversation (console only, not committed) before writing
any package code, following the same "formalize an ad hoc technique"
path as `sketchy()`/`fill_charcoal()`: several parallel bristles fanned
perpendicular to a backbone path, each independently wobbled and
raggedly trimmed, rather than one clean parallel comb -- a plain, evenly
spaced fan of identical-length bristles read as too uniform to pass for
a dry brush; the convincing version needed randomized per-bristle length
(fraying) and width, plus enough perpendicular overlap between adjacent
bristles for a darker, denser core with only the outer bristles visibly
separating.

**Reused existing building blocks rather than duplicating their logic.**
The perpendicular fan direction is exactly `shape_stroke()`'s own
per-point unit normal, so `bristle_stroke()` calls `shape_stroke.R`'s
internal `stroke_normals()`/`resample_by_length()` helpers directly
(same package, no `:::` needed, unlike the console prototype which had
to reach into the namespace this way since it wasn't part of the package
yet). Each bristle's own independent wobble is a `sketchy()` call with
`layers = 1L` -- `sketchy()`'s per-layer jitter mechanism is exactly what
a single independently-wobbling bristle needs, just invoked once per
bristle position rather than once per layer of the same path.
`shape_stroke()`'s own taper-to-zero at both ends was already exactly
the "bristle tip fade" effect wanted, needing no extra code.

**Randomization needed `withr::with_seed()`, unlike `sketchy()`'s own
jitter.** `sketchy()`'s jitter is a pure function of its own seed
argument (`ambient::gen_simplex()` takes a seed directly, no global RNG
involved), but the console prototype's fray/width-jitter used
`stats::runif()` against R's global random state -- fine for an
interactive script, but a real package function must not leak side
effects into the caller's own RNG state. Scoped each bristle's
`stats::runif()` calls inside `withr::with_seed(bristle_seed, {...})`,
the same convention `fill_stipple()`/`fill_scatter()`/`fill_halftone()`
already use for exactly this reason. Verified with a dedicated test that
`.Random.seed` is unchanged after a `bristle_stroke()` call.

**A `seq(..., length.out = 1)` edge case caught before it shipped.**
`n_bristles = 1L` needs a single bristle centered on the backbone (offset
`0`), but `seq(-spread / 2, spread / 2, length.out = 1)` returns `-spread
/ 2` (the `from` value), not `0` -- confirmed with a quick console check
before writing the fix, not discovered via a failing test. Handled with
an explicit `if (n_bristles == 1L) 0 else seq(...)` branch, together
with a dedicated `n_bristles = 1L` test.

Implemented as `R/bristle_stroke.R`, the second member of the `effects`
pkgdown family (alongside `sketchy()`), collated right after `sketchy.R`.
`tests/testthat/test-bristle-stroke.R` covers bristle count, per-bristle
class, the single-bristle edge case, seed reproducibility, no RNG leakage,
`...` forwarding, that bristles actually land at distinct perpendicular
offsets, argument validation, and a `draw()` smoke test. Verified with a
full test suite run (798/798 passing) and `devtools::check()` (0 errors/
warnings/notes).
