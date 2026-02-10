# Tests for clean_table() function

test_that("clean_table() works with basic table", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    clean_table()

  expect_s3_class(tbl, "gtsummary")
})

test_that("clean_table() handles missing data correctly", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("dplyr")

  # Create data with missing values
  trial_missing <- gtsummary::trial |>
    dplyr::mutate(
      marker = dplyr::if_else(trt == "Drug A", NA_real_, marker)
    )

  tbl <- trial_missing |>
    gtsummary::tbl_summary(by = trt) |>
    clean_table()

  expect_s3_class(tbl, "gtsummary")

  # Check that missing symbol is set
  expect_true(!is.null(tbl$table_styling$text_format))
})

test_that("clean_table() works with regression tables", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("broom")

  mod <- lm(age ~ grade, data = gtsummary::trial)
  tbl <- gtsummary::tbl_regression(mod) |>
    clean_table()

  expect_s3_class(tbl, "gtsummary")
})

test_that("clean_table() uses default symbol '---'", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    clean_table()

  # Check that modify_missing_symbol was applied with default
  fmt_missing <- tbl$table_styling$fmt_missing
  expect_true(any(fmt_missing$symbol == "---"))
})

test_that("clean_table() accepts custom symbol", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    clean_table(symbol = "\u2014")

  fmt_missing <- tbl$table_styling$fmt_missing
  expect_true(any(fmt_missing$symbol == "\u2014"))
})

test_that("clean_table() custom symbol works with em-dash", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    clean_table(symbol = "--")

  fmt_missing <- tbl$table_styling$fmt_missing
  expect_true(any(fmt_missing$symbol == "--"))
})

test_that("extras() passes symbol to clean_table()", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(symbol = "\u2013")

  fmt_missing <- tbl$table_styling$fmt_missing
  expect_true(any(fmt_missing$symbol == "\u2013"))
})

test_that("extras() symbol works through .args", {
  skip_if_not_installed("gtsummary")

  args <- list(symbol = "N/A", pval = FALSE)

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(.args = args)

  fmt_missing <- tbl$table_styling$fmt_missing
  expect_true(any(fmt_missing$symbol == "N/A"))
})

test_that("clean_table() works in pipeline with other functions", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    gtsummary::add_overall() |>
    gtsummary::add_p() |>
    clean_table()

  expect_s3_class(tbl, "gtsummary")
})

# =============================================================================
# Input validation error tests
# =============================================================================

test_that("clean_table() errors with non-gtsummary input", {
  expect_error(
    clean_table(mtcars),
    class = "clean_table_invalid_input"
  )
})

test_that("clean_table() errors with invalid symbol type", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = age)

  expect_error(
    clean_table(tbl, symbol = 123),
    class = "clean_table_invalid_symbol"
  )
})

test_that("clean_table() errors with NULL symbol", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = age)

  expect_error(
    clean_table(tbl, symbol = NULL),
    class = "clean_table_invalid_symbol"
  )
})

test_that("clean_table() errors with vector symbol", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = age)

  expect_error(
    clean_table(tbl, symbol = c("---", "--")),
    class = "clean_table_invalid_symbol"
  )
})
