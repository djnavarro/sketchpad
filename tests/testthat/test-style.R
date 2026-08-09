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
  b <- shape_blob(fill = fill_stipple())
  expect_true(inherits(b@style@fill, "GridPattern"))
})

test_that("style()'s linetype/linejoin default to \"solid\"/\"round\"", {
  expect_identical(style()@linetype, "solid")
  expect_identical(style()@linejoin, "round")
})

test_that("style() accepts named, integer, and custom hex linetypes", {
  expect_identical(style(linetype = "dashed")@linetype, "dashed")
  expect_identical(style(linetype = 2)@linetype, 2)
  expect_identical(style(linetype = "13")@linetype, "13")
})

test_that("style() accepts every valid linejoin value", {
  expect_identical(style(linejoin = "round")@linejoin, "round")
  expect_identical(style(linejoin = "mitre")@linejoin, "mitre")
  expect_identical(style(linejoin = "bevel")@linejoin, "bevel")
})

test_that("style() rejects an invalid linejoin", {
  expect_error(style(linejoin = "curvy"), "linejoin")
})

test_that("style() rejects a non-scalar linetype or linejoin", {
  expect_error(style(linetype = c("solid", "dashed")), "linetype")
  expect_error(style(linejoin = c("round", "mitre")), "linejoin")
})
