test_that("fill_solid() wraps its color argument in a fill object", {
  expect_identical(fv(fill_solid()), "black")
  expect_identical(fv(fill_solid("red")), "red")
  expect_identical(fv(fill_solid("#112233")), "#112233")
  expect_true(S7::S7_inherits(fill_solid(), fill))
})

test_that("fill_solid() validates its argument", {
  expect_error(fill_solid(1), "color")
  expect_error(fill_solid(c("red", "blue")), "color")
  expect_error(fill_solid(NA_character_), NA) # NA is a valid (transparent) colour
})

test_that("fill_none() wraps a transparent (NA) colour in a fill object", {
  expect_identical(fv(fill_none()), NA_character_)
})

test_that("fill_none() is usable as style()'s fill", {
  expect_identical(fv(style(fill = fill_none())@fill), NA_character_)
})

test_that("fill_hatch() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_hatch()), "GridPattern")
})

test_that("fill_hatch() defers aspect resolution by default", {
  f <- fill_hatch()
  expect_true(S7::S7_inherits(f, fill))
  expect_true(is.function(f@resolve))
})

test_that("fill_hatch() resolves aspect immediately when supplied explicitly", {
  f <- fill_hatch(aspect = 2)
  expect_null(f@resolve)
})

test_that("fill_hatch() validates its arguments", {
  expect_error(fill_hatch(spacing = 0), "spacing")
  expect_error(fill_hatch(spacing = -1), "spacing")
  expect_error(fill_hatch(aspect = 0), "aspect")
  expect_error(fill_hatch(aspect = -1), "aspect")
  expect_error(fill_hatch(angle = c(1, 2)), "angle")
  expect_error(fill_hatch(linewidth = 0), "linewidth")
  expect_error(fill_hatch(linewidth = -1), "linewidth")
})

test_that("fill_hatch() handles axis-aligned angles without error", {
  expect_s3_class(fv(fill_hatch(angle = 0)), "GridPattern")
  expect_s3_class(fv(fill_hatch(angle = 90)), "GridPattern")
  expect_s3_class(fv(fill_hatch(angle = 180)), "GridPattern")
})

test_that("fill_hatch() works with a non-default aspect ratio", {
  fill <- fv(fill_hatch(angle = 45, aspect = 2.33))
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_crosshatch() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_crosshatch()), "GridPattern")
})

test_that("fill_crosshatch() validates its arguments", {
  expect_error(fill_crosshatch(spacing = 0), "spacing")
  expect_error(fill_crosshatch(spacing = -1), "spacing")
  expect_error(fill_crosshatch(aspect = 0), "aspect")
  expect_error(fill_crosshatch(aspect = -1), "aspect")
  expect_error(fill_crosshatch(angle = c(1, 2)), "angle")
  expect_error(fill_crosshatch(linewidth = 0), "linewidth")
  expect_error(fill_crosshatch(linewidth = -1), "linewidth")
})

test_that("fill_crosshatch() handles angles that are multiples of 90 without error", {
  expect_s3_class(fv(fill_crosshatch(angle = 0)), "GridPattern")
  expect_s3_class(fv(fill_crosshatch(angle = 90)), "GridPattern")
  expect_s3_class(fv(fill_crosshatch(angle = 180)), "GridPattern")
  expect_s3_class(fv(fill_crosshatch(angle = -90)), "GridPattern")
})

test_that("fill_crosshatch() works with a non-default aspect ratio", {
  fill <- fv(fill_crosshatch(angle = 30, aspect = 2.33))
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_crosshatch() validates its color argument", {
  expect_error(fill_crosshatch(color = 1), "color")
  expect_error(fill_crosshatch(color = NA_character_), "color")
})

test_that("fill_crosshatch() recycles a two-colour vector across its two lines", {
  fill <- fv(fill_crosshatch(color = c("steelblue", "tomato"), angle = 30))
  children <- environment(fill$f)$grob$children
  cols <- unname(purrr::map_chr(children, \(g) g$gp$col))
  expect_identical(cols, c("steelblue", "tomato"))
})

test_that("fill_checker() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_checker()), "GridPattern")
})

test_that("fill_checker() validates its arguments", {
  expect_error(fill_checker(spacing = 0), "spacing")
  expect_error(fill_checker(spacing = -1), "spacing")
  expect_error(fill_checker(aspect = 0), "aspect")
  expect_error(fill_checker(aspect = -1), "aspect")
  expect_error(fill_checker(color = 1), "color")
  expect_error(fill_checker(color = "black"), "color") # needs at least 2
  expect_error(fill_checker(color = NA_character_), "color")
})

test_that("fill_checker() works with a non-default aspect ratio", {
  expect_s3_class(fv(fill_checker(aspect = 2.33)), "GridPattern")
})

test_that("fill_checker() tile content has four quadrant rectangles for two colours", {
  children <- environment(fv(fill_checker())$f)$grob$children
  expect_length(children, 4)
})

test_that("fill_checker() grid grows with the number of colours", {
  children <- environment(fv(fill_checker(color = c("red", "white", "blue")))$f)$grob$children
  expect_length(children, 9)
})

test_that("fill_stripe() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_stripe()), "GridPattern")
})

test_that("fill_stripe() validates its arguments", {
  expect_error(fill_stripe(spacing = 0), "spacing")
  expect_error(fill_stripe(spacing = -1), "spacing")
  expect_error(fill_stripe(aspect = 0), "aspect")
  expect_error(fill_stripe(aspect = -1), "aspect")
  expect_error(fill_stripe(angle = c(1, 2)), "angle")
  expect_error(fill_stripe(color = 1), "color")
  expect_error(fill_stripe(color = "black"), "color") # needs at least 2
  expect_error(fill_stripe(color = NA_character_), "color")
})

test_that("fill_stripe() works with a non-default aspect ratio", {
  expect_s3_class(fv(fill_stripe(aspect = 2.33)), "GridPattern")
})

test_that("fill_stripe() tile content is filled with a hard-stop linear gradient", {
  gradient <- environment(fv(fill_stripe())$f)$grob$gp$fill
  expect_s3_class(gradient, "GridLinearGradient")
  expect_identical(gradient$stops, c(0, 0.5, 0.5, 1))
})

test_that("fill_stripe() uses equal-width bands for three or more colours", {
  gradient <- environment(fv(fill_stripe(color = c("red", "white", "blue")))$f)$grob$gp$fill
  expect_identical(gradient$colours, c("red", "red", "white", "white", "blue", "blue"))
  expect_equal(gradient$stops, c(0, 1 / 3, 1 / 3, 2 / 3, 2 / 3, 1))
})

test_that("fill_stripe() biases band width by repeating a colour", {
  gradient <- environment(fv(fill_stripe(color = c("red", "red", "blue")))$f)$grob$gp$fill
  expect_identical(gradient$colours, c("red", "red", "red", "red", "blue", "blue"))
})

test_that("fill_stripe()'s extend argument reaches the inner gradient, not the outer pattern", {
  fill_default <- fv(fill_stripe())
  fill_custom <- fv(fill_stripe(extend = "pad"))
  # the outer pattern() call always uses "repeat" -- see fill_stripe() details
  expect_identical(fill_default$extend, "repeat")
  expect_identical(fill_custom$extend, "repeat")
  # extend itself is threaded through to the inner linearGradient()
  gradient_default <- environment(fill_default$f)$grob$gp$fill
  gradient_custom <- environment(fill_custom$f)$grob$gp$fill
  expect_identical(gradient_default$extend, "repeat")
  expect_identical(gradient_custom$extend, "pad")
})

test_that("fill_stipple() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_stipple()), "GridPattern")
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
  fill <- fv(fill_stipple(aspect = 2.33))
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_stipple() is reproducible for a given seed", {
  extract_x <- function(fill) {
    children <- environment(fv(fill)$f)$grob$children
    unname(purrr::map_dbl(children, \(g) as.numeric(g$x)))
  }
  fill_a <- fill_stipple(seed = 481L)
  fill_b <- fill_stipple(seed = 481L)
  fill_c <- fill_stipple(seed = 482L)
  expect_identical(extract_x(fill_a), extract_x(fill_b))
  expect_false(identical(extract_x(fill_a), extract_x(fill_c)))
})

test_that("fill_stipple() validates its color argument", {
  expect_error(fill_stipple(color = 1), "color")
  expect_error(fill_stipple(color = character(0)), "color")
  expect_error(fill_stipple(color = NA_character_), "color")
})

test_that("fill_stipple() recycles a colour vector across the dots", {
  fill <- fv(fill_stipple(color = c("steelblue", "tomato"), n = 5L))
  children <- environment(fill$f)$grob$children
  cols <- unname(purrr::map_chr(children, \(g) g$gp$fill))
  expect_identical(cols, rep(c("steelblue", "tomato"), length.out = 5))
})

test_that("fill_scatter() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_scatter()), "GridPattern")
})

test_that("fill_scatter() validates its arguments", {
  expect_error(fill_scatter(spacing = 0), "spacing")
  expect_error(fill_scatter(spacing = -1), "spacing")
  expect_error(fill_scatter(aspect = 0), "aspect")
  expect_error(fill_scatter(aspect = -1), "aspect")
  expect_error(fill_scatter(unit = "circle"), "unit")
  expect_error(fill_scatter(unit = 1), "unit")
  expect_error(fill_scatter(size = 0), "size")
  expect_error(fill_scatter(size = 1), "size")
  expect_error(fill_scatter(size = -0.5), "size")
  expect_error(fill_scatter(n = 0), "n")
  expect_error(fill_scatter(n = 1.5), "n")
  expect_error(fill_scatter(seed = 1.5), "seed")
})

test_that("fill_scatter() accepts an arbitrary drawable as the scattered unit", {
  expect_s3_class(fv(fill_scatter(unit = shape_blob(radius = 1, distortion = noise_field(seed = 7L)))), "GridPattern")
  expect_s3_class(fv(fill_scatter(unit = shape_bezier(x = c(0, 1, 0), y = c(0, 1, 2)))), "GridPattern")
})

test_that("fill_scatter() accepts a unit whose own fill is another fill_*() pattern", {
  nested_unit <- shape_circle(radius = 1, fill = fill_hatch())
  expect_s3_class(fv(fill_scatter(unit = nested_unit)), "GridPattern")
})

test_that("fill_scatter() works with a non-default aspect ratio", {
  expect_s3_class(fv(fill_scatter(aspect = 2.33)), "GridPattern")
})

test_that("fill_scatter() is reproducible for a given seed", {
  extract_x <- function(fill) {
    children <- environment(fv(fill)$f)$grob$children
    unname(purrr::map_dbl(children, \(g) mean(as.numeric(g$x))))
  }
  fill_a <- fill_scatter(seed = 481L)
  fill_b <- fill_scatter(seed = 481L)
  fill_c <- fill_scatter(seed = 482L)
  expect_identical(extract_x(fill_a), extract_x(fill_b))
  expect_false(identical(extract_x(fill_a), extract_x(fill_c)))
})

test_that("fill_scatter() validates its color argument", {
  expect_error(fill_scatter(color = 1), "color")
  expect_error(fill_scatter(color = NA_character_), "color")
})

test_that("fill_scatter() defaults to unit's own style colour when color is NULL", {
  unit <- shape_circle(radius = 1, color = "forestgreen")
  fill <- fv(fill_scatter(unit = unit, n = 3L))
  children <- environment(fill$f)$grob$children
  cols <- unname(purrr::map_chr(children, \(g) g$gp$col))
  expect_true(all(cols == "forestgreen"))
})

test_that("fill_scatter() recycles a color vector, overriding unit's own colour", {
  unit <- shape_circle(radius = 1, color = "forestgreen")
  fill <- fv(fill_scatter(unit = unit, n = 4L, color = c("steelblue", "tomato")))
  children <- environment(fill$f)$grob$children
  cols <- unname(purrr::map_chr(children, \(g) g$gp$col))
  expect_identical(cols, rep(c("steelblue", "tomato"), length.out = 4))
})

test_that("fill_halftone() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_halftone()), "GridPattern")
})

test_that("fill_halftone() validates its arguments", {
  expect_error(fill_halftone(spacing = 0), "spacing")
  expect_error(fill_halftone(spacing = -1), "spacing")
  expect_error(fill_halftone(aspect = 0), "aspect")
  expect_error(fill_halftone(aspect = -1), "aspect")
  expect_error(fill_halftone(radius = 0.1), "radius")
  expect_error(fill_halftone(radius = c(0.1, 0.2, 0.3)), "radius")
  expect_error(fill_halftone(radius = c(-0.1, 0.2)), "radius")
  expect_error(fill_halftone(radius = c(0.3, 0.1)), "radius")
  expect_error(fill_halftone(radius = c(0.1, 0.6)), "radius")
  expect_error(fill_halftone(n = 0), "n")
  expect_error(fill_halftone(n = 1.5), "n")
  expect_error(fill_halftone(seed = 1.5), "seed")
})

test_that("fill_halftone() works with a non-default aspect ratio", {
  expect_s3_class(fv(fill_halftone(aspect = 2.33)), "GridPattern")
})

test_that("fill_halftone() dot radii vary within the requested range", {
  fill <- fv(fill_halftone(radius = c(0.05, 0.2), n = 10L, seed = 481L))
  radii <- purrr::map_dbl(environment(fill$f)$grob$children, \(g) as.numeric(g$r))
  expect_true(all(radii >= 0.05 & radii <= 0.2))
  expect_gt(length(unique(radii)), 1)
})

test_that("fill_halftone() is reproducible for a given seed", {
  extract_r <- function(fill) {
    unname(purrr::map_dbl(environment(fv(fill)$f)$grob$children, \(g) as.numeric(g$r)))
  }
  fill_a <- fill_halftone(seed = 481L)
  fill_b <- fill_halftone(seed = 481L)
  fill_c <- fill_halftone(seed = 482L)
  expect_identical(extract_r(fill_a), extract_r(fill_b))
  expect_false(identical(extract_r(fill_a), extract_r(fill_c)))
})

test_that("fill_halftone() validates its color argument", {
  expect_error(fill_halftone(color = 1), "color")
  expect_error(fill_halftone(color = NA_character_), "color")
})

test_that("fill_halftone() recycles a colour vector across the dots", {
  fill <- fv(fill_halftone(color = c("steelblue", "tomato"), n = 5L))
  children <- environment(fill$f)$grob$children
  cols <- unname(purrr::map_chr(children, \(g) g$gp$fill))
  expect_identical(cols, rep(c("steelblue", "tomato"), length.out = 5))
})

test_that("fill_scribble() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_scribble()), "GridPattern")
  expect_s3_class(fv(fill_scribble(direction = "vertical")), "GridPattern")
})

test_that("fill_scribble() validates its arguments", {
  expect_error(fill_scribble(direction = "diagonal"))
  expect_error(fill_scribble(spacing = 0), "spacing")
  expect_error(fill_scribble(spacing = -1), "spacing")
  expect_error(fill_scribble(aspect = 0), "aspect")
  expect_error(fill_scribble(aspect = -1), "aspect")
  expect_error(fill_scribble(n_lines = 0), "n_lines")
  expect_error(fill_scribble(n_lines = 1.5), "n_lines")
  expect_error(fill_scribble(n_harmonics = 0), "n_harmonics")
  expect_error(fill_scribble(n_harmonics = 1.5), "n_harmonics")
  expect_error(fill_scribble(amplitude = -1), "amplitude")
  expect_error(fill_scribble(resolution = 1), "resolution")
  expect_error(fill_scribble(resolution = 4.5), "resolution")
  expect_error(fill_scribble(color = 1), "color")
  expect_error(fill_scribble(color = NA_character_), "color")
  expect_error(fill_scribble(linewidth = 0), "linewidth")
  expect_error(fill_scribble(linewidth = -1), "linewidth")
  expect_error(fill_scribble(seed = 1.5), "seed")
})

test_that("fill_scribble() works with a non-default aspect ratio", {
  expect_s3_class(fv(fill_scribble(aspect = 2.33)), "GridPattern")
})

test_that("fill_scribble() draws n_lines separate strokes", {
  fill <- fv(fill_scribble(n_lines = 7L))
  children <- environment(fill$f)$grob$children
  expect_length(children, 7)
})

test_that("fill_scribble() is reproducible for a given seed", {
  extract_y <- function(fill) {
    children <- environment(fv(fill)$f)$grob$children
    unname(purrr::map_dbl(children, \(g) mean(as.numeric(g$y))))
  }
  fill_a <- fill_scribble(seed = 481L)
  fill_b <- fill_scribble(seed = 481L)
  fill_c <- fill_scribble(seed = 482L)
  expect_identical(extract_y(fill_a), extract_y(fill_b))
  expect_false(identical(extract_y(fill_a), extract_y(fill_c)))
})

test_that("fill_scribble() each line meets itself exactly at the tile edge", {
  lines <- scribble_lines(
    n_lines = 4L, n_harmonics = 3L, amplitude = 0.4, resolution = 50L, seed = 481L
  )
  gaps <- vapply(lines, \(ln) abs(ln$across[1] - ln$across[length(ln$across)]), numeric(1))
  expect_true(all(gaps < 1e-10))
})

test_that("fill_scribble() recycles a colour vector across the wandering lines", {
  fill <- fv(fill_scribble(color = c("steelblue", "tomato"), n_lines = 5L))
  children <- environment(fill$f)$grob$children
  cols <- unname(purrr::map_chr(children, \(g) g$gp$col))
  expect_identical(cols, rep(c("steelblue", "tomato"), length.out = 5))
})

test_that("fill_scribble() horizontal and vertical transpose x/y", {
  h <- fv(fill_scribble(direction = "horizontal", seed = 481L))
  v <- fv(fill_scribble(direction = "vertical", seed = 481L))
  h_x <- as.numeric(environment(h$f)$grob$children[[1]]$x)
  h_y <- as.numeric(environment(h$f)$grob$children[[1]]$y)
  v_x <- as.numeric(environment(v$f)$grob$children[[1]]$x)
  v_y <- as.numeric(environment(v$f)$grob$children[[1]]$y)
  expect_identical(h_x, v_y)
  expect_identical(h_y, v_x)
})

test_that("fill_noise() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_noise()), "GridPattern")
})

test_that("fill_noise() validates its arguments", {
  expect_error(fill_noise(spacing = 0), "spacing")
  expect_error(fill_noise(spacing = -1), "spacing")
  expect_error(fill_noise(aspect = 0), "aspect")
  expect_error(fill_noise(aspect = -1), "aspect")
  expect_error(fill_noise(color = 1), "color")
  expect_error(fill_noise(color = NA_character_), "color")
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
  fill <- fv(fill_noise(aspect = 2.33))
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_noise() is reproducible for a given seed", {
  extract_raster <- function(fill) environment(fv(fill)$f)$grob$raster
  fill_a <- fill_noise(seed = 481L, resolution = 8L)
  fill_b <- fill_noise(seed = 481L, resolution = 8L)
  fill_c <- fill_noise(seed = 482L, resolution = 8L)
  expect_identical(extract_raster(fill_a), extract_raster(fill_b))
  expect_false(identical(extract_raster(fill_a), extract_raster(fill_c)))
})

test_that("fill_noise() with a single colour reproduces the original alpha-fade behavior", {
  # single colour: fully transparent at the noise minimum, opaque (up to
  # alpha) at the maximum -- i.e. some alpha channel values near 0
  fill <- fv(fill_noise(color = "black", resolution = 8L, seed = 481L))
  raster <- environment(fill$f)$grob$raster
  alphas <- grDevices::col2rgb(as.vector(raster), alpha = TRUE)["alpha", ]
  expect_true(min(alphas) < max(alphas))
})

test_that("fill_noise() with two or more colours blends hue instead of fading alpha", {
  fill <- fv(fill_noise(color = c("red", "blue"), resolution = 8L, seed = 481L, alpha = 1))
  raster <- environment(fill$f)$grob$raster
  rgb <- t(grDevices::col2rgb(as.vector(raster)))
  # a red/blue blend should vary in the red and blue channels
  expect_gt(length(unique(rgb[, "red"])), 1)
  expect_gt(length(unique(rgb[, "blue"])), 1)
})

test_that("fill_charcoal() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_charcoal()), "GridPattern")
})

test_that("fill_charcoal() validates its arguments (forwarded to fill_noise())", {
  expect_error(fill_charcoal(spacing = 0), "spacing")
  expect_error(fill_charcoal(color = 1), "color")
  expect_error(fill_charcoal(frequency = -1), "frequency")
  expect_error(fill_charcoal(octaves = 1.5), "octaves")
})

test_that("fill_charcoal() differs from fill_noise() only in its defaults", {
  extract_raster <- function(fill) environment(fv(fill)$f)$grob$raster
  charcoal_default <- fill_charcoal(seed = 481L, resolution = 8L)
  noise_matching_args <- fill_noise(
    color = "gray15", spacing = 0.25, frequency = 4, octaves = 3L,
    seed = 481L, resolution = 8L
  )
  expect_identical(extract_raster(charcoal_default), extract_raster(noise_matching_args))
})

test_that("fill_marble() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_marble()), "GridPattern")
})

test_that("fill_marble() validates its arguments", {
  expect_error(fill_marble(spacing = 0), "spacing")
  expect_error(fill_marble(spacing = -1), "spacing")
  expect_error(fill_marble(aspect = 0), "aspect")
  expect_error(fill_marble(aspect = -1), "aspect")
  expect_error(fill_marble(color = 1), "color")
  expect_error(fill_marble(color = "black"), "color") # needs at least 2
  expect_error(fill_marble(color = NA_character_), "color")
  expect_error(fill_marble(resolution = 1), "resolution")
  expect_error(fill_marble(resolution = 4.5), "resolution")
  expect_error(fill_marble(stripes = 0), "stripes")
  expect_error(fill_marble(stripes = 1.5), "stripes")
  expect_error(fill_marble(warp = -1), "warp")
  expect_error(fill_marble(frequency = -1), "frequency")
  expect_error(fill_marble(octaves = 0), "octaves")
  expect_error(fill_marble(octaves = 1.5), "octaves")
  expect_error(fill_marble(seed = 1.5), "seed")
})

test_that("fill_marble() works with a non-default aspect ratio", {
  expect_s3_class(fv(fill_marble(aspect = 2.33)), "GridPattern")
})

test_that("fill_marble() is reproducible for a given seed", {
  extract_raster <- function(fill) environment(fv(fill)$f)$grob$raster
  fill_a <- fill_marble(seed = 481L, resolution = 8L)
  fill_b <- fill_marble(seed = 481L, resolution = 8L)
  fill_c <- fill_marble(seed = 482L, resolution = 8L)
  expect_identical(extract_raster(fill_a), extract_raster(fill_b))
  expect_false(identical(extract_raster(fill_a), extract_raster(fill_c)))
})

test_that("fill_marble() uses only color in its raster", {
  fill <- fv(fill_marble(color = c("white", "black"), resolution = 8L))
  raster <- environment(fill$f)$grob$raster
  channels <- t(grDevices::col2rgb(as.vector(raster)))
  expect_true(all(channels[, 1] == channels[, 2] & channels[, 2] == channels[, 3]))
})

test_that("fill_marble() blends across three or more colours", {
  fill <- fv(fill_marble(color = c("red", "white", "blue"), resolution = 8L))
  raster <- environment(fill$f)$grob$raster
  channels <- t(grDevices::col2rgb(as.vector(raster)))
  expect_gt(length(unique(channels[, "red"])), 1)
})

test_that("fill_flow() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_flow()), "GridPattern")
})

test_that("fill_flow() validates its arguments", {
  expect_error(fill_flow(spacing = 0), "spacing")
  expect_error(fill_flow(spacing = -1), "spacing")
  expect_error(fill_flow(aspect = 0), "aspect")
  expect_error(fill_flow(aspect = -1), "aspect")
  expect_error(fill_flow(color = 1), "color")
  expect_error(fill_flow(color = NA_character_), "color")
  expect_error(fill_flow(resolution = 1), "resolution")
  expect_error(fill_flow(resolution = 4.5), "resolution")
  expect_error(fill_flow(alpha = 0), "alpha")
  expect_error(fill_flow(alpha = 1.5), "alpha")
  expect_error(fill_flow(warp = -1), "warp")
  expect_error(fill_flow(warp_frequency = -1), "warp_frequency")
  expect_error(fill_flow(warp_octaves = 0), "warp_octaves")
  expect_error(fill_flow(warp_octaves = 1.5), "warp_octaves")
  expect_error(fill_flow(frequency = -1), "frequency")
  expect_error(fill_flow(octaves = 0), "octaves")
  expect_error(fill_flow(octaves = 1.5), "octaves")
  expect_error(fill_flow(seed = 1.5), "seed")
})

test_that("fill_flow() works with a non-default aspect ratio", {
  expect_s3_class(fv(fill_flow(aspect = 2.33)), "GridPattern")
})

test_that("fill_flow() is reproducible for a given seed", {
  extract_raster <- function(fill) environment(fv(fill)$f)$grob$raster
  fill_a <- fill_flow(seed = 481L, resolution = 8L)
  fill_b <- fill_flow(seed = 481L, resolution = 8L)
  fill_c <- fill_flow(seed = 482L, resolution = 8L)
  expect_identical(extract_raster(fill_a), extract_raster(fill_b))
  expect_false(identical(extract_raster(fill_a), extract_raster(fill_c)))
})

test_that("fill_flow() differs from fill_noise() at the same seed (domain-warped)", {
  extract_raster <- function(fill) environment(fv(fill)$f)$grob$raster
  flow <- fill_flow(seed = 481L, resolution = 8L, warp = 2)
  noise <- fill_noise(seed = 481L, resolution = 8L)
  expect_false(identical(extract_raster(flow), extract_raster(noise)))
})

test_that("fill_flow() with warp = 0 still returns a valid pattern", {
  expect_s3_class(fv(fill_flow(warp = 0)), "GridPattern")
})

test_that("fill_flow() with two or more colours blends hue instead of fading alpha", {
  fill <- fv(fill_flow(color = c("red", "blue"), resolution = 8L, seed = 481L, alpha = 1))
  raster <- environment(fill$f)$grob$raster
  rgb <- t(grDevices::col2rgb(as.vector(raster)))
  expect_gt(length(unique(rgb[, "red"])), 1)
})

test_that("fill_image() returns a fill object resolving to a grid pattern", {
  img <- matrix(c("red", "blue", "green", "white"), nrow = 2)
  expect_s3_class(fv(fill_image(img)), "GridPattern")
  expect_s3_class(fv(fill_image(grDevices::as.raster(img))), "GridPattern")

  arr <- array(c(0.9, 0.1, 0.2, 0.8, 0.3, 0.7), dim = c(1, 2, 3))
  expect_s3_class(fv(fill_image(arr)), "GridPattern")
})

test_that("fill_image() validates its arguments", {
  img <- matrix(c("red", "blue", "green", "white"), nrow = 2)
  expect_error(fill_image(img, spacing = 0), "spacing")
  expect_error(fill_image(img, spacing = -1), "spacing")
  expect_error(fill_image(img, aspect = 0), "aspect")
  expect_error(fill_image(img, aspect = -1), "aspect")
  expect_error(fill_image("not an image"), "image")
  expect_error(fill_image(list(1, 2)), "image")
  expect_error(fill_image(1:5), "image")
  expect_error(fill_image(array(2, dim = c(1, 1, 3))), "as.raster")
  expect_error(fill_image(img, preserve_aspect = "yes"), "preserve_aspect")
  expect_error(fill_image(img, preserve_aspect = NA), "preserve_aspect")
  expect_error(fill_image(img, interpolate = "yes"), "interpolate")
  expect_error(fill_image(img, interpolate = NA), "interpolate")
})

test_that("fill_image() letterboxes a non-square image by default", {
  wide_img <- matrix(c("red", "blue"), nrow = 1) # 1 row x 2 cols -> aspect 2
  fill <- fv(fill_image(wide_img))
  grob <- environment(fill$f)$grob
  expect_equal(as.numeric(grob$width), 1)
  expect_equal(as.numeric(grob$height), 0.5)
})

test_that("fill_image() stretches to fill the tile when preserve_aspect = FALSE", {
  wide_img <- matrix(c("red", "blue"), nrow = 1)
  fill <- fv(fill_image(wide_img, preserve_aspect = FALSE))
  grob <- environment(fill$f)$grob
  expect_equal(as.numeric(grob$width), 1)
  expect_equal(as.numeric(grob$height), 1)
})

test_that("fill_image() works with a non-default aspect ratio", {
  img <- matrix(c("red", "blue", "green", "white"), nrow = 2)
  expect_s3_class(fv(fill_image(img, aspect = 2.33)), "GridPattern")
})

test_that("fill_gradient() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_gradient()), "GridPattern")
  expect_s3_class(fv(fill_gradient(type = "radial")), "GridPattern")
})

test_that("fill_gradient() validates its arguments", {
  expect_error(fill_gradient(spacing = 0), "spacing")
  expect_error(fill_gradient(spacing = -1), "spacing")
  expect_error(fill_gradient(aspect = 0), "aspect")
  expect_error(fill_gradient(aspect = -1), "aspect")
  expect_error(fill_gradient(color = "black"), "color")
  expect_error(fill_gradient(color = 1), "color")
  expect_error(fill_gradient(stops = 0.5), "stops")
  expect_error(fill_gradient(angle = c(1, 2)), "angle")
  expect_error(fill_gradient(type = "diagonal"))
})

test_that("fill_gradient() accepts custom stops", {
  fill <- fv(fill_gradient(color = c("red", "white", "blue"), stops = c(0, 0.2, 1)))
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_gradient() works with a non-default aspect ratio", {
  expect_s3_class(fv(fill_gradient(aspect = 2.33)), "GridPattern")
  expect_s3_class(fv(fill_gradient(type = "radial", aspect = 2.33)), "GridPattern")
})

test_that("fill_gradient() tile content uses the requested gradient type", {
  linear_content <- environment(fv(fill_gradient(type = "linear"))$f)$grob$gp$fill
  radial_content <- environment(fv(fill_gradient(type = "radial"))$f)$grob$gp$fill
  expect_s3_class(linear_content, "GridLinearGradient")
  expect_s3_class(radial_content, "GridRadialGradient")
})

test_that("fill_vignette() returns a fill object resolving to a grid pattern", {
  expect_s3_class(fv(fill_vignette()), "GridPattern")
  expect_s3_class(fv(fill_vignette(background = "white")), "GridPattern")
})

test_that("fill_vignette() validates its arguments", {
  expect_error(fill_vignette(spacing = 0), "spacing")
  expect_error(fill_vignette(spacing = -1), "spacing")
  expect_error(fill_vignette(aspect = 0), "aspect")
  expect_error(fill_vignette(aspect = -1), "aspect")
  expect_error(fill_vignette(color = 1), "color")
  expect_error(fill_vignette(color = NA_character_), "color")
  expect_error(fill_vignette(background = 1), "background")
  expect_error(fill_vignette(background = c("red", "blue")), "background")
})

test_that("fill_vignette() works with a non-default aspect ratio", {
  expect_s3_class(fv(fill_vignette(aspect = 2.33)), "GridPattern")
})

test_that("fill_vignette() draws a background layer only when requested", {
  no_bg_children <- environment(fv(fill_vignette())$f)$grob$children
  with_bg_children <- environment(fv(fill_vignette(background = "white"))$f)$grob$children
  expect_length(no_bg_children, 1)
  expect_length(with_bg_children, 2)
})

test_that("fill_vignette() exposes and forwards an extend argument", {
  expect_identical(fv(fill_vignette())$extend, "repeat")
  expect_identical(fv(fill_vignette(extend = "pad"))$extend, "pad")
  expect_identical(fv(fill_vignette(extend = "none"))$extend, "none")
})

test_that("fill_vignette() uses a solid fill for a single colour", {
  rect <- environment(fv(fill_vignette(color = "steelblue"))$f)$grob$children[[1]]$gp$fill
  expect_identical(rect, "steelblue")
})

test_that("fill_vignette() uses a radial gradient for two or more colours", {
  rect <- environment(fv(fill_vignette(color = c("goldenrod", "steelblue")))$f)$grob$children[[1]]$gp$fill
  expect_s3_class(rect, "GridRadialGradient")
})
