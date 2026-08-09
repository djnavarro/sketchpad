# sketchpad development plan

This document tracks scoped-out future development for sketchpad -- work
that's been thought about but not done, or deliberately deferred. It is
not a changelog: once an item here is completed, its write-up should
move to [.agents/HISTORY.md](HISTORY.md) and be removed from this file
rather than marked "done" in place.

## Deferred: port `bezier_ribbon` from series-lissajous

`series-lissajous`'s `bezier_ribbon` combines a Bezier path with the same
noise-perturbed perpendicular-offset logic `shape_ribbon`/`shape_twist`
already use, giving a curved (rather than straight or Brownian-bridge)
ribbon. Not ported yet -- `shape_bezier` (the plain curve) was the
requested unit of work. Would slot in as `R/shape_bezier_ribbon.R`,
immediately after `shape_bezier.R` in `Collate`.

**Naming note:** when this is ported, name the constructor
`shape_bezier_ribbon()` (not bare `bezier_ribbon()`), to match the
`shape_*` prefix convention adopted for every drawable-producing
constructor -- see `.agents/HISTORY.md`'s "Renaming drawable
constructors to a shared `shape_*` prefix" entry.

## Deferred: open/stroked curve support

Every `drawable` currently renders as a closed `grid::polygonGrob()`.
`shape_bezier` in particular would also be useful as an open, stroked path
(`grid::polylineGrob()` or `grid::linesGrob()`) rather than always
implicitly closing back to its first control point. No concrete need has
forced a decision on the API shape yet (a `closed = TRUE/FALSE` property
on `drawable`? a separate `curve`-like non-drawable class? a different
`draw()` method dispatch?) -- deferred until a real sketch needs it.

## Deferred: arbitrary angle for `fill_scribble()`

`fill_scribble()` only supports `direction = "horizontal"` or
`"vertical"` -- see its "Known limitation" docs section and
`.agents/HISTORY.md`'s write-up for why `fill_hatch()`'s tile-reshaping
angle trick doesn't generalize to wandering-line content. A genuinely
rotated wandering line would need the tile built as a rotated/sheared
parallelogram with edge-matching worked out for a curve rather than a
segment; no such technique exists in this package yet, and none was
prototyped successfully. Revisit if a real sketch needs an arbitrary
angle.

## Deferred: S7 class for `fill` objects

All fifteen `fill_*()` helpers in `R/fill.R` currently return either a
plain colour string (`fill_solid()`) or whatever `grid::pattern()`
produces (`"GridPattern"`-classed S3 objects, everything else) --
`style@fill` stores this directly, and `draw()` hands it straight to
`grid::gpar(fill = ...)`, which already accepts either kind
interchangeably with no branching needed. Considered wrapping these in a
proper S7 `fill` class (e.g. `fill(pattern = <string or GridPattern>)`)
to match the rest of the package's S7-based design and give a dispatch
target for any future `fill_*()` that needs behavior beyond "hand this
to `gpar()`" -- e.g. `draw()`-time recomputation against the target
polygon, or device-capability warnings. Deferred: no current `fill_*()`
needs this, so the wrapper would add an unwrap-at-every-call-site cost
(`style()`'s validator, `draw()`) for no present behavioral gain. Revisit
if a concrete `fill_*()` idea comes up that can't be expressed as a bare
colour string or `GridPattern`.

## Deferred: migrate `sketches` repo's `example_*.R` scripts to depend on the package

The four `example_*.R` scripts in the `sketches` repo were *adapted* into
`README.Rmd`, but the original scripts in that repo still
`source(here::here("sketches.R"))` rather than `library(sketchpad)`. Not
touched, since the `sketches` repo may want to stay as a standalone
sketchbook independent of the package's release cycle.

## Deferred: decide what belongs in sketchpad vs. stays series-specific

Series repos (e.g. `series-lissajous`) extend the core drawing system
with series-specific classes. `shape_bezier` was pulled into the shared
package; other series-specific shapes have not been reviewed for
candidacy. No process yet for deciding "shared primitive" vs.
"series-specific one-off."

## Candidate features (brainstormed, not yet prioritized)

The items below came out of a deliberate brainstorming pass over the
package's current gaps, not a specific need that came up while building
something else (contrast with the four items above). Each is a candidate
to pick up, reject, or refine later -- none are scheduled.

### Additional primitive shapes

`rectangle`/`square`, `polygon` (regular n-gon), `ellipse` (`shape_circle`
is currently radius-only, with no independent x/y radii), `arc`/`wedge` (a
partial circle/annulus), `star`, a bare `line` (an open segment, distinct
from `shape_ribbon`'s width), and `spiral` -- several `series-*` repo names
(e.g. `series-nautilus`) suggest spirals recur often enough across
projects to be worth a shared primitive rather than a one-off.

### Multiple sub-paths and holes per drawable

Every `drawable` currently renders as exactly one `grid::polygonGrob()`
per shape. `grid::polygonGrob()` supports multiple disjoint sub-paths via
its `id`/`id.lengths` arguments (e.g. a ring with a hole, or several
disconnected polygons sharing one `style`), which nothing in sketchpad
currently uses.

### Open/unstroked curve support

(See also the existing "Deferred: open/stroked curve support" item
above -- these overlap, kept separate since one is scoped narrowly to
`shape_bezier` and this one is the more general open-vs-closed rendering
question for any `drawable`.) Would also want line styling beyond the
current single `linewidth`: dash patterns, line caps/joins.

### Alpha/opacity in `style`

`style` currently exposes only `color`/`fill`/`linewidth` -- no
transparency control, a fairly basic omission for layered generative
work where overlapping semi-transparent shapes are a common effect.

### Transform helpers

Translate/rotate/scale/reflect a single `drawable` or an entire `sketch`
as a first-class operation, rather than hand-recomputing `x`/`y`/control
points before constructing a shape.

### A `group` class

A nested collection of drawables sharing one transform and/or style
override, distinct from `sketch` (which represents the whole canvas of
independently-styled shapes). Would pair naturally with the transform
helpers above -- e.g. rotate a `group` as a unit.

### List-like access on `sketch`

`length()`, `` `[[` ``, `` `[` `` methods for `sketch`, rather than
reaching into `@shapes` directly.

### Canvas/background concept

`draw()` always starts from `grid::grid.newpage()` (the device's default
background); there's no explicit `canvas()`/`background()` concept the
way p5.js has one, despite that being the package's stated inspiration.

### Save-to-file and multi-frame/animation export helpers

No `save_png()`/`save_svg()`-style convenience -- currently the caller
wraps `draw()` in `png()`/`dev.off()` by hand, as `example_04.R`'s
original 50-seed export loop (in the `sketches` repo) had to. A thin
wrapper generating a seed sequence plus a `gifski`-based animation export
would mirror that same example's use case.

### Vectorized constructors

Building many shapes currently always goes through `purrr::pmap()` over
a tibble of parameters (see every `README.Rmd` example). A plural
constructor (e.g. `shape_circles(x = ..., y = ..., ...)`, vectorized over its
arguments) could return a `sketch` directly instead.

### `print`/`format` methods

`drawable` and `sketch` currently print as the default S7 object dump;
dedicated `print`/`format` methods would give more useful console
feedback.

### Palette integration

There's a sibling `palettes` repo (`djnavarro/palettes`) holding reusable
CSV palettes. sketchpad could depend on or bundle from it rather than
every series/example inlining its own palette vector (as all four
`README.Rmd` examples currently do).

### Broader test coverage and runnable examples

Test coverage is currently concentrated on `shape_bezier` plus a few
`sketch`-level tests (`+`, validation, `convert()`); `shape_circle`/
`shape_blob`/`shape_ribbon`/`shape_twist` have no dedicated tests. Most
`@examples` blocks are
`\dontrun{}` or absent entirely; per-drawable runnable examples would
both document and exercise the geometry.

### Explicitly flagged as possibly out of scope

Two ideas considered and tentatively set aside rather than silently
omitted, so they don't get re-proposed without acknowledging the
tradeoff:

- **Boolean geometry ops** (union/intersection/clip between shapes) --
  heavy geometry-library territory (`sf`/`polyclip`), in tension with
  the package's "lightweight" design goal.
- **Interactivity/event handling** -- sketchpad targets static
  generative art output, not p5.js's live-canvas/event-loop use case;
  adding this would be a much larger scope change than anything else on
  this list.
