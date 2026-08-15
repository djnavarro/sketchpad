test_that("shape_rectangle has four corner points", {
  expect_length(shape_rectangle()@points@x, 4)
  expect_length(shape_rectangle()@points@y, 4)
})

test_that("shape_rectangle's corners are offset by half width/height from its centroid", {
  r <- shape_rectangle(x = 2, y = -1, width = 4, height = 2)
  expect_equal(sort(unique(r@points@x)), c(0, 4))
  expect_equal(sort(unique(r@points@y)), c(-2, 0))
})

test_that("a zero-width/height rectangle collapses to its centroid", {
  r <- shape_rectangle(x = 1, y = 2, width = 0, height = 0)
  expect_equal(r@points@x, rep(1, 4))
  expect_equal(r@points@y, rep(2, 4))
})

test_that("shape_rectangle validates its scalar arguments", {
  expect_error(shape_rectangle(x = c(0, 1)))
  expect_error(shape_rectangle(y = c(0, 1)))
  expect_error(shape_rectangle(width = c(1, 2)))
  expect_error(shape_rectangle(height = c(1, 2)))
})

test_that("shape_rectangle rejects a negative width or height", {
  expect_error(shape_rectangle(width = -1), "width")
  expect_error(shape_rectangle(height = -1), "height")
})

test_that("shape_square is a shape_rectangle with equal width and height", {
  s <- shape_square(x = 1, y = 1, side = 2)
  expect_true(S7::S7_inherits(s, shape_rectangle))
  expect_equal(s@width, 2)
  expect_equal(s@height, 2)
})

test_that("shape_square rejects a negative side", {
  expect_error(shape_square(side = -1), "width")
})
