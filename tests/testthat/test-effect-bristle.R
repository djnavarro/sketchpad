test_that("effect_bristle() returns a sketch with the requested number of bristles", {
  sk <- effect_bristle(shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.05), n_bristles = 5L)
  expect_s3_class(sk, "sketchpad::sketch")
  expect_length(sk, 5)
})

test_that("effect_bristle() bristles are all copies of object's own class", {
  sk <- effect_bristle(shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.05), n_bristles = 3L)
  for (i in 1:3) expect_true(S7::S7_inherits(sk[[i]], shape_stroke))
})

test_that("effect_bristle() works with a single bristle", {
  sk <- effect_bristle(shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.05), n_bristles = 1L)
  expect_length(sk, 1)
})

test_that("effect_bristle() is reproducible for a given seed, and varies across seeds", {
  obj <- shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.05)
  sk_a <- effect_bristle(obj, seed = 3L)
  sk_b <- effect_bristle(obj, seed = 3L)
  sk_c <- effect_bristle(obj, seed = 4L)
  expect_identical(sk_a[[1]]@points, sk_b[[1]]@points)
  expect_false(isTRUE(all.equal(sk_a[[1]]@x, sk_c[[1]]@x)))
})

test_that("effect_bristle()'s randomization doesn't leak into the global RNG state", {
  set.seed(2609L) # ensure .Random.seed exists before capturing it
  rng_before <- .Random.seed
  effect_bristle(shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.05))
  expect_identical(.Random.seed, rng_before)
})

test_that("effect_bristle() preserves object's own style on every bristle", {
  sk <- effect_bristle(
    shape_stroke(
      x = c(0, 1, 2), y = c(0, 1, 0), width = 0.05,
      fill = "red", fill_alpha = 0.4, color = NA_character_
    ),
    n_bristles = 2L
  )
  expect_equal(sk[[1]]@style@fill, "red")
  expect_equal(sk[[1]]@style@fill_alpha, 0.4)
})

test_that("effect_bristle() fans bristles at different perpendicular offsets", {
  sk <- effect_bristle(
    shape_stroke(x = c(0, 1, 2), y = c(0, 0, 0), width = 0.05),
    n_bristles = 3L, spread = 0.6, fray = 0, jitter = 0
  )
  # a straight horizontal backbone offsets purely in y
  mean_y <- purrr::map_dbl(1:3, \(i) mean(sk[[i]]@points@y))
  expect_true(length(unique(round(mean_y, 6))) == 3)
})

test_that("effect_bristle() scales object's own width per bristle", {
  sk <- effect_bristle(
    shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.1), n_bristles = 5L
  )
  widths <- purrr::map_dbl(1:5, \(i) sk[[i]]@width)
  expect_true(length(unique(round(widths, 6))) > 1)
})

test_that("effect_bristle() validates its arguments", {
  base <- shape_stroke(x = c(0, 1), y = c(0, 1), width = 0.05)
  expect_error(effect_bristle(base, n_bristles = 0L), "n_bristles")
  expect_error(effect_bristle(base, n_bristles = 1.5), "n_bristles")
  expect_error(effect_bristle(base, spread = -1), "spread")
  expect_error(effect_bristle(base, width_jitter = -0.1), "width_jitter")
  expect_error(effect_bristle(base, width_jitter = 1), "width_jitter")
  expect_error(effect_bristle(base, fray = -0.1), "fray")
  expect_error(effect_bristle(base, fray = 0.5), "fray")
  expect_error(effect_bristle(base, n = 1L), "n")
})

test_that("effect_bristle() requires a pathlike object with a width property", {
  expect_error(effect_bristle(1), "<drawable>")
  # shape_ribbon() isn't pathlike (its x/y is a segment start point)
  expect_error(effect_bristle(shape_ribbon(x = 0, y = 0, xend = 1, yend = 1)), "pathlike")
  # curve_line() is pathlike, but has no width property
  expect_error(effect_bristle(curve_line(x = c(0, 1), y = c(0, 1))), "`width`")
})

test_that("draw() renders an effect_bristle() sketch without error", {
  sk <- effect_bristle(shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.05))
  expect_no_error(draw(sk))
})
