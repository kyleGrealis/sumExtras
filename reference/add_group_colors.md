# Add background colors to group headers with automatic gt conversion

Convenience function that adds background colors to variable group
headers and converts the table to gt. This is a terminal operation that
combines
[`get_group_rows()`](https://www.kyleGrealis.com/sumExtras/reference/get_group_rows.md),
[`gtsummary::as_gt()`](https://www.danieldsjoberg.com/gtsummary/reference/as_gt.html),
and [`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)
into a single pipeable function.

For text formatting (bold/italic), use
[`add_group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_styling.md)
before calling this function.

## Usage

``` r
add_group_colors(tbl, color = "#E8E8E8")
```

## Arguments

- tbl:

  A gtsummary table object with variable group headers created by
  [`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)

- color:

  Background color(s) for group headers. Default `"#E8E8E8"` (light
  gray). Accepts a single color (applied to all groups) or a vector of
  colors (one per group). Can be any valid CSS color (hex code, color
  name, rgb(), etc.).

## Value

A gt table object with colored group headers. **Note:** This is a
terminal operation that converts to gt. You cannot pipe to additional
gtsummary functions after calling this function.

## Details

This function:

1.  Identifies group header rows with
    [`get_group_rows()`](https://www.kyleGrealis.com/sumExtras/reference/get_group_rows.md)

2.  Converts the table to gt with
    [`gtsummary::as_gt()`](https://www.danieldsjoberg.com/gtsummary/reference/as_gt.html)

3.  Applies background color using
    [`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)

Since this function converts to gt, it should be used as the final
styling step in your pipeline. Apply all gtsummary functions (like
[`modify_caption()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_caption.html),
[`modify_footnote()`](https://www.danieldsjoberg.com/gtsummary/reference/deprecated_modify_footnote.html),
etc.) and text formatting with
[`add_group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_styling.md)
before calling `add_group_colors()`.

## See also

- [`add_group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_styling.md)
  for text formatting only (stays gtsummary)

- [`get_group_rows()`](https://www.kyleGrealis.com/sumExtras/reference/get_group_rows.md)
  for identifying group header rows

- [`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
  for creating variable groups

- [`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)
  for additional gt-specific styling

## Examples

``` r
# \donttest{
# Basic usage - text formatting then color
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt) |>
  extras() |>
  gtsummary::add_variable_group_header(
    header = "Patient Characteristics",
    variables = age:stage
  ) |>
  add_group_styling() |>
  add_group_colors()


  
```
