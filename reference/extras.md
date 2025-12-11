# Add standard styling and formatting to gtsummary tables

Applies a consistent set of formatting options to gtsummary tables
including overall column, bold labels, clean headers, and optional
p-values. Streamlines the common workflow of adding multiple formatting
functions. The function always succeeds by applying what works and
warning about unsupported features.

## Usage

``` r
extras(tbl, pval = TRUE, overall = TRUE, last = FALSE, .args = NULL)
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

- .args:

  Optional list of arguments to use instead of individual parameters.
  When provided, overrides `pval`, `overall`, and `last` arguments.

## Value

A gtsummary table object with standard formatting applied

## Details

The function applies the following modifications:

- Bolds variable labels for emphasis (all table types)

- Removes the "Characteristic" header label (all table types)

- Adds an "Overall" column (only stratified summary tables)

- Optionally adds p-values (only stratified summary tables)

- Applies
  [`clean_table()`](https://kyleGrealis.com/sumExtras/reference/clean_table.md)
  styling (all table types)

The function automatically detects whether the input table is stratified
(has a `by` argument) and what type of table it is (tbl_summary,
tbl_regression, tbl_strata, etc.).

For tables that don't support overall columns or p-values
(non-stratified tables, regression tables, or stacked tables), the
function will issue a warning and continue by applying only the
universally supported features (bold_labels and modify_header). This
ensures the function always succeeds rather than failing midway through
the pipeline.

If any individual formatting step fails (e.g., due to unexpected table
structure), the function will issue a warning and continue without that
feature. This provides robustness while keeping you informed of what was
skipped.

## Table Type Support

The function applies features based on table type and stratification:

- **bold_labels()** and **modify_header()**: Work on all table types

- **add_overall()**: Only works on stratified summary tables
  (tbl_summary with `by`)

- **add_p()**: Only works on stratified summary tables (tbl_summary with
  `by`)

**Full feature support:** tbl_summary and tbl_svysummary with `by`
argument

**Partial support (basic formatting only):** tbl_regression, tbl_strata,
and non-stratified tables. When applied to these table types and
overall/pval = TRUE, the function warns about unsupported features but
applies the formatting that works.

## See also

- [`gtsummary::add_overall()`](https://www.danieldsjoberg.com/gtsummary/reference/add_overall.html)
  for adding overall columns

- [`gtsummary::add_p()`](https://www.danieldsjoberg.com/gtsummary/reference/add_p.html)
  for adding p-values

- [`clean_table()`](https://kyleGrealis.com/sumExtras/reference/clean_table.md)
  for additional table styling

## Examples

``` r
# \donttest{
# With p-values (default)
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

\# Using .args list extra_args \<-
[list](https://rdrr.io/r/base/list.html)(pval = TRUE, overall = TRUE,
last = FALSE)
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\> extras(.args = extra_args)

[TABLE]

\# Without p-values
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\> extras(pval = FALSE)

[TABLE]

\# Chain with other functions \# Create required dictionary first
dictionary \<-
tibble::[tribble](https://tibble.tidyverse.org/reference/tribble.html)(
~Variable, ~Description, 'record_id', 'Participant ID', 'age', 'Age at
enrollment', 'sex', 'Biological sex' )
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\>
[add_auto_labels](https://kyleGrealis.com/sumExtras/reference/add_auto_labels.md)()
\|\> extras(pval = TRUE) \|\>
[group_styling](https://kyleGrealis.com/sumExtras/reference/group_styling.md)()
\#\> Warning: Failed to add overall column. \#\> ✖ Error: An error
occured in \`add_overall()\`, and the overall statistic cannot be \#\>
added. \#\> Have variable labels changed since the original call to
\`tbl_summary()\`? \#\> ℹ Continuing without overall column.

[TABLE]

\# }
