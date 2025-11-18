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

# ==============================================================================
# COMPREHENSIVE TESTS FOR DICTIONARY AUTO-DISCOVERY
# ==============================================================================

test_that("add_auto_labels() shows message only once per session for auto-discovery", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Reset message flag
  options(sumExtras.dictionary_message_shown = NULL)

  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age Label"
  )

  # First call should show message
  expect_message(
    get_unlabeled_trial() |>
      gtsummary::tbl_summary(include = age) |>
      add_auto_labels(),
    "Auto-labeling from 'dictionary'"
  )

  # Second call should NOT show message
  expect_no_message(
    get_unlabeled_trial() |>
      gtsummary::tbl_summary(include = age) |>
      add_auto_labels()
  )

  # Clean up
  options(sumExtras.dictionary_message_shown = NULL)
})

test_that("add_auto_labels() auto-discovery works when dictionary has extra variables", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Dictionary with many variables, only some in table
  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Baseline",
    "marker", "Marker Level",
    "grade", "Tumor Grade",
    "stage", "Clinical Stage",
    "response", "Treatment Response",
    "death", "Patient Died"
  )

  options(sumExtras.dictionary_message_shown = NULL)

  # Only include age - should still work
  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels()

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, "Age at Baseline")

  options(sumExtras.dictionary_message_shown = NULL)
})

test_that("add_auto_labels() handles dictionary with no matching variables gracefully", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Dictionary with completely different variables
  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "foo", "Foo Variable",
    "bar", "Bar Variable"
  )

  options(sumExtras.dictionary_message_shown = NULL)

  # Should work without error
  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels()

  expect_s3_class(tbl, "gtsummary")
  # Label should remain as default (not from dictionary)

  options(sumExtras.dictionary_message_shown = NULL)
})

# ==============================================================================
# COMPREHENSIVE TESTS FOR LABEL PRIORITY LOGIC
# ==============================================================================

test_that("add_auto_labels() priority: manual > attribute > dictionary (default)", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Reset to default
  options(sumExtras.preferDictionary = FALSE)

  # Create data with attributes for age and marker
  labeled_data <- get_unlabeled_trial()
  attr(labeled_data$age, "label") <- "Age from Attribute"
  attr(labeled_data$marker, "label") <- "Marker from Attribute"

  # Dictionary has labels for age, grade, and response
  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Dictionary",
    "grade", "Grade from Dictionary",
    "response", "Response from Dictionary"
  )

  # Manual override for age
  tbl <- labeled_data |>
    gtsummary::tbl_summary(
      include = c(age, marker, grade, response),
      label = list(age ~ "Age Manual Override")
    ) |>
    add_auto_labels(dictionary = my_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]
  grade_label <- tbl$table_body$label[tbl$table_body$variable == "grade"][1]
  response_label <- tbl$table_body$label[tbl$table_body$variable == "response"][1]

  # age: manual override wins
  expect_equal(age_label, "Age Manual Override")
  # marker: only attribute available
  expect_equal(marker_label, "Marker from Attribute")
  # grade: only dictionary available
  expect_equal(grade_label, "Grade from Dictionary")
  # response: only dictionary available
  expect_equal(response_label, "Response from Dictionary")
})

test_that("add_auto_labels() priority: manual > dictionary > attribute (preferDictionary = TRUE)", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Set preference
  old_opt <- getOption("sumExtras.preferDictionary")
  on.exit(options(sumExtras.preferDictionary = old_opt), add = TRUE)
  options(sumExtras.preferDictionary = TRUE)

  # Create data with attributes
  labeled_data <- get_unlabeled_trial()
  attr(labeled_data$age, "label") <- "Age from Attribute"
  attr(labeled_data$marker, "label") <- "Marker from Attribute"

  # Dictionary
  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Dictionary",
    "grade", "Grade from Dictionary"
  )

  # Manual override for age
  tbl <- labeled_data |>
    gtsummary::tbl_summary(
      include = c(age, marker, grade),
      label = list(age ~ "Age Manual Override")
    ) |>
    add_auto_labels(dictionary = my_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]
  grade_label <- tbl$table_body$label[tbl$table_body$variable == "grade"][1]

  # age: manual override still wins
  expect_equal(age_label, "Age Manual Override")
  # marker: only attribute (no dictionary entry)
  expect_equal(marker_label, "Marker from Attribute")
  # grade: only dictionary
  expect_equal(grade_label, "Grade from Dictionary")
})

test_that("add_auto_labels() handles all variables with manual overrides", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Even with dictionary and attributes, manual overrides should win
  labeled_data <- get_unlabeled_trial()
  attr(labeled_data$age, "label") <- "Age Attribute"
  attr(labeled_data$marker, "label") <- "Marker Attribute"

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age Dictionary",
    "marker", "Marker Dictionary"
  )

  tbl <- labeled_data |>
    gtsummary::tbl_summary(
      include = c(age, marker),
      label = list(
        age ~ "Age Manual",
        marker ~ "Marker Manual"
      )
    ) |>
    add_auto_labels(dictionary = my_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]

  # Both should use manual labels
  expect_equal(age_label, "Age Manual")
  expect_equal(marker_label, "Marker Manual")
})

# ==============================================================================
# COMPREHENSIVE ERROR VALIDATION TESTS
# ==============================================================================

test_that("add_auto_labels() errors informatively with non-gtsummary input", {
  skip_if_not_installed("gtsummary")

  expect_error(
    add_auto_labels(data.frame(x = 1:5)),
    class = "add_auto_labels_invalid_input"
  )

  expect_error(
    add_auto_labels(data.frame(x = 1:5)),
    "must be a gtsummary object"
  )

  expect_error(
    add_auto_labels(data.frame(x = 1:5)),
    "Create a gtsummary table"
  )
})

test_that("add_auto_labels() errors informatively with invalid dictionary", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age)

  # Non-data.frame dictionary
  expect_error(
    add_auto_labels(tbl, dictionary = "not a data frame"),
    class = "add_auto_labels_invalid_dictionary"
  )

  expect_error(
    add_auto_labels(tbl, dictionary = list(x = 1)),
    "must be a data frame"
  )
})

test_that("add_auto_labels() errors informatively with missing dictionary columns", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = age)

  # Missing Variable column
  bad_dict1 <- tibble::tribble(
    ~VarName, ~Description,
    "age", "Age"
  )

  expect_error(
    add_auto_labels(tbl, dictionary = bad_dict1),
    class = "add_auto_labels_invalid_dictionary"
  )

  expect_error(
    add_auto_labels(tbl, dictionary = bad_dict1),
    "Missing column.*Variable"
  )

  # Missing Description column
  bad_dict2 <- tibble::tribble(
    ~Variable, ~Label,
    "age", "Age"
  )

  expect_error(
    add_auto_labels(tbl, dictionary = bad_dict2),
    "Missing column.*Description"
  )

  # Missing both columns
  bad_dict3 <- tibble::tribble(
    ~Var, ~Desc,
    "age", "Age"
  )

  expect_error(
    add_auto_labels(tbl, dictionary = bad_dict3),
    "Missing column.*Variable.*Description"
  )
})

test_that("apply_labels_from_dictionary() errors have correct class and messages", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age"
  )

  # Non-data.frame data
  expect_error(
    apply_labels_from_dictionary("not a df", my_dict),
    class = "apply_labels_invalid_data"
  )

  # Missing dictionary
  expect_error(
    apply_labels_from_dictionary(gtsummary::trial),
    class = "apply_labels_missing_dictionary"
  )

  # NULL dictionary
  expect_error(
    apply_labels_from_dictionary(gtsummary::trial, dictionary = NULL),
    class = "apply_labels_missing_dictionary"
  )

  # Non-data.frame dictionary
  expect_error(
    apply_labels_from_dictionary(gtsummary::trial, dictionary = "not a df"),
    class = "apply_labels_invalid_dictionary_type"
  )

  # Missing columns
  bad_dict <- tibble::tribble(
    ~Var, ~Desc,
    "age", "Age"
  )

  expect_error(
    apply_labels_from_dictionary(gtsummary::trial, bad_dict),
    class = "apply_labels_missing_columns"
  )

  # Invalid overwrite
  expect_error(
    apply_labels_from_dictionary(gtsummary::trial, my_dict, overwrite = "yes"),
    class = "apply_labels_invalid_overwrite"
  )
})

# ==============================================================================
# EDGE CASE TESTS
# ==============================================================================

test_that("add_auto_labels() handles NA values in dictionary gracefully", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Dictionary with NA in Description
  dict_with_na <- tibble::tribble(
    ~Variable, ~Description,
    "age", NA_character_,
    "marker", "Marker Level"
  )

  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(include = c(age, marker)) |>
    add_auto_labels(dictionary = dict_with_na)

  # Should not error
  expect_s3_class(tbl, "gtsummary")
})

test_that("add_auto_labels() handles data with all missing values", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Create data with all NA values (gtsummary can handle this)
  na_data <- tibble::tibble(
    age = rep(NA_real_, 10),
    marker = rep(NA_real_, 10),
    trt = rep(NA_character_, 10)
  )

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age",
    "marker", "Marker"
  )

  # Should handle data with all missing values
  tbl <- na_data |>
    gtsummary::tbl_summary(include = c(age, marker)) |>
    add_auto_labels(dictionary = my_dict)

  expect_s3_class(tbl, "gtsummary")
})

test_that("apply_labels_from_dictionary() handles data with zero rows", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  empty_data <- gtsummary::trial[0, ]

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age",
    "marker", "Marker"
  )

  labeled <- apply_labels_from_dictionary(empty_data, my_dict)

  expect_equal(nrow(labeled), 0)
  expect_equal(attr(labeled$age, "label"), "Age")
  expect_equal(attr(labeled$marker, "label"), "Marker")
})

test_that("apply_labels_from_dictionary() handles data with single row", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  single_row <- gtsummary::trial[1, ]

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Patient Age",
    "marker", "Biomarker"
  )

  labeled <- apply_labels_from_dictionary(single_row, my_dict)

  expect_equal(nrow(labeled), 1)
  expect_equal(attr(labeled$age, "label"), "Patient Age")
  expect_equal(attr(labeled$marker, "label"), "Biomarker")
})

test_that("add_auto_labels() handles very long label strings", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  long_label <- paste(rep("Very long description that goes on and on", 10), collapse = " ")

  long_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", long_label
  )

  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels(dictionary = long_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, long_label)
})

test_that("apply_labels_from_dictionary() preserves data structure and values", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  original_data <- get_unlabeled_trial()

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age",
    "marker", "Marker"
  )

  labeled_data <- apply_labels_from_dictionary(original_data, my_dict)

  # Data values should be unchanged (ignore label attributes for comparison)
  expect_equal(as.numeric(labeled_data$age), as.numeric(original_data$age))
  expect_equal(as.numeric(labeled_data$marker), as.numeric(original_data$marker))
  expect_equal(nrow(labeled_data), nrow(original_data))
  expect_equal(ncol(labeled_data), ncol(original_data))
  expect_equal(names(labeled_data), names(original_data))

  # Labels should be set
  expect_equal(attr(labeled_data$age, "label"), "Age")
  expect_equal(attr(labeled_data$marker, "label"), "Marker")
})

# ==============================================================================
# INTEGRATION TESTS - VIGNETTE SCENARIOS
# ==============================================================================

context("Integration Tests - Vignette Workflows")

test_that("Vignette scenario: dictionary passed explicitly to add_auto_labels()", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "trt", "Chemotherapy Treatment",
    "age", "Age at Enrollment (years)",
    "marker", "Marker Level (ng/mL)",
    "grade", "Tumor Grade"
  )

  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(by = trt, include = c(age, grade, marker)) |>
    add_auto_labels(dictionary = dictionary)

  expect_s3_class(tbl, "gtsummary")

  # Verify labels applied correctly
  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  grade_label <- tbl$table_body$label[tbl$table_body$variable == "grade"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]

  expect_equal(age_label, "Age at Enrollment (years)")
  expect_equal(grade_label, "Tumor Grade")
  expect_equal(marker_label, "Marker Level (ng/mL)")
})

test_that("Vignette scenario: automatic dictionary discovery", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Reset message flag
  options(sumExtras.dictionary_message_shown = NULL)

  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "trt", "Chemotherapy Treatment",
    "age", "Age at Enrollment (years)",
    "stage", "T Stage",
    "response", "Tumor Response"
  )

  # Should find dictionary automatically
  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(by = trt, include = c(age, stage, response)) |>
    add_auto_labels()

  expect_s3_class(tbl, "gtsummary")

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  stage_label <- tbl$table_body$label[tbl$table_body$variable == "stage"][1]
  response_label <- tbl$table_body$label[tbl$table_body$variable == "response"][1]

  expect_equal(age_label, "Age at Enrollment (years)")
  expect_equal(stage_label, "T Stage")
  expect_equal(response_label, "Tumor Response")

  options(sumExtras.dictionary_message_shown = NULL)
})

test_that("Vignette scenario: working with pre-labeled data", {
  skip_if_not_installed("gtsummary")

  labeled_trial <- gtsummary::trial
  attr(labeled_trial$age, "label") <- "Patient Age at Baseline"
  attr(labeled_trial$marker, "label") <- "Biomarker Concentration (ng/mL)"

  tbl <- labeled_trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
    add_auto_labels()

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]

  expect_equal(age_label, "Patient Age at Baseline")
  expect_equal(marker_label, "Biomarker Concentration (ng/mL)")
})

test_that("Vignette scenario: manual overrides always win", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment (years)",
    "grade", "Tumor Grade",
    "marker", "Marker Level (ng/mL)"
  )

  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(
      by = trt,
      include = c(age, grade, marker),
      label = list(age ~ "Age (Custom Label)")
    ) |>
    add_auto_labels(dictionary = dictionary)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  grade_label <- tbl$table_body$label[tbl$table_body$variable == "grade"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]

  # Manual override for age
  expect_equal(age_label, "Age (Custom Label)")
  # Dictionary labels for others
  expect_equal(grade_label, "Tumor Grade")
  expect_equal(marker_label, "Marker Level (ng/mL)")
})

test_that("Vignette scenario: apply_labels_from_dictionary() then use in gtsummary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment (years)",
    "marker", "Marker Level (ng/mL)",
    "trt", "Treatment Group",
    "grade", "Tumor Grade"
  )

  trial_labeled <- get_unlabeled_trial() |>
    apply_labels_from_dictionary(my_dictionary)

  # Verify attributes were set
  expect_equal(attr(trial_labeled$age, "label"), "Age at Enrollment (years)")
  expect_equal(attr(trial_labeled$marker, "label"), "Marker Level (ng/mL)")
  expect_equal(attr(trial_labeled$trt, "label"), "Treatment Group")

  # Use in gtsummary
  tbl <- trial_labeled |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
    add_auto_labels()

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]
  grade_label <- tbl$table_body$label[tbl$table_body$variable == "grade"][1]

  expect_equal(age_label, "Age at Enrollment (years)")
  expect_equal(marker_label, "Marker Level (ng/mL)")
  expect_equal(grade_label, "Tumor Grade")
})

test_that("Vignette scenario: controlling label priority with options", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Save old option
  old_opt <- getOption("sumExtras.preferDictionary")
  on.exit(options(sumExtras.preferDictionary = old_opt), add = TRUE)

  # Test with preferDictionary = FALSE (default)
  options(sumExtras.preferDictionary = FALSE)

  trial_both <- get_unlabeled_trial()
  attr(trial_both$age, "label") <- "Age from Attribute"

  dictionary_conflict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Dictionary"
  )

  tbl1 <- trial_both |>
    gtsummary::tbl_summary(by = trt, include = age) |>
    add_auto_labels(dictionary = dictionary_conflict)

  age_label1 <- tbl1$table_body$label[tbl1$table_body$variable == "age"][1]
  expect_equal(age_label1, "Age from Attribute")

  # Test with preferDictionary = TRUE
  options(sumExtras.preferDictionary = TRUE)

  tbl2 <- trial_both |>
    gtsummary::tbl_summary(by = trt, include = age) |>
    add_auto_labels(dictionary = dictionary_conflict)

  age_label2 <- tbl2$table_body$label[tbl2$table_body$variable == "age"][1]
  expect_equal(age_label2, "Age from Dictionary")
})

test_that("Vignette scenario: cross-package workflow with apply_labels_from_dictionary()", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment (years)",
    "marker", "Marker Level (ng/mL)",
    "trt", "Treatment Group",
    "grade", "Tumor Grade",
    "stage", "T Stage"
  )

  # Apply to data once
  trial_final <- get_unlabeled_trial() |>
    apply_labels_from_dictionary(my_dictionary)

  # Verify labels are set as attributes
  expect_equal(attr(trial_final$age, "label"), "Age at Enrollment (years)")
  expect_equal(attr(trial_final$marker, "label"), "Marker Level (ng/mL)")
  expect_equal(attr(trial_final$trt, "label"), "Treatment Group")
  expect_equal(attr(trial_final$grade, "label"), "Tumor Grade")
  expect_equal(attr(trial_final$stage, "label"), "T Stage")

  # Use in gtsummary table
  tbl <- trial_final |>
    gtsummary::tbl_summary(
      by = trt,
      include = c(age, marker, grade, stage)
    ) |>
    add_auto_labels()

  expect_s3_class(tbl, "gtsummary")

  # Verify labels in table
  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]
  grade_label <- tbl$table_body$label[tbl$table_body$variable == "grade"][1]
  stage_label <- tbl$table_body$label[tbl$table_body$variable == "stage"][1]

  expect_equal(age_label, "Age at Enrollment (years)")
  expect_equal(marker_label, "Marker Level (ng/mL)")
  expect_equal(grade_label, "Tumor Grade")
  expect_equal(stage_label, "T Stage")
})

test_that("Vignette scenario: combining with dplyr operations preserves labels", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")
  skip_if_not_installed("dplyr")

  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment (years)",
    "marker", "Marker Level (ng/mL)",
    "trt", "Treatment Group"
  )

  trial_labeled <- get_unlabeled_trial() |>
    apply_labels_from_dictionary(dictionary)

  # Perform dplyr operations
  trial_subset <- trial_labeled |>
    dplyr::filter(stage %in% c("T1", "T2")) |>
    dplyr::select(age, marker, trt)

  # Labels should survive
  expect_equal(attr(trial_subset$age, "label"), "Age at Enrollment (years)")
  expect_equal(attr(trial_subset$marker, "label"), "Marker Level (ng/mL)")
  expect_equal(attr(trial_subset$trt, "label"), "Treatment Group")

  # Use in table
  tbl <- trial_subset |>
    gtsummary::tbl_summary(by = trt) |>
    add_auto_labels()

  expect_s3_class(tbl, "gtsummary")
})

# ==============================================================================
# PERFORMANCE AND ROBUSTNESS TESTS
# ==============================================================================

test_that("add_auto_labels() handles large dictionaries efficiently", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Create large dictionary (more realistic scenario)
  large_dict <- tibble::tibble(
    Variable = paste0("var", 1:1000),
    Description = paste0("Description for variable ", 1:1000)
  )

  # Add actual variables from trial
  large_dict <- dplyr::bind_rows(
    large_dict,
    tibble::tribble(
      ~Variable, ~Description,
      "age", "Age",
      "marker", "Marker"
    )
  )

  # Should handle efficiently
  expect_silent(
    tbl <- get_unlabeled_trial() |>
      gtsummary::tbl_summary(include = c(age, marker)) |>
      add_auto_labels(dictionary = large_dict)
  )

  expect_s3_class(tbl, "gtsummary")
})

test_that("apply_labels_from_dictionary() handles wide data (many columns)", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Create data with many columns
  wide_data <- gtsummary::trial[, c("age", "marker", "trt", "grade", "stage", "response", "death")]

  wide_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age",
    "marker", "Marker",
    "trt", "Treatment",
    "grade", "Grade",
    "stage", "Stage",
    "response", "Response",
    "death", "Death"
  )

  labeled <- apply_labels_from_dictionary(wide_data, wide_dict)

  # All should be labeled
  expect_equal(attr(labeled$age, "label"), "Age")
  expect_equal(attr(labeled$marker, "label"), "Marker")
  expect_equal(attr(labeled$trt, "label"), "Treatment")
  expect_equal(attr(labeled$grade, "label"), "Grade")
  expect_equal(attr(labeled$stage, "label"), "Stage")
  expect_equal(attr(labeled$response, "label"), "Response")
  expect_equal(attr(labeled$death, "label"), "Death")
})

test_that("add_auto_labels() handles underscores in variable names", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Create data with underscores in names
  special_data <- get_unlabeled_trial()
  names(special_data)[names(special_data) == "age"] <- "age_years"

  special_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age_years", "Age in Years"
  )

  tbl <- special_data |>
    gtsummary::tbl_summary(include = age_years) |>
    add_auto_labels(dictionary = special_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age_years"][1]
  expect_equal(age_label, "Age in Years")
})
