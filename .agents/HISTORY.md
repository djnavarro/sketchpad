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
