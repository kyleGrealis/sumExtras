# Changelog

## sumExtras 0.1.0 (2025-11-15)

### Breaking Changes

- Removed automatic JAMA compact theme setting on package load to comply
  with CRAN policies
- Package no longer modifies global gtsummary theme automatically when
  loaded

### New Features

- Added
  [`use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
  function for explicit JAMA compact theme application
- Users can now opt-in to the recommended JAMA theme by calling
  [`use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
- [`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
  now supports `tbl_regression` and `tbl_uvregression` objects in
  addition to `tbl_summary` objects, enabling automatic variable
  labeling for regression tables from dictionary files (55bc540)
- [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  gains a `last` parameter to control Overall column position (default
  `FALSE` aligns with
  [`gtsummary::add_overall()`](https://www.danieldsjoberg.com/gtsummary/reference/add_overall.html)
  behavior)
- [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  gains a `.args` parameter to accept a list of arguments, allowing
  programmatic control of `pval`, `overall`, and `last` parameters

### Bug Fixes

- Fixed missing import of
  [`gtsummary::all_tests()`](https://www.danieldsjoberg.com/gtsummary/reference/select_helpers.html)
  in
  [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  function
- Improved regex pattern in
  [`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
  to avoid false positives (e.g., matching `"..."` or `" "`)
- [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  now warns when
  [`add_overall()`](https://www.danieldsjoberg.com/gtsummary/reference/add_overall.html)
  or
  [`add_p()`](https://www.danieldsjoberg.com/gtsummary/reference/add_p.html)
  fail instead of silently continuing
- Fixed
  [`modify_indent()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_indent.html)
  column parameter in
  [`group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/group_styling.md) -
  column name now properly quoted as “label” to ensure correct
  indentation when rendering vignettes in pkgdown
- Enhanced
  [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  to warn when called with unsupported table types (tbl_regression,
  tbl_strata, non-stratified tables) instead of silently skipping
  features
- Fixed
  [`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
  handling of `tbl_strata` objects by detecting when `var_type` column
  is missing

### Performance Improvements

- Optimized
  [`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
  to avoid double iteration when extracting variable names and labels

### Documentation

- Updated README with
  [`use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
  usage in Quick Start
- Updated vignette with new theme management section
- Added
  [`use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
  to function reference list
- Improved documentation formatting across all functions

## sumExtras 0.0.0.9000 (development version)

- Initial development release of sumExtras
- Added
  [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  function for streamlined gtsummary table styling
- Added
  [`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
  for standardized missing value display
- Added
  [`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
  and
  [`create_labels()`](https://www.kyleGrealis.com/sumExtras/reference/create_labels.md)
  for automatic variable labeling
- Added
  [`theme_gt_compact()`](https://www.kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)
  for JAMA-style gt table themes
- Added
  [`group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/group_styling.md)
  for enhanced group header formatting
