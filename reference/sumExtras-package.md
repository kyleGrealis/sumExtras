# sumExtras: Extra Functions for 'gtsummary' Table Styling

Provides additional convenience functions for 'gtsummary' (Sjoberg et
al. (2021)
[doi:10.32614/RJ-2021-053](https://doi.org/10.32614/RJ-2021-053) ) &
'gt' tables, including automatic variable labeling from dictionaries,
standardized missing value display, and consistent formatting helpers
for streamlined table styling workflows.

## Main Functions

- [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md) -
  Overall columns, p-values, clean styling

- [`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md) -
  Standardize missing value display

- [`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md) -
  Automatic variable labeling

- [`use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md) -
  JAMA compact theme for gtsummary

- [`theme_gt_compact()`](https://www.kyleGrealis.com/sumExtras/reference/theme_gt_compact.md) -
  JAMA-style compact theme for gt

- [`add_group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_styling.md) -
  Format grouped table headers

- [`add_group_colors()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_colors.md) -
  Group colors with gt conversion

## Important Notes on Package Dependencies

**gtsummary Internals:** This package depends on internal structures of
the gtsummary package (specifically `tbl$call_list`, `tbl$inputs`, and
`tbl$table_body`). Compatibility is maintained where possible, but major
gtsummary updates may require sumExtras updates.

**Minimum Versions:** Requires gtsummary \>= 1.7.0 and gt \>= 0.9.0 for
the necessary internal structures.

**Testing:** Test your workflows after gtsummary updates, especially
major version changes.

## See also

- gtsummary package: <https://www.danieldsjoberg.com/gtsummary/>

- Package website: <https://www.kyleGrealis.com/sumExtras/>

## Author

**Maintainer**: Kyle Grealis <kyleGrealis@proton.me>
([ORCID](https://orcid.org/0000-0002-9223-8854))

Other contributors:

- Raymond Balise <balise@miami.edu>
  ([ORCID](https://orcid.org/0000-0002-9856-5901)) \[contributor\]

- Daniel Maya <dheal.maya@gmail.com>
  ([ORCID](https://orcid.org/0000-0002-0164-7768)) \[contributor\]

## Examples

``` r
# \donttest{
# Basic workflow with extras()
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt) |>
  extras()


  
```
