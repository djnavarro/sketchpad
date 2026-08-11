test_that("curve_twist defaults to path geometry", {
  expect_identical(curve_twist()@geometry, "path")
})

test_that("curve_twist has n points", {
  ct <- curve_twist(n = 40L)
  expect_length(ct@points@x, 40)
  expect_length(ct@points@y, 40)
})

test_that("a zero-scale twist is exactly the straight backbone", {
  ct <- curve_twist(x = 0, y = 0, xend = 1, yend = 2, scale = 0, n = 30L)
  expect_equal(ct@points@x, seq(0, 1, length.out = 30))
  expect_equal(ct@points@y, seq(0, 2, length.out = 30))
})

test_that("curve_twist's path deviates from a straight line once scale > 0", {
  ct <- curve_twist(x = 0, y = 0, xend = 1, yend = 1, scale = 1, n = 40L)
  straight_x <- seq(0, 1, length.out = 40)
  expect_false(isTRUE(all.equal(ct@points@x, straight_x)))
})

test_that("curve_twist matches shape_twist's own path for the same arguments", {
  args <- list(x = 0, y = 0.5, xend = 1, yend = -0.5, n = 25L)
  pd <- noise_bridge(seed = 42L, smooth = 2)
  ct <- do.call(curve_twist, c(args, list(scale = 0.3, path_distortion = pd)))
  st <- do.call(shape_twist, c(args, list(width = 0.3, path_distortion = pd)))
  expect_equal(ct@points, st@path)
})

test_that("curve_twist is reproducible for a given seed, and varies across seeds", {
  t1 <- curve_twist(scale = 1, path_distortion = noise_bridge(seed = 7L))
  t2 <- curve_twist(scale = 1, path_distortion = noise_bridge(seed = 7L))
  t3 <- curve_twist(scale = 1, path_distortion = noise_bridge(seed = 8L))
  expect_identical(t1@points, t2@points)
  expect_false(isTRUE(all.equal(t1@points@x, t3@points@x)))
})

test_that("curve_twist validates its scalar arguments", {
  expect_error(curve_twist(x = c(0, 1)))
  expect_error(curve_twist(xend = c(0, 1)))
  expect_error(curve_twist(scale = c(0.1, 0.2)))
})

test_that("curve_twist rejects invalid non-negative/positive arguments", {
  expect_error(curve_twist(scale = -1), "scale")
  expect_error(curve_twist(n = 0L), "n")
})
