test_that("fill_hatch() returns a grid pattern object", {
  fill <- fill_hatch()
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_hatch() validates its arguments", {
  expect_error(fill_hatch(spacing = 0), "spacing")
  expect_error(fill_hatch(spacing = -1), "spacing")
  expect_error(fill_hatch(aspect = 0), "aspect")
  expect_error(fill_hatch(aspect = -1), "aspect")
  expect_error(fill_hatch(angle = c(1, 2)), "angle")
})

test_that("fill_hatch() handles axis-aligned angles without error", {
  expect_s3_class(fill_hatch(angle = 0), "GridPattern")
  expect_s3_class(fill_hatch(angle = 90), "GridPattern")
  expect_s3_class(fill_hatch(angle = 180), "GridPattern")
})

test_that("fill_hatch() works with a non-default aspect ratio", {
  fill <- fill_hatch(angle = 45, aspect = 2.33)
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_crosshatch() returns a grid pattern object", {
  fill <- fill_crosshatch()
  expect_s3_class(fill, "GridPattern")
})

test_that("fill_crosshatch() validates its arguments", {
  expect_error(fill_crosshatch(spacing = 0), "spacing")
  expect_error(fill_crosshatch(spacing = -1), "spacing")
  expect_error(fill_crosshatch(aspect = 0), "aspect")
  expect_error(fill_crosshatch(aspect = -1), "aspect")
  expect_error(fill_crosshatch(angle = c(1, 2)), "angle")
})

test_that("fill_crosshatch() handles angles that are multiples of 90 without error", {
  expect_s3_class(fill_crosshatch(angle = 0), "GridPattern")
  expect_s3_class(fill_crosshatch(angle = 90), "GridPattern")
  expect_s3_class(fill_crosshatch(angle = 180), "GridPattern")
  expect_s3_class(fill_crosshatch(angle = -90), "GridPattern")
})

test_that("fill_crosshatch() works with a non-default aspect ratio", {
  fill <- fill_crosshatch(angle = 30, aspect = 2.33)
  expect_s3_class(fill, "GridPattern")
})
