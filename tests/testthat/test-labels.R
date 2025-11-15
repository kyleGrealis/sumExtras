# Tests for label functions (create_labels and add_auto_labels)

test_that("create_labels() creates proper label list", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Create a dictionary
  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment",
    "marker", "Marker Level",
    "trt", "Treatment"
  )

  # Pass dictionary explicitly (recommended approach)
  labels <- create_labels(gtsummary::trial, dictionary = my_dict)

  expect_type(labels, "list")
  expect_true(length(labels) > 0)
  expect_true(all(sapply(labels, inherits, "formula")))
})

test_that("create_labels() handles missing variables gracefully", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Dictionary with variables not in dataset
  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "nonexistent", "This doesn't exist",
    "age", "Age"
  )

  labels <- create_labels(gtsummary::trial, dictionary = my_dict)

  expect_type(labels, "list")
  # Should only have labels for variables that exist
  vars <- sapply(labels, function(x) all.vars(x)[1])
  expect_false("nonexistent" %in% vars)
})

test_that("add_auto_labels() works with tbl_summary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment",
    "trt", "Treatment Group",
    "grade", "Tumor Grade"
  )

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
    add_auto_labels(dictionary = my_dict)

  expect_s3_class(tbl, "gtsummary")
  expect_true("tbl_summary" %in% class(tbl))

  # Verify labels were actually applied
  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, "Age at Enrollment")
})

test_that("add_auto_labels() works with tbl_regression", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")
  skip_if_not_installed("broom")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age",
    "grade", "Grade",
    "marker", "Marker"
  )

  mod <- lm(age ~ grade + marker, data = gtsummary::trial)
  tbl <- gtsummary::tbl_regression(mod) |>
    add_auto_labels(dictionary = my_dict)

  expect_s3_class(tbl, "gtsummary")
  expect_true("tbl_regression" %in% class(tbl))
})

test_that("add_auto_labels() preserves manual label overrides", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Dictionary"
  )

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(
      include = age,
      label = list(age ~ "Manual Override")
    ) |>
    add_auto_labels(dictionary = my_dict)

  expect_s3_class(tbl, "gtsummary")
  # Manual label should be preserved (this test may need updating based on new behavior)
  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, "Manual Override")
})

test_that("add_auto_labels() handles tables without dictionary variables", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Dictionary with no matching variables
  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "nonexistent", "Doesn't exist"
  )

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels(dictionary = my_dict)

  expect_s3_class(tbl, "gtsummary")
})
