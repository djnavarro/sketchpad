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
