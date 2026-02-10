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
  When provided, overrides `pval`, `overall`, and `last` arguments.

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
before merging — all formatting carries through.

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

Full features (overall, p-values) require stratified `tbl_summary` or
`tbl_svysummary`. Regression and stacked tables get basic formatting
only (bold labels, clean header). Unsupported features trigger a
warning.

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

\# Custom header text
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\> extras(header = "Variable")

[TABLE]

\# Customize add_p() behavior
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\> extras(.add_p_args =
[list](https://rdrr.io/r/base/list.html)( test =
[list](https://rdrr.io/r/base/list.html)([all_continuous](https://www.danieldsjoberg.com/gtsummary/reference/select_helpers.html)()
~ "t.test"), pvalue_fun = ~
gtsummary::[style_pvalue](https://www.danieldsjoberg.com/gtsummary/reference/style_pvalue.html)(.x,
digits = 2) )) \#\> Warning: Failed to add p-values. \#\> ✖ Error: Error
processing \`test\` argument. \#\> ! Caused by error in
\`all_continuous()\`: ! could not find function \#\> "all_continuous"
\#\> ℹ Select among columns "age", "marker", "stage", "grade",
"response", "death", \#\> and "ttdeath" \#\> ℹ Continuing without
p-values.

[TABLE]

\# Chain with other functions \# Create required dictionary first
dictionary \<-
tibble::[tribble](https://tibble.tidyverse.org/reference/tribble.html)(
~Variable, ~Description, "record_id", "Participant ID", "age", "Age at
enrollment", "sex", "Biological sex" )
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\>
[add_auto_labels](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)()
\|\> extras(pval = TRUE) \|\>
[add_group_styling](https://www.kyleGrealis.com/sumExtras/reference/add_group_styling.md)()

[TABLE]

\# }
