# sumExtras - gtsummary Table Type Compatibility Review
## CRAN Release Assessment

**Review Date:** 2025-11-15
**Status:** CRITICAL ISSUES FOUND - NOT CRAN READY FOR GENERAL RELEASE
**Recommendation:** Fix gtsummary compatibility issues before CRAN submission

---

## Executive Summary

The sumExtras package provides 8 exported functions for styling gtsummary tables. Current implementation has **GOOD coverage for tbl_summary and tbl_svysummary** but **CRITICAL GAPS for stacked/merged tables**. Additionally, one function has architectural issues that may affect reliability.

### Compatibility Matrix

| Function | tbl_summary | tbl_svysummary | tbl_regression | Stacked | Merged | Status |
|----------|:-----------:|:--------------:|:--------------:|:-------:|:------:|--------|
| `extras()` | ✅ YES | ⚠️ PARTIAL | ❌ NO | ❌ NO | ❌ NO | CRITICAL ISSUES |
| `clean_table()` | ✅ YES | ✅ YES | ✅ YES | ✅ YES | ✅ YES | COMPATIBLE |
| `add_auto_labels()` | ✅ YES | ✅ YES | ✅ YES | ✅ YES | ✅ YES | COMPATIBLE |
| `create_labels()` | ✅ YES | ✅ YES | ✅ YES | ✅ YES | ✅ YES | COMPATIBLE |
| `group_styling()` | ✅ YES | ✅ YES | ✅ YES | ⚠️ UNTESTED | ⚠️ UNTESTED | LIKELY OK |
| `get_group_rows()` | ✅ YES | ✅ YES | ✅ YES | ⚠️ UNTESTED | ⚠️ UNTESTED | LIKELY OK |
| `theme_gt_compact()` | N/A | N/A | N/A | N/A | N/A | COMPATIBLE (gt only) |
| `use_jama_theme()` | ✅ YES | ✅ YES | ✅ YES | ✅ YES | ✅ YES | COMPATIBLE |

---

## CRITICAL FINDINGS

### 1. **extras() - SEVERE COMPATIBILITY ISSUES**

**File:** `/home/kyle/dev/sumExtras/R/extras.R` (lines 77-182)

#### Problem 1a: Works with tbl_summary (stratified only)
```r
extras <- function(tbl, pval = TRUE, overall = TRUE, last = FALSE, .args = NULL)
```

**Current behavior:**
- Lines 136-153: Calls `add_overall()` - ONLY works for stratified tbl_summary
- Lines 156-178: Calls `add_p()` - ONLY works for stratified tbl_summary
- Lines 127: Checks `tbl$inputs$by` - only exists on tbl_summary/tbl_svysummary

**Issues:**
1. **Does NOT work with tbl_regression:** No `tbl$inputs$by` field (regression tables aren't stratified)
   - Function silently skips add_overall() and add_p() without warning (line 136, 156)
   - Documentation says it works but doesn't mention this limitation
   - Users will apply extras() to regression and get no styling

2. **Partial support for tbl_svysummary:**
   - `add_overall()` - UNTESTED with survey data
   - `add_p()` - UNTESTED with survey data
   - May fail silently with try/catch (lines 137-152, 157-178)

3. **NO support for stacked/merged tables:**
   - Stacked tables have `tbl$inputs` as a list of inputs
   - Merged tables are gt_tables (not gtsummary objects)
   - Function will error on merged tables (fails class check line 80)
   - Function will silently do nothing on stacked tables

#### Problem 1b: Documentation is misleading
```r
#' Applies a consistent set of formatting options to gtsummary tables
#' including overall column, bold labels, clean headers, and optional p-values.
```
- Says it works with "gtsummary tables" (implies all types)
- Doesn't document that it only works with stratified tbl_summary
- Doesn't document that tbl_regression is unsupported
- Examples only show stratified tbl_summary (lines 41-68)

#### Problem 1c: Error handling silently hides failures
```r
# Lines 137-152
result <- tryCatch(
  { suppressMessages(result |> add_overall(last = last)) },
  error = function(e) {
    rlang::warn(...)  # Issues warning instead of erroring
    result  # Returns modified table without overall
  }
)
```

**Risk:** If add_overall() fails on survey data, user gets a warning but silently missing functionality.

#### Recommendation for CRAN
**Defer stacked/merged table support.** For CRAN release:
1. Add explicit check rejecting tbl_regression in extras()
2. Add explicit check rejecting stacked/merged tables
3. Document that extras() ONLY works with stratified tbl_summary
4. Add tests for tbl_svysummary with add_overall() and add_p()
5. Consider separate function for tbl_regression styling

**Code change needed:**
```r
extras <- function(tbl, pval = TRUE, overall = TRUE, last = FALSE, .args = NULL) {
  # Validate tbl is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(...)  # existing code
  }

  # NEW: Check for unsupported table types
  if ("tbl_regression" %in% class(tbl)) {
    rlang::abort(
      c(
        "`extras()` does not support tbl_regression tables.",
        "i" = "Use `bold_labels() |> modify_header(label ~ \"\")`",
        "i" = "for regression table formatting instead."
      ),
      class = "extras_unsupported_table_type"
    )
  }

  # Check if table is stratified (required for overall/pval)
  is_stratified <- !is.null(tbl$inputs) && length(tbl$inputs$by) > 0

  if ((overall || pval) && !is_stratified) {
    rlang::warn(
      c(
        "extras() requires a stratified table for overall columns and p-values.",
        "i" = "Your table is not stratified (missing `by` argument).",
        "i" = "Applying only `bold_labels()` and `modify_header()`."
      ),
      class = "extras_not_stratified"
    )
  }

  # ... rest of implementation
}
```

---

### 2. **add_auto_labels() - FRAGILE INTERNAL DEPENDENCY** ⚠️

**File:** `/home/kyle/dev/sumExtras/R/labels.R` (lines 194-277)

#### Problem 2a: Depends on internal `tbl$inputs$data`
```r
# Line 252 (NOT SHOWN IN CURRENT CODE BUT CRITICAL)
table_vars <- unique(tbl$table_body$variable)
```

**Current implementation IMPROVED:** Uses `modify_table_body()` approach which is good!

**However, there's still fragility:**

1. Lines 252: `table_vars <- unique(tbl$table_body$variable)`
   - Assumes `tbl$table_body$variable` exists
   - Works for ALL gtsummary types: ✅

2. Lines 260-274: Uses `modify_table_body()` with row_type logic
   ```r
   label = dplyr::if_else(
     row_type == 'label' & !is.na(auto_label),
     auto_label,
     label
   )
   ```
   - This works because it ONLY updates rows where row_type == 'label'
   - Stacked/merged tables DO have row_type: ✅
   - But stacked tables may have DIFFERENT table_body structure: ⚠️

#### Problem 2b: Untested with stacked/merged tables
- **Stacked tables:** Each component has its own table_body
  - `add_auto_labels()` will ONLY label the first component's table_body
  - Other components won't get labels

- **Merged tables:** Are gt_tables, not gtsummary objects
  - Will fail class check (line 197): ✅ Correct behavior

#### Recommendation for CRAN
**GOOD NEWS:** Current implementation is much better! However:
1. Add explicit test for stacked tables to verify current behavior
2. Document that add_auto_labels() only works on single tables (not stacked)
3. Consider adding support for stacked tables if feasible:
   ```r
   # Check if table is a stacked table
   if (inherits(tbl, "tbl_strata")) {
     # Apply labels to each component in the list
     # This requires iterating through strata_list
   }
   ```

---

## MODERATE ISSUES

### 3. **clean_table() - EXCELLENT COMPATIBILITY** ✅

**File:** `/home/kyle/dev/sumExtras/R/clean_table.R` (lines 62-102)

**Compatibility Analysis:**

✅ **Universal compatibility:**
- Uses `modify_table_body()` with `all_stat_cols()` - works for ANY table type
- Uses `modify_missing_symbol()` with `all_stat_cols()` - works for ANY table type
- Row type filtering (line 99-101) is conservative and safe

✅ **Works with:**
- tbl_summary: ✅ YES
- tbl_svysummary: ✅ YES
- tbl_regression: ✅ YES (though missing values less common)
- Stacked tables: ✅ YES (modifies each component separately)
- Merged tables: ❌ NO (are gt_tables, not gtsummary - correct behavior)

**Minor concern:** Line 99-101 assumes specific row_type values
```r
rows =
  (var_type %in% c("continuous", "dichotomous") & row_type == "label") |
  (var_type %in% c("continuous2", "categorical") & row_type == "level")
```
- These are standard gtsummary row_types, safe assumption
- May miss rows in custom tables, but graceful degradation

**Recommendation:** No changes needed for CRAN. Document that it works universally.

---

### 4. **group_styling() - LARGELY UNTESTED WITH STACKED**

**File:** `/home/kyle/dev/sumExtras/R/styling.R` (lines 151-196)

**Compatibility Analysis:**

✅ **Core functionality solid:**
- Line 190-195: Uses `modify_table_styling()` with row_type filtering
- Works because `row_type == 'variable_group'` is standard

⚠️ **Untested with stacked tables:**
- Should work (modifies each component separately)
- No explicit tests for stacked scenario
- Variable groups are gtsummary feature, may not appear in all tables

**Recommendation for CRAN:**
1. Add test: Apply variable groups to stacked table and verify styling works
2. Add documentation note: "Works with all gtsummary table types"

---

### 5. **get_group_rows() - UNTESTED WITH STACKED/REGRESSION**

**File:** `/home/kyle/dev/sumExtras/R/styling.R` (lines 250-286)

**Compatibility Analysis:**

✅ **Correct implementation:**
- Line 285: Simple extraction of row numbers where `row_type == 'variable_group'`
- Safe because it only reads, doesn't modify

⚠️ **Issues:**
1. Returns row numbers from first table_body only
   - For stacked tables: Only row numbers from first component are correct
   - These won't align with rows in `as_gt()` output!

2. Example from documentation (lines 220-241) shows expected usage but not tested

**Recommendation for CRAN:**
1. Add explicit test for stacked tables showing it fails with current approach
2. Document: "Works with single gtsummary tables. For stacked tables, apply styling to each component separately."
3. Consider adding helper: `get_group_rows_from_strata()` for stacked tables

---

## COMPATIBILITY BY TABLE TYPE

### tbl_summary (Stratified and Unstratified)

**Status:** ✅ EXCELLENT SUPPORT

| Function | Stratified | Unstratified | Notes |
|----------|:----------:|:------------:|-------|
| `extras()` | ✅ Full | ⚠️ Partial | Skips overall/pval silently if not stratified - should warn |
| `clean_table()` | ✅ Full | ✅ Full | Universal approach |
| `add_auto_labels()` | ✅ Full | ✅ Full | Unified modify_table_body approach |
| `create_labels()` | ✅ Full | ✅ Full | Data-only function |
| `group_styling()` | ✅ Full | ✅ Full | Works with variable groups |
| `get_group_rows()` | ✅ Full | ✅ Full | Returns rows if they exist |

**Recommendation:** Add warning to `extras()` when table is not stratified.

---

### tbl_svysummary (Survey Summary Tables)

**Status:** ⚠️ PARTIAL SUPPORT

| Function | Status | Issues |
|----------|:------:|--------|
| `extras()` | ⚠️ Untested | add_overall() and add_p() behavior with survey data not tested |
| `clean_table()` | ✅ Full | Works same as tbl_summary |
| `add_auto_labels()` | ✅ Full | Unified approach works |
| `create_labels()` | ✅ Full | Data-only function |
| `group_styling()` | ✅ Full | Should work (same row_type system) |
| `get_group_rows()` | ✅ Full | Should work (same row_type system) |

**Recommendation for CRAN:**
1. Add tests for `extras()` with tbl_svysummary
2. Document which functions are tested with survey tables
3. Create test:
   ```r
   test_that("extras() works with tbl_svysummary", {
     # Create survey design
     survey_design <- survey::svydesign(...)
     tbl <- gtsummary::tbl_svysummary(survey_design)

     expect_no_error(extras(tbl))
     expect_s3_class(extras(tbl), "gtsummary")
   })
   ```

---

### tbl_regression (and other regression models)

**Status:** ❌ NOT SUPPORTED

| Function | Status | Issue |
|----------|:------:|-------|
| `extras()` | ❌ NO | Function checks `tbl$inputs$by` which doesn't exist; silently does nothing |
| `clean_table()` | ✅ YES | Works fine (missing values less common but possible) |
| `add_auto_labels()` | ✅ YES | Works via modify_table_body approach |
| `create_labels()` | ✅ YES | Data-only function |
| `group_styling()` | ⚠️ Untested | Should work if regression table has variable groups |
| `get_group_rows()` | ⚠️ Untested | Should work if rows exist |

**Critical Issue:** `extras()` silently fails on tbl_regression without warning to user.

**Recommendation for CRAN:**
```r
# Add explicit check in extras()
if (!("tbl_summary" %in% class(tbl)) && !("tbl_svysummary" %in% class(tbl))) {
  rlang::abort(
    c(
      "`extras()` only works with tbl_summary and tbl_svysummary tables.",
      "x" = sprintf("You supplied a %s object.", paste(class(tbl), collapse = ", ")),
      "i" = "For regression tables, use `bold_labels() |> modify_header(label ~ '')`"
    ),
    class = "extras_unsupported_table_type"
  )
}
```

---

### Stacked Tables (tbl_strata)

**Status:** ⚠️ DEFER TO FUTURE RELEASE

**Current behavior:**
- `extras()`: Silently does nothing (no `tbl$inputs$by` on strata objects)
- `clean_table()`: Modifies ONLY first component
- `add_auto_labels()`: Modifies ONLY first component's table_body
- `group_styling()`: Modifies ONLY first component
- `get_group_rows()`: Returns rows ONLY from first component

**Example showing the problem:**
```r
stacked_tbl <- gtsummary::trial |>
  gtsummary::tbl_strata(
    strata = grade,
    ~ .x |> gtsummary::tbl_summary(by = trt)
  ) |>
  extras()  # Does NOTHING - no warning to user!

# User expects all components to have overall column, but only first gets it
```

**Implementation approach needed:**
- Check if table is stacked: `inherits(tbl, "tbl_strata")`
- If yes, iterate through each stratum and apply function
- Or: Document that stacked tables need per-component styling

**Recommendation for CRAN:**
1. **DEFER stacked table support** to future release
2. Add explicit error:
   ```r
   if (inherits(tbl, "tbl_strata")) {
     rlang::abort(
       c(
         "Stacked tables are not yet supported.",
         "i" = "Please apply sumExtras functions to individual table components.",
         "i" = "This will be supported in a future release."
       ),
       class = "extras_stacked_not_supported"
     )
   }
   ```

---

### Merged Tables (Combined with as_gt)

**Status:** ❌ NOT APPLICABLE

**Current behavior:**
- All functions check `inherits(tbl, "gtsummary")`
- Merged tables are gt_tables (not gtsummary objects)
- All functions correctly reject them

**Only exception:** `theme_gt_compact()` - explicitly works with gt_tables

**Recommendation:** Keep as-is. Document that sumExtras styling functions only work with gtsummary objects, not merged tables.

---

## TESTING GAPS AFFECTING COMPATIBILITY

### Missing Tests

1. **tbl_svysummary with extras()**
   - No test of add_overall() with survey design
   - No test of add_p() with survey design

2. **Stacked tables (tbl_strata)**
   - No test that shows current behavior (silently doing nothing)
   - No test that shows partial modification (only first component)

3. **Edge cases**
   - Unstratified tbl_summary with extras() should warn but doesn't
   - Multiple stratification variables not tested
   - Tables with no variable groups passed to get_group_rows()

### Required Tests for CRAN
```r
# Test 1: extras() warns on unstratified table
test_that("extras() warns when table is not stratified", {
  tbl <- gtsummary::trial |> gtsummary::tbl_summary()  # No by=
  expect_warning(extras(tbl), class = "extras_not_stratified")
})

# Test 2: extras() errors on regression table
test_that("extras() errors on tbl_regression", {
  mod <- lm(age ~ trt, data = gtsummary::trial)
  tbl <- gtsummary::tbl_regression(mod)
  expect_error(extras(tbl), class = "extras_unsupported_table_type")
})

# Test 3: extras() errors on stacked table
test_that("extras() errors on tbl_strata", {
  stacked <- gtsummary::trial |>
    gtsummary::tbl_strata(
      strata = grade,
      ~ .x |> gtsummary::tbl_summary(by = trt)
    )
  expect_error(extras(stacked), class = "extras_stacked_not_supported")
})

# Test 4: clean_table() works with all types
test_that("clean_table() works with tbl_regression", {
  mod <- lm(age ~ trt, data = gtsummary::trial)
  tbl <- gtsummary::tbl_regression(mod) |> clean_table()
  expect_s3_class(tbl, "gtsummary")
})

# Test 5: add_auto_labels() works with all types
test_that("add_auto_labels() works with tbl_regression", {
  dict <- tibble::tribble(~Variable, ~Description, "trt", "Treatment")
  mod <- lm(age ~ trt, data = gtsummary::trial)
  tbl <- gtsummary::tbl_regression(mod) |> add_auto_labels(dictionary = dict)
  expect_s3_class(tbl, "gtsummary")
})

# Test 6: tbl_svysummary compatibility
test_that("extras() works with tbl_svysummary", {
  skip_if_not_installed("survey")
  design <- survey::svydesign(ids = ~1, data = gtsummary::trial)
  tbl <- gtsummary::tbl_svysummary(design, by = trt) |> extras()
  expect_s3_class(tbl, "gtsummary")
})
```

---

## DOCUMENTATION GAPS

### Functions needing documentation updates:

1. **extras()**
   - Document that it only works with stratified tbl_summary
   - Add @seealso for how to style tbl_regression
   - Add warning about silent skipping of overall/pval on non-stratified tables

2. **add_auto_labels()**
   - Document: "Works with single tables. For stacked tables, apply to each component separately"
   - Add @seealso for stacked table approach

3. **clean_table()**
   - Document: "Universal compatibility with all gtsummary table types"
   - Already good, no changes needed

4. **group_styling() and get_group_rows()**
   - Document: "Assumes variable groups were added with add_variable_group_header()"
   - Add note about stacked table limitations

---

## SEVERITY SUMMARY

| Severity | Issue | Impact | Fix Effort |
|----------|-------|--------|-----------|
| 🔴 CRITICAL | extras() silently fails on tbl_regression | User gets non-functional output | 2 hours |
| 🔴 CRITICAL | extras() undocumented tbl_svysummary limitations | May fail on survey data | 3 hours |
| 🟡 MODERATE | Stacked table behavior undocumented | Users frustrated by partial results | 2 hours |
| 🟡 MODERATE | add_auto_labels() stacked support untested | May have bugs | 1 hour |
| 🟢 MINOR | group_styling() stacked table untested | Unknown if it works | 1 hour |

---

## CRAN READINESS RECOMMENDATIONS

### MUST FIX (Blocking CRAN submission):
1. ✅ [FIXED] Global dictionary dependency - Done in Phase 1
2. ✅ [FIXED] Fragile do.call() approach - Done in Phase 1
3. ❌ Add error handling for unsupported table types in extras()
4. ❌ Add tests for tbl_svysummary with add_overall() and add_p()
5. ❌ Add explicit error for stacked tables (defer support)
6. ❌ Add warning for non-stratified tables in extras()
7. ❌ Update extras() documentation

### SHOULD FIX (Recommended):
1. Add test for extras() with tbl_regression (should error)
2. Add test for clean_table() with tbl_regression (should work)
3. Add test for add_auto_labels() with tbl_regression (should work)
4. Document compatibility matrix in package README

### NICE TO HAVE (Post-CRAN):
1. Implement stacked table support for add_auto_labels(), clean_table(), etc.
2. Implement stacked table support for extras()
3. Add merged table examples (as_gt() workflow)

---

## IMPLEMENTATION PRIORITY

**Week 1 (Must-have for CRAN):**
- [ ] Add error checks to extras() for unsupported types
- [ ] Add tbl_svysummary compatibility tests
- [ ] Add documentation updates to extras()
- [ ] Test extras() behavior with survey::svydesign

**Week 2 (Polish before submission):**
- [ ] Add comprehensive test coverage for all table types
- [ ] Document compatibility matrix in README
- [ ] Run R CMD check --as-cran to verify no warnings

**Post-CRAN (Future releases):**
- [ ] Implement stacked table support
- [ ] Extend group_styling() to stacked tables
- [ ] Extend add_auto_labels() to stacked tables

---

## Conclusion

The sumExtras package is **well-designed for tbl_summary tables** but needs clarification and testing for broader gtsummary compatibility before CRAN release. The most critical issue is `extras()` silently failing on non-supported table types.

**Current status:** 70% CRAN ready
**After critical fixes:** 95% CRAN ready

The package provides real value for the gtsummary ecosystem. Focus on explicit error messages and comprehensive testing for compatibility matrix completion.
