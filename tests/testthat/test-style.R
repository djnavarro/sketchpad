test_that("style()'s default fill is unchanged (\"black\")", {
  expect_identical(style()@fill, "black")
})

test_that("style() accepts a fill_*() pattern/gradient object", {
  expect_true(inherits(style(fill = fill_hatch())@fill, "GridPattern"))
  expect_true(inherits(style(fill = fill_gradient(type = "radial"))@fill, "GridPattern"))
})

test_that("style() still accepts a plain colour string", {
  expect_identical(style(fill = "red")@fill, "red")
})

test_that("style() rejects a fill that is neither a string nor a GridPattern", {
  expect_error(style(fill = 123))
})

test_that("drawable constructors forward fill_*() outputs to style() unchanged", {
  b <- blob(fill = fill_stipple())
  expect_true(inherits(b@style@fill, "GridPattern"))
})
