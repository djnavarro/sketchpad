test_that("shape_circle has n points", {
  expect_length(shape_circle(n = 37L)@points@x, 37)
  expect_length(shape_circle(n = 37L)@points@y, 37)
})

test_that("shape_circle's points lie at the given radius from its centroid", {
  c <- shape_circle(x = 2, y = -1, radius = 3, n = 50L)
  d <- sqrt((c@points@x - 2)^2 + (c@points@y + 1)^2)
  expect_equal(d, rep(3, 50), tolerance = 1e-12)
})

test_that("shape_circle closes exactly (first point equals last point)", {
  c <- shape_circle(x = 1, y = 1, radius = 2, n = 40L)
  expect_equal(c@points@x[1], c@points@x[40])
  expect_equal(c@points@y[1], c@points@y[40])
})

test_that("a zero-radius circle collapses to its centroid", {
  c <- shape_circle(x = 1, y = 2, radius = 0, n = 10L)
  expect_equal(c@points@x, rep(1, 10))
  expect_equal(c@points@y, rep(2, 10))
})

test_that("shape_circle validates its scalar arguments", {
  expect_error(shape_circle(x = c(0, 1)))
  expect_error(shape_circle(y = c(0, 1)))
  expect_error(shape_circle(radius = c(1, 2)))
  expect_error(shape_circle(n = c(10L, 20L)))
})

test_that("shape_circle rejects a negative radius or a non-positive n", {
  expect_error(shape_circle(radius = -1), "radius")
  expect_error(shape_circle(n = 0L), "n")
})
