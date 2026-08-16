# sketchpad development plan

This document tracks scoped-out future development for sketchpad -- work
that's been thought about but not done, or deliberately deferred. It is
not a changelog: once an item here is completed, its write-up should
move to [.agents/HISTORY.md](HISTORY.md) and be removed from this file
rather than marked "done" in place.

## Release targets

Open items below are triaged into three buckets. Update an item's own
section heading (or this list) as its target changes; don't duplicate
the writeup.

No 0.1 items currently open.

(`star`, the last outstanding "additional primitive shapes" item,
"Multiple sub-paths and holes per drawable", the `group` class, the S7
`fill` class (with automatic `aspect` resolution), and an `angle`
argument for `fill_scribble()` are now done -- see `.agents/HISTORY.md`.)

**0.2:**
- Multi-frame/animation export helpers (and interactivity/event handling,
  if ever reconsidered -- see "Explicitly flagged as possibly out of
  scope")
- Boolean geometry ops (if ever reconsidered -- see "Explicitly flagged
  as possibly out of scope")

**Won't implement:**
- Palette integration with the sibling `palettes` repo -- superseded by
  `palette_manual()`/`palette_cosine()`, which already vendor/generate
  palettes directly inside sketchpad with no external dependency needed.

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

## Candidate features (brainstormed, not yet prioritized)

The items below came out of a deliberate brainstorming pass over the
package's current gaps, not a specific need that came up while building
something else (contrast with the four items above). Each is a candidate
to pick up, reject, or refine later -- none are scheduled.


### Open/unstroked curve support

(Merged into the "Deferred: a `curve_*()` constructor family using
`drawable`'s `geometry` property" item above -- see there and
`.agents/HISTORY.md` for the settled `geometry`-property design. What's
still open is the concrete `curve_*()` constructor family and whether
line styling needs to grow beyond the current single `linewidth` -- dash
patterns, line caps/joins.)

### Multi-frame/animation export helpers (0.2)

`save_png()`/`save_svg()`/`save_pdf()` (see `.agents/HISTORY.md`) now
cover single-image export -- a thin wrapper opening the right
`grDevices` device, calling `draw()`, and always closing the device
afterward. Still open: something to mirror `example_04.R`'s original
50-seed export loop (in the `sketches` repo) -- a thin wrapper
generating a seed sequence plus a `gifski`-based animation export.
Revisit if a concrete sketch needs a multi-frame/animated export rather
than one-off images.

### Palette integration (won't implement)

There's a sibling `palettes` repo (`djnavarro/palettes`) holding reusable
CSV palettes. sketchpad could depend on or bundle from it rather than
every series/example inlining its own palette vector (as all four
`README.Rmd` examples currently do). Decided against: `palette_manual()`
already vendors this same source directly into sketchpad
(`R/sysdata.rda`, see `data-raw/build_manual_palettes.R`), and
`palette_cosine()` covers the procedural-palette case -- no external
dependency is needed.

### Stylized stroke rendering: still open beyond `shape_stroke()`/`sketchy()`/`bristle_stroke()`/`fill_charcoal()`

The variable-width ribbon-from-path idea is now implemented as
`shape_stroke()`, the layered/jittered multi-stroke idea as `sketchy()`,
the bristle/dry-brush idea as `bristle_stroke()`, the "textured fill
reads as charcoal/marker grain" finding as `fill_charcoal()`, and the
rasterized/textured stroke idea as `textured_stroke()` -- see
`.agents/HISTORY.md`. No further item from the original brainstorm is
currently open.

`fill_scribble()` remains a poor fit for texturing a curved
`shape_stroke()`'s interior: its `angle` is one fixed value for the whole
tile (and only tiles exactly seamlessly at a multiple of 90 degrees --
see `.agents/HISTORY.md`'s write-up), so it can't track a curved path's
own continuously-varying tangent; `fill_charcoal()`/`fill_noise()`/
`fill_marble()` don't have this problem and are the recommended textures
for a `shape_stroke()` body.

### Explicitly flagged as possibly out of scope (0.2 if reconsidered)

Two ideas considered and tentatively set aside rather than silently
omitted, so they don't get re-proposed without acknowledging the
tradeoff. Neither is scheduled for 0.1; if either is picked up at all,
target 0.2.

- **Boolean geometry ops** (union/intersection/clip between shapes) --
  heavy geometry-library territory (`sf`/`polyclip`), in tension with
  the package's "lightweight" design goal.
- **Interactivity/event handling** -- sketchpad targets static
  generative art output, not p5.js's live-canvas/event-loop use case;
  adding this would be a much larger scope change than anything else on
  this list.
