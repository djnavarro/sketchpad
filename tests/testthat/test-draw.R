local_null_device <- function() {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off(), envir = parent.frame())
}

test_that("draw() renders a solid-fill drawable without error", {
  local_null_device()
  expect_no_error(draw(shape_circle(fill = fill_solid("red"))))
})

test_that("draw() renders a fill_hatch()-filled drawable without error", {
  local_null_device()
  expect_no_error(draw(shape_circle(fill = fill_hatch())))
})

test_that("draw() renders a fill_gradient()-filled drawable without error", {
  local_null_device()
  expect_no_error(draw(shape_blob(seed = 1L, fill = fill_gradient(type = "radial"))))
})

test_that("draw() renders a sketch mixing solid and pattern fills without error", {
  local_null_device()
  s <- sketch() +
    shape_circle(fill = fill_solid("blue")) +
    shape_circle(x = 3, fill = fill_crosshatch())
  expect_no_error(draw(s))
})

test_that("draw() renders path and points geometries without error", {
  local_null_device()
  path_shape <- shape_circle()
  S7::prop(path_shape, "geometry") <- "path"
  points_shape <- shape_circle()
  S7::prop(points_shape, "geometry") <- "points"
  expect_no_error(draw(path_shape))
  expect_no_error(draw(points_shape))
})

test_that("draw() renders custom linetype/linejoin without error", {
  local_null_device()
  expect_no_error(draw(shape_circle(linetype = "dashed", linejoin = "mitre")))
  path_shape <- shape_circle(linetype = "dotdash", linejoin = "bevel")
  S7::prop(path_shape, "geometry") <- "path"
  expect_no_error(draw(path_shape))
})

test_that("draw() rejects an invalid geometry at draw time", {
  local_null_device()
  # bypass the drawable validator to exercise geometry_grob()'s own guard
  bad_shape <- shape_circle()
  S7::prop(bad_shape, "geometry", check = FALSE) <- "triangle"
  expect_error(draw(bad_shape), "geometry")
})
