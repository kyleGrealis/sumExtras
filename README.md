
# sumExtras <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->

> *Some extras for gtsummary tables* 📊

[![R-CMD-check](https://github.com/yourusername/sumExtras/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/yourusername/sumExtras/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

The goal of sumExtras is to ...

## Installation

You can install the development version of sumExtras like so:

``` r
remotes::install_github("kyleGrealis/sumExtras")
```

## Quick Start

```r
library(sumExtras)
library(gtsummary)

# The extras() function - does it all!
trial |> 
  tbl_summary(by = trt) |> 
  extras()  # Adds overall, p-values, cleans missing values, and more!

# With automatic labels from your dictionary
trial |> 
  tbl_summary(by = trt) |> 
  add_auto_labels() |>  # Requires a 'dictionary' object
  extras()
```

## What's Included

- `extras()` - The signature function that adds overall columns, p-values, and clean styling
- `clean_table()` - Standardizes missing value display  
- `add_auto_labels()` - Automatic variable labeling from dictionaries
- `theme_gt_compact()` - JAMA-style compact themes for gt tables
- `group_styling()` - Enhanced formatting for grouped tables

## The Name

**sumExtras** = "**SUM**mary table **EXTRAS**" + "**SOME EXTRAS** for gt**SUMMARY**" 

Get it? 😉
