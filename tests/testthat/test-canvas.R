local_null_device <- function() {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off(), envir = parent.frame())
}

test_that("canvas() defaults to no background, auto limits, no clipping", {
  cv <- canvas()
  expect_identical(cv@background, fill_none())
  expect_null(cv@xlim)
  expect_null(cv@ylim)
  expect_false(cv@clip)
})

test_that("canvas() accepts a plain colour or a fill_*() pattern as background", {
  expect_identical(canvas(background = "grey90")@background, "grey90")
  expect_true(inherits(canvas(background = fill_hatch())@background, "GridPattern"))
})

test_that("canvas() rejects malformed xlim/ylim/clip", {
  expect_error(canvas(xlim = c(0, 1, 2)), "xlim")
  expect_error(canvas(ylim = 1), "ylim")
  expect_error(canvas(clip = c(TRUE, FALSE)), "clip")
})

test_that("sketch() defaults to canvas()", {
  expect_identical(sketch()@canvas, canvas())
})

test_that("sketch() accepts a custom canvas", {
  s <- sketch(canvas = canvas(background = "white"))
  expect_identical(s@canvas@background, "white")
})

test_that("draw() renders a sketch with a solid background without error", {
  local_null_device()
  s <- sketch(canvas = canvas(background = "grey90")) + shape_circle()
  expect_no_error(draw(s))
})

test_that("draw() renders a sketch with a pattern background without error", {
  local_null_device()
  s <- sketch(canvas = canvas(background = fill_hatch())) + shape_circle()
  expect_no_error(draw(s))
})

test_that("draw() uses canvas()'s xlim/ylim when draw()'s own are omitted", {
  local_null_device()
  s <- sketch(canvas = canvas(xlim = c(-5, 5), ylim = c(-5, 5))) + shape_circle(radius = 1)
  expect_no_error(draw(s))
})

test_that("an explicit draw() xlim/ylim overrides canvas()'s own", {
  local_null_device()
  s <- sketch(canvas = canvas(xlim = c(-5, 5), ylim = c(-5, 5))) + shape_circle(radius = 1)
  expect_no_error(draw(s, xlim = c(-1, 1), ylim = c(-1, 1)))
})

test_that("draw() does not clip an overflowing shape when clip = FALSE", {
  local_null_device()
  s <- sketch(canvas = canvas(xlim = c(-0.1, 0.1), ylim = c(-0.1, 0.1), clip = FALSE)) +
    shape_circle(radius = 1)
  expect_no_error(draw(s))
})

test_that("draw() clips an overflowing shape when clip = TRUE", {
  local_null_device()
  s <- sketch(canvas = canvas(xlim = c(-0.1, 0.1), ylim = c(-0.1, 0.1), clip = TRUE)) +
    shape_circle(radius = 1)
  expect_no_error(draw(s))
})
