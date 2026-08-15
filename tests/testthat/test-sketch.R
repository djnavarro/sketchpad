test_that("length() reports the number of shapes", {
  s <- sketch()
  expect_equal(length(s), 0L)

  s <- s + shape_circle(radius = 1) + shape_circle(x = 2, radius = 0.5)
  expect_equal(length(s), 2L)
})

test_that("[[ returns a single drawable", {
  circ <- shape_circle(radius = 1)
  blob <- shape_blob(x = 2)
  s <- sketch() + circ + blob

  expect_equal(s[[1]], circ)
  expect_equal(s[[2]], blob)
})

test_that("[ returns a sketch containing the selected shapes", {
  circ <- shape_circle(radius = 1)
  blob <- shape_blob(x = 2)
  square <- shape_square(x = 4)
  s <- sketch(canvas = canvas(background = "grey95")) + circ + blob + square

  sub <- s[c(1, 3)]
  expect_true(S7::S7_inherits(sub, sketch))
  expect_equal(length(sub), 2L)
  expect_equal(sub[[1]], circ)
  expect_equal(sub[[2]], square)
  # canvas is preserved on the subset
  expect_equal(sub@canvas, s@canvas)
})

test_that("[ supports logical indexing", {
  circ <- shape_circle(radius = 1)
  blob <- shape_blob(x = 2)
  s <- sketch() + circ + blob

  sub <- s[c(TRUE, FALSE)]
  expect_equal(length(sub), 1L)
  expect_equal(sub[[1]], circ)
})
