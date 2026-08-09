#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import S7
#' @importFrom ambient fracture
#' @importFrom grid viewport
#' @importFrom purrr map_dbl
#' @importFrom rlang warn
## usethis namespace: end
NULL

.onLoad <- function(libname, pkgname) {
  S7::methods_register()
}

# S7's method<- machinery references a `properties` symbol internally in a
# way that R CMD check misattributes to this package; this silences the
# resulting (spurious) "no visible binding" NOTE.
utils::globalVariables("properties")

