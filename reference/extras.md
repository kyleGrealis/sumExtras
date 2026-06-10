# Add standard styling and formatting to gtsummary tables

Applies a consistent set of formatting options to gtsummary tables
including overall column, bold labels, clean headers, and optional
p-values. Wraps the common workflow of adding multiple formatting
functions into one call. Always succeeds by applying what works and
warning about the rest.

## Usage

``` r
extras(
  tbl,
  pval = TRUE,
  overall = TRUE,
  last = FALSE,
  header = "",
  symbol = "---",
  .args = NULL,
  .add_p_args = NULL
)
```

## Arguments

- tbl:

  A gtsummary table object (e.g., from
  [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
  [`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html))

- pval:

  Logical indicating whether to add p-values. Default is `TRUE`. When
  `TRUE`, uses gtsummary's default statistical tests (Kruskal-Wallis for
  continuous variables with 3+ groups, chi-square for categorical
  variables).

- overall:

  Logical indicating whether to add overall column

- last:

  Logical indicating if Overall column should be last. Aligns with
  default from
  [`gtsummary::add_overall()`](https://www.danieldsjoberg.com/gtsummary/reference/add_overall.html).

- header:

  Character string for the label column header. Default is `""` (blank).
  Use `"Characteristic"` or any custom text.

- symbol:

  Character string for missing value replacement in
  [`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md).
  Default is `"---"`. Passed directly to `clean_table(symbol = ...)`.

- .args:

  Optional list of arguments to use instead of individual parameters.
  When provided, overrides `pval`, `overall`, `last`, `header`, and
  `symbol` arguments.

- .add_p_args:

  Optional named list of arguments to pass to
  [`gtsummary::add_p()`](https://www.danieldsjoberg.com/gtsummary/reference/add_p.html).
  Allows customization of statistical tests and p-value formatting.
  User-provided arguments override the default arguments (`pvalue_fun`
  and `test.args`). See
  [`gtsummary::add_p()`](https://www.danieldsjoberg.com/gtsummary/reference/add_p.html)
  documentation for available arguments.

## Value

A gtsummary table object with standard formatting applied

## Details

The function applies the following modifications (in order):

1.  Bolds variable labels for emphasis (all table types)

2.  Removes the "Characteristic" header label (all table types)

3.  Adds an "Overall" column (only stratified summary tables)

4.  Optionally adds p-values with bold significance (only stratified
    summary tables)

5.  Applies automatic labels if options are set (see Options section)

6.  Applies
    [`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
    styling (all table types)

The function automatically detects whether the input table is stratified
(has a `by` argument) and what type of table it is (tbl_summary,
tbl_regression, tbl_strata, etc.).

For tables that don't support overall columns or p-values
(non-stratified tables, regression tables, or stacked tables), the
function warns and applies only basic formatting (bold_labels and
modify_header).

For merged tables (`tbl_merge`), call `extras()` on each sub-table
before merging. All formatting carries through.

If any individual step fails (e.g., due to unexpected table structure),
the function warns and continues without that feature.

## Options

Set `options(sumExtras.auto_labels = TRUE)` for automatic labeling. See
[`vignette("options")`](https://www.kyleGrealis.com/sumExtras/articles/options.md)
for details.

## Pipeline Ordering

Call `extras()` before
[`add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
and
[`add_group_colors()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_colors.md)
last. See
[`vignette("sumExtras-intro")`](https://www.kyleGrealis.com/sumExtras/articles/sumExtras-intro.md).

## Table Type Support

Full features (overall, p-values, bold p-values) require a stratified
`tbl_summary` or `tbl_svysummary`. Regression tables get bold labels,
bold model p-values, header cleaning, and
[`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md).
Stacked (`tbl_strata`) and merged (`tbl_merge`) tables get bold labels,
header cleaning, and
[`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md).
Warnings only fire when the user explicitly requests unsupported
features (e.g., `overall = TRUE` on a non-stratified table).

## See also

- [`gtsummary::add_overall()`](https://www.danieldsjoberg.com/gtsummary/reference/add_overall.html)
  for adding overall columns

- [`gtsummary::add_p()`](https://www.danieldsjoberg.com/gtsummary/reference/add_p.html)
  for adding p-values

- [`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
  for additional table styling

## Examples

``` r
# \donttest{
# With p-values (default)
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt) |>
  extras()


  
```
