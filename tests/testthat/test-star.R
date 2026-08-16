test_that("shape_star has 2n distinct vertices (no closing repeat)", {
  s <- shape_star(n = 5L)
  expect_length(s@points@x, 10)
  expect_length(s@points@y, 10)
  expect_false(s@points@x[1] == s@points@x[10] && s@points@y[1] == s@points@y[10])
})

test_that("shape_star's vertices alternate outer_radius and inner_radius from its centroid", {
  s <- shape_star(x = 2, y = -1, outer_radius = 3, inner_radius = 1, n = 6L)
  d <- sqrt((s@points@x - 2)^2 + (s@points@y + 1)^2)
  expect_equal(d, rep(c(3, 1), 6), tolerance = 1e-12)
})

test_that("shape_star's first vertex is an outer vertex at angle 0", {
  s <- shape_star(x = 0, y = 0, outer_radius = 2, n = 4L)
  expect_equal(s@points@x[1], 2)
  expect_equal(s@points@y[1], 0, tolerance = 1e-12)
})

test_that("inner_radius = 0 collapses every inner vertex onto the centroid", {
  s <- shape_star(x = 1, y = 2, outer_radius = 3, inner_radius = 0, n = 5L)
  inner <- seq(2, 10, by = 2)
  expect_equal(s@points@x[inner], rep(1, 5))
  expect_equal(s@points@y[inner], rep(2, 5))
})

test_that("inner_radius = outer_radius degenerates to a regular 2n-gon", {
  s <- shape_star(outer_radius = 2, inner_radius = 2, n = 5L)
  p <- shape_polygon(radius = 2, n = 10L)
  expect_equal(s@points@x, p@points@x, tolerance = 1e-12)
  expect_equal(s@points@y, p@points@y, tolerance = 1e-12)
})

test_that("shape_star validates its scalar arguments", {
  expect_error(shape_star(x = c(0, 1)))
  expect_error(shape_star(y = c(0, 1)))
  expect_error(shape_star(outer_radius = c(1, 2)))
  expect_error(shape_star(inner_radius = c(0.1, 0.2)))
  expect_error(shape_star(n = c(5L, 6L)))
})

test_that("shape_star rejects invalid radii or too few points", {
  expect_error(shape_star(outer_radius = -1), "outer_radius")
  expect_error(shape_star(inner_radius = -0.1), "inner_radius")
  expect_error(shape_star(outer_radius = 1, inner_radius = 1.5), "inner_radius")
  expect_error(shape_star(n = 1L), "n")
})

test_that("draw() renders a shape_star() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(shape_star()))
})

test_that("shape_stars() vectorizes n like every other argument", {
  s <- shape_stars(n = c(4L, 5L, 6L))
  expect_length(s, 3)
  expect_equal(purrr::map_int(s@shapes, \(x) x@n), c(4L, 5L, 6L))
})
