test_that("a two-point bezier is a straight line", {
  b <- shape_bezier(x = c(0, 1), y = c(0, 1), n = 50L)
  expect_equal(b@points@x, seq(0, 1, length.out = 50))
  expect_equal(b@points@y, seq(0, 1, length.out = 50))
})

test_that("a cubic bezier starts and ends at its endpoint controls", {
  b <- shape_bezier(x = c(0, 0.2, 0.8, 1), y = c(0, 1, -1, 0), n = 100L)
  expect_equal(b@points@x[1], 0)
  expect_equal(b@points@x[100], 1)
  expect_equal(b@points@y[1], 0)
  expect_equal(b@points@y[100], 0)
})

test_that("bezier validates control point lengths", {
  expect_error(shape_bezier(x = c(0, 1), y = c(0, 1, 2)))
  expect_error(shape_bezier(x = 0, y = 0))
})

