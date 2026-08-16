test_that("palette_manual() returns the stored palette's own colours by default", {
  pal <- palette_manual(index = 1)
  expect_type(pal, "character")
  expect_length(pal, 5)
  expect_true(all(grepl("^#[0-9a-f]{6}$", pal)))
})

test_that("palette_manual() interpolates to n colours", {
  pal <- palette_manual(n = 12, index = 1)
  expect_length(pal, 12)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", pal)))
})

test_that("palette_manual() is deterministic for a given index", {
  expect_identical(palette_manual(index = 3), palette_manual(index = 3))
  expect_false(identical(palette_manual(index = 1), palette_manual(index = 2)))
})

test_that("palette_manual() validates its arguments", {
  expect_error(palette_manual(index = 0), "index")
  expect_error(palette_manual(index = 1e6), "index")
  expect_error(palette_manual(index = "a"), "index")
  expect_error(palette_manual(n = 0, index = 1), "n")
  expect_error(palette_manual(n = 1.5, index = 1), "n")
})

test_that("palette_cosine() returns n valid hex colours", {
  pal <- palette_cosine(n = 16, seed = 11)
  expect_type(pal, "character")
  expect_length(pal, 16)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", pal)))
})

test_that("palette_cosine() is reproducible for a given seed", {
  pal_a <- palette_cosine(n = 8, seed = 481L)
  pal_b <- palette_cosine(n = 8, seed = 481L)
  pal_c <- palette_cosine(n = 8, seed = 482L)
  expect_identical(pal_a, pal_b)
  expect_false(identical(pal_a, pal_c))
})

test_that("palette_cosine() validates its arguments", {
  expect_error(palette_cosine(n = 0), "n")
  expect_error(palette_cosine(n = 1.5), "n")
  expect_error(palette_cosine(n = 8, base = character(0)), "base")
  expect_error(palette_cosine(n = 8, base = NA_character_), "base")
  expect_error(palette_cosine(n = 8, seed = 1.5), "seed")
})
