test_that("sketchy() returns a sketch with the requested number of layers", {
  sk <- sketchy(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)), layers = 3L)
  expect_s3_class(sk, "sketchpad::sketch")
  expect_length(sk, 3)
})

test_that("sketchy() layers are copies of object's own class", {
  sk <- sketchy(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)), layers = 2L)
  expect_true(S7::S7_inherits(sk[[1]], curve_line))
  expect_true(S7::S7_inherits(sk[[2]], curve_line))
})

test_that("sketchy() layers differ from the unperturbed path once jitter > 0", {
  sk <- sketchy(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)), layers = 2L, jitter = 0.2)
  expect_false(isTRUE(all.equal(sk[[1]]@x, c(0, 1, 2))))
})

test_that("sketchy() collapses to the unperturbed path when jitter = 0", {
  sk <- sketchy(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)), layers = 3L, jitter = 0)
  for (i in seq_len(3)) {
    expect_equal(sk[[i]]@x, c(0, 1, 2))
    expect_equal(sk[[i]]@y, c(0, 1, 0))
  }
})

test_that("sketchy() layers wobble independently rather than in lockstep", {
  sk <- sketchy(curve_line(x = c(0, 1, 2, 3), y = c(0, 1, 0, 1)), layers = 2L, jitter = 0.2)
  expect_false(isTRUE(all.equal(sk[[1]]@x, sk[[2]]@x)))
})

test_that("sketchy() is reproducible for a given seed, and varies across seeds", {
  obj <- curve_line(x = c(0, 1, 2), y = c(0, 1, 0))
  sk_a <- sketchy(obj, seed = 3L)
  sk_b <- sketchy(obj, seed = 3L)
  sk_c <- sketchy(obj, seed = 4L)
  expect_identical(sk_a[[1]]@points, sk_b[[1]]@points)
  expect_false(isTRUE(all.equal(sk_a[[1]]@x, sk_c[[1]]@x)))
})

test_that("sketchy() preserves object's other properties across every layer", {
  sk <- sketchy(
    shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.3, color_alpha = 0.4),
    layers = 2L
  )
  expect_equal(sk[[1]]@width, 0.3)
  expect_equal(sk[[1]]@style@color_alpha, 0.4)
  expect_equal(sk[[2]]@width, 0.3)
  expect_equal(sk[[2]]@style@color_alpha, 0.4)
})

test_that("sketchy() works with shape_stroke() as object", {
  sk <- sketchy(shape_stroke(x = c(0, 1, 2), y = c(0, 1, 0), width = 0.2), layers = 2L)
  expect_true(S7::S7_inherits(sk[[1]], shape_stroke))
})

test_that("sketchy() validates its arguments", {
  expect_error(sketchy(curve_line(x = c(0, 1), y = c(0, 1)), layers = 0L), "layers")
  expect_error(sketchy(curve_line(x = c(0, 1), y = c(0, 1)), layers = 1.5), "layers")
  expect_error(sketchy(curve_line(x = c(0, 1), y = c(0, 1)), jitter = -1), "jitter")
  expect_error(sketchy(curve_line(x = c(0, 1), y = c(0, 1)), jitter_frequency = -1), "jitter_frequency")
  expect_error(sketchy(1), "<drawable>")
  # shape_ribbon() has enough scalar x/y properties to pass a naive
  # "has x/y" check, but they're a segment's start point, not a
  # perturbable control-point path -- pathlike catches this directly
  expect_error(sketchy(shape_ribbon(x = 0, y = 0, xend = 1, yend = 1)), "pathlike")
})

test_that("draw() renders a sketchy() sketch without error", {
  sk <- sketchy(curve_line(x = c(0, 1, 2), y = c(0, 1, 0)))
  expect_no_error(draw(sk))
})
