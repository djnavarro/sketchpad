local_null_device <- function() {
  grDevices::pdf(nullfile())
  withr::defer(grDevices::dev.off(), envir = parent.frame())
}

test_that("group() defaults to no shapes, identity trans, no style override", {
  g <- group()
  expect_equal(length(g), 0L)
  expect_true(S7::S7_inherits(g@trans, trans))
  expect_true(isTRUE(all.equal(g@trans@matrix, diag(3))))
  expect_null(g@style)
})

test_that("+ accumulates drawables into a group's shapes", {
  circ <- shape_circle(radius = 1)
  blob <- shape_blob(x = 2)
  g <- group() + circ + blob

  expect_equal(length(g), 2L)
  expect_equal(g[[1]], circ)
  expect_equal(g[[2]], blob)
})

test_that("a group can nest another group", {
  inner <- group() + shape_circle(radius = 1)
  outer <- group() + inner + shape_square(x = 2)

  expect_equal(length(outer), 2L)
  expect_true(S7::S7_inherits(outer[[1]], group))
  expect_equal(outer[[1]], inner)
})

test_that("group + trans composes onto @trans without touching members' own trans", {
  circ <- shape_circle(radius = 1)
  g <- group() + circ
  rotated <- g + trans_rotate(pi / 6)

  expect_equal(rotated@trans, trans_identity() + trans_rotate(pi / 6))
  # the member's own trans is untouched
  expect_equal(rotated[[1]]@trans, circ@trans)
})

test_that("group + trans_warp/trans_fn/trans_chain also composes onto @trans", {
  # the group's own @trans starts as a plain trans_identity(); composing it
  # with a non-affine transform can't collapse into a single matrix, so it
  # becomes a trans_chain (mirrors drawable's own trans + trans_warp)
  g <- group() + shape_circle(radius = 1)

  g_warp <- g + trans_warp(amount = 0.1)
  expect_true(S7::S7_inherits(g_warp@trans, trans_chain))

  swirl <- function(x, y) list(x = x, y = y)
  g_fn <- g + trans_fn(swirl)
  expect_true(S7::S7_inherits(g_fn@trans, trans_chain))

  g_chain <- g + trans_rotate(pi / 6) + trans_warp(amount = 0.1)
  expect_true(S7::S7_inherits(g_chain@trans, trans_chain))
})

test_that("group + style sets a style override", {
  g <- group() + shape_circle(radius = 1)
  styled <- g + style(color = "tomato")

  expect_true(S7::S7_inherits(styled@style, style))
  expect_equal(styled@style@color, "tomato")
  # the member's own style is untouched
  expect_equal(styled[[1]]@style@color, "black")
})

test_that("shapes must be a list of drawable/group objects", {
  expect_error(group(shapes = list(1)), "drawable/group")
})

test_that("style must be NULL or a style object", {
  expect_error(group(style = "tomato"), "style")
})

test_that("a group can be added to a sketch alongside plain drawables", {
  g <- group() + shape_circle(radius = 1)
  s <- sketch() + g + shape_square(x = 2)

  expect_equal(length(s), 2L)
  expect_true(S7::S7_inherits(s[[1]], group))
  expect_true(S7::S7_inherits(s[[2]], drawable))
})

test_that("[ returns a group containing the selected shapes", {
  circ <- shape_circle(radius = 1)
  blob <- shape_blob(x = 2)
  square <- shape_square(x = 4)
  g <- group() + circ + blob + square

  sub <- g[c(1, 3)]
  expect_true(S7::S7_inherits(sub, group))
  expect_equal(length(sub), 2L)
  expect_equal(sub[[1]], circ)
  expect_equal(sub[[2]], square)
})

test_that("flatten_shapes() leaves a top-level drawable's points unchanged", {
  circ <- shape_circle(radius = 1, n = 8L)
  out <- flatten_shapes(list(circ))

  expect_length(out, 1L)
  expect_equal(out[[1]]@points@x, circ@points@x)
  expect_equal(out[[1]]@points@y, circ@points@y)
  expect_equal(out[[1]]@style, circ@style)
})

test_that("resolve_group() composes the group's own trans after each member's own trans", {
  member <- shape_square(side = 1, trans = trans_translate(1, 0))
  g <- group() + member + trans_rotate(pi / 2)

  resolved <- resolve_group(g)
  expect_length(resolved, 1L)

  # expected: member's own trans_translate(1, 0) applied first, then the
  # group's own trans_rotate(pi / 2) -- not the reverse order. Apply the
  # full chain to the member's own *raw* (pre-trans) points from scratch.
  expected_trans <- trans_translate(1, 0) + trans_rotate(pi / 2)
  raw <- shape_square(side = 1)@points
  expected_pts <- apply_trans(expected_trans, raw)

  expect_equal(resolved[[1]]@points@x, expected_pts@x)
  expect_equal(resolved[[1]]@points@y, expected_pts@y)
})

test_that("a member with no enclosing style override keeps its own style", {
  circ <- shape_circle(radius = 1, color = "forestgreen")
  g <- group() + circ

  resolved <- resolve_group(g)
  expect_equal(resolved[[1]]@style@color, "forestgreen")
})

test_that("an outer group's style override cascades down to a member with none", {
  circ <- shape_circle(radius = 1, color = "forestgreen")
  g <- (group() + circ) + style(color = "tomato")

  resolved <- resolve_group(g)
  expect_equal(resolved[[1]]@style@color, "tomato")
})

test_that("a nested group's own style override wins over an outer one", {
  circ <- shape_circle(radius = 1, color = "forestgreen")
  inner <- (group() + circ) + style(color = "steelblue")
  outer <- (group() + inner) + style(color = "tomato")

  resolved <- resolve_group(outer)
  expect_equal(resolved[[1]]@style@color, "steelblue")
})

test_that("nesting flattens all the way down to plain drawables", {
  a <- shape_circle(radius = 1)
  b <- shape_square(x = 2)
  nested <- group() + (group() + a) + (group() + b)

  resolved <- resolve_group(nested)
  expect_length(resolved, 2L)
  expect_true(all(purrr::map_lgl(resolved, \(d) S7::S7_inherits(d, drawable))))
})

test_that("draw(group) renders without error", {
  local_null_device()
  g <- group() + shape_circle(radius = 1) + shape_square(x = 2)
  expect_no_error(draw(g))
})

test_that("draw(group) renders a group with a trans and style override without error", {
  local_null_device()
  g <- (group() + shape_circle(radius = 1) + shape_square(x = 2)) +
    trans_rotate(pi / 6) +
    style(color = "tomato")
  expect_no_error(draw(g))
})

test_that("draw(sketch) renders a sketch containing a group without error", {
  local_null_device()
  g <- group() + shape_circle(radius = 1)
  s <- sketch() + g + shape_square(x = 2)
  expect_no_error(draw(s))
})

test_that("draw(group) actually applies the group's own @trans (regression)", {
  # regression test for a bug where draw(group) called
  # flatten_shapes(object@shapes) -- which resolves object's own children
  # but never composes object's own @trans/@style at all -- instead of
  # resolve_group(object), silently dropping any trans/style set directly
  # on the group being drawn. grid.grabExpr() lets us inspect the actual
  # rendered pathGrob's coordinates, not just resolve_group()'s output
  # (which was already correct and already covered by the tests above --
  # the bug was specifically in how draw(group) was wired to it).
  local_null_device()
  member <- shape_square(side = 1)
  g <- (group() + member) + trans_rotate(pi / 6)

  grabbed <- grid::grid.grabExpr(draw(g))
  rendered <- grabbed$children[[1]]
  expected <- apply_trans(trans_rotate(pi / 6), member@points)

  expect_equal(as.numeric(rendered$x), expected@x)
  expect_equal(as.numeric(rendered$y), expected@y)
})

test_that("draw(group) actually applies the group's own @style override (regression)", {
  local_null_device()
  g <- (group() + shape_square(side = 1)) + style(color = "tomato", fill = "grey90")

  grabbed <- grid::grid.grabExpr(draw(g))
  rendered <- grabbed$children[[1]]

  expect_equal(rendered$gp$col, "tomato")
  expect_equal(rendered$gp$fill, "grey90")
})
