test_that("a strokepath's backbone follows its input curve's endpoints", {
  r <- shape_strokepath(
    curve_bezier(
      x = c(0, 0.25, 0.75, 1), y = c(0, 1, -1, 0), n = 50L
    ),
    width = 0, n = 50L
  )
  expect_equal(r@x[1], 0)
  expect_equal(r@y[1], 0)
  expect_equal(r@x[50], 1)
  expect_equal(r@y[50], 0)
})

test_that("a zero-width strokepath collapses onto its backbone", {
  r <- shape_strokepath(
    curve_bezier(x = c(0, 0.5, 0.5, 1), y = c(0, 0, 1, 1), n = 20L),
    width = 0, n = 20L
  )
  # width 0 means both sides of the ribbon sit exactly on the backbone,
  # so the two halves of `points` (front, then reversed back) coincide
  expect_equal(r@points@x[1:20], rev(r@points@x[21:40]))
  expect_equal(r@points@y[1:20], rev(r@points@y[21:40]))
  expect_equal(r@points@x[1], 0)
  expect_equal(r@points@y[1], 0)
  expect_equal(r@points@x[20], 1)
  expect_equal(r@points@y[20], 1)
})

test_that("a strokepath's width varies once width > 0", {
  r <- shape_strokepath(
    curve_bezier(x = c(0, 0.25, 0.75, 1), y = c(0, 1, -1, 0), n = 30L),
    width = 0.3, n = 30L
  )
  top <- r@points@y[1:30]
  bottom <- rev(r@points@y[31:60])
  expect_true(any(abs(top - bottom) > 1e-9))
})

test_that("a strokepath is reproducible for a given seed, and varies across seeds", {
  path <- curve_line(x = c(0, 1), y = c(0, 0))
  r1 <- shape_strokepath(path, width = 0.3, n = 30L, distortion = noise_field(seed = 3L))
  r2 <- shape_strokepath(path, width = 0.3, n = 30L, distortion = noise_field(seed = 3L))
  r3 <- shape_strokepath(path, width = 0.3, n = 30L, distortion = noise_field(seed = 4L))
  expect_identical(r1@points, r2@points)
  expect_false(isTRUE(all.equal(r1@points@y, r3@points@y)))
})

test_that("shape_strokepath() works with a non-Bezier backbone", {
  r <- shape_strokepath(
    curve_twist(
      x = 0, y = 0, xend = 1, yend = 0,
      path_distortion = noise_bridge(seed = 7734L), n = 40L
    ),
    width = 0.2, n = 40L
  )
  expect_s3_class(r, "sketchpad::shape_stroke")
  expect_equal(length(r@points@x), 80L)
})

test_that("shape_strokepath() validates its path argument", {
  expect_error(shape_strokepath(1))
  expect_error(shape_strokepath(shape_circle()))
  expect_error(shape_strokepath(curve_line(x = c(0, 1), y = c(0, 0)), width = -1))
  expect_error(shape_strokepath(curve_line(x = c(0, 1), y = c(0, 0)), n = 1L))
})
