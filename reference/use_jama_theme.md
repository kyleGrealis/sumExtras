# Apply JAMA Compact Theme to gtsummary Tables

Sets the global gtsummary theme to the JAMA (Journal of the American
Medical Association) compact style. Reduces padding and applies JAMA
journal styling. The theme stays active for the entire R session or
until changed with another theme.

## Usage

``` r
use_jama_theme(quiet = TRUE)
```

## Arguments

- quiet:

  Logical. If `FALSE`, prints a message confirming theme application.
  Default is `TRUE` (silent).

## Value

Invisibly returns the theme list object from
`gtsummary::theme_gtsummary_compact("jama")`. The theme is applied
globally via
[`gtsummary::set_gtsummary_theme()`](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html),
affecting all subsequent gtsummary tables created in the session.

## Details

The JAMA compact theme applies formatting standards from the Journal of
the American Medical Association: 13px font, 1px cell padding, bold
column headers, and clean borders.

The function checks for the gtsummary package and will stop with an
informative error if it is not installed. The theme is applied globally
and will affect all gtsummary tables created after calling this
function, including
[`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
[`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html),
[`tbl_cross()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_cross.html),
[`tbl_strata()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_strata.html),
and related functions.

For visual consistency with regular gt tables, use
[`theme_gt_compact()`](https://www.kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)
which replicates the same styling for non-gtsummary tables.

## See also

- [`theme_gt_compact`](https://www.kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)
  for JAMA-style gt tables

- [`extras`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  for standard sumExtras table formatting

- [`gtsummary::theme_gtsummary_compact()`](https://www.danieldsjoberg.com/gtsummary/reference/theme_gtsummary.html)
  for other compact theme options

- [`gtsummary::set_gtsummary_theme()`](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html)
  for setting custom themes

- [`gtsummary::reset_gtsummary_theme()`](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html)
  for resetting to default theme

## Examples

``` r
# \donttest{
# Apply theme at the start of your analysis
use_jama_theme()

# All subsequent gtsummary tables will use JAMA formatting
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt)


  

Characteristic
```
