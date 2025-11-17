# Tests for label functions (add_auto_labels and apply_labels_from_dictionary)

# Helper function to get unlabeled trial data
get_unlabeled_trial <- function() {
  data <- gtsummary::trial
  # Clear any existing label attributes
  for (col in names(data)) {
    attr(data[[col]], "label") <- NULL
  }
  data
}

test_that("add_auto_labels() works with tbl_summary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment",
    "trt", "Treatment Group",
    "grade", "Tumor Grade"
  )

  tbl <- get_unlabeled_trial() |>
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

# NEW TESTS FOR ENHANCED add_auto_labels() FUNCTIONALITY

test_that("add_auto_labels() searches environment for dictionary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Create dictionary in environment
  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Environment"
  )

  # Should find dictionary automatically
  # Reset the message flag for this test
  options(sumExtras.dictionary_message_shown = NULL)

  expect_message(
    tbl <- get_unlabeled_trial() |>
      gtsummary::tbl_summary(include = age) |>
      add_auto_labels(),
    "Auto-labeling from 'dictionary' object in your environment"
  )

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, "Age from Environment")
})

test_that("add_auto_labels() reads label attributes from data", {
  skip_if_not_installed("gtsummary")

  # Create labeled data
  labeled_data <- gtsummary::trial
  attr(labeled_data$age, "label") <- "Age from Attribute"
  attr(labeled_data$marker, "label") <- "Marker from Attribute"

  tbl <- labeled_data |>
    gtsummary::tbl_summary(include = c(age, marker)) |>
    add_auto_labels()  # No dictionary provided

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]

  expect_equal(age_label, "Age from Attribute")
  expect_equal(marker_label, "Marker from Attribute")
})

test_that("add_auto_labels() respects options(sumExtras.preferDictionary = TRUE)", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Set option
  old_opt <- getOption("sumExtras.preferDictionary")
  on.exit(options(sumExtras.preferDictionary = old_opt), add = TRUE)
  options(sumExtras.preferDictionary = TRUE)

  # Create data with attribute
  labeled_data <- gtsummary::trial
  attr(labeled_data$age, "label") <- "Age from Attribute"

  # Create dictionary
  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Dictionary"
  )

  tbl <- labeled_data |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels(dictionary = my_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  # Dictionary should win
  expect_equal(age_label, "Age from Dictionary")
})

test_that("add_auto_labels() respects options(sumExtras.preferDictionary = FALSE)", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Set option
  old_opt <- getOption("sumExtras.preferDictionary")
  on.exit(options(sumExtras.preferDictionary = old_opt), add = TRUE)
  options(sumExtras.preferDictionary = FALSE)

  # Create data with attribute
  labeled_data <- gtsummary::trial
  attr(labeled_data$age, "label") <- "Age from Attribute"

  # Create dictionary
  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Dictionary"
  )

  tbl <- labeled_data |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels(dictionary = my_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  # Attribute should win
  expect_equal(age_label, "Age from Attribute")
})

test_that("add_auto_labels() with dictionary = NULL skips environment search", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Create dictionary in environment
  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Environment"
  )

  # Create data with attribute
  labeled_data <- gtsummary::trial
  attr(labeled_data$age, "label") <- "Age from Attribute"

  # Explicitly set dictionary = NULL should skip environment search
  tbl <- labeled_data |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels(dictionary = NULL)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  # Should use attribute, not environment dictionary
  expect_equal(age_label, "Age from Attribute")
})

test_that("add_auto_labels() works with tbl_svysummary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")
  skip_if_not_installed("survey")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age"
  )

  # Create survey design
  svy_trial <- survey::svydesign(
    ids = ~1,
    data = gtsummary::trial,
    weights = ~1
  )

  tbl <- svy_trial |>
    gtsummary::tbl_svysummary(include = age) |>
    add_auto_labels(dictionary = my_dict)

  expect_s3_class(tbl, "gtsummary")
  expect_true("tbl_svysummary" %in% class(tbl))
})

test_that("add_auto_labels() preserves manual labels from tbl_svysummary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")
  skip_if_not_installed("survey")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Dictionary"
  )

  # Create survey design
  svy_trial <- survey::svydesign(
    ids = ~1,
    data = gtsummary::trial,
    weights = ~1
  )

  tbl <- svy_trial |>
    gtsummary::tbl_svysummary(
      include = age,
      label = list(age ~ "Manual Override")
    ) |>
    add_auto_labels(dictionary = my_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, "Manual Override")
})

test_that("add_auto_labels() handles no dictionary and no attributes gracefully", {
  skip_if_not_installed("gtsummary")

  # No dictionary, no attributes - should just work without errors
  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels()

  expect_s3_class(tbl, "gtsummary")
  # Label should be default (variable name)
  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_true(!is.na(age_label))
})

# TESTS FOR apply_labels_from_dictionary()

test_that("apply_labels_from_dictionary() sets label attributes", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment",
    "marker", "Marker Level"
  )

  labeled_data <- gtsummary::trial |>
    apply_labels_from_dictionary(my_dict)

  expect_equal(attr(labeled_data$age, "label"), "Age at Enrollment")
  expect_equal(attr(labeled_data$marker, "label"), "Marker Level")
})

test_that("apply_labels_from_dictionary() overwrites existing labels by default", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Set existing label
  data_with_label <- gtsummary::trial
  attr(data_with_label$age, "label") <- "Existing Label"

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "New Label"
  )

  labeled_data <- data_with_label |>
    apply_labels_from_dictionary(my_dict)

  expect_equal(attr(labeled_data$age, "label"), "New Label")
})

test_that("apply_labels_from_dictionary() preserves existing labels when overwrite = FALSE", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Set existing label on unlabeled data
  data_with_label <- get_unlabeled_trial()
  attr(data_with_label$age, "label") <- "Existing Label"

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "New Label",
    "marker", "Marker Label"
  )

  labeled_data <- data_with_label |>
    apply_labels_from_dictionary(my_dict, overwrite = FALSE)

  # age should keep existing label
  expect_equal(attr(labeled_data$age, "label"), "Existing Label")
  # marker should get new label (had none before)
  expect_equal(attr(labeled_data$marker, "label"), "Marker Label")
})

test_that("apply_labels_from_dictionary() ignores dictionary entries for missing variables", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age",
    "nonexistent_var", "This doesn't exist"
  )

  # Should not error
  labeled_data <- gtsummary::trial |>
    apply_labels_from_dictionary(my_dict)

  expect_equal(attr(labeled_data$age, "label"), "Age")
  expect_false("nonexistent_var" %in% names(labeled_data))
})

test_that("apply_labels_from_dictionary() errors with non-data.frame input", {
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age"
  )

  expect_error(
    apply_labels_from_dictionary("not a data frame", my_dict),
    "must be a data frame"
  )
})

test_that("apply_labels_from_dictionary() errors with missing dictionary", {
  skip_if_not_installed("gtsummary")

  expect_error(
    apply_labels_from_dictionary(gtsummary::trial),
    "dictionary.*required"
  )
})

test_that("apply_labels_from_dictionary() errors with invalid dictionary columns", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  bad_dict <- tibble::tribble(
    ~VarName, ~Label,
    "age", "Age"
  )

  expect_error(
    apply_labels_from_dictionary(gtsummary::trial, bad_dict),
    "missing required columns"
  )
})

# EDGE CASE TESTS

test_that("add_auto_labels() handles empty strings in attributes", {
  skip_if_not_installed("gtsummary")

  labeled_data <- gtsummary::trial
  attr(labeled_data$age, "label") <- ""  # Empty string

  tbl <- labeled_data |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels()

  # Empty string should be treated as a label (not NA)
  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, "")
})

test_that("add_auto_labels() handles duplicate dictionary entries", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Dictionary with duplicates
  dup_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "First Age Label",
    "age", "Second Age Label"
  )

  # Should use last one after filtering (standard R behavior)
  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels(dictionary = dup_dict)

  expect_s3_class(tbl, "gtsummary")
  # Behavior with duplicates is defined by left_join (uses first match)
})

test_that("apply_labels_from_dictionary() handles invalid overwrite parameter", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age"
  )

  expect_error(
    apply_labels_from_dictionary(gtsummary::trial, my_dict, overwrite = "yes"),
    "must be a single logical value"
  )

  expect_error(
    apply_labels_from_dictionary(gtsummary::trial, my_dict, overwrite = c(TRUE, FALSE)),
    "must be a single logical value"
  )
})

test_that("add_auto_labels() with both dictionary and attributes uses correct priority", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Default behavior (prefer attributes)
  labeled_data <- get_unlabeled_trial()
  attr(labeled_data$age, "label") <- "Attribute Label"
  attr(labeled_data$marker, "label") <- "Marker Attribute"

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Dictionary Label",
    "grade", "Grade Dictionary"
  )

  tbl <- labeled_data |>
    gtsummary::tbl_summary(include = c(age, marker, grade)) |>
    add_auto_labels(dictionary = my_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]
  grade_label <- tbl$table_body$label[tbl$table_body$variable == "grade"][1]

  # age has both - attribute wins (default preferDictionary = FALSE)
  expect_equal(age_label, "Attribute Label")
  # marker has only attribute
  expect_equal(marker_label, "Marker Attribute")
  # grade has only dictionary
  expect_equal(grade_label, "Grade Dictionary")
})

test_that("add_auto_labels() handles unicode and emoji in labels", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Dictionary with unicode and emoji
  unicode_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age 🎂",
    "marker", "Marker Level μg/mL",
    "grade", "Tumor Grade ★★★"
  )

  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(include = c(age, marker, grade)) |>
    add_auto_labels(dictionary = unicode_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]
  grade_label <- tbl$table_body$label[tbl$table_body$variable == "grade"][1]

  # Should handle unicode/emoji without errors
  expect_equal(age_label, "Age 🎂")
  expect_equal(marker_label, "Marker Level μg/mL")
  expect_equal(grade_label, "Tumor Grade ★★★")
})
