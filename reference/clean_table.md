# Standardize missing value display across all gtsummary table types

Replaces various missing value representations with a consistent symbol
(default `"---"`) so it is easier to tell actual data from missing or
undefined values.

Works with all gtsummary table types, including stacked tables
(`tbl_strata`) and survey-weighted summaries (`tbl_svysummary`). Handles
tables with or without the standard `var_type` column.

## Usage

``` r
clean_table(tbl, symbol = "---")
```

## Arguments

- tbl:

  A gtsummary table object (e.g., from
  [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
  [`tbl_svysummary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_svysummary.html),
  [`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html),
  or
  [`tbl_strata()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_strata.html))

- symbol:

  Character string to replace missing values with. Default is `"---"`
  (em-dash style). Common alternatives: `"\u2014"` (em-dash), `"\u2013"`
  (en-dash), `"--"`, or `"N/A"`.

## Value

A gtsummary table object with standardized missing value display

## Details

The function uses
[`gtsummary::modify_table_body()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_table_body.html)
to transform character columns and replace missing, undefined, and
zero-valued patterns with a consistent symbol. Matched patterns include:

- Literal `NA` and `Inf` / `-Inf` values

- Count/percent pairs: `"0 (0%)"`, `"0 (NA%)"`, `"0 (NA)"`, `"NA (0)"`,
  `"NA (NA)"`

- Decimal variants: `"0.00 (0.00)"`, `"0.00% (0.00)"`, `"0% (0.000)"`

- Paired values: `"NA, NA"`

- Confidence intervals: `"NA (NA, NA)"`, `"0% (0.000) (0%, 0%)"`,
  `"0.00 (0.00) (0.00, 0.00)"`, and similar zero-CI patterns

Replacing these patterns with a single symbol keeps the table easier to
read.

Note: The function checks for the presence of `var_type` column before
applying
[`modify_missing_symbol()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_missing_symbol.html).
This allows it to work with `tbl_strata` objects which use `var_type_1`,
`var_type_2`, etc. instead of `var_type`.

## See also

- [`gtsummary::modify_table_body()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_table_body.html)
  for general table body modifications

- [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  which includes `clean_table()` in its styling pipeline

## Examples

``` r
# \donttest{
# Basic usage - clean missing values in summary table
demo_trial <- gtsummary::trial |>
  dplyr::mutate(
    age = dplyr::if_else(trt == "Drug B", 0, age),
    marker = dplyr::if_else(trt == "Drug A", NA, marker)
  ) |>
  dplyr::select(trt, age, marker)

demo_trial |>
  gtsummary::tbl_summary(by = trt) |>
  clean_table()


  

Characteristic
```
