test_that("curve_arc() defaults to path geometry", {
  expect_identical(curve_arc()@geometry, "path")
})

test_that("curve_arc() has n points, with no centroid vertex", {
  ca <- curve_arc(n = 37L)
  expect_length(ca@points@x, 37)
  expect_length(ca@points@y, 37)
})

test_that("curve_arc() and shape_wedge() compute identical arc points", {
  ca <- curve_arc(x = 1, y = -2, radius = 2, start = 0, end = pi, n = 20L)
  sw <- shape_wedge(x = 1, y = -2, radius = 2, start = 0, end = pi, n = 20L)
  expect_equal(ca@points@x, sw@points@x[-1])
  expect_equal(ca@points@y, sw@points@y[-1])
})

test_that("curve_arc()'s points lie at the given radius from its centroid", {
  ca <- curve_arc(x = 2, y = -1, radius = 3, n = 50L)
  d <- sqrt((ca@points@x - 2)^2 + (ca@points@y + 1)^2)
  expect_equal(d, rep(3, 50), tolerance = 1e-12)
})

test_that("curve_arc() validates its scalar arguments", {
  expect_error(curve_arc(x = c(0, 1)))
  expect_error(curve_arc(radius = c(1, 2)))
  expect_error(curve_arc(n = c(10L, 20L)))
})

test_that("curve_arc() rejects a negative radius or too few points", {
  expect_error(curve_arc(radius = -1), "radius")
  expect_error(curve_arc(n = 1L), "n")
})

test_that("draw() renders a curve_arc() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(curve_arc()))
})

test_that("curve_arc() accepts stroke styling via style()", {
  ca <- curve_arc(color = "red", linewidth = 3, linetype = "dashed")
  expect_identical(ca@style@color, "red")
  expect_identical(ca@style@linewidth, 3)
  expect_identical(ca@style@linetype, "dashed")
})
