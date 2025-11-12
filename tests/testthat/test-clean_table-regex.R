# Tests for Issue 8: Regex pattern in clean_table()
# Tests both current and proposed regex patterns

# context("clean_table() - Regex pattern behavior")

test_that("clean_table() current regex matches intended patterns", {
  skip_if_not_installed("stringr")

  # Current pattern from R/clean_table.R:69
  current_pattern <- "\\bNA\\b|\\bInf\\b|^[0\\s%().,]+$"

  # Should match these (true positives)
  expect_true(stringr::str_detect("NA", current_pattern))
  expect_true(stringr::str_detect("Inf", current_pattern))
  expect_true(stringr::str_detect("NA (NA)", current_pattern))
  expect_true(stringr::str_detect("0 (0%)", current_pattern))

  # Should NOT match real data (but might fail with current pattern)
  expect_false(stringr::str_detect("15 (30%)", current_pattern))
  expect_false(stringr::str_detect("0.5 (25%)", current_pattern))
  expect_false(stringr::str_detect("45 (40, 50)", current_pattern))
})

test_that("clean_table() current regex has known false positives", {
  skip_if_not_installed("stringr")

  current_pattern <- "\\bNA\\b|\\bInf\\b|^[0\\s%().,]+$"

  # These are FALSE POSITIVES - pattern matches but shouldn't
  # Documents the problem with current regex
  expect_true(stringr::str_detect("...", current_pattern))  # Just dots
  expect_true(stringr::str_detect("   ", current_pattern))  # Just spaces
  expect_true(stringr::str_detect("()", current_pattern))   # Just parens
})

test_that("clean_table() proposed regex fixes false positives", {
  skip_if_not_installed("stringr")

  # Proposed pattern (Option B)
  proposed_pattern <- paste(c(
    "\\bNA\\b",
    "\\bInf\\b",
    "-Inf",
    "^0 \\(0%\\)$",
    "^0 \\(NA%\\)$",
    "^NA \\(NA\\)$",
    "^NA \\(NA, NA\\)$",
    "^0\\.0+ \\(0\\.0+%?\\)$",
    "^NA, NA$"
  ), collapse = "|")

  # Should match intended patterns
  expect_true(stringr::str_detect("NA", proposed_pattern))
  expect_true(stringr::str_detect("Inf", proposed_pattern))
  expect_true(stringr::str_detect("-Inf", proposed_pattern))
  expect_true(stringr::str_detect("0 (0%)", proposed_pattern))
  expect_true(stringr::str_detect("0 (NA%)", proposed_pattern))
  expect_true(stringr::str_detect("NA (NA)", proposed_pattern))
  expect_true(stringr::str_detect("NA (NA, NA)", proposed_pattern))
  expect_true(stringr::str_detect("0.00 (0.00)", proposed_pattern))
  expect_true(stringr::str_detect("0.00 (0.00%)", proposed_pattern))
  expect_true(stringr::str_detect("NA, NA", proposed_pattern))

  # Should NOT match false positives
  expect_false(stringr::str_detect("...", proposed_pattern))
  expect_false(stringr::str_detect("   ", proposed_pattern))
  expect_false(stringr::str_detect("()", proposed_pattern))

  # Should NOT match real data
  expect_false(stringr::str_detect("15 (30%)", proposed_pattern))
  expect_false(stringr::str_detect("0.5 (25%)", proposed_pattern))
  expect_false(stringr::str_detect("45 (40, 50)", proposed_pattern))
  expect_false(stringr::str_detect("2.5, 3.8", proposed_pattern))
  expect_false(stringr::str_detect("1.23 (0.45, 2.01)", proposed_pattern))
  expect_false(stringr::str_detect("0.001", proposed_pattern))
})

test_that("clean_table() proposed regex avoids partial matches", {
  skip_if_not_installed("stringr")

  proposed_pattern <- paste(c(
    "\\bNA\\b",
    "\\bInf\\b",
    "-Inf",
    "^0 \\(0%\\)$",
    "^0 \\(NA%\\)$",
    "^NA \\(NA\\)$",
    "^NA \\(NA, NA\\)$",
    "^0\\.0+ \\(0\\.0+%?\\)$",
    "^NA, NA$"
  ), collapse = "|")

  # Should not match NA/Inf within larger words
  expect_false(stringr::str_detect("BANANA", proposed_pattern))
  expect_false(stringr::str_detect("Information", proposed_pattern))
})

test_that("clean_table() works with actual gtsummary table", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("dplyr")

  # Create table with missing data
  test_data <- gtsummary::trial |>
    dplyr::mutate(
      marker = dplyr::if_else(trt == "Drug A", NA_real_, marker)
    )

  tbl <- test_data |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade))

  # Should execute without error
  expect_s3_class(
    clean_table(tbl),
    "gtsummary"
  )
})

test_that("clean_table() handles zero counts correctly", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("dplyr")

  # Create data where a category has zero counts
  zero_data <- gtsummary::trial |>
    dplyr::filter(!(trt == "Drug A" & grade == "I"))

  tbl <- zero_data |>
    gtsummary::tbl_summary(by = trt, include = grade)

  expect_s3_class(
    clean_table(tbl),
    "gtsummary"
  )
})

test_that("clean_table() handles Inf values", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("dplyr")

  # Create data with Inf
  inf_data <- gtsummary::trial |>
    dplyr::mutate(marker = dplyr::if_else(dplyr::row_number() == 1, Inf, marker))

  tbl <- inf_data |>
    gtsummary::tbl_summary(by = trt, include = marker)

  expect_s3_class(
    clean_table(tbl),
    "gtsummary"
  )
})

test_that("clean_table() preserves actual data values", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = age) |>
    clean_table()

  # Check that age statistics are still present
  age_row <- tbl$table_body[tbl$table_body$variable == "age", ]
  expect_true(nrow(age_row) > 0)

  # Stat columns should have values (not all NA)
  stat_cols <- names(age_row)[grepl("^stat_", names(age_row))]
  has_values <- sapply(stat_cols, function(col) !all(is.na(age_row[[col]])))
  expect_true(any(has_values))
})
