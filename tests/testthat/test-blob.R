test_that("shape_blob has n points", {
  expect_length(shape_blob(n = 64L)@points@x, 64)
  expect_length(shape_blob(n = 64L)@points@y, 64)
})

test_that("shape_blob with range = 0 reduces to a circle of the given radius", {
  b <- shape_blob(x = 1, y = -2, radius = 2, range = 0, n = 80L)
  d <- sqrt((b@points@x - 1)^2 + (b@points@y + 2)^2)
  expect_equal(d, rep(2, 80), tolerance = 1e-6)
})

test_that("shape_blob's radius varies once range > 0", {
  b <- shape_blob(radius = 2, range = 0.5, n = 80L)
  d <- sqrt(b@points@x^2 + b@points@y^2)
  expect_true(diff(range(d)) > 0)
  expect_true(all(d >= 2 - 0.5 - 1e-9 & d <= 2 + 0.5 + 1e-9))
})

test_that("shape_blob is reproducible for a given seed, and varies across seeds", {
  b1 <- shape_blob(seed = 5L)
  b2 <- shape_blob(seed = 5L)
  b3 <- shape_blob(seed = 6L)
  expect_identical(b1@points, b2@points)
  expect_false(isTRUE(all.equal(b1@points@x, b3@points@x)))
})

test_that("shape_blob validates its scalar arguments", {
  expect_error(shape_blob(x = c(0, 1)))
  expect_error(shape_blob(radius = c(1, 2)))
  expect_error(shape_blob(range = c(0, 1)))
  expect_error(shape_blob(frequency = c(1, 2)))
  expect_error(shape_blob(octaves = c(1L, 2L)))
  expect_error(shape_blob(seed = c(1L, 2L)))
})

test_that("shape_blob rejects invalid non-negative/positive arguments", {
  expect_error(shape_blob(radius = -1), "radius")
  expect_error(shape_blob(range = -1), "range")
  expect_error(shape_blob(frequency = -1), "frequency")
  expect_error(shape_blob(octaves = 0L), "octaves")
  expect_error(shape_blob(n = 0L), "n")
})
