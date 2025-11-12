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

test_that("clean_table() works in pipeline with other functions", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    gtsummary::add_overall() |>
    gtsummary::add_p() |>
    clean_table()

  expect_s3_class(tbl, "gtsummary")
})
