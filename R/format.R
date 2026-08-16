#' Format a single property value for `format(drawable)`/`format(sketch)`
#'
#' A scalar prints via [format()] directly; a short vector (length <= 4)
#' prints as a comma-separated `[...]` list; a longer vector is truncated
#' to its first three elements plus a `(n total)` count, so a drawable
#' with e.g. a 200-point `x`/`y` control path still prints on one line.
#' A nested S7 object (e.g. a [noise_field]/[noise_bridge] `distortion`)
#' prints as `<class_name>` rather than recursing into its own
#' properties, keeping a drawable's own summary to a handful of lines
#' regardless of how deeply nested its settings are. A plain list prints
#' as `<list[n]>` for the same reason.
#'
#' @param value Any property value.
#' @return A single string.
#' @noRd
format_prop_value <- function(value) {
  if (S7::S7_inherits(value)) {
    return(paste0("<", S7::S7_class(value)@name, ">"))
  }
  if (is.list(value)) {
    return(paste0("<list[", length(value), "]>"))
  }
  if (length(value) == 0) {
    return("<empty>")
  }
  if (length(value) == 1) {
    return(format(value))
  }
  if (length(value) <= 4) {
    return(paste0("[", paste(format(value), collapse = ", "), "]"))
  }
  paste0(
    "[", paste(format(value[1:3]), collapse = ", "), ", ... (", length(value), " total)]"
  )
}

#' Summarize a drawable's own `trans` property for `format(drawable)`
#'
#' `trans`/`trans_warp`/`trans_fn`/`trans_chain` each get a one-word (or
#' short) summary rather than printing their own properties in full -- an
#' affine [trans] is reported as `"identity"` when its matrix is exactly
#' the 3x3 identity (`drawable`'s own default), or `"affine"` otherwise;
#' a [trans_warp] as `"warp"`; a [trans_fn] as `"fn"`; a [trans_chain] as
#' `"chain (n steps)"`.
#'
#' Summarize a `fill` object for `format(drawable)`/`format(sketch)`
#'
#' A [fill] with no `resolve` (a fixed colour string, `GridPattern`, or an
#' explicit-`aspect` pattern) is reported via `format_prop_value()` on its
#' own `value`; one with a `resolve` (the default for every aspect-taking
#' `fill_*()` helper -- see [fill_hatch()]'s own `aspect` docs) is
#' reported the same way but suffixed `" (auto-aspect)"`, since its
#' `value` is only a placeholder computed at `aspect = 1` until [draw()]
#' resolves it against the real target.
#'
#' @param f A [fill] object.
#' @return A single string.
#' @noRd
format_fill_summary <- function(f) {
  if (!S7::S7_inherits(f, fill)) {
    return(format_prop_value(f))
  }
  base <- format_prop_value(f@value)
  if (is.null(f@resolve)) base else paste0(base, " (auto-aspect)")
}

#' @param x A [trans]/[trans_warp]/[trans_fn]/[trans_chain] object.
#' @return A single string.
#' @noRd
format_trans_summary <- function(x) {
  if (S7::S7_inherits(x, trans)) {
    if (isTRUE(all.equal(unname(x@matrix), diag(3)))) "identity" else "affine"
  } else if (S7::S7_inherits(x, trans_warp)) {
    "warp"
  } else if (S7::S7_inherits(x, trans_fn)) {
    "fn"
  } else if (S7::S7_inherits(x, trans_chain)) {
    paste0("chain (", length(x@steps), " steps)")
  } else {
    "unknown"
  }
}

#' Format a `drawable` for printing
#'
#' Reports the drawable's own class name, its subclass-specific
#' properties (i.e. every property besides `style`/`geometry`/`trans`/
#' `pathlike`/`points`, which every `drawable` already shares), a short
#' `style` summary (`color`/`fill`/`linewidth` only -- the properties most
#' relevant at a glance), and `geometry`/`trans`. `points` itself is
#' deliberately omitted, since it's a computed property that can be
#' expensive (e.g. noise-based) or long (many points) to print in full --
#' access `@points` directly to see it.
#'
#' @param x A [drawable].
#' @param ... Currently unused.
#' @return A character vector, one element per printed line.
#' @export
#' @noRd
method(format, drawable) <- function(x, ...) {
  own_props <- setdiff(S7::prop_names(x), c("style", "geometry", "trans", "pathlike", "points"))
  detail_line <- if (length(own_props) > 0) {
    prop_strs <- purrr::map_chr(
      own_props,
      \(p) paste0(p, " = ", format_prop_value(S7::prop(x, p)))
    )
    paste0("  ", paste(prop_strs, collapse = ", "))
  }
  style_line <- paste0(
    "  style: color = ", format_prop_value(x@style@color),
    ", fill = ", format_fill_summary(x@style@fill),
    ", linewidth = ", format_prop_value(x@style@linewidth)
  )
  geometry_line <- paste0(
    "  geometry: ", x@geometry, ", trans: ", format_trans_summary(x@trans)
  )
  c(paste0("<", S7::S7_class(x)@name, ">"), detail_line, style_line, geometry_line)
}

#' Print a `drawable`
#'
#' @param x A [drawable].
#' @param ... Currently unused.
#' @export
#' @noRd
method(print, drawable) <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' Format a `sketch` for printing
#'
#' Reports the number of shapes, each shape's own class name in order,
#' and a short summary of `canvas`'s `background`/`clip` settings.
#'
#' @param x A [sketch].
#' @param ... Currently unused.
#' @return A character vector, one element per printed line.
#' @export
#' @noRd
method(format, sketch) <- function(x, ...) {
  n <- length(x@shapes)
  header <- paste0("<sketch: ", n, " shape", if (n != 1) "s" else "", ">")
  shape_lines <- if (n > 0) {
    paste0("  ", seq_len(n), ": ", purrr::map_chr(x@shapes, \(d) S7::S7_class(d)@name))
  }
  canvas_line <- paste0(
    "  canvas: background = ", format_fill_summary(x@canvas@background),
    ", clip = ", x@canvas@clip
  )
  c(header, shape_lines, canvas_line)
}

#' Print a `sketch`
#'
#' @param x A [sketch].
#' @param ... Currently unused.
#' @export
#' @noRd
method(print, sketch) <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}
