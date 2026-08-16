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

test_that("shape_raw() defaults id to a single sub-path", {
  sr <- shape_raw(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1))
  expect_identical(sr@points@id, rep(1L, 4))
})

test_that("shape_raw() accepts an explicit id", {
  sr <- shape_raw(x = c(0, 0, 1, 1, 2, 2, 3, 3), y = c(0, 1, 1, 0, 0, 1, 1, 0), id = rep(1:2, each = 4))
  expect_identical(sr@points@id, rep(1L:2L, each = 4))
})

test_that("shape_raw() validates id is the same length as x/y", {
  expect_error(shape_raw(x = c(0, 1), y = c(0, 1), id = c(1, 1, 2)))
})

test_that("curve_raw() defaults id to a single sub-path, and accepts an explicit one", {
  cr <- curve_raw(x = c(0, 1, 2), y = c(0, 1, 0))
  expect_identical(cr@points@id, rep(1L, 3))
  cr2 <- curve_raw(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), id = c(1, 1, 2, 2))
  expect_identical(cr2@points@id, c(1L, 1L, 2L, 2L))
})

test_that("points_raw() defaults id to a single sub-path, and accepts an explicit one", {
  pr <- points_raw(x = c(0, 1), y = c(0, 1))
  expect_identical(pr@points@id, rep(1L, 2))
  pr2 <- points_raw(x = c(0, 1, 2), y = c(0, 1, 2), id = c(1, 2, 2))
  expect_identical(pr2@points@id, c(1L, 2L, 2L))
})

test_that("shape_raws()/curve_raws()/points_raws() forward id as a list, one per shape", {
  s <- shape_raws(
    x = list(c(0, 1, 1, 0), c(2, 3, 3, 2)),
    y = list(c(0, 0, 1, 1), c(0, 0, 1, 1)),
    id = list(c(1, 1, 2, 2), NULL)
  )
  expect_identical(s[[1]]@points@id, c(1L, 1L, 2L, 2L))
  expect_identical(s[[2]]@points@id, rep(1L, 4))
})

test_that("shape_raws()/curve_raws()/points_raws() default id per shape when omitted entirely", {
  s <- shape_raws(x = list(c(0, 1, 1, 0), c(2, 3, 3, 2)), y = list(c(0, 0, 1, 1), c(0, 0, 1, 1)))
  expect_identical(s[[1]]@points@id, rep(1L, 4))
  expect_identical(s[[2]]@points@id, rep(1L, 4))
})

test_that("multi-sub-path shape_raw()/curve_raw() render without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  holed <- shape_raw(
    x = c(0, 0, 4, 4, 1, 1, 3, 3), y = c(0, 4, 4, 0, 1, 3, 3, 1),
    id = rep(1:2, each = 4), fill = "steelblue"
  )
  expect_no_error(draw(holed))
  disjoint_curve <- curve_raw(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), id = c(1, 1, 2, 2))
  expect_no_error(draw(disjoint_curve))
})
