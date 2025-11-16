
# sumExtras <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->

> *Some extras for gtsummary tables*

<!-- badges: end -->

## Overview

**sumExtras** provides convenience functions for gtsummary and gt tables, including automatic variable labeling from dictionaries, standardized missing value display, and consistent formatting helpers for streamlined table styling workflows.

## Installation

### CRAN (after acceptance)

Once accepted to CRAN, install with:

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

## Quick Start

```r
library(sumExtras)
library(gtsummary)

# Apply the recommended JAMA theme (optional but recommended)
use_jama_theme()

# The extras() function - does it all!
trial |>
  tbl_summary(by = trt) |>
  extras()  # Adds overall, p-values, cleans missing values, and more!

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
  add_auto_labels() |>
  extras()
```

## What's Included

- `extras()` - The signature function that adds overall columns, p-values, and clean styling
- `clean_table()` - Standardizes missing value display
- `add_auto_labels()` - Automatic variable labeling from dictionaries
- `create_labels()` - Create a list of variable labels from a dataset using a dictionary
- `use_jama_theme()` - Apply JAMA compact theme to gtsummary tables
- `theme_gt_compact()` - JAMA-style compact themes for gt tables
- `group_styling()` - Enhanced formatting for grouped tables
- `get_group_rows()` - Extract group row information from grouped tables

## Table Type Support

The `extras()` function is designed to work with all gtsummary table types using a "warn-and-continue" philosophy:
- It applies all compatible features to your table
- For unsupported features, it issues a helpful warning and continues with what works
- **The function always succeeds** - it never breaks your pipeline

### Feature Support by Table Type

| Table Type | bold_labels | modify_header | add_overall | add_p | Status |
|------------|:-----------:|:-------------:|:-----------:|:-----:|--------|
| tbl_summary (stratified) | ✅ | ✅ | ✅ | ✅ | Full support |
| tbl_summary (unstratified) | ✅ | ✅ | ⚠️ | ⚠️ | Partial support |
| tbl_svysummary (stratified) | ✅ | ✅ | ✅ | ✅ | Full support |
| tbl_regression | ✅ | ✅ | ⚠️ | ⚠️ | Partial support |
| tbl_strata | ✅ | ✅ | ⚠️ | ⚠️ | Partial support |

**Legend:**
- ✅ Feature works and is applied
- ⚠️ Feature not applicable to this table type (function warns but continues)

### How It Works

When you call `extras()` on any table:

1. **Always applied:** Bold labels and clean headers
2. **Conditionally applied:** Overall column and p-values (only on stratified summary tables)
3. **On unsupported features:** You'll see a warning, but the function completes successfully

Example with an unstratified table:
```r
trial |>
  tbl_summary() |>  # No 'by' argument = unstratified
  extras()  # Warns that overall/p-values aren't supported, but still bolds labels and cleans headers
```

You'll see a warning like: "This table is not stratified. Overall column and p-values require stratification. Applying only bold_labels() and modify_header()." - but your table is still successfully formatted!

## The Name

**sumExtras** = "**SUM**mary table **EXTRAS**" + "**SOME EXTRAS** for gt**SUMMARY**"

Get it?

## Getting Help

- **Bug reports & feature requests**: <https://github.com/kyleGrealis/sumExtras/issues>
- **Documentation**: See the package vignette with `vignette("sumExtras-intro")` or use `?sumExtras` for help
- **Examples**: Run `example(extras)` for quick demos of the main functions
