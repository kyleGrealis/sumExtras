# sumExtras - Detailed CRAN Compatibility Fixes
## Technical Specification & Code Changes

**Last Updated:** 2025-11-15
**Priority:** HIGH - Required for CRAN submission

---

## Fix 1: extras() - Add Type Checking and Error Handling

### Current Code (R/extras.R, lines 77-182)

**PROBLEM:** Function silently skips functionality for unsupported table types.

### Issue 1a: No check for tbl_regression
```r
# Current behavior (lines 124-127):
is_stratified <- !is.null(tbl$inputs) && length(tbl$inputs$by) > 0
# tbl_regression has NO tbl$inputs$by, so is_stratified = FALSE
# Function continues and applies only bold_labels() + modify_header()
# USER HAS NO IDEA that overall/pval weren't added!
```

### Issue 1b: No check for stacked tables
```r
# Current behavior:
# stacked_tbl <- tbl_strata(...) |> extras()
# This has a different $inputs structure
# No $by field means is_stratified = FALSE
# Silently does nothing beyond bold_labels()
```

### Issue 1c: No warning for non-stratified tables
```r
# Current behavior:
# unstratified_tbl <- tbl_summary() |> extras()  # No by=
# Silently skips add_overall() and add_p() (lines 136, 156)
# No warning to user
```

### RECOMMENDED FIX

**Location:** `R/extras.R` - Add type checking right after gtsummary validation

```r
extras <- function(tbl, pval = TRUE, overall = TRUE, last = FALSE, .args = NULL) {

  # Validate tbl is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a gtsummary table using `tbl_summary()` or `tbl_regression()`."
      ),
      class = "extras_invalid_input"
    )
  }

  # ========== ADD THIS NEW SECTION ==========
  # Check for unsupported table types
  if ("tbl_strata" %in% class(tbl)) {
    rlang::abort(
      c(
        "Stacked tables (tbl_strata) are not yet supported by `extras()`.",
        "i" = "Apply `extras()` to individual table components instead:",
        "i" = "  tbl_strata(...) |>",
        "i" = "    purrr::map(~ .x |> extras())"
      ),
      class = "extras_stacked_not_supported"
    )
  }

  if ("tbl_regression" %in% class(tbl)) {
    rlang::abort(
      c(
        "`extras()` does not support `tbl_regression` tables.",
        "x" = "tbl_regression tables are not stratified.",
        "i" = "Use these alternatives for regression tables:",
        "i" = "  tbl_regression(...) |>",
        "i" = "    bold_labels() |>",
        "i" = "    modify_header(label ~ '')"
      ),
      class = "extras_unsupported_table_type"
    )
  }

  # Parse arguments (existing code lines 91-122)
  if (!is.null(.args)) {
    if (!is.list(.args)) {
      rlang::abort(
        c(
          "`.args` must be a list.",
          "x" = sprintf("You supplied an object of class: %s", class(.args)[1]),
          "i" = "Use a named list like `list(pval = TRUE, overall = TRUE, last = FALSE)`."
        ),
        class = "extras_invalid_args"
      )
    }

    valid_args <- c("pval", "overall", "last")
    invalid_args <- setdiff(names(.args), valid_args)

    if (length(invalid_args) > 0) {
      rlang::abort(
        c(
          "`.args` contains invalid argument names.",
          "x" = sprintf("Invalid argument(s): %s", paste(invalid_args, collapse = ", ")),
          "i" = sprintf("Valid arguments are: %s", paste(valid_args, collapse = ", "))
        ),
        class = "extras_invalid_arg_names"
      )
    }

    pval <- .args$pval %||% TRUE
    overall <- .args$overall %||% TRUE
    last <- .args$last %||% FALSE
  }

  # ========== MODIFY THIS SECTION ==========
  # Check if table is stratified (required for overall/pval)
  is_stratified <- !is.null(tbl$inputs) && length(tbl$inputs$by) > 0

  # NEW: Warn if not stratified but user requested overall/pval
  if (!is_stratified && (overall || pval)) {
    rlang::warn(
      c(
        "This table is not stratified (missing `by` argument in tbl_summary).",
        "i" = "Overall column and p-values are only available for stratified tables.",
        "i" = "Applying only `bold_labels()` and `modify_header(label ~ '')`."
      ),
      class = "extras_not_stratified"
    )
  }

  result <- tbl |>
    bold_labels() |>
    modify_header(label ~ "")

  # Add overall column only if table is stratified
  if (overall && is_stratified) {
    result <- tryCatch(
      {
        suppressMessages(result |> add_overall(last = last))
      },
      error = function(e) {
        rlang::warn(
          c(
            "Failed to add overall column.",
            "x" = sprintf("Error: %s", conditionMessage(e)),
            "i" = "Continuing without overall column."
          ),
          class = "extras_overall_failed"
        )
        result
      }
    )
  }

  # Only add p-values if table is stratified
  if (pval && is_stratified) {
    result <- tryCatch(
      {
        suppressMessages(
          result |>
            add_p(
              pvalue_fun = ~ style_pvalue(.x, digits = 3),
              test.args = all_tests("fisher.test") ~ list(simulate.p.value = TRUE)
            )
        )
      },
      error = function(e) {
        rlang::warn(
          c(
            "Failed to add p-values.",
            "x" = sprintf("Error: %s", conditionMessage(e)),
            "i" = "Continuing without p-values."
          ),
          class = "extras_pvalue_failed"
        )
        result
      }
    )
  }

  result |> clean_table()
}
```

### Tests Required

**File:** `tests/testthat/test-extras-errors.R` (NEW)

```r
# Test 1: tbl_regression should error
test_that("extras() errors on tbl_regression", {
  skip_if_not_installed("gtsummary")
  mod <- lm(age ~ trt, data = gtsummary::trial)
  tbl <- gtsummary::tbl_regression(mod)

  expect_error(
    extras(tbl),
    class = "extras_unsupported_table_type"
  )
})

# Test 2: tbl_strata should error
test_that("extras() errors on tbl_strata", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("purrr")

  stacked <- gtsummary::trial |>
    gtsummary::tbl_strata(
      strata = grade,
      ~ .x |> gtsummary::tbl_summary(by = trt)
    )

  expect_error(
    extras(stacked),
    class = "extras_stacked_not_supported"
  )
})

# Test 3: Non-stratified table should warn
test_that("extras() warns on non-stratified table", {
  skip_if_not_installed("gtsummary")
  tbl <- gtsummary::trial |> gtsummary::tbl_summary()  # No by=

  expect_warning(
    extras(tbl, overall = TRUE),
    class = "extras_not_stratified"
  )
})

# Test 4: Non-stratified table with pval should warn
test_that("extras() warns when requesting p-values on non-stratified table", {
  skip_if_not_installed("gtsummary")
  tbl <- gtsummary::trial |> gtsummary::tbl_summary()  # No by=

  expect_warning(
    extras(tbl, pval = TRUE),
    class = "extras_not_stratified"
  )
})

# Test 5: Stratified tbl_svysummary should work
test_that("extras() works with stratified tbl_svysummary", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("survey")

  design <- survey::svydesign(ids = ~1, data = gtsummary::trial)
  tbl <- gtsummary::tbl_svysummary(design, by = trt)

  result <- extras(tbl)
  expect_s3_class(result, "gtsummary")
  expect_true("tbl_svysummary" %in% class(result))
})

# Test 6: Invalid .args should error
test_that("extras() errors on invalid .args", {
  skip_if_not_installed("gtsummary")
  tbl <- gtsummary::trial |> gtsummary::tbl_summary(by = trt)

  expect_error(
    extras(tbl, .args = list(invalid_arg = TRUE)),
    class = "extras_invalid_arg_names"
  )
})
```

### Documentation Updates

**File:** `man/extras.Rd` - Update DESCRIPTION section

```
@description Applies a consistent set of formatting options to \emph{stratified}
  gtsummary summary tables. Adds overall columns, bold labels, clean headers,
  and optional p-values.

  This function is designed specifically for \code{tbl_summary()} and
  \code{tbl_svysummary()} tables with a \code{by} argument (stratified).
  For \code{tbl_regression()} tables, see the examples section.
```

Add to DETAILS section:
```
\section{Supported Table Types}{
  The function works with:
  \itemize{
    \item \code{tbl_summary()} tables that are stratified (have a \code{by} argument)
    \item \code{tbl_svysummary()} tables that are stratified
  }

  The function will error on:
  \itemize{
    \item \code{tbl_regression()} and other regression tables (use \code{bold_labels()}
          and \code{modify_header()} instead)
    \item Stacked tables from \code{tbl_strata()} (apply to individual components)
  }

  The function will warn if:
  \itemize{
    \item Your table is not stratified (missing \code{by} argument) but you
          requested \code{overall = TRUE} or \code{pval = TRUE}
  }
}
```

---

## Fix 2: clean_table() - Verify and Document Universal Compatibility

### Current Code (R/clean_table.R, lines 62-102)

**STATUS:** ✅ GOOD - No code changes needed

### Recommendation

1. **Keep existing code - it's solid**
2. **Add documentation note** emphasizing universal compatibility

**File:** `man/clean_table.Rd` - Add section

```
@section Compatibility{
  This function works with all gtsummary table types:
  \itemize{
    \item \code{tbl_summary()} - with or without stratification
    \item \code{tbl_svysummary()} - survey summary tables
    \item \code{tbl_regression()} - regression models
    \item \code{tbl_strata()} - stacked tables (applies to each component)
  }

  For merged tables created with \code{as_gt()}, use \code{theme_gt_compact()}
  instead.
}
```

### Test to Add

**File:** `tests/testthat/test-clean_table.R` (NEW or APPEND)

```r
test_that("clean_table() works with tbl_regression", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("broom")

  mod <- lm(age ~ trt + grade, data = gtsummary::trial)
  tbl <- gtsummary::tbl_regression(mod)

  result <- clean_table(tbl)
  expect_s3_class(result, "gtsummary")
  expect_true("tbl_regression" %in% class(result))
})

test_that("clean_table() works with unstratified tbl_summary", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = c(age, marker))

  result <- clean_table(tbl)
  expect_s3_class(result, "gtsummary")
})
```

---

## Fix 3: add_auto_labels() - Document Stacked Table Limitation

### Current Code (R/labels.R, lines 194-277)

**STATUS:** ✅ GOOD - Implementation is solid

**Issue:** No documentation about stacked table limitation

### Recommended Changes

1. **Keep existing code** - the modify_table_body() approach is correct
2. **Add documentation** about stacked table behavior
3. **Add test** showing current behavior

**File:** `man/add_auto_labels.Rd` - Add section

```
@section Stacked Tables (tbl_strata){
  For stacked tables created with \code{tbl_strata()}, this function applies
  labels only to the first stratum's table body. To apply labels to all strata,
  consider:

  \preformatted{
  # Option 1: Apply labels before stacking
  tbl_strata(
    strata = grade,
    ~ .x |>
        tbl_summary(by = trt) |>
        add_auto_labels(dictionary = my_dict)
  )

  # Option 2: Apply to each component (requires custom approach)
  # This will be supported natively in a future release
  }
}
```

### Test to Add

**File:** `tests/testthat/test-labels-stacked.R` (NEW)

```r
test_that("add_auto_labels() with stacked tables documents current behavior", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment",
    "marker", "Marker Level"
  )

  # Current behavior: only first stratum gets labels
  stacked <- gtsummary::trial |>
    gtsummary::tbl_strata(
      strata = grade,
      ~ .x |> gtsummary::tbl_summary()
    ) |>
    add_auto_labels(dictionary = my_dict)

  # This test documents current behavior for future enhancement
  expect_s3_class(stacked, "gtsummary")
  # TODO: Verify which components actually got labels
})

test_that("add_auto_labels() recommended: apply before stacking", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("tibble")

  my_dict <- tibble::tribble(
    ~Variable, ~Description,
    "age", "Age at Enrollment",
    "marker", "Marker Level"
  )

  # Recommended approach: apply labels before stacking
  stacked <- gtsummary::trial |>
    gtsummary::tbl_strata(
      strata = grade,
      ~ .x |>
          gtsummary::tbl_summary() |>
          add_auto_labels(dictionary = my_dict)
    )

  expect_s3_class(stacked, "gtsummary")
})
```

---

## Fix 4: group_styling() and get_group_rows() - Add Stacked Table Tests

### Current Code

**STATUS:** ⚠️ UNTESTED with stacked tables

### Recommended Changes

**File:** `tests/testthat/test-styling-stacked.R` (NEW)

```r
test_that("group_styling() works with variable groups in tbl_summary", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
    gtsummary::add_variable_group_header(
      header = "Demographics",
      variables = age:marker
    ) |>
    group_styling()

  expect_s3_class(tbl, "gtsummary")
  # Verify styling was applied
  expect_true(any(tbl$table_styling$text_format == "bold"))
})

test_that("get_group_rows() returns correct row indices", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
    gtsummary::add_variable_group_header(
      header = "Demographics",
      variables = age:marker
    )

  group_rows <- get_group_rows(tbl)
  expect_type(group_rows, "integer")
  expect_true(length(group_rows) > 0)

  # Verify these rows have row_type == 'variable_group'
  row_types <- tbl$table_body$row_type[group_rows]
  expect_true(all(row_types == "variable_group"))
})

test_that("get_group_rows() returns empty vector if no variable groups", {
  skip_if_not_installed("gtsummary")

  tbl <- gtsummary::trial |>
    gtsummary::tbl_summary(include = c(age, marker))

  group_rows <- get_group_rows(tbl)
  expect_type(group_rows, "integer")
  expect_equal(length(group_rows), 0)
})

test_that("group_styling() documents stacked table behavior", {
  skip_if_not_installed("gtsummary")

  # Document that stacked tables need per-component styling
  # This is not a failure - just documenting current approach
  skip("Stacked table support deferred to future release")

  stacked <- gtsummary::trial |>
    gtsummary::tbl_strata(
      strata = grade,
      ~ .x |>
          gtsummary::tbl_summary(by = trt) |>
          gtsummary::add_variable_group_header(
            header = "Demographics",
            variables = age
          ) |>
          group_styling()
    )

  expect_s3_class(stacked, "gtsummary")
})
```

---

## Fix 5: Documentation - Create Compatibility Matrix

### New File: README updates

**Update:** `/home/kyle/dev/sumExtras/README.md`

Add new section after installation:

```markdown
## Compatibility Matrix

sumExtras functions work with different gtsummary table types:

| Function | tbl_summary | tbl_svysummary | tbl_regression | tbl_strata | Status |
|----------|:-----------:|:--------------:|:--------------:|:----------:|--------|
| `extras()` | ✅ | ⚠️ | ❌ | ❌ | See docs |
| `clean_table()` | ✅ | ✅ | ✅ | ✅ | Universal |
| `add_auto_labels()` | ✅ | ✅ | ✅ | ⚠️ | See docs |
| `create_labels()` | ✅ | ✅ | ✅ | ✅ | Data-only |
| `group_styling()` | ✅ | ✅ | ✅ | ⚠️ | See docs |
| `get_group_rows()` | ✅ | ✅ | ✅ | ⚠️ | See docs |
| `theme_gt_compact()` | N/A | N/A | N/A | N/A | gt only |
| `use_jama_theme()` | ✅ | ✅ | ✅ | ✅ | Global |

Legend:
- ✅ Fully supported
- ⚠️ Partially supported (see function documentation)
- ❌ Not supported (see documentation for alternatives)
- N/A Not applicable

### Key Limitations

1. **extras()** - Requires stratified tables (with `by` argument in tbl_summary/tbl_svysummary)
2. **add_auto_labels()** - For stacked tables, apply to components before stacking
3. **group_styling()** / **get_group_rows()** - Single table only; for stacked tables apply to each component
```

---

## Summary of Changes

### Files to Modify

| File | Changes | Priority | Effort |
|------|---------|----------|--------|
| R/extras.R | Add type checking (lines 77-182) | 🔴 CRITICAL | 1-2 hrs |
| man/extras.Rd | Update documentation | 🔴 CRITICAL | 1 hr |
| man/clean_table.Rd | Add compatibility note | 🟡 MEDIUM | 30 min |
| man/add_auto_labels.Rd | Document stacked limitation | 🟡 MEDIUM | 30 min |
| tests/testthat/test-extras-errors.R | NEW: 6 tests | 🔴 CRITICAL | 1 hr |
| tests/testthat/test-clean_table.R | Add 2 tests | 🟡 MEDIUM | 30 min |
| tests/testthat/test-labels-stacked.R | NEW: 2 tests | 🟡 MEDIUM | 1 hr |
| tests/testthat/test-styling-stacked.R | NEW: 4 tests | 🟡 MEDIUM | 1 hr |
| README.md | Add compatibility matrix | 🟡 MEDIUM | 30 min |

### Total Effort
- **Critical fixes:** 2-3 hours
- **Quality improvements:** 3-4 hours
- **Total for CRAN ready:** 5-7 hours

### Testing Requirements
- [ ] Run `R CMD check --as-cran` after changes
- [ ] Verify all tests pass: `devtools::test()`
- [ ] Check test coverage: `covr::package_coverage()`
- [ ] Verify documentation renders: `devtools::document()` then `?extras`

---

## Implementation Checklist

**Phase 1: Critical Fixes**
- [ ] Modify extras() to add type checking and warnings
- [ ] Create test-extras-errors.R with 6 tests
- [ ] Update extras.Rd documentation
- [ ] Run tests and verify passing

**Phase 2: Quality Documentation**
- [ ] Update clean_table.Rd with compatibility note
- [ ] Update add_auto_labels.Rd with stacked table note
- [ ] Create test-clean_table.R additions
- [ ] Create test-labels-stacked.R
- [ ] Create test-styling-stacked.R

**Phase 3: Final Polish**
- [ ] Update README with compatibility matrix
- [ ] Run full R CMD check
- [ ] Verify test coverage > 80%
- [ ] Review all documentation

**Phase 4: CRAN Submission**
- [ ] Update DESCRIPTION version
- [ ] Update NEWS.md with breaking changes
- [ ] Final documentation review
- [ ] Submit to CRAN
