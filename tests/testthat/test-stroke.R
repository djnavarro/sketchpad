test_that("shape_stroke's outline has 2n points", {
  s <- shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), n = 30L)
  expect_length(s@points@x, 60)
  expect_length(s@points@y, 60)
})

test_that("a zero-width stroke collapses onto its resampled backbone", {
  s <- shape_stroke(x = c(0, 1), y = c(0, 0), width = 0, n = 30L)
  backbone_x <- seq(0, 1, length.out = 30)
  backbone_y <- rep(0, 30)
  expect_equal(s@points@x, c(backbone_x, rev(backbone_x)))
  expect_equal(s@points@y, c(backbone_y, rev(backbone_y)))
})

test_that("shape_stroke's width varies once width > 0", {
  s <- shape_stroke(x = c(0, 1), y = c(0, 0), width = 0.3, n = 30L)
  top <- s@points@y[1:30]
  bottom <- rev(s@points@y[31:60])
  expect_true(any(abs(top - bottom) > 1e-9))
})

test_that("shape_stroke's taper goes to zero at both ends", {
  s <- shape_stroke(x = c(0, 1), y = c(0, 0), width = 0.3, n = 30L)
  expect_equal(s@points@y[1], 0)
  expect_equal(s@points@y[30], 0)
})

test_that("shape_stroke follows a bending path rather than a global chord", {
  # a right-angle bend: a global (non-per-point) offset direction would
  # skew the outline visibly away from the backbone near the corner
  s <- shape_stroke(x = c(0, 1, 1), y = c(0, 0, 1), width = 0.2, n = 61L)
  # every offset point should stay within a bounding box that pads the
  # backbone's own bounding box by at most half the max width
  expect_true(all(s@points@x >= -0.11 & s@points@x <= 1.11))
  expect_true(all(s@points@y >= -0.11 & s@points@y <= 1.11))
})

test_that("shape_stroke is reproducible for a given seed, and varies across seeds", {
  s1 <- shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), distortion = noise_field(seed = 3L))
  s2 <- shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), distortion = noise_field(seed = 3L))
  s3 <- shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), distortion = noise_field(seed = 4L))
  expect_identical(s1@points, s2@points)
  expect_false(isTRUE(all.equal(s1@points@x, s3@points@x)))
})

test_that("shape_stroke validates x/y", {
  expect_error(shape_stroke(x = c(0, 1), y = 0))
  expect_error(shape_stroke(x = 0, y = 0))
})

test_that("shape_stroke rejects invalid non-negative/positive arguments", {
  expect_error(shape_stroke(x = c(0, 1), y = c(0, 1), width = -1), "width")
  expect_error(shape_stroke(x = c(0, 1), y = c(0, 1), n = 1L), "n")
})

test_that("shape_strokes() vectorizes over a list of control point vectors", {
  sk <- shape_strokes(
    x = list(c(0, 1, 2), c(0, 1, 2)),
    y = list(c(0, 1, 0), c(1, 2, 1)),
    width = 0.2
  )
  expect_s3_class(sk, "sketchpad::sketch")
  expect_length(sk, 2)
})
