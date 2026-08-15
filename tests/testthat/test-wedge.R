test_that("shape_wedge has n + 1 points (centroid plus the arc)", {
  w <- shape_wedge(n = 37L)
  expect_length(w@points@x, 38)
  expect_length(w@points@y, 38)
})

test_that("shape_wedge's first point is its centroid", {
  w <- shape_wedge(x = 2, y = -1, radius = 3, n = 10L)
  expect_equal(w@points@x[1], 2)
  expect_equal(w@points@y[1], -1)
})

test_that("shape_wedge's arc points lie at the given radius from its centroid", {
  w <- shape_wedge(x = 2, y = -1, radius = 3, start = 0, end = pi, n = 50L)
  arc_x <- w@points@x[-1]
  arc_y <- w@points@y[-1]
  d <- sqrt((arc_x - 2)^2 + (arc_y + 1)^2)
  expect_equal(d, rep(3, 50), tolerance = 1e-12)
})

test_that("shape_wedge's arc sweeps from start to end", {
  w <- shape_wedge(x = 0, y = 0, radius = 1, start = 0, end = pi / 2, n = 5L)
  angle <- seq(0, pi / 2, length.out = 5L)
  expect_equal(w@points@x[-1], cos(angle))
  expect_equal(w@points@y[-1], sin(angle))
})

test_that("a zero-radius wedge collapses to its centroid", {
  w <- shape_wedge(x = 1, y = 2, radius = 0, n = 10L)
  expect_equal(w@points@x, rep(1, 11))
  expect_equal(w@points@y, rep(2, 11))
})

test_that("shape_wedge validates its scalar arguments", {
  expect_error(shape_wedge(x = c(0, 1)))
  expect_error(shape_wedge(y = c(0, 1)))
  expect_error(shape_wedge(radius = c(1, 2)))
  expect_error(shape_wedge(start = c(0, 1)))
  expect_error(shape_wedge(end = c(0, 1)))
  expect_error(shape_wedge(n = c(10L, 20L)))
})

test_that("shape_wedge rejects a negative radius or too few arc points", {
  expect_error(shape_wedge(radius = -1), "radius")
  expect_error(shape_wedge(n = 1L), "n")
})

test_that("draw() renders a shape_wedge() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(shape_wedge()))
})
