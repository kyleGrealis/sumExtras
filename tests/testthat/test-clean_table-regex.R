# Tests for Issue 8: Regex pattern in clean_table()
# Tests both current and proposed regex patterns

# context("clean_table() - Regex pattern behavior")

test_that("clean_table() current regex matches intended patterns", {
  # Current pattern from R/clean_table.R:69
  current_pattern <- "\\bNA\\b|\\bInf\\b|^[0\\s%().,]+$"

  # Should match these (true positives)
  expect_true(grepl(current_pattern, "NA", perl = TRUE))
  expect_true(grepl(current_pattern, "Inf", perl = TRUE))
  expect_true(grepl(current_pattern, "NA (NA)", perl = TRUE))
  expect_true(grepl(current_pattern, "0 (0%)", perl = TRUE))

  # Should NOT match real data (but might fail with current pattern)
  expect_false(grepl(current_pattern, "15 (30%)", perl = TRUE))
  expect_false(grepl(current_pattern, "0.5 (25%)", perl = TRUE))
  expect_false(grepl(current_pattern, "45 (40, 50)", perl = TRUE))
})

test_that("clean_table() current regex has known false positives", {
  current_pattern <- "\\bNA\\b|\\bInf\\b|^[0\\s%().,]+$"

  # These are FALSE POSITIVES - pattern matches but shouldn't
  # Documents the problem with current regex
  expect_true(grepl(current_pattern, "...", perl = TRUE))  # Just dots
  expect_true(grepl(current_pattern, "   ", perl = TRUE))  # Just spaces
  expect_true(grepl(current_pattern, "()", perl = TRUE))   # Just parens
})

test_that("clean_table() proposed regex fixes false positives", {
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
  expect_true(grepl(proposed_pattern, "NA", perl = TRUE))
  expect_true(grepl(proposed_pattern, "Inf", perl = TRUE))
  expect_true(grepl(proposed_pattern, "-Inf", perl = TRUE))
  expect_true(grepl(proposed_pattern, "0 (0%)", perl = TRUE))
  expect_true(grepl(proposed_pattern, "0 (NA%)", perl = TRUE))
  expect_true(grepl(proposed_pattern, "NA (NA)", perl = TRUE))
  expect_true(grepl(proposed_pattern, "NA (NA, NA)", perl = TRUE))
  expect_true(grepl(proposed_pattern, "0.00 (0.00)", perl = TRUE))
  expect_true(grepl(proposed_pattern, "0.00 (0.00%)", perl = TRUE))
  expect_true(grepl(proposed_pattern, "NA, NA", perl = TRUE))

  # Should NOT match false positives
  expect_false(grepl(proposed_pattern, "...", perl = TRUE))
  expect_false(grepl(proposed_pattern, "   ", perl = TRUE))
  expect_false(grepl(proposed_pattern, "()", perl = TRUE))

  # Should NOT match real data
  expect_false(grepl(proposed_pattern, "15 (30%)", perl = TRUE))
  expect_false(grepl(proposed_pattern, "0.5 (25%)", perl = TRUE))
  expect_false(grepl(proposed_pattern, "45 (40, 50)", perl = TRUE))
  expect_false(grepl(proposed_pattern, "2.5, 3.8", perl = TRUE))
  expect_false(grepl(proposed_pattern, "1.23 (0.45, 2.01)", perl = TRUE))
  expect_false(grepl(proposed_pattern, "0.001", perl = TRUE))
})

test_that("clean_table() proposed regex avoids partial matches", {
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
  expect_false(grepl(proposed_pattern, "BANANA", perl = TRUE))
  expect_false(grepl(proposed_pattern, "Information", perl = TRUE))
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
