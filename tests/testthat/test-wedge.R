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

test_that("inner_radius defaults to 0 and reproduces the pie-slice outline exactly", {
  w <- shape_wedge(x = 1, y = -2, radius = 3, start = 0.2, end = 2, n = 20L)
  expect_identical(w@inner_radius, 0)
  expect_identical(
    w@points,
    shape_wedge(x = 1, y = -2, radius = 3, inner_radius = 0, start = 0.2, end = 2, n = 20L)@points
  )
})

test_that("inner_radius > 0 drops the centroid vertex and adds a reversed inner arc", {
  w <- shape_wedge(x = 0, y = 0, radius = 2, inner_radius = 1, start = 0, end = pi / 2, n = 10L)
  expect_length(w@points@x, 20)

  outer <- w@points@x[1:10]
  inner <- w@points@x[11:20]
  outer_y <- w@points@y[1:10]
  inner_y <- w@points@y[11:20]

  # outer arc at radius 2, sweeping start -> end
  angle <- seq(0, pi / 2, length.out = 10L)
  expect_equal(outer, 2 * cos(angle))
  expect_equal(outer_y, 2 * sin(angle))

  # inner arc at radius 1, swept back end -> start
  expect_equal(inner, 1 * cos(rev(angle)))
  expect_equal(inner_y, 1 * sin(rev(angle)))
})

test_that("inner_radius validates as non-negative and no greater than radius", {
  expect_error(shape_wedge(inner_radius = -0.1), "inner_radius")
  expect_error(shape_wedge(radius = 1, inner_radius = 1.5), "inner_radius")
  expect_error(shape_wedge(inner_radius = c(0.1, 0.2)), "inner_radius")
  expect_no_error(shape_wedge(radius = 1, inner_radius = 1))
})

test_that("a full sweep with inner_radius > 0 gives a complete annulus", {
  ring <- shape_wedge(radius = 1, inner_radius = 0.5, start = 0, end = 2 * pi, n = 50L)
  outer_d <- sqrt(ring@points@x[1:50]^2 + ring@points@y[1:50]^2)
  inner_d <- sqrt(ring@points@x[51:100]^2 + ring@points@y[51:100]^2)
  expect_equal(outer_d, rep(1, 50), tolerance = 1e-12)
  expect_equal(inner_d, rep(0.5, 50), tolerance = 1e-12)
})

test_that("draw() renders a ring-slice shape_wedge() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(shape_wedge(inner_radius = 0.5)))
})

test_that("shape_wedges() vectorizes inner_radius like every other argument", {
  s <- shape_wedges(inner_radius = c(0, 0.3, 0.6), start = 0, end = pi / 2)
  expect_length(s, 3)
  expect_equal(purrr::map_dbl(s@shapes, \(w) w@inner_radius), c(0, 0.3, 0.6))
})
