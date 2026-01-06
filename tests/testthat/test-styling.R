# Tests for styling functions (theme_gt_compact, add_group_styling, get_group_rows)

test_that("theme_gt_compact() works with gt tables", {
  skip_if_not_installed("gt")

  tbl <- mtcars |>
    head() |>
    gt::gt() |>
    theme_gt_compact()

  expect_s3_class(tbl, "gt_tbl")
})

test_that("theme_gt_compact() sets correct options", {
  skip_if_not_installed("gt")

  tbl <- mtcars |>
    head() |>
    gt::gt() |>
    theme_gt_compact()

  expect_s3_class(tbl, "gt_tbl")
  # Check that styling was applied
  expect_true(!is.null(tbl$`_options`))
})

test_that("add_group_styling() works with default formatting", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
    gtsummary::add_variable_group_header(
      header = "Test Group",
      variables = age:grade
    ) |>
    add_group_styling()

  expect_s3_class(tbl, "gtsummary")
})

test_that("add_group_styling() works with bold only", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Demographics",
      variables = age:marker
    ) |>
    add_group_styling(format = "bold")

  expect_s3_class(tbl, "gtsummary")
})

test_that("add_group_styling() works with italic only", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Demographics",
      variables = age:marker
    ) |>
    add_group_styling(format = "italic")

  expect_s3_class(tbl, "gtsummary")
})

test_that("add_group_styling() works with multiple groups", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade, stage)) |>
    gtsummary::add_variable_group_header(
      header = "Group 1",
      variables = age
    ) |>
    gtsummary::add_variable_group_header(
      header = "Group 2",
      variables = marker:stage
    ) |>
    add_group_styling()

  expect_s3_class(tbl, "gtsummary")
})

test_that("get_group_rows() returns correct row numbers", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
    gtsummary::add_variable_group_header(
      header = "Test Group",
      variables = age:grade
    )

  rows <- get_group_rows(tbl)

  expect_type(rows, "integer")
  expect_true(length(rows) > 0)
})

test_that("get_group_rows() works with multiple groups", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade, stage)) |>
    gtsummary::add_variable_group_header(
      header = "Group 1",
      variables = age
    ) |>
    gtsummary::add_variable_group_header(
      header = "Group 2",
      variables = marker:stage
    )

  rows <- get_group_rows(tbl)

  expect_type(rows, "integer")
  expect_equal(length(rows), 2)
})

test_that("get_group_rows() errors with non-gtsummary input", {
  expect_error(
    get_group_rows(mtcars),
    "must be a gtsummary object"
  )
})

test_that("get_group_rows() returns empty vector when no groups", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker))

  rows <- get_group_rows(tbl)

  expect_type(rows, "integer")
  expect_equal(length(rows), 0)
})

test_that("add_group_styling() sets indent to 0 for label rows by default", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
    gtsummary::add_variable_group_header(
      header = "Test Group",
      variables = age:grade
    ) |>
    add_group_styling()

  # Verify that table_styling$indent exists and has n_spaces = 0 for label rows
  indent_df <- tbl$table_styling$indent
  expect_true(any(indent_df$n_spaces == 0))
})

test_that("add_group_styling() accepts custom indent_labels value", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
    gtsummary::add_variable_group_header(
      header = "Test Group",
      variables = age:grade
    ) |>
    add_group_styling(indent_labels = 4L)

  # Verify that table_styling$indent exists and has n_spaces = 4 for label rows
  indent_df <- tbl$table_styling$indent
  expect_true(any(indent_df$n_spaces == 4))
})

test_that("add_group_styling() accepts indent_labels = 2L", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Variables",
      variables = age:marker
    ) |>
    add_group_styling(indent_labels = 2L)

  expect_s3_class(tbl, "gtsummary")
  indent_df <- tbl$table_styling$indent
  expect_true(any(indent_df$n_spaces == 2))
})

test_that("add_group_styling() errors with negative indent_labels", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Test",
      variables = age:marker
    )

  expect_error(
    add_group_styling(tbl, indent_labels = -1L),
    "must be non-negative"
  )
})

test_that("add_group_styling() errors with non-numeric indent_labels", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Test",
      variables = age:marker
    )

  expect_error(
    add_group_styling(tbl, indent_labels = "4"),
    "must be a single integer"
  )
})

test_that("add_group_styling() errors with vector indent_labels", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Test",
      variables = age:marker
    )

  expect_error(
    add_group_styling(tbl, indent_labels = c(0L, 4L)),
    "must be a single integer"
  )
})

# Tests for add_group_colors()

test_that("add_group_colors() returns gt object", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("gt")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
    gtsummary::add_variable_group_header(
      header = "Test Group",
      variables = age:grade
    ) |>
    add_group_colors()

  expect_s3_class(tbl, "gt_tbl")
})

test_that("add_group_colors() works with default color", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("gt")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Demographics",
      variables = age:marker
    ) |>
    add_group_colors()

  expect_s3_class(tbl, "gt_tbl")
})

test_that("add_group_colors() works with custom color", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("gt")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Demographics",
      variables = age:marker
    ) |>
    add_group_colors(color = "#E3F2FD")

  expect_s3_class(tbl, "gt_tbl")
})

test_that("add_group_colors() works with composed styling", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("gt")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Demographics",
      variables = age:marker
    ) |>
    add_group_styling(format = "bold") |>
    add_group_colors(color = "#FFF9E6")

  expect_s3_class(tbl, "gt_tbl")
})

test_that("add_group_colors() works with multiple groups", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("gt")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade, stage)) |>
    gtsummary::add_variable_group_header(
      header = "Group 1",
      variables = age
    ) |>
    gtsummary::add_variable_group_header(
      header = "Group 2",
      variables = marker:stage
    ) |>
    add_group_colors()

  expect_s3_class(tbl, "gt_tbl")
})

test_that("add_group_colors() errors with non-gtsummary input", {
  expect_error(
    add_group_colors(mtcars),
    "must be a gtsummary object"
  )
})

test_that("add_group_colors() errors with invalid color type", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Test",
      variables = age:marker
    )

  expect_error(
    add_group_colors(tbl, color = 123),
    "must be a single character string"
  )
})

test_that("add_group_colors() errors with color vector", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    gtsummary::add_variable_group_header(
      header = "Test",
      variables = age:marker
    )

  expect_error(
    add_group_colors(tbl, color = c("#E8E8E8", "#E3F2FD")),
    "must be a single character string"
  )
})

