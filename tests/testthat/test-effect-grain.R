local_null_device <- function() {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off(), envir = parent.frame())
}

test_that("effect_grain() outline matches object's own points", {
  ss <- shape_stroke(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.3, n = 50L)
  eg <- effect_grain(ss)
  expect_equal(eg@outline@x, ss@points@x)
  expect_equal(eg@outline@y, ss@points@y)
})

test_that("effect_grain() outline tapers to (near) zero width at both ends", {
  ss <- shape_stroke(x = c(0, 1, 2), y = c(0, 0, 0), width = 0.4, n = 50L)
  eg <- effect_grain(ss)
  n <- length(eg@outline@x)
  # first/last points of the two taper edges should coincide (zero width)
  expect_equal(eg@outline@y[1], eg@outline@y[n], tolerance = 1e-6)
})

test_that("effect_grain() works with other polygon-geometry drawables", {
  blob <- shape_blob(radius = 1, n = 40L)
  eg <- effect_grain(blob)
  expect_equal(eg@outline@x, blob@points@x)
})

test_that("effect_grain() requires a polygon-geometry object", {
  expect_error(effect_grain(curve_line(x = c(0, 1), y = c(0, 1))), "polygon")
})

test_that("effect_grain() validates its arguments", {
  base <- shape_stroke(x = c(0, 1), y = c(0, 1), width = 0.2)
  expect_error(effect_grain(base, resolution = 1L), "resolution")
  expect_error(effect_grain(base, color = c("a", "b")), "color")
  expect_error(effect_grain(base, alpha = 0), "alpha")
  expect_error(effect_grain(base, alpha = 1.5), "alpha")
  expect_error(effect_grain(base, background = c("a", "b")), "background")
})

test_that("draw() renders an effect_grain() without error", {
  local_null_device()
  t <- seq(0, 4, length.out = 30)
  expect_no_error(draw(effect_grain(
    shape_stroke(x = t, y = sin(t), width = 0.3),
    resolution = 16L
  )))
})

test_that("draw() renders an effect_grain() with a background colour without error", {
  local_null_device()
  t <- seq(0, 4, length.out = 30)
  expect_no_error(draw(effect_grain(
    shape_stroke(x = t, y = sin(t), width = 0.3),
    resolution = 16L, background = "gray80"
  )))
})
