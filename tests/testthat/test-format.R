test_that("format(drawable) reports class name, own properties, style, geometry, trans", {
  cc <- shape_circle(x = 1, y = 2, radius = 3, n = 8L, color = "red", linewidth = 2)
  out <- format(cc)
  expect_true(any(grepl("^<shape_circle>$", out)))
  expect_true(any(grepl("x = 1.*y = 2.*radius = 3.*n = 8", out)))
  expect_true(any(grepl("style:.*color = red.*linewidth = 2", out)))
  expect_true(any(grepl("geometry: polygon, trans: identity", out)))
})

test_that("format(drawable) omits the computed points property", {
  out <- format(shape_circle(n = 8L))
  expect_false(any(grepl("points", out)))
})

test_that("format(drawable) summarizes a nested S7 property by class name", {
  b <- shape_blob(radius = 1, distortion = noise_field(seed = 1L))
  out <- format(b)
  expect_true(any(grepl("distortion = <noise_field>", out)))
})

test_that("format(drawable) truncates a long numeric property", {
  cl <- curve_line(x = 1:10, y = 1:10)
  out <- format(cl)
  expect_true(any(grepl("\\.\\.\\. \\(10 total\\)", out)))
})

test_that("format(drawable) reports a non-identity trans", {
  rotated <- shape_rectangle(width = 1, height = 1, trans = trans_rotate(pi / 6))
  expect_true(any(grepl("trans: affine", format(rotated))))

  warped <- shape_rectangle(width = 1, height = 1, trans = trans_warp())
  expect_true(any(grepl("trans: warp", format(warped))))

  chained <- shape_rectangle(width = 1, height = 1, trans = trans_rotate(pi / 6) + trans_warp())
  expect_true(any(grepl("trans: chain \\(2 steps\\)", format(chained))))

  identity_fn <- function(x, y) list(x = x, y = y)
  fn_trans <- shape_rectangle(width = 1, height = 1, trans = trans_fn(identity_fn))
  expect_true(any(grepl("trans: fn", format(fn_trans))))
})

test_that("print(drawable) prints format(drawable)'s lines and returns its input invisibly", {
  cc <- shape_circle(n = 8L)
  expect_identical(withVisible(print(cc)), list(value = cc, visible = FALSE))
  expect_output(print(cc), format(cc)[1], fixed = TRUE)
})

test_that("format(sketch) reports shape count, each shape's class, and canvas summary", {
  s <- sketch() + shape_circle() + shape_blob(distortion = noise_field(seed = 1L))
  out <- format(s)
  expect_true(any(grepl("^<sketch: 2 shapes>$", out)))
  expect_true(any(grepl("1: shape_circle", out)))
  expect_true(any(grepl("2: shape_blob", out)))
  expect_true(any(grepl("canvas:", out)))
})

test_that("format(sketch) handles an empty sketch and singular/plural shape counts", {
  expect_true(any(grepl("^<sketch: 0 shapes>$", format(sketch()))))
  expect_true(any(grepl("^<sketch: 1 shape>$", format(sketch() + shape_circle()))))
})

test_that("format(sketch) reports canvas background/clip", {
  s <- sketch(canvas = canvas(background = "grey90", clip = TRUE))
  out <- format(s)
  expect_true(any(grepl("background = grey90", out)))
  expect_true(any(grepl("clip = TRUE", out)))
})

test_that("print(sketch) prints format(sketch)'s lines and returns its input invisibly", {
  s <- sketch() + shape_circle()
  expect_identical(withVisible(print(s)), list(value = s, visible = FALSE))
  expect_output(print(s), format(s)[1], fixed = TRUE)
})

test_that("format(group) reports shape count, each shape's class, trans, and style", {
  g <- group() + shape_circle() + shape_blob(distortion = noise_field(seed = 1L))
  out <- format(g)
  expect_true(any(grepl("^<group: 2 shapes>$", out)))
  expect_true(any(grepl("1: shape_circle", out)))
  expect_true(any(grepl("2: shape_blob", out)))
  expect_true(any(grepl("trans: identity", out)))
  expect_true(any(grepl("style: none", out)))
})

test_that("format(group) handles an empty group and singular/plural shape counts", {
  expect_true(any(grepl("^<group: 0 shapes>$", format(group()))))
  expect_true(any(grepl("^<group: 1 shape>$", format(group() + shape_circle()))))
})

test_that("format(group) reports a nested group member by class name", {
  nested <- group() + (group() + shape_circle())
  out <- format(nested)
  expect_true(any(grepl("1: group", out)))
})

test_that("format(group) reports a non-identity trans and a style override", {
  g <- (group() + shape_circle()) + trans_rotate(pi / 6) + style(color = "tomato", linewidth = 2)
  out <- format(g)
  expect_true(any(grepl("trans: affine", out)))
  expect_true(any(grepl("style: color = tomato.*linewidth = 2", out)))
})

test_that("print(group) prints format(group)'s lines and returns its input invisibly", {
  g <- group() + shape_circle()
  expect_identical(withVisible(print(g)), list(value = g, visible = FALSE))
  expect_output(print(g), format(g)[1], fixed = TRUE)
})
