test_that("every shape_*() defaults to polygon geometry", {
  expect_identical(shape_circle()@geometry, "polygon")
  expect_identical(shape_blob(seed = 1L)@geometry, "polygon")
  expect_identical(shape_ribbon()@geometry, "polygon")
  expect_identical(shape_twist(seed = 1L)@geometry, "polygon")
  expect_identical(shape_bezier(x = c(0, 1, 2), y = c(0, 1, 0))@geometry, "polygon")
})

test_that("geometry is validated as one of the three allowed values", {
  # no shape_*() constructor exposes `geometry` yet (every shape_*() is
  # fixed to "polygon"; curve_*()/points_raw() fix "path"/"points"
  # instead), so exercise the validator via S7::prop<-, which
  # re-validates on assignment
  cc <- shape_circle()
  expect_error(S7::prop(cc, "geometry") <- "triangle", "geometry")
  expect_error(S7::prop(cc, "geometry") <- c("path", "points"), "geometry")
})

test_that("circle points lie on the expected radius", {
  cc <- shape_circle(x = 0, y = 0, radius = 2, n = 50L)
  d <- sqrt(cc@points@x^2 + cc@points@y^2)
  expect_equal(d, rep(2, 50), tolerance = 1e-8)
})

test_that("sketch requires drawable-classed shapes", {
  expect_error(sketch(shapes = list(1, 2)))
})

test_that("+ appends a drawable to a sketch", {
  s <- sketch() + shape_circle() + shape_circle(x = 2)
  expect_length(s@shapes, 2)
})

test_that("convert freezes a drawable's points into a shape", {
  b <- shape_blob(radius = 1, seed = 1L)
  s <- convert(b, shape_raw)
  expect_s3_class(s, "sketchpad::shape_raw")
  expect_equal(s@x, b@points@x)
})

