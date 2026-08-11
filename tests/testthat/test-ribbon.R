test_that("shape_ribbon's outline has 2n points", {
  r <- shape_ribbon(n = 30L)
  expect_length(r@points@x, 60)
  expect_length(r@points@y, 60)
})

test_that("a zero-width ribbon collapses onto its straight backbone", {
  r <- shape_ribbon(x = 0, y = 0, xend = 1, yend = 2, width = 0, n = 30L)
  backbone_x <- seq(0, 1, length.out = 30)
  backbone_y <- seq(0, 2, length.out = 30)
  expect_equal(r@points@x, c(backbone_x, rev(backbone_x)))
  expect_equal(r@points@y, c(backbone_y, rev(backbone_y)))
})

test_that("shape_ribbon's width varies once width > 0", {
  r <- shape_ribbon(x = 0, y = 0, xend = 1, yend = 0, width = 0.3, n = 30L)
  # top and bottom edges (first/second half) shouldn't coincide everywhere
  top <- r@points@y[1:30]
  bottom <- rev(r@points@y[31:60])
  expect_true(any(abs(top - bottom) > 1e-9))
})

test_that("shape_ribbon is reproducible for a given seed, and varies across seeds", {
  r1 <- shape_ribbon(distortion = noise_field(seed = 3L))
  r2 <- shape_ribbon(distortion = noise_field(seed = 3L))
  r3 <- shape_ribbon(distortion = noise_field(seed = 4L))
  expect_identical(r1@points, r2@points)
  expect_false(isTRUE(all.equal(r1@points@x, r3@points@x)))
})

test_that("shape_ribbon validates its scalar arguments", {
  expect_error(shape_ribbon(x = c(0, 1)))
  expect_error(shape_ribbon(xend = c(0, 1)))
  expect_error(shape_ribbon(width = c(0.1, 0.2)))
})

test_that("shape_ribbon rejects invalid non-negative/positive arguments", {
  expect_error(shape_ribbon(width = -1), "width")
  expect_error(shape_ribbon(n = 0L), "n")
})
