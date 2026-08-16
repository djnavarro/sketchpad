#' Coerce an integerish value to a genuine integer
#'
#' Many constructor arguments are conceptually whole-number counts or seeds
#' (`n`, `seed`, `octaves`, `n_harmonics`, `resolution`, ...) but are backed
#' by `S7::class_integer` properties, which reject a plain numeric literal
#' like `100` (a `double`) unless explicitly suffixed `100L`. This helper
#' accepts any numeric value within floating-point tolerance of a whole
#' number and coerces it to a true `integer`, so a constructor can accept
#' `n = 100` as readily as `n = 100L`. Anything else (non-numeric, `NA`, or
#' genuinely fractional, e.g. `n = 12.5`) errors with a message naming the
#' offending argument -- called from each affected constructor, before its
#' own `S7::new_object()` call, so the underlying property can stay a
#' strictly-typed `integer` with no change to its own class or validator.
#'
#' @param x A numeric or integer vector.
#' @param arg_name Argument name to use in the error message.
#' @return `x` coerced to `integer`.
#' @noRd
as_integerish <- function(x, arg_name) {
  if (!is.numeric(x) || anyNA(x) ||
    any(abs(x - round(x)) > sqrt(.Machine$double.eps))) {
    rlang::abort(paste0(arg_name, " must be integerish (a whole number)"))
  }
  as.integer(round(x))
}
