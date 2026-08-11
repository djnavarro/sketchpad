test_that("a bezier ribbon's backbone follows its control points", {
  r <- shape_bezier_ribbon(
    x = 0, y = 0, xend = 1, yend = 0,
    x_ctrl1 = 0.25, y_ctrl1 = 1, x_ctrl2 = 0.75, y_ctrl2 = -1,
    width = 0, n = 50L
  )
  expect_equal(r@path@x[1], 0)
  expect_equal(r@path@y[1], 0)
  expect_equal(r@path@x[50], 1)
  expect_equal(r@path@y[50], 0)
})

test_that("a zero-width bezier ribbon collapses onto its backbone", {
  r <- shape_bezier_ribbon(
    x = 0, y = 0, xend = 1, yend = 1,
    x_ctrl1 = 0.5, y_ctrl1 = 0, x_ctrl2 = 0.5, y_ctrl2 = 1,
    width = 0, n = 20L
  )
  expect_equal(r@points@x, c(r@path@x, rev(r@path@x)))
  expect_equal(r@points@y, c(r@path@y, rev(r@path@y)))
})

test_that("a bezier ribbon's width varies once width > 0", {
  r <- shape_bezier_ribbon(
    x = 0, y = 0, xend = 1, yend = 0,
    x_ctrl1 = 0.25, y_ctrl1 = 1, x_ctrl2 = 0.75, y_ctrl2 = -1,
    width = 0.3, n = 30L
  )
  top <- r@points@y[1:30]
  bottom <- rev(r@points@y[31:60])
  expect_true(any(abs(top - bottom) > 1e-9))
})

test_that("a bezier ribbon is reproducible for a given seed, and varies across seeds", {
  args <- list(
    x = 0, y = 0, xend = 1, yend = 0,
    x_ctrl1 = 0.25, y_ctrl1 = 1, x_ctrl2 = 0.75, y_ctrl2 = -1,
    width = 0.3, n = 30L
  )
  r1 <- do.call(shape_bezier_ribbon, c(args, list(distortion = noise_field(seed = 3L))))
  r2 <- do.call(shape_bezier_ribbon, c(args, list(distortion = noise_field(seed = 3L))))
  r3 <- do.call(shape_bezier_ribbon, c(args, list(distortion = noise_field(seed = 4L))))
  expect_identical(r1@points, r2@points)
  # xend == x here (dy == 0 along the backbone's straight endpoints), so
  # only the y coordinates pick up the width perturbation's seed dependence
  expect_false(isTRUE(all.equal(r1@points@y, r3@points@y)))
})

test_that("a bezier ribbon validates its scalar arguments", {
  expect_error(shape_bezier_ribbon(x = c(0, 1)))
  expect_error(shape_bezier_ribbon(width = -1))
  expect_error(shape_bezier_ribbon(n = 0L))
})
