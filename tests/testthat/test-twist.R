test_that("shape_twist's outline has 2n points", {
  t <- shape_twist(n = 25L)
  expect_length(t@points@x, 50)
  expect_length(t@points@y, 50)
})

test_that("a zero-width twist's path is exactly the straight backbone", {
  # width also scales the Brownian-bridge displacement itself, so
  # width = 0 collapses the path to a straight line regardless of smooth/seed
  t <- shape_twist(x = 0, y = 0, xend = 1, yend = 1, width = 0, n = 40L)
  expect_equal(t@path@x, seq(0, 1, length.out = 40))
  expect_equal(t@path@y, seq(0, 1, length.out = 40))
})

test_that("a zero-width twist collapses onto its own (straight) path", {
  t <- shape_twist(x = 0, y = 0, xend = 1, yend = 2, width = 0, n = 20L)
  expect_equal(t@points@x, c(t@path@x, rev(t@path@x)))
  expect_equal(t@points@y, c(t@path@y, rev(t@path@y)))
})

test_that("shape_twist's path deviates from a straight line once width > 0", {
  t <- shape_twist(x = 0, y = 0, xend = 1, yend = 1, width = 1, n = 40L)
  straight_x <- seq(0, 1, length.out = 40)
  expect_false(isTRUE(all.equal(t@path@x, straight_x)))
})

test_that("shape_twist is reproducible for a given seed, and varies across seeds", {
  t1 <- shape_twist(width = 1, seed = 7L)
  t2 <- shape_twist(width = 1, seed = 7L)
  t3 <- shape_twist(width = 1, seed = 8L)
  expect_identical(t1@points, t2@points)
  expect_false(isTRUE(all.equal(t1@points@x, t3@points@x)))
})

test_that("shape_twist validates its scalar arguments", {
  expect_error(shape_twist(x = c(0, 1)))
  expect_error(shape_twist(xend = c(0, 1)))
  expect_error(shape_twist(width = c(0.1, 0.2)))
  expect_error(shape_twist(frequency = c(1, 2)))
  expect_error(shape_twist(octaves = c(1L, 2L)))
  expect_error(shape_twist(seed = c(1L, 2L)))
})

test_that("shape_twist rejects invalid non-negative/positive arguments", {
  expect_error(shape_twist(width = -1), "width")
  expect_error(shape_twist(frequency = -1), "frequency")
  expect_error(shape_twist(n = 0L), "n")
  expect_error(shape_twist(octaves = 0L), "octaves")
})
