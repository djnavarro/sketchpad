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

test_that("fill_checker() returns a grid pattern object", {
  expect_s3_class(fill_checker(), "GridPattern")
})

test_that("fill_checker() validates its arguments", {
  expect_error(fill_checker(spacing = 0), "spacing")
  expect_error(fill_checker(spacing = -1), "spacing")
  expect_error(fill_checker(aspect = 0), "aspect")
  expect_error(fill_checker(aspect = -1), "aspect")
  expect_error(fill_checker(color1 = 1), "color1")
  expect_error(fill_checker(color1 = c("red", "blue")), "color1")
  expect_error(fill_checker(color2 = 1), "color2")
  expect_error(fill_checker(color2 = c("red", "blue")), "color2")
})

test_that("fill_checker() works with a non-default aspect ratio", {
  expect_s3_class(fill_checker(aspect = 2.33), "GridPattern")
})

test_that("fill_checker() tile content has four quadrant rectangles", {
  children <- environment(fill_checker()$f)$grob$children
  expect_length(children, 4)
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

test_that("fill_gradient() returns a grid pattern object", {
  expect_s3_class(fill_gradient(), "GridPattern")
  expect_s3_class(fill_gradient(type = "radial"), "GridPattern")
})

test_that("fill_gradient() validates its arguments", {
  expect_error(fill_gradient(spacing = 0), "spacing")
  expect_error(fill_gradient(spacing = -1), "spacing")
  expect_error(fill_gradient(aspect = 0), "aspect")
  expect_error(fill_gradient(aspect = -1), "aspect")
  expect_error(fill_gradient(colors = "black"), "colors")
  expect_error(fill_gradient(colors = 1), "colors")
  expect_error(fill_gradient(stops = 0.5), "stops")
  expect_error(fill_gradient(angle = c(1, 2)), "angle")
  expect_error(fill_gradient(type = "diagonal"))
})

test_that("fill_gradient() accepts custom stops", {
  fill <- fill_gradient(colors = c("red", "white", "blue"), stops = c(0, 0.2, 1))
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_gradient() works with a non-default aspect ratio", {
  expect_s3_class(fill_gradient(aspect = 2.33), "GridPattern")
  expect_s3_class(fill_gradient(type = "radial", aspect = 2.33), "GridPattern")
})

test_that("fill_gradient() tile content uses the requested gradient type", {
  linear_content <- environment(fill_gradient(type = "linear")$f)$grob$gp$fill
  radial_content <- environment(fill_gradient(type = "radial")$f)$grob$gp$fill
  expect_s3_class(linear_content, "GridLinearGradient")
  expect_s3_class(radial_content, "GridRadialGradient")
})

test_that("fill_vignette() returns a grid pattern object", {
  expect_s3_class(fill_vignette(), "GridPattern")
  expect_s3_class(fill_vignette(background = "white"), "GridPattern")
})

test_that("fill_vignette() validates its arguments", {
  expect_error(fill_vignette(spacing = 0), "spacing")
  expect_error(fill_vignette(spacing = -1), "spacing")
  expect_error(fill_vignette(aspect = 0), "aspect")
  expect_error(fill_vignette(aspect = -1), "aspect")
  expect_error(fill_vignette(color = 1), "color")
  expect_error(fill_vignette(color = c("red", "blue")), "color")
  expect_error(fill_vignette(background = 1), "background")
  expect_error(fill_vignette(background = c("red", "blue")), "background")
})

test_that("fill_vignette() works with a non-default aspect ratio", {
  expect_s3_class(fill_vignette(aspect = 2.33), "GridPattern")
})

test_that("fill_vignette() draws a background layer only when requested", {
  no_bg_children <- environment(fill_vignette()$f)$grob$children
  with_bg_children <- environment(fill_vignette(background = "white")$f)$grob$children
  expect_length(no_bg_children, 1)
  expect_length(with_bg_children, 2)
})
