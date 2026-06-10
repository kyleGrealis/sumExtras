# Apply styling to variable group headers in gtsummary tables

Adds customizable formatting to variable group headers in gtsummary
tables. Variable groups are created using
[`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
to organize variables into sections. This function makes group headers
stand out from individual variable labels.

## Usage

``` r
add_group_styling(tbl, format = c("bold", "italic"), indent_labels = 0L)
```

## Arguments

- tbl:

  A gtsummary table object (e.g., from
  [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
  [`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html))

- format:

  Character vector specifying text formatting. Options include `"bold"`,
  `"italic"`, or both. Default is `c("bold", "italic")`.

- indent_labels:

  Integer specifying indentation level (in spaces) for variable labels
  under group headers. Default is `0L` (left-aligned). Set to `4L` to
  preserve gtsummary's default group indentation, or use any
  non-negative integer for custom spacing.

## Value

A gtsummary table object with specified formatting applied to variable
group headers

## Details

The function targets rows where `row_type == 'variable_group'` and
applies the specified text formatting to the label column.

By default, variable labels are left-aligned (`indent_labels = 0L`) to
distinguish them from categorical levels and statistics. Use
`indent_labels = 4L` to preserve the default gtsummary behavior where
grouped variables are indented under their group headers.

## See also

- [`gtsummary::modify_table_styling()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_table_styling.html)
  for general table styling options

- [`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
  for creating variable group headers

## Examples

``` r
# \donttest{
# Default formatting (bold and italic)
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
  gtsummary::add_variable_group_header(
    header = "Patient Characteristics",
    variables = age:grade
  ) |>
  add_group_styling()


  

Characteristic
```
