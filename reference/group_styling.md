# Apply styling to variable group headers in gtsummary tables

Adds customizable formatting to variable group headers in gtsummary
tables. Variable groups are created using
[`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
to organize variables into sections. This function enhances table
readability by making group headers visually distinct from individual
variable labels.

## Usage

``` r
group_styling(tbl, format = c("bold", "italic"))
```

## Arguments

- tbl:

  A gtsummary table object (e.g., from
  [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
  [`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html))

- format:

  Character vector specifying text formatting. Options include `"bold"`,
  `"italic"`, or both. Default is `c("bold", "italic")`.

## Value

A gtsummary table object with specified formatting applied to variable
group headers

## Details

The function targets rows where `row_type == 'variable_group'` and
applies the specified text formatting to the label column. This is
particularly useful for tables with multiple sections or stratified
analyses where clear visual hierarchy improves interpretation.

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
  group_styling()


  

Characteristic
```

**Drug A**  
N = 98¹

**Drug B**  
N = 102¹

Patient Characteristics

  

  

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

\# Bold only
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt, include = [c](https://rdrr.io/r/base/c.html)(age, marker)) \|\>
gtsummary::[add_variable_group_header](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)(
header = "Demographics", variables = age:marker ) \|\>
group_styling(format = "bold")

[TABLE]

\# Multiple group headers
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\>
gtsummary::[add_variable_group_header](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)(
header = "Demographics", variables = age ) \|\>
gtsummary::[add_variable_group_header](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)(
header = "Clinical Measures", variables = marker:response ) \|\>
group_styling()

[TABLE]

\# }
