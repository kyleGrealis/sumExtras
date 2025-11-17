# sumExtras 0.1.1 (development version)

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
* `add_auto_labels()` now supports `tbl_regression` and `tbl_uvregression` objects in addition to `tbl_summary` objects, enabling automatic variable labeling for regression tables from dictionary files (55bc540)
* `add_auto_labels()` now automatically searches the calling environment for a
  `dictionary` object when no dictionary is explicitly provided
* `add_auto_labels()` can now read label attributes directly from data as a
  fallback when no dictionary is found, enabling seamless integration with
  {haven}, {labelled}, and other packages that set label attributes
* `add_auto_labels()` implements a smart label priority hierarchy: Manual labels
  (set via `label = list()` in `tbl_summary()`) always take precedence, followed
  by dictionary/attribute labels (based on `sumExtras.preferDictionary` option),
  then default variable names
* Added `apply_labels_from_dictionary()` function to set label attributes on
  data from a dictionary, enabling cross-package workflows with ggplot2 4.0+
  automatic axis labeling, gt, and other label-aware packages
* Added `options(sumExtras.preferDictionary)` to control label priority when
  both dictionary and attribute labels are available. Default is `FALSE`
  (attributes preferred over dictionary)
* `group_styling()` gains an `indent_labels` parameter (default `0L`) to control
  indentation of variable labels under group headers. Set to `4L` to preserve
  gtsummary's default group indentation behavior
* `extras()` gains a `last` parameter to control Overall column position (default `FALSE` aligns with `gtsummary::add_overall()` behavior)
* `extras()` gains a `.args` parameter to accept a list of arguments, allowing programmatic control of `pval`, `overall`, and `last` parameters

## Minor Improvements and Bug Fixes

* `add_auto_labels()` now gracefully handles missing dictionaries by falling
  back to label attributes instead of erroring, improving robustness in
  workflows where dictionary availability varies
* Fixed missing import of `gtsummary::all_tests()` in `extras()` function
* Improved regex pattern in `clean_table()` to avoid false positives (e.g., matching `"..."` or `"   "`)
* `extras()` now warns when `add_overall()` or `add_p()` fail instead of silently continuing
* Fixed `modify_indent()` column parameter in `group_styling()` - column name now properly quoted as "label" to ensure correct indentation when rendering vignettes in pkgdown
* Enhanced `extras()` to warn when called with unsupported table types (tbl_regression, tbl_strata, non-stratified tables) instead of silently skipping features
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
* Added `extras()` function for streamlined gtsummary table styling
* Added `clean_table()` for standardized missing value display
* Added `add_auto_labels()` and `create_labels()` for automatic variable labeling
* Added `theme_gt_compact()` for JAMA-style gt table themes
* Added `group_styling()` for enhanced group header formatting
