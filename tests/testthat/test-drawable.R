test_that("circle points lie on the expected radius", {
  cc <- circle(x = 0, y = 0, radius = 2, n = 50L)
  d <- sqrt(cc@points@x^2 + cc@points@y^2)
  expect_equal(d, rep(2, 50), tolerance = 1e-8)
})

test_that("sketch requires drawable-classed shapes", {
  expect_error(sketch(shapes = list(1, 2)))
})

test_that("+ appends a drawable to a sketch", {
  s <- sketch() + circle() + circle(x = 2)
  expect_length(s@shapes, 2)
})

test_that("convert freezes a drawable's points into a shape", {
  b <- blob(radius = 1, seed = 1L)
  s <- convert(b, shape)
  expect_s3_class(s, "sketchpad::shape")
  expect_equal(s@x, b@points@x)
})

