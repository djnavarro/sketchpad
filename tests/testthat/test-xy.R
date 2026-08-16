test_that("xy() defaults id to a single implicit sub-path", {
  pts <- xy(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1))
  expect_identical(pts@id, rep(1L, 4))
})

test_that("xy() accepts an explicit id, coercing integerish doubles", {
  pts <- xy(x = 1:4, y = 1:4, id = c(1, 1, 2, 2))
  expect_identical(pts@id, c(1L, 1L, 2L, 2L))
})

test_that("xy()'s id defaults to an empty vector for empty x/y", {
  pts <- xy(x = numeric(0), y = numeric(0))
  expect_identical(pts@id, integer(0))
})

test_that("xy() rejects an id of mismatched length", {
  expect_error(xy(x = c(0, 1), y = c(0, 1), id = c(1, 1, 2)))
})

test_that("xy() rejects a non-integerish id", {
  expect_error(xy(x = c(0, 1), y = c(0, 1), id = c(1, 1.5)))
})

test_that("every current drawable's own points has a single implicit sub-path", {
  shapes <- list(
    shape_circle(), shape_rectangle(), shape_polygon(), shape_star(),
    shape_ellipse(), shape_wedge(), shape_blob(),
    shape_ribbon(), shape_stroke(x = c(0, 1), y = c(0, 1), width = 0.1),
    curve_line(x = c(0, 1, 2), y = c(0, 1, 0)), points_raw(x = c(0, 1), y = c(0, 1))
  )
  for (s in shapes) {
    expect_equal(s@points@id, rep(1L, length(s@points@x)))
  }
})
