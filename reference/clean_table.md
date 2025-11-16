# Standardize missing value display across all gtsummary table types

Improves table readability by replacing various missing value
representations with a consistent "–" symbol. This makes it easier to
distinguish between actual data and missing/undefined values in summary
tables, creating a cleaner and more professional appearance.

Works seamlessly with all gtsummary table types, including stacked
tables (`tbl_strata`) and survey-weighted summaries (`tbl_svysummary`).
Automatically handles tables with or without the standard `var_type`
column.

## Usage

``` r
clean_table(tbl)
```

## Arguments

- tbl:

  A gtsummary table object (e.g., from
  [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
  [`tbl_svysummary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_svysummary.html),
  [`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html),
  or
  [`tbl_strata()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_strata.html))

## Value

A gtsummary table object with standardized missing value display

## Details

The function uses
[`gtsummary::modify_table_body()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_table_body.html)
to transform character columns and replace common missing value patterns
with "–":

- `"0 (NA%)"` - No events occurred and percentages cannot be calculated

- `"NA (NA)"` - Completely missing data for both count and percentage

- `"0 (0%)"` - Zero counts with zero percentage

- `"NA (NA, NA)"` - Missing data with confidence intervals

- `"NA, NA"` - Missing paired values (e.g., median and IQR)

This standardization makes tables more scannable and reduces visual
clutter from various "empty" data representations.

Note: The function checks for the presence of `var_type` column before
applying
[`modify_missing_symbol()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_missing_symbol.html).
This allows it to work seamlessly with `tbl_strata` objects which use
`var_type_1`, `var_type_2`, etc. instead of `var_type`.

## See also

- [`gtsummary::modify_table_body()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_table_body.html)
  for general table body modifications

- [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  which includes `clean_table()` in its styling pipeline

## Examples

``` r
# \donttest{
# Basic usage - clean missing values in summary table
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt) |>
  clean_table()


  

Characteristic
```

**Drug A**  
N = 98¹

**Drug B**  
N = 102¹

Age

46 (37, 60)

48 (39, 56)

    Unknown

7

4

Marker Level (ng/mL)

0.84 (0.23, 1.60)

0.52 (0.18, 1.21)

    Unknown

6

4

T Stage

  

  

    T1

28 (29%)

25 (25%)

    T2

25 (26%)

29 (28%)

    T3

22 (22%)

21 (21%)

    T4

23 (23%)

27 (26%)

Grade

  

  

    I

35 (36%)

33 (32%)

    II

32 (33%)

36 (35%)

    III

31 (32%)

33 (32%)

Tumor Response

28 (29%)

33 (34%)

    Unknown

3

4

Patient Died

52 (53%)

60 (59%)

Months to Death/Censor

23.5 (17.4, 24.0)

21.2 (14.5, 24.0)

¹ Median (Q1, Q3); n (%)

\# Often used as part of a styling pipeline \# Create a test dictionary
for add_auto_labels(): dictionary \<-
tibble::[tribble](https://tibble.tidyverse.org/reference/tribble.html)(
~Variable, ~Description, 'age', 'Age at enrollment', 'stage', 'T Stage',
'grade', 'Grade', 'response', 'Tumor Response' )
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\>
[add_auto_labels](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)()
\|\>
[extras](https://www.kyleGrealis.com/sumExtras/reference/extras.md)()
\|\> clean_table() \#\> Warning: Failed to add overall column. \#\> ✖
Error: An error occured in \`add_overall()\`, and the overall statistic
cannot be \#\> added. \#\> Have variable labels changed since the
original call to \`tbl_summary()\`? \#\> ℹ Continuing without overall
column.

[TABLE]

\# Works with regression tables too
[lm](https://rdrr.io/r/stats/lm.html)(age ~ trt + grade, data =
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html))
\|\>
gtsummary::[tbl_regression](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html)()
\|\> clean_table()

[TABLE]

\# }
