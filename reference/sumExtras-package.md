# sumExtras: Extra Functions for 'gtsummary' Table Styling

Provides additional convenience functions for gtsummary & gt tables,
including automatic variable labeling from dictionaries, standardized
missing value display, and consistent formatting helpers for streamlined
table styling workflows.

Provides additional convenience functions for gtsummary & gt tables,
including automatic variable labeling from dictionaries, standardized
missing value display, and consistent formatting helpers for streamlined
table styling workflows.

## Main Functions

- [`extras()`](https://kyleGrealis.com/sumExtras/reference/extras.md) -
  The signature function that adds overall columns, p-values, and clean
  styling

- [`clean_table()`](https://kyleGrealis.com/sumExtras/reference/clean_table.md) -
  Standardizes missing value display

- [`add_auto_labels()`](https://kyleGrealis.com/sumExtras/reference/add_auto_labels.md) -
  Smart automatic variable labeling from dictionaries or label
  attributes

- [`apply_labels_from_dictionary()`](https://kyleGrealis.com/sumExtras/reference/apply_labels_from_dictionary.md) -
  Set label attributes on data for cross-package workflows

- [`use_jama_theme()`](https://kyleGrealis.com/sumExtras/reference/use_jama_theme.md) -
  Apply JAMA compact theme to gtsummary tables

- [`theme_gt_compact()`](https://kyleGrealis.com/sumExtras/reference/theme_gt_compact.md) -
  JAMA-style compact themes for gt tables

- [`add_group_styling()`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md) -
  Enhanced text formatting for grouped tables

- [`add_group_colors()`](https://kyleGrealis.com/sumExtras/reference/add_group_colors.md) -
  Convenience function for group colors with automatic gt conversion

## Important Notes on Package Dependencies

**gtsummary Internals:** This package depends on internal structures of
the gtsummary package (specifically `tbl$call_list`, `tbl$inputs`, and
`tbl$table_body`). While we make every effort to maintain compatibility,
major updates to gtsummary may require corresponding updates to
sumExtras.

**Minimum Versions:** Requires gtsummary \>= 1.7.0 and gt \>= 0.9.0.
These minimum versions ensure the necessary internal structures are
available.

**Testing:** We recommend testing your workflows after any gtsummary
updates, especially major version changes.

## See also

- gtsummary package: <https://www.danieldsjoberg.com/gtsummary/>

- Package website: <https://kyleGrealis.com/sumExtras/>

## Author

**Maintainer**: Kyle Grealis <kyleGrealis@proton.me>
([ORCID](https://orcid.org/0000-0002-9223-8854))

Other contributors:

- Raymond Balise <balise@miami.edu>
  ([ORCID](https://orcid.org/0000-0002-9856-5901)) \[contributor\]

## Examples

``` r
# \donttest{
# Basic workflow with extras()
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt) |>
  extras()


  
```

**Overall**  
N = 200¹

**Drug A**  
N = 98¹

**Drug B**  
N = 102¹

**p-value**²

Age

47 (38, 57)

46 (37, 60)

48 (39, 56)

0.718

    Unknown

11

7

4

  

Marker Level (ng/mL)

0.64 (0.22, 1.41)

0.84 (0.23, 1.60)

0.52 (0.18, 1.21)

0.085

    Unknown

10

6

4

  

T Stage

  

  

  

0.866

    T1

53 (27%)

28 (29%)

25 (25%)

  

    T2

54 (27%)

25 (26%)

29 (28%)

  

    T3

43 (22%)

22 (22%)

21 (21%)

  

    T4

50 (25%)

23 (23%)

27 (26%)

  

Grade

  

  

  

0.871

    I

68 (34%)

35 (36%)

33 (32%)

  

    II

68 (34%)

32 (33%)

36 (35%)

  

    III

64 (32%)

31 (32%)

33 (32%)

  

Tumor Response

61 (32%)

28 (29%)

33 (34%)

0.530

    Unknown

7

3

4

  

Patient Died

112 (56%)

52 (53%)

60 (59%)

0.412

Months to Death/Censor

22.4 (15.9, 24.0)

23.5 (17.4, 24.0)

21.2 (14.5, 24.0)

0.145

¹ Median (Q1, Q3); n (%)

² Wilcoxon rank sum test; Pearson’s Chi-squared test

\# Complete workflow with styling
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt, include = [c](https://rdrr.io/r/base/c.html)(age, marker, grade,
stage)) \|\>
[extras](https://kyleGrealis.com/sumExtras/reference/extras.md)() \|\>
gtsummary::[add_variable_group_header](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)(
header = "Patient Characteristics", variables = age:stage ) \|\>
[add_group_styling](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)()
\|\>
[add_group_colors](https://kyleGrealis.com/sumExtras/reference/add_group_colors.md)()

[TABLE]

\# }
