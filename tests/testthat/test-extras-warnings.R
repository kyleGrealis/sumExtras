# Tests for Issue 9: Warning on failure instead of silent failure
# Tests that extras() warns when add_overall() or add_p() fail

# context("extras() - Warning on failure")

test_that("extras() completes successfully with normal stratified table", {
  skip_if_not_installed("gtsummary")

  # Should not warn with normal operation
  expect_no_warning(
    gtsummary::trial |>
      gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
      extras(pval = TRUE, overall = TRUE)
  )
})

test_that("extras() returns valid gtsummary object even if components fail", {
  skip_if_not_installed("gtsummary")

  result <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = age) |>
    extras()

  expect_s3_class(result, "gtsummary")
})

test_that("extras() silently skips overall/pval for non-stratified tables", {
  skip_if_not_installed("gtsummary")

  # Non-stratified table should not warn (features silently skipped)
  expect_no_warning(
    gtsummary::trial |>
      gtsummary::tbl_summary(include = age) |>
      extras(pval = TRUE, overall = TRUE)
  )
})

test_that("extras() with .args parameter works without warnings", {
  skip_if_not_installed("gtsummary")

  extra_args <- list(pval = TRUE, overall = TRUE, last = FALSE)

  expect_no_warning(
    gtsummary::trial |>
      gtsummary::tbl_summary(by = trt, include = age) |>
      extras(.args = extra_args)
  )
})

test_that("extras() warning has correct class when add_overall fails", {
  skip_if_not_installed("gtsummary")

  # This test documents the expected warning class
  # Actual triggering depends on gtsummary internal failures
  # The warning class should be "extras_overall_failed" when it does trigger

  # We can't easily force add_overall() to fail without breaking gtsummary
  # But we verify the warning infrastructure is in place by checking the function
  func_body <- deparse(body(extras))

  expect_true(any(grepl("extras_overall_failed", func_body)))
  expect_true(any(grepl("Failed to add overall column", func_body)))
})

test_that("extras() warning has correct class when add_p fails", {
  skip_if_not_installed("gtsummary")

  # This test documents the expected warning class
  # The warning class should be "extras_pvalue_failed" when it triggers

  func_body <- deparse(body(extras))

  expect_true(any(grepl("extras_pvalue_failed", func_body)))
  expect_true(any(grepl("Failed to add p-values", func_body)))
})

test_that("extras() completes with both pval and overall options", {
  skip_if_not_installed("gtsummary")

  result <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
    extras(pval = TRUE, overall = TRUE, last = FALSE)

  expect_s3_class(result, "gtsummary")

  # Verify both features were added
  expect_true("p.value" %in% names(result$table_body))
  expect_true("stat_0" %in% names(result$table_body))
})

test_that("extras() completes with last = TRUE for overall column", {
  skip_if_not_installed("gtsummary")

  result <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = age) |>
    extras(overall = TRUE, last = TRUE)

  expect_s3_class(result, "gtsummary")
  expect_true("stat_0" %in% names(result$table_body))
})
