test_that("bristle_stroke() returns a sketch with the requested number of bristles", {
  sk <- bristle_stroke(x = c(0, 1, 2), y = c(0, 1, 0), n_bristles = 5L)
  expect_s3_class(sk, "sketchpad::sketch")
  expect_length(sk, 5)
})

test_that("bristle_stroke() bristles are all shape_stroke() drawables", {
  sk <- bristle_stroke(x = c(0, 1, 2), y = c(0, 1, 0), n_bristles = 3L)
  for (i in 1:3) expect_true(S7::S7_inherits(sk[[i]], shape_stroke))
})

test_that("bristle_stroke() works with a single bristle", {
  sk <- bristle_stroke(x = c(0, 1, 2), y = c(0, 1, 0), n_bristles = 1L)
  expect_length(sk, 1)
})

test_that("bristle_stroke() is reproducible for a given seed, and varies across seeds", {
  sk_a <- bristle_stroke(x = c(0, 1, 2), y = c(0, 1, 0), seed = 3L)
  sk_b <- bristle_stroke(x = c(0, 1, 2), y = c(0, 1, 0), seed = 3L)
  sk_c <- bristle_stroke(x = c(0, 1, 2), y = c(0, 1, 0), seed = 4L)
  expect_identical(sk_a[[1]]@points, sk_b[[1]]@points)
  expect_false(isTRUE(all.equal(sk_a[[1]]@x, sk_c[[1]]@x)))
})

test_that("bristle_stroke()'s randomization doesn't leak into the global RNG state", {
  set.seed(2609L) # ensure .Random.seed exists before capturing it
  rng_before <- .Random.seed
  bristle_stroke(x = c(0, 1, 2), y = c(0, 1, 0))
  expect_identical(.Random.seed, rng_before)
})

test_that("bristle_stroke() forwards ... to every bristle's shape_stroke()", {
  sk <- bristle_stroke(
    x = c(0, 1, 2), y = c(0, 1, 0), n_bristles = 2L,
    fill = "red", fill_alpha = 0.4, color = NA_character_
  )
  expect_equal(sk[[1]]@style@fill, "red")
  expect_equal(sk[[1]]@style@fill_alpha, 0.4)
})

test_that("bristle_stroke() fans bristles at different perpendicular offsets", {
  sk <- bristle_stroke(
    x = c(0, 1, 2), y = c(0, 0, 0), n_bristles = 3L, spread = 0.6,
    fray = 0, jitter = 0
  )
  # a straight horizontal backbone offsets purely in y
  mean_y <- purrr::map_dbl(1:3, \(i) mean(sk[[i]]@points@y))
  expect_true(length(unique(round(mean_y, 6))) == 3)
})

test_that("bristle_stroke() validates its arguments", {
  expect_error(bristle_stroke(x = c(0, 1), y = 0), "same length")
  expect_error(bristle_stroke(x = 0, y = 0), "at least two")
  expect_error(bristle_stroke(x = c(0, 1), y = c(0, 1), n_bristles = 0L), "n_bristles")
  expect_error(bristle_stroke(x = c(0, 1), y = c(0, 1), n_bristles = 1.5), "n_bristles")
  expect_error(bristle_stroke(x = c(0, 1), y = c(0, 1), spread = -1), "spread")
  expect_error(bristle_stroke(x = c(0, 1), y = c(0, 1), width = -1), "width")
  expect_error(bristle_stroke(x = c(0, 1), y = c(0, 1), width_jitter = -0.1), "width_jitter")
  expect_error(bristle_stroke(x = c(0, 1), y = c(0, 1), width_jitter = 1), "width_jitter")
  expect_error(bristle_stroke(x = c(0, 1), y = c(0, 1), fray = -0.1), "fray")
  expect_error(bristle_stroke(x = c(0, 1), y = c(0, 1), fray = 0.5), "fray")
  expect_error(bristle_stroke(x = c(0, 1), y = c(0, 1), n = 1L), "n")
})

test_that("draw() renders a bristle_stroke() sketch without error", {
  sk <- bristle_stroke(x = c(0, 1, 2), y = c(0, 1, 0))
  expect_no_error(draw(sk))
})
