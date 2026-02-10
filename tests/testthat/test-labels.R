# Tests for add_auto_labels()

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
  # Manual label should be preserved
  # (may need updating based on new behavior)
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

  # Should find dictionary automatically (silently)
  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels()

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
    add_auto_labels() # No dictionary provided

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]

  expect_equal(age_label, "Age from Attribute")
  expect_equal(marker_label, "Marker from Attribute")
})

test_that("add_auto_labels() attributes win over dictionary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

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

test_that("add_auto_labels() handles no dict and no attrs", {
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

# EDGE CASE TESTS

test_that("add_auto_labels() handles empty strings in attributes", {
  skip_if_not_installed("gtsummary")

  labeled_data <- gtsummary::trial
  attr(labeled_data$age, "label") <- "" # Empty string

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

test_that("add_auto_labels() dict + attributes correct priority", {
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

  # age has both - attribute wins
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

test_that("add_auto_labels() auto-discovery is silent", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age Label"
  )

  # Should be silent (no message)
  expect_no_message(
    tbl <- get_unlabeled_trial() |>
      gtsummary::tbl_summary(include = age) |>
      add_auto_labels()
  )

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, "Age Label")
})

test_that("add_auto_labels() auto-discovery with extra dict vars", {
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


  # Only include age - should still work
  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels()

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, "Age at Baseline")
})

test_that("add_auto_labels() handles dict with no matching vars", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Dictionary with completely different variables
  dictionary <- tibble::tribble(
    ~Variable, ~Description,
    "foo", "Foo Variable",
    "bar", "Bar Variable"
  )


  # Should work without error
  tbl <- get_unlabeled_trial() |>
    gtsummary::tbl_summary(include = age) |>
    add_auto_labels()

  expect_s3_class(tbl, "gtsummary")
  # Label should remain as default (not from dictionary)
})

# ==============================================================================
# COMPREHENSIVE TESTS FOR LABEL PRIORITY LOGIC
# ==============================================================================

test_that("add_auto_labels() priority: manual > attr > dict", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

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
  response_label <- tbl$table_body$label[
    tbl$table_body$variable == "response"
  ][1]

  # age: manual override wins
  expect_equal(age_label, "Age Manual Override")
  # marker: only attribute available
  expect_equal(marker_label, "Marker from Attribute")
  # grade: only dictionary available
  expect_equal(grade_label, "Grade from Dictionary")
  # response: only dictionary available
  expect_equal(response_label, "Response from Dictionary")
})

test_that("add_auto_labels() dict is fallback when no attribute", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  # Create data with attribute only for marker
  labeled_data <- get_unlabeled_trial()
  attr(labeled_data$marker, "label") <- "Marker from Attribute"

  # Dictionary has age and grade
  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Dictionary",
    "grade", "Grade from Dictionary"
  )

  tbl <- labeled_data |>
    gtsummary::tbl_summary(
      include = c(age, marker, grade)
    ) |>
    add_auto_labels(dictionary = my_dict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  marker_label <- tbl$table_body$label[tbl$table_body$variable == "marker"][1]
  grade_label <- tbl$table_body$label[tbl$table_body$variable == "grade"][1]

  # age: dictionary (no attribute)
  expect_equal(age_label, "Age from Dictionary")
  # marker: attribute (no dictionary entry)
  expect_equal(marker_label, "Marker from Attribute")
  # grade: dictionary (no attribute)
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
    "Create a table"
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

test_that("add_auto_labels() errors with missing dict columns", {
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

test_that("add_auto_labels() handles very long label strings", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  long_label <- paste(
    rep("Very long description that goes on and on", 10),
    collapse = " "
  )

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

# ==============================================================================
# INTEGRATION TESTS - VIGNETTE SCENARIOS
# ==============================================================================

# Integration Tests - Vignette Workflows

test_that("Vignette scenario: explicit dict to add_auto_labels()", {
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
  response_label <- tbl$table_body$label[
    tbl$table_body$variable == "response"
  ][1]

  expect_equal(age_label, "Age at Enrollment (years)")
  expect_equal(stage_label, "T Stage")
  expect_equal(response_label, "Tumor Response")
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

test_that("Vignette scenario: attributes always win over dictionary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  trial_both <- get_unlabeled_trial()
  attr(trial_both$age, "label") <- "Age from Attribute"

  dictionary_conflict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age from Dictionary"
  )

  tbl <- trial_both |>
    gtsummary::tbl_summary(by = trt, include = age) |>
    add_auto_labels(dictionary = dictionary_conflict)

  age_label <- tbl$table_body$label[tbl$table_body$variable == "age"][1]
  expect_equal(age_label, "Age from Attribute")
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
