test_that("effect_tremor() returns a group with the requested number of layers", {
  sk <- effect_tremor(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)), layers = 3L)
  expect_s3_class(sk, "sketchpad::group")
  expect_length(sk, 3)
})

test_that("effect_tremor() layers are copies of object's own class", {
  sk <- effect_tremor(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)), layers = 2L)
  expect_true(S7::S7_inherits(sk[[1]], curve_line))
  expect_true(S7::S7_inherits(sk[[2]], curve_line))
})

test_that("effect_tremor() layers differ from the unperturbed path once jitter > 0", {
  sk <- effect_tremor(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)), layers = 2L, jitter = 0.2)
  expect_false(isTRUE(all.equal(sk[[1]]@x, c(0, 1, 2))))
})

test_that("effect_tremor() collapses to the unperturbed path when jitter = 0", {
  sk <- effect_tremor(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)), layers = 3L, jitter = 0)
  for (i in seq_len(3)) {
    expect_equal(sk[[i]]@x, c(0, 1, 2))
    expect_equal(sk[[i]]@y, c(0, 1, 0))
  }
})

test_that("effect_tremor() layers wobble independently rather than in lockstep", {
  sk <- effect_tremor(curve_line(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1)), layers = 2L, jitter = 0.2)
  expect_false(isTRUE(all.equal(sk[[1]]@x, sk[[2]]@x)))
})

test_that("effect_tremor() is reproducible for a given seed, and varies across seeds", {
  obj <- curve_line(x = c(0, 1, 2), y = c(0, 1, 0))
  sk_a <- effect_tremor(obj, seed = 3L)
  sk_b <- effect_tremor(obj, seed = 3L)
  sk_c <- effect_tremor(obj, seed = 4L)
  expect_identical(sk_a[[1]]@points, sk_b[[1]]@points)
  expect_false(isTRUE(all.equal(sk_a[[1]]@x, sk_c[[1]]@x)))
})

test_that("effect_tremor() preserves object's other properties across every layer", {
  sk <- effect_tremor(
    shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.3, color_alpha = 0.4),
    layers = 2L
  )
  expect_equal(sk[[1]]@width, 0.3)
  expect_equal(sk[[1]]@style@color_alpha, 0.4)
  expect_equal(sk[[2]]@width, 0.3)
  expect_equal(sk[[2]]@style@color_alpha, 0.4)
})

test_that("effect_tremor() works with shape_stroke() as object", {
  sk <- effect_tremor(shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.2), layers = 2L)
  expect_true(S7::S7_inherits(sk[[1]], shape_stroke))
})

test_that("effect_tremor() validates its arguments", {
  expect_error(effect_tremor(curve_line(x = c(0, 1), y = c(0, 1)), layers = 0L), "layers")
  expect_error(effect_tremor(curve_line(x = c(0, 1), y = c(0, 1)), layers = 1.5), "layers")
  expect_error(effect_tremor(curve_line(x = c(0, 1), y = c(0, 1)), jitter = -1), "jitter")
  expect_error(effect_tremor(curve_line(x = c(0, 1), y = c(0, 1)), jitter_frequency = -1), "jitter_frequency")
  expect_error(effect_tremor(1), "<drawable>")
  # shape_ribbon() has enough scalar x/y properties to pass a naive
  # "has x/y" check, but they're a segment's start point, not a
  # perturbable control-point path -- pathlike catches this directly
  expect_error(effect_tremor(shape_ribbon(x = 0, y = 0, xend = 1, yend = 1)), "pathlike")
})

test_that("draw() renders an effect_tremor() group without error", {
  sk <- effect_tremor(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)))
  expect_no_error(draw(sk))
})

test_that("effect_tremor() rejects a multi-sub-path drawable", {
  multi <- shape_combine(shape_circle(), shape_circle(x = 5))
  expect_error(effect_tremor(multi), "multi-sub-path")
})

test_that("effect_tremor() still works on a shape_raw()/curve_raw() with an explicit single-value id", {
  sr <- shape_raw(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1), id = c(1, 1, 1, 1))
  expect_no_error(effect_tremor(sr, layers = 1L))
})
