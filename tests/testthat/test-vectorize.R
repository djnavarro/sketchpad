test_that("scalar-argument plural constructors recycle length-1 args and error on mismatches", {
  s <- shape_circles(x = 1:3, radius = c(0.5, 1, 1.5))
  expect_true(S7::S7_inherits(s, sketch))
  expect_equal(length(s), 3L)
  expect_equal(purrr::map_dbl(1:3, \(i) s[[i]]@x), 1:3)
  expect_equal(purrr::map_dbl(1:3, \(i) s[[i]]@radius), c(0.5, 1, 1.5))
  # n is left at its length-1 default and recycled
  expect_true(all(purrr::map_dbl(1:3, \(i) s[[i]]@n) == 100L))

  expect_error(shape_circles(x = 1:3, radius = 1:2), "recycle")
})

test_that("style arguments passed via ... are vectorized alongside the shape's own args", {
  s <- shape_circles(x = 1:2, fill = c("red", "blue"))
  expect_equal(s[[1]]@style@fill, "red")
  expect_equal(s[[2]]@style@fill, "blue")
})

test_that("a shared scalar S7 object is recycled across every shape", {
  nf <- noise_field(seed = 99L)
  s <- shape_blobs(x = 1:3, distortion = nf)
  expect_equal(length(s), 3L)
  for (i in 1:3) expect_equal(s[[i]]@distortion, nf)
})

test_that("a list of distinct S7 objects varies per shape instead of being shared", {
  nf1 <- noise_field(seed = 1L)
  nf2 <- noise_field(seed = 2L)
  s <- shape_blobs(x = 1:2, distortion = list(nf1, nf2))
  expect_equal(s[[1]]@distortion, nf1)
  expect_equal(s[[2]]@distortion, nf2)
})

test_that("control-point shapes take x/y as a list of per-shape vectors", {
  s <- shape_beziers(
    x = list(c(0, 0.5, 1, 0.5), c(2, 2.5, 3, 2.5)),
    y = list(c(0, 1, 0, -1), c(0, 1, 0, -1))
  )
  expect_equal(length(s), 2L)
  expect_equal(s[[1]]@x, c(0, 0.5, 1, 0.5))
  expect_equal(s[[2]]@x, c(2, 2.5, 3, 2.5))
})

test_that("curve_lines() vectorizes over a list of control-point vectors", {
  s <- curve_lines(
    x = list(c(0, 1, 1, 2), c(2, 3, 3, 4)),
    y = list(c(0, 1, 0, 1), c(0, 1, 0, 1))
  )
  expect_equal(length(s), 2L)
  expect_true(S7::S7_inherits(s[[1]], curve_line))
})

test_that("points_raws() vectorizes over a list of per-scatter coordinate vectors", {
  s <- points_raws(
    x = list(1:3, 4:6),
    y = list(1:3, 4:6),
    color = c("steelblue", "darkred")
  )
  expect_equal(length(s), 2L)
  expect_equal(s[[1]]@style@color, "steelblue")
  expect_equal(s[[2]]@style@color, "darkred")
})

test_that("a shared noise_bridge path_distortion is recycled across shape_twists()/curve_twists()", {
  nb <- noise_bridge(seed = 42L)
  s <- shape_twists(x = 1:3, xend = 2:4, path_distortion = nb)
  for (i in 1:3) expect_equal(s[[i]]@path_distortion, nb)

  s2 <- curve_twists(x = 1:2, xend = 2:3, path_distortion = nb)
  for (i in 1:2) expect_equal(s2[[i]]@path_distortion, nb)
})

test_that("vectorized constructors produce a zero-shape sketch for zero-length input", {
  s <- shape_circles(x = numeric(0))
  expect_true(S7::S7_inherits(s, sketch))
  expect_equal(length(s), 0L)
})

test_that("draw() renders a sketch built by a vectorized constructor without error", {
  s <- shape_circles(x = 1:3, radius = c(0.5, 1, 1.5))
  expect_no_error(draw(s))
})
