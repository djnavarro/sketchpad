test_that("shape_ellipse has n points", {
  expect_length(shape_ellipse(n = 37L)@points@x, 37)
  expect_length(shape_ellipse(n = 37L)@points@y, 37)
})

test_that("shape_ellipse's points lie on the given ellipse around its centroid", {
  e <- shape_ellipse(x = 2, y = -1, x_radius = 3, y_radius = 5, n = 50L)
  d <- ((e@points@x - 2) / 3)^2 + ((e@points@y + 1) / 5)^2
  expect_equal(d, rep(1, 50), tolerance = 1e-12)
})

test_that("shape_ellipse with equal radii matches shape_circle", {
  e <- shape_ellipse(x = 1, y = 1, x_radius = 2, y_radius = 2, n = 20L)
  c <- shape_circle(x = 1, y = 1, radius = 2, n = 20L)
  expect_equal(e@points@x, c@points@x, tolerance = 1e-12)
  expect_equal(e@points@y, c@points@y, tolerance = 1e-12)
})

test_that("shape_ellipse closes exactly (first point equals last point)", {
  e <- shape_ellipse(x = 1, y = 1, x_radius = 2, y_radius = 3, n = 40L)
  expect_equal(e@points@x[1], e@points@x[40])
  expect_equal(e@points@y[1], e@points@y[40])
})

test_that("a zero-radius ellipse collapses to its centroid", {
  e <- shape_ellipse(x = 1, y = 2, x_radius = 0, y_radius = 0, n = 10L)
  expect_equal(e@points@x, rep(1, 10))
  expect_equal(e@points@y, rep(2, 10))
})

test_that("shape_ellipse validates its scalar arguments", {
  expect_error(shape_ellipse(x = c(0, 1)))
  expect_error(shape_ellipse(y = c(0, 1)))
  expect_error(shape_ellipse(x_radius = c(1, 2)))
  expect_error(shape_ellipse(y_radius = c(1, 2)))
  expect_error(shape_ellipse(n = c(10L, 20L)))
})

test_that("shape_ellipse rejects a negative radius or a non-positive n", {
  expect_error(shape_ellipse(x_radius = -1), "x_radius")
  expect_error(shape_ellipse(y_radius = -1), "y_radius")
  expect_error(shape_ellipse(n = 0L), "n")
})
