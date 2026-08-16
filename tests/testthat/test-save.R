test_that("save_png() writes a non-empty file", {
  file <- withr::local_tempfile(fileext = ".png")
  expect_invisible(res <- save_png(shape_circle(radius = 1), file))
  expect_identical(res, file)
  expect_true(file.exists(file))
  expect_gt(file.size(file), 0)
})

test_that("save_svg() writes a non-empty file", {
  file <- withr::local_tempfile(fileext = ".svg")

  # capabilities("cairo") reports whether R was *built* with cairo
  # support, not whether the cairo shared library's own runtime
  # dependencies actually resolve -- on some macOS CI runners (missing
  # XQuartz/X11), grDevices::svg() fails to dlopen cairo even though
  # capabilities("cairo") still reports TRUE. Probe the real device
  # directly instead of trusting that flag.
  probe <- withr::local_tempfile(fileext = ".svg")
  svg_works <- withCallingHandlers(
    tryCatch(
      {
        grDevices::svg(probe)
        grDevices::dev.off()
        file.exists(probe) && file.size(probe) > 0
      },
      error = function(e) FALSE
    ),
    warning = function(w) invokeRestart("muffleWarning")
  )
  skip_if_not(svg_works, "svg() device unavailable in this environment (likely missing cairo/X11 support)")

  save_svg(shape_circle(radius = 1), file)
  expect_true(file.exists(file))
  expect_gt(file.size(file), 0)
})

test_that("save_pdf() writes a non-empty file", {
  file <- withr::local_tempfile(fileext = ".pdf")
  save_pdf(shape_circle(radius = 1), file)
  expect_true(file.exists(file))
  expect_gt(file.size(file), 0)
})

test_that("save_*() work on a sketch, not just a single drawable", {
  file <- withr::local_tempfile(fileext = ".png")
  s <- sketch() + shape_circle() + shape_blob(x = 2)
  save_png(s, file)
  expect_true(file.exists(file))
  expect_gt(file.size(file), 0)
})

test_that("save_*() forward extra arguments to draw()", {
  file <- withr::local_tempfile(fileext = ".png")
  expect_no_error(save_png(shape_circle(radius = 1), file, xlim = c(-2, 2), ylim = c(-2, 2)))
})

test_that("save_*() close the device even when draw() itself errors", {
  file <- withr::local_tempfile(fileext = ".png")
  # bypass validate_save_args() so the device actually opens before the
  # error, by erroring inside draw() instead (an invalid geometry)
  bad_shape <- shape_circle()
  S7::prop(bad_shape, "geometry", check = FALSE) <- "triangle"
  n_devices_before <- length(grDevices::dev.list())
  expect_error(save_png(bad_shape, file))
  expect_identical(length(grDevices::dev.list()), n_devices_before)
})

test_that("save_*() reject a non-drawable object", {
  file <- withr::local_tempfile(fileext = ".png")
  expect_error(save_png("not a drawable", file), "drawable")
})

test_that("save_*() reject a bad filename", {
  expect_error(save_png(shape_circle(), 123), "filename")
  expect_error(save_png(shape_circle(), c("a.png", "b.png")), "filename")
})

test_that("save_*() reject non-positive width/height", {
  file <- withr::local_tempfile(fileext = ".png")
  expect_error(save_png(shape_circle(), file, width = -1), "width")
  expect_error(save_png(shape_circle(), file, height = 0), "height")
})

test_that("save_png() rejects a non-positive dpi", {
  file <- withr::local_tempfile(fileext = ".png")
  expect_error(save_png(shape_circle(), file, dpi = 0), "dpi")
})
