# sketchpad development plan

This document tracks scoped-out future development for sketchpad -- work
that's been thought about but not done, or deliberately deferred. It is
not a changelog: once an item here is completed, its write-up should
move to [.agents/HISTORY.md](HISTORY.md) and be removed from this file
rather than marked "done" in place.

## Deferred: rest of the `curve_*()` constructor family

`curve_bezier()` (see `.agents/HISTORY.md`) is the first `curve_*()`
constructor, proving out `drawable`'s `geometry = "path"` end to end:
`curve_bezier()`/`shape_bezier()` share their geometry computation and
argument validation via two internal helpers factored into
`R/shape_bezier.R` (`bezier_curve_points()`, `validate_bezier_args()`),
differing only in which `drawable(geometry = ...)` they construct from.

`curve_line()` (a straight open polyline through arbitrary control
points, with no `n`/resampling since it uses its control points as
vertices directly), `curve_spiral()` (angle sweeps `turns` revolutions
while radius interpolates linearly from `radius_start` to
`radius_end`), and `curve_scribble()` (a single wandering line, sharing
`fill_scribble()`'s internal `scribble_lines()` generator rather than
duplicating it, scaled into an arbitrary `x`/`y` + `width`/`height`
bounding box instead of tiled) are all done -- see `.agents/HISTORY.md`.
`lineend`/`linemitre` have also since been added to `style()`, once
`curve_line()`'s sharp vertex angles and free endpoints gave both a
demonstrated visible effect.

`curve_raw()`/`points_raw()` (see `.agents/HISTORY.md`) round out the
family: `shape_raw`'s `"path"`/`"points"`-geometry analogs, giving all
three `geometry` values a trivial "supply `x`/`y` directly" constructor.
`points_raw()` is also the first concrete `geometry = "points"`
constructor -- previously reserved on the dimensional reading with
nothing exposing it. No further `curve_*()`/`points_*()` constructor is
currently planned.

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

## Candidate features (brainstormed, not yet prioritized)

The items below came out of a deliberate brainstorming pass over the
package's current gaps, not a specific need that came up while building
something else (contrast with the four items above). Each is a candidate
to pick up, reject, or refine later -- none are scheduled.

### Additional primitive shapes

`star`. (`rectangle`/`square` are now covered by `shape_rectangle()`/
`shape_square()`; `polygon` is now covered by `shape_polygon()`;
`ellipse` is now covered by `shape_ellipse()`; `arc`/`wedge` are now
covered by `curve_arc()`/`shape_wedge()` -- these cover a partial circle,
not an annulus segment (a wedge with a nonzero *inner* radius, i.e. a
ring slice); revisit if a concrete use case needs one, since it's a
reasonably natural `inner_radius` extension to `shape_wedge()`'s current
`points` getter. A bare open `line` and a `spiral` were also on this
list -- both are now covered by `curve_line()`/`curve_spiral()`; see
`.agents/HISTORY.md`.)

### Multiple sub-paths and holes per drawable

Every `drawable` currently renders as exactly one `grid::polygonGrob()`
per shape. `grid::polygonGrob()` supports multiple disjoint sub-paths via
its `id`/`id.lengths` arguments (e.g. a ring with a hole, or several
disconnected polygons sharing one `style`), which nothing in sketchpad
currently uses. Explicitly kept separate from the `geometry` property
decided above -- this needs a data-shape change to `points` (a collection
of sub-paths), not a new `geometry` value.

### Open/unstroked curve support

(Merged into the "Deferred: a `curve_*()` constructor family using
`drawable`'s `geometry` property" item above -- see there and
`.agents/HISTORY.md` for the settled `geometry`-property design. What's
still open is the concrete `curve_*()` constructor family and whether
line styling needs to grow beyond the current single `linewidth` -- dash
patterns, line caps/joins.)

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
