local_null_device <- function() {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off(), envir = parent.frame())
}

test_that("shape_combine() requires at least two drawables", {
  expect_error(shape_combine(shape_circle()), "at least two")
})

test_that("shape_combine() requires drawable arguments", {
  expect_error(shape_combine(shape_circle(), "not a drawable"), "drawable")
})

test_that("shape_combine() requires polygon-geometry drawables", {
  expect_error(shape_combine(shape_circle(), curve_line(x = c(0, 1), y = c(0, 1))), "polygon")
})

test_that("shape_combine() concatenates points and assigns one id per input", {
  a <- shape_circle(x = 0, radius = 2, n = 5L)
  b <- shape_circle(x = 5, radius = 1, n = 5L)
  combined <- shape_combine(a, b)
  expect_equal(combined@points@x, c(a@points@x, b@points@x))
  expect_equal(combined@points@y, c(a@points@y, b@points@y))
  expect_identical(combined@points@id, c(rep(1L, 5), rep(2L, 5)))
})

test_that("shape_combine() renumbers an already multi-sub-path input distinctly", {
  a <- shape_raw(x = c(0, 0, 4, 4, 1, 1, 3, 3), y = c(0, 4, 4, 0, 1, 3, 3, 1), id = rep(1:2, each = 4))
  b <- shape_circle(x = 10, n = 4L)
  combined <- shape_combine(a, b)
  expect_identical(combined@points@id, c(rep(1L, 4), rep(2L, 4), rep(3L, 4)))
})

test_that("shape_combine() defaults style to the first input's own style", {
  a <- shape_circle(fill = "tomato")
  b <- shape_circle(x = 5)
  combined <- shape_combine(a, b)
  expect_identical(combined@style@fill, "tomato")
})

test_that("shape_combine() accepts an explicit style override", {
  combined <- shape_combine(shape_circle(), shape_circle(x = 5), style = style(fill = "goldenrod"))
  expect_identical(combined@style@fill, "goldenrod")
})

test_that("shape_combine() bakes in each input's own trans/distortion", {
  a <- shape_circle(radius = 1, trans = trans_translate(3, 0))
  b <- shape_circle(x = 10, radius = 1)
  combined <- shape_combine(a, b)
  expect_equal(combined@points@x[seq_along(a@points@x)], a@points@x)
})

test_that("shape_combine() returns a shape_raw", {
  expect_true(S7::S7_inherits(shape_combine(shape_circle(), shape_circle(x = 5)), shape_raw))
})

test_that("draw() renders shape_combine()'s hole and disjoint-shapes cases without error", {
  local_null_device()
  hole <- shape_combine(shape_circle(radius = 2), shape_circle(radius = 1))
  expect_no_error(draw(hole))
  disjoint <- shape_combine(shape_circle(x = 0), shape_circle(x = 5), shape_circle(x = 10))
  expect_no_error(draw(disjoint))
})
