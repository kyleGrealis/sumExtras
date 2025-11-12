
# sumExtras <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->

> *Some extras for gtsummary tables*

<!-- badges: end -->

## Overview

**sumExtras** provides convenience functions for gtsummary and gt tables, including automatic variable labeling from dictionaries, standardized missing value display, and consistent formatting helpers for streamlined table styling workflows.

## Installation

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

## The Name

**sumExtras** = "**SUM**mary table **EXTRAS**" + "**SOME EXTRAS** for gt**SUMMARY**"

Get it?
