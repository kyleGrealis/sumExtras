# Add automatic labels from dictionary to a gtsummary table

Automatically apply variable labels from a dictionary to `tbl_summary`
or `tbl_svysummary` objects. Intelligently preserves manual label
overrides set in the original table call while applying dictionary
labels only to unlabeled variables. The dictionary can be passed
explicitly or will be searched for in the calling environment. See
[`create_labels()`](https://www.kyleGrealis.com/sumExtras/reference/create_labels.md)
for dictionary format requirements.

## Usage

``` r
add_auto_labels(tbl, dictionary = NULL)
```

## Arguments

- tbl:

  A gtsummary table object created by
  [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
  [`tbl_svysummary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_svysummary.html),
  or
  [`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html)

- dictionary:

  Optional. A data frame or tibble with `Variable` and `Description`
  columns. If not provided, the function will search for a `dictionary`
  object in the calling environment.

## Value

A gtsummary table object with labels applied. Manual labels set via
`label = list(...)` in the original table call are preserved.

## Details

The function intelligently applies labels:

- Dictionary labels are applied to variables without manual overrides

- Manual labels set via `label = list(variable ~ "Custom Label")` in
  [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
  [`tbl_svysummary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_svysummary.html),
  or
  [`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html)
  are preserved

- Only variables present in both the table and dictionary receive labels

- Variables not in the dictionary are left unchanged

## See also

[`create_labels()`](https://www.kyleGrealis.com/sumExtras/reference/create_labels.md)
for dictionary requirements

Other labeling functions:
[`create_labels()`](https://www.kyleGrealis.com/sumExtras/reference/create_labels.md)

## Examples

``` r
# \donttest{
# Create a dictionary
my_dict <- tibble::tribble(
  ~Variable, ~Description,
  "age", "Age at Enrollment",
  "trt", "Treatment Group",
  "grade", "Grade"
)

# Basic usage: apply dictionary labels to all variables
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt, include = c(age, grade, trt)) |>
  add_auto_labels(dictionary = my_dict)


  

Characteristic
```

**Drug A**  
N = 98¹

**Drug B**  
N = 102¹

Age at Enrollment

46 (37, 60)

48 (39, 56)

    Unknown

7

4

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

¹ Median (Q1, Q3); n (%)

\# Manual label overrides are preserved
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(
by = trt, include = [c](https://rdrr.io/r/base/c.html)(age, grade, trt),
label = [list](https://rdrr.io/r/base/list.html)(age ~ "Custom Age
Label") \# This override is kept ) \|\> add_auto_labels(dictionary =
my_dict) \# grade and trt get dict labels

[TABLE]

\# Works with tbl_svysummary (if survey package is available) \#
survey_design \<- survey::svydesign(...) \# survey_design \|\> \#
gtsummary::tbl_svysummary(include = c(age, grade)) \|\> \#
add_auto_labels(dictionary = my_dict) \# Or search for dictionary in
environment dictionary \<- my_dict
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt, include = [c](https://rdrr.io/r/base/c.html)(age, grade)) \|\>
add_auto_labels()

[TABLE]

\# }
