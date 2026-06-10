# Apply compact JAMA-style theme to gt tables

Applies a compact table theme to gt tables that matches the 'jama' theme
from gtsummary, so gtsummary and plain gt tables look the same in one
document. Reduces padding, adjusts font sizes, and applies JAMA journal
styling.

## Usage

``` r
theme_gt_compact(tbl)
```

## Arguments

- tbl:

  A gt table object created with
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html)

## Value

A gt table object with compact JAMA-style formatting applied

## Details

This function replicates the visual appearance of
`gtsummary::theme_gtsummary_compact("jama")` for use with regular gt
tables. Key styling includes:

- Reduced font size (13px) for compact appearance

- Minimal padding (1px) on all row types

- Bold column headers and table titles

- Hidden top and bottom table borders

- Consistent spacing that matches JAMA journal standards

## See also

- [`sumExtras::use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
  for complimentary table styling

- [`gt::tab_options()`](https://gt.rstudio.com/reference/tab_options.html)
  for additional gt table styling options

## Examples

``` r
# Basic usage with a data frame
mtcars |>
  head() |>
  gt::gt() |>
  theme_gt_compact()


  

mpg
```
