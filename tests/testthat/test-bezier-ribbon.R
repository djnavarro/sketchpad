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

test_that("a bezier ribbon validates its scalar arguments", {
  expect_error(shape_bezier_ribbon(x = c(0, 1)))
  expect_error(shape_bezier_ribbon(width = -1))
  expect_error(shape_bezier_ribbon(n = 0L))
  expect_error(shape_bezier_ribbon(octaves = 0L))
})
