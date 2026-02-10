# Tests for clean_table() regex pattern matching
# Tests the actual regex pattern used in clean_table()

# Build the same pattern used in clean_table() for unit testing
get_na_pattern <- function() {
  paste(c(
    "\\bNA\\b",
    "\\bInf\\b",
    "-Inf",
    "^0 \\(0\\)$",
    "^0 \\(0%\\)$",
    "^0% \\(0\\.0+\\)$",
    "^0 \\(NA%\\)$",
    "^0 \\(NA\\)$",
    "^NA \\(0\\)$",
    "^NA \\(NA\\)$",
    "^NA \\(NA, NA\\)$",
    "^0\\.0+ \\(0\\.0+%?\\)$",
    "^0\\.0+% \\(0\\.0+\\)$",
    "^NA, NA$",
    "^0% \\(0\\.0+\\) \\(0%?, 0%?\\)$",
    "^0\\.0+% \\(0\\.0+\\) \\(0\\.0+%?, 0\\.0+%?\\)$",
    "^0 \\(0\\.0+\\) \\(0, 0\\)$",
    "^0\\.0+ \\(0\\.0+\\) \\(0\\.0+, 0\\.0+\\)$",
    "\\(0%?, 0%?\\)$",
    "\\(0\\.0+%?, 0\\.0+%?\\)$"
  ), collapse = "|")
}

test_that("clean_table() regex matches intended patterns", {
  na_pattern <- get_na_pattern()

  # Should match these (true positives)
  expect_true(grepl(na_pattern, "NA", perl = TRUE))
  expect_true(grepl(na_pattern, "Inf", perl = TRUE))
  expect_true(grepl(na_pattern, "-Inf", perl = TRUE))
  expect_true(grepl(na_pattern, "0 (0)", perl = TRUE))
  expect_true(grepl(na_pattern, "0 (0%)", perl = TRUE))
  expect_true(grepl(na_pattern, "0 (NA%)", perl = TRUE))
  expect_true(grepl(na_pattern, "0 (NA)", perl = TRUE))
  expect_true(grepl(na_pattern, "NA (0)", perl = TRUE))
  expect_true(grepl(na_pattern, "NA (NA)", perl = TRUE))
  expect_true(grepl(na_pattern, "NA (NA, NA)", perl = TRUE))
  expect_true(grepl(na_pattern, "0.00 (0.00)", perl = TRUE))
  expect_true(grepl(na_pattern, "0.00 (0.00%)", perl = TRUE))
  expect_true(grepl(na_pattern, "0.00% (0.00)", perl = TRUE))
  expect_true(grepl(na_pattern, "0% (0.000)", perl = TRUE))
  expect_true(grepl(na_pattern, "NA, NA", perl = TRUE))
})

test_that("clean_table() regex does not match real data values", {
  na_pattern <- get_na_pattern()

  # Should NOT match actual data
  expect_false(grepl(na_pattern, "15 (30%)", perl = TRUE))
  expect_false(grepl(na_pattern, "0.5 (25%)", perl = TRUE))
  expect_false(grepl(na_pattern, "45 (40, 50)", perl = TRUE))
  expect_false(grepl(na_pattern, "2.5, 3.8", perl = TRUE))
  expect_false(grepl(na_pattern, "1.23 (0.45, 2.01)", perl = TRUE))
  expect_false(grepl(na_pattern, "0.001", perl = TRUE))

  # Should NOT match false positives
  expect_false(grepl(na_pattern, "...", perl = TRUE))
  expect_false(grepl(na_pattern, "()", perl = TRUE))
})

test_that("clean_table() regex avoids partial word matches", {
  na_pattern <- get_na_pattern()

  # Should not match NA/Inf within larger words
  expect_false(grepl(na_pattern, "BANANA", perl = TRUE))
  expect_false(grepl(na_pattern, "Information", perl = TRUE))
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
    dplyr::mutate(
      marker = dplyr::if_else(dplyr::row_number() == 1, Inf, marker)
    )

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
