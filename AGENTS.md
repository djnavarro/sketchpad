# AGENTS.md

## What this package is

sketchpad is a lightweight, p5.js-inspired drawing system for generative
art, built on [S7](https://rconsortium.github.io/S7/) classes and `grid`
graphics. It bypasses ggplot2 entirely: a small set of `drawable` shapes
(`circle`, `blob`, `ribbon`, `twist`, `bezier`) expose a computed
`points` property, are composed into a `sketch`, and rendered with
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

- **`style`** – container for `color`/`fill`/`linewidth`, forwarded to
  [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html).
- **`points`** – a polygon’s vertices (`x`/`y` numeric vectors, equal
  length).
- **`drawable`** – parent class of every shape. Declares two properties:
  `style` (default
  [`style()`](https://sketchpad.djnavarro.net/reference/style.md)) and a
  computed `points` property that subclasses override. Not meant to be
  instantiated directly.
- **`shape`** – the trivial drawable: `x`/`y` supplied directly as
  `points`. Usually produced by `convert()`, not constructed by hand.
- **`circle`** – centroid + radius + `n` (point count); `points` is `n`
  evenly-spaced points around the circumference.
- **`blob`** – like `circle`, but the radius is perturbed by simplex
  noise
  ([`ambient::fracture()`](https://ambient.data-imaginist.com/reference/fracture.html)/[`ambient::gen_simplex()`](https://ambient.data-imaginist.com/reference/noise_simplex.html)/[`ambient::fbm()`](https://ambient.data-imaginist.com/reference/fbm.html)),
  giving an irregular outline. `range` controls noise amplitude,
  `frequency`/`octaves`/`seed` control the noise field.
- **`ribbon`** – a tapered band between `(x, y)` and `(xend, yend)`,
  width modulated by simplex noise and a `sqrt` taper that goes to zero
  at both ends.
- **`twist`** – like `ribbon`, but the underlying path is a smoothed
  Brownian bridge
  ([`e1071::rbridge()`](https://rdrr.io/pkg/e1071/man/rbridge.html) via
  the internal `smooth_bridge()` helper) rather than a straight line.
- **`bezier`** – outline follows a Bezier curve through an arbitrary
  number of control points (`x`/`y`), evaluated via the Bernstein
  polynomial basis (internal `bernstein()` helper, *not* De Casteljau’s
  algorithm). Ported from `series-lissajous`, but redesigned: the
  original was a bare `S7_object` producing a `curve` data frame,
  consumed internally by a separate `bezier_ribbon` drawable. Here
  `bezier` itself has `parent = drawable`, so it’s directly usable with
  [`draw()`](https://sketchpad.djnavarro.net/reference/draw.md) – at the
  cost of always rendering as a closed polygon (the curve’s last point
  connects straight back to its first), since every `drawable`’s
  `points` are drawn with
  [`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html).
  There is no open/stroked-curve option. `bezier_ribbon` itself has not
  been ported; see PLAN.md.
- **`sketch`** – a list of `drawable`s (`shapes` property). Built up
  with `sketch() + circle() + blob(...)`; the `+` method requires an S7
  method registration, not an S3 `` `+.sketch` `` (see “Gotchas”).
- **[`draw()`](https://sketchpad.djnavarro.net/reference/draw.md)** – S7
  generic, `dispatch_args = "object"`. Methods for `drawable` (single
  shape) and `sketch` (renders every shape into one shared, equal-aspect
  viewport); a catch-all method on `class_any` warns and returns
  `invisible(NULL)` for anything else. `xlim`/`ylim` default to the
  range of the object’s own points.
- **`convert()`** – S7’s own generic (not defined by this package); a
  `method(convert, list(drawable, shape))` “freezes” any drawable’s
  computed points into a plain `shape`, preserving `style`.

### Rendering model

Every `drawable` is drawn as a single
[`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html) inside
a [`grid::viewport()`](https://rdrr.io/r/grid/viewport.html) with
equal-axis scaling (`width`/`height` set via `"snpc"` units so a 1:1
aspect ratio is preserved regardless of the device’s own aspect ratio).
`draw(sketch)` computes one shared viewport/axis-range across every
shape’s points, then draws each shape’s polygon into it in list order –
later shapes are drawn on top.

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
- **A drawable’s `shape(x = ..., y = ..., style = from@style)` shortcut
  doesn’t work.**
  [`shape()`](https://sketchpad.djnavarro.net/reference/shape.md)’s
  constructor only has named `x`/`y` parameters; everything else in
  `...` is forwarded to `style(...)`, so passing
  `style = <a style object>` tries to call `style(style = <...>)` and
  errors. `convert()` instead builds the shape from `x`/`y` alone, then
  reassigns `@style` afterward.
- **R sources `R/*.R` alphabetically by default, which breaks subclass
  definitions.** `blob.R` needs `drawable` (from `drawable.R`) to exist
  first, but “blob.R” \< “drawable.R” alphabetically. Fixed with an
  explicit `Collate` field in `DESCRIPTION` (see “Structure” below for
  the required order) rather than `@include` tags.
- **The first `devtools::document()` pass after adding a new
  cross-referencing class emits “could not resolve link” warnings.**
  This is expected roxygen2 behavior when several classes’ `[link]`
  references point at each other and none of their `.Rd` files exist
  yet; a second `document()` call resolves them all. Don’t chase this
  warning by rewording the docs.
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

## Structure

- `R/style.R`, `R/points.R`, `R/drawable.R` – foundation classes, in
  load order (each depends on the previous).
- `R/bezier.R`, `R/shape.R`, `R/circle.R`, `R/blob.R`, `R/ribbon.R`,
  `R/twist.R` – the concrete `drawable` subclasses, one file each.
- `R/sketch.R` – the `sketch` class and its `+` method.
- `R/draw.R` – the `draw` generic and its three methods.
- `R/convert.R` – the `convert(drawable, shape)` method.
- `R/sketchpad-package.R` – package-level doc, `#' @import S7`, the
  `.onLoad()` calling
  [`S7::methods_register()`](https://rconsortium.github.io/S7/reference/methods_register.html),
  and the `globalVariables("properties")` workaround.
- `DESCRIPTION`’s `Collate` field pins the load order above explicitly
  (style -\> points -\> drawable -\> bezier -\> shape -\> circle -\>
  blob -\> ribbon -\> twist -\> sketch -\> draw -\> convert -\>
  sketchpad-package). **Any new drawable subclass must be added to
  `Collate` after `drawable.R`**, or
  `devtools::load_all()`/`R CMD check` will fail with an “object
  ‘drawable’ not found” error.

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
  `twist`) is a `new_property()` with only a `getter` – geometry is
  always derived, never stored and mutated in place.
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
