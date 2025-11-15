# CRAN Submission Plan - sumExtras Package

## Progress Summary (Updated 2025-11-15)

**Phase 1 - Critical Fixes: 50% COMPLETE**

Completed:
- ✅ Refactored `create_labels()` - dictionary is now an explicit parameter with fallback to parent.frame()
- ✅ Refactored `add_auto_labels()` - dictionary is now an explicit parameter with fallback to parent.frame()
- ✅ Replaced `do.call()` with `modify_table_body()` in add_auto_labels() - completely unified approach for all table types
- ✅ Cleaned up `globalVariables()` - removed "dictionary" and "tbl_svysummary"
- ✅ Updated all existing tests in test-labels.R to pass dictionary explicitly

Remaining:
- ❌ Create test-extras-errors.R with error class tests (17 error classes)
- ❌ Create test-clean_table-errors.R with error class tests
- ❌ Create test-labels-errors.R with error class tests
- ❌ Create test-styling-errors.R with error class tests
- ❌ Fix warning tests to actually trigger warnings
- ❌ Update NEWS.md with breaking changes

---

## Executive Summary

**Overall Assessment:** Package is ~90% CRAN-ready. Excellent documentation, structure, and coding style. However, critical architectural issues and incomplete test coverage must be addressed before submission.

**Agent Review Results:**
- ✅ DESCRIPTION, NEWS.md, README.md: Excellent, no changes needed
- ✅ R/ folder: Major architectural issues FIXED in Phase 1
- ❌ tests/ folder: Only 45% coverage, 17 untested error classes (PENDING)

---

## Critical Issues (MUST FIX Before CRAN)

### 1. Global `dictionary` Object Dependency ✅ FIXED

**Location:** `R/labels.R` lines 64, 190 (create_labels, add_auto_labels)

**Previous Problem:**
- Functions checked for `dictionary` in `parent.frame()`
- Fetched it into `dict` variable with `get()`
- **Then ignored `dict` and used bare `dictionary`** via normal scoping
- Documentation claimed "global" but code checked "parent.frame()" (not the same)
- Violated functional programming - behavior depended on calling environment
- Was untestable in isolation

**Solution Applied:**
```r
create_labels <- function(data, dictionary = NULL) {
  # If dictionary not provided, try to find it
  if (is.null(dictionary)) {
    if (!exists("dictionary", envir = parent.frame())) {
      rlang::abort(
        c(
          "No `dictionary` provided and none found in calling environment.",
          "i" = "Pass dictionary explicitly: create_labels(data, dictionary = my_dict)",
          "i" = "Or ensure a `dictionary` object exists in your environment."
        ),
        class = "create_labels_missing_dictionary"
      )
    }
    dictionary <- get("dictionary", envir = parent.frame())
  }

  # Validate and use dictionary parameter consistently
  # ...
}
```

**Files updated:**
- ✅ `R/labels.R` - Both create_labels() and add_auto_labels()
- ✅ `R/utils.R` - Removed "dictionary" from globalVariables()
- ✅ `tests/testthat/test-labels.R` - Updated tests to pass dictionary explicitly
- ✅ Documentation for both functions

---

### 2. Fragile `do.call()` in `add_auto_labels()` ✅ FIXED

**Location:** `R/labels.R` lines 279-286 (PREVIOUS CODE)

**Previous Problem:**
```r
args <- tbl$inputs  # Relied on internal gtsummary structure
args$label <- combined_labels

if (is_survey_table) {
  do.call(tbl_svysummary, args)  # Rebuilt entire table
} else {
  do.call(tbl_summary, args)
}
```

**Why it was fragile:**
1. Relied on undocumented `tbl$inputs` internal structure
2. Rebuilt entire table from scratch (wasteful, risky)
3. **Threw away prior modifications** - Example:
   ```r
   trial |>
     tbl_summary(by = trt) |>
     add_p() |>              # These p-values would get lost!
     add_auto_labels()
   ```
4. Would break if gtsummary changes internals

**Solution Applied:** Now uses unified `modify_table_body()` approach for all table types:
```r
result <- tbl |>
  modify_table_body(
    ~ .x |>
      dplyr::left_join(dict_filtered, by = 'variable') |>
      dplyr::mutate(
        label = dplyr::if_else(
          row_type == 'label' & !is.na(auto_label),
          auto_label,
          label
        )
      ) |>
      dplyr::select(-auto_label)
  )
```

**Benefits Achieved:**
- ✅ Works with ANY gtsummary table type
- ✅ Preserves all existing modifications (add_p(), add_overall(), etc.)
- ✅ Doesn't rely on internal `tbl$inputs` structure
- ✅ Won't break on gtsummary updates
- ✅ Consistent with regression table implementation

---

### 3. Missing Error Class Tests ❌ CRITICAL

**Problem:**
- Package has 17 custom error classes with elaborate `rlang::abort()` calls
- **ZERO tests use `expect_error(..., class = "error_class")`**
- Tests only check error messages, not error classes

**Custom error classes without tests:**

| Function | Untested Error Classes |
|----------|------------------------|
| extras() | extras_invalid_input, extras_invalid_args, extras_invalid_arg_names |
| clean_table() | clean_table_invalid_input |
| create_labels() | create_labels_invalid_data, create_labels_missing_dictionary, create_labels_invalid_dictionary_type, create_labels_missing_columns |
| add_auto_labels() | add_auto_labels_invalid_input, add_auto_labels_missing_dictionary |
| theme_gt_compact() | theme_gt_compact_invalid_input |
| group_styling() | group_styling_invalid_input, group_styling_invalid_format_type, group_styling_invalid_format_value |
| get_group_rows() | get_group_rows_invalid_input, get_group_rows_missing_table_body, get_group_rows_missing_row_type |

**Example current test (WRONG):**
```r
expect_error(get_group_rows(mtcars), "must be a gtsummary object")
```

**Should be:**
```r
expect_error(
  get_group_rows(mtcars),
  class = "get_group_rows_invalid_input"
)
```

**Files needed:**
- `tests/testthat/test-extras-errors.R` (NEW)
- `tests/testthat/test-clean_table-errors.R` (NEW)
- `tests/testthat/test-labels-errors.R` (NEW)
- `tests/testthat/test-styling-errors.R` (NEW)

---

### 4. Misleading Warning Tests ❌ CRITICAL

**Location:** `tests/testthat/test-extras-warnings.R` lines 50-75

**Problem:**
```r
# Current test checks if warning CODE exists in function body
func_body <- deparse(body(extras))
expect_true(any(grepl("extras_overall_failed", func_body)))
```

**This is useless!** It verifies the string "extras_overall_failed" appears in code, not that warnings actually trigger.

**Should be:**
```r
# Actually trigger the warning
expect_warning(
  problem_table |> extras(overall = TRUE),
  class = "extras_overall_failed"
)

expect_warning(
  problem_table |> extras(pval = TRUE),
  class = "extras_pvalue_failed"
)
```

---

### 5. Missing Input Validation ⚠️ MEDIUM

**Location:** `R/labels.R` line 236

**Problem:**
```r
original_data <- tbl$inputs$data  # Assumes this exists!
```

No check if `tbl$inputs` or `tbl$inputs$data` exists. Will crash with cryptic error on malformed gtsummary objects.

**Fix:**
```r
if (is.null(tbl$inputs) || is.null(tbl$inputs$data)) {
  rlang::abort(
    c(
      "Cannot extract data from gtsummary object.",
      "i" = "The table must be created with `tbl_summary()` or similar functions."
    ),
    class = "add_auto_labels_invalid_structure"
  )
}
original_data <- tbl$inputs$data
```

---

## Quality Improvements (SHOULD FIX)

### 6. Clean up `globalVariables()` ⚠️ MINOR

**Location:** `R/utils.R` line 9

**Problem:**
```r
utils::globalVariables(
  c(
    "var_type",
    "row_type",
    "label",
    "Variable",
    "Description",
    "dictionary",      # Remove after dictionary refactor
    "tbl_svysummary"   # Remove - this is imported!
  )
)
```

**Fix:**
- Remove "dictionary" after refactoring to explicit parameter
- Remove "tbl_svysummary" - it's already imported on line 140 of labels.R

---

### 7. Inefficient Double Filtering ⚠️ MINOR

**Location:** `R/labels.R` lines 247-254

**Current:**
```r
auto_labels_list <- create_labels(data_for_labels)  # All variables
# ... then filter
auto_labels_filtered <- auto_labels_list[keep_vars]
```

**Better:**
```r
included_vars <- tbl$inputs$include %||% names(data_for_labels)
data_filtered <- data_for_labels[, included_vars, drop = FALSE]
auto_labels_list <- create_labels(data_filtered)  # Only included vars
```

---

### 8. Edge Case Testing ❌ MEDIUM

**Missing tests for:**
- NULL inputs
- Empty data frames
- Single-row/single-column tables
- Very long variable names
- Special characters in variable names
- Dictionary with duplicate Variable entries
- Dictionary with NA in Variable column
- Tables with zero groups
- Malformed gtsummary objects

---

### 9. Test Output Correctness ⚠️ MEDIUM

**Problem:** Tests verify functions return objects but not that they're correct.

**Example from test-labels.R:**
```r
test_that("add_auto_labels() works with tbl_summary", {
  tbl <- trial |>
    tbl_summary(by = trt, include = c(age, grade)) |>
    add_auto_labels()

  expect_s3_class(tbl, "gtsummary")  # Only checks class!
})
```

**Should also verify:**
```r
expect_equal(
  tbl$table_body$label[tbl$table_body$variable == "age"][1],
  "Age at Enrollment"
)
```

---

## Polish (NICE TO HAVE)

### 10. Regex Pattern Too Broad ⚠️ LOW

**Location:** `R/clean_table.R` lines 81-91

**Problem:**
```r
"\\bNA\\b"  # Will match "NANA (23%)"
```

The word boundary approach might match NA within other words. Specific patterns like `"^NA \\(NA\\)$"` are fine, but bare `\\bNA\\b` is too greedy.

---

## Test Coverage Summary

**Current Coverage: ~45%**
- Happy paths: 70% covered ✅
- Error conditions: 0% covered ❌
- Edge cases: 15% covered ⚠️
- Warning conditions: 0% properly covered ❌

**CRAN Readiness:** NOT READY

Need ~100-150 additional test assertions covering:
1. All 17 error classes with proper `expect_error(..., class = ...)`
2. Actual warning triggering (not code inspection)
3. Edge cases (NULL, NA, empty, special characters)
4. Output correctness verification

---

## Action Plan

### Phase 1: Critical Fixes (MUST DO)
- [x] Refactor `create_labels()` - dictionary as explicit parameter
- [x] Refactor `add_auto_labels()` - dictionary as explicit parameter
- [x] Replace `do.call()` with `modify_table_body()` in add_auto_labels()
- [x] Add input validation for `tbl$inputs$data`
- [x] Clean up globalVariables() - remove dictionary and tbl_svysummary
- [x] Update all existing tests to pass dictionary explicitly
- [ ] Create test-extras-errors.R with all error class tests
- [ ] Create test-clean_table-errors.R with error class tests
- [ ] Create test-labels-errors.R with error class tests
- [ ] Create test-styling-errors.R with error class tests
- [ ] Fix warning tests to actually trigger warnings

### Phase 2: Quality Improvements (SHOULD DO)
- [ ] Optimize double filtering in add_auto_labels()
- [ ] Add edge case tests (NULL, NA, empty inputs)
- [ ] Verify output correctness in existing tests
- [ ] Update NEWS.md with breaking changes

### Phase 3: Polish (NICE TO HAVE)
- [ ] Tighten regex patterns in clean_table()
- [ ] Test with large tables for performance
- [ ] Test special character encoding

### Phase 4: Final CRAN Prep
- [ ] Run R CMD check --as-cran
- [ ] Run devtools::check()
- [ ] Verify test coverage with covr::package_coverage()
- [ ] Review all documentation
- [ ] Update DESCRIPTION version for CRAN submission
- [ ] Submit to CRAN

---

## Files Requiring Changes

### R/ Code
- ✅ `R/labels.R` - Both dictionary functions + do.call() refactor (COMPLETED)
- ✅ `R/utils.R` - Clean up globalVariables() (COMPLETED)

### Tests
- ✅ `tests/testthat/test-labels.R` - Updated for dictionary parameter (COMPLETED)
- ⏳ `tests/testthat/test-extras-warnings.R` - Fix to trigger warnings (PENDING)
- ➕ `tests/testthat/test-extras-errors.R` - NEW (PENDING)
- ➕ `tests/testthat/test-clean_table-errors.R` - NEW (PENDING)
- ➕ `tests/testthat/test-labels-errors.R` - NEW (PENDING)
- ➕ `tests/testthat/test-styling-errors.R` - NEW (PENDING)

### Documentation
- ✅ `man/create_labels.Rd` - Updated for dictionary parameter (COMPLETED)
- ✅ `man/add_auto_labels.Rd` - Updated for dictionary parameter (COMPLETED)
- ⏳ `NEWS.md` - Document breaking changes (PENDING)

---

## Comparison: Gemini vs. Agent Findings

| Assessment | Gemini | r-code-roaster | r-test-builder |
|------------|--------|----------------|----------------|
| Dictionary issue | BLOCKER ✅ | BLOCKER ✅ (with better explanation) | - |
| do.call() issue | MEDIUM ✅ | MEDIUM-HIGH ✅ (found it breaks modifications) | - |
| Test coverage | "High" (optimistic) ❌ | - | 45% actual ❌ |
| Error class testing | Mentioned ✅ | - | 0/17 tested ❌ |
| DESCRIPTION/NEWS/README | Perfect ✅ | - | - |
| Additional issues | - | Found 5 more issues | Found misleading warning tests |

**Bottom line:** Gemini was ~90% right but too optimistic about tests. The specialized agents found the remaining 10% plus critical testing gaps.

---

## Estimated Effort

- **Phase 1 (Critical):** 6-8 hours
- **Phase 2 (Quality):** 3-4 hours
- **Phase 3 (Polish):** 1-2 hours
- **Phase 4 (CRAN prep):** 2-3 hours

**Total: 12-17 hours** to CRAN-ready

---

## Notes

- The package is fundamentally solid - this is about fixing architectural debt and testing gaps
- The dictionary refactor is breaking but necessary - document clearly in NEWS.md
- Once fixed, this will be a top-tier package with proper defensive programming
- CRAN submission should be straightforward after these changes
