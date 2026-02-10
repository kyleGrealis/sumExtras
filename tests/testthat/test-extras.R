# Tests for extras() function

test_that("extras() works with basic tbl_summary", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras()

  expect_s3_class(tbl, "gtsummary")
  expect_true("tbl_summary" %in% class(tbl))
})

test_that("extras() bolds significant p-values by default", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras()

  # Check that bold formatting was applied to p.value column
  text_fmt <- tbl$table_styling$text_format
  pval_bold <- text_fmt[
    text_fmt$column == "p.value" & text_fmt$format_type == "bold",
  ]
  expect_true(nrow(pval_bold) > 0)
})

test_that("extras() does not bold p-values when pval = FALSE", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(pval = FALSE)

  # p.value column should not exist
  expect_false("p.value" %in% names(tbl$table_body))

  # No bold formatting on p.value
  text_fmt <- tbl$table_styling$text_format
  pval_bold <- text_fmt[
    text_fmt$column == "p.value" & text_fmt$format_type == "bold",
  ]
  expect_equal(nrow(pval_bold), 0)
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

test_that("extras() default header is blank", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras()

  label_header <- tbl$table_styling$header |>
    dplyr::filter(column == "label")
  expect_equal(label_header$label, "")
})

test_that("extras() respects custom header text", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(header = "Variable")

  label_header <- tbl$table_styling$header |>
    dplyr::filter(column == "label")
  expect_equal(label_header$label, "Variable")
})

test_that("extras() header works through .args", {
  skip_if_not_installed("gtsummary")

  args <- list(header = "Characteristic", pval = FALSE)

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt) |>
    extras(.args = args)

  label_header <- tbl$table_styling$header |>
    dplyr::filter(column == "label")
  expect_equal(label_header$label, "Characteristic")
})

test_that("extras() works with non-stratified tables", {
  skip_if_not_installed("gtsummary")

  # Should work without warning when using defaults
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

test_that("extras() works with tbl_svysummary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("survey")

  svy_design <- survey::svydesign(
    ids = ~1,
    data = gtsummary::trial,
    weights = ~1
  )

  tbl <- gtsummary::tbl_svysummary(
    svy_design,
    by = trt,
    include = c(age, grade)
  ) |>
    extras()

  expect_s3_class(tbl, "gtsummary")
  # Should have overall column and p-values
  expect_true("stat_0" %in% names(tbl$table_body))
  expect_true("p.value" %in% names(tbl$table_body))
})


# =============================================================================
# Auto-labeling options tests
# =============================================================================

# Helper to get label for a variable from a gtsummary table
get_label <- function(tbl, var_name) {
  rows <- tbl$table_body[
    tbl$table_body$variable == var_name & tbl$table_body$row_type == "label",
  ]
  unname(rows$label[1])
}

test_that("extras() does not auto-label when options are unset (default)", {
  skip_if_not_installed("gtsummary")

  old_auto <- getOption("sumExtras.auto_labels")
  on.exit(options(sumExtras.auto_labels = old_auto), add = TRUE)
  options(sumExtras.auto_labels = NULL)

  trial_data <- get_unlabeled_trial()

  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment"
  )

  tbl <- trial_data |>
    gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
    extras()

  # Without options, labels should be the default variable names
  expect_equal(get_label(tbl, "age"), "age")
})

test_that("extras() auto-labels with auto_labels and dict in env", {
  skip_if_not_installed("gtsummary")

  old_auto <- getOption("sumExtras.auto_labels")
  on.exit(options(sumExtras.auto_labels = old_auto), add = TRUE)
  options(sumExtras.auto_labels = TRUE)

  trial_data <- get_unlabeled_trial()

  # Dictionary must be in the calling environment for auto-discovery
  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment",
    "grade", "Tumor Grade"
  )

  tbl <- trial_data |>
    gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
    extras()

  expect_s3_class(tbl, "gtsummary")
  expect_equal(get_label(tbl, "age"), "Age at Enrollment")
  expect_equal(get_label(tbl, "grade"), "Tumor Grade")
})

test_that("extras() auto-labels with auto_labels using attributes", {
  skip_if_not_installed("gtsummary")

  old_auto <- getOption("sumExtras.auto_labels")
  on.exit(options(sumExtras.auto_labels = old_auto), add = TRUE)
  options(sumExtras.auto_labels = TRUE)

  trial_data <- get_unlabeled_trial()
  attr(trial_data$age, "label") <- "Patient Age (years)"
  attr(trial_data$grade, "label") <- "Tumor Grade"

  tbl <- trial_data |>
    gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
    extras()

  expect_s3_class(tbl, "gtsummary")
  expect_equal(get_label(tbl, "age"), "Patient Age (years)")
  expect_equal(get_label(tbl, "grade"), "Tumor Grade")
})


test_that("extras() auto-labels work with non-stratified tables", {
  skip_if_not_installed("gtsummary")

  old_auto <- getOption("sumExtras.auto_labels")
  on.exit(options(sumExtras.auto_labels = old_auto), add = TRUE)
  options(sumExtras.auto_labels = TRUE)

  trial_data <- get_unlabeled_trial()
  attr(trial_data$age, "label") <- "Patient Age"

  tbl <- trial_data |>
    gtsummary::tbl_summary(include = c(age, grade)) |>
    extras()

  expect_s3_class(tbl, "gtsummary")
  expect_equal(get_label(tbl, "age"), "Patient Age")
})

test_that("extras() auto-labels work with regression tables", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("broom")

  old_auto <- getOption("sumExtras.auto_labels")
  on.exit(options(sumExtras.auto_labels = old_auto), add = TRUE)
  options(sumExtras.auto_labels = TRUE)

  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "grade", "Tumor Grade",
    "marker", "Serum Marker"
  )

  mod <- lm(age ~ grade + marker, data = gtsummary::trial)
  tbl <- gtsummary::tbl_regression(mod) |>
    extras()

  expect_s3_class(tbl, "gtsummary")
  expect_equal(get_label(tbl, "grade"), "Tumor Grade")
  expect_equal(get_label(tbl, "marker"), "Serum Marker")
})

test_that("explicit add_auto_labels() still works independently of options", {
  skip_if_not_installed("gtsummary")

  old_auto <- getOption("sumExtras.auto_labels")
  on.exit(options(sumExtras.auto_labels = old_auto), add = TRUE)
  options(sumExtras.auto_labels = NULL)

  trial_data <- get_unlabeled_trial()

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Custom Age Label"
  )

  tbl <- trial_data |>
    gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
    add_auto_labels(dictionary = my_dict) |>
    extras()

  expect_equal(get_label(tbl, "age"), "Custom Age Label")
})
