# Add background colors to group headers with automatic gt conversion

Convenience function that adds background colors to variable group
headers and converts the table to gt. This is a terminal operation that
combines
[`get_group_rows()`](https://kyleGrealis.com/sumExtras/reference/get_group_rows.md),
[`gtsummary::as_gt()`](https://www.danieldsjoberg.com/gtsummary/reference/as_gt.html),
and [`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)
into a single pipeable function.

For text formatting (bold/italic), use
[`add_group_styling()`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)
before calling this function. This composable design keeps each function
focused on doing one thing well.

## Usage

``` r
add_group_colors(tbl, color = "#E8E8E8")
```

## Arguments

- tbl:

  A gtsummary table object with variable group headers created by
  [`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)

- color:

  Background color for group headers. Default `"#E8E8E8"` (light gray).
  Can be any valid CSS color (hex code, color name, rgb(), etc.).

## Value

A gt table object with colored group headers. **Note:** This is a
terminal operation that converts to gt. You cannot pipe to additional
gtsummary functions after calling this function.

## Details

This function:

1.  Identifies group header rows with
    [`get_group_rows()`](https://kyleGrealis.com/sumExtras/reference/get_group_rows.md)

2.  Converts the table to gt with
    [`gtsummary::as_gt()`](https://www.danieldsjoberg.com/gtsummary/reference/as_gt.html)

3.  Applies background color using
    [`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)

Since this function converts to gt, it should be used as the final
styling step in your pipeline. Apply all gtsummary functions (like
[`modify_caption()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_caption.html),
[`modify_footnote()`](https://www.danieldsjoberg.com/gtsummary/reference/deprecated_modify_footnote.html),
etc.) and text formatting with
[`add_group_styling()`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)
before calling `add_group_colors()`.

## See also

- [`add_group_styling()`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)
  for text formatting only (stays gtsummary)

- [`get_group_rows()`](https://kyleGrealis.com/sumExtras/reference/get_group_rows.md)
  for identifying group header rows

- [`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
  for creating variable groups

- [`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)
  for additional gt-specific styling

## Examples

``` r
# \donttest{
# Basic usage - text formatting then color
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt) |>
  extras() |>
  gtsummary::add_variable_group_header(
    header = "Patient Characteristics",
    variables = age:stage
  ) |>
  add_group_styling() |>
  add_group_colors()


  
```

**Overall**  
N = 200¹

**Drug A**  
N = 98¹

**Drug B**  
N = 102¹

**p-value**²

Patient Characteristics

  

  

  

  

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

\# Custom color - light blue
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\>
[extras](https://kyleGrealis.com/sumExtras/reference/extras.md)() \|\>
gtsummary::[add_variable_group_header](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)(
header = "Baseline Characteristics", variables = age:marker ) \|\>
[add_group_styling](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)()
\|\> add_group_colors(color = "#E3F2FD")

[TABLE]

\# Bold only formatting with custom color
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\>
[extras](https://kyleGrealis.com/sumExtras/reference/extras.md)() \|\>
gtsummary::[add_variable_group_header](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)(
header = "Clinical Measures", variables = marker:stage ) \|\>
[add_group_styling](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)(format
= "bold") \|\> add_group_colors(color = "#FFF9E6")

[TABLE]

\# Multiple group headers
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt) \|\>
[extras](https://kyleGrealis.com/sumExtras/reference/extras.md)() \|\>
gtsummary::[add_variable_group_header](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)(
header = "Demographics", variables = age ) \|\>
gtsummary::[add_variable_group_header](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)(
header = "Disease Measures", variables = marker:response ) \|\>
[add_group_styling](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)()
\|\> add_group_colors(color = "#E8E8E8")

[TABLE]

\# }
