test_that("curve_bezier() defaults to path geometry", {
  cb <- curve_bezier(x = c(0, 1), y = c(0, 1), n = 50L)
  expect_identical(cb@geometry, "path")
})

test_that("a two-point curve_bezier() is a straight line", {
  cb <- curve_bezier(x = c(0, 1), y = c(0, 1), n = 50L)
  expect_equal(cb@points@x, seq(0, 1, length.out = 50))
  expect_equal(cb@points@y, seq(0, 1, length.out = 50))
})

test_that("curve_bezier() and shape_bezier() compute identical points", {
  x <- c(0, 0.2, 0.8, 1)
  y <- c(0, 1, -1, 0)
  cb <- curve_bezier(x = x, y = y, n = 100L)
  sb <- shape_bezier(x = x, y = y, n = 100L)
  expect_equal(cb@points@x, sb@points@x)
  expect_equal(cb@points@y, sb@points@y)
})

test_that("curve_bezier() validates control point lengths", {
  expect_error(curve_bezier(x = c(0, 1), y = c(0, 1, 2)))
  expect_error(curve_bezier(x = 0, y = 0))
})

test_that("draw() renders a curve_bezier() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(curve_bezier(x = c(0, 0.5, 1), y = c(0, 1, 0))))
})

test_that("curve_bezier() accepts stroke styling via style()", {
  cb <- curve_bezier(x = c(0, 1), y = c(0, 1), color = "red", linewidth = 3, linetype = "dashed")
  expect_identical(cb@style@color, "red")
  expect_identical(cb@style@linewidth, 3)
  expect_identical(cb@style@linetype, "dashed")
})
