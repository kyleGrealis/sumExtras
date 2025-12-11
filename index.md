# sumExtras

> *Some extras for gtsummary tables*

## Overview

**sumExtras** provides convenience functions for gtsummary and gt
tables, including automatic variable labeling from dictionaries,
standardized missing value display, and consistent formatting helpers
for streamlined table styling workflows.

## Installation

### CRAN

``` r
install.packages("sumExtras")
```

### Development version

You can install the development version of sumExtras from GitHub:

``` r
# install.packages("pak")
pak::pak("kyleGrealis/sumExtras")
```

Alternatively, using remotes:

``` r
# install.packages("remotes")
remotes::install_github("kyleGrealis/sumExtras")
```

## See the Difference

[TABLE]

Both produce identical output, but
[`extras()`](https://kyleGrealis.com/sumExtras/reference/extras.md)
requires significantly less code and ensures consistency across your
analysis.

## Quick Start

``` r
library(sumExtras)
library(gtsummary)

# Apply the recommended JAMA theme (optional but recommended)
use_jama_theme()

# The extras() function - does it all!
trial |>
  tbl_summary(by = trt) |>
  extras()  # Adds overall, p-values, cleans missing values, and more!

# Clean missing values independently
trial |>
  tbl_summary(by = trt) |>
  clean_table()  # Standardizes missing/zero displays to "---"

# With automatic labels from your dictionary
# First, create a dictionary with Variable and Description columns
dictionary <- tibble::tribble(
  ~Variable, ~Description,
  "age", "Age at Enrollment",
  "marker", "Marker Level (ng/mL)",
  "trt", "Treatment Group",
  "grade", "Tumor Grade"
)

trial |>
  tbl_summary(by = trt) |>
  add_auto_labels() |>  # Automatically finds 'dictionary' in your environment
  extras()
```

## What’s Included

- [`extras()`](https://kyleGrealis.com/sumExtras/reference/extras.md) -
  The signature function that adds overall columns, p-values, and clean
  styling
- [`clean_table()`](https://kyleGrealis.com/sumExtras/reference/clean_table.md) -
  Standardizes missing value display
- [`add_auto_labels()`](https://kyleGrealis.com/sumExtras/reference/add_auto_labels.md) -
  Smart automatic variable labeling from dictionaries or label
  attributes
- [`apply_labels_from_dictionary()`](https://kyleGrealis.com/sumExtras/reference/apply_labels_from_dictionary.md) -
  Set label attributes on data for cross-package workflows (ggplot2, gt,
  etc.)
- [`use_jama_theme()`](https://kyleGrealis.com/sumExtras/reference/use_jama_theme.md) -
  Apply JAMA compact theme to gtsummary tables
- [`theme_gt_compact()`](https://kyleGrealis.com/sumExtras/reference/theme_gt_compact.md) -
  JAMA-style compact themes for gt tables
- [`group_styling()`](https://kyleGrealis.com/sumExtras/reference/group_styling.md) -
  Enhanced formatting for grouped tables with customizable indentation
- [`get_group_rows()`](https://kyleGrealis.com/sumExtras/reference/get_group_rows.md) -
  Extract group row information from grouped tables

### How Labels Work

The labeling functions use the same native R attribute approach as
popular packages like **haven**, **Hmisc**, and **ggplot2 4.0+**. Labels
are stored as simple `'label'` attributes on data columns—no special
packages or formats required.

Your data may already have labels from various sources:  
- Imported datasets (haven reads SPSS/Stata/SAS labels automatically)  
- Other packages that set label attributes  
- Manual labeling with `attr(data$column, "label") <- "Label"`  
- Collaborative projects with pre-labeled data

The
[`add_auto_labels()`](https://kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
function intelligently reads both dictionary-based labels and existing
label attributes from your data, letting you choose which takes
precedence. Labels work seamlessly across the entire R
ecosystem—compatible with **gtsummary**, **ggplot2**, **gt**, and other
label-aware packages.

## Table Type Support

The [`extras()`](https://kyleGrealis.com/sumExtras/reference/extras.md)
function is designed to work with all gtsummary table types using a
“warn-and-continue” philosophy:  
\* It applies all compatible features to your table  
\* For unsupported features, it issues a helpful warning and continues
with what works  
\* **The function always succeeds** - it never breaks your pipeline

### Feature Support by Table Type

| Table Type                  | bold_labels | modify_header | add_overall | add_p | Status          |
|-----------------------------|:-----------:|:-------------:|:-----------:|:-----:|-----------------|
| tbl_summary (stratified)    |     ✅      |      ✅       |     ✅      |  ✅   | Full support    |
| tbl_summary (unstratified)  |     ✅      |      ✅       |     ⚠️      |  ⚠️   | Partial support |
| tbl_svysummary (stratified) |     ✅      |      ✅       |     ✅      |  ✅   | Full support    |
| tbl_regression              |     ✅      |      ✅       |     ⚠️      |  ⚠️   | Partial support |
| tbl_strata                  |     ✅      |      ✅       |     ⚠️      |  ⚠️   | Partial support |

**Legend:**  
\* ✅ Feature works and is applied  
\* ⚠️ Feature not applicable to this table type (function warns but
continues)

### How It Works

When you call
[`extras()`](https://kyleGrealis.com/sumExtras/reference/extras.md) on
any table:

1.  **Always applied:** Bold labels and clean headers  
2.  **Conditionally applied:** Overall column and p-values (only on
    stratified summary tables)  
3.  **On unsupported features:** You’ll see a warning, but the function
    completes successfully

Example with an unstratified table:

``` r
trial |>
  tbl_summary() |>  # No 'by' argument = unstratified
  extras()  # Warns that overall/p-values aren't supported, but still bolds labels and cleans headers
```

You’ll see a warning like: “This table is not stratified. Overall column
and p-values require stratification. Applying only bold_labels() and
modify_header().” - but your table is still successfully formatted!

## The Name

**sumExtras** = “**SUM**mary table **EXTRAS**” + “**SOME EXTRAS** for
gt**SUMMARY**”

Get it?

## Getting Help

- **Bug reports & feature requests**:
  <https://github.com/kyleGrealis/sumExtras/issues>
- **Documentation**: See the package vignette with
  [`vignette("sumExtras-intro")`](https://kyleGrealis.com/sumExtras/articles/sumExtras-intro.md)
- **Function help**:
  - [`?extras`](https://kyleGrealis.com/sumExtras/reference/extras.md)  
  - [`?clean_table`](https://kyleGrealis.com/sumExtras/reference/clean_table.md)  
  - [`?add_auto_labels`](https://kyleGrealis.com/sumExtras/reference/add_auto_labels.md)  
  - [`?group_styling`](https://kyleGrealis.com/sumExtras/reference/group_styling.md)
  - [`?use_jama_theme`](https://kyleGrealis.com/sumExtras/reference/use_jama_theme.md)  
- **Examples**: Run `example(extras)` for quick demos

------------------------------------------------------------------------

## Testing & Quality

sumExtras is thoroughly tested with:

- 245 test assertions across 7 comprehensive test suites
- Tests covering all core functions and edge cases
- Comprehensive test suites for:
  - Main extras functionality (`test-extras.R`,
    `test-extras-warnings.R`)
  - Table cleaning and missing value handling (`test-clean_table.R`,
    `test-clean_table-regex.R`)
  - Automatic label creation and application (`test-labels.R`) - **51
    tests** covering:
    - Dictionary auto-discovery and session messaging
    - Label priority logic (manual \> attributes \> dictionary)
    - Comprehensive error validation with informative error classes
    - Edge cases (NA values, empty/single-row data, long labels)
    - All 9 vignette workflow scenarios
    - Performance with large dictionaries (1000+ entries) and wide data
  - JAMA theme styling (`test-use_jama_theme.R`)
  - Grouped table formatting (`test-styling.R`)

All tests pass with 100% success rate. See the [tests
directory](https://github.com/kyleGrealis/sumExtras/tree/main/tests/testthat)
for detailed test examples and patterns.

------------------------------------------------------------------------

## Upcoming Features

We’re constantly improving sumExtras. Upcoming feature considerations
include:

- Additional gtsummary table type support (tbl_uvregression,
  tbl_logistic)  
- More compact theme options for different journals and styles  
- Enhanced dictionary labeling features with validation  
- Advanced row grouping and styling customization

------------------------------------------------------------------------

## Contributing

We welcome contributions and ideas! Here’s how you can help:

- **Report bugs** - [Open an
  issue](https://github.com/kyleGrealis/sumExtras/issues) with a clear
  description  
- **Suggest features** - Have an idea? [Submit a feature
  request](https://github.com/kyleGrealis/sumExtras/issues)  
- **Share feedback** - Let us know how sumExtras is working for you  
- **Improve documentation** - Help us make docs clearer and more
  complete

------------------------------------------------------------------------

## License

sumExtras is licensed under the [MIT
License](https://github.com/kyleGrealis/sumExtras/blob/main/LICENSE).
See the LICENSE file for details.

------------------------------------------------------------------------

## Acknowledgments

sumExtras is built with love using R and these amazing packages:

- [gtsummary](https://www.danieldsjoberg.com/gtsummary/) - Easily create
  publication-ready analytical tables  
- [gt](https://gt.rstudio.com/) - The grammar of tables for R  
- [dplyr](https://dplyr.tidyverse.org/) - Data manipulation and
  transformation  
- [rlang](https://rlang.r-lib.org/) - Low-level programming tools for
  R  
- [purrr](https://purrr.tidyverse.org/) - Functional programming tools

------------------------------------------------------------------------

**Developed by [Kyle Grealis](https://github.com/kyleGrealis)**

sumExtras adds some extras to your summary tables! ✨
