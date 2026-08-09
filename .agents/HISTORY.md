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
