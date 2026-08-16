test_that("trans_identity() is the identity matrix", {
  expect_equal(trans_identity()@matrix, diag(3))
})

test_that("trans_translate() shifts points", {
  pts <- xy(x = c(0, 1), y = c(0, 1))
  out <- apply_trans(trans_translate(2, 3), pts)
  expect_equal(out@x, c(2, 3))
  expect_equal(out@y, c(3, 4))
})

test_that("trans_scale() scales about the origin by default", {
  pts <- xy(x = c(1, 2), y = c(1, -1))
  out <- apply_trans(trans_scale(2, 3), pts)
  expect_equal(out@x, c(2, 4))
  expect_equal(out@y, c(3, -3))
})

test_that("trans_scale() scales about an arbitrary pivot", {
  pts <- xy(x = 2, y = 2)
  out <- apply_trans(trans_scale(2, 2, about_x = 1, about_y = 1), pts)
  expect_equal(out@x, 3)
  expect_equal(out@y, 3)
})

test_that("trans_rotate() rotates about the origin by default", {
  pts <- xy(x = 1, y = 0)
  out <- apply_trans(trans_rotate(pi / 2), pts)
  expect_equal(out@x, 0, tolerance = 1e-12)
  expect_equal(out@y, 1, tolerance = 1e-12)
})

test_that("trans_rotate() rotates about an arbitrary pivot", {
  pts <- xy(x = 2, y = 1)
  out <- apply_trans(trans_rotate(pi / 2, about_x = 1, about_y = 1), pts)
  expect_equal(out@x, 1, tolerance = 1e-12)
  expect_equal(out@y, 2, tolerance = 1e-12)
})

test_that("trans_reflect() flips the requested coordinate(s)", {
  pts <- xy(x = 1, y = 1)
  expect_equal(apply_trans(trans_reflect(x = TRUE), pts)@x, -1)
  expect_equal(apply_trans(trans_reflect(x = TRUE), pts)@y, 1)
  expect_equal(apply_trans(trans_reflect(y = TRUE), pts)@x, 1)
  expect_equal(apply_trans(trans_reflect(y = TRUE), pts)@y, -1)
  expect_equal(apply_trans(trans_reflect(x = TRUE, y = TRUE), pts)@x, -1)
  expect_equal(apply_trans(trans_reflect(x = TRUE, y = TRUE), pts)@y, -1)
})

test_that("trans_reflect() with no axes is the identity", {
  expect_equal(trans_reflect()@matrix, diag(3))
})

test_that("trans_shear() shears points", {
  pts <- xy(x = 1, y = 1)
  out <- apply_trans(trans_shear(shx = 1), pts)
  expect_equal(out@x, 2)
  expect_equal(out@y, 1)
})

test_that("trans_affine() accepts a 3x3 or 2x3 matrix", {
  m3 <- matrix(c(2, 0, 0, 0, 3, 0, 0, 0, 1), nrow = 3, byrow = TRUE)
  m2 <- matrix(c(2, 0, 0, 0, 3, 0), nrow = 2, byrow = TRUE)
  expect_equal(trans_affine(m3)@matrix, m3)
  expect_equal(trans_affine(m2)@matrix, m3)
})

test_that("trans objects compose with + in left-to-right order", {
  t1 <- trans_translate(1, 0)
  t2 <- trans_rotate(pi / 2)
  pts <- xy(x = 0, y = 0)

  translate_then_rotate <- apply_trans(t1 + t2, pts)
  rotate_then_translate <- apply_trans(t2 + t1, pts)

  # translate (1, 0) then rotate 90deg -> (0, 1)
  expect_equal(translate_then_rotate@x, 0, tolerance = 1e-12)
  expect_equal(translate_then_rotate@y, 1, tolerance = 1e-12)

  # rotate 90deg (no-op on origin) then translate (1, 0) -> (1, 0)
  expect_equal(rotate_then_translate@x, 1, tolerance = 1e-12)
  expect_equal(rotate_then_translate@y, 0, tolerance = 1e-12)
})

test_that("trans threads through geometry = 'polygon' drawables (shape_circle)", {
  base <- shape_circle(x = 0, y = 0, radius = 1, n = 4L)
  shifted <- shape_circle(x = 0, y = 0, radius = 1, n = 4L, trans = trans_translate(5, 0))
  expect_equal(shifted@points@x, base@points@x + 5)
  expect_equal(shifted@points@y, base@points@y)
})

test_that("trans threads through geometry = 'path' drawables (curve_line)", {
  base <- curve_line(x = c(0, 1), y = c(0, 1))
  shifted <- curve_line(x = c(0, 1), y = c(0, 1), trans = trans_translate(0, 2))
  expect_equal(shifted@points@x, base@points@x)
  expect_equal(shifted@points@y, base@points@y + 2)
})

test_that("trans threads through geometry = 'points' drawables (points_raw)", {
  base <- points_raw(x = c(0, 1), y = c(0, 1))
  scaled <- points_raw(x = c(0, 1), y = c(0, 1), trans = trans_scale(2))
  expect_equal(scaled@points@x, base@points@x * 2)
  expect_equal(scaled@points@y, base@points@y * 2)
})

test_that("trans is applied after noise-based distortion (shape_blob)", {
  distortion <- noise_field(seed = 101L)
  base <- shape_blob(radius = 1, range = 0.3, n = 10L, distortion = distortion)
  shifted <- shape_blob(
    radius = 1, range = 0.3, n = 10L, distortion = distortion,
    trans = trans_translate(10, 0)
  )
  expect_equal(shifted@points@x, base@points@x + 10)
  expect_equal(shifted@points@y, base@points@y)
})

test_that("trans_identity() is a no-op", {
  circ <- shape_circle(radius = 1, n = 8L)
  expect_equal(apply_trans(trans_identity(), circ@points)@x, circ@points@x)
  expect_equal(apply_trans(trans_identity(), circ@points)@y, circ@points@y)
})

test_that("drawable + trans composes onto the drawable's own trans", {
  circ <- shape_circle(radius = 1, n = 4L) + trans_translate(1, 0)
  expect_equal(circ@points@x, shape_circle(radius = 1, n = 4L, trans = trans_translate(1, 0))@points@x)

  circ2 <- shape_circle(radius = 1, n = 4L) + trans_translate(1, 0) + trans_translate(0, 1)
  expect_equal(
    circ2@points,
    shape_circle(radius = 1, n = 4L, trans = trans_translate(1, 1))@points
  )
})

test_that("sketch + trans transforms every shape in the sketch", {
  s <- sketch() + shape_circle(radius = 1, n = 4L) + shape_square(side = 1)
  moved <- s + trans_translate(3, 0)

  expect_equal(
    moved@shapes[[1]]@points@x,
    (shape_circle(radius = 1, n = 4L) + trans_translate(3, 0))@points@x
  )
  expect_equal(
    moved@shapes[[2]]@points@x,
    (shape_square(side = 1) + trans_translate(3, 0))@points@x
  )
})

test_that("trans_warp() with amount = 0 is a no-op", {
  pts <- xy(x = c(0, 1, 2), y = c(0, -1, 3))
  out <- apply_trans(trans_warp(amount = 0), pts)
  expect_equal(out@x, pts@x)
  expect_equal(out@y, pts@y)
})

test_that("trans_warp() displaces points using noise", {
  pts <- xy(x = c(0, 1, 2), y = c(0, -1, 3))
  out <- apply_trans(trans_warp(amount = 0.2, distortion_x = noise_field(seed = 55L)), pts)
  expect_false(isTRUE(all.equal(out@x, pts@x)))
  expect_false(isTRUE(all.equal(out@y, pts@y)))
  expect_true(all(is.finite(out@x)) && all(is.finite(out@y)))
})

test_that("trans_warp()'s distortion_y defaults to distortion_x's seed + 1", {
  w <- trans_warp(distortion_x = noise_field(seed = 10L))
  expect_equal(w@distortion_y@seed, 11L)
})

test_that("two trans objects still collapse into a single trans via +", {
  combined <- trans_translate(1, 0) + trans_rotate(pi / 2)
  expect_true(S7::S7_inherits(combined, trans))
  expect_false(S7::S7_inherits(combined, trans_chain))
})

test_that("trans + trans_warp produces a trans_chain applied in order", {
  t <- trans_translate(5, 0)
  w <- trans_warp(amount = 0.1, distortion_x = noise_field(seed = 3L))
  chained <- t + w

  expect_true(S7::S7_inherits(chained, trans_chain))
  expect_length(chained@steps, 2)

  pts <- xy(x = c(0, 1), y = c(0, 1))
  expect_equal(apply_trans(chained, pts), apply_trans(w, apply_trans(t, pts)))
})

test_that("trans_warp + trans_warp + trans flattens into one trans_chain", {
  w1 <- trans_warp(amount = 0.1, distortion_x = noise_field(seed = 1L))
  w2 <- trans_warp(amount = 0.2, distortion_x = noise_field(seed = 2L))
  t <- trans_rotate(pi / 4)
  chained <- w1 + w2 + t
  expect_true(S7::S7_inherits(chained, trans_chain))
  expect_length(chained@steps, 3)
})

test_that("trans_warp threads through a drawable via trans = and +", {
  circ_base <- shape_circle(radius = 1, n = 20L)
  circ_via_arg <- shape_circle(radius = 1, n = 20L, trans = trans_warp(amount = 0.1, distortion_x = noise_field(seed = 7L)))
  circ_via_plus <- shape_circle(radius = 1, n = 20L) + trans_warp(amount = 0.1, distortion_x = noise_field(seed = 7L))

  expect_equal(circ_via_arg@points, circ_via_plus@points)
  expect_false(isTRUE(all.equal(circ_via_arg@points@x, circ_base@points@x)))
})

test_that("sketch + trans_warp transforms every shape", {
  w <- trans_warp(amount = 0.1, distortion_x = noise_field(seed = 9L))
  s <- sketch() + shape_circle(radius = 1, n = 10L) + shape_square(side = 1)
  moved <- s + w

  expect_equal(moved@shapes[[1]]@points, (shape_circle(radius = 1, n = 10L) + w)@points)
  expect_equal(moved@shapes[[2]]@points, (shape_square(side = 1) + w)@points)
})

test_that("trans_fn() applies its own fn directly", {
  pts <- xy(x = c(0, 1, 2), y = c(0, -1, 3))
  double_it <- function(x, y) list(x = 2 * x, y = 2 * y)
  out <- apply_trans(trans_fn(double_it), pts)
  expect_equal(out@x, 2 * pts@x)
  expect_equal(out@y, 2 * pts@y)
})

test_that("trans_fn() handles an empty point set without calling fn", {
  called <- FALSE
  fn <- function(x, y) {
    called <<- TRUE
    list(x = x, y = y)
  }
  out <- apply_trans(trans_fn(fn), xy(x = numeric(0), y = numeric(0)))
  expect_equal(out@x, numeric(0))
  expect_equal(out@y, numeric(0))
  expect_false(called)
})

test_that("trans_fn() errors if fn's return value is missing x/y", {
  pts <- xy(x = c(0, 1), y = c(0, 1))
  expect_error(apply_trans(trans_fn(function(x, y) list(x = x)), pts), "x/y")
  expect_error(apply_trans(trans_fn(function(x, y) x + y), pts), "x/y")
})

test_that("trans_fn() errors if fn's return value has the wrong length", {
  pts <- xy(x = c(0, 1, 2), y = c(0, 1, 2))
  bad_fn <- function(x, y) list(x = x[1], y = y[1])
  expect_error(apply_trans(trans_fn(bad_fn), pts), "same length")
})

test_that("trans_fn threads through a drawable via trans = and +", {
  swirl <- function(x, y) {
    r <- sqrt(x^2 + y^2)
    theta <- atan2(y, x) + r
    list(x = r * cos(theta), y = r * sin(theta))
  }
  circ_base <- shape_circle(x = 1, radius = 0.4, n = 20L)
  circ_via_arg <- shape_circle(x = 1, radius = 0.4, n = 20L, trans = trans_fn(swirl))
  circ_via_plus <- shape_circle(x = 1, radius = 0.4, n = 20L) + trans_fn(swirl)

  expect_equal(circ_via_arg@points, circ_via_plus@points)
  expect_false(isTRUE(all.equal(circ_via_arg@points@x, circ_base@points@x)))
})

test_that("sketch + trans_fn transforms every shape", {
  double_it <- function(x, y) list(x = 2 * x, y = 2 * y)
  f <- trans_fn(double_it)
  s <- sketch() + shape_circle(radius = 1, n = 10L) + shape_square(side = 1)
  moved <- s + f

  expect_equal(moved@shapes[[1]]@points, (shape_circle(radius = 1, n = 10L) + f)@points)
  expect_equal(moved@shapes[[2]]@points, (shape_square(side = 1) + f)@points)
})

test_that("trans_fn composes with trans/trans_warp/trans_fn into a trans_chain", {
  identity_fn <- function(x, y) list(x = x, y = y)
  f <- trans_fn(identity_fn)
  t <- trans_translate(1, 0)
  w <- trans_warp(amount = 0.1, distortion_x = noise_field(seed = 4L))

  expect_true(S7::S7_inherits(f + t, trans_chain))
  expect_true(S7::S7_inherits(t + f, trans_chain))
  expect_true(S7::S7_inherits(f + w, trans_chain))
  expect_true(S7::S7_inherits(w + f, trans_chain))
  expect_true(S7::S7_inherits(f + f, trans_chain))

  chained <- t + f
  pts <- xy(x = c(0, 1), y = c(0, 1))
  expect_equal(apply_trans(chained, pts), apply_trans(f, apply_trans(t, pts)))
})

test_that("trans_warp + trans_fn + trans flattens into one trans_chain", {
  identity_fn <- function(x, y) list(x = x, y = y)
  w <- trans_warp(amount = 0.1, distortion_x = noise_field(seed = 1L))
  f <- trans_fn(identity_fn)
  t <- trans_rotate(pi / 4)
  chained <- w + f + t
  expect_true(S7::S7_inherits(chained, trans_chain))
  expect_length(chained@steps, 3)
})

test_that("trans_chain's steps validator accepts trans_fn objects", {
  identity_fn <- function(x, y) list(x = x, y = y)
  expect_no_error(trans_chain(steps = list(trans_fn(identity_fn), trans_translate(1, 0))))
  expect_error(trans_chain(steps = list("not a trans")), "trans_fn")
})

test_that("convert() bakes in a drawable's transform", {
  circ <- shape_circle(radius = 1, n = 8L, trans = trans_translate(2, 0))
  frozen <- S7::convert(circ, shape_raw)
  expect_equal(frozen@x, circ@points@x)
  expect_equal(frozen@y, circ@points@y)
  # frozen is a plain shape_raw with its own trans left at the default,
  # since the transform has already been baked into x/y
  expect_equal(frozen@trans@matrix, trans_identity()@matrix)
})

test_that("apply_trans() forwards id unchanged for trans/trans_warp/trans_fn/trans_chain", {
  pts <- xy(x = c(0, 1, 2, 3), y = c(0, 1, 2, 3), id = c(1L, 1L, 2L, 2L))

  expect_identical(apply_trans(trans_translate(1, 0), pts)@id, pts@id)
  expect_identical(
    apply_trans(trans_warp(amount = 0.1, distortion_x = noise_field(seed = 4L)), pts)@id,
    pts@id
  )
  expect_identical(apply_trans(trans_fn(function(x, y) list(x = x, y = y)), pts)@id, pts@id)

  chained <- trans_translate(1, 0) + trans_warp(amount = 0.1, distortion_x = noise_field(seed = 4L))
  expect_identical(apply_trans(chained, pts)@id, pts@id)
})

test_that("apply_trans() on an empty point set returns an empty id too", {
  pts <- xy(x = numeric(0), y = numeric(0))
  expect_identical(apply_trans(trans_translate(1, 0), pts)@id, integer(0))
  expect_identical(apply_trans(trans_warp(amount = 0.1), pts)@id, integer(0))
})
