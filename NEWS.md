# sumExtras 0.0.1.9002 (development version)

## Breaking Changes

* Removed automatic JAMA compact theme setting on package load to comply with CRAN policies
* Package no longer modifies global gtsummary theme automatically when loaded

## New Features

* Added `use_jama_theme()` function for explicit JAMA compact theme application
* Users can now opt-in to the recommended JAMA theme by calling `use_jama_theme()`
* `add_auto_labels()` now supports `tbl_regression` and `tbl_uvregression` objects in addition to `tbl_summary` objects, enabling automatic variable labeling for regression tables from dictionary files (55bc540)
* `extras()` gains a `last` parameter to control Overall column position (default `FALSE` aligns with `gtsummary::add_overall()` behavior)
* `extras()` gains a `.args` parameter to accept a list of arguments, allowing programmatic control of `pval`, `overall`, and `last` parameters

## Bug Fixes

* Fixed missing import of `gtsummary::all_tests()` in `extras()` function
* Improved regex pattern in `clean_table()` to avoid false positives (e.g., matching `"..."` or `"   "`)
* `extras()` now warns when `add_overall()` or `add_p()` fail instead of silently continuing

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