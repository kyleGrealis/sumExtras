# Tests for extras() warning behavior with different table types
# Tests that extras() warns appropriately but always succeeds

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

# Tests for tbl_regression warning behavior
# Note: tbl_regression objects trigger BOTH regression-specific AND not-stratified warnings
# since they are inherently non-stratified
test_that("tbl_regression warns with regression-specific warning when requesting unsupported features", {
  skip_if_not_installed("gtsummary")

  # Create a regression model first
  m1 <- glm(response ~ age + grade, data = gtsummary::trial, family = binomial)
  tbl <- gtsummary::tbl_regression(m1)

  # Expect the regression-specific warning
  expect_warning(
    result <- extras(tbl, overall = TRUE, pval = TRUE),
    class = "extras_regression_unsupported_features"
  )

  # Also expect the not-stratified warning (since regression tables aren't stratified)
  suppressWarnings(
    expect_warning(
      extras(tbl, overall = TRUE, pval = TRUE),
      class = "extras_not_stratified"
    )
  )
})

test_that("tbl_regression warns when requesting only overall", {
  skip_if_not_installed("gtsummary")

  m1 <- glm(response ~ age + grade, data = gtsummary::trial, family = binomial)
  tbl <- gtsummary::tbl_regression(m1)

  # Both warnings should fire
  expect_warning(
    extras(tbl, overall = TRUE, pval = FALSE),
    class = "extras_regression_unsupported_features"
  )
})

test_that("tbl_regression warns when requesting only pval", {
  skip_if_not_installed("gtsummary")

  m1 <- glm(response ~ age + grade, data = gtsummary::trial, family = binomial)
  tbl <- gtsummary::tbl_regression(m1)

  # Both warnings should fire
  expect_warning(
    extras(tbl, overall = FALSE, pval = TRUE),
    class = "extras_regression_unsupported_features"
  )
})

test_that("tbl_regression does NOT warn when overall and pval are both FALSE", {
  skip_if_not_installed("gtsummary")

  m1 <- glm(response ~ age + grade, data = gtsummary::trial, family = binomial)
  tbl <- gtsummary::tbl_regression(m1)

  expect_no_warning(
    extras(tbl, overall = FALSE, pval = FALSE)
  )
})

test_that("tbl_regression succeeds despite warning", {
  skip_if_not_installed("gtsummary")

  # Create a regression model first
  m1 <- glm(response ~ age + grade, data = gtsummary::trial, family = binomial)
  tbl <- gtsummary::tbl_regression(m1)

  result <- suppressWarnings(extras(tbl, overall = TRUE, pval = TRUE))

  expect_s3_class(result, "gtsummary")
  expect_s3_class(result, "tbl_regression")
})

# Tests for tbl_strata warning behavior
test_that("tbl_strata warns when requesting unsupported features", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("purrr")

  tbl <- gtsummary::trial |>
    dplyr::select(grade, age, trt) |>
    gtsummary::tbl_strata(
      strata = grade,
      .tbl_fun = ~ .x |>
        gtsummary::tbl_summary(by = trt, include = age)
    )

  expect_warning(
    extras(tbl, overall = TRUE, pval = TRUE),
    class = "extras_strata_limited_support"
  )
})

test_that("tbl_strata succeeds despite warning", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("purrr")

  tbl <- gtsummary::trial |>
    dplyr::select(grade, age, trt) |>
    gtsummary::tbl_strata(
      strata = grade,
      .tbl_fun = ~ .x |>
        gtsummary::tbl_summary(by = trt, include = age)
    )

  result <- suppressWarnings(extras(tbl, overall = TRUE, pval = TRUE))

  expect_s3_class(result, "gtsummary")
  expect_s3_class(result, "tbl_strata")
})

# Tests for non-stratified table warning behavior
test_that("non-stratified tbl_summary warns when requesting overall", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age)

  expect_warning(
    extras(tbl, overall = TRUE, pval = FALSE),
    class = "extras_not_stratified"
  )
})

test_that("non-stratified tbl_summary warns when requesting pval", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age)

  expect_warning(
    extras(tbl, pval = TRUE, overall = FALSE),
    class = "extras_not_stratified"
  )
})

test_that("non-stratified tbl_summary warns when requesting both overall and pval", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age)

  expect_warning(
    extras(tbl, overall = TRUE, pval = TRUE),
    class = "extras_not_stratified"
  )
})

test_that("non-stratified tbl_summary succeeds despite warning", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age)

  result <- suppressWarnings(extras(tbl, overall = TRUE, pval = TRUE))

  expect_s3_class(result, "gtsummary")
  expect_s3_class(result, "tbl_summary")
})

test_that("non-stratified tbl_summary does not warn when pval and overall are FALSE", {
  skip_if_not_installed("gtsummary")

  expect_no_warning(
    gtsummary::trial |>
      gtsummary::tbl_summary(include = age) |>
      extras(pval = FALSE, overall = FALSE)
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

test_that("extras() with .args parameter warns for non-stratified table", {
  skip_if_not_installed("gtsummary")

  extra_args <- list(pval = TRUE, overall = TRUE)

  expect_warning(
    gtsummary::trial |>
      gtsummary::tbl_summary(include = age) |>
      extras(.args = extra_args),
    class = "extras_not_stratified"
  )
})

test_that("extras() with .args parameter warns for tbl_regression", {
  skip_if_not_installed("gtsummary")

  m1 <- glm(response ~ age + grade, data = gtsummary::trial, family = binomial)
  tbl <- gtsummary::tbl_regression(m1)

  extra_args <- list(pval = TRUE, overall = TRUE)

  # Expect both regression-specific and not-stratified warnings
  expect_warning(
    extras(tbl, .args = extra_args),
    class = "extras_regression_unsupported_features"
  )

  suppressWarnings(
    expect_warning(
      extras(tbl, .args = extra_args),
      class = "extras_not_stratified"
    )
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

# Tests that basic formatting is still applied even when warnings occur
test_that("extras() applies basic formatting to tbl_regression despite warning", {
  skip_if_not_installed("gtsummary")

  m1 <- glm(response ~ age + grade, data = gtsummary::trial, family = binomial)
  tbl <- gtsummary::tbl_regression(m1)

  result <- suppressWarnings(extras(tbl, overall = TRUE, pval = TRUE))

  # Should still have modified the header (label column should be empty string)
  expect_s3_class(result, "gtsummary")
  # The table_styling$header should have label with label = ""
  label_header <- result$table_styling$header |>
    dplyr::filter(column == "label")
  expect_equal(label_header$label, "")
})

test_that("extras() applies basic formatting to non-stratified table despite warning", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age)

  result <- suppressWarnings(extras(tbl, overall = TRUE, pval = TRUE))

  # Should still have modified the header
  expect_s3_class(result, "gtsummary")
  label_header <- result$table_styling$header |>
    dplyr::filter(column == "label")
  expect_equal(label_header$label, "")
})

test_that("extras() with different regression models all warn appropriately", {
  skip_if_not_installed("gtsummary")

  # Test with lm
  m_lm <- lm(age ~ grade + marker, data = gtsummary::trial)
  tbl_lm <- gtsummary::tbl_regression(m_lm)

  # Expect both regression and not-stratified warnings
  expect_warning(
    extras(tbl_lm, overall = TRUE),
    class = "extras_regression_unsupported_features"
  )

  suppressWarnings(
    expect_warning(
      extras(tbl_lm, overall = TRUE),
      class = "extras_not_stratified"
    )
  )

  # Verify it succeeds
  result_lm <- suppressWarnings(extras(tbl_lm, overall = TRUE))
  expect_s3_class(result_lm, "gtsummary")
})
