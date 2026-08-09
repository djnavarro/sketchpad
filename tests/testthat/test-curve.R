test_that("curve_bezier() defaults to path geometry", {
  cb <- curve_bezier(x = c(0, 1), y = c(0, 1), n = 50L)
  expect_identical(cb@geometry, "path")
})

test_that("a two-point curve_bezier() is a straight line", {
  cb <- curve_bezier(x = c(0, 1), y = c(0, 1), n = 50L)
  expect_equal(cb@points@x, seq(0, 1, length.out = 50))
  expect_equal(cb@points@y, seq(0, 1, length.out = 50))
})

test_that("curve_bezier() and shape_bezier() compute identical points", {
  x <- c(0, 0.2, 0.8, 1)
  y <- c(0, 1, -1, 0)
  cb <- curve_bezier(x = x, y = y, n = 100L)
  sb <- shape_bezier(x = x, y = y, n = 100L)
  expect_equal(cb@points@x, sb@points@x)
  expect_equal(cb@points@y, sb@points@y)
})

test_that("curve_bezier() validates control point lengths", {
  expect_error(curve_bezier(x = c(0, 1), y = c(0, 1, 2)))
  expect_error(curve_bezier(x = 0, y = 0))
})

test_that("draw() renders a curve_bezier() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(curve_bezier(x = c(0, 0.5, 1), y = c(0, 1, 0))))
})

test_that("curve_bezier() accepts stroke styling via style()", {
  cb <- curve_bezier(x = c(0, 1), y = c(0, 1), color = "red", linewidth = 3, linetype = "dashed")
  expect_identical(cb@style@color, "red")
  expect_identical(cb@style@linewidth, 3)
  expect_identical(cb@style@linetype, "dashed")
})

test_that("curve_line() defaults to path geometry", {
  cl <- curve_line(x = c(0, 1), y = c(0, 1))
  expect_identical(cl@geometry, "path")
})

test_that("curve_line() points are exactly its control points", {
  cl <- curve_line(x = c(0, 1, 2), y = c(0, 1, 0))
  expect_equal(cl@points@x, c(0, 1, 2))
  expect_equal(cl@points@y, c(0, 1, 0))
})

test_that("curve_line() validates control point lengths", {
  expect_error(curve_line(x = c(0, 1), y = c(0, 1, 2)))
  expect_error(curve_line(x = 0, y = 0))
})

test_that("draw() renders a curve_line() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(curve_line(x = c(0, 0.5, 1), y = c(0, 1, 0))))
})

test_that("curve_line() accepts stroke styling via style()", {
  cl <- curve_line(x = c(0, 1), y = c(0, 1), color = "red", linewidth = 3, linetype = "dashed")
  expect_identical(cl@style@color, "red")
  expect_identical(cl@style@linewidth, 3)
  expect_identical(cl@style@linetype, "dashed")
})

test_that("curve_line() accepts lineend/linemitre via style()", {
  cl <- curve_line(
    x = c(0, 1, 0.5),
    y = c(0, 1, 2),
    lineend = "square",
    linejoin = "mitre",
    linemitre = 2
  )
  expect_identical(cl@style@lineend, "square")
  expect_identical(cl@style@linejoin, "mitre")
  expect_identical(cl@style@linemitre, 2)
})

test_that("draw() renders a curve_line() with lineend/linemitre set without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  cl <- curve_line(
    x = c(0, 1, 0.2),
    y = c(0, 1, 2),
    linewidth = 10,
    lineend = "square",
    linejoin = "mitre",
    linemitre = 1
  )
  expect_no_error(draw(cl))
})

test_that("curve_spiral() defaults to path geometry", {
  expect_identical(curve_spiral()@geometry, "path")
})

test_that("curve_spiral() starts and ends at the expected radius", {
  cs <- curve_spiral(x = 0, y = 0, radius_start = 0, radius_end = 2, turns = 2, n = 50L)
  expect_equal(cs@points@x[1], 0)
  expect_equal(cs@points@y[1], 0)
  start_radius <- sqrt(cs@points@x[1]^2 + cs@points@y[1]^2)
  end_radius <- sqrt(cs@points@x[50]^2 + cs@points@y[50]^2)
  expect_equal(start_radius, 0)
  expect_equal(end_radius, 2)
})

test_that("curve_spiral() sweeps the requested number of turns", {
  cs <- curve_spiral(radius_start = 1, radius_end = 1, turns = 2, n = 5L)
  angle <- seq(0, 2 * pi * 2, length.out = 5L)
  expect_equal(cs@points@x, cos(angle))
  expect_equal(cs@points@y, sin(angle))
})

test_that("curve_spiral() validates its arguments", {
  expect_error(curve_spiral(radius_start = -1))
  expect_error(curve_spiral(radius_end = -1))
  expect_error(curve_spiral(turns = 0))
  expect_error(curve_spiral(turns = -1))
  expect_error(curve_spiral(n = 0L))
  expect_error(curve_spiral(x = c(0, 1)))
})

test_that("draw() renders a curve_spiral() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(curve_spiral()))
})

test_that("curve_spiral() accepts stroke styling via style()", {
  cs <- curve_spiral(color = "red", linewidth = 3, linetype = "dashed")
  expect_identical(cs@style@color, "red")
  expect_identical(cs@style@linewidth, 3)
  expect_identical(cs@style@linetype, "dashed")
})

test_that("curve_scribble() defaults to path geometry", {
  expect_identical(curve_scribble()@geometry, "path")
})

test_that("curve_scribble() and scribble_lines() agree on a horizontal curve", {
  cs <- curve_scribble(x = 0, y = 0, width = 2, height = 3, seed = 7L, n = 20L)
  line <- scribble_lines(n_lines = 1L, n_harmonics = 3L, amplitude = 0.35, resolution = 20L, seed = 7L)[[1]]
  expect_equal(cs@points@x, line$along * 2)
  expect_equal(cs@points@y, line$across * 3)
})

test_that("curve_scribble() swaps along/across for direction = \"vertical\"", {
  cs <- curve_scribble(width = 2, height = 3, direction = "vertical", seed = 3L, n = 15L)
  line <- scribble_lines(n_lines = 1L, n_harmonics = 3L, amplitude = 0.35, resolution = 15L, seed = 3L)[[1]]
  expect_equal(cs@points@x, line$across * 2)
  expect_equal(cs@points@y, line$along * 3)
})

test_that("curve_scribble() is reproducible for a given seed", {
  expect_identical(curve_scribble(seed = 5L)@points, curve_scribble(seed = 5L)@points)
})

test_that("curve_scribble() validates its arguments", {
  expect_error(curve_scribble(width = 0))
  expect_error(curve_scribble(height = -1))
  expect_error(curve_scribble(direction = "diagonal"))
  expect_error(curve_scribble(n_harmonics = 0L))
  expect_error(curve_scribble(amplitude = -1))
  expect_error(curve_scribble(n = 1L))
})

test_that("draw() renders a curve_scribble() without error", {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off())
  expect_no_error(draw(curve_scribble()))
})

test_that("curve_scribble() accepts stroke styling via style()", {
  cs <- curve_scribble(color = "red", linewidth = 3, linetype = "dashed")
  expect_identical(cs@style@color, "red")
  expect_identical(cs@style@linewidth, 3)
  expect_identical(cs@style@linetype, "dashed")
})
