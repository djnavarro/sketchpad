test_that("noise_field has expected defaults", {
  f <- noise_field()
  expect_identical(f@noise, ambient::gen_simplex)
  expect_identical(f@fractal, ambient::fbm)
  expect_identical(f@frequency, 1)
  expect_identical(f@octaves, 2L)
  expect_identical(f@seed, 1L)
})

test_that("noise_sample rescales into the requested range", {
  x <- seq(0, 10, length.out = 50)
  y <- seq(0, 10, length.out = 50)
  s <- noise_sample(noise_field(seed = 99L), x = x, y = y, to = c(-3, 5))
  expect_true(all(s >= -3 - 1e-9 & s <= 5 + 1e-9))
  expect_equal(range(s), c(-3, 5), tolerance = 1e-6)
})

test_that("noise_sample is reproducible for a given seed, and varies across seeds", {
  x <- seq(0, 10, length.out = 50)
  y <- seq(0, 10, length.out = 50)
  s1 <- noise_sample(noise_field(seed = 1L), x = x, y = y)
  s2 <- noise_sample(noise_field(seed = 1L), x = x, y = y)
  s3 <- noise_sample(noise_field(seed = 2L), x = x, y = y)
  expect_identical(s1, s2)
  expect_false(isTRUE(all.equal(s1, s3)))
})

test_that("noise_field accepts alternative noise/fractal functions", {
  f <- noise_field(noise = ambient::gen_perlin, fractal = ambient::billow)
  expect_identical(f@noise, ambient::gen_perlin)
  expect_identical(f@fractal, ambient::billow)
})

test_that("noise_field validates its scalar arguments", {
  expect_error(noise_field(frequency = c(1, 2)))
  expect_error(noise_field(octaves = c(1L, 2L)))
  expect_error(noise_field(seed = c(1L, 2L)))
})

test_that("noise_field rejects invalid non-negative/positive arguments", {
  expect_error(noise_field(frequency = -1), "frequency")
  expect_error(noise_field(octaves = 0L), "octaves")
})
