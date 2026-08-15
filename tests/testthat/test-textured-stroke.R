local_null_device <- function() {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off(), envir = parent.frame())
}

test_that("textured_stroke() builds a tapered outline like shape_stroke()", {
  ts <- textured_stroke(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.3, n = 50L)
  ss <- shape_stroke(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1), width = 0.3, n = 50L)
  expect_equal(ts@outline@x, ss@points@x)
  expect_equal(ts@outline@y, ss@points@y)
})

test_that("textured_stroke() outline tapers to (near) zero width at both ends", {
  ts <- textured_stroke(x = c(0, 1, 2), y = c(0, 0, 0), width = 0.4, n = 50L)
  n <- length(ts@outline@x)
  # first/last points of the two taper edges should coincide (zero width)
  expect_equal(ts@outline@y[1], ts@outline@y[n], tolerance = 1e-6)
})

test_that("textured_stroke() validates its arguments", {
  expect_error(textured_stroke(x = c(0, 1), y = 0), "same length")
  expect_error(textured_stroke(x = 0, y = 0), "at least two")
  expect_error(textured_stroke(x = c(0, 1), y = c(0, 1), width = -1), "width")
  expect_error(textured_stroke(x = c(0, 1), y = c(0, 1), n = 1L), "n must be")
  expect_error(textured_stroke(x = c(0, 1), y = c(0, 1), resolution = 1L), "resolution")
  expect_error(textured_stroke(x = c(0, 1), y = c(0, 1), color = c("a", "b")), "color")
  expect_error(textured_stroke(x = c(0, 1), y = c(0, 1), alpha = 0), "alpha")
  expect_error(textured_stroke(x = c(0, 1), y = c(0, 1), alpha = 1.5), "alpha")
  expect_error(textured_stroke(x = c(0, 1), y = c(0, 1), background = c("a", "b")), "background")
})

test_that("draw() renders a textured_stroke() without error", {
  local_null_device()
  t <- seq(0, 4, length.out = 30)
  expect_no_error(draw(textured_stroke(x = t, y = sin(t), width = 0.3, resolution = 16L)))
})

test_that("draw() renders a textured_stroke() with a background colour without error", {
  local_null_device()
  t <- seq(0, 4, length.out = 30)
  expect_no_error(draw(textured_stroke(
    x = t, y = sin(t), width = 0.3, resolution = 16L, background = "gray80"
  )))
})
