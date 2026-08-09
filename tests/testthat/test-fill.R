test_that("fill_solid() returns its color argument unchanged", {
  expect_identical(fill_solid(), "black")
  expect_identical(fill_solid("red"), "red")
  expect_identical(fill_solid("#112233"), "#112233")
})

test_that("fill_solid() validates its argument", {
  expect_error(fill_solid(1), "color")
  expect_error(fill_solid(c("red", "blue")), "color")
  expect_error(fill_solid(NA_character_), NA) # NA is a valid (transparent) colour
})

test_that("fill_hatch() returns a grid pattern object", {
  fill <- fill_hatch()
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_hatch() validates its arguments", {
  expect_error(fill_hatch(spacing = 0), "spacing")
  expect_error(fill_hatch(spacing = -1), "spacing")
  expect_error(fill_hatch(aspect = 0), "aspect")
  expect_error(fill_hatch(aspect = -1), "aspect")
  expect_error(fill_hatch(angle = c(1, 2)), "angle")
})

test_that("fill_hatch() handles axis-aligned angles without error", {
  expect_s3_class(fill_hatch(angle = 0), "GridPattern")
  expect_s3_class(fill_hatch(angle = 90), "GridPattern")
  expect_s3_class(fill_hatch(angle = 180), "GridPattern")
})

test_that("fill_hatch() works with a non-default aspect ratio", {
  fill <- fill_hatch(angle = 45, aspect = 2.33)
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_crosshatch() returns a grid pattern object", {
  fill <- fill_crosshatch()
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_crosshatch() validates its arguments", {
  expect_error(fill_crosshatch(spacing = 0), "spacing")
  expect_error(fill_crosshatch(spacing = -1), "spacing")
  expect_error(fill_crosshatch(aspect = 0), "aspect")
  expect_error(fill_crosshatch(aspect = -1), "aspect")
  expect_error(fill_crosshatch(angle = c(1, 2)), "angle")
})

test_that("fill_crosshatch() handles angles that are multiples of 90 without error", {
  expect_s3_class(fill_crosshatch(angle = 0), "GridPattern")
  expect_s3_class(fill_crosshatch(angle = 90), "GridPattern")
  expect_s3_class(fill_crosshatch(angle = 180), "GridPattern")
  expect_s3_class(fill_crosshatch(angle = -90), "GridPattern")
})

test_that("fill_crosshatch() works with a non-default aspect ratio", {
  fill <- fill_crosshatch(angle = 30, aspect = 2.33)
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_stipple() returns a grid pattern object", {
  fill <- fill_stipple()
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_stipple() validates its arguments", {
  expect_error(fill_stipple(spacing = 0), "spacing")
  expect_error(fill_stipple(spacing = -1), "spacing")
  expect_error(fill_stipple(aspect = 0), "aspect")
  expect_error(fill_stipple(aspect = -1), "aspect")
  expect_error(fill_stipple(radius = 0), "radius")
  expect_error(fill_stipple(radius = -1), "radius")
  expect_error(fill_stipple(n = 0), "n")
  expect_error(fill_stipple(n = 1.5), "n")
  expect_error(fill_stipple(seed = 1.5), "seed")
})

test_that("fill_stipple() works with a non-default aspect ratio", {
  fill <- fill_stipple(aspect = 2.33)
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_stipple() is reproducible for a given seed", {
  extract_x <- function(fill) {
    children <- environment(fill$f)$grob$children
    unname(purrr::map_dbl(children, \(g) as.numeric(g$x)))
  }
  fill_a <- fill_stipple(seed = 481L)
  fill_b <- fill_stipple(seed = 481L)
  fill_c <- fill_stipple(seed = 482L)
  expect_identical(extract_x(fill_a), extract_x(fill_b))
  expect_false(identical(extract_x(fill_a), extract_x(fill_c)))
})

test_that("fill_noise() returns a grid pattern object", {
  fill <- fill_noise()
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_noise() validates its arguments", {
  expect_error(fill_noise(spacing = 0), "spacing")
  expect_error(fill_noise(spacing = -1), "spacing")
  expect_error(fill_noise(aspect = 0), "aspect")
  expect_error(fill_noise(aspect = -1), "aspect")
  expect_error(fill_noise(color = 1), "color")
  expect_error(fill_noise(color = c("red", "blue")), "color")
  expect_error(fill_noise(resolution = 1), "resolution")
  expect_error(fill_noise(resolution = 4.5), "resolution")
  expect_error(fill_noise(alpha = 0), "alpha")
  expect_error(fill_noise(alpha = 1.5), "alpha")
  expect_error(fill_noise(frequency = -1), "frequency")
  expect_error(fill_noise(octaves = 0), "octaves")
  expect_error(fill_noise(octaves = 1.5), "octaves")
  expect_error(fill_noise(seed = 1.5), "seed")
})

test_that("fill_noise() works with a non-default aspect ratio", {
  fill <- fill_noise(aspect = 2.33)
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_noise() is reproducible for a given seed", {
  extract_raster <- function(fill) environment(fill$f)$grob$raster
  fill_a <- fill_noise(seed = 481L, resolution = 8L)
  fill_b <- fill_noise(seed = 481L, resolution = 8L)
  fill_c <- fill_noise(seed = 482L, resolution = 8L)
  expect_identical(extract_raster(fill_a), extract_raster(fill_b))
  expect_false(identical(extract_raster(fill_a), extract_raster(fill_c)))
})
