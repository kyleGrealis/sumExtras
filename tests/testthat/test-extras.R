# Tests for extras() function

test_that("extras() works with basic tbl_summary", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras()

  expect_s3_class(tbl, "gtsummary")
  expect_true("tbl_summary" %in% class(tbl))
})

test_that("extras() works without p-values", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(pval = FALSE)

  expect_s3_class(tbl, "gtsummary")
  # P-value column should not exist
  expect_false("p.value" %in% names(tbl$table_body))
})

test_that("extras() works without overall column", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(overall = FALSE)

  expect_s3_class(tbl, "gtsummary")
  # Check that stat_0 column (overall) doesn't exist
  expect_false("stat_0" %in% names(tbl$table_body))
})

test_that("extras() works with last parameter", {
  skip_if_not_installed("gtsummary")

  tbl_first <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(last = FALSE)

  tbl_last <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(last = TRUE)

  expect_s3_class(tbl_first, "gtsummary")
  expect_s3_class(tbl_last, "gtsummary")
})

test_that("extras() works with .args parameter", {
  skip_if_not_installed("gtsummary")

  args <- list(pval = TRUE, overall = TRUE, last = FALSE)

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(.args = args)

  expect_s3_class(tbl, "gtsummary")
})

test_that("extras() works with non-stratified tables", {
  skip_if_not_installed("gtsummary")

  # Should work without error even without 'by' argument
  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary() |>
    extras()

  expect_s3_class(tbl, "gtsummary")
})

test_that("extras() handles regression tables", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("broom")

  mod <- lm(age ~ grade + marker, data = gtsummary::trial)
  tbl <- gtsummary::tbl_regression(mod) |>
    extras()

  expect_s3_class(tbl, "gtsummary")
})
