# sumExtras 1.0.0 (2026-02-09)

## Breaking Changes

* Removed `apply_labels_from_dictionary()`. Use `attr(data$var, "label") <- "Label"` directly, or the `{labelled}` package for bulk attribute labeling.

## New Features

* `extras()` auto-labeling via `options(sumExtras.auto_labels = TRUE)` and (recommended) `options(sumExtras.prefer_dictionary = TRUE)`. See `vignette("options")`.
* `extras()` now bolds significant p-values (`bold_p()`) automatically when p-values are added.
* New `header` parameter in `extras()` controls the label column header text (default `""`).
* New `symbol` parameter in `clean_table()` and `extras()` controls the missing value replacement string (default `"---"`).
* `add_group_colors()` now accepts a vector of colors (one per group) in addition to a single color for all groups.

## Improvements

* Data dictionaries now use lowercase column names (`variable`, `description`) by convention. Title-case names (`Variable`, `Description`) still work — column matching is case-insensitive.
* `extras()` now handles `tbl_regression` gracefully: `overall` and `pval` are silently ignored (regression tables already have model p-values), and `bold_p()` is applied automatically. No more warnings when using `extras()` with default arguments on regression tables.
* Removed startup message. The package now loads silently.
* Dropped `{purrr}` from Imports (4 dependencies instead of 5).
* New vignettes: `vignette("options")` and `vignette("themes")`.

# sumExtras 0.3.1 (2026-01-22)

## Improvements

* Added `quiet = TRUE` default to `use_jama_theme()` to suppress messages from {gtsummary} and {sumExtras}. Resolves issue #12 (thank you @RaymondBalise).

* `extras()` no longer warns when called with default arguments on non-stratified tables. Previously, calling `extras(tbl)` on a table without a `by` argument would warn even though the user didn't explicitly request `overall` or `pval` features. Now warnings only fire when users **explicitly** request features that can't be applied:
  * `extras(non_stratified_tbl)` - Silent (applies basic formatting)
  * `extras(non_stratified_tbl, overall = TRUE)` - Warns (user explicitly requested)
  * `extras(non_stratified_tbl, pval = TRUE)` - Warns (user explicitly requested)

# sumExtras 0.3.0 (2026-01-15)

## New Features

* New `.add_p_args` argument to `extras()` allows for passing `gtsummary::add_p()` arguments, such as:
  * `test` for specifying statistical tests for each variable (i.e., `"t.test"`, `"fisher.test"`). Thank you, Daniel Maya.
  * `pvalue_fun` for formatting p-values
  * `group`, `include`, etc.
  * See `?gtsummary::add_p.tbl_summary` for more information of proper usage.

## Improvements

* Extended list of zero or `NA` value recognition used by `clean_table`. This fixes the function previously not recognizing `0 (0)` for Mean (SD).

# sumExtras 0.2.0 (2026-01-05)

## Breaking Changes

* `group_styling()` renamed to `add_group_styling()` to follow gtsummary's `add_*()` naming convention

## New Features

* New `add_group_colors()` function provides a clean, pipeable way to add background colors to group headers
  * Combines text formatting, gt conversion, and color application in one step
  * Eliminates need for manual `get_group_rows()` and `as_gt()` calls
  * Reduces typical styling code from 20+ lines to ~11 lines

## Documentation

* Updated all examples and vignettes to use new function names
* Improved README with cleaner side-by-side comparison showcasing the new API
* Added `add_group_colors()` section to styling vignette with side-by-side manual vs. convenience pattern comparison
* Updated all function references across documentation

# sumExtras 0.1.1 (2025-11-15)

## Bug Fixes

* `clean_table()` now correctly handles additional percentage formats including
  `0% (0.000)` and `0.00% (0.00)`, which were previously not being converted to
  dashes
* `apply_labels_from_dictionary()` improved with clearer implementation using
  traditional for-loop instead of confusing `<<-` side-effect assignment

## Improvements

* Removed stringr dependency by replacing `str_detect()` with base R `grepl(..., perl = TRUE)`,
  reducing package dependency footprint
* Replaced `purrr::walk2()` with traditional for-loop in `apply_labels_from_dictionary()`
  for improved code clarity and maintainability

## Documentation

* Added package-level documentation (`sumExtras-package`) with notes about
  dependency on gtsummary internal structures and minimum version requirements
* Enhanced `add_auto_labels()` documentation with implementation notes about
  gtsummary internals
* Added Fisher test documentation in `extras()` explaining why Monte Carlo
  simulation is used
* Created CITATION file for proper package attribution

## Testing

* Added unicode and emoji test to verify label handling of special characters
  (emoji, Greek letters, symbols)
* Updated all regex tests to use base R `grepl()` instead of stringr

# sumExtras 0.1.0 (2025-11-15)

## Breaking Changes

* Removed automatic JAMA compact theme setting on package load to comply with CRAN policies
* Package no longer modifies global gtsummary theme automatically when loaded
* `create_labels()` has been deprecated and removed. Users should migrate to
  `add_auto_labels()` instead. Migration example: Instead of
  `tbl_summary(label = create_labels(data, dict))`, use
  `tbl_summary() |> add_auto_labels(dict)`.

## New Features

* Added `use_jama_theme()` function for explicit JAMA compact theme application
* Users can now opt-in to the recommended JAMA theme by calling `use_jama_theme()`
* `add_auto_labels()` now supports `tbl_regression` and `tbl_uvregression` objects in addition to `tbl_summary` objects (55bc540)
* `add_auto_labels()` now automatically searches the calling environment for a
  `dictionary` object when no dictionary is explicitly provided
* `add_auto_labels()` can now read label attributes directly from data as a
  fallback when no dictionary is found, so it works with {haven}, {labelled},
  and other packages that set label attributes
* `add_auto_labels()` uses a fixed label priority: manual labels (from
  `label = list()`) take precedence, then attribute labels, then dictionary
  labels, then variable names
* Added `apply_labels_from_dictionary()` function to set label attributes on
  data from a dictionary for use with ggplot2 4.0+, gt, and other
  label-aware packages
* Label priority is fixed: manual labels > attribute labels > dictionary labels
* `group_styling()` gains an `indent_labels` parameter (default `0L`) to control
  indentation of variable labels under group headers. Set to `4L` to preserve
  gtsummary's default group indentation behavior
* `extras()` gains a `last` parameter to control Overall column position (default `FALSE` aligns with `gtsummary::add_overall()` behavior)
* `extras()` gains a `.args` parameter to accept a list of arguments, allowing programmatic control of `pval`, `overall`, and `last` parameters

## Minor Improvements and Bug Fixes

* `add_auto_labels()` now falls back to label attributes when no dictionary
  is found instead of erroring
* Fixed missing import of `gtsummary::all_tests()` in `extras()` function
* Improved regex pattern in `clean_table()` to avoid false positives (e.g., matching `"..."` or `"   "`)
* `extras()` now warns when `add_overall()` or `add_p()` fail instead of silently continuing
* Fixed `modify_indent()` column parameter in `group_styling()` - column name now properly quoted as "label" to ensure correct indentation when rendering vignettes in pkgdown
* `extras()` now warns when called with unsupported table types (tbl_regression, tbl_strata, non-stratified tables) instead of silently skipping features
* Fixed `clean_table()` handling of `tbl_strata` objects by detecting when `var_type` column is missing

## Performance Improvements

* Optimized `add_auto_labels()` to avoid double iteration when extracting variable names and labels

## Documentation

* Updated README with `use_jama_theme()` usage in Quick Start
* Updated vignette with new theme management section
* Added `use_jama_theme()` to function reference list
* Improved documentation formatting across all functions

# sumExtras 0.0.0.9000 (development version)

* Initial development release of sumExtras
* Added `extras()` function for one-call gtsummary table styling
* Added `clean_table()` for standardized missing value display
* Added `add_auto_labels()` and `create_labels()` for automatic variable labeling
* Added `theme_gt_compact()` for JAMA-style gt table themes
* Added `group_styling()` for group header formatting
