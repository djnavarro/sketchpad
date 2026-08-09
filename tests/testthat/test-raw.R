test_that("curve_raw() defaults to path geometry", {
  expect_identical(curve_raw(x = c(0, 1), y = c(0, 1))@geometry, "path")
})

test_that("curve_raw() points are exactly its input coordinates", {
  cr <- curve_raw(x = c(0, 1, 2), y = c(0, 1, 0))
  expect_equal(cr@points@x, c(0, 1, 2))
  expect_equal(cr@points@y, c(0, 1, 0))
})

test_that("curve_raw() places no minimum on the number of points", {
  expect_no_error(curve_raw(x = 0, y = 0))
  expect_no_error(curve_raw(x = numeric(0), y = numeric(0)))
})

test_that("curve_raw() validates x/y are the same length", {
  expect_error(curve_raw(x = c(0, 1), y = c(0, 1, 2)))
})

test_that("draw() renders a curve_raw() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(curve_raw(x = c(0, 0.5, 1), y = c(0, 1, 0))))
})

test_that("curve_raw() accepts stroke styling via style()", {
  cr <- curve_raw(x = c(0, 1), y = c(0, 1), color = "red", linewidth = 3, linetype = "dashed")
  expect_identical(cr@style@color, "red")
  expect_identical(cr@style@linewidth, 3)
  expect_identical(cr@style@linetype, "dashed")
})

test_that("points_raw() defaults to points geometry", {
  expect_identical(points_raw(x = c(0, 1), y = c(0, 1))@geometry, "points")
})

test_that("points_raw() points are exactly its input coordinates", {
  pr <- points_raw(x = c(0, 1, 2), y = c(0, 1, 0))
  expect_equal(pr@points@x, c(0, 1, 2))
  expect_equal(pr@points@y, c(0, 1, 0))
})

test_that("points_raw() places no minimum on the number of points", {
  expect_no_error(points_raw(x = 0, y = 0))
  expect_no_error(points_raw(x = numeric(0), y = numeric(0)))
})

test_that("points_raw() validates x/y are the same length", {
  expect_error(points_raw(x = c(0, 1), y = c(0, 1, 2)))
})

test_that("draw() renders a points_raw() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(points_raw(x = c(0, 0.5, 1), y = c(0, 1, 0))))
})

test_that("points_raw() accepts a marker color via style()", {
  pr <- points_raw(x = c(0, 1), y = c(0, 1), color = "red")
  expect_identical(pr@style@color, "red")
})
