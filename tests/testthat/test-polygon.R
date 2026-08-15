test_that("shape_polygon has n distinct vertices (no closing repeat)", {
  p <- shape_polygon(n = 5L)
  expect_length(p@points@x, 5)
  expect_length(p@points@y, 5)
  expect_false(p@points@x[1] == p@points@x[5] && p@points@y[1] == p@points@y[5])
})

test_that("shape_polygon's vertices lie at the given radius from its centroid", {
  p <- shape_polygon(x = 2, y = -1, radius = 3, n = 7L)
  d <- sqrt((p@points@x - 2)^2 + (p@points@y + 1)^2)
  expect_equal(d, rep(3, 7), tolerance = 1e-12)
})

test_that("a zero-radius polygon collapses to its centroid", {
  p <- shape_polygon(x = 1, y = 2, radius = 0, n = 4L)
  expect_equal(p@points@x, rep(1, 4))
  expect_equal(p@points@y, rep(2, 4))
})

test_that("shape_polygon validates its scalar arguments", {
  expect_error(shape_polygon(x = c(0, 1)))
  expect_error(shape_polygon(y = c(0, 1)))
  expect_error(shape_polygon(radius = c(1, 2)))
  expect_error(shape_polygon(n = c(5L, 6L)))
})

test_that("shape_polygon rejects a negative radius or fewer than 3 sides", {
  expect_error(shape_polygon(radius = -1), "radius")
  expect_error(shape_polygon(n = 2L), "n")
})
