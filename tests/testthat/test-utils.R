test_that("as_integerish() accepts whole-number doubles and integers", {
  expect_identical(as_integerish(12, "n"), 12L)
  expect_identical(as_integerish(12L, "n"), 12L)
  expect_identical(as_integerish(0, "n"), 0L)
  expect_identical(as_integerish(c(1, 2, 3), "n"), c(1L, 2L, 3L))
})

test_that("as_integerish() tolerates floating-point noise around a whole number", {
  expect_identical(as_integerish(3 + 1e-10, "n"), 3L)
})

test_that("as_integerish() rejects fractional, non-numeric, or missing values", {
  expect_error(as_integerish(12.5, "n"), "n must be integerish")
  expect_error(as_integerish("a", "n"), "n must be integerish")
  expect_error(as_integerish(NA_real_, "n"), "n must be integerish")
})

test_that("class_integer constructor arguments accept integerish doubles", {
  expect_identical(noise_field(seed = 4821, octaves = 3)@seed, 4821L)
  expect_identical(noise_field(seed = 4821, octaves = 3)@octaves, 3L)
  expect_identical(noise_bridge(seed = 4821)@seed, 4821L)
  expect_identical(shape_circle(radius = 1, n = 12)@n, 12L)
  expect_identical(shape_polygon(radius = 1, n = 6)@n, 6L)
  expect_identical(shape_ellipse(x_radius = 1, y_radius = 1, n = 12)@n, 12L)
  expect_identical(shape_wedge(radius = 1, n = 20)@n, 20L)
  expect_identical(curve_arc(radius = 1, n = 20)@n, 20L)
  expect_identical(
    shape_stroke(x = c(0, 1), y = c(0, 1), width = 0.1, n = 50)@n, 50L
  )
  expect_identical(shape_bezier(x = c(0, 1), y = c(0, 1), n = 50)@n, 50L)
  expect_identical(curve_bezier(x = c(0, 1), y = c(0, 1), n = 50)@n, 50L)
  expect_identical(
    shape_ribbon(x = 0, y = 0, xend = 1, yend = 1, n = 50)@n, 50L
  )
  expect_identical(
    shape_twist(x = 0, y = 0, xend = 1, yend = 1, n = 50)@n, 50L
  )
  expect_identical(
    curve_twist(x = 0, y = 0, xend = 1, yend = 1, n = 50)@n, 50L
  )
  expect_identical(curve_spiral(n = 50)@n, 50L)
  cs <- curve_scribble(n_harmonics = 3, n = 200, seed = 5591)
  expect_identical(cs@n_harmonics, 3L)
  expect_identical(cs@n, 200L)
  expect_identical(cs@seed, 5591L)
  expect_identical(
    effect_grain(shape_circle(radius = 1), resolution = 100)@resolution, 100L
  )
})

test_that("class_integer constructor arguments still reject fractional values", {
  expect_error(noise_field(seed = 1.5), "seed must be integerish")
  expect_error(noise_field(octaves = 2.5), "octaves must be integerish")
  expect_error(noise_bridge(seed = 1.5), "seed must be integerish")
  expect_error(shape_circle(radius = 1, n = 12.5), "n must be integerish")
  expect_error(curve_scribble(n_harmonics = 2.5), "n_harmonics must be integerish")
  expect_error(
    effect_grain(shape_circle(radius = 1), resolution = 100.5),
    "resolution must be integerish"
  )
})
