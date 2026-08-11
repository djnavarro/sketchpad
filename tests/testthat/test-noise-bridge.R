test_that("noise_bridge has expected defaults", {
  b <- noise_bridge()
  expect_identical(b@smooth, 3L)
  expect_identical(b@seed, 1L)
})

test_that("noise_sample returns a length-n bridge pinned to 0 at start (no smoothing)", {
  # smoothing passes (the default) blend the pinned endpoint with its
  # neighbour, so only an unsmoothed bridge stays exactly 0 at start
  s <- noise_sample(noise_bridge(seed = 99L, smooth = 0), n = 40L, scale = 2)
  expect_length(s, 40)
  expect_equal(s[1], 0)
})

test_that("noise_sample is reproducible for a given seed, and varies across seeds", {
  s1 <- noise_sample(noise_bridge(seed = 1L), n = 40L, scale = 1)
  s2 <- noise_sample(noise_bridge(seed = 1L), n = 40L, scale = 1)
  s3 <- noise_sample(noise_bridge(seed = 2L), n = 40L, scale = 1)
  expect_identical(s1, s2)
  expect_false(isTRUE(all.equal(s1, s3)))
})

test_that("noise_sample's scale multiplies the bridge linearly", {
  s1 <- noise_sample(noise_bridge(seed = 5L, smooth = 0), n = 30L, scale = 1)
  s2 <- noise_sample(noise_bridge(seed = 5L, smooth = 0), n = 30L, scale = 3)
  expect_equal(s2, s1 * 3)
})

test_that("noise_bridge validates its scalar arguments", {
  expect_error(noise_bridge(smooth = c(1, 2)))
  expect_error(noise_bridge(seed = c(1L, 2L)))
})

test_that("noise_bridge rejects invalid non-negative arguments", {
  expect_error(noise_bridge(smooth = -1), "smooth")
})

test_that("noise_bridge accepts smooth = 0 (no smoothing passes)", {
  expect_no_error(noise_bridge(smooth = 0))
})
