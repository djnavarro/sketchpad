# sketchpad development plan

This document tracks scoped-out future development for sketchpad -- work
that's been thought about but not done, or deliberately deferred. It is
not a changelog: once an item here is completed, its write-up should
move to [.agents/HISTORY.md](HISTORY.md) and be removed from this file
rather than marked "done" in place.

## Deferred: port `bezier_ribbon` from series-lissajous

`series-lissajous`'s `bezier_ribbon` combines a Bezier path with the same
noise-perturbed perpendicular-offset logic `ribbon`/`twist` already use,
giving a curved (rather than straight or Brownian-bridge) ribbon. Not
ported yet -- `bezier` (the plain curve) was the requested unit of work.
Would slot in as `R/bezier_ribbon.R`, immediately after `bezier.R` in
`Collate`.

## Deferred: open/stroked curve support

Every `drawable` currently renders as a closed `grid::polygonGrob()`.
`bezier` in particular would also be useful as an open, stroked path
(`grid::polylineGrob()` or `grid::linesGrob()`) rather than always
implicitly closing back to its first control point. No concrete need has
forced a decision on the API shape yet (a `closed = TRUE/FALSE` property
on `drawable`? a separate `curve`-like non-drawable class? a different
`draw()` method dispatch?) -- deferred until a real sketch needs it.

## Deferred: migrate `sketches` repo's `example_*.R` scripts to depend on the package

The four `example_*.R` scripts in the `sketches` repo were *adapted* into
`README.Rmd`, but the original scripts in that repo still
`source(here::here("sketches.R"))` rather than `library(sketchpad)`. Not
touched, since the `sketches` repo may want to stay as a standalone
sketchbook independent of the package's release cycle.

## Deferred: decide what belongs in sketchpad vs. stays series-specific

Series repos (e.g. `series-lissajous`) extend the core drawing system
with series-specific classes. `bezier` was pulled into the shared
package; other series-specific shapes have not been reviewed for
candidacy. No process yet for deciding "shared primitive" vs.
"series-specific one-off."
