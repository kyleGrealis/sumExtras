# Get row numbers of variable group headers for gt styling

Extracts the row indices of variable group headers from a gtsummary
table. This is useful for applying background colors or other
gt-specific styling after converting a gtsummary table to gt with
[`as_gt()`](https://www.danieldsjoberg.com/gtsummary/reference/as_gt.html).

## Usage

``` r
get_group_rows(tbl)
```

## Arguments

- tbl:

  A gtsummary table object with variable group headers created by
  [`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)

## Value

An integer vector of row numbers where variable_group headers are
located

## Details

Variable group headers are identified by `row_type == 'variable_group'`
in the table body. The returned row numbers can be used with
[`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html) to
apply styling like background colors after converting to a gt table.

This function should be called BEFORE converting the table with
[`as_gt()`](https://www.danieldsjoberg.com/gtsummary/reference/as_gt.html),
as the row type information is only available in gtsummary table
objects.

## See also

- [`group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/group_styling.md)
  for applying text formatting to group headers

- [`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
  for creating variable groups

- [`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)
  for applying gt-specific styling

## Examples

``` r
# \donttest{
# Create table with variable groups
my_tbl <- gtsummary::trial |>
  gtsummary::tbl_summary(by = trt, include = c(age, marker, grade, stage)) |>
  gtsummary::add_variable_group_header(
    header = "Demographics",
    variables = age
  ) |>
  gtsummary::add_variable_group_header(
    header = "Clinical",
    variables = marker:stage
  ) |>
  group_styling()

# Get group row numbers before conversion
group_rows <- get_group_rows(my_tbl)

# Convert to gt and apply gray background
my_tbl |>
  gtsummary::as_gt() |>
  gt::tab_style(
    style = gt::cell_fill(color = "#E8E8E8"),
    locations = gt::cells_body(rows = group_rows)
  )


  

Characteristic
```

**Drug A**  
N = 98¹

**Drug B**  
N = 102¹

Demographics

  

  

Age

46 (37, 60)

48 (39, 56)

    Unknown

7

4

Clinical

  

  

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

¹ Median (Q1, Q3); n (%)

\# }
